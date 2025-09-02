# How to Import and Use Postman Collection & Variables

## 📥 **Step 1: Import the Collection**

### Method 1: Using Postman Desktop App (Recommended)

1. **Open Postman** on your computer
2. **Click "Import"** button (top-left)
3. **Drag & Drop** or **Select** `MenuMate-API-Collection.json`
4. **Click "Import"** to confirm
5. ✅ Collection appears in your Collections panel

### Method 2: Using File Browser

1. In Postman, click **"Import"**
2. Click **"Upload Files"**
3. Navigate to your project folder: `/dinq-backend/postman-collections/`
4. Select `MenuMate-API-Collection.json`
5. Click **"Open"** → **"Import"**

## 🌍 **Step 2: Import Environment Variables**

### Import Development Environment

1. **Click "Import"** again
2. **Select** `environments/development.json`
3. **Click "Import"**
4. ✅ "MenuMate Development Environment" appears in Environments

### Import Production Environment (Optional)

1. **Click "Import"** again
2. **Select** `environments/production.json`
3. **Click "Import"**

## ⚙️ **Step 3: Select and Configure Environment**

### Select Environment

1. **Top-right dropdown** in Postman (next to the eye icon 👁️)
2. **Select**: "MenuMate Development Environment"
3. ✅ You'll see variables are now active

### Verify Environment Variables

1. **Click the eye icon** 👁️ next to the environment dropdown
2. **View variables** - you should see:
   ```
   base_url: http://localhost:8080/api/v1
   test_user_email: test@menumate.com
   access_token: (empty - will be filled automatically)
   ```

## 🔧 **Step 4: Using Variables in Requests**

### How Variables Work in Postman

Variables are used with double curly braces: `{{variable_name}}`

### Examples in Your Collection:

```
URL: {{base_url}}/auth/login
Header: Authorization: Bearer {{access_token}}
Body: {
  "email": "{{test_user_email}}",
  "password": "{{test_user_password}}"
}
```

### Variable Types in Your Collection:

#### 🤖 **Automatically Managed Variables**

These are set by scripts - **don't change manually**:

- `{{access_token}}` - JWT token (auto-refreshed)
- `{{refresh_token}}` - Refresh token
- `{{user_id}}` - Current user ID
- `{{token_expiry}}` - Token expiration time

#### ✋ **Manually Set Variables**

You can change these as needed:

- `{{base_url}}` - API base URL
- `{{test_user_email}}` - Test email
- `{{restaurant_slug}}` - Restaurant identifier

## 🧪 **Step 5: Test the Setup**

### Quick Test Workflow:

1. **First**: Test **Authentication** → **Register User**

   - Click **Send**
   - Should return `201 Created` with user data

2. **Then**: Test **Authentication** → **Login User**

   - Click **Send**
   - Should return `200 OK` with tokens
   - ✅ `access_token` automatically saved!

3. **Finally**: Test **Restaurant Management** → **Create Restaurant**
   - Click **Send**
   - Should return `201 Created`
   - Uses your saved `access_token` automatically

### Verify Auto-Token Management:

1. **After login**, click the **eye icon** 👁️
2. **Check**: `access_token` should now have a value
3. **Check**: `user_id` should be set
4. **Try**: Any protected endpoint - should work automatically!

## 📝 **Step 6: Managing Variables**

### View Current Variables

1. **Click eye icon** 👁️ next to environment name
2. **See all variables** and their current values

### Edit Variables Manually

1. **Click environment name** in the dropdown
2. **Edit values** in the table
3. **Save** changes

### Common Variables to Set Manually:

```
restaurant_slug: "the-italian-corner"
restaurant_id: "507f1f77bcf86cd799439012"
test_user_email: "your-test@email.com"
```

## 🔄 **How Auto-Token Management Works**

### Pre-Request Script (Runs Before Each Request):

