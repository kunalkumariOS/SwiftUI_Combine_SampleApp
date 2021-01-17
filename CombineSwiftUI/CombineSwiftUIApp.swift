//
//  CombineSwiftUIApp.swift
//  CombineSwiftUI
//
//  Created by Kunal Kumar on 2021-01-16.
//

import SwiftUI

@main
struct CombineSwiftUIApp: App {
    @StateObject private var modelData = NASAViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(modelData)
        }
    }
}
