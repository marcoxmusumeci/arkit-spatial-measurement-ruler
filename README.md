# ARKitSpatialMeasurementRuler

| Attribute | Specification |
| :--- | :--- |
| Project Name | ARKitSpatialMeasurementRuler |
| Primary Framework | ARKit |
| Supporting Technologies | RealityKit, SwiftUI, Combine |
| Language | Swift 5.0 |
| Target Platform | iOS 16.0+ (LiDAR optional, iPhone 12 Pro or later recommended) |
| Source Location | additional-course-materials/ARKit/MeasureAR |
| Deliverable Type | Supplementary Interactive ARKit Application |

## Overview
ARKitSpatialMeasurementRuler is an interactive augmented reality application that measures real-world distances between two user-selected points using ARKit raycasting against detected planes and scene geometry. Each tap places a 3D marker in world space; a cylinder-shaped line entity is rendered between the two markers, and the computed distance is displayed in centimetres.

## Key Features
- ARKit world tracking with horizontal and vertical plane detection, configured to enable LiDAR scene reconstruction on supported devices (iPhone 12 Pro and later).
- Two-tap interaction cycle placing sphere markers at raycasted world positions, computing SIMD Euclidean distance, and rendering a cylinder connector entity between them.
- Automatic measurement reset on the third tap, enabling successive measurements without explicit user intervention.
- Three-state status messaging guiding the user sequentially through first point placement, second point placement, and computed result.
- @MainActor-annotated ObservableObject view model managing all AR scene mutations from the main thread.

## Technology Stack
- ARKit for world tracking session management, plane detection, and raycasting against estimated plane geometry.
- RealityKit for entity creation (sphere and cylinder meshes with SimpleMaterial), AnchorEntity placement, and scene anchor lifecycle management.
- SwiftUI for declarative overlay interface embedding status messages and a reset button.
- UIViewRepresentable bridge pattern (ARViewContainer) connecting ARView to the SwiftUI hierarchy.
- Combine for reactive ObservableObject property publishing.

## Architecture and Components
- ARViewModel: @MainActor ObservableObject coordinator holding the ARView reference, accumulated world-space point array, placed anchor list, and published state (distance, statusMessage). Implements handleTap(at:) for raycast-based point placement and reset() for session state clearance.
- ARViewContainer: UIViewRepresentable wrapping ARView, configuring the ARWorldTrackingConfiguration session, assigning the view model ARView reference, and routing UITapGestureRecognizer events through a Coordinator object.
- ContentView: SwiftUI view layering the ARViewContainer full-screen with a status label overlay and a reset button.

## System Requirements
- macOS 14.0 Sonoma or later.
- Xcode 15.0 or later.
- Physical iOS device with an A12 Bionic processor or later running iOS 16.0 or later. LiDAR-enhanced accuracy requires iPhone 12 Pro, 13 Pro, 14 Pro, or 15 Pro. The application cannot be functionally tested in the iOS Simulator.

## Getting Started
1. Navigate to the project directory:
   cd arkit-spatial-measurement-ruler
2. Open the Xcode project:
   open "MeasureAR.xcodeproj"
3. Connect a physical iOS device.
4. Update the signing team in the project target under Signing and Capabilities.
5. Select the connected device in Xcode and execute Product > Run (Command + R).
6. Point the camera at a textured surface; tap two points to measure the distance between them.

## Implementation Notes
- Raycasting targets .estimatedPlane with .any alignment rather than detected plane anchors, providing broader surface coverage in environments where formal plane anchors have not yet been confirmed by ARKit.
- The line entity is implemented as a cylinder mesh. Its orientation is computed using simd_quatf(from:to:), aligning the default cylinder Y-axis with the direction vector between the two measured points.
- The project checks ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) at runtime and conditionally enables LiDAR mesh reconstruction, allowing the configuration to run correctly on non-LiDAR devices without source modification.

## Learning Outcomes
- Integrating ARKit raycasting with RealityKit entity placement in a SwiftUI application.
- Implementing MVVM architecture with @MainActor guarantees in an AR context.
- Bridging ARView into SwiftUI using UIViewRepresentable and Coordinator delegation.
- Performing SIMD vector arithmetic for Euclidean distance computation and 3D geometric orientation.

## Limitations and Future Extensions
- The measurement session stores at most two points; extending to multi-segment polyline measurements with cumulative totaling would improve practical utility.
- No persistent record of measurements is maintained. Adding a log panel with date-stamped session history would serve use cases requiring documented spatial records.

## Academic Credits and Course Context
Developed as part of the Apple Foundation Program 2026 – Advanced Course at the University of Palermo.
