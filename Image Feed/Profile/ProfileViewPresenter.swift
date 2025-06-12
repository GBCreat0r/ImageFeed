//
//  ProfileViewPresenter.swift
//  Image Feed
//
//  Created by semrumyantsev on 28.05.2025.
//

import Foundation

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    
    func viewDidLoad()
    func didTapLogoutButton()
    func updateProfile()
    func updateAvatar()
    func logout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {

    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol

    init(profileService: ProfileServiceProtocol = ProfileService.shared,
         profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared,
         profileLogoutService: ProfileLogoutServiceProtocol = ProfileLogoutService.shared ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.profileLogoutService = profileLogoutService
    }

    func viewDidLoad() {
        view?.showLoading()
        updateProfile()
        updateAvatar()
    }

    func didTapLogoutButton() {
        view?.showLogoutAlert()
    }

    func updateProfile() {
        guard let token = OAuth2TokenStorage().token else { return }
        profileService.fetchProfile(bearer: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                self.view?.updateProfileDetails(with: profile)
            case .failure(let error):
                print("Error fetching profile: \(error)")
            }
        }
    }

    func updateAvatar() {
        guard let username = profileService.profile?.username else { return }
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let avatarURL):
                self.view?.updateAvatarImage(with: avatarURL)
            case .failure(let error):
                print("Error fetching avatar: \(error)")
            }
        }
    }

    func logout() {
        profileLogoutService.logout()
    }
}
