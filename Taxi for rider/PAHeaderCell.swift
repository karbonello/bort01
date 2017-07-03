//
//  PAHeaderCell.swift
//  Taxi for rider
//
//  Created by Chingis on 01.07.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit

class PAHeaderCell: UITableViewCell {
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    private let editUserDataSegue = "EditUserData"
    

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.clipsToBounds = true
        avatarImageView.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
