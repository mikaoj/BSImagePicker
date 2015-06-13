//
//  BSImagePicker_UI_Tests.swift
//  BSImagePicker UI Tests
//
//  Created by Joakim Gyllström on 2015-06-12.
//  Copyright © 2015 Joakim Gyllström. All rights reserved.
//

import Foundation
import XCTest

class BSImagePicker_UI_Tests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDoneButtonDisabled() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        
        XCTAssert(app.navigationBars.buttons["Done"].enabled == false, "No images selected, done button should be disabled")
    }
    
    func testDoneButtonEnabled() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        
        let element = app.windows.childrenMatchingType(.Unknown).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(0)
        element.tap()
        
        XCTAssert(app.navigationBars.buttons["Done"].enabled == true, "1 image selected, done button should be enabled")
    }
    
    func testDoneButtonDisabledEfterDeselecting() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()

        let cells = app.windows.childrenMatchingType(.Unknown).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(0).cells
        
        // Select & deselect
        cells.elementAtIndex(0).tap()
        cells.elementAtIndex(0).tap()
        
        XCTAssert(app.navigationBars.buttons["Done"].enabled == false, "No images selected, done button should be disabled")
    }
    
    func testStillSelectedAfterPreview() {
        let app = XCUIApplication()
        app.buttons["Button"].tap()
        
        let cells = app.windows.childrenMatchingType(.Unknown).elementAtIndex(0).childrenMatchingType(.Unknown).elementAtIndex(0).cells
        
        let firstCell = cells.elementAtIndex(0)
        firstCell.tap()
        
        cells.elementAtIndex(4).pressForDuration(1.1);
        app.navigationBars.buttons["Back"].tap()
        
        let selectedCell = cells.elementMatchingPredicate(NSPredicate(format: "selected == true"))        
        XCTAssert(selectedCell.exists)
    }
}
