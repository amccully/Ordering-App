//
//  OrderingApp.swift
//  OrderingApp
//
//  Created by Aaron McCully
//
//  Notes for development:
//  we want the server to handle all information that will be the same for every device
//  keep things simple for json files, so 4 simple ints is better than 1 string that you need to extract info from
//  this project will only use sf symbols for the sake of simplicity
//  look out for hard coded sections, consider flexibility

// Xcode and Swift info:
// press enter to autofill
// SwiftOnTap: guide for swiftui
// use plus button in top right to access sf symbol library

import SwiftUI

@main
struct OrderingApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
