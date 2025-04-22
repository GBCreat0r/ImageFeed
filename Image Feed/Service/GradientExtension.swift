//
//  GradientExtension.swift
//  Image Feed
//
//  Created by semrumyantsev on 10.03.2025.
//

import UIKit

extension UIImageView {
    func addGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientLayer"
        gradientLayer.colors = [UIColor.clear.cgColor,
                                UIColor(red: 26/255,
                                        green: 27/255,
                                        blue: 34/255,
                                        alpha: 0.6).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: self.bounds.height - 30, width: self.bounds.width, height: 30)
        self.layer.addSublayer(gradientLayer)
    }
    
    func removeGradientLayer() {
        self.layer.sublayers?.filter { $0.name == "gradientLayer" }.forEach { $0.removeFromSuperlayer() }
    }
}

extension UILabel {
    func addGradientToText() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor(red: 255/255,
                                        green: 160/255,
                                        blue: 122/255,
                                        alpha: 1).cgColor,
                                UIColor(red: 255/255,
                                        green: 188/255,
                                        blue: 156/255,
                                        alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.cornerRadius = 5
        
        let textLayer = CATextLayer()
        textLayer.frame = self.bounds
        textLayer.string = self.text
        guard let font else { return }
        textLayer.fontSize = self.font.pointSize
        textLayer.alignmentMode = .center
        textLayer.foregroundColor = UIColor.white.cgColor
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        self.layer.insertSublayer(textLayer, above: gradientLayer)
        self.textColor = .clear
    }
}
