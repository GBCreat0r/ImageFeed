//
//  SplashViewController.swift
//  Image Feed
//
//  Created by semrumyantsev on 08.04.2025.
//

import UIKit


final class SplashViewController: UIViewController {
    
    private let storage = OAuth2TokenStorage()
    private let authenticationSegueIdentifier = "showAuthenticationScreen"
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = storage.token {
            //switchToTabBarController()
            fetchProfile()
        }
        else {
            performSegue(withIdentifier: authenticationSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
                print("Invalid window configuration")
                assertionFailure("Invalid window configuration")
                return
            }
            let tabBarController = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "TabBarViewController")
            window.rootViewController = tabBarController
        }
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == authenticationSegueIdentifier,
              let navigationController = segue.destination as? UINavigationController,
              let viewController = navigationController.viewControllers.first as? AuthViewController else {
            assertionFailure("Failed to prepare for \(String(describing: segue.identifier))")
            return
        }
        segue.destination.modalPresentationStyle = .fullScreen
        viewController.delegate = self
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        DispatchQueue.main.async {
            vc.dismiss(animated: true)
        }
        fetchProfile()
    }
    
    private func fetchProfile() {
        guard let token = storage.token
        else {print("no token value"); return}
        profileService.fetchProfile(bearer: token) {
            [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else {
                print("Error: self crashed")
                return
            }
            
            switch result {
            case .success(let profile):
                print("успех получения информации профиля")
                fetchProfileImage(username: profile.username)
                self.switchToTabBarController()
            case .failure(let error):
                print("Fail fetch \(error)")
            }
        }
    }
    
    private func fetchProfileImage(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { result in
//            guard let self else {
//                print("photo self crash")
//                return
//            }
            switch result {
            case .success(let url):
                print("\(url)")
            case .failure(let error):
                print("Fail fetch \(error)")
            }
        }
    }
}
