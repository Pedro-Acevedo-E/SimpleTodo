//
//  ContentView.swift
//  SimpleTodo
//
//  Created by Pedro Acevedo on 08/05/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("To-Do")
        }
    }
}

#Preview {
    ContentView()
}
