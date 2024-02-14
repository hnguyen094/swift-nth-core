//
//  UserDefaults+Extensions.swift
//  dimensions
//
//  Created by hung on 2/7/24.
//

import NthComposable

extension UserDefaultsClient {
    var hasShownFirstLaunch: Bool {
        self.boolForKey(Keys.hasShownFirstLaunch.rawValue)
    }
    
    func setHasShownFirstLaunch(_ v: Bool) async {
        await self.setBool(v, Keys.hasShownFirstLaunch.rawValue)
    }
    
    var usesMetricSystem: Bool {
        self.boolForKey(Keys.usesMetricSystem.rawValue)
    }
    
    func setUsesMetricSystem(_ v: Bool) async {
        await self.setBool(v, Keys.usesMetricSystem.rawValue)
    }

    var prefersMeshReconstruction: Bool {
        self.boolForKey(Keys.prefersMeshReconstruction.rawValue)
    }

    func setPrefersMeshReconstruction(_ v: Bool) async {
        await self.setBool(v, Keys.prefersMeshReconstruction.rawValue)
    }

    private enum Keys: String {
        case hasShownFirstLaunch
        case usesMetricSystem
        case prefersMeshReconstruction
    }
}
