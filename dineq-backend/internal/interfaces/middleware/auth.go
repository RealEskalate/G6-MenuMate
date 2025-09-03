package middleware

import (
	"net/http"
	"strings"
	"time"

	utils "github.com/RealEskalate/G6-MenuMate/Utils"
	"github.com/RealEskalate/G6-MenuMate/internal/bootstrap"
	"github.com/RealEskalate/G6-MenuMate/internal/domain"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

// AuthMiddleware checks if the user is authenticated by verifying the JWT token
func AuthMiddleware(env bootstrap.Env) gin.HandlerFunc {
	return func(c *gin.Context) {

		var tokenStr string
		var err error

		// Prefer Authorization header (Bearer) then fallback to cookie
		authHeader := c.GetHeader("Authorization")
		if len(authHeader) > 0 {
			lower := strings.ToLower(authHeader)
			if strings.HasPrefix(lower, "bearer ") && len(authHeader) > 7 {
				tokenStr = strings.TrimSpace(authHeader[7:])
				tokenStr = strings.Trim(tokenStr, "\"") // remove accidental quotes
			}
		}
		if tokenStr == "" { // fallback to cookie
			tokenStr, err = utils.GetCookie(c, "access_token")
			if err != nil || tokenStr == "" {
				c.JSON(http.StatusUnauthorized, gin.H{"error": "No access token found, please login again"})
				c.Abort()
				return
			}
		}

		// Parse and validate the JWT using MapClaims container
		claims := jwt.MapClaims{}
		token, err := jwt.ParseWithClaims(tokenStr, claims, func(t *jwt.Token) (interface{}, error) {
			if method, ok := t.Method.(*jwt.SigningMethodHMAC); !ok || method.Alg() != jwt.SigningMethodHS256.Alg() {
				return nil, jwt.ErrSignatureInvalid
			}
			return []byte(env.ATS), nil
		})
		if err != nil || !token.Valid {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
			return
		}
		_, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid token claims"})
			return
		}
		// check if the token has not expired
		if exp, ok := claims["exp"].(float64); !ok || exp < float64(time.Now().Unix()) {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "token expired"})
			return
		}

		// Set user ID and role in the context for further use
		if sub, ok := claims["sub"].(string); ok {
			c.Set("user_id", sub)
		}
		if role, ok := claims["role"].(string); ok {
			c.Set("role", role)
		}
		if isVerified, ok := claims["is_verified"].(bool); ok {
			c.Set("is_verified", isVerified)
		} else {
			c.Set("is_verified", false)
		}

		// Optional debug: if client sends X-Debug-Auth: true return early with claims
		if c.GetHeader("X-Debug-Auth") == "true" {
			c.JSON(http.StatusOK, gin.H{"debug_claims": claims})
			c.Abort()
			return
		}
		c.Next()
	}
}

func AdminOnly() gin.HandlerFunc {
	return func(c *gin.Context) {
		if c.GetString("role") != string(domain.RoleAdmin) {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "super_admin only"})
			return
		}
		c.Next()
	}
}

// manager only
func ManagerOnly() gin.HandlerFunc {
	return func(c *gin.Context) {
		if c.GetString("role") != string(domain.RoleManager) && c.GetString("role") != string(domain.RoleOwner) {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "This Operation is allowed for MANAGER only"})
			return
		}
		c.Next()
	}
}

func VerifiedUserOnly() gin.HandlerFunc {
	return func(c *gin.Context) {
		IsVerified := c.GetBool("is_verified")
		if !IsVerified {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "user not verified"})
			return
		}
		c.Next()
	}
}
