//
//  TealiumAutotrackingModule.swift
//  SegueCatalog
//
//  Created by Jason Koo on 12/21/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import UIKit

enum TealiumAutotrackingKey {
    static let moduleName = "autotracking"
}

class TealiumAutotrackingModule : TealiumModule {
    
    override func moduleConfig() -> TealiumModuleConfig {
        return TealiumModuleConfig(name: TealiumAutotrackingKey.moduleName,
                                   priority: 300,
                                   build: 1,
                                   enabled: true)
    }
    
    override func enable(config: TealiumConfig) {
        
        
        
        self.didFinishEnable(config: config)
        
    }
    
    override func disable() {
        
        
        
        self.didFinishDisable()
            
    }
    
    override func track(_ track: TealiumTrack) {
        
        
        self.didFinishTrack(track)
        
    }

    
}

extension UIApplication {
    
    
    
}
