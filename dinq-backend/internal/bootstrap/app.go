package bootstrap

import (
	"context"

	mongo "github.com/RealEskalate/G6-MenuMate/internal/infrastructure/database"
)

type Application struct {
	Env   *Env
	Mongo mongo.Client
}

func InitApp() (*Application, error) {
	env, err := NewEnv()
	if err != nil {
		return nil, err
	}

	mongoClient, err := mongo.NewClient(env.DB_Uri)
	if err != nil {
		return nil, err
	}

	app := &Application{
		Env:   env,
		Mongo: mongoClient,
	}

	// Ensure indexes early (non-fatal on partial failures)
	mongo.EnsureIndexes(mongoClient, env.DB_Name, mongo.IndexConfig{
		RestaurantCollection:    env.RestaurantCollection,
		UserCollection:          env.UserCollection,
		RefreshTokenCollection:  env.RefreshTokenCollection,
		PasswordResetCollection: env.PasswordResetCollection,
		OtpCollection:           env.OtpCollection,
	})

	return app, nil
}

func (app *Application) CloseDBConnection() {
	if app.Mongo != nil {
		_ = app.Mongo.Disconnect(context.TODO())
	}
}
