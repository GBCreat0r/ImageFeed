//
//  ProfileViewController.swift
//  Image Feed
//
//  Created by semrumyantsev on 10.03.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private var logoutButton: UIButton?
    private var nameLabel: UILabel?
    private var nickLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var profilePhoto: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addProfilePhoto()
        addLabels()
        addButton()
        addConstraints()
    }
    
    @objc
    func didTapLogoutButton() {
        let logoutToken = OAuth2TokenStorage()
        logoutToken.token = nil
        performSegue(withIdentifier: "logoutSegue" , sender: nil)
    }
    
    private func addSubviews(anyView: UIView) {
        anyView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(anyView)
        
    }
    
    private func addLabels() {
        let label1 = UILabel()
        let label2 = UILabel()
        let label3 = UILabel()
        
        label1.text = "Allochka le Classic"
        label1.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
        label1.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        
        label2.text = "@AllochkaMaybyRusalochka"
        label2.textColor = #colorLiteral(red: 0.6823529412, green: 0.6862745098, blue: 0.7058823529, alpha: 1)
        label2.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        label3.text = "Label, BlackStar"
        label3.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label3.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label3.numberOfLines = 0
        
        nameLabel = label1
        nickLabel = label2
        descriptionLabel = label3
        
        addSubviews(anyView: label1)
        addSubviews(anyView: label2)
        addSubviews(anyView: label3)
    }
    
    private func addProfilePhoto() {
        let imageView = UIImageView(image: UIImage(named: "Photo"))
        imageView.contentMode = .scaleAspectFit
        profilePhoto = imageView
        addSubviews(anyView: imageView)
    }
    
    private func addButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "Exit"), for: .normal)
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        
        logoutButton = button
        addSubviews(anyView: button)
    }
    
    private func addConstraints() {
        guard let profilePhoto,
              let nameLabel,
              let nickLabel,
              let descriptionLabel,
              let logoutButton
        else { return }
        
        NSLayoutConstraint.activate([
            profilePhoto.widthAnchor.constraint(equalToConstant: 70),
            profilePhoto.heightAnchor.constraint(equalToConstant: 70),
            profilePhoto.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profilePhoto.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: profilePhoto.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profilePhoto.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            nickLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nickLabel.leadingAnchor.constraint(equalTo: profilePhoto.leadingAnchor),
            nickLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: nickLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: profilePhoto.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            logoutButton.centerYAnchor.constraint(equalTo: profilePhoto.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
