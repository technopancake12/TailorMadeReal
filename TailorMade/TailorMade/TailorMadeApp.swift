//
//  Tailor_MadeApp.swift
//  Tailor Made
//
//  Created by Ian Bundy-Weiss on 1/30/24.
//

import SwiftUI
import FirebaseCore

@main
struct Tailor_MadeApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject var explore = ExplorePageViewModel()
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(explore)
        }
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate {

 
}
