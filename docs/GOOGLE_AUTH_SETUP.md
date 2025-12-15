# Google Authentication Setup

## Current Configuration

### Backend (.env)
```
GOOGLE_CLIENT_ID=1071453270740-qojgn6bfqf2dhinr2etkmd92f0has46n.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=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
```

### Frontend (google_config.dart)
```dart
webClientId = '1071453270740-qojgn6bfqf2dhinr2etkmd92f0has46n.apps.googleusercontent.com'
```

### Web (index.html)
```html
<meta name="google-signin-client_id" content="1071453270740-qojgn6bfqf2dhinr2etkmd92f0has46n.apps.googleusercontent.com">
```

## ✅ What's Configured

1. **Google Client ID** - Set in all required places
2. **Backend endpoint** - `/auth/google-login` ready
3. **Frontend screen** - Google login screen implemented
4. **Meta tag** - Added to web/index.html for web authentication

## 🔧 Required: Authorize Redirect URIs

You need to add these URIs in Google Cloud Console:

1. Go to: https://console.cloud.google.com
2. Select your project
3. Go to: APIs & Services > Credentials
4. Click on your OAuth 2.0 Client ID
5. Add these **Authorized JavaScript origins**:
   - `http://localhost:8080`
   - `http://localhost:3000`
   
6. Add these **Authorized redirect URIs**:
   - `http://localhost:8080`
   - `http://localhost:8080/auth/callback`
   - `http://localhost:3000/auth/google/callback`

## 🚀 How to Test

1. **Start servers** (already running):
   - Backend: http://localhost:3000 ✅
   - Frontend: http://localhost:8080 ✅

2. **Open app**: http://localhost:8080/#/

3. **Click "Sign in with Google"** button

4. **Expected flow**:
   - Google popup opens
   - Select your Google account
   - Grant permissions
   - Redirects back to app
   - Logged in successfully!

## 🐛 Troubleshooting

### Error: "redirect_uri_mismatch"
**Solution**: Add `http://localhost:8080` to Authorized JavaScript origins in Google Console

### Error: "popup_closed_by_user"
**Solution**: User cancelled - this is normal, try again

### Error: "idpiframe_initialization_failed"
**Solution**: 
- Clear browser cookies for localhost
- Make sure meta tag is in index.html
- Rebuild Flutter app

## 📝 Current Status

✅ Backend configured with Google OAuth
✅ Frontend has Google login screen
✅ Meta tag added to index.html
✅ Running on port 8080 only
⚠️ Need to verify redirect URIs in Google Console

## Next Steps

1. Rebuild Flutter app (to include meta tag)
2. Test Google login at http://localhost:8080
3. If redirect error, add URIs to Google Console
