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
    private let showWebViewSegueIdentifier = "showWebView"
    weak var delegate: AuthViewControllerDelegate?
    private let token = OAuth2TokenStorage()
    
    @IBOutlet private weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .navBackButton)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1)
    }
    
    @IBAction private func didTapEnterButton(_ sender: Any) {
        let webViewController = WebViewViewController()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewController.delegate = self
        webViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewController
        webViewController.modalPresentationStyle = .fullScreen
        present(webViewController, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else {
                print("Сервис авторизации: Error: AuthViewController deallocated")
                return
            }
            switch result {
            case .success(let oAuthTokenResponse):
                token.token = oAuthTokenResponse.accessToken
                delegate?.didAuthenticate(self)
                print("Сервис авторизации: Token saved successfully.")
                
            case .failure(let error):
                print("Сервис авторизации: Failed to fetch OAuth token: \(error)")
                self.showErrorAlert()
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок",
                                      style: .default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
