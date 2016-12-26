//
//  TealiumHelper.swift
//  WatchPuzzle
//
//  Created by Jason Koo on 11/22/16.
//  Copyright © 2016 Apple. All rights reserved.
//

import Foundation


/// Example of a shared helper to handle all 3rd party tracking services. This
/// paradigm is recommended to reduce burden of future code updates for external services
/// in general.
class TealiumHelper : NSObject {
    
    static let _sharedInstance = TealiumHelper()
    fileprivate var tealium : Tealium
    
    class func sharedInstance() -> TealiumHelper {
        
        return _sharedInstance
        
    }
    
    override init() {
        tealium = Tealium(config: defaultTealiumConfig)
    }
    
    func start() {
        tealium.autotracking()?.delegate = self
    }
    
    func track(title: String, data:[String:Any]?) {
    
        tealium.track(title: title,
                      data: data,
                      completion: { (success, info, error) in
                        
            print("\n*** TRACK COMPLETION HANDLER *** Track finished. Was successful:\(success)\n\n Info:\(info as AnyObject)")
                        
        })
    }
    
}

extension TealiumHelper : TealiumAutotrackingDelegate {
    
    func autotrackShouldTrack(data: [String : Any]) -> Bool {
        
        if data["tealium_event_type"] as? String == "view" {
            return false
        }
        
        return true
    }
    
    func autotrackCompleted(success: Bool, info: [String : Any]?, error: Error?) {
        
        print("\n*** AUTO TRACK COMPLETION HANDLER *** Track finished. Was successful:\(success)\n\n Info:\(info as AnyObject)")

    }
}
