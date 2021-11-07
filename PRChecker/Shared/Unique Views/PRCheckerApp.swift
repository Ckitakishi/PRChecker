//
//  PRCheckerApp.swift
//  Shared
//
//  Created by Bruce Evans on 2021/11/02.
//

import SwiftUI

@main
struct PRCheckerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(FilterViewModel())
                .background(Color.gray6)
        }
    }
}
