//
//  ImmersiveView.swift
//  VOSCapstone001
//
//  Created by James Nachbar on 6/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
                //if let fish = content.entities.first?.findEntity(named: "Jungle")
                //{
                    
                //}
            }
        }.gesture(tapGesture)
    }
    var tapGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                let name = value.entity.name
                print("got Tap Gesture on \(name)")
                let pos = value.entity.position
                print("position \(pos)")
                if name == "Jungle" {
                    value.entity.position.z = -0.8
                }

                /*value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
                value.entity.components[PhysicsMotionComponent.self]?.linearVelocity = [0, 7, -5]
                */
            }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
