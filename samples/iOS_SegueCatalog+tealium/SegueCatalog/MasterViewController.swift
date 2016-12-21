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
        
        let simpleDict = ["app_name":"swiftSampleApp",
                          "link_id":"linkTest"]
//        let rawDictionary = ["app_name" : "swiftSampleApp",
//                             "link_id" : "legacy_event_id",
//                             "string" : "string",
//                             "int" : 5,
//                             "float": 1.2,
//                             "bool" : true,
//                             "arrayOfStrings" : ["a", "b", "c"],
//                             "arrayOfVariousNumbers": [1, 2.2, 3.0045],
//                             "arrayOfBools" : [true, false, true],
//                             "arrayOfMixedElements": [1, "two", 3.00]] as [String : Any]
        
        TealiumHelper.sharedInstance().track(title: "launchtest",
                                             data: simpleDict)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let extraData : [String:Any] = ["app_name" : "swiftSampleApp",
                                        "screen_title" : "masterView",
                                        "tealium_event_type" : "view"]
        
        
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
