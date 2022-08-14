//
//  MessageCell.swift
//  Flash Chat iOS13
//
//  Created by Nathan Aleman on 1/31/22.
//  Copyright © 2022 Angela Yu. All rights reserved.
//

import UIKit

// custom message cell displayed when reviewing other features of a certain restroom
// and contains additional comments that other user have made for a certain bathroom
class MessageCell: UITableViewCell {

    @IBOutlet weak var MessageBubble: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        MessageBubble.layer.cornerRadius = MessageBubble.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
