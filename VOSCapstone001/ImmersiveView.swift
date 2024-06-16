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

    @Environment(AppModel.self) private var appModel
    
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
        }
        .gesture(tapGesture)
        .gesture(rotateGesture)
    }
    
    // rotation code based on Apple sample TransformingRealityKitEntitiesUsingGestures
    var rotateGesture: some Gesture {
        RotateGesture3D()
            .targetedToAnyEntity()
            .onChanged { value in
                let entity = value.entity
                if !appModel.closeIsRotating {
                    appModel.closeIsRotating = true
                    appModel.startOrientation = .init(entity.orientation(relativeTo: nil))
                }
                // now, closeIsRotating is true, and we have the original orientation available
                let rotation = value.rotation
                let flippedRotation = Rotation3D(angle: rotation.angle,
                                                 axis: RotationAxis3D(x: -rotation.axis.x,
                                                                      y: rotation.axis.y,
                                                                      z: -rotation.axis.z))
                let newOrientation =    appModel.startOrientation.rotated(by: flippedRotation)
                entity.setOrientation(.init(newOrientation), relativeTo: nil)
            }
            .onEnded { value in
                appModel.closeIsRotating = false
            }
    }
    
    var tapGesture: some Gesture {
        TapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
                let newEntity = value.entity
                    //print("got Tap Gesture on \(name)")
                    //let pos = value.entity.position
                    //print("position \(pos)")
                    let newEntityName = newEntity.name
                    if newEntityName == "Jungle" ||
                        newEntityName == "FishTeapot" ||
                        newEntityName == "Horn"
                    {
                        
                        if let oldEntity = appModel.closeEntity {
                            // we have already moved an entity close, so put it back to its original position
                            oldEntity.scale.x = appModel.closeBaseScale
                            oldEntity.scale.y = appModel.closeBaseScale
                            oldEntity.scale.z = appModel.closeBaseScale
                            oldEntity.position.x = appModel.closeBasePositionX
                            oldEntity.position.y = appModel.closeBasePositionY
                            oldEntity.position.z = appModel.closeBasePositionZ
                            appModel.closeEntity = nil
                            // if we tapped on the close one, just put it back
                            if oldEntity.name == newEntityName {
                                return
                            }
                        }
                    // Now, move the selected entity forward, and save that state in the appModel
                    appModel.closeEntity = newEntity
                    appModel.closeBasePositionX = newEntity.position.x
                    appModel.closeBasePositionY = newEntity.position.y
                    appModel.closeBasePositionZ = newEntity.position.z
                    appModel.closeBaseScale = newEntity.scale.x
                        
                    newEntity.position.x = 0
                    newEntity.position.y = 1.30
                    newEntity.position.z = -0.8
                        
                    // don't make the horn too tall.  Reduce its scale from 2.0
                    if newEntityName == "Horn" {
                        newEntity.scale.x = 1.3
                        newEntity.scale.y = 1.3
                        newEntity.scale.z = 1.3
                    }
                        
                        
                    }
                
                
                                
                //if name == "Jungle" {
                //    value.entity.position.z = -0.8
                //}

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
