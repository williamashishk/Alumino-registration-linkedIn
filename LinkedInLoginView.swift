import SwiftUI
import SafariServices

struct LinkedInLoginView: View {
    @ObservedObject var viewModel: LinkedInVerificationViewModel
    let profileName: String
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSafari = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "linkedin")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("LinkedIn Authentication")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("You'll be redirected to LinkedIn to authorize this app")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                
                // Profile Name Display
                VStack(spacing: 8) {
                    Text("Verifying Profile:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(profileName)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                
                // Login Button
                Button(action: {
                    viewModel.authenticateWithLinkedIn()
                    showingSafari = true
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .foregroundColor(.white)
                        Text("Continue with LinkedIn")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // Loading State
                if viewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Verifying your profile...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                }
                
                // Error Display
                if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        Text("Error")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Cancel Button
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSafari) {
            SafariView(url: URL(string: "https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=YOUR_LINKEDIN_CLIENT_ID&redirect_uri=https://yourdomain.com/linkedin-callback&scope=r_liteprofile&state=\(UUID().uuidString)")!)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

struct LinkedInLoginView_Previews: PreviewProvider {
    static var previews: some View {
        LinkedInLoginView(viewModel: LinkedInVerificationViewModel(), profileName: "john-doe")
        }
}