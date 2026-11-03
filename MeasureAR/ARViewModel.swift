//
//  ARViewModel.swift
//  MeasureAR
//
//  Created by Mariella on 31/03/26.
//

import Foundation
import RealityKit
import ARKit
import Combine

@MainActor
class ARViewModel: ObservableObject {
    @Published var distance: Float? = nil
    @Published var statusMessage: String = "Punta verso una superficie e tocca il primo punto"
    
    var arView: ARView?
    private var points: [SIMD3<Float>] = []
    private var anchorEntities: [AnchorEntity] = []
    private var lineEntity: ModelEntity?
    





    func reset() {
        // Rimuovi tutti gli anchor dalla scena
        anchorEntities.forEach { arView?.scene.removeAnchor($0) }
        anchorEntities.removeAll()
        points.removeAll()
        distance = nil
        statusMessage = "Punta verso una superficie e tocca il primo punto"
    }

    func handleTap(at location: CGPoint) {
        guard let arView = arView else { return }

        // Raycasting verso piani esistenti (più preciso)
        guard let result = arView.raycast(
            from: location,
            allowing: .estimatedPlane,
            alignment: .any
        ).first else {
            statusMessage = "Nessuna superficie rilevata. Muovi lentamente la fotocamera."
            return
        }

        let worldPosition = result.worldTransform.columns.3
        let point = SIMD3<Float>(worldPosition.x, worldPosition.y, worldPosition.z)
        points.append(point)

        // Aggiungi sfera visiva
        placeSphere(at: result.worldTransform, index: points.count)

        if points.count == 1 {
            statusMessage = "Primo punto posizionato. Tocca il secondo punto."
        } else if points.count == 2 {
            let dist = simd_distance(points[0], points[1])
            distance = dist
            statusMessage = String(format: "Distanza: %.1f cm", dist * 100)
            drawLine(from: points[0], to: points[1])
        } else {
            // Terzo tap: reset automatico e riparti
            reset()
            handleTap(at: location)
        }
    }

    // MARK: - Helpers 3D

    private func placeSphere(at transform: simd_float4x4, index: Int) {
        guard let arView = arView else { return }

        let color: UIColor = index == 1 ? .systemGreen : .systemRed
        let sphere = MeshResource.generateSphere(radius: 0.008)
        let material = SimpleMaterial(color: color, roughness: 0.3, isMetallic: true)
        let entity = ModelEntity(mesh: sphere, materials: [material])

        let anchor = AnchorEntity(world: transform)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        anchorEntities.append(anchor)
    }

    private func drawLine(from start: SIMD3<Float>, to end: SIMD3<Float>) {
        guard let arView = arView else { return }

        let midPoint = (start + end) / 2
        let direction = end - start
        let length = simd_length(direction)

        // Crea un cilindro come "linea"
        let cylinder = MeshResource.generateCylinder(height: length, radius: 0.002)
        let material = SimpleMaterial(color: .systemYellow, roughness: 0.5, isMetallic: false)
        let entity = ModelEntity(mesh: cylinder, materials: [material])

        // Ruota il cilindro nella direzione corretta
        let normalized = simd_normalize(direction)
        let up = SIMD3<Float>(0, 1, 0)
        let rotation = simd_quatf(from: up, to: normalized)
        entity.orientation = rotation

        let anchor = AnchorEntity(world: midPoint)
        anchor.addChild(entity)
        arView.scene.addAnchor(anchor)
        anchorEntities.append(anchor)
    }
}
