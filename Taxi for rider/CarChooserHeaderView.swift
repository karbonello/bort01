//
//  CarChooserHeaderView.swift
//  Taxi for rider
//
//  Created by Chingis on 28.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit

class CarChooserHeaderView: UIView {
    
    @IBOutlet weak var carClassImageView: UIImageView!
    @IBOutlet weak var carClassName: UILabel!
    @IBOutlet weak var carClassDescription: UILabel!
    
    var card: CarClass! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        carClassImageView.image = card.carImage
        carClassName.text = card.title
        carClassDescription.text = card.description
    }

}
