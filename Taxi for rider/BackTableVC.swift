  //
//  BackTableVC.swift
//  Taxi for rider
//
//  Created by Chingis on 24.06.17.
//  Copyright © 2017 Chingis. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class BackTableVC: UITableViewController {
    
    var TableArray = [String]()
    let user = Auth.auth().currentUser
    
    
    override func viewDidLoad() {
        TableArray = ["first", "История поездок", "Платежная система", "Промо", "#bortgram", "Вопросы", "Служба поддержки"]
        view.backgroundColor = UIColor.black
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func updatePersonalCell() {
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableArray[indexPath.row], for: indexPath)

        if TableArray[indexPath.row] == "first" {
            DBProvider.Instance.ridersRef.child(user!.uid).observe(DataEventType.value, with: {(snapshot) in
                if let dataInData = snapshot.value as? NSDictionary {
                    if let data = dataInData["data"] as? NSDictionary {
                        if let firstName = data[Constants.FIRST_NAME] as? String {
                            cell.textLabel?.text = firstName
                        }
                        else {
                            cell.textLabel?.text = Auth.auth().currentUser?.email
                        }
                    }
                }
            })
        } else {
            cell.textLabel?.text = TableArray[indexPath.row]
        }
        
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor.darkGray
            cell.frame.size.height = 60
        }
        cell.textLabel?.textColor = UIColor.white
        
        return cell
    }
    
    
    
}
