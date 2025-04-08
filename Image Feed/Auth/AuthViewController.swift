//
//  AuthViewController.swift
//  Image Feed
//
//  Created by semrumyantsev on 25.03.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    let showWebViewSegueIdentifier = "showWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    private func  configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
        vc.dismiss(animated: true)
        OAuth2Service.shared.fetchOAuthToken(code: code) { result in
            switch result {
            case .success(let oauthTokenResponse):
                let token = OAuth2TokenStorage()
                token.token = oauthTokenResponse.accessToken
                self.delegate?.didAuthenticate(self)
                print("Token saved successfully.")
                
            case .failure(let error):
                print("Failed to fetch OAuth token: \(error)")
            }
        }
    }
}
