//
//  ChallengeTVUITests.swift
//  ChallengeTVUITests
//
//  Created by Mark Volpe on 2019-07-06.
//  Copyright © 2019 Mark Volpe. All rights reserved.
//

import XCTest

class ChallengeTVUITests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app.launchArguments += ["-isTest", "YES"]
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRowDataAndDetailsDataIntegrity(){
        
        let app = XCUIApplication()
        
        // ensure were in portrait
        XCUIDevice.shared.orientation = .portrait
        let collectionViewsQuery = app.collectionViews
        // tap the first row's label
        let thuJul11StaticText = collectionViewsQuery.staticTexts["Thu Jul 11"]
        thuJul11StaticText.tap()
        
        // find our cell in row one...
        let cellsQuery = collectionViewsQuery.cells.collectionViews.cells
        cellsQuery.otherElements.containing(.staticText, identifier:"S2019:E140").element(boundBy: 0).tap()
        
        let label = app.staticTexts["S2019:E140 2019.07.10"]
        let exists = NSPredicate(format: "exists == 1")
        
        // ensure we wait a bit for the details page to open
        expectation(for: exists, evaluatedWith: label, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        let closeButtonButton = app.buttons["close button"]
        closeButtonButton.tap()
        
        // ensure we see row 2
        let friJul12 = collectionViewsQuery.staticTexts["Fri Jul 12"]
        
        // wait a bit for the previous detail page to close
        expectation(for: exists, evaluatedWith: friJul12, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // find our swamp thing cell we know should be on row 2
        let swampThingCell = collectionViewsQuery.collectionViews.staticTexts["S1:E7"]
        // open swamp things detail page
        swampThingCell.tap()
        
        let s1E7BrilliantDisguiseStaticText = app.staticTexts["S1:E7 Brilliant Disguise"]
        
        // wait a bit for the details page to open by waiting on the title to show up
        expectation(for: exists, evaluatedWith: s1E7BrilliantDisguiseStaticText, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // tap the title
        s1E7BrilliantDisguiseStaticText.tap()
        
        // look for the show title
        let swampThingStaticText = app.staticTexts["Swamp Thing"]
        swampThingStaticText.tap()
        
        // look for the start stop time...
        let staticText = app.staticTexts["09:00-10:00 2019-07-12"]
        staticText.tap()
        
        // look for the duration
        let staticText2 = app.staticTexts["60 mins"]
        staticText2.tap()
        
        // ensure we have genres (we know this show has them)
        let dramaActionHorrorStaticText = app.staticTexts["Drama,Action,Horror"]
        dramaActionHorrorStaticText.tap()
        
        // ensure we have the premiered date
        let premiered20190531StaticText = app.staticTexts["Premiered: 2019-05-31"]
        premiered20190531StaticText.tap()
        
        let willPatton = app.staticTexts["Will Patton"]
        expectation(for: exists, evaluatedWith: willPatton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        willPatton.tap()
        
        // make sure we have the summary... we have to do this because the string is longer than 128...
        var queryString = "While Maria meets with the shadowy finance"
        queryString = queryString.replacingOccurrences(of: "\n", with: "?")
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", queryString)
        let swampThingSummary = app.staticTexts.element(matching: predicate)
        XCTAssert(swampThingSummary.exists)
        
        // close this screen
        app.buttons["close button"].tap()
        
        
    }
    
    func testFiltering(){
        // ensure were in portrait
        XCUIDevice.shared.orientation = .portrait
        let collectionViewsQuery = app.collectionViews

        // find our cell in row one...
        let cellsQuery = collectionViewsQuery.cells.collectionViews.cells

        let exists = NSPredicate(format: "exists == 1")
        let doesNotExist = NSPredicate(format: "exists == 0")
        // now perform a filter on swamp
        app.searchFields["Enter show or episode title or network"].tap()
        app.keys["S"].tap()
        app.keys["w"].tap()
        app.keys["a"].tap()
        app.keys["m"].tap()
        app.keys["p"].tap()
        
        // once we have filtered, we should NOT find this show...
        let S2019E140 = cellsQuery.otherElements.containing(.staticText, identifier:"S2019:E140").element
        
        expectation(for: doesNotExist, evaluatedWith: S2019E140, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // find our swamp thing cell...
        collectionViewsQuery.cells.collectionViews.cells.otherElements.containing(.staticText, identifier:"Swamp Thing").element(boundBy: 0).tap()
        
        let s1E7BrilliantDisguiseStaticText = app.staticTexts["S1:E7 Brilliant Disguise"]

        // wait a bit for the details page to open by waiting on the title to show up
        expectation(for: exists, evaluatedWith: s1E7BrilliantDisguiseStaticText, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)

        // tap the title
        s1E7BrilliantDisguiseStaticText.tap()

        // look for the show title
        let swampThingStaticText = app.staticTexts["Swamp Thing"]
        swampThingStaticText.tap()

        // look for the start stop time...
        let staticText = app.staticTexts["09:00-10:00 2019-07-12"]
        staticText.tap()

        // look for the duration
        let staticText2 = app.staticTexts["60 mins"]
        staticText2.tap()

        // ensure we have genres (we know this show has them)
        let dramaActionHorrorStaticText = app.staticTexts["Drama,Action,Horror"]
        dramaActionHorrorStaticText.tap()

        // ensure we have the premiered date
        let premiered20190531StaticText = app.staticTexts["Premiered: 2019-05-31"]
        premiered20190531StaticText.tap()
        
        // make sure we have the summary... we have to do this because the string is longer than 128...
        var queryString = "While Maria meets with the shadowy finance"
        queryString = queryString.replacingOccurrences(of: "\n", with: "?")
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", queryString)
        let swampThingSummary = app.staticTexts.element(matching: predicate)
        XCTAssert(swampThingSummary.exists)
        
        // last but not least... shut down the details screen
        // close this screen
        app.buttons["close button"].tap()
        
        //collectionViewsQuery = app.collectionViews
        //cellsQuery = collectionViewsQuery.cells.collectionViews.cells
        
        // once we have filtered, we should NOT find this show...
        let s1e7 = cellsQuery.otherElements.containing(.staticText, identifier:"S1:E7").element
        
        expectation(for: exists, evaluatedWith: s1e7, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // now filter by network...
        app.searchFields["Enter show or episode title or network"].tap()
        app.keys["delete"].tap()
        app.keys["delete"].tap()
        app.keys["delete"].tap()
        app.keys["delete"].tap()
        app.keys["delete"].tap()
        app.keys["N"].tap()
        app.keys["b"].tap()
        app.keys["c"].tap()
        
        // once we have filtered, we should NOT find this show...
        // we should not find shows from CBS (unless it's in the title - one minor setback to having a bit of a fuzzy search)
        let CBS = cellsQuery.otherElements.containing(.staticText, identifier:"CBS").element
        
        expectation(for: doesNotExist, evaluatedWith: CBS, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        let NBC = cellsQuery.otherElements.containing(.staticText, identifier:"NBC").element
        
        expectation(for: exists, evaluatedWith: NBC, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
