import SwiftUI

// Commented out class (not used in the current code)
//@MainActor
//final class SignInWithEmailModel: ObservableObject {
//
//    @Published var email = ""
//    @Published var password = ""
//
//    func signIn() {
//        guard !email.isEmpty, !password.isEmpty else {
//            print("No email or password found")
//            return
//        }
//
//        Task {
//            do {
//                let returnedUserData = try await AuthView.shared.CreateUser(email: email, password: password)
//                print("Success")
//                print(returnedUserData)
//            } catch {
//                print("Error: \(error)")
//            }
//        }
//    }
//}

// Main login page view
struct LoginPage: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingLoginScreen = false
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background styling - Ian
                Color.blue
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.white)
                Circle()
                    .scale(1.35)
                    .foregroundColor(.white)
                
                VStack {
                    // App title - Ian
                    Text("Tailor Made")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    // Email text field - Ian
                    TextField("Email", text: $email)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    
                    // Password secure field - Ian
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    
                    // Login button - Nathan
                    Button("Login") {
                        Task {
                            try await viewModel.SignIn(withEmail: email, password: password)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
                    
                    // Navigation link to sign-up page - Nathan
                    NavigationLink() {
                        BrandInterest()
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack(spacing: 3){
                            Text("Don't have an Account?")
                            Text("Sign Up")
                                .fontWeight(.bold)
                        }
                    }
                    
                    // Navigation link to logged-in page - Nathan
                    NavigationLink(destination: Text("You are logged in @\(email)"), isActive: $showingLoginScreen) {
                        EmptyView()
                    }
                }
            }.navigationBarHidden(true)
        }
    }
}

// Extension for form validation - Nathan
extension LoginPage: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

// Preview for the login page
struct LoginPage_Previews: PreviewProvider {
    static var previews: some View {
        LoginPage()
    }
}
