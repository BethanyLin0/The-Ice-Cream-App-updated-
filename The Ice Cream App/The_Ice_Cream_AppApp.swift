//
//  The_Ice_Cream_AppApp.swift
//  The Ice Cream App
//
//  Created by Bethany on 2025/3/26.
//

import SwiftUI
import SwiftData

@main
struct The_Ice_Cream_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        //Telling SwiftData which models to manage
        .modelContainer(for: [Recipe.self, Expense.self])
    }
}
