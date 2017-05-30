//
//  DetailsViewController.swift
//  SportFind
//
//  Created by Erin Baatar on 5/22/17.
//  Copyright © 2017 Erin Baatar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class DetailsViewController: UIViewController {

    var post = Post()
    
    @IBOutlet weak var sport: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var skill: UILabel!
    @IBOutlet weak var gender: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var deleteout: UIBarButtonItem!

    @IBOutlet weak var groupchat: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        
        groupchat.layer.borderWidth = 1
        groupchat.layer.borderColor = UIColor.white.cgColor
        groupchat.layer.cornerRadius = 5
        
        sport.text = post.sport
        skill.text = post.skill
        location.text = post.locationTitle
        author.text = "Posted By \(post.author!)"
        date.text = post.date
        
        if post.gender == "Men" || post.gender == "Women" {
            gender.text = "\(post.gender!) Only"
        } else {
            gender.text = "Men and Women"
        }
        
        if post.userID! == FIRAuth.auth()?.currentUser?.uid{
            deleteout.isEnabled = true
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func deletebtn(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure you want to delete this post?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let OKAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default) { (action) in
            FIRDatabase.database().reference().child("posts").child(self.post.postID!).removeValue()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersVC")
            self.present(vc, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chat"{
            if let ChatLogController = segue.destination as? ChatLogController{
                ChatLogController.post = self.post
            }
        }

    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
