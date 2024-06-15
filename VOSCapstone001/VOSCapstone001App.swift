//
//  VOSCapstone001App.swift
//  VOSCapstone001
//
//  Created by James Nachbar on 6/13/24.
//

import SwiftUI


@main
struct VOSCapstone001App: App {

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.scenePhase) private var scenePhase
    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
            // .onAppear always gets called, but .onDisappear doesn't.  onChange(of: scenePhase) allows us to detect when the ContentView is closed, and escape from immersive view
            .onChange(of: scenePhase) { _, newScenePhase in
                if newScenePhase == .background || newScenePhase == .inactive {
                    //appState.visibleScenes.remove(trackedScene)
                    Task { @MainActor in
                        switch appModel.immersiveSpaceState {
                            case .open:
                                appModel.immersiveSpaceState = .inTransition
                            print("about to await dismissImmersiveSpace")
                                await dismissImmersiveSpace()
                                // Don't set immersiveSpaceState to .closed because there
                                // are multiple paths to ImmersiveView.onDisappear().
                                // Only set .closed in ImmersiveView.onDisappear().

                            break

                            case .inTransition:
                                // This case should not ever happen because button is disabled for this case.
                                break
                        case .closed:
                            break
                        }
                    }
                    
                }
                print("onChange(of: scenePhase) called for ContentView in App, with scenePhase \(scenePhase), newScenePhase \(newScenePhase)")
            }
            .volumeBaseplateVisibility(appModel.immersiveSpaceState == .open ? .hidden : .automatic)
        }
        .windowStyle(.volumetric)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed, .full, .progressive)
    }
}
