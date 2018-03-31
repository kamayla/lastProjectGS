//
//  ItemsTableViewCell.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/11.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ItemsTableViewCell: UITableViewCell {
    
    
    

    
    
    //IBOutlet宣言
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    //IBOutlet宣言end
    
    //グローバル変数宣言
    var user: User!
    var name: String!
    var price: Int!
    var quantity: Int!
    var selectedQuantity = 0
    var itemNow = [String : Any]()
    var OwnItemsViewController: ItemsViewController!
    var ref: DatabaseReference!
    //グローバル変数宣言end
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        user = Auth.auth().currentUser
        self.minusButton.isEnabled = false
        quantityLabel.text = String(selectedQuantity)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tappedPlus(_ sender: Any) {
        minusButton.isEnabled = true
        OwnItemsViewController.cartInArea.isHidden = false
        selectedQuantity += 1
        quantityLabel.text = String(selectedQuantity)
        if selectedQuantity >= quantity {
            plusButton.isEnabled = false
        }
        
        itemNow = ["name" : name,"price" : price,"quantity" : selectedQuantity,"shopID": OwnItemsViewController.shopID]
        var flag = true
        for n in 0..<OwnItemsViewController.willCart.count {
            if OwnItemsViewController.willCart[n]["name"] as! String  == name {
                OwnItemsViewController.willCart[n]["quantity"] = selectedQuantity
                flag = false
            }
        }
        if flag == true {
            OwnItemsViewController.willCart.append(itemNow)
        }
        print(OwnItemsViewController.willCart)
        totalOutput()
    }
    
    @IBAction func tappedMinus(_ sender: Any) {
        plusButton.isEnabled = true
        selectedQuantity -= 1
        quantityLabel.text = String(selectedQuantity)
        if selectedQuantity == 0 {
            minusButton.isEnabled = false
        }
        
        for n in 0..<OwnItemsViewController.willCart.count {
            if OwnItemsViewController.willCart[n]["name"] as! String  == name {
                if selectedQuantity > 0 {
                    OwnItemsViewController.willCart[n]["quantity"] = selectedQuantity
                }else {
                    OwnItemsViewController.willCart.remove(at: n)
                    print(OwnItemsViewController.willCart)
                    totalOutput()
                    if OwnItemsViewController.willCart.count <= 0 {
                        OwnItemsViewController.cartInArea.isHidden = true
                    }
                    return
                }
            }
        }
        print(OwnItemsViewController.willCart)
        totalOutput()
    }
    
    func totalOutput() {
        var sumQuantity = 0
        var sumPay = 0
        for i in OwnItemsViewController.willCart {
            sumQuantity += i["quantity"] as! Int
            sumPay += (i["price"] as! Int) * (i["quantity"] as! Int)
        }
        OwnItemsViewController.cartInQuantity.text = String(sumQuantity)
        OwnItemsViewController.cartInSum.text = "¥\(String(sumPay))"
    }
}
