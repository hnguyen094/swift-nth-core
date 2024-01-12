//
//  ARUpdates.swift
//  keepers
//
//  Created by hung on 1/12/24.
//

import Foundation
import CoreMedia

struct ARUpdates {
    enum Event {
            case anchorAdded(_ anchors: [UUID : AnchorFacade])
            case anchorUpdated(_ anchors: [UUID : AnchorFacade])
            case anchorRemoved(_ ids: [UUID])
            
            // TODO: avoid classes through TCA when possible?
            case frameUpdated(FrameFacade)
            case audioSampleBufferOutputted(CMSampleBuffer)
        }
}
