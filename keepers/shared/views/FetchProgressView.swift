//
//  FetchProgressView.swift
//  keepers
//
//  Created by Hung on 9/5/23.
//

import SwiftUI

import SwiftData
import CoreData

typealias CLContainer = NSPersistentCloudKitContainer

struct FetchProgressView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack {
            ProgressView()
            Text("Fetching data...")
        }
        .progressViewStyle(.circular)
        .onReceive(
            NotificationCenter.default.publisher(
                for: CLContainer.eventChangedNotification)) { notification in
                    guard let evt = notification.userInfo?[CLContainer.eventNotificationUserInfoKey]
                            as? CLContainer.Event else {
                        return; // not event we're looking for
                    }
                    if evt.endDate != nil && evt.type == .import {
                        Task { @MainActor in
                            let petFetchDescriptor = FetchDescriptor<Pet_Identity>()
                            _ = try? modelContext.fetch(petFetchDescriptor)
                            
                        }
                    }
                }
    }
}
