# LinkedIn Verification Feature for iOS App

This project implements LinkedIn OAuth verification for your iOS app's profile tab. Users can verify their professional identity by connecting their LinkedIn account.

## Files Created

1. **`LinkedInManager.swift`** - Core OAuth implementation
2. **`LinkedInVerificationView.swift`** - Reusable UI component
3. **`ProfileView.swift`** - Sample profile view with LinkedIn verification
4. **`AppDelegate.swift`** - URL scheme handling
5. **`Info.plist`** - App configuration
6. **`linkedin_redirect.html`** - OAuth redirect page

## Setup Instructions

### 1. LinkedIn App Configuration

1. Go to [LinkedIn Developers](https://www.linkedin.com/developers/)
2. Create a new app or use existing one
3. In your app settings, configure:
   - **OAuth 2.0 Redirect URLs**: `https://glistening-cranachan-919a16.netlify.app/`
   - **OAuth 2.0 Scopes**: `openid profile email`
   - **Products**: Enable "Sign In with LinkedIn (OpenID)"

### 2. Update LinkedIn Credentials

In `LinkedInManager.swift`, update these values with your actual LinkedIn app credentials:

```swift
private let clientID     = "YOUR_CLIENT_ID"
private let clientSecret = "YOUR_CLIENT_SECRET"
private let redirectURI  = "YOUR_REDIRECT_URI"
```

### 3. Xcode Project Setup

1. **Add Files to Xcode**:
   - Drag all `.swift` files into your Xcode project
   - Make sure they're added to your target

2. **Configure URL Scheme**:
   - In Xcode, select your project
   - Go to "Info" tab
   - Add URL scheme: `alumino`
   - Or manually add to Info.plist:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>alumino</string>
           </array>
       </dict>
   </array>
   ```

3. **Add Dependencies**:
   - Ensure `AuthenticationServices` framework is linked
   - Add `import AuthenticationServices` to your bridging header if needed

### 4. Integration in Your App

#### Option A: Use as Environment Object (Recommended)

```swift
// In your main app file
@main
struct YourApp: App {
    @StateObject private var linkedInManager = LinkedInManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(linkedInManager)
        }
    }
}

// In your profile view
struct ProfileView: View {
    @EnvironmentObject var linkedInManager: LinkedInManager
    
    var body: some View {
        VStack {
            LinkedInVerificationView(linkedInManager: linkedInManager)
            // ... rest of your profile content
        }
    }
}
```

#### Option B: Use as State Object

```swift
struct ProfileView: View {
    @StateObject private var linkedInManager = LinkedInManager()
    
    var body: some View {
        VStack {
            LinkedInVerificationView(linkedInManager: linkedInManager)
            // ... rest of your profile content
        }
    }
}
```

### 5. Handle URL Callbacks

If you're using SwiftUI App lifecycle (iOS 14+), add this to your main app:

```swift
@main
struct YourApp: App {
    @StateObject private var linkedInManager = LinkedInManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(linkedInManager)
                .onOpenURL { url in
                    if url.scheme == "alumino" && url.host == "auth" {
                        linkedInManager.handleRedirect(url: url) { success in
                            print("LinkedIn OAuth result: \(success)")
                        }
                    }
                }
        }
    }
}
```

## Features

- ✅ LinkedIn OAuth 2.0 with OpenID Connect
- ✅ Professional verification status
- ✅ Loading states and error handling
- ✅ Re-verification capability
- ✅ Clean, modern UI design
- ✅ Accessibility support

## Customization

### UI Customization

Modify `LinkedInVerificationView.swift` to match your app's design:
- Colors and fonts
- Layout and spacing
- Icons and images

### Business Logic

Extend `LinkedInManager.swift` to:
- Store verification status in UserDefaults or Core Data
- Sync with your backend API
- Add additional LinkedIn profile data
- Implement verification expiration

## Troubleshooting

### Common Issues

1. **"Invalid authorization URL"**
   - Check your LinkedIn app redirect URI configuration
   - Ensure client ID and secret are correct

2. **"State validation failed"**
   - This is a security feature, usually resolves on retry
   - Check for multiple authentication sessions

3. **Callback not working**
   - Verify URL scheme is properly configured in Info.plist
   - Check that `alumino://auth` URLs are being handled

4. **LinkedIn API errors**
   - Verify OAuth scopes are enabled in LinkedIn app
   - Check if OpenID Connect is enabled

### Debug Mode

Enable debug logging by adding this to `LinkedInManager`:

```swift
private let debugMode = true

// Then use throughout the code:
if debugMode {
    print("Debug: \(message)")
}
```

## Security Notes

- ⚠️ Never commit client secrets to version control
- 🔒 Use environment variables or secure storage for production
- 🛡️ Implement proper state validation (already included)
- 🔐 Consider implementing PKCE for additional security

## Production Considerations

1. **Environment Configuration**:
   - Use different credentials for dev/staging/production
   - Implement secure credential management

2. **Error Handling**:
   - Add user-friendly error messages
   - Implement retry mechanisms
   - Log errors for monitoring

3. **Performance**:
   - Cache verification status
   - Implement background refresh
   - Add offline support

## Support

For issues with:
- **LinkedIn API**: Check [LinkedIn API Documentation](https://developer.linkedin.com/)
- **iOS Development**: Refer to [Apple Developer Documentation](https://developer.apple.com/)
- **OAuth Implementation**: Review [OAuth 2.0 RFC](https://tools.ietf.org/html/rfc6749)