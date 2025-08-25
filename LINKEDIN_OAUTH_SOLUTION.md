# LinkedIn OAuth Redirect URI Solution

## Problem
LinkedIn requires HTTPS redirect URIs for security reasons and doesn't allow custom URL schemes like `linkedinverifier://auth` to be registered as authorized redirect URIs.

## Solution
We use a **two-step redirect process**:

1. **LinkedIn redirects to HTTPS**: LinkedIn redirects to your HTTPS domain (e.g., `https://yourdomain.com/linkedin-callback`)
2. **HTML page redirects to app**: The HTML page automatically redirects to your iOS app using the custom URL scheme

## How It Works

### Step 1: LinkedIn OAuth Flow
```
User → LinkedIn OAuth → LinkedIn redirects to https://yourdomain.com/linkedin-callback?code=AUTH_CODE&state=STATE
```

### Step 2: Web to App Redirect
```
https://yourdomain.com/linkedin-callback → linkedinverifier://auth?code=AUTH_CODE&state=STATE → iOS App
```

## Implementation Details

### 1. LinkedIn Developer Settings
- **Redirect URI**: `https://yourdomain.com/linkedin-callback`
- **Scope**: `r_liteprofile`
- **Response Type**: `code`

### 2. HTML Callback Page (`linkedin-callback.html`)
- Automatically extracts the authorization code from URL parameters
- Redirects to the iOS app using the custom URL scheme
- Provides fallback for users without the app installed
- Beautiful loading interface with LinkedIn branding

### 3. iOS App URL Scheme
- **Custom URL Scheme**: `linkedinverifier://`
- **Callback Path**: `linkedinverifier://auth`
- **Handling**: `AppDelegate.swift` processes the callback and posts a notification

### 4. App Flow
- `ContentView` listens for LinkedIn callback notifications
- `LinkedInVerificationViewModel` exchanges the code for an access token
- App fetches user profile data from LinkedIn API
- Displays verification status and profile information

## Setup Requirements

### Web Server
- **Domain**: Must have a valid SSL certificate
- **Path**: Host `linkedin-callback.html` at `/linkedin-callback`
- **HTTPS**: Required for LinkedIn OAuth

### iOS App
- **URL Scheme**: `linkedinverifier` (configured in `Info.plist`)
- **AppDelegate**: Handles URL scheme callbacks
- **Notification System**: Communicates between AppDelegate and SwiftUI views

## Security Benefits

1. **HTTPS Compliance**: Meets LinkedIn's security requirements
2. **Custom URL Scheme**: App-specific callback handling
3. **State Parameter**: Prevents CSRF attacks
4. **Secure Token Exchange**: Server-to-server communication for access tokens

## Alternative Solutions Considered

1. **Universal Links**: More complex setup, requires Apple App Site Association
2. **Deep Links**: Limited to specific LinkedIn app scenarios
3. **Web View**: Less secure, poor user experience
4. **Server Proxy**: Requires backend infrastructure

## Testing

### Web Page
- Visit `https://yourdomain.com/linkedin-callback`
- Should show loading interface
- Test with and without app installed

### iOS App
- Test URL scheme: `linkedinverifier://auth?code=test&state=test`
- Verify notification handling
- Test complete OAuth flow

## Troubleshooting

### Common Issues
1. **HTTPS Required**: Ensure your domain has valid SSL certificate
2. **Path Mismatch**: LinkedIn redirect URI must exactly match your hosted path
3. **URL Scheme**: Verify `linkedinverifier://` is properly configured in `Info.plist`
4. **AppDelegate**: Ensure AppDelegate is properly connected in main app file

### Debug Steps
1. Check LinkedIn developer console for redirect URI configuration
2. Verify HTML page loads correctly at the redirect URI
3. Test URL scheme handling in iOS app
4. Monitor Xcode console for OAuth flow errors