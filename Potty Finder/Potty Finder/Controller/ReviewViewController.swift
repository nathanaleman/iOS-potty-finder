//
//  ReviewViewController.swift
//  Potty Finder
//
//  Created by Nathan Aleman on 2/24/22.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseFirestore


class ReviewViewController: UIViewController {
    
    // initialize variables
    @IBOutlet weak var addReviewButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var cleanlinessTextField: UITextField!
    @IBOutlet weak var allGenderTextField: UITextField!
    @IBOutlet weak var overallRatingTextField: UITextField!
    @IBOutlet weak var stockLevelsTextField: UITextField!
    @IBOutlet weak var babyChangingTextField: UITextField!
    @IBOutlet weak var additionalCommentsTextView: UITextView!
    @IBOutlet weak var addReviewLabel: UILabel!
    
    var restroomName: String?
    var pinLatitude: CLLocationDegrees?
    var pinLongitude: CLLocationDegrees?
    
    // custom PickerView options
    let ratingPickerViewOptions = ["1", "2", "3", "4", "5"]
    let keyPickerViewOptions = ["Yes", "No"]
    
    // initialze Firebase
    let db = Firestore.firestore()
    


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // delegate initialization
        nameTextField.delegate = self
        cleanlinessTextField.delegate = self
        keyTextField.delegate = self
        allGenderTextField.delegate = self
        overallRatingTextField.delegate = self
        stockLevelsTextField.delegate = self
        babyChangingTextField.delegate = self
        additionalCommentsTextView.delegate = self
        
        // add review button is grayed out until form is complete
        addReviewButton.isEnabled = false
        nameTextField.text = restroomName
        additionalCommentsTextView.insertTextPlaceholder(with: CGSize.init(width: 5.0, height: 5.0))
        
        // if user is coming from preview page and not the map view page
        // name label will be populated
        if let rest = restroomName{
            if !rest.isEmpty {
                addReviewLabel.text = restroomName! + " Review"
            }
            nameTextField.isUserInteractionEnabled = false
            
        }
        
        // if user taps anywhere on screen when keyboard is present
        // the keyboard will disappear
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        
//        let pickerView = UIPickerView()
//        pickerView.delegate = self
//
//        ratingTextField.inputView = pickerView
        
        // load custom picker views for text fields
        cleanlinessTextField.loadDropdownData(data: ratingPickerViewOptions)
        keyTextField.loadDropdownData(data: keyPickerViewOptions)
        allGenderTextField.loadDropdownData(data: keyPickerViewOptions)
        overallRatingTextField.loadDropdownData(data: ratingPickerViewOptions)
        stockLevelsTextField.loadDropdownData(data: ratingPickerViewOptions)
        babyChangingTextField.loadDropdownData(data: keyPickerViewOptions)
        
