//
//  ARViewContainer.swift
//  MeasureAR
//
//  Created by Mariella on 30/03/26.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Configurazione ARKit
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        config.environmentTexturing = .automatic

        // Abilita LiDAR se disponibile (iPhone 12 Pro+)
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
            config.sceneReconstruction = .mesh
        }

        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])

        // Debug (opzionale, rimuovi in produzione)
        // arView.debugOptions = [.showFeaturePoints, .showAnchorOrigins]

        // Collega ViewModel
        viewModel.arView = arView

        // Gesture recognizer
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    class Coordinator: NSObject {
        let viewModel: ARViewModel

        init(viewModel: ARViewModel) {
            self.viewModel = viewModel
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = gesture.view as? ARView else { return }
            let location = gesture.location(in: arView)
            Task { @MainActor in
                self.viewModel.handleTap(at: location)
            }
        }
    }
}
