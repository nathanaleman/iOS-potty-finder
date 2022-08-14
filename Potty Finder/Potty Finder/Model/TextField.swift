//
//  TextField.swift
//  Potty Finder
//
//  Created by Nathan Aleman on 3/28/22.
//

import Foundation
import UIKit

// Allow any TextField to be turned into a UIPickerView
extension UITextField {
    func loadDropdownData(data: [String]) {
        self.inputView = MyPickerView(pickerData: data, dropdownField: self)
    }
    
}
