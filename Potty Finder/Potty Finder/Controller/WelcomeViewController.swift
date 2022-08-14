//
//  WelcomeViewController.swift
//  Potty Finder
//
//  Created by Nathan Aleman on 2/15/22.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    //  initialize variables
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // make the title text appear like it is being typed out
        // could use typing package but wanted to practice Timer
        titleLabel.text = ""
        var charIndex = 0.0
        let titleText = "🚽Potty Finder"
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { timer in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
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
