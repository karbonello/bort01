//
//  PAHeaderView.swift
//  Taxi for rider
//
//  Created by Chingis on 01.07.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

struct userData {
    let userFirstName: String!
    let userPhoneNumber: String!
    let userEmail: String!
    let avatarImage: UIImage!
}

class PAView: UITableViewController {
    
    var currentUserData: userData!
    let user = Auth.auth().currentUser
    private let editUserDataSegue = "EditUserData"
    
    override func viewDidLoad() {
        currentUserData = userData(userFirstName: "Keira Knightley", userPhoneNumber: "+7(927)123-45-67", userEmail: "keira@gmail.com", avatarImage: UIImage(named: "keira-knightley"))
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        UIApplication.shared.statusBarStyle = .default
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = Bundle.main.loadNibNamed("PAHeaderCell", owner: self, options: nil)?.first as! PAHeaderCell
            cell.avatarImageView.image = currentUserData.avatarImage
            cell.editButton.addTarget(self, action: #selector(goToEditView), for: .touchUpInside)
            
            return cell
        }
        else if indexPath.row == 1{
            let cell = Bundle.main.loadNibNamed("PADataCell", owner: self, options: nil)?.first as! PADataCell
            fillDataCell(cell: cell)
            return cell
        }
        else {
            let cell = Bundle.main.loadNibNamed("PABlackCars", owner: self, options: nil)?.first as! PABlackCars
            return cell
        }
    }
    
    func goToEditView() {
        self.performSegue(withIdentifier: self.editUserDataSegue, sender: nil)
    }
    
    func fillDataCell(cell: PADataCell)  {
        DBProvider.Instance.ridersRef.child(user!.uid).observe(DataEventType.value, with: {(snapshot) in
            if let dataInData = snapshot.value as? NSDictionary {
                if let data = dataInData["data"] as? NSDictionary {
                    
                    if let email = data[Constants.EMAIL] as? String {
                        cell.emailLabel.text = email
                    } else {
                        cell.emailLabel.text = "Нет данных"
                    }
                    
                    if let firstName = data[Constants.FIRST_NAME] as? String {
                        cell.userFirstName.text = firstName
                    }
                    else {
                        cell.userFirstName.text = "Введите имя"
                    }
                    
                    
                    if let phoneNumber = data[Constants.PHONE_NUMBER] as? String {
                        cell.phoneLabel.text = phoneNumber
                    } else {
                        cell.phoneLabel.text = "Нет данных"
                    }
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 136
        }
        else if indexPath.row == 1 {
            return 120
        }
        else {
            return 160
        }
    }
}
