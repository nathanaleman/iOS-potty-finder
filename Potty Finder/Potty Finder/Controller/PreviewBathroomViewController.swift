//
//  PreviewBathroomViewController.swift
//  Potty Finder
//
//  Created by Nathan Aleman on 2/25/22.
//

import UIKit
import Firebase
import FirebaseFirestore

class PreviewBathroomViewController: UIViewController {

    // initialize variables
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var cleanlinessLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var babyLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    var name: String?
    var currentBathroom: Bathroom?
    var allMessages: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // create underline under title
        let attributedString = NSMutableAttributedString.init(string: currentBathroom!.name)
        
        // Add Underline Style Attribute.
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
            NSRange.init(location: 0, length: attributedString.length));
        titleLabel.attributedText = attributedString
        
        // when page is loaded up
        // populate bathroom features from the bathroom that was selected
        // from the previous page
        ratingLabel.text = "⭐️ \(currentBathroom!.rating)/5"
        keyLabel.text = currentBathroom?.key
        if keyLabel.text == "No" {
            keyLabel.text = "❌ No Key Needed"
        } else {
            keyLabel.text = "✅ Key Needed"
        }
        babyLabel.text = currentBathroom?.baby
        if babyLabel.text == "No" {
            babyLabel.text = "❌ No Baby Station"
        } else {
            babyLabel.text = "✅ Baby Station"
        }
        genderLabel.text = currentBathroom?.gender
        if genderLabel.text == "No" {
            genderLabel.text = "❌ No All-Gender Bathroom"
        } else {
            genderLabel.text = "✅ All-Gender Bathroom"
        }
        cleanlinessLabel.text = "⭐️ \(currentBathroom!.cleanliness)/5"
        stockLabel.text = "⭐️ \(currentBathroom!.stock)/5"
        
        // initialize delegates
        tableView.dataSource = self
        tableView.delegate = self
        
        // register custom tabel cell
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
        // get additional comments and display into tabel cell
        getMessages()
        
        // create outlines and attributes for table cells
        tableView.layer.masksToBounds = true
        tableView.layer.borderColor = UIColor( red: 0/255, green: 0/255, blue:0/255, alpha: 1.0 ).cgColor
        tableView.layer.borderWidth = 1.0

    }
    
    // make time and battery on top of phone black
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .default
    }
    
    // get additonal comments from firebase of a certain bathroom
    func getMessages() {
        
        db.collection("bathrooms")
            .addSnapshotListener { querySnapshot, error in

            if let e = error {
                print("There was an issue retrieveing data from Firestore, \(e)")
            } else {
                // retrieve documents from firebase
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let name = data["name"] as? String, let messages = data["additionalComments"] as? [String] {
                            
                            // if current bathroom name equals firebase name
                            if name == self.currentBathroom?.name {
                                
                                // append all messages to array
                                for message in messages {
                                    self.allMessages.append(String(message))
                                }
                                
                                DispatchQueue.main.async {
                                    // listen for any changes
                                    self.tableView.reloadData()
                                }
                                
                            }

                        }
                    }
                }
            }
        }

        
    }
    
    
    // if the add review button is pressed
    @IBAction func addReviewPressed(_ sender: UIButton) {
        
        // if a user is logged in
        if let currentUser = Auth.auth().currentUser?.email {
            
            db.collection("bathrooms")
                .addSnapshotListener { querySnapshot, error in

                if let e = error {
                    print("There was an issue retrieveing data from Firestore, \(e)")
                } else {
                    // retrieve documents from firebase
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments {
                            let data = doc.data()
                            if let name = data["name"] as? String, let emails = data["email"] as? [String] {
                                if name == self.currentBathroom?.name {
                                    for email in emails {
                                        if currentUser == email {
                                            // show alert if user has already rated this restroom
                                            let uialert = UIAlertController(title: "Can't Review Again", message: "This user has already made a review for this restroom", preferredStyle: UIAlertController.Style.alert)
                                            uialert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
                                            self.present(uialert, animated: true, completion: nil)
                                        } else {
                                            // perform segue to review page
                                            self.performSegue(withIdentifier: "previewAddBath", sender: self)
                                        }
                                    }
                                }

                            }
                        }
                    }
                }
            }
        
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // prepare segue by transferring the current bathrooms name
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewAddBath" {
            let destinationVC = segue.destination as! ReviewViewController
            destinationVC.restroomName = name
        }

    }

}


extension PreviewBathroomViewController: UITableViewDataSource {
    
    // rewuired delegate function
    // return message array length
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageCell
        
        // populate cell with messages
        cell.label.text = allMessages[indexPath.row]
        
        return cell
        
    }
    
}

extension PreviewBathroomViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.indexOfBathroom = indexPath.row
//        self.performSegue(withIdentifier: "ViewBathroom", sender: self)
//    }
    
}

