//
//  ImmersiveView.swift
//  VOSCapstone001
//
//  Created by James Nachbar on 6/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

extension float4x4 {
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.3 = SIMD4<Float>(translation.x, translation.y, translation.z, 1)
    }
}

struct ImmersiveView: View {

    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)

                // Put skybox here.  See example in World project available at
                // https://developer.apple.com/
                if let jungle = content.entities.first?.findEntity(named: "Jungle")
                {
                    // save the base starting orientation - should be the same for all
                    appModel.startingBaseOrientation = .init(jungle.orientation(relativeTo: nil))
                    appModel.originalParentEntity = jungle.parent

                    appModel.jungleBackX = jungle.position.x
                    appModel.jungleBackY = jungle.position.y
                }
                if let fish = content.entities.first?.findEntity(named: "FishTeapot")
                {
                    appModel.fishBackX = fish.position.x
                    appModel.fishBackY = fish.position.y
                }
                if let horn = content.entities.first?.findEntity(named: "Horn")
                {
                    appModel.hornBackX = horn.position.x
                    appModel.hornBackY = horn.position.y
                }

                let tableAnchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: SIMD2<Float>(0.6, 0.6)))
                print("Got tableAnchor: \(tableAnchor)")
                print("Table anchor position: \(tableAnchor.position)")
                
                let headAnchor = AnchorEntity(.head)
                print("Got headAnchor: \(headAnchor)")
                print("Head anchor position: \(headAnchor.position)")
                
                content.add(headAnchor)
                appModel.headAnchor = headAnchor
                
                content.add(tableAnchor)
                appModel.tableAnchor = tableAnchor
            }
        }
        .gesture(tapGesture)
        .gesture(rotateGesture)

    }
    
    func getHeight(of entity: Entity) -> Float? {
        // Our entities doe not have a ModelComponent, but they do have a CollisionComponent

        // Ensure the entity has a CollisionComponent
        guard let collisionComponent = entity.components[CollisionComponent.self] else {
            return nil
        }
        
        // Get the extent of the collision shape
        //let shapeCount = collisionComponent.shapes.count
        let firstShapeBounds = collisionComponent.shapes.first?.bounds

        // Extract the height (Y component of the extent)
        guard let firstShapeBounds = firstShapeBounds else {
            return nil
        }
        let height = abs(firstShapeBounds.max.y - firstShapeBounds.min.y)

        return height
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
                    appModel.startingTransform = entity.transformMatrix(relativeTo: nil)
                    let entityHeight = getHeight(of: entity)
                    if let entityHeight = entityHeight {
                        //print("height of \(entity.name) is \(entityHeight)")
                        appModel.startingRotationCenter = SIMD3<Float>(0, (entityHeight / 2), 0)
                    } else {
                        //print("Unable to obtain height of entity")
                        appModel.startingRotationCenter = SIMD3<Float>(0, 1, 0) //.zero // entity.position(relativeTo: nil)                    }
                    }

                }
                // now, closeIsRotating is true, and we have the original orientation available
                let rotation = value.rotation
                
                // We want to rotate about a point halfway between the bottom and the top,
                // because rotation around zero is around the base of the entity, which
                // is not that great.
                
                // Therefore, we have already determined the rotation center based on the
                // height of the entity, based on the difference between max y and min y of
                // the collision components first shape
                
                // Now, we rotate by first translating to the origin, then apply the
                // rotation, then translate back to where we were
                
                // Convert Rotation3DGesture.Value to simd_quatf
                let axis = SIMD3<Float>(Float(rotation.axis.x), Float(rotation.axis.y), Float(rotation.axis.z))
                let angle = Float(rotation.angle.radians)
                let quaternion = simd_quatf(angle: angle, axis: axis)
                
                // Calculate the translation to maintain the rotation center
                let translationToCenter = float4x4(translation: appModel.startingRotationCenter)
                let translationBack = float4x4(translation: -appModel.startingRotationCenter)
                let rotationTransform = float4x4(quaternion)

                // Combine the current transform with the new rotation
                let newTransform = appModel.startingTransform * translationToCenter * rotationTransform * translationBack
                entity.setTransformMatrix(newTransform, relativeTo: nil)
                
                /*
                 // Alternative rotation code; allows head anchor to move entity while rotating, but
                 // rotates over the zero position of the entity, which is the bottom rather than the center
                 
                let flippedRotation = Rotation3D(angle: rotation.angle,
                                                 axis: RotationAxis3D(x: -rotation.axis.x,
                                                                      y: rotation.axis.y,
                                                                      z: -rotation.axis.z))
                let newOrientation =    appModel.startOrientation.rotated(by: flippedRotation)
                entity.setOrientation(.init(newOrientation), relativeTo: nil)
                */
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
                            // reset orientation always if appModel.closeIsRotating {
                                oldEntity.setOrientation(.init(appModel.startOrientation), relativeTo: nil)
                            //}
                            //oldEntity.setOrientation(simd_quatf(angle: 0, axis: SIMD3<Float>(0, 0, 1)), relativeTo: nil)
                            
                            // reparent the entity from the anchor, if that was used
                            appModel.originalParentEntity?.addChild(oldEntity)
                            
                            let axis = simd_float3(0, 1, 0) // Y-axis
                            let angle: Float = 0 // .pi / 4 // that would be 45 degrees

                            let quaternion = simd_quatf(angle: angle, axis: axis)
                            oldEntity.setOrientation(quaternion, relativeTo: nil)
                            oldEntity.scale.x = appModel.closeBaseScale
                            oldEntity.scale.y = appModel.closeBaseScale
                            oldEntity.scale.z = appModel.closeBaseScale
                            var xPos = appModel.jungleBackX
                            if oldEntity.name == "FishTeapot" {
                                xPos = appModel.fishBackX
                            } else {
                                if oldEntity.name == "Horn" {
                                    xPos = appModel.hornBackX
                                }
                            }
                            
                            oldEntity.position.x = xPos // appModel.closeBasePositionX
                            oldEntity.position.y = appModel.jungleBackY //appModel.closeBasePositionY
                            oldEntity.position.z = -2.0 // appModel.closeBasePositionZ
                            appModel.closeEntity = nil
                            // if we tapped on the close one, just put it back
                            if oldEntity.name == newEntityName {
                                return
                            }
                        }
                        
                    // Now, move the selected entity forward, and save that state in the appModel
                    // always reset the orientation first
                        newEntity.setOrientation(.init(appModel.startOrientation), relativeTo: nil)
                        appModel.closeEntity = newEntity
                        appModel.closeBasePositionX = newEntity.position.x
                        appModel.closeBasePositionY = newEntity.position.y
                        appModel.closeBasePositionZ = newEntity.position.z
                        appModel.closeBaseScale = newEntity.scale.x
                        //print("Making \(newEntityName) close; position was \(appModel.closeBasePositionX), \(appModel.closeBasePositionY), \(appModel.closeBasePositionZ), and scale \(appModel.closeBaseScale)")
                     
                        // instead of setting position, may anchor to head or table based on user request
                        if appModel.anchorToHead {
                            appModel.headAnchor?.addChild(newEntity)
                            // code to just position newEntity:
                            let height = getHeight(of: newEntity) ?? 0.5
                            // print("height of \(newEntityName) is \(height)")
                            newEntity.position.x = 0
                            newEntity.position.y = 0 - (height / 2) - 0.25
                            var zPos = -(height * 3)
                            if zPos > -1 {
                                zPos = -1
                            }
                            newEntity.position.z = zPos
                        } else {
                            if appModel.anchorToTable {
                                // Use a table anchor
                                appModel.tableAnchor?.addChild(newEntity)
                                newEntity.position.x = 0
                                newEntity.position.y = 0
                                newEntity.position.z = 0
                            } else {
                                // not anchored
                                newEntity.position.x = 0
                                newEntity.position.y = 1.3
                                newEntity.position.z = -1.0
                            }

                        }

                        
                    }
            }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
