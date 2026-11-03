//
//  ContentView.swift
//  MeasureAR
//
//  Created by Mariella on 30/03/26.
//

import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    @StateObject private var arViewModel = ARViewModel()

    var body: some View {
        ZStack {
            ARViewContainer(viewModel: arViewModel)
                .ignoresSafeArea()

            // HUD sovrapposto
            VStack {
                // Banner distanza
                if let distance = arViewModel.distance {
                    Text(String(format: "📏 %.1f cm", distance * 100))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                        .foregroundColor(.white)
                        .shadow(radius: 6)
                        .padding(.top, 60)
                } else {
                    Text(arViewModel.statusMessage)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .foregroundColor(.white)
                        .padding(.top, 60)
                }

                Spacer()

                // Pulsante reset
                Button(action: { arViewModel.reset() }) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial, in: Capsule())
                        .foregroundColor(.white)
                }
                .padding(.bottom, 50)
            }

        }
    }
}

#Preview {
    ContentView()
}
