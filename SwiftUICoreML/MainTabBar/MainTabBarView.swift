//
//  MainTabBarView.swift
//  SwiftUICoreML
//
//  Created by Владимир Моторкин on 20.12.2024.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TrainingView()
                .tabItem {
                    Label("Train", systemImage: "pencil.and.scribble")
                }
            
            GameView()
                .tabItem {
                    Label("Play", systemImage: "gamecontroller")
                }
            
            ModelsViewerView()
                .tabItem {
                    Label("Models", systemImage: "list.bullet")
                }
        }
    }
}
