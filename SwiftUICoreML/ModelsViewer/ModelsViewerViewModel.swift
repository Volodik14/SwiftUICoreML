//
//  ModelsViewModel.swift
//  SwiftUICoreML
//
//  Created by Владимир Моторкин on 20.12.2024.
//

import SwiftUI

class ModelsViewerViewModel: ObservableObject {
    @Published var savedModels: [String] = []
    
    func loadModels() {
        savedModels = UserDefaults.standard.stringArray(forKey: "trainedWords") ?? []
    }
    
    func resetAllModels() {
        // Сброс модели
        UpdatableModel.resetToDefault()
        
        // Очистка сохраненных слов
        UserDefaults.standard.removeObject(forKey: "trainedWords")
        savedModels.removeAll()
    }
}
