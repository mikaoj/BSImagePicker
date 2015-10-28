//
//  BSImagePicker_UI_Tests.swift
//  BSImagePicker_UI_Tests
//
//  Created by Joakim Gyllström on 2015-10-27.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
@testable import BSImagePicker

class BSImagePicker_UI_Tests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDoneButtonDisabledOnStartup() {
        let app = XCUIApplication()
        app.buttons["Image picker"].tap()
        XCTAssert(app.navigationBars.buttons.elementBoundByIndex(3).enabled == false)
    }
    
    func testDoneButtonEnabledAfterSelection() {
        let app = XCUIApplication()
        app.buttons["Image picker"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        XCTAssert(app.navigationBars.buttons.elementBoundByIndex(3).enabled == true)
    }
    
    func testDoneButtonDisabledAfterDeselection() {
        let app = XCUIApplication()
        app.buttons["Image picker"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        XCTAssert(app.navigationBars.buttons.elementBoundByIndex(3).enabled == false)
    }
    
    func testLongpressPreview() {
        
        let app = XCUIApplication()
        app.buttons["Image picker"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.pressForDuration(1.0);
        app.navigationBars.buttons["Back"].tap()
        XCTAssert(app.navigationBars.buttons.elementBoundByIndex(3).enabled == false)
    }
}
