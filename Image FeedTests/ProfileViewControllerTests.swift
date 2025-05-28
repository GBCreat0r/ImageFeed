//
//  ProfileViewControllerTests.swift
//  Image FeedTests
//
//  Created by semrumyantsev on 28.05.2025.
//
import UIKit
import XCTest
@testable import Image_Feed

final class ProfileViewControllerTests: XCTestCase {
    
    private var sut: ProfileViewController!
    private var presenterMock: ProfilePresenterMock!
    
    override func setUp() {
        super.setUp()
        sut = ProfileViewController()
        presenterMock = ProfilePresenterMock()
        sut.configure(presenterMock)
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        presenterMock = nil
        super.tearDown()
    }
    
    func testViewDidLoad_CallsPresenter() {
        // Проверяем, что презентер получил вызов viewDidLoad
        XCTAssertTrue(presenterMock.viewDidLoadCalled)
    }
    
    func testUpdateProfileDetails_UpdatesLabels() {
        // Than
        let testProfile = Profile(
            username: "testuser",
            firstName: "Test",
            lastName: "User",
            bio: "Test bio"
        )
        
        // When
        sut.updateProfileDetails(with: testProfile)
        
        // Than
        XCTAssertEqual(sut.getNameLabelText(), "Test User")
        XCTAssertEqual(sut.getNickLabelText(), "@testuser")
        XCTAssertEqual(sut.getDescriptionLabelText(), "Test bio")
    }
    
    func testShowLogoutAlert_CreatesAlertWithCorrectProperties() {
        // Get
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()
        
        // What
        sut.showLogoutAlert()
        
        // Than
        let alert = sut.presentedViewController as? UIAlertController
        XCTAssertNotNil(alert)
        XCTAssertEqual(alert?.title, "Пока, пока!")
        XCTAssertEqual(alert?.message, "Уверены что хотите выйти?")
        XCTAssertEqual(alert?.actions.count, 2)
        XCTAssertEqual(alert?.actions.first?.title, "Да")
        XCTAssertEqual(alert?.actions.last?.title, "Нет")
    }
    
    func testLogoutButtonAction_CallsPresenter() {
        sut.didTapLogoutButton()
        XCTAssertTrue(presenterMock.didTapLogoutButtonCalled)
    }
}

// MARK: - Mock Objects

private final class ProfilePresenterMock: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var didTapLogoutButtonCalled = false
    var updateProfileCalled = false
    var updateAvatarCalled = false
    var logoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
    
    func updateProfile() {
        updateProfileCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func logout() {
        logoutCalled = true
    }
}
