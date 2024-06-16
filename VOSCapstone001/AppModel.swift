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
class AppModel {
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
    
    var closeIsRotating : Bool = false
    var startOrientation = Rotation3D.identity
    var startingBaseOrientation = Rotation3D.identity
    
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
}
