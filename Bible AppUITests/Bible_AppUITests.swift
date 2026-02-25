//
//  Bible_AppUITests.swift
//  Bible AppUITests
//
//  Created by Matthias Meister on 07.02.26.
//

import XCTest

final class Bible_AppUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testCanNavigateAcrossAllTabs() throws {
        let tabNames = ["Today", "Discover", "Search", "Favorites", "Settings"]

        for tabName in tabNames {
            let tabButton = app.tabBars.buttons[tabName]
            XCTAssertTrue(tabButton.waitForExistence(timeout: 5), "Missing tab button: \(tabName)")
            tabButton.tap()
            XCTAssertTrue(tabButton.isSelected, "Tab should be selected after tap: \(tabName)")
        }
    }

    @MainActor
    func testSettingsScreenShowsPrimaryControls() throws {
        app.tabBars.buttons["Settings"].tap()

        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Bible Translation"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.segmentedControls.element.waitForExistence(timeout: 5))
        XCTAssertTrue(app.switches["Show Verse Numbers"].waitForExistence(timeout: 5))
    }

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
