# LinkedIn Profile Verifier iOS App

A native iOS mobile app built with SwiftUI that allows users to verify their LinkedIn profiles through OAuth authentication.

## Features

- Single screen interface for profile verification
- LinkedIn OAuth integration using `r_liteprofile` scope
- Fetches user's basic LinkedIn details (full name and profile URL)
- Displays verification status with a green "LinkedIn Verified" tag
- Tappable LinkedIn profile URL

## Setup Instructions

### 1. LinkedIn Developer Account Setup

1. Go to [LinkedIn Developers](https://www.linkedin.com/developers/)
2. Create a new app
3. Get your **Client ID** and **Client Secret**
4. Add `linkedinverifier://auth` as an authorized redirect URI
5. Request access to the `r_liteprofile` scope

### 2. Xcode Project Setup

1. Create a new Xcode project (iOS App with SwiftUI)
2. Replace the default files with the provided Swift files
3. Update the `Info.plist` with the provided configuration
4. Replace `YOUR_LINKEDIN_CLIENT_ID` and `YOUR_LINKEDIN_CLIENT_SECRET` in `LinkedInVerificationViewModel.swift` with your actual credentials

### 3. Build and Run

1. Select your target device or simulator
2. Build and run the project
3. The app will open with the LinkedIn verification interface

## File Structure

- `LinkedInVerifierApp.swift` - Main app entry point
- `ContentView.swift` - Main interface with profile input and verification display
- `LinkedInVerificationViewModel.swift` - Business logic and LinkedIn API integration
- `LinkedInLoginView.swift` - LinkedIn authentication interface
- `AppDelegate.swift` - URL scheme handling for OAuth callbacks
- `Info.plist` - App configuration and URL schemes

## OAuth Flow

1. User enters their LinkedIn profile name
2. Taps "Verify with LinkedIn" button
3. App opens LinkedIn OAuth page in Safari
4. User authorizes the app
5. LinkedIn redirects back to the app with an authorization code
6. App exchanges the code for an access token
7. App fetches user profile using the LinkedIn API
8. Profile details are displayed with verification status

## API Endpoints Used

- **Authorization**: `https://www.linkedin.com/oauth/v2/authorization`
- **Token Exchange**: `https://www.linkedin.com/oauth/v2/accessToken`
- **Profile Data**: `https://api.linkedin.com/v2/me`

## Permissions Required

- `r_liteprofile` - Basic profile information (name, profile picture)

## Security Notes

- Client secret should be kept secure and not exposed in client-side code
- OAuth flow uses secure HTTPS endpoints
- App Transport Security is configured for LinkedIn domains
- URL scheme is restricted to the app's custom scheme

## Troubleshooting

- Ensure LinkedIn app credentials are correctly configured
- Check that redirect URI matches exactly in LinkedIn developer settings
- Verify network connectivity and HTTPS requirements
- Check Xcode console for any error messages

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.3+
- Active LinkedIn Developer account