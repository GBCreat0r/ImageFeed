//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by semrumyantsev on 29.05.2025.
//

import XCTest

final class Image_FeedUITests: XCTestCase {
    
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        let app = XCUIApplication()
        // тестируем сценарий авторизации
        let authButton = app.buttons["Войти"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("Cooleriip@mail.ru")
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
        
        UIPasteboard.general.string = "123789asdqwe"
        passwordTextField.press(forDuration: 1.0)
        
        let pasteMenuItem = app.menuItems["Paste"]
        XCTAssertTrue(pasteMenuItem.waitForExistence(timeout: 2))
        pasteMenuItem.tap()
        
        webView.buttons["Login"].tap()
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        sleep(5)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
        app.terminate()
        app.launch()
    }
    
    func testFeed() throws {
        //'nb  2теста у меня не совсем получились из-за ограничений реквестов
        let app = XCUIApplication()
        app.launchArguments.append("--UITests")
        app.launch()
        let tabBar = app.tabBars.element
        XCTAssertTrue(tabBar.waitForExistence(timeout: 10), "TabBar не появился")
        
        let feedTabButton = tabBar.buttons.element(boundBy: 0)
        if !feedTabButton.isSelected {
            feedTabButton.tap()
            sleep(1)
        }
        
        let firstCell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Первая ячейка не появилась")
        
        firstCell.swipeUp()
        
        let cellToLike = app.tables.cells.element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "Вторая ячейка не появилась")
        sleep(2)
        
        let likeButton = cellToLike.buttons["likeButton"]
        likeButton.tap()
        XCTAssertTrue(likeButton.isSelected)
        likeButton.tap()
        XCTAssertFalse(likeButton.isSelected)
        
        sleep(2)
        let image = app.scrollViews.images.element(boundBy: 1)
        image.tap()

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let backButton = app.buttons["singleImageBackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка назад не найдена")
        backButton.tap()
        
    }
    
    func testProfile() throws {
        let app = XCUIApplication()
        sleep(3)
        app.tabBars.buttons.element(boundBy: 1).tap()
       
        XCTAssertTrue(app.staticTexts["1"].exists)
        XCTAssertTrue(app.staticTexts["2"].exists)
        
        app.buttons["logoutButton"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