- Checks if `access_token` is expired
- If expired, automatically uses `refresh_token` to get new tokens
- Updates variables automatically

### Post-Response Script (Runs After Each Request):

- If response contains tokens (login/register), saves them automatically
- Extracts and saves `user_id` from responses
- Calculates and saves token expiry time

### No Manual Work Needed!

```
Login → Tokens Auto-Saved → All Future Requests Work
```

## 🛠 **Advanced Usage**

### Using Variables in Scripts

```javascript
// Get variable value
let baseUrl = pm.environment.get("base_url");

// Set variable value
pm.environment.set("restaurant_id", "new-id-123");

// Use in request URL
pm.request.url = baseUrl + "/restaurants/create";
```

### Dynamic Variables

Some variables update automatically:

```javascript
// These are set by collection scripts
pm.environment.set("access_token", responseJson.access_token);
pm.environment.set("user_id", responseJson.user.id);
```

## 🚨 **Troubleshooting**

### ❌ "Variable not found" error

**Problem**: Using `{{variable_name}}` but variable doesn't exist
**Solution**:

1. Check environment is selected
2. Check variable name spelling
3. Check if variable exists in environment

### ❌ "401 Unauthorized" on protected endpoints

**Problem**: No valid access token
**Solution**:

1. Run **Login User** request first
2. Check `access_token` variable has value
3. Verify environment is selected

### ❌ Variables not updating automatically

**Problem**: Scripts not running
**Solution**:

1. Check if scripts are enabled in Postman settings
2. Look at Postman Console for script errors
3. Re-import collection if needed

### ❌ Environment variables are empty

**Problem**: Environment not properly imported
**Solution**:

1. Re-import environment file
2. Make sure to select it in dropdown
3. Check file path is correct

## 💡 **Pro Tips**

### 1. **Use Multiple Environments**

- Development: `http://localhost:8080`
- Staging: `https://staging-api.menumate.com`
- Production: `https://api.menumate.com`

### 2. **Environment Switching**

Switch environments without changing requests:

- Same requests work on dev/staging/prod
- Just change environment dropdown

### 3. **Variable Scoping**

Variable priority (highest to lowest):

1. Local variables (request-specific)
2. Environment variables
3. Global variables
4. Collection variables

### 4. **Script Debugging**

View script output:

1. **View** → **Show Postman Console**
2. **See script logs** and errors
3. **Debug variable values**

## 📋 **Variable Reference**

### Complete Variable List:

| Variable             | Type   | Description            | Example Value                  |
| -------------------- | ------ | ---------------------- | ------------------------------ |
| `base_url`           | Manual | API base URL           | `http://localhost:8080/api/v1` |
| `web_base_url`       | Manual | Frontend URL           | `http://localhost:3000`        |
| `access_token`       | Auto   | JWT access token       | `eyJhbGciOiJIUzI1NiIs...`      |
| `refresh_token`      | Auto   | JWT refresh token      | `eyJhbGciOiJIUzI1NiIs...`      |
| `token_expiry`       | Auto   | Token expiry timestamp | `1640995200000`                |
| `user_id`            | Auto   | Current user ID        | `507f1f77bcf86cd799439011`     |
| `restaurant_id`      | Manual | Restaurant for testing | `507f1f77bcf86cd799439012`     |
| `restaurant_slug`    | Manual | Restaurant slug        | `the-italian-corner`           |
| `test_user_email`    | Manual | Test user email        | `test@menumate.com`            |
| `test_user_password` | Manual | Test user password     | `testpassword123`              |
| `admin_email`        | Manual | Admin email            | `admin@menumate.com`           |
| `admin_password`     | Manual | Admin password         | `adminpassword123`             |

---

## 🎉 **You're All Set!**

Your Postman collection is now ready with:

- ✅ **Auto-token management**
- ✅ **Environment variables**
- ✅ **Pre-filled test data**
- ✅ **Production-ready structure**

**Start testing your API immediately!** 🚀
