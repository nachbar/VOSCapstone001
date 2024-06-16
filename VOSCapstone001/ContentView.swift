//
//  ContentView.swift
//  VOSCapstone001
//
//  Created by James Nachbar on 6/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @State private var enlarge = false
    @State private var anchorToHead : Bool = false // local copy, because binding does not appear to work with environment appModel
    
    @State private var anchorToTable : Bool = false
    @Environment(AppModel.self) private var appModel

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                content.add(scene)
            }
        } update: { content in
            // Hide RealityKit content when we enter immersive
            if let scene = content.entities.first {
                if appModel.immersiveSpaceState == .open
                    {
                        scene.isEnabled = false
                        return
                    } else {
                        scene.isEnabled = true
                        // Update the RealityKit content when SwiftUI state changes

                        let uniformScale: Float = enlarge ? 1.4 : 1.0
                        scene.transform.scale = [uniformScale, uniformScale, uniformScale]
                    }
                }
            
            
            // Update the RealityKit content when SwiftUI state changes
            if let scene = content.entities.first {
                let uniformScale: Float = enlarge ? 1.4 : 1.0
                scene.transform.scale = [uniformScale, uniformScale, uniformScale]
            }
        }
        .gesture(TapGesture().targetedToAnyEntity().onEnded { _ in
            enlarge.toggle()
        })
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                VStack (spacing: 12) {
                    /*
                    Button {
                        enlarge.toggle()
                    } label: {
                        Text(enlarge ? "Reduce RealityView Content" : "Enlarge RealityView Content")
                    }
                    .animation(.none, value: 0)
                    .fontWeight(.semibold)
                     */
                    ToggleImmersiveSpaceButton()
                    // Only allow toggling of anchor flag while immersive state is closed
                    if appModel.immersiveSpaceState == .closed
                    {
                        Toggle(isOn: $anchorToHead) {
                            Text("Anchor Close Object to Your Head")
                        }
                        .onChange(of: anchorToHead) { oldValue, newValue in
                            appModel.anchorToHead = anchorToHead
                            // can only anchor to one thing
                            if newValue {
                                anchorToTable = false
                                appModel.anchorToTable = false
                            }
                        }

                        Toggle(isOn: $anchorToTable) {
                            Text("Anchor Close Object to Table")
                        }
                        .onChange(of: anchorToTable) { oldValue, newValue in
                            appModel.anchorToTable = anchorToTable
                            // can only anchor to one thing
                            if newValue {
                                anchorToHead = false
                                appModel.anchorToHead = false
                            }
                        }
                    } else {
                        // In immersive space, show the button that will show or hide signs, and
                        // provide notification about anchoring
                        Button {
                            appModel.showSigns.toggle()
                        } label: {
                            Text(appModel.showSigns ? "Hide Signs" : "Show Signs")
                        }
                        Text(anchorToHead ? "Head anchored" : (anchorToTable ? "Table anchord" : "Not anchored"))
                    }
                }
            }
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
        .environment(AppModel())
}
