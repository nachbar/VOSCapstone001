//
//  AppModel.swift
//  VOSCapstone001
//
//  Created by James Nachbar on 6/13/24.
//

import SwiftUI
import RealityKit // for Entity

/// Maintains app-wide state
@MainActor
@Observable
class AppModel : ObservableObject {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var closeEntity : Entity? = nil
    var closeBasePositionX : Float = 0
    var closeBasePositionY : Float = 0
    var closeBasePositionZ : Float = 0
    var closeBaseScale : Float = 1.0
    
    // when objects are rotated in back, the origin can get reset, so be sure to restore it
    var jungleBackY : Float = 0
    var jungleBackX : Float = 0
    var fishBackY : Float = 0
    var fishBackX : Float = 0    
    var hornBackX : Float = 0
    var hornBackY : Float = 0

    var closeIsRotating : Bool = false
    var startOrientation = Rotation3D.identity
    var startingBaseOrientation = Rotation3D.identity
    
    var startingTransform : simd_float4x4 = .init()
    var startingRotationCenter: SIMD3<Float> = .zero
    
    var originalParentEntity : Entity? = nil
    /*
    var headAnchor: Entity = {
        let headAnchor = AnchorEntity(.head)
        headAnchor.position = [0, 1.5, -0.5]
        
        //let radians = -30 * Float.pi / 180
        //ImmersiveView.rotateEntityAroundYAxis(entity: headAnchor, angle: radians)
        
        return headAnchor
    }()
     */
    var headAnchor: Entity? = nil
    var anchorToHead : Bool = false
}
