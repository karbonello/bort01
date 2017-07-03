//
//  CarChooserViewController.swift
//  Taxi for rider
//
//  Created by Chingis on 27.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit

class CarChooserViewController: UIViewController {
    
    var itemIndex = 0
    var imageName: String = "" {
        didSet {
            if let imageView = carClassImageView {
                imageView.image = UIImage(named: imageName)
            }
        }
    }
    var categoryName: String = "" {
        didSet {
            if let categoryNameLabel = carClassName {
                categoryNameLabel.text = categoryName
            }
        }
    }
    var categoryPrice: Int = 0 {
        didSet {
            if let categoryPriceLabel = carClassPrice {
                categoryPriceLabel.text = String(categoryPrice) + "₽/час"
            }
        }
    }
    var categoryCarModel: String = "" {
        didSet {
            if let categoryCarModelLabel = carClassModel {
                categoryCarModelLabel.text = categoryCarModel
            }
        }
    }
    
    @IBOutlet weak var carClassImageView: UIImageView!
    @IBOutlet weak var carClassName: UILabel!
    @IBOutlet weak var carClassModel: UILabel!
    @IBOutlet weak var carClassPrice: UILabel!
    @IBOutlet weak var carClassView: UIView!
    
    @IBAction func closeBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var card: CarCategory! = CarCategory.createCarCategory()[0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carClassView.layer.cornerRadius = 10
        carClassView.layer.borderWidth = 1
        carClassView.layer.borderColor = UIColor.white.cgColor
        carClassView.clipsToBounds = true
        carClassImageView.image = UIImage(named: imageName)
        carClassName.text = categoryName
        carClassModel.text = categoryCarModel
        carClassPrice.text = String(categoryPrice) + "₽/час"
    }    
}
