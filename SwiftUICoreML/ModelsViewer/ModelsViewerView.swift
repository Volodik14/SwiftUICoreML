//
//  ModelsView.swift
//  SwiftUICoreML
//
//  Created by Владимир Моторкин on 20.12.2024.
//

import SwiftUI

struct ModelsViewerView: View {
    @StateObject private var viewModel = ModelsViewerViewModel()
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.savedModels, id: \.self) { model in
                    Text(model)
                }
            }
            .navigationTitle("Trained Models")
            .toolbar {
                Button("Reset All", role: .destructive) {
                    showResetAlert = true
                }
            }
            .alert("Reset All Models", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    viewModel.resetAllModels()
                }
            } message: {
                Text("All trained data will be permanently deleted. This action cannot be undone.")
            }
            .onAppear {
                viewModel.loadModels()
            }
        }
    }
}
