//
//  CustomPickerView.swift
//  Potty Finder
//
//  Created by Nathan Aleman on 3/28/22.
//

import Foundation
import UIKit

// Customize UIPickerView to be instered when a textField is chosen
class MyPickerView : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
 
    var pickerData : [String]!
    var pickerTextField : UITextField!
 
    init(pickerData: [String], dropdownField: UITextField) {
        super.init(frame: CGRect.zero)
 
        self.pickerData = pickerData
        self.pickerTextField = dropdownField
 
        self.delegate = self
        self.dataSource = self
        
        
        DispatchQueue.global(qos: .background).async {

            // Background Thread

            DispatchQueue.main.async {
                // Run UI Updates
                if pickerData.count > 0 {
//                    self.pickerTextField.text = self.pickerData[0]
                    self.pickerTextField.isEnabled = true
                } else {
                    self.pickerTextField.text = nil
                    self.pickerTextField.isEnabled = false
                }
            }
        }
        
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
 
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
 
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
 
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerData[row]
    }
 
 
}
