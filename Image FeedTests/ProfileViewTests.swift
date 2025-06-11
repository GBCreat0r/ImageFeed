//
//  ProfileViewTests.swift
//  Image FeedTests
//
//  Created by semrumyantsev on 28.05.2025.
//
//

import UIKit
import XCTest
@testable import Image_Feed

class ProfileViewPresenterTests: XCTestCase {
    
    var presenter: ProfileViewPresenter!
    var mockView: MockProfileViewControllerProtocol!
    var mockProfileService: MockProfileService!
    var mockProfileImageService: MockProfileImageService!
    var mockProfileLogoutService: MockProfileLogoutService!
    
    override func setUp() {
        super.setUp()
        mockView = MockProfileViewControllerProtocol()
        mockProfileService = MockProfileService()
        mockProfileImageService = MockProfileImageService()
        mockProfileLogoutService = MockProfileLogoutService()
        
        presenter = ProfileViewPresenter(
            profileService: mockProfileService,
            profileImageService: mockProfileImageService,
            profileLogoutService: mockProfileLogoutService
        )
        presenter.view = mockView
    }
    
    override func tearDown() {
        presenter = nil
        mockView = nil
        mockProfileService = nil
        mockProfileImageService = nil
        mockProfileLogoutService = nil
        super.tearDown()
    }
    
    func testViewDidLoad() {
        presenter.viewDidLoad()
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockProfileService.fetchProfileCalled)
    }
    
    func testDidTapLogoutButton() {
        presenter.didTapLogoutButton()
        XCTAssertTrue(mockView.showLogoutAlertCalled)
    }
    
    func testUpdateProfileSuccess() {
        let profile = Profile(
            username: "testUser",
            firstName: "Иван",
            lastName: "Петров",
            bio: "Тестовое описание"
        )
        mockProfileService.profileResult = .success(profile)
        presenter.updateProfile()
        
        XCTAssertTrue(mockView.updateProfileDetailsCalled)
        XCTAssertEqual(mockView.updatedProfile?.name, "Иван Петров")
        XCTAssertEqual(mockView.updatedProfile?.loginName, "@testUser")
        XCTAssertEqual(mockView.updatedProfile?.bio, "Тестовое описание")
    }
    
    func testUpdateProfileFailure() {
        mockProfileService.profileResult = .failure(NSError(domain: "", code: 404, userInfo: nil))
        presenter.updateProfile()
        
        XCTAssertFalse(mockView.updateProfileDetailsCalled)
    }
    
    func testUpdateAvatarSuccess() {
        let avatarURL = "https://example.com/avatar.jpg"
        let profile = Profile(
            username: "testUser",
            firstName: "Иван",
            lastName: "Петров",
            bio: ""
        )
        mockProfileService.profile = profile
        mockProfileImageService.avatarResult = .success(avatarURL)
        presenter.updateAvatar()
        
        XCTAssertTrue(mockView.updateAvatarImageCalled)
    }
    
    func testUpdateAvatarFailure() {
        let profile = Profile(
            username: "testUser",
            firstName: "Иван",
            lastName: "Петров",
            bio: ""
        )
        mockProfileService.profile = profile
        mockProfileImageService.avatarResult = .failure(NSError(domain: "", code: 404, userInfo: nil))
        presenter.updateAvatar()
        
        XCTAssertFalse(mockView.updateAvatarImageCalled)
    }
    
    func testLogout() {
        presenter.logout()
        XCTAssertTrue(mockProfileLogoutService.logoutCalled)
    }
}

// MARK: - Mock Classes

class MockProfileViewControllerProtocol: ProfileViewControllerProtocol {
    var showLoadingCalled = false
    var updateProfileDetailsCalled = false
    var updateAvatarImageCalled = false
    var showLogoutAlertCalled = false
    var updatedProfile: Profile?
    
    func showLoading() {
        showLoadingCalled = true
    }
    
    func updateProfileDetails(with profile: Profile) {
        updateProfileDetailsCalled = true
        updatedProfile = profile
    }
    
    func updateAvatarImage(with avatarURL: String) {
        updateAvatarImageCalled = true
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}

class MockProfileService: ProfileServiceProtocol {
    var profile: Profile?
    var profileResult: Result<Profile, Error>?
    var fetchProfileCalled = false
    
    func fetchProfile(bearer token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        fetchProfileCalled = true
        if let result = profileResult {
            completion(result)
        }
    }
    
    func clearData() {
        profile = nil
    }
}

class MockProfileImageService: ProfileImageServiceProtocol {
    static var didChangeNotification: Notification.Name = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    var avatarURL: String?
    var avatarResult: Result<String, Error>?
    var fetchProfileImageURLCalled = false
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        fetchProfileImageURLCalled = true
        if let result = avatarResult {
            completion(result)
        }
    }
}

class MockProfileLogoutService: ProfileLogoutServiceProtocol {
    var logoutCalled = false
    
    func logout() {
        logoutCalled = true
    }
}
