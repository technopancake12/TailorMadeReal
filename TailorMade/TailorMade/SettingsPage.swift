//
//  SettingsPage.swift
//  Tailor Made
//
//  Created by Ian Bundy-Weiss on 2/13/24.
//

import SwiftUI

struct SettingsPage: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account")) {
                    NavigationLink(destination:
                            EditProfilePage()) {
                        SettingsRow(icon: "person", title: "Edit Profile")
                    }
                    NavigationLink(destination: ChangePasswordPage()) {
                        SettingsRow(icon: "key", title: "Change Password")
                    }
                }

                Section(header: Text("Support")) {
                    NavigationLink(destination: ContactUsPage()) {
                        SettingsRow(icon: "envelope", title: "Contact Us")
                    }
                    NavigationLink(destination: Text("Feedback")) {
                        SettingsRow(icon: "heart.fill", title: "Feedback")
                    }
                }
                
                Section {
                    NavigationLink(destination: ProfilePage()){
                        SettingsRow(icon: "arrowshape.turn.up.backward.fill", title: "Back")
                    }
                }

                Section {
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRow(icon: "arrowshape.turn.up.backward.fill", title: "Sign Out")
                    }.foregroundColor(Color.orange)
                    
                    Button {
                        viewModel.deleteAccount()
                    } label: {
                        SettingsRow(icon: "delete.right.fill", title: "Delete Account")
                    }.foregroundColor(Color.red)
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }.navigationBarHidden(true)
    }
}

struct SettingsRow: View {
    var icon: String
    var title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30, height: 30)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)

            Text(title)
                .padding(.leading, 10)

            Spacer()

            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPage()
    }
}
