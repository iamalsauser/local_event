//
//  ContentView.swift
//  local_event
//
//  Created by admin17 on 30/01/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedURL: URL?
    @State private var showPicker = false

    var body: some View {
        VStack {
            if let url = selectedURL {
                Text("Selected File: \(url.lastPathComponent)")
            } else {
                Text("No File Selected")
            }

            Button("Pick a File") {
                showPicker = true
            }
            .sheet(isPresented: $showPicker) {
                DocumentPicker(selectedURL: $selectedURL)
            }
        }
    }
}


#Preview {
    ContentView()
}
