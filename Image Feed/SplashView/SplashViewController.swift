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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            switchToTabBarController()
        }
        else {
            performSegue(withIdentifier: authenticationSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        DispatchQueue.main.async {
            guard let window = UIApplication.shared.windows.first else {
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
        if segue.identifier == authenticationSegueIdentifier {guard
            let navigationController = segue.destination as? UINavigationController,
            let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
            assertionFailure("Failed to prepare for \(authenticationSegueIdentifier)")
            return
        }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        DispatchQueue.main.async {
            vc.dismiss(animated: true)
        }
        switchToTabBarController()
    }
}
