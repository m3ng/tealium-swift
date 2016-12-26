//
//  TealiumAutotrackingModule.swift
//  SegueCatalog
//
//  Created by Jason Koo on 12/21/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

#if TEST
    import Foundation
#else
    import UIKit
#endif

enum TealiumAutotrackingKey {
    static let moduleName = "autotracking"
    static let eventNotificationName = "com.tealium.autotracking.event"
    static let viewNotificationName = "com.tealium.autotracking.view"
    static let autotracked = "autotracked"
}

extension Tealium {
    
    public func autotracking() -> TealiumAutotracking? {
        
        guard let module = modulesManager.getModule(forName: TealiumAutotrackingKey.moduleName) as? TealiumAutotrackingModule else {
            return nil
        }
        
        return module.autotracking
        
    }
    
}


public protocol TealiumAutotrackingDelegate {
    
    func autotrackShouldTrack(data: [String:Any]) -> Bool
    func autotrackCompleted(success:Bool, info:[String:Any]?, error:Error?)
    
}

public class TealiumAutotracking {
    
    var delegate : TealiumAutotrackingDelegate?
    
}

class TealiumAutotrackingModule : TealiumModule {
    
    var notificationsEnabled = false
    let autotracking = TealiumAutotracking()
    
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
        
        notificationsEnabled = true
        self.didFinishEnable(config: config)
        
    }
    
    override func disable() {
        
        if notificationsEnabled == true {
            NotificationCenter.default.removeObserver(self)
            notificationsEnabled = false
        }
        
        self.didFinishDisable()
            
    }

    @objc func requestEventTrack(sender: Notification) {
        
        if notificationsEnabled == false {
            return
        }
    
        var title = ""
        if let object = sender.object {
            title = String(describing: type(of: object))
        }
        
        let data: [String : Any] = [TealiumKey.event: title ,
                                    TealiumKey.eventName: title ,
                                    TealiumKey.eventType: TealiumTrackType.activity.description(),
                                    TealiumAutotrackingKey.autotracked : "true",
                                    "was_tapped" : "true"]
        
        if autotracking.delegate?.autotrackShouldTrack(data: data) == false {
            return
        }
        
        let completion : tealiumTrackCompletion = {(success, info, error) in
            self.autotracking.delegate?.autotrackCompleted(success:success, info:info, error:error)
        }
        
        let track = TealiumTrack(data: data,
                                 info: [:],
                                 completion: completion)
        
        let process = TealiumProcess(type: .track,
                                     successful: true,
                                     track: track,
                                     error: nil)
        self.delegate?.tealiumModuleRequests(module: self, process: process)

    }
    
    @objc func requestViewTrack(sender: Notification) {
        
        if notificationsEnabled == false {
            return
        }
        
        #if TEST
        #else
        guard let viewController = sender.object as? UIViewController else {
            return
        }
        
        let title = viewController.title ?? String(describing: type(of: viewController))
        let data: [String : Any] = [TealiumKey.event: title ,
                                    TealiumKey.eventName: title ,
                                    TealiumKey.eventType: TealiumTrackType.view.description(),
                                    TealiumAutotrackingKey.autotracked : "true",
                                    ]
        
        if autotracking.delegate?.autotrackShouldTrack(data: data) == false {
            return
        }
            
            
        let completion : tealiumTrackCompletion = {(success, info, error) in
            self.autotracking.delegate?.autotrackCompleted(success:success, info:info, error:error)
        }
        
        let track = TealiumTrack(data: data,
                                 info: [:],
                                 completion: completion)
              
        let process = TealiumProcess(type: .track,
                                     successful: true,
                                     track: track,
                                     error: nil)
        self.delegate?.tealiumModuleRequests(module: self, process: process)
        #endif
        
    }
    
    deinit {
        
        if notificationsEnabled == true {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
}
