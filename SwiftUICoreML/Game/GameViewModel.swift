//
//  GameViewModel.swift
//  SwiftUICoreML
//
//  Created by Владимир Моторкин on 20.12.2024.
//

import Combine
import PencilKit
import CoreML

class GameViewModel: ObservableObject {
    @Published var currentWord: String?
    @Published var isCorrect = false
    @Published var resultMessage = ""
    
    private var words: [String] = []
    private let maxAttempts = 3
    private var attempts = 0
    
    func loadWords() {
        words = UserDefaults.standard.stringArray(forKey: "trainedWords") ?? []
        nextWord()
    }
    
    func nextWord() {
        let filteredWords = words.filter { $0.lowercased() != currentWord?.lowercased() }
        currentWord = words.count == 1 ? words.first : filteredWords.randomElement()
        attempts = 0
    }
    
    func checkDrawing(_ drawing: PKDrawing) {
        guard let currentWord = currentWord else { return }
        
        let drawingWrapper = Drawing(drawing: drawing, rect: CGRect(x: 0, y: 0, width: 299, height: 299))
        let featureValue = drawingWrapper.featureValue
        
        if let prediction = UpdatableModel.predictLabelFor(featureValue) {
            attempts += 1
            isCorrect = prediction.lowercased() == currentWord.lowercased()
            
            if isCorrect {
                resultMessage = "You got it! It's \(currentWord)"
            } else {
                resultMessage = """
                Attempt \(attempts)/\(maxAttempts)
                Model thinks it's: \(prediction)
                """
                
                if attempts >= maxAttempts {
                    resultMessage += "\nCorrect answer: \(currentWord)"
                }
            }
        }
    }
}
