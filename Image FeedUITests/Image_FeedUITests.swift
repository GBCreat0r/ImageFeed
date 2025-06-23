//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by semrumyantsev on 29.05.2025.
//

import XCTest

final class Image_FeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["disablePagination"]
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
        loginTextField.typeText("MAIL")
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
        
        UIPasteboard.general.string = "Pass"
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
        let tablesQuery = app.tables
        let firstCell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        cell.swipeUp()
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 2)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5))
        
        sleep(2)
        
        cellToLike.buttons.firstMatch.tap()
        
        sleep(2)
        
        cellToLike.buttons.firstMatch.tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1) // zoom in
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()
        sleep(2)
    }
    
    func testProfile() throws {
        sleep(3)
        
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Получаем лейблы
        let nameLabel = app.staticTexts["nameLabel"]
        let usernameLabel = app.staticTexts["nickLabel"]
        
        // Проверяем, что они существуют и содержат текст
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5))
        print(nameLabel)
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 5))
        print(usernameLabel)
        
        app.buttons.element(boundBy: 2).tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        let authButton = app.buttons["Войти"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
}
