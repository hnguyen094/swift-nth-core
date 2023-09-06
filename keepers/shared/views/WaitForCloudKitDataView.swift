//
//  WaitForCloudKitDataView.swift
//  keepers
//
//  Created by Hung on 9/5/23.
//

import SwiftUI
import CoreData

typealias CLContainer = NSPersistentCloudKitContainer

/// A loading screen that waits for CloudKit to publish its import event.
///
/// Code partially taken from [here](https://alexanderlogan.co.uk/blog/wwdc23/08-cloudkit-swift-data).
struct WaitForCloudKitDataView: View {
    @Binding var active: Bool
    
    var body: some View {
        VStack {
            ProgressView()
            Text("Fetching data...")
        }
        .onReceive(
            NotificationCenter.default.publisher(for: CLContainer.eventChangedNotification)
                .receive(on: DispatchQueue.main),
            perform: receive)
    }
    
    private func receive(notification : NotificationCenter.Publisher.Output) {
        guard 
            let evt = notification
                .userInfo?[CLContainer.eventNotificationUserInfoKey]
                as? CLContainer.Event,
            evt.endDate != nil,
            evt.type == .import
        else {
            return
        }
        logger.info("Loaded iCloud data from container.")
        withAnimation {
            active = true
        }
        
    }
}
