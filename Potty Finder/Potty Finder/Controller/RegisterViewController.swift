//
//  RegisterViewController.swift
//  Potty Finder
//
//  Created by Nathan Aleman on 2/22/22.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    // initialize variables
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    // allow time and battery to be black
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .default
    }
    
    // when register is pressed
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            
            // create a user with login information
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    let error_string = e.localizedDescription
                    if error_string.contains("password") {
//                        print("exists")
                        
                        self.passwordTextfield.text = nil
                        // show alert if invalid password
                        let uialert = UIAlertController(title: "Invalid Password", message: error_string, preferredStyle: UIAlertController.Style.alert)
                        uialert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
                        self.present(uialert, animated: true, completion: nil)
                        
                    } else {
                        
                        // show alert if invalid email
                        let uialert = UIAlertController(title: "Invalid Email", message: error_string, preferredStyle: UIAlertController.Style.alert)
                        uialert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
                        self.present(uialert, animated: true, completion: nil)
                    }
                } else {
                    // Navigate to ChatViewController
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
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

}
