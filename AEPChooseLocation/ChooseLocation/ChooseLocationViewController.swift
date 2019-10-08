//
//  ChooseLocationViewController.swift
//  AEPChooseLocation
//
//  Created by Abraham Escamilla Pinelo on 4/18/19.
//  Copyright © 2019 Abraham Escamilla Pinelo. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


protocol ChooseLocationViewControllerDelegate: class {
    func didChooseLocation(_ location: CLLocationCoordinate2D, addressText: String?)
    func didCancel()
}

class ChooseLocationViewController: UIViewController, CLLocationManagerDelegate, GMSAutocompleteTableDataSourceDelegate, UITextFieldDelegate, GMSMapViewDelegate
{
    //MARK: - GUI
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var shadowView: UIView!
    
    @IBOutlet weak var topContentView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var centralPinImageView: UIImageView!
    @IBOutlet weak var okButton: UIButton!
    var cancelBarButton: UIBarButtonItem!
    
    //MARK: - Variables
    
    var autocompleteDataSource: GMSAutocompleteTableDataSource!
    var locationManager: CLLocationManager!
    var didFindMyLocation: Bool = false
    let actionRangeSegue = "toActionRangeSegue"
    
    weak var delegate: ChooseLocationViewControllerDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.mapView.camera = GMSCameraPosition.camera(withTarget: CLLocationCoordinate2D.init(latitude: 20.966536, longitude:  -89.623927), zoom: 12)
    }
    
    //MARK: - Helper
    
    private func setup() {
        
        self.title = "Agrega una dirección"
        
        self.setupTableView()
        self.setupTextField()
        self.setupLocationManager()
        self.setupOkButton()
        self.setupTopContentView()
        self.setupCancelBarButton()
        
        self.mapView.delegate = self
        self.topContentView.roundBordersWith(radius: 12)
    }
    
    private func setupCancelBarButton() {
        self.cancelBarButton = UIBarButtonItem(title: "Cancelar", style: .done, target: self, action: #selector(cancelBarButtonAction))
        self.navigationItem.leftBarButtonItem = self.cancelBarButton
    }
    
    private func setupTopContentView() {
        self.topContentView.backgroundColor = UIColor.white
        DispatchQueue.main.async {
            self.topContentView.roundBordersWith(radius: 15)
            self.shadowView.roundBordersWith(radius: 15)
            self.shadowView.applyShadow()
        }
    }
    
    private func setupOkButton() {
        self.okButton.setTitle("Continuar", for: .normal)
        self.okButton.backgroundColor = UIColor.red
        self.okButton.setTitleColor(UIColor.white, for: .normal)
        DispatchQueue.main.async {
            self.okButton.roundBordersWith(radius: 15)
        }
    }
    
    private func setupLocationManager() {
        self.view.showProgressHUD()
        self.locationManager = CLLocationManager()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
    }
    
    private func setupTableView() {
        self.setupAutoCompleteDataSource()
        self.tableView.delegate = self.autocompleteDataSource
        self.tableView.dataSource = self.autocompleteDataSource
        self.tableView.roundBordersWith(radius: 12)
        self.tableView.isHidden = true
        self.tableView.alpha = 0
    }
    
    private func setupTextField() {
        self.searchTextField.delegate = self
        self.searchTextField.addTarget(self, action: #selector(didChangeText(_:)), for: .editingChanged)
    }
    
    private func setupAutoCompleteDataSource() {
        self.autocompleteDataSource = GMSAutocompleteTableDataSource()
        self.autocompleteDataSource.delegate = self
        self.autocompleteDataSource.tableCellBackgroundColor = UIColor.white
        self.autocompleteDataSource.autocompleteBounds = GMSCoordinateBounds(
            coordinate: CLLocationCoordinate2D.init(latitude: CLLocationDegrees.init(21.299045), longitude: CLLocationDegrees.init(-89.832815)),
            coordinate: CLLocationCoordinate2D.init(latitude: CLLocationDegrees.init(20.806132), longitude: CLLocationDegrees.init(-89.450136)))
        
        let filter = GMSAutocompleteFilter()
        filter.country = "MX"
        
        self.autocompleteDataSource.autocompleteFilter = filter
        
        
    }
    
    private func showTableView() {
        self.tableView.isHidden = true
        UIView.animate(withDuration: 0.3) {
            self.tableView.isHidden = false
            self.tableView.alpha = 1
        }
    }
    
    private func dismissTableView() {
        self.tableView.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.tableView.alpha = 0
        }) { (finished) in
            self.tableView.isHidden = true
        }
    }
    
    //MARK: - GMSAutocomplete Datasource Delegate
    
    var didAutoComplete = false
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        
        self.dismissTableView()
        self.view.endEditing(true)
        self.didAutoComplete = true
        self.mapView.animate(with: GMSCameraUpdate.setTarget(place.coordinate, zoom: 16))
        self.searchTextField.text = place.formattedAddress
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error)
    {
        print("Error Google Search Data Source \(error.localizedDescription)")
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        
    }
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        
        self.tableView.reloadData()
    }
    
    //MARK: - MapView Delegate
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if !didAutoComplete {
            let currentLocation = self.mapView.camera.target
            let geocoder = GMSGeocoder()
            
            self.view.showProgressHUD()
            geocoder.reverseGeocodeCoordinate(currentLocation) { (response, error) in
                
                self.view.dismissProgressHUD()
                if error == nil {
                    //Sin errores
                    guard let address = response?.firstResult() else {
                        
                        return
                    }
                    let addressText = "\(address.thoroughfare ?? "") \(address.subLocality ?? "")"
                    self.searchTextField.text = addressText
                    
                }else{
                    //Errores
                    
                }
            }
            
        }
        
        self.didAutoComplete = false
    }
    
    //MARK: - TextField Delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.tableView.isHidden {
            self.showTableView()
            self.centralPinImageView.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if !self.tableView.isHidden {
            self.dismissTableView()
            self.centralPinImageView.isHidden = false
        }
    }
    
    //MARK: - Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .denied || status == CLAuthorizationStatus.restricted || status == .notDetermined {
            
            let okAction = UIAlertAction(title: "Aceptar", style: .default) { [weak self] (_) in
                guard let self = self else {return}
                self.dismiss(animated: true, completion: nil)
            }
            self.showAlert("Permiso de ubicación denegado", "Para usar la app por favor activa el permiso de ubicación", type: .alert, actions: [okAction])
            
            return
        }
        
        if status == .authorizedWhenInUse {
            self.locationManager.requestLocation()
            self.mapView.isMyLocationEnabled = true
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.view.dismissProgressHUD()
        guard let currentLocation = locations.last else {
            
            let okAction = UIAlertAction(title: "Aceptar", style: .default) { [weak self] (_) in
                guard let self = self else {return}
                self.dismiss(animated: true, completion: nil)
            }
            self.showAlert("No fue posible obtener tu ubicación actual", nil, type: .alert, actions: [okAction])
            
            
            return
        }
        if !didFindMyLocation {
            self.mapView.camera = GMSCameraPosition.camera(withTarget: currentLocation.coordinate, zoom: 12)
            self.didFindMyLocation = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager DidFailWithError: " + error.localizedDescription)
    }
    
    //MARK: - Actions
    
    @IBAction func didChangeText(_ textfield: UITextField) {
        if self.tableView.isHidden {
            self.showTableView()
        }
        self.autocompleteDataSource.sourceTextHasChanged(textfield.text!)
    }
    
    @IBAction func okButtonAction(_ sender: UIButton)
    {
        self.delegate?.didChooseLocation(self.mapView.camera.target, addressText: self.searchTextField.text)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBarButtonAction() {
        self.delegate?.didCancel()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Prepare For segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
