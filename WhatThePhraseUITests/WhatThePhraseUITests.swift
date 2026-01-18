import XCTest

@MainActor
final class WhatThePhraseUITests: XCTestCase {
    let app = XCUIApplication()
    
    private func ensureToggle(_ toggle: XCUIElement, isOn: Bool) {
        guard toggle.exists else { return }
        let rawValue = (toggle.value as? String) ?? ""
        let isCurrentlyOn = rawValue == "1" || rawValue.lowercased() == "on"
        if isCurrentlyOn != isOn {
            toggle.tap()
        }
    }
    
    func testTakeScreenshots() async throws {
        setupSnapshot(app)

        // Force light mode for screenshots
        app.launchArguments.append("-UIUserInterfaceStyle")
        app.launchArguments.append("Light")
        
        app.launch()
        
        // Wait for app to launch and initial view to appear
        let categoryView = app.staticTexts["Select Category"]
        XCTAssertTrue(categoryView.waitForExistence(timeout: 5))
        
        // 01: Category View (default)
        snapshot("01CategoryView")
        
        // 02: Info Page View
        let infoButton = app.buttons["infoButton"]
        XCTAssertTrue(infoButton.waitForExistence(timeout: 5))
        infoButton.tap()
        
        // Wait for info sheet to appear
        let infoNavBar = app.navigationBars["How To Play"]
        XCTAssertTrue(infoNavBar.waitForExistence(timeout: 5))
        snapshot("02InfoView")
        
        // Dismiss info
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()
        
        // Wait for info sheet to dismiss
        XCTAssertTrue(categoryView.waitForExistence(timeout: 5))
        
        // Open settings
        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()
        
        // Wait for settings sheet to appear
        let settingsNavBar = app.navigationBars["Options"]
        XCTAssertTrue(settingsNavBar.waitForExistence(timeout: 5))
        
        let kidsToggle = app.switches["kidsModeToggle"]
        XCTAssertTrue(kidsToggle.waitForExistence(timeout: 5))
        ensureToggle(kidsToggle, isOn: false)

        let settingsTeamsToggle = app.switches["playAsTeamsToggle"]
        XCTAssertTrue(settingsTeamsToggle.waitForExistence(timeout: 5))
        ensureToggle(settingsTeamsToggle, isOn: true)

        try await Task.sleep(nanoseconds: 300_000_000)

        // 03: Settings View
        snapshot("03SettingsView")
        
        // Dismiss settings
        let settingsDoneButton = app.buttons["Done"]
        XCTAssertTrue(settingsDoneButton.waitForExistence(timeout: 5))
        settingsDoneButton.tap()
        
        // Wait for settings to dismiss
        XCTAssertTrue(categoryView.waitForExistence(timeout: 5))
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Start a game with teams enabled (default)
        let placesCategory = app.scrollViews.otherElements.buttons["Places & Spaces"]
        XCTAssertTrue(placesCategory.waitForExistence(timeout: 5))
        placesCategory.tap()
        
        let startButton = app.buttons["Start"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()
        
        // Wait for game to start - look for the game view elements
        let team1Button = app.buttons["Team 1"]
        XCTAssertTrue(team1Button.waitForExistence(timeout: 5))
        try await Task.sleep(nanoseconds: 1_000_000_000) // Wait for word to load
        
        // 04: Teams Game Mode View
        snapshot("04TeamsGameView")
        
        // Go back to categories
        let backButton = app.buttons["Go Back To Categories"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
        
        XCTAssertTrue(categoryView.waitForExistence(timeout: 5))
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Disable teams mode
        settingsButton.tap()
        XCTAssertTrue(settingsNavBar.waitForExistence(timeout: 5))
        
        let teamsToggle = app.switches["playAsTeamsToggle"]
        XCTAssertTrue(teamsToggle.waitForExistence(timeout: 5))
        ensureToggle(teamsToggle, isOn: false)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let settingsDoneButton3 = app.buttons["Done"]
        XCTAssertTrue(settingsDoneButton3.waitForExistence(timeout: 5))
        settingsDoneButton3.tap()
        
        XCTAssertTrue(categoryView.waitForExistence(timeout: 5))
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Start a game without teams
        placesCategory.tap()
        XCTAssertTrue(startButton.waitForExistence(timeout: 5))
        startButton.tap()
        
        // Wait for game to start - look for the Correct button (non-team mode)
        let correctButton = app.buttons["Correct"]
        XCTAssertTrue(correctButton.waitForExistence(timeout: 5))
        try await Task.sleep(nanoseconds: 1_000_000_000) // Wait for word to load
        
        // Complete the game flow for the final screenshot
        // Note: In non-team mode, there's no "Team 2" button, so we'll just stop the game
        let stopButton = app.buttons["Stop"]
        XCTAssertTrue(stopButton.waitForExistence(timeout: 5))
        stopButton.tap()
        
        try await Task.sleep(nanoseconds: 500_000_000)
        // 05: Time's Up Alert
        snapshot("05TimesUp")
        
        // Dismiss alert and finish
        let okButton = app.alerts["Time's Up!"].scrollViews.otherElements.buttons["OK"]
        XCTAssertTrue(okButton.waitForExistence(timeout: 5))
        okButton.tap()
    }
}
