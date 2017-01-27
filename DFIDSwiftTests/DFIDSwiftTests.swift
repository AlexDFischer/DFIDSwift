//
//  DFIDSwiftTests.swift
//  DFIDSwiftTests
//
//  Created by Alexander Fischer on 1/16/17.
//  Copyright © 2017 UMass CS. All rights reserved.
//

import XCTest
import DFIDSwift

class DFIDSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPrintDFID() {
        //let dfid: String = DFID.dfid();
        //print(dfid);
        print("raw string is: " + DFID.buildRawString() + "\n");
        print("DFID is: " + DFID.dfid() + "\n");
    }
    
}
