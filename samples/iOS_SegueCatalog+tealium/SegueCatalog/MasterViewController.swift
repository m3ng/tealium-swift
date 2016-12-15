/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    The view controller used as the root of the split view's master-side navigation controller.
*/

import UIKit

class MasterViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let extraData : [String:AnyObject] = ["link_id" : "launchtest" as AnyObject]
        
        TealiumHelper.sharedInstance().track(title: "launchtest",
                                             data: extraData)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let extraData : [String:AnyObject] = ["screen_title" : "viewtest" as AnyObject,
                                              "tealium_event_type" : "view" as AnyObject]
        
        TealiumHelper.sharedInstance().track(title: "viewtest",
                                             data: extraData)
    }
    
    @IBAction func unwindInMaster(_ segue: UIStoryboardSegue)  {
        /*
            Empty. Exists solely so that "unwind in master" segues can
            find this instance as a destination.
        */
    }
}
