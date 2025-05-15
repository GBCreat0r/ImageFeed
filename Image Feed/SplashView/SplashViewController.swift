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
    private let authViewController = AuthViewController()
    private var imageLogo: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1)
        prepareImageLogo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = storage.token {
            print("Есть ключ авторизации")
            fetchProfile()
        }
        else {
            print("Нет ключа авторизации")
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let viewController = storyboard.instantiateViewController(identifier: "AuthViewController") as? AuthViewController
            guard let authViewController = viewController else { print ("Нет экрана авторизации"); return }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            self.present(authViewController, animated: true)
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
    
    private func prepareImageLogo() {
        guard let imageLogo else { return }
        imageLogo.image = UIImage(resource: .splashScreenLogo)
        NSLayoutConstraint.activate([
            imageLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageLogo.widthAnchor.constraint(equalToConstant: 75),
            imageLogo.heightAnchor.constraint(equalToConstant: 75)
        ])
        view.addSubview(imageLogo)
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
        UIBlockingProgressHUD.show()
        guard let token = storage.token
        else {print("Сервис fetchProfile: no token value"); return}
        profileService.fetchProfile(bearer: token) {
            [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else {
                print("Сервис fetchProfile: Ошибка: self crashed")
                return
            }
            
            switch result {
            case .success(let profile):
                print("Сервис fetchProfile: успех получения информации профиля")
                fetchProfileImage(username: profile.username)
                self.switchToTabBarController()
            case .failure(let error):
                print("Сервис fetchProfile: Fail fetch \(error)")
            }
        }
    }
    
    private func fetchProfileImage(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { result in
            switch result {
            case .success:
                print("Сервис fetchProfileImage: Аватарка получена")
            case .failure(let error):
                print("Сервис fetchProfileImage: Fail fetch \(error)")
            }
        }
    }
}
