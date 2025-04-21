//
//  TabBarController.swift
//  Image Feed
//
//  Created by semrumyantsev on 21.04.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = storyboard.instantiateViewController(identifier: "ProfileViewController")
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
