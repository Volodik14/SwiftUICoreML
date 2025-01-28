//
//  GameView.swift
//  SwiftUICoreML
//
//  Created by Владимир Моторкин on 20.12.2024.
//

import SwiftUI
import PencilKit

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var canvasView = PKCanvasView()
    @State private var showResultAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack {
                    Text("Draw:")
                        .font(.title2)
                    Text(viewModel.currentWord ?? "Loading...")
                        .font(.largeTitle.weight(.bold))
                        .foregroundColor(.blue)
                }
                .padding()
                
                DrawingRepresentation(canvasView: $canvasView)
                    .frame(height: 400)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button("Clear") {
                        canvasView.drawing = PKDrawing()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Check") {
                        viewModel.checkDrawing(canvasView.drawing)
                        showResultAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.currentWord == nil)
                    
                    Button("Next Word") {
                        viewModel.nextWord()
                        canvasView.drawing = PKDrawing()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("QuickDraw Game")
            .alert(isPresented: $showResultAlert) {
                Alert(
                    title: Text(viewModel.isCorrect ? "Correct!" : "Try Again"),
                    message: Text(viewModel.resultMessage),
                    dismissButton: .default(Text("OK")) {
                        if viewModel.isCorrect {
                            viewModel.nextWord()
                            canvasView.drawing = PKDrawing()
                        }
                    }
                )
            }
            .onAppear {
                viewModel.loadWords()
            }
        }
    }
}
