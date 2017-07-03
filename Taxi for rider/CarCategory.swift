//
//  CarClasses.swift
//  Taxi for rider
//
//  Created by Chingis on 27.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//
// Описание ячейки выбора класса автомобиля

import UIKit

class CarCategory {
    var categoryName: String!
    var categoryCarName: String!
    var categoryPrice: Int!
    var categoryImage: String!
    var isChosen: Bool!
    
    init(name: String, carName: String, price: Int, image: String, isChosen: Bool) {
        self.categoryName = name
        self.categoryCarName = carName
        self.categoryPrice = price
        self.categoryImage = image
        self.isChosen = false
    }
    
    static func createCarCategory() -> [CarCategory] {
        return [
            CarCategory(name: "Бизнес", carName: "Audi A6", price: 900, image: "carIcon1", isChosen: false),
            CarCategory(name: "Бизнес+", carName: "Mercedes W213", price: 1000, image: "carIcon0", isChosen: true),
            CarCategory(name: "Спорт", carName: "Ford Mustang", price: 1900, image: "carIcon2", isChosen: false),
            CarCategory(name: "VIP", carName: "Mercedes Maybach", price: 2000, image: "carIcon3", isChosen: false)
        ]
    }
}
