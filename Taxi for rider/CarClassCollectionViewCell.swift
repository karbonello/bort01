//
//  CarClassCollectionViewCell.swift
//  Taxi for rider
//
//  Created by Chingis on 27.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit

class CarClassCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var carClassImageView: UIImageView!
    
    var card: CarCategory! {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        carClassImageView.image = UIImage(named: card.categoryImage!)
        if card.isChosen {
            carClassImageView.backgroundColor = UIColor.lightGray
        }
    }
}
 
