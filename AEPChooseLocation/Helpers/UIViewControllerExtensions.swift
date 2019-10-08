//
//  UIViewControllerExtensions.swift
//  AEPChooseLocation
//
//  Created by Abraham Escamilla Pinelo on 4/18/19.
//  Copyright © 2019 Abraham Escamilla Pinelo. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(_ title: String?, _ message: String? = nil, type : UIAlertController.Style = .alert ,actions: [UIAlertAction] = [UIAlertAction.init(title: "Aceptar", style: .default, handler: nil)]) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: type)
        actions.forEach { (action) in
            alert.addAction(action)
        }
        self.present(alert, animated: true, completion:nil)
    }
}
