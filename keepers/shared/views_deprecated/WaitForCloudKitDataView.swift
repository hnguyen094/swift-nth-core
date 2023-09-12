//
//  WaitForCloudKitDataView.swift
//  keepers
//
//  Created by Hung on 9/5/23.
//

import SwiftUI
import CoreData

/// A loading screen that waits for CloudKit to publish its import event.
///
/// Code partially taken from [here](https://alexanderlogan.co.uk/blog/wwdc23/08-cloudkit-swift-data ).
struct WaitForCloudKitDataView: View {
    typealias CKContainer = NSPersistentCloudKitContainer

    @Binding var active: Bool
    
    var body: some View {
        VStack {
            ProgressView()
            Text("Fetching data...")
        }
        .onReceive(
            NotificationCenter.default.publisher(for: CKContainer.eventChangedNotification)
                .receive(on: DispatchQueue.main),
            perform: receive)
    }
    
    private func receive(notification : NotificationCenter.Publisher.Output) {
        guard 
            let evt = notification
                .userInfo?[CKContainer.eventNotificationUserInfoKey]
                as? CKContainer.Event,
            evt.endDate != nil,
            evt.type == .import
        else {
            return
        }
        withAnimation {
            active = true
        }
        
    }
}
