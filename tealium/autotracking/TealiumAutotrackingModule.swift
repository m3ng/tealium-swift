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
    static let eventNotificationName = "com.tealium.autotracking.event"
    static let viewNotificationName = "com.tealium.autotracking.view"
    static let autotracked = "autotracked"
}

class TealiumAutotrackingModule : TealiumModule {
    
    override func moduleConfig() -> TealiumModuleConfig {
        return TealiumModuleConfig(name: TealiumAutotrackingKey.moduleName,
                                   priority: 300,
                                   build: 1,
                                   enabled: true)
    }
    
    override func enable(config: TealiumConfig) {
        
        let eventName = NSNotification.Name.init(TealiumAutotrackingKey.eventNotificationName)
        NotificationCenter.default.addObserver(self, selector: #selector(requestEventTrack(sender:)), name: eventName, object: nil)

        let viewName = NSNotification.Name.init(TealiumAutotrackingKey.viewNotificationName)
        NotificationCenter.default.addObserver(self, selector: #selector(requestViewTrack(sender:)), name: viewName, object: nil)
        
        self.didFinishEnable(config: config)
        
    }
    
    override func disable() {
        
        
        
        self.didFinishDisable()
            
    }

    @objc func requestEventTrack(sender: Notification) {
        
        guard let view = sender.object as? UIView else {
            return
        }
        
        let title = view.accessibilityIdentifier ??  String(describing: type(of: view))
        let data: [String : Any] = [TealiumKey.event: title ,
                                    TealiumKey.eventName: title ,
                                    TealiumKey.eventType: TealiumTrackType.activity.description(),
                                    TealiumAutotrackingKey.autotracked : "true",
                                    "was_tapped" : "true"]
        
        let track = TealiumTrack(data: data,
                                 info: [:],
                                 completion: {(success, info, error) in
                                    
                                    print("\n*** TRACK COMPLETION HANDLER *** Track finished. Was successful:\(success)\n\n Info:\(info as AnyObject)")

        })
        let process = TealiumProcess(type: .track,
                                     successful: true,
                                     track: track,
                                     error: nil)
        self.delegate?.tealiumModuleRequests(module: self, process: process)
        
    }
    
    @objc func requestViewTrack(sender: Notification) {
        
        guard let viewController = sender.object as? UIViewController else {
            return
        }
        
        let title = viewController.title ?? String(describing: type(of: viewController))
        let data: [String : Any] = [TealiumKey.event: title ,
                                    TealiumKey.eventName: title ,
                                    TealiumKey.eventType: TealiumTrackType.view.description(),
                                    TealiumAutotrackingKey.autotracked : "true",
                                    ]
        
        
        let track = TealiumTrack(data: data,
                                 info: [:],
                                 completion: {(success, info, error) in
        
                                    print("\n*** TRACK COMPLETION HANDLER *** Track finished. Was successful:\(success)\n\n Info:\(info as AnyObject)")
     
        })
        let process = TealiumProcess(type: .track,
                                     successful: true,
                                     track: track,
                                     error: nil)
        self.delegate?.tealiumModuleRequests(module: self, process: process)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
