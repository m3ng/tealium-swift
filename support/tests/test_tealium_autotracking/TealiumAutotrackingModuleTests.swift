//
//  TealiumAutotrackingModuleTests.swift
//  tealium-swift
//
//  Created by Jason Koo on 12/22/16.
//  Copyright © 2016 tealium. All rights reserved.
//

import XCTest

class TealiumAutotrackingModuleTests: XCTestCase {
    
    var module : TealiumAutotrackingModule?
    var expectationRequest : XCTestExpectation?
    var requestProcess : TealiumProcess?
    
    override func setUp() {
        super.setUp()
        module = TealiumAutotrackingModule(delegate: self)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        expectationRequest = nil
        requestProcess = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMinimumProtocolsReturn() {
        
        let helper = test_tealium_helper()
        let module = TealiumAutotrackingModule(delegate: nil)
        let tuple = helper.modulesReturnsMinimumProtocols(module: module)
        XCTAssertTrue(tuple.success, "Not all protocols returned. Failing protocols: \(tuple.protocolsFailing)")
        
    }
    
    func testEnableDisable() {
        
        module!.enable(config: testTealiumConfig)
        
        XCTAssertTrue(module!.notificationsEnabled)
        
        module!.disable()
        
        XCTAssertFalse(module!.notificationsEnabled)
        
    }
    
    func testRequestEmptyEventTrack() {
        
        module?.enable(config: testTealiumConfig)
        
        let notification = Notification(name: Notification.Name(rawValue: "com.tealium.autotracking.event"),
                                        object: nil,
                                        userInfo: nil)
        
        expectationRequest = expectation(description: "eventDetected")
        
        module?.requestEventTrack(sender: notification)
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertTrue(requestProcess != nil)
        
        
        let data: [String : Any] = ["tealium_event": "",
                                    "event_name": "" ,
                                    "tealium_event_type": "activity",
                                    "autotracked" : "true",
                                    "was_tapped" : "true"]

        guard let recievedData = requestProcess?.track?.data else {
            XCTFail("No track data retured with request: \(requestProcess!)")
            return
        }
        
        XCTAssertTrue(recievedData == data, "Mismatch between data expected: \n \(data as AnyObject) and data received post processing: \n \(recievedData as AnyObject)")
        
        
    }
    
    func testRequestEmptyEventTrackWhenDisabled() {
        
        module?.enable(config: testTealiumConfig)
        
        module?.disable()
        
        let notification = Notification(name: Notification.Name(rawValue: "com.tealium.autotracking.event"),
                                        object: nil,
                                        userInfo: nil)
        
        module?.requestEventTrack(sender: notification)

        
        XCTAssertTrue(requestProcess == nil, "Module not disabled as expected")
        
    }
    
    
    func testRequestEventTrack() {
        
        module?.enable(config: testTealiumConfig)
        
        let testObject = TestObject()
        
        let notification = Notification(name: Notification.Name(rawValue: "com.tealium.autotracking.event"),
                                        object: testObject,
                                        userInfo: nil)
        
        expectationRequest = expectation(description: "eventDetected")
        
        module?.requestEventTrack(sender: notification)
        
        waitForExpectations(timeout: 1.0, handler: nil)
        
        XCTAssertTrue(requestProcess != nil)
        
        
        let data: [String : Any] = ["tealium_event": "TestObject",
                                    "event_name": "TestObject" ,
                                    "tealium_event_type": "activity",
                                    "autotracked" : "true",
                                    "was_tapped" : "true"]
        
        guard let recievedData = requestProcess?.track?.data else {
            XCTFail("No track data retured with request: \(requestProcess!)")
            return
        }
        
        XCTAssertTrue(recievedData == data, "Mismatch between data expected: \n \(data as AnyObject) and data received post processing: \n \(recievedData as AnyObject)")
        
        
    }
    
    // Cannot unit test requestViewTrack
    
    // Cannot unit test swizzling
    
}



extension TealiumAutotrackingModuleTests : TealiumModuleDelegate {
    
    func tealiumModuleFinished(module: TealiumModule, process: TealiumProcess) {
        
    }
    
    func tealiumModuleRequests(module: TealiumModule, process: TealiumProcess) {
     
        requestProcess = process
        expectationRequest?.fulfill()
        
    }
    
    func tealiumModuleFinishedReport(fromModule: TealiumModule, module: TealiumModule, process: TealiumProcess) {
        
    }
}

class TestObject: NSObject {
    
    
}
