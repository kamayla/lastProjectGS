//
//  CartViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/16.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class CartViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //グローバル変数宣言
    var user: User!
    var name: String!
    var price: Int!
    var quantity: Int!
    var selectedQuantity = 0
    var cartNow = [[String : Any]]()
    var ref: DatabaseReference!
    var defaultStore : Firestore!
    let sendPay = 380
    //グローバル変数宣言end
    
    
    
    
    
    
    //IBOutlet宣言
    @IBOutlet weak var cartTableView: UITableView!
    //IBOutlet宣言end
    override func viewDidLoad() {
        super.viewDidLoad()
        cartTableView.dataSource = self
        cartTableView.delegate = self
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        
        //firebaseからcarts情報を取得
        self.ref.child("carts").child(user.uid).observe(.value) { (snapshot) in
            self.cartNow = [[String:Any]]()
            for item in snapshot.children {
                let child = item as! DataSnapshot
                let array = child.value as! NSArray
                for arrayChild in array {
                    var arrayChildDic = arrayChild as! [String : Any]
                    arrayChildDic.updateValue(child.key, forKey: "orderKey")
                    arrayChildDic.updateValue(self.user.uid, forKey: "userID")
                    arrayChildDic.updateValue(array.index(of: arrayChild), forKey: "indexNum")
                    self.cartNow.append(arrayChildDic)
                    print("辞書型テストしてます\(arrayChildDic)")
                }
            }
            
            self.cartTableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cartNow.count
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        if indexPath.section == 0 {
            self.cartTableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
            cell = cartTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableViewCell
            (cell as! ProductTableViewCell).name.text = self.cartNow[indexPath.row]["name"] as? String
            (cell as! ProductTableViewCell).price.text = "¥\(String(self.cartNow[indexPath.row]["price"] as! Int))"
            (cell as! ProductTableViewCell).quantity.text = String(self.cartNow[indexPath.row]["quantity"] as! Int)
            (cell as! ProductTableViewCell).orderKey = self.cartNow[indexPath.row]["orderKey"] as! String
            (cell as! ProductTableViewCell).userID = self.cartNow[indexPath.row]["userID"] as! String
            (cell as! ProductTableViewCell).indexNum = self.cartNow[indexPath.row]["indexNum"] as! Int
            (cell as! ProductTableViewCell).CartViewController = self
        } else if indexPath.section == 1 {
            self.cartTableView.register(UINib(nibName: "PaySumTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
            cell = cartTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PaySumTableViewCell
            var paySum = 0
            for i in self.cartNow {
                paySum += (i["price"] as! Int) * (i["quantity"] as! Int)
            }
            (cell as! PaySumTableViewCell).paySumLabel.text = "¥\(paySum)"
            (cell as! PaySumTableViewCell).paySendLabel.text = "¥\(self.sendPay)"
            (cell as! PaySumTableViewCell).totalLabel.text = "¥\(paySum + self.sendPay)"
        }
        
        
        
        
        if let cell = cell as? ProductTableViewCell {
            return cell
        } else if let cell = cell as? PaySumTableViewCell {
            return cell
        } else {
            return cell
        }
    }
    
    @IBAction func tappedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
