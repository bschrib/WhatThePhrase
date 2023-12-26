//
//  WhatThePhraseUITests.swift
//  WhatThePhraseUITests
//
//  Created by Brandon Schreiber on 4/19/23.
//

import XCTest

final class WhatThePhraseUITests: XCTestCase {
    let app = XCUIApplication()
    
    func testTakeScreenshots() {
      let app = XCUIApplication()
      setupSnapshot(app)
      app.launch()
        
      snapshot("01CategoryView")
      app.scrollViews.otherElements.buttons["Places & Spaces"].tap()
      app.buttons["Start"].tap()
      snapshot("02GameView")
      app.buttons["Team 2"].tap()
      let stopButton = app.buttons["Stop"]
      stopButton.tap()
      snapshot("03GameViewComplete")
      let okButton = app.alerts["Time's Up!"].scrollViews.otherElements.buttons["OK"]
      okButton.tap()
      app.navigationBars["Select Category"]/*@START_MENU_TOKEN@*/.buttons["gearshape"]/*[[".otherElements[\"gearshape\"].buttons[\"gearshape\"]",".buttons[\"gearshape\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
      snapshot("04SettingsView")
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
