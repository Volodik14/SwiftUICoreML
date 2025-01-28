//
//  TrainingView.swift
//  SwiftUICoreML
//
//  Created by Владимир Моторкин on 20.12.2024.
//

import SwiftUI
import PencilKit

struct TrainingView: View {
    @StateObject private var viewModel = TrainingViewModel()
    @State private var canvasView = PKCanvasView()
    @State private var showingSaveAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    Text("Current object: \(viewModel.currentObjectName)")
                    Spacer()
                    Text("Samples: \(viewModel.samplesCount)/3")
                }
                .padding(.horizontal)
                
                DrawingRepresentation(canvasView: $canvasView)
                    .frame(height: 400)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                
                Group {
                    if let prediction = viewModel.currentPrediction {
                        Text("Current prediction: \(prediction)")
                            .font(.headline)
                    }
                    
                    TextField("Enter object name", text: $viewModel.objectName)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                VStack(spacing: 15) {
                    HStack {
                        Button("Clear Canvas") {
                            canvasView.drawing = PKDrawing()
                            viewModel.clearPrediction()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Save Sample") {
                            viewModel.saveDrawing(canvasView.drawing)
                            if !viewModel.showDuplicateAlert {
                                canvasView.drawing = PKDrawing()
                                showingSaveAlert = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.objectName.isEmpty)
                        .alert("Sample Saved", isPresented: $showingSaveAlert) {
                            Button("OK") { }
                        }
                    }
                    
                    Button("Train Model") {
                        viewModel.trainModel()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.samplesCount < 3)
                    .help("Minimum 3 samples required")
                    .alert("Duplicate Word", isPresented: $viewModel.showDuplicateAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("This word already exists in the training data. Please use a different name.")
                    }
                }
            }
            .navigationTitle("Train Model")
            .onChange(of: canvasView.drawing) {
                viewModel.predictDrawing(canvasView.drawing)
            }
        }
    }
}
