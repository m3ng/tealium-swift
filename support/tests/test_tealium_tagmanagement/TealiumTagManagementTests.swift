//
//  TealiumTagManagementTests.swift
//  tealium-swift
//
//  Created by Jason Koo on 12/16/16.
//  Copyright © 2016 tealium. All rights reserved.
//

import XCTest


/// Can only test class level functions due to limitation of XCTest with WebViews
class TealiumTagManagementTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        //
    }
    
    override func tearDown() {
        //
        super.tearDown()
    }

    // WebViews can not yet be tested by XCTest
//    func testEnableDisable() {
//     
//        expectationSuccess = self.expectation(description: "enable")
//        tagManagement?.enable(forAccount: "test",
//                              profile: "test",
//                              environment: "test",
//                              completion: { (success, error) in
//                                
//                                XCTAssertTrue(success)
//                                XCTAssertTrue(error == nil, "Unknown error returned: \(error)")
//                                self.expectationSuccess?.fulfill()
//        })
//        
//        self.waitForExpectation
//
//        tagManagement?.disable()
//        
//        XCTAssertTrue(tagManagement?.webView == nil, "Webview still available.")
//        
//    }
    
    func testGetLegacyTypeView() {

        let eventType = "tealium_event_type"
        let viewValue = "view"
        let viewDictionary = [eventType:viewValue]
        let viewResult = TealiumTagManagement.getLegacyType(fromData: viewDictionary)
        
        XCTAssertTrue(viewResult == viewValue)
        
    }
    
    func testGetLegacyTypeEvent() {
        
        let eventType = "tealium_event_type"
        let anyValue = "any"
        let eventDictionary = [eventType:anyValue]
        let eventResult = TealiumTagManagement.getLegacyType(fromData: eventDictionary)
        
        XCTAssertTrue(eventResult == "link")
        
    }
    
    func testJSONEncode(){
        
    }
    
    func testSanitized() {
        
        
    }
}
