import Foundation
import SwiftUI
import AuthenticationServices

class LinkedInVerificationViewModel: ObservableObject {
    @Published var isVerified = false
    @Published var userProfile: LinkedInProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // LinkedIn API Configuration
    private let clientId = "YOUR_LINKEDIN_CLIENT_ID" // Replace with your actual LinkedIn Client ID
    private let clientSecret = "YOUR_LINKEDIN_CLIENT_SECRET" // Replace with your actual LinkedIn Client Secret
    private let redirectURI = "linkedinverifier://auth"
    private let scope = "r_liteprofile"
    
    private var authCode: String?
    
    func authenticateWithLinkedIn() {
        isLoading = true
        errorMessage = nil
        
        // Create LinkedIn OAuth URL
        let authURL = "https://www.linkedin.com/oauth/v2/authorization?" +
            "response_type=code&" +
            "client_id=\(clientId)&" +
            "redirect_uri=\(redirectURI)&" +
            "scope=\(scope)&" +
            "state=\(UUID().uuidString)"
        
        guard let url = URL(string: authURL) else {
            errorMessage = "Invalid authentication URL"
            isLoading = false
            return
        }
        
        // Open Safari for LinkedIn authentication
        UIApplication.shared.open(url)
    }
    
    func handleCallback(url: URL) {
        guard url.scheme == "linkedinverifier" else { return }
        
        // Extract authorization code from URL
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let codeItem = components.queryItems?.first(where: { $0.name == "code" }) {
            authCode = codeItem.value
            exchangeCodeForToken()
        } else {
            errorMessage = "Failed to get authorization code"
            isLoading = false
        }
    }
    
    private func exchangeCodeForToken() {
        guard let authCode = authCode else {
            errorMessage = "No authorization code available"
            isLoading = false
            return
        }
        
        // Create token exchange request
        let tokenURL = "https://www.linkedin.com/oauth/v2/accessToken"
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=authorization_code&" +
            "code=\(authCode)&" +
            "client_id=\(clientId)&" +
            "client_secret=\(clientSecret)&" +
            "redirect_uri=\(redirectURI)"
        
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Token exchange failed: \(error.localizedDescription)"
                    self?.isLoading = false
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    self?.isLoading = false
                    return
                }
                
                do {
                    let tokenResponse = try JSONDecoder().decode(LinkedInTokenResponse.self, from: data)
                    self?.fetchUserProfile(accessToken: tokenResponse.accessToken)
                } catch {
                    self?.errorMessage = "Failed to parse token response: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }
        }.resume()
    }
    
    private func fetchUserProfile(accessToken: String) {
        let profileURL = "https://api.linkedin.com/v2/me?projection=(id,firstName,lastName,profilePicture(displayImage~:playableStreams))"
        var request = URLRequest(url: URL(string: profileURL)!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Profile fetch failed: \(error.localizedDescription)"
                    self?.isLoading = false
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "No profile data received"
                    self?.isLoading = false
                    return
                }
                
                do {
                    let profileResponse = try JSONDecoder().decode(LinkedInProfileResponse.self, from: data)
                    
                    // Create profile URL
                    let profileURL = "https://www.linkedin.com/in/\(profileResponse.id)"
                    
                    // Create user profile
                    let profile = LinkedInProfile(
                        fullName: "\(profileResponse.firstName.localized.en_US) \(profileResponse.lastName.localized.en_US)",
                        profileURL: profileURL
                    )
                    
                    self?.userProfile = profile
                    self?.isVerified = true
                    self?.isLoading = false
                    
                } catch {
                    self?.errorMessage = "Failed to parse profile response: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }
        }.resume()
    }
}

// Data Models
struct LinkedInProfile {
    let fullName: String
    let profileURL: String
}

struct LinkedInTokenResponse: Codable {
    let accessToken: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}

struct LinkedInProfileResponse: Codable {
    let id: String
    let firstName: LocalizedString
    let lastName: LocalizedString
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "firstName"
        case lastName = "lastName"
    }
}

struct LocalizedString: Codable {
    let localized: LocalizedValues
}

struct LocalizedValues: Codable {
    let en_US: String
    
    enum CodingKeys: String, CodingKey {
        case en_US = "en_US"
    }
}