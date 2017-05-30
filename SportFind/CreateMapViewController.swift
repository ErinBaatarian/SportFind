//
//  CreateMapViewController.swift
//  SportFind
//
//  Created by Erin Baatar on 5/7/17.
//  Copyright © 2017 Erin Baatar. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces
import GoogleMaps



class CreateMapViewController: UIViewController , CLLocationManagerDelegate , GMSAutocompleteViewControllerDelegate , GMSMapViewDelegate {

    @IBOutlet weak var googleMapsView: GMSMapView!

    var locationManager = CLLocationManager()

    var marker = GMSMarker()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        initGoogleMaps()

        
    }
    
    func initGoogleMaps() {
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.googleMapsView.camera = camera
        
        self.googleMapsView.delegate = self
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
        
        
        
    }

    // MARK: CLLocation Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        
        self.googleMapsView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
        
    }

    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.googleMapsView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        self.googleMapsView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
        
    }

    // MARK: GOOGLE AUTO COMPLETE DELEGATE
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15.0)
        self.googleMapsView.camera = camera
        self.marker.title = place.name
        self.marker.map = self.googleMapsView
        self.marker.position = place.coordinate
        self.dismiss(animated: true, completion: nil) // dismiss after select place
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        
        print("ERROR AUTO COMPLETE \(error)")
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }
    
    
    
    @IBAction func openSearchAddress(_ sender: UIBarButtonItem) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        
        let southwest = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)! - 1, (locationManager.location?.coordinate.longitude)! - 1)
        let northeast = CLLocationCoordinate2DMake((locationManager.location?.coordinate.latitude)! + 1, (locationManager.location?.coordinate.longitude)! + 1)
        let bounds = GMSCoordinateBounds(coordinate: southwest, coordinate: northeast)
        autoCompleteController.autocompleteBounds = bounds
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }


    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindToMenu"{
            if let SecondViewController = segue.destination as? SecondViewController{
                SecondViewController.locationTitle = self.marker.title!
                SecondViewController.location2D = self.marker.position
            }
        }
        
    }
    //alert
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        let alert = UIAlertController(title: "Use Location?", message: self.marker.title, preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { (action) in
            self.performSegue(withIdentifier: "unwindToMenu", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
}

    
    
