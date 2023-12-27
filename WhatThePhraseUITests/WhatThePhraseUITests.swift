//
//  WhatThePhraseUITests.swift
//  WhatThePhraseUITests
//
//  Created by Brandon Schreiber on 4/19/23.
//

import XCTest

final class WhatThePhraseUITests: XCTestCase {
    let app = XCUIApplication()
    
    func testTakeScreenshots() async throws {
      await setupSnapshot(app)
      app.launch()
        await snapshot("01CategoryView")
        
      app.scrollViews.otherElements.buttons["Places & Spaces"].tap()
      app.buttons["Start"].tap()
        await snapshot("02GameView")
        
      app.buttons["Team 2"].tap()
      let stopButton = app.buttons["Stop"]
      stopButton.tap()
        await snapshot("03GameViewComplete")
        
      let okButton = app.alerts["Time's Up!"].scrollViews.otherElements.buttons["OK"]
      okButton.tap()
      app.navigationBars["Select Category"]/*@START_MENU_TOKEN@*/.buttons["gearshape"]/*[[".otherElements[\"gearshape\"].buttons[\"gearshape\"]",".buttons[\"gearshape\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        await snapshot("04SettingsView")
    }
}
