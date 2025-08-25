import SwiftUI

struct ProfileView: View {
    @StateObject private var linkedInManager = LinkedInManager()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("John Doe")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Software Engineer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("San Francisco, CA")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // LinkedIn Verification Section
                    LinkedInVerificationView(linkedInManager: linkedInManager)
                    
                    // Other Profile Sections
                    VStack(spacing: 16) {
                        ProfileSection(title: "Personal Information") {
                            ProfileRow(icon: "envelope", title: "Email", value: "john.doe@example.com")
                            ProfileRow(icon: "phone", title: "Phone", value: "+1 (555) 123-4567")
                            ProfileRow(icon: "location", title: "Location", value: "San Francisco, CA")
                        }
                        
                        ProfileSection(title: "Professional") {
                            ProfileRow(icon: "building.2", title: "Company", value: "Tech Corp")
                            ProfileRow(icon: "graduationcap", title: "Education", value: "Stanford University")
                            ProfileRow(icon: "briefcase", title: "Experience", value: "5+ years")
                        }
                        
                        ProfileSection(title: "Skills") {
                            SkillsView(skills: ["Swift", "iOS", "SwiftUI", "Git", "REST APIs"])
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Supporting Views

struct ProfileSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct SkillsView: View {
    let skills: [String]
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
            ForEach(skills, id: \.self) { skill in
                Text(skill)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(16)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    ProfileView()
}