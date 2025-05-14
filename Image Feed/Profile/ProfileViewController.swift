//
//  ProfileViewController.swift
//  Image Feed
//
//  Created by semrumyantsev on 10.03.2025.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var logoutButton: UIButton?
    private var nameLabel: UILabel?
    private var nickLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var profilePhoto: UIImageView?
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1058823529, blue: 0.1333333333, alpha: 1)
        addProfilePhoto()
        addLabels()
        addButton()
        addConstraints()
        
        updateProfile()
        updateAvatar()
    }
    
    @objc
    private func didTapLogoutButton() {
        DispatchQueue.main.async{
            let alert = UIAlertController(title: "Пока, пока!",
                                          message: "Уверены что хотите выйти?",
                                          preferredStyle: .alert)
            let actionYes = UIAlertAction(title: "Да",
                                          style: .default) { (action) in
                ProfileLogoutService.shared.logout()
            }
            
            let actionNo = UIAlertAction(title: "Нет", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(actionYes)
            alert.addAction(actionNo)
            
            self.present(alert, animated: true)
        }
    }
    
    private func updateAvatar() {
        self.nameLabel?.addLoadGradientLayer()
        self.nickLabel?.addLoadGradientLayer()
        self.descriptionLabel?.addLoadGradientLayer()
        self.profilePhoto?.addLoadProfileGradientLayer()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let profilePhoto,
            let url = URL(string: profileImageURL)
        else {
            print("Сервис Профиля: Ошибка обновление данных профиля")
            return
        }
        profilePhoto.kf.setImage(with: url,
                                 placeholder:UIImage(resource: .stub),completionHandler: {_ in
            self.nameLabel?.removeLoadGradientLayer()
            self.nickLabel?.removeLoadGradientLayer()
            self.descriptionLabel?.removeLoadGradientLayer()
            self.profilePhoto?.removeLoadGradientLayer()
        })
    }
    
    
    private func updateProfile() {
        guard let profile = profileService.profile,
              let nameLabel,
              let nickLabel,
              let descriptionLabel
        else {
            print("Сервис Профиля: Ошибка обновление данных профиля")
            return
        }
        
        nameLabel.text = profile.name
        nickLabel.text = profile.loginName
        descriptionLabel.text = profile.bio
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
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
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
