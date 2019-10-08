//
//  UIViewExtensions.swift
//  AEPChooseLocation
//
//  Created by Abraham Escamilla Pinelo on 4/18/19.
//  Copyright © 2019 Abraham Escamilla Pinelo. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

extension UIView {
    func roundBordersWith(radius: CGFloat){
        
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = false
        self.clipsToBounds = true
    }
    
    func applyShadow(width: Int = 1, height: Int = 1, color: UIColor = UIColor.lightGray) {
        
        //Adds a shadow to sampleView
        
        layer.shadowOffset = CGSize(width: width, height: height)
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 2
        layer.shadowOpacity = 1
        self.layer.masksToBounds = false
        
        layer.shouldRasterize = true
    }
    
    func showProgressHUD(animated: Bool = true) {
        MBProgressHUD.showAdded(to: self, animated: animated)
    }
    
    func dismissProgressHUD(animated: Bool = true) {
        MBProgressHUD.hide(for: self, animated: animated)
    }
}
