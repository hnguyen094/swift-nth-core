//
//  ContentWithLoadView.swift
//  keepers
//
//  Created by Hung on 9/6/23.
//

import SwiftUI

struct ContentWithLoadView: View {
    @State var loaded : Bool = false
    var body: some View {
        if (!loaded) {
            WaitForCloudKitDataView(active: $loaded)
        } else {
            PetListView()
        }
    }
}

#Preview {
    ContentWithLoadView()
}
