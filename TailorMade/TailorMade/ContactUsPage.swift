//
//  ContactUsPage.swift
//  Tailor Made
//
//  Created by Ian Bundy-Weiss on 2/14/24.
//

import SwiftUI

struct ContactUsPage: View {
    @State private var subject = ""
    @State private var message = ""
    @State private var showErrorAlert = false

    var body: some View {
        NavigationView {
            Form {
                Section ("Subject"){
                    TextField("", text: $subject)
                }

                Section ("Message"){
                    TextEditor(text: $message)
                        .frame(height: 150)
                        .cornerRadius(8)
                }

                Section {
                    Button(action: {
                        // Add action to send the message
                        if subject.isEmpty || message.isEmpty {
                            showErrorAlert = true
                        } else {
                            // Perform action to send the message
                            // You can implement your own logic to send the message (e.g., using an API)
                        }
                    }) {
                        Text("Send Message")
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
            .navigationBarTitle("Contact Us", displayMode: .inline)
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text("Please fill in all fields."), dismissButton: .default(Text("OK")))
            }
        }.navigationBarHidden(true)
    }
}

struct ContactUsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactUsPage()
    }
}

