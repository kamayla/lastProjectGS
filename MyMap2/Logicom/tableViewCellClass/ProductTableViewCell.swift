//
//  ProductTableViewCell.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/16.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ProductTableViewCell: UITableViewCell {
    //IBOutlet宣言
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var quantity: UILabel!
    //IBOutlet宣言end
    
    //グローバル変数宣言
    var ref: DatabaseReference!
    var userID: String!
    var orderKey: String!
    var indexNum: Int!
    var CartViewController: CartViewController!
    //グローバル変数宣言end
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ref = Database.database().reference()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func tappedGoTrash(_ sender: Any) {
        CartViewController.cartTableView.reloadData()
        var data = [[String:Any]]()
        ref.child("carts").child(userID).child(orderKey).observeSingleEvent(of: .value) { (snapshot) in
            for item in snapshot.children {
                let child = item as! DataSnapshot
                print(child.value! as! [String:Any])
                print(child.key)
                if Int(child.key) != self.indexNum {
                    data.append(child.value! as! [String:Any])
                    print("aaaaaaaaaaaaaaaaaaa\(data)")
                }
            }
            self.ref.child("carts/\(self.userID!)/\(self.orderKey!)").setValue(data)
        }
    }
    
}
