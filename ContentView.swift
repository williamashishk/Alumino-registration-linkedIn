import SwiftUI
import AuthenticationServices
import SafariServices

struct ContentView: View {
    @StateObject private var viewModel = LinkedInVerificationViewModel()
    @State private var profileName = ""
    @State private var showingLinkedInLogin = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("LinkedIn Profile Verifier")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Verify your LinkedIn profile to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Profile Name Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("LinkedIn Profile Name")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your LinkedIn profile name", text: $profileName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .padding(.horizontal, 20)
                
                // Verify Button
                Button(action: {
                    showingLinkedInLogin = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.white)
                        Text("Verify with LinkedIn")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .disabled(profileName.isEmpty)
                .opacity(profileName.isEmpty ? 0.6 : 1.0)
                
                // Profile Display Section
                if viewModel.isVerified {
                    VStack(spacing: 16) {
                        // Verification Badge
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("LinkedIn Verified")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(20)
                        
                        // Profile Details
                        VStack(spacing: 12) {
                            if let fullName = viewModel.userProfile?.fullName {
                                HStack {
                                    Text("Full Name:")
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(fullName)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal, 20)
                            }
                            
                            if let profileURL = viewModel.userProfile?.profileURL {
                                HStack {
                                    Text("Profile URL:")
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Button(action: {
                                        if let url = URL(string: profileURL) {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Text("Open Profile")
                                            .foregroundColor(.blue)
                                            .underline()
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingLinkedInLogin) {
            LinkedInLoginView(viewModel: viewModel, profileName: profileName)
        }
        .onReceive(viewModel.$isVerified) { isVerified in
            if isVerified {
                showingLinkedInLogin = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .linkedInCallback)) { notification in
            if let url = notification.object as? URL {
                viewModel.handleCallback(url: url)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}