//
//  StandingsSwiftUIApp.swift
//  StandingsSwiftUI
//
//  Created by Pierluigi Cifani on 1/6/23.
//

import SwiftUI

@main
struct StandingsSwiftUIApp: App {
  var body: some Scene {
    WindowGroup {
      NavigationStack {
        StandingsView(model: .mock())
      }
    }
  }
}
