// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
import Photos
@testable import BSImagePicker

class BSImagePicker_UI_Tests: XCTestCase {
        
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        sleep(3)

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
        super.tearDown()
    }
    
    func testDoneButtonDisabledOnStartup() {
        app.buttons["Image picker"].tap()
        XCTAssert(app.navigationBars.buttons["Done"].enabled == false)
    }
    
    func testDoneButtonEnabledAfterSelection() {
        app.buttons["Image picker"].tap()
        app.collectionViews.childrenMatchingType(.Any).elementBoundByIndex(0).tap()
        XCTAssert(app.navigationBars.buttons["Done (1)"].enabled == true)
    }
    
    func testDoneButtonDisabledAfterDeselection() {
        app.buttons["Image picker"].tap()
        app.collectionViews.childrenMatchingType(.Any).elementBoundByIndex(0).tap()
        app.collectionViews.childrenMatchingType(.Any).elementBoundByIndex(0).tap()
        XCTAssert(app.navigationBars.buttons["Done"].enabled == false)
    }
    
    func testLongpressPreview() {
        app.buttons["Image picker"].tap()
        app.collectionViews.childrenMatchingType(.Any).elementBoundByIndex(0).pressForDuration(1.0)
        app.navigationBars.buttons["Back"].tap()
        XCTAssert(app.navigationBars.buttons["Done"].enabled == false)
    }
}
