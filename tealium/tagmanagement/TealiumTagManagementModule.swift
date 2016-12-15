//
//  TealiumTagManagement.swift
//  SegueCatalog
//
//  Created by Jason Koo on 12/14/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import Foundation

enum TealiumTagManagementKey {
    static let moduleName = "tagmanagement"
}

enum TealiumTagManagementError : Error {
    case couldNotLoadURL
    case couldNotJSONEncodeData
}

extension Tealium {
    
    public func tagManagement() -> TealiumTagManagement? {
        
        guard let module = modulesManager.getModule(forName: TealiumTagManagementKey.moduleName) as? TealiumTagManagementModule else {
            return nil
        }
        
        return module.tagManagement
        
    }
    
}

class TealiumTagManagementModule : TealiumModule {
    
    var tagManagement = TealiumTagManagement()
    var queue = [TealiumTrack]()

    override func moduleConfig() -> TealiumModuleConfig {
        return TealiumModuleConfig(name: TealiumTagManagementKey.moduleName,
                                   priority: 1100,
                                   build: 1,
                                   enabled: true)
    }
    
    override func enable(config: TealiumConfig) {
        
        let account = config.account
        let profile = config.profile
        let environment = config.environment
        tagManagement.delegate = self
        if tagManagement.enable(forAccount: account,
                                profile: profile,
                                environment: environment) == false {
            didFailToEnable(config: config,
                            error: TealiumTagManagementError.couldNotLoadURL)
        }
        
        didFinishEnable(config: config)
        
    }
    
    override func disable() {
        
        tagManagement.disable()
        
        didFinishDisable()
    }
    
    override func track(_ track: TealiumTrack) {
        
        addToQueue(track: track)

        if tagManagement.isWebViewReady() == false {
            
            // TODO: Queue notice
            
            self.didFinishTrack(track)
            return
        }
        
        sendQueue()
        
    }
    
    func send(_ track: TealiumTrack) {
        
        tagManagement.track(track.data,
                            completion:{(success, info, error) in
                                
            var newInfo = [String:AnyObject]()
            if let trackInfo = track.info {
                newInfo += trackInfo
            }
            newInfo += info
            
            let newTrack = TealiumTrack(data: track.data,
                                        info: newInfo,
                                        completion: track.completion)
            
            self.didFinishTrack(newTrack)
            
        })
        
    }
    
    // MARK: INTERNAL
    
    internal func addToQueue(track: TealiumTrack) {
        queue.append(track)
    }
    
    internal func sendQueue() {
        
        let queueCopy = queue
        
        for track in queueCopy{
        
            send(track)
            
            queue.removeFirst()
        
        }
    
    }

}

extension TealiumTagManagementModule : TealiumTagManagementDelegate {
    
    func TagManagementWebViewFinishedLoading() {
        
        sendQueue()
        
    }
    
}
