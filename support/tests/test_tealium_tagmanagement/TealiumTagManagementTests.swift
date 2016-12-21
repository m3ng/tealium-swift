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
        
        let data = TealiumTagManagement.jsonEncode(sanitizedDictionary: ["abc":"123"])
        
        let dataString = "\(data!)"
        
        XCTAssertTrue(dataString == "{\"abc\":\"123\"}", "Unexpected dataString: \(dataString)")
    }
    
    func testSanitized() {
        
        let rawDictionary = ["string" : "string",
                             "int" : 5,
                             "float": 1.2,
                             "bool" : true,
                             "arrayOfStrings" : ["a", "b", "c"],
                             "arrayOfVariousNumbers": [1, 2.2, 3.0045],
                             "arrayOfBools" : [true, false, true],
                             "arrayOfMixedElements": [1, "two", 3.00]] as [String : Any]
        
        let sanitized = TealiumTagManagement.sanitized(dictionary: rawDictionary)
        
        print("Sanitized Dictionary: \(sanitized as AnyObject)")
        
        // TODO: Test data recieved by UDH
        
            // Sample output
//        Sanitized Dictionary: {
//            arrayOfBools = "[true, false, true]";
//            arrayOfMixedElements = "[1, \"two\", 3.0]";
//            arrayOfStrings = "[\"a\", \"b\", \"c\"]";
//            arrayOfVariousNumbers = "[1.0, 2.2000000000000002, 3.0045000000000002]";
//            bool = true;
//            float = "1.2";
//            int = 5;
//            string = string;
//        }
    }
}
