//
//  TealiumTagManagementModuleTests.swift
//  tealium-swift
//
//  Created by Jason Koo on 12/16/16.
//  Copyright © 2016 tealium. All rights reserved.
//

import XCTest

class TealiumTagManagementModuleTests: XCTestCase {
    
    var delegateExpectationSuccess : XCTestExpectation?
    var delegateExpectationFail : XCTestExpectation?
    var module : TealiumTagManagementModule?
    var queueName: String?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMinimumProtocolsReturn() {
        
        let helper = test_tealium_helper()
        let module = TealiumTagManagementModule(delegate: nil)
        let tuple = helper.modulesReturnsMinimumProtocols(module: module)
        XCTAssertTrue(tuple.success, "Not all protocols returned. Failing protocols: \(tuple.protocolsFailing)")
        
    }

    
}


extension TealiumTagManagementModuleTests : TealiumModuleDelegate {
    
    func tealiumModuleFinished(module: TealiumModule, process: TealiumProcess) {
        
        delegateExpectationSuccess?.fulfill()
        
        queueName = currentQueueName()
        
    }
    
    func tealiumModuleRequests(module: TealiumModule, process: TealiumProcess) {
        
        delegateExpectationSuccess?.fulfill()
        
        queueName = currentQueueName()
        
    }
    
    func tealiumModuleFinishedReport(fromModule: TealiumModule, module: TealiumModule, process: TealiumProcess) {
        
        delegateExpectationSuccess?.fulfill()
        
        queueName = currentQueueName()
        
    }
    
}
