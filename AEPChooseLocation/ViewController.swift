//
//  ViewController.swift
//  AEPChooseLocation
//
//  Created by Abraham Escamilla Pinelo on 4/18/19.
//  Copyright © 2019 Abraham Escamilla Pinelo. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var chooseLocationButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func chooseLocationButtonAction(_ sender: UIButton) {
        let chooseLocationSB = UIStoryboard(name: "ChooseLocationStoryboard", bundle: nil)
        let chooseLocationVC = chooseLocationSB.instantiateViewController(withIdentifier: "ChooseLocationNavigationViewController") as! UINavigationController
        let vc = chooseLocationVC.topViewController as! ChooseLocationViewController
        vc.delegate = self
        self.present(chooseLocationVC, animated: true, completion: nil)
        
    }
}

extension ViewController: ChooseLocationViewControllerDelegate {
    func didChooseLocation(_ location: CLLocationCoordinate2D, addressText: String?) {
        self.addressLabel.text = "Coordinates: Latitude \(location.latitude), Longitude \(location.longitude). Address: \(addressText ?? "")"
    }
    
    func didCancel() {
        self.addressLabel.text = "Canceled"
    }
    
    
}

