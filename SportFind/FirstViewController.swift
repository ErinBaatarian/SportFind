//
//  FirstViewController.swift
//  SportFind
//
//  Created by Erin Baatar on 5/6/17.
//  Copyright © 2017 Erin Baatar. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces
import GoogleMaps
import Firebase
import FirebaseDatabase
import FirebaseStorage

class FirstViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    
    var locationManager = CLLocationManager()
    
    var marker = GMSMarker()
    
    var postArray = [Post]()
    
    var realArray = [Post]()
    
    var markers = [GMSMarker]()

    var tappedPost = Post()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        self.tabBarController?.tabBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        initGoogleMaps()
        
        fetchPosts()
        

        
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
    
    func fetchPosts(){
        let ref = FIRDatabase.database().reference()
        
        ref.child("posts").queryOrderedByKey().observe(.childAdded, with: { (snap) in
            let posts = snap.value as! [String : AnyObject]

                if let location = posts["location"] as? String, let date = posts["date"] as? String, let postID = posts["postID"] as? String  {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
                    let dateValue = formatter.date(from: date)
                    let values = location.components(separatedBy: ",")
                    let lat = Double(values[0])
                    let long = Double(values[1])
                    let mylat = Double((self.locationManager.location?.coordinate.latitude)!)
                    let mylong = Double((self.locationManager.location?.coordinate.longitude)!)
                    
                    if (dateValue! < Date()){
                        ref.child("posts").child(postID).removeValue()
                    }
                    if (abs(lat! - mylat) <= 1 && abs(long! - mylong) <= 1 && dateValue! > Date()){
                        let posst = Post()
                        if let author = posts["author"] as? String, let gender = posts["gender"] as? String, let locationTitle = posts["locationTitle"] as? String, let skill = posts["skill"] as? String, let sport = posts["sport"] as? String, let userID = posts["userID"] as? String{
                            
                            posst.author = author
                            posst.date = date
                            posst.gender = gender
                            posst.location = location
                            posst.locationTitle = locationTitle
                            posst.postID = postID
                            posst.skill = skill
                            posst.sport = sport
                            posst.userID = userID
                            
                            
                            self.postArray.append(posst)
                            let values = location.components(separatedBy: ",")
                            let marker = GMSMarker(position: CLLocationCoordinate2DMake(Double(values[0])!, Double(values[1])!))
                            
                            
                            marker.map = self.googleMapsView
                            marker.title = sport
                            marker.snippet = locationTitle
                            
                            if(sport == "Football"){
                                marker.icon = GMSMarker.markerImage(with: .red)
                            }
                            if(sport == "Basketball"){
                                marker.icon = GMSMarker.markerImage(with: .orange)
                            }
                            if(sport == "Soccer"){
                                marker.icon = GMSMarker.markerImage(with: .yellow)
                            }
                            if(sport == "Tennis"){
                                marker.icon = GMSMarker.markerImage(with: .green)
                            }
                            if(sport == "Golf"){
                                marker.icon = GMSMarker.markerImage(with: .blue)
                            }
                            if(sport == "Other"){
                                marker.icon = GMSMarker.markerImage(with: .purple)
                            }
                            self.markers.append(marker)
                        }
                    }
            }
            
        })

    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Error while get location \(error)")
    }
        
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
            
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 10.0)
            
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
        
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let index = markers.index(of: marker) {
            self.tappedPost = postArray[index]
        
            let alert = UIAlertController(title: "Go to Details?", message: tappedPost.locationTitle, preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { (action) in
                self.performSegue(withIdentifier: "details", sender: self)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(OKAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "details"{
            if let DetailsViewController = segue.destination as? DetailsViewController{
                DetailsViewController.post = self.tappedPost
            }
        }
    }
    
}

//extension String {
//    func index(of string: String, options: CompareOptions = .literal) -> Index? {
//        return range(of: string, options: options)?.lowerBound
//    }
//    func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
//        return range(of: string, options: options)?.upperBound
//    }
//    func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
//        var result: [Index] = []
//        var start = startIndex
//        while let range = range(of: string, options: options, range: start..<endIndex) {
//            result.append(range.lowerBound)
//            start = range.upperBound
//        }
//        return result
//    }
//    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
//        var result: [Range<Index>] = []
//        var start = startIndex
//        while let range = range(of: string, options: options, range: start..<endIndex) {
//            result.append(range)
//            start = range.upperBound
//        }
//        return result
//    }
//}
//
//
//
