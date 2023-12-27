import XCTest

final class WhatThePhraseUITests: XCTestCase {
    let app = XCUIApplication()
    
    func testTakeScreenshots() async throws {
        await setupSnapshot(app)

        DispatchQueue.main.async {
            self.app.launch()
        }
        await snapshot("01CategoryView")
        
        DispatchQueue.main.async {
            self.app.scrollViews.otherElements.buttons["Places & Spaces"].tap()
            self.app.buttons["Start"].tap()
        }
        await snapshot("02GameView")
        
        DispatchQueue.main.async {
            self.app.buttons["Team 2"].tap()
            let stopButton = self.app.buttons["Stop"]
            stopButton.tap()
        }
        await snapshot("03GameViewComplete")
        
        DispatchQueue.main.async {
            let okButton = self.app.alerts["Time's Up!"].scrollViews.otherElements.buttons["OK"]
            okButton.tap()
            self.app.buttons["Go Back To Categories"].tap()
            self.app.navigationBars["Select Category"].buttons["gearshape"].tap()
        }
        await snapshot("04SettingsView")
    }
}
