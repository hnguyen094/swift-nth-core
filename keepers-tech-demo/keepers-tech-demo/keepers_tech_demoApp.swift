//
//  keepers_tech_demoApp.swift
//  keepers-tech-demo
//
//  Created by hung on 1/13/24.
//

import SwiftUI
import ComposableArchitecture
import ARKit

@main
struct keepers_tech_demoApp: App {
    @State var session = ARKitSession()
    @State var size: CGSize = .init(width: 400, height: 400)
    
    private let store = Store(initialState: Creature.Feature.State()) {
        Creature.Feature()
    }
    
    init() {
        Emoting.System.registerSystem()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .frame(
                    minWidth: size.width, maxWidth: size.width,
                    minHeight: size.height, maxHeight: size.height)
        }
        .windowResizability(.contentSize)
        ImmersiveSpace(id: ImmersiveView.ID) {
            ImmersiveView()
                .task {
                    let authorizations = await session.requestAuthorization(for: [.handTracking, .worldSensing])
                    switch authorizations[.worldSensing] {
                    case .allowed:
                        print("World sensing allowed")
                    case .denied:
                        print("World sensing denied")
                    case .notDetermined:
                        print("World sensing not determined")
                    default:
                        print("World sensing authorization error")
                    }
                    switch authorizations[.handTracking] {
                    case .allowed:
                        print("Hand tracking allowed")
                    case .denied:
                        print("Hand tracking denied")
                    case .notDetermined:
                        print("Hand tracking not determined")
                    default:
                        print("Hand tracking authorization error")
                    }
                    
                    var trackingProviders = [DataProvider]()
                    
                    if PlaneDetectionProvider.hasRequiredAuthorizations(authorizations) &&
                        PlaneDetectionProvider.isSupported {
                        trackingProviders.append(PlaneDetectionProvider(alignments: [.horizontal]))
                    }
                    if HandTrackingProvider.hasRequiredAuthorizations(authorizations) &&
                        HandTrackingProvider.isSupported {
                        trackingProviders.append(HandTrackingProvider())
                    }
                    if WorldTrackingProvider.hasRequiredAuthorizations(authorizations) &&
                        WorldTrackingProvider.isSupported {
                        trackingProviders.append(WorldTrackingProvider())
                    }
                                        
                    do {
                        try await session.run(trackingProviders)
                    } catch {
                        print("ARKit session error \(error)")
                    }
                    
                }
        }
    }
}
