//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by semrumyantsev on 29.05.2025.
//

import XCTest

final class Image_FeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    func testAuth() throws {
        let authButton = app.buttons["Войти"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 15))
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        loginTextField.tap()
        loginTextField.typeText("mAIL")
        if app.keyboards.element.exists {
            let returnKey = app.keyboards.buttons["Return"]
            if returnKey.exists {
                returnKey.tap()
            } else {
                // Альтернатива для разных типов клавиатур
                app.toolbars.buttons["Done"].tap()
            }
        }
        sleep(1)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        
        UIPasteboard.general.string = "pass"
        passwordTextField.press(forDuration: 1.0)
        
        let pasteMenuItem = app.menuItems["Paste"]
        XCTAssertTrue(pasteMenuItem.waitForExistence(timeout: 2))
        pasteMenuItem.tap()
        
        webView.buttons["Login"].tap()
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        sleep(5)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        // Перед началом теста печатаем иерархию элементов для отладки
        print("Иерархия элементов перед началом теста:")
        print(app.debugDescription)
        
        
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like button off"].tap()
        cellToLike.buttons["like button on"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        XCTAssertTrue(app.staticTexts["1"].exists)
        XCTAssertTrue(app.staticTexts["2"].exists)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
