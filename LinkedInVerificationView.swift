import SwiftUI

struct LinkedInVerificationView: View {
    @ObservedObject var linkedInManager: LinkedInManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("LinkedIn Verification")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Verify your professional identity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Verification status indicator
                if linkedInManager.isVerified {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            
            // Current status
            if linkedInManager.isVerified {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("LinkedIn Verified")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    
                    if let profileURL = linkedInManager.linkedinProfileURL {
                        Button(action: {
                            if let url = URL(string: profileURL) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "link")
                                Text("View LinkedIn Profile")
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Action button
            if !linkedInManager.isVerified {
                Button(action: {
                    linkedInManager.connect { success in
                        // Handle completion if needed
                    }
                }) {
                    HStack {
                        if linkedInManager.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "link.circle")
                        }
                        
                        Text(linkedInManager.isLoading ? "Verifying..." : "Verify with LinkedIn")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(linkedInManager.isLoading ? Color.gray : Color.blue)
                    .cornerRadius(10)
                }
                .disabled(linkedInManager.isLoading)
            } else {
                Button(action: {
                    linkedInManager.resetVerification()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Re-verify")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            
            // Error message
            if let errorMessage = linkedInManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    LinkedInVerificationView(linkedInManager: LinkedInManager())
        .padding()
}