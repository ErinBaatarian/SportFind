//
//  ThirdViewController.swift
//  SportFind
//
//  Created by Erin Baatar on 5/7/17.
//  Copyright © 2017 Erin Baatar. All rights reserved.
//

import UIKit
import FirebaseAuth

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var bar: UINavigationBar!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)

        bar.tintColor = UIColor.white

        name.text = FIRAuth.auth()?.currentUser?.displayName!
        email.text = FIRAuth.auth()?.currentUser?.email!
    }


    @IBAction func signout(_ sender: Any) {
        
        let alert = UIAlertController(title: "Logout?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { (action) in
            if FIRAuth.auth()?.currentUser != nil{
                do{
                    try? FIRAuth.auth()?.signOut()
                    
                    if FIRAuth.auth()?.currentUser == nil{
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "login")
                        
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)

        

    }


}
