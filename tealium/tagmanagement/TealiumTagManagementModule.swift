//
//  TealiumTagManagement.swift
//  SegueCatalog
//
//  Created by Jason Koo on 12/14/16.
//  Copyright © 2016 Apple, Inc. All rights reserved.
//

import Foundation

enum TealiumTagManagementKey {
    static let estimatedProgress = "estimatedProgress"
    static let moduleName = "tagmanagement"
    static let payload = "payload"
    static let responseHeader = "response_headers"
    static let dispatchService = "dispatch_service"
    static let jsCommand = "js_command"
    static let jsResult = "js_result"
}

enum TealiumTagManagementError : Error {
    case couldNotCreateURL
    case couldNotLoadURL
    case couldNotJSONEncodeData
    case webViewNotYetReady
}

extension Tealium {
    
    // A lot of if elses as UIWebview, the primary element of TealiumTagManagement can not run in XCTests
    
    #if TEST
    #else
    public func tagManagement() -> TealiumTagManagement? {
        
        guard let module = modulesManager.getModule(forName: TealiumTagManagementKey.moduleName) as? TealiumTagManagementModule else {
            return nil
        }
        
        return module.tagManagement
        
    }
    #endif
}

class TealiumTagManagementModule : TealiumModule {
    
    #if TEST
    #else
    var tagManagement = TealiumTagManagement()
    #endif
    var queue = [TealiumTrack]()

    override func moduleConfig() -> TealiumModuleConfig {
        return TealiumModuleConfig(name: TealiumTagManagementKey.moduleName,
                                   priority: 1100,
                                   build: 1,
                                   enabled: true)
    }
    
    override func enable(config: TealiumConfig) {
        
        // TODO: Check if Tag Management should be enabled.
        let account = config.account
        let profile = config.profile
        let environment = config.environment
        
        #if TEST
            self.didFinishEnable(config: config)
        #else
        DispatchQueue.main.async {

            self.tagManagement.delegate = self
            self.tagManagement.enable(forAccount: account,
                                 profile: profile,
                                 environment: environment,
                                 completion: {(success, error) in
            
                if success == false {
                    self.didFailToEnable(config: config,
                                    error: TealiumTagManagementError.couldNotLoadURL)
                    return
                }
                self.didFinishEnable(config: config)
                                    
            })
        }
        #endif
        
    }
    
    override func disable() {
        
        #if TEST
        #else
        DispatchQueue.main.async {

            self.tagManagement.disable()

        }
        #endif
        didFinishDisable()
    }
    
    override func track(_ track: TealiumTrack) {
        
        #if TEST
        self.didFinishTrack(track)
        #else

        DispatchQueue.main.async {
            
            self.addToQueue(track: track)
            
            if self.tagManagement.isWebViewReady() == false {
                // Not ready to send, move on.
                self.didFinishTrack(track)
                return
            }
            self.sendQueue()
        }
        #endif

    }
    
    func send(_ track: TealiumTrack) {
        
        #if TEST
        #else
        tagManagement.track(track.data,
                            completion:{(success, info, error) in
                                        
            track.completion?(success, info, error)
            self.didFinishTrack(track)
                                
        })
        #endif
        
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

#if TEST
#else
extension TealiumTagManagementModule : TealiumTagManagementDelegate {
    
    func TagManagementWebViewFinishedLoading() {
        
        DispatchQueue.main.async {
            
            self.sendQueue()
            
        }
    }
    
}
#endif