        additionalCommentsTextView.text = "(e.g. bathroom passcode, wait times, # of stalls)"
        additionalCommentsTextView.textColor = UIColor.lightGray
        
        
    }
  
    
    
    
    
    
    
    // allow battery and time on top to be black
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .default
    }
    
    // testing some form fill out requirements
    @IBAction func nameTextFieldReturn(_ sender: UITextField) {
        
//        let str = sender.text!
//        
//        if str.isEmpty {
//            addReviewButton.isEnabled = false
//        } else {
//            addReviewButton.isEnabled = true
//        }
        

    }
    
    // if last text field is filled out
    @IBAction func overallRatingTextFieldReturn(_ sender: UITextField) {
        
        let str = sender.text!
        
        // enable the add review button is not empty
        if str.isEmpty {
            addReviewButton.isEnabled = false
        } else {
            addReviewButton.isEnabled = true
        }
        
    }
    
    // if add review is pressed
    @IBAction func addReviewPressed(_ sender: UIButton) {
        
        // there is a name for the restroom
        // if user is coming from preview page and adding a review to an already reviewd bathroom
        if let nameOfRestroom = restroomName {
            
            // if a user is logged in
            if let currentUser = Auth.auth().currentUser?.email {
                
                // retrieve document from firebase
                let bathroomRef = db.collection("bathrooms").document(nameOfRestroom)
                
                
                db.collection("bathrooms")
                    .addSnapshotListener { querySnapshot, error in

                    if let e = error {
                        print("There was an issue retrieveing data from Firestore, \(e)")
                    } else {
                        
                        // update firebase bathroom with added reviews
                        bathroomRef.updateData([
                            "overallRating": FieldValue.arrayUnion([self.overallRatingTextField.text!])
                        ])
                        
                        bathroomRef.updateData([
                            "cleanliness":FieldValue.arrayUnion([self.cleanlinessTextField.text!])
                        ])
                        
                        bathroomRef.updateData([
                            "stockLevels":FieldValue.arrayUnion([self.stockLevelsTextField.text!])
                        ])
                        
                        // retriev documents from firebase
                        if let snapshotDocuments = querySnapshot?.documents {
                            for doc in snapshotDocuments {
                                let data = doc.data()
                                if let name = data["name"] as? String, let rating = data["overallRating"] as? [String], let cleanliness = data["cleanliness"] as? [String], let stocks = data["stockLevels"] as? [String] {
                                    // if document is equal to current restroom
                                    if name == self.restroomName {
                                        
                                        // get average rating
                                        let intRating = rating.compactMap { Double(String($0)) }
                                        var totalRating = 0.0
                                        for rate in intRating {
                                            totalRating += rate
                                        }
                                        totalRating /= Double(intRating.count)
                                        let strTotalRating = String(format: "%.1f", totalRating)
                                        
                                        // get average cleanliness
                                        let intCleanliness = cleanliness.compactMap { Double(String($0)) }
                                        var totalCleanliness = 0.0
                                        for clean in intCleanliness {
                                            totalCleanliness += clean
                                        }
                                        totalCleanliness /= Double(intCleanliness.count)
                                        let strTotalCleanliness = String(format: "%.1f", totalCleanliness)
                                        
                                        // get average stock
                                        let intStock = stocks.compactMap { Double(String($0)) }
                                        var totalStock = 0.0
                                        for stock in intStock {
                                            totalStock += stock
                                        }
                                        totalStock /= Double(intStock.count)
                                        let strTotalStock = String(format: "%.1f", totalStock)
                                        
                                        
                                        // update firebase bathroom with new averages of reviews
                                        bathroomRef.updateData([
                                            "averageRating": strTotalRating
                                        ])
                                        
                                        bathroomRef.updateData([
                                            "averageCleanliness": strTotalCleanliness
                                        ])
                                        
                                        bathroomRef.updateData([
                                            "averageStockLevels": strTotalStock
                                        ])
                                        
                                        bathroomRef.updateData([
                                            "email": FieldValue.arrayUnion([currentUser])
                                        ])
                                        bathroomRef.updateData([
                                            "additionalComments": FieldValue.arrayUnion([self.additionalCommentsTextView.text!])
                                        ])
                                        
                                    }

                                }
                            }
                        }
                    }
                }
            }

            
            self.dismiss(animated: true, completion: nil)
        } else {
            // if user is making a new bathroom
            if let currentUser = Auth.auth().currentUser?.email {
                db.collection("bathrooms").document(nameTextField.text!).setData([
                    // add reviews, ratings, name and all that
                    // check if pin already here and if user already reviewed
                    "longitude":pinLongitude!,
                    "latitude":pinLatitude!,
                    "email":[currentUser],
                    "name":nameTextField.text!,
                    "cleanliness":[cleanlinessTextField.text!],
                    "averageCleanliness":cleanlinessTextField.text!,
                    "keyEntry":[keyTextField.text!],
                    "allGender":[allGenderTextField.text!],
                    "babyStation":[babyChangingTextField.text!],
                    "stockLevels":[stockLevelsTextField.text!],
                    "averageStockLevels":stockLevelsTextField.text!,
                    "overallRating":[overallRatingTextField.text!],
                    "additionalComments":[additionalCommentsTextView.text!],
                    "averageRating":overallRatingTextField.text!,
                    K.FStore.dateField:Date().timeIntervalSince1970]) { error in
                    if let e = error {
                        print("There was an issue saving data to the Firestore, \(e)")
                    } else {
                        print("Successfully Saved Data.")
                    }
                }
            }
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}

extension ReviewViewController: UITextViewDelegate {
    
    // allow the text in the additional comments section be grayed out
    // act like a placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {

        if textView.text == "(e.g. bathroom passcode, wait times, # of stalls)"{
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
    }
    
    // allow the text in the additional comments section be grayed out
    // act like a placeholder
    func textViewDidEndEditing(_ textView: UITextView) {
 
        if textView.text.isEmpty {
            textView.text = "(e.g. bathroom passcode, wait times, # of stalls)"
            textView.textColor = UIColor.lightGray
        }
    }
    
}

extension ReviewViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

/*
extension ReviewViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
 
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return salutations.count
    }
 
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return salutations[row]
    }
 
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ratingTextField.text = salutations[row]
    }
    
}
*/
