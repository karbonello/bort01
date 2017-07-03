//
//  RiderVCCarPickerExtention.swift
//  Taxi for rider
//
//  Created by Chingis on 27.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit


extension RiderVC: UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return carClasses.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarCell", for: indexPath) as! CarClassCollectionViewCell
        cell.card = self.carClasses[indexPath.item]
        return cell
    }
}
