//
//  LoginViewController.swift
//  Potty Finder
//
//  Created by Nathan Aleman on 2/22/22.
//

import UIKit
import Firebase


class LoginViewController: UIViewController {
    
    // initialize variables
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        self.navigationController!.navigationBar.barStyle = .black
    }
    
    // allow time and battery to be black
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .default
    }
    
    // when login button is pressed
    @IBAction func loginPressed(_ sender: UIButton) {
        
        if let email = emailTextfield.text, let password = passwordTextfield.text {
        
            // create new user into firebase with credentials
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    let error_string = e.localizedDescription
                    if error_string.contains("password") {
//                        print("exists")
//                        let components = error_string.components(separatedBy: "password")
//                        print(components)
                        
                        self.passwordTextfield.text = nil
                        
                        // shwo alert if invalid password
                        let uialert = UIAlertController(title: "Invalid Password", message: error_string, preferredStyle: UIAlertController.Style.alert)
                        uialert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
                        self.present(uialert, animated: true, completion: nil)
                        
                    } else {
                        
                        let replaced = error_string.replacingOccurrences(of: "identifier", with: "email")
                        
                        // show alert if invalid email
                        let uialert = UIAlertController(title: "Invalid Email", message: replaced, preferredStyle: UIAlertController.Style.alert)
                        uialert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
                        self.present(uialert, animated: true, completion: nil)
                    }
                } else {
                    // Navigate to ChatViewController
                    self.performSegue(withIdentifier: K.loginSegue, sender: self)
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
