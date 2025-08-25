import Foundation
import AuthenticationServices
import SwiftUI

final class LinkedInManager: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {

    // 1) CONFIG — make sure these EXACTLY match your LinkedIn app settings
    private let clientID     = "77ckvgthb5dqux"
    private let clientSecret = "WPL_AP1.8BEXqLbhZVbXEoa0.I+B+Rw=="   // ⚠️ For test only
    private let redirectURI  = "https://glistening-cranachan-919a16.netlify.app/" // EXACT match

    // If you do NOT have "Sign In with LinkedIn (OpenID)" enabled, use the legacy scopes:
    // private let scope = "r_liteprofile r_emailaddress"
    // If you DO have OpenID product enabled, keep:
    private let scope = "openid profile email"

    @Published var linkedinProfileURL: String?
    @Published var isVerified = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var pendingState: String?

    // MARK: - Start OAuth
    func connect(completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        
        let state = UUID().uuidString
        pendingState = state

        var comps = URLComponents(string: "https://www.linkedin.com/oauth/v2/authorization")!
        comps.queryItems = [
            .init(name: "response_type", value: "code"),
            .init(name: "client_id",     value: clientID),
            .init(name: "redirect_uri",  value: redirectURI),
            .init(name: "state",         value: state),
            .init(name: "scope",         value: scope)
        ]

        guard let authURL = comps.url else { 
            isLoading = false
            errorMessage = "Invalid authorization URL"
            completion(false)
            return 
        }

        // The callback scheme should be your app scheme ("alumino").
        let session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "alumino") { [weak self] callbackURL, error in
            guard let self else { return }
            if let error = error {
                print("ASWebAuthenticationSession error:", error)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
                return
            }
            guard let callbackURL = callbackURL else {
                print("Nil callbackURL")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "No callback URL received"
                    completion(false)
                }
                return
            }
            self.handleRedirect(url: callbackURL, completion: completion)
        }
        session.prefersEphemeralWebBrowserSession = true
        session.presentationContextProvider = self
        session.start()
    }

    // MARK: - Handle alumino://auth?code=...&state=...
    func handleRedirect(url: URL, completion: @escaping (Bool) -> Void) {
        let qi = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        let code  = qi?.first(where: { $0.name == "code" })?.value
        let state = qi?.first(where: { $0.name == "state" })?.value

        // Optional but recommended: validate state
        if let expected = pendingState, expected != state {
            print("State mismatch")
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "State validation failed"
                completion(false)
            }
            return
        }

        guard let code = code else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "No authorization code received"
                completion(false)
            }
            return
        }

        exchangeCodeForToken(code: code) { [weak self] result in
            switch result {
            case .failure(let err):
                print("Token exchange failed:", err.localizedDescription)
                DispatchQueue.main.async { 
                    self?.isLoading = false
                    self?.errorMessage = err.localizedDescription
                    completion(false) 
                }
            case .success(let accessToken):
                self?.fetchLinkedInProfile(accessToken: accessToken) { ok in
                    DispatchQueue.main.async { 
                        self?.isLoading = false
                        completion(ok) 
                    }
                }
            }
        }
    }

    // MARK: - Exchange code -> token
    private func exchangeCodeForToken(code: String,
                                      completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://www.linkedin.com/oauth/v2/accessToken")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        // Build form body safely (this percent-encodes +, =, etc.)
        var form = URLComponents()
        form.queryItems = [
            URLQueryItem(name: "grant_type",    value: "authorization_code"),
            URLQueryItem(name: "code",          value: code),
            URLQueryItem(name: "redirect_uri",  value: redirectURI),   // EXACT match
            URLQueryItem(name: "client_id",     value: clientID),
            URLQueryItem(name: "client_secret", value: clientSecret)
        ]
        req.httpBody = form.percentEncodedQuery?.data(using: .utf8)

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err { return completion(.failure(err)) }
            guard let data = data else {
                return completion(.failure(NSError(domain: "LinkedIn", code: -1,
                                                   userInfo: [NSLocalizedDescriptionKey: "No data"])))
            }

            if let http = resp as? HTTPURLResponse {
                print("Token HTTP status:", http.statusCode)
                if http.statusCode != 200 {
                    print("Token body:", String(data: data, encoding: .utf8) ?? "")
                }
            }

            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                  let token = json["access_token"] as? String
            else {
                return completion(.failure(NSError(domain: "LinkedIn", code: -2,
                                                   userInfo: [NSLocalizedDescriptionKey: "Bad token JSON"])))
            }
            completion(.success(token))
        }.resume()
    }

    // MARK: - Fetch profile (OpenID userinfo)
    private func fetchLinkedInProfile(accessToken: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://api.linkedin.com/v2/userinfo") else { completion(false); return }
        var req = URLRequest(url: url)
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let err = err {
                print("Profile request error:", err)
                return completion(false)
            }
            if let http = resp as? HTTPURLResponse { print("Profile HTTP status:", http.statusCode) }
            guard let data = data,
                  let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            else { return completion(false) }

            // If you used OpenID, "sub" is the stable identifier.
            // LinkedIn does not always give the public vanity name here;
            // you can store `sub` as your proof and mark verified.
            DispatchQueue.main.async {
                self.linkedinProfileURL = "https://www.linkedin.com/" // you can store/format as you prefer
                self.isVerified = true
                completion(true)
            }
        }.resume()
    }

    // MARK: - ASWebAuthenticationPresentationContextProviding
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.windows.first ?? ASPresentationAnchor()
    }
    
    // MARK: - Reset verification
    func resetVerification() {
        isVerified = false
        linkedinProfileURL = nil
        errorMessage = nil
    }
}