//
//  ChangePasswordPage.swift
//  Tailor Made
//
//  Created by Ian Bundy-Weiss on 2/14/24.
//

import SwiftUI

struct ChangePasswordPage: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showErrorAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    SecureField("Current Password", text: $currentPassword)
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmPassword)
                }

                Section {
                    Button(action: {
                        // Add action to validate and change password
                        if validatePasswordChange() {
                            // Perform password change logic
                        } else {
                            showErrorAlert = true
                        }
                    }) {
                        Text("Change Password")
                            .foregroundColor(.blue)
                    }
                }
                
                Section {
                    NavigationLink(){
                        SettingsPage()
                    } label: {
                        Text("Back")
                    }
                }
            }
            .navigationBarTitle("Change Password", displayMode: .inline)
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text("Passwords do not match."), dismissButton: .default(Text("OK")))
            }
        }.navigationBarHidden(true)
    }

    private func validatePasswordChange() -> Bool {
        // Add validation logic (e.g., check if passwords match)
        return newPassword == confirmPassword
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordPage()
    }
}
