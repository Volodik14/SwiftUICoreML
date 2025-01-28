//
//  TrainingViewModel.swift
//  SwiftUICoreML
//
//  Created by Владимир Моторкин on 20.12.2024.
//

import Combine
import PencilKit
import CoreML
import SwiftUI

class TrainingViewModel: ObservableObject {
    @Published var objectName = "" {
        didSet {
            checkForNameChange(oldValue: oldValue)
        }
    }
    @Published var currentPrediction: String?
    @Published var currentObjectName = ""
    @Published var samplesCount = 0
    @Published var showDuplicateAlert = false
    
    private var currentSamples: [Drawing] = []
    private var trainingData: [String: [Drawing]] = [:]
    
    private func checkForNameChange(oldValue: String) {
        if objectName != oldValue && objectName != currentObjectName {
            resetTrainingSession()
        }
    }
    
    func predictDrawing(_ drawing: PKDrawing) {
        let drawingWrapper = Drawing(drawing: drawing, rect: CGRect(x: 0, y: 0, width: 299, height: 299))
        let featureValue = drawingWrapper.featureValue
        
        currentPrediction = UpdatableModel.predictLabelFor(featureValue)
    }
    
    func saveDrawing(_ drawing: PKDrawing) {
        guard !objectName.isEmpty else { return }
        
        // Проверка на уже существующее слово
        let name = objectName.lowercased()
        let existingWords = UserDefaults.standard.stringArray(forKey: "trainedWords") ?? []
        
        if existingWords.contains(where: { $0.lowercased() == name }) {
            showDuplicateAlert = true
            return
        }
        
        let newDrawing = Drawing(drawing: drawing, rect: CGRect(x: 0, y: 0, width: 299, height: 299))
        currentSamples.append(newDrawing)
        currentObjectName = objectName
        samplesCount = currentSamples.count
    }
    
    func trainModel() {
        guard currentSamples.count >= 3 else { return }
        
        trainingData[currentObjectName] = currentSamples
        let batchProvider = createBatchProvider()
        
        UpdatableModel.updateWith(trainingData: batchProvider) {
            print("Model updated with \(self.currentSamples.count) samples!")
            self.saveTrainedWord()
            self.resetTrainingSession()
        }
    }
    
    private func saveTrainedWord() {
        var trainedWords = UserDefaults.standard.stringArray(forKey: "trainedWords") ?? []
        if !trainedWords.contains(currentObjectName) {
            trainedWords.append(currentObjectName)
            UserDefaults.standard.set(trainedWords, forKey: "trainedWords")
        }
    }
    
    func clearPrediction() {
        currentPrediction = nil
    }
    
    private func resetTrainingSession() {
        currentSamples.removeAll()
        currentObjectName = objectName
        samplesCount = 0
        currentPrediction = nil
    }
    
    private func createBatchProvider() -> MLBatchProvider {
        var featureProviders: [MLFeatureProvider] = []
        
        for (label, drawings) in trainingData {
            for drawing in drawings {
                let dataPoint: [String: Any] = [
                    "drawing": drawing.featureValue,
                    "label": label
                ]
                
                if let provider = try? MLDictionaryFeatureProvider(dictionary: dataPoint) {
                    featureProviders.append(provider)
                }
            }
        }
        
        return MLArrayBatchProvider(array: featureProviders)
    }
}

struct DrawingRepresentation: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 10)
        
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
