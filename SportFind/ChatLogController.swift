//
//  ChatLogController.swift
//  SportFind
//
//  Created by Erin Baatar on 5/29/17.
//  Copyright © 2017 Erin Baatar. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ChatLogController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var post = Post()
    
    @IBOutlet weak var sendbtn: UIButton!
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var sendmsg: UITextField!
    
    var names : [String] = []
    var messages : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        sendbtn.layer.cornerRadius = 5
        table.backgroundColor = .clear
        table.separatorStyle = UITableViewCellSeparatorStyle.none
        fetchPosts()
        
        self.table.isScrollEnabled = true
    
    }

    @IBAction func send(_ sender: Any) {
        if sendmsg.text != "" {
            let ref = FIRDatabase.database().reference()
            let key = ref.child("posts").child(self.post.postID).child("messages").childByAutoId().key
            
            let message = sendmsg.text
            
            let post = ["author" : self.post.author,
                        "message" : message!] as [String: Any]
            
            let postFeed = ["\(key)" : post]
            ref.child("posts").child(self.post.postID).child("messages").updateChildValues(postFeed)
            sendmsg.text = ""
        } else {
            let alert = UIAlertController(title: "Invalid Message", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(OKAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func fetchPosts(){
        let ref = FIRDatabase.database().reference()
        
        ref.child("posts").child(self.post.postID).child("messages").queryOrderedByKey().observe(.childAdded, with: { (snap) in
            let posts = snap.value as! [String : AnyObject]
            
            if let author = posts["author"] as? String, let message = posts["message"] as? String {
                
                self.messages.append(message)
                self.names.append(author)
                DispatchQueue.main.async {
                    self.table.reloadData()
                    let numberOfSections = self.table.numberOfSections
                    let numberOfRows = self.table.numberOfRows(inSection: numberOfSections-1)
                    
                    let indexPath = IndexPath(row: numberOfRows-1 , section: numberOfSections-1)
                    self.table.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
                }
                
            }
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! ViewControllerTableViewCell
        cell.message.text = messages[indexPath.row]
        cell.name.text = names[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
}
