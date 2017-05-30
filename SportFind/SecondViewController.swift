//
//  SecondViewController.swift
//  SportFind
//
//  Created by Erin Baatar on 5/6/17.
//  Copyright © 2017 Erin Baatar. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import FirebaseDatabase
import FirebaseStorage


protocol DataSentDelegate {
    func userDidEnterData(data: String)
}


class SecondViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var locationTitle = "Choose Location"
    var location2D = kCLLocationCoordinate2DInvalid
    
    @IBOutlet weak var _sport: UIPickerView!
    @IBOutlet weak var _date: UIDatePicker!
    @IBOutlet weak var _skill: UISegmentedControl!
    @IBOutlet weak var _gender: UISegmentedControl!
    @IBOutlet weak var _location: UIButton!
    @IBOutlet weak var _create: UIButton!

    
    @IBAction func createOffer(_ sender: Any){
        
        if CLLocationCoordinate2DIsValid(location2D) {
            let ref = FIRDatabase.database().reference()
            let uid = FIRAuth.auth()?.currentUser!.uid
            let key = ref.child("posts").childByAutoId().key
            let sport = Array[_sport.selectedRow(inComponent: 0)]
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
            let date = formatter.string(from: _date.date)
            let skill = _skill.titleForSegment(at: _skill.selectedSegmentIndex)
            let gender = _gender.titleForSegment(at: _gender.selectedSegmentIndex)
            let location1D = "\(location2D.latitude),\(location2D.longitude)"
        
            let post = ["author" : FIRAuth.auth()!.currentUser!.displayName!,
                        "sport" : sport,
                        "location" : location1D,
                        "date" : date,
                        "skill" : skill!,
                        "gender" : gender!,
                        "postID" : key,
                        "userID" : uid!,
                        "locationTitle" : locationTitle] as [String: Any]
            
            let postFeed = ["\(key)" : post]
            ref.child("posts").updateChildValues(postFeed)
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
            
            self.present(vc, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Please Select a Location", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(OKAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }

    @IBAction func unwindToMenu(segue: UIStoryboardSegue){
    }

    var Array = ["Football","Basketball","Soccer","Tennis","Golf","Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        _location.layer.borderWidth = 1
        _location.layer.borderColor = UIColor.white.cgColor
        _location.layer.cornerRadius = 5
        _create.layer.borderWidth = 1
        _create.layer.borderColor = UIColor.white.cgColor
        _create.layer.cornerRadius = 5
        _sport.backgroundColor = UIColor.clear
        _date.setValue(UIColor.white, forKeyPath: "textColor")
        _date.setValue(true, forKey: "highlightsToday")
        _sport.selectRow(1, inComponent: 0, animated: true)
        _sport.delegate = self
        _sport.dataSource = self
        _date.minimumDate = Date()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        _location.setTitle(locationTitle, for: .normal)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: Array[row], attributes: [NSForegroundColorAttributeName : UIColor.white])
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Array.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
}

