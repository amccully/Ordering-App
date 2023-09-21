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
// ! means optional: promises program that the values will be valid (not nil)
// ?? means nil-coelescing: can act as fail-safe

/*
 Food for thought: have wait time and distance away considered, whichever is higher is the limiting factor. So figure which is higher and rank the restaurants based on that. To find out walking distance time, use a constant. However, you could give the user a way to change the constant based on mode of transport?
 */

import SwiftUI

@main
struct OrderingApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
