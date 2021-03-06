//
//  ItemsViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/11.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage
import FirebaseAuth

class ItemsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    //グローバル変数宣言
    var user: User!
    var shopName: String!
    var shopID: String!
    var category: String!
    var ref: DatabaseReference!
    var imgRef: StorageReference!
    var defaultStore : Firestore!
    var categoryCell: CustomTableViewCell!
    var product = [Any]()
    var products = [[Any]]()
    var willCart = [[String:Any]]()
    //グローバル変数宣言end
    
    
    //IBOutlet宣言
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var shopImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var cartInQuantity: UILabel!
    @IBOutlet weak var cartInSum: UILabel!
    @IBOutlet weak var cartInArea: UIView!
    //IBOutlet宣言end
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        itemsTableView.allowsSelection = false
        itemsTableView.dataSource = self
        shopNameLabel.text = shopName
        categoryLabel.text = category
        //SDWebImageライブラリで画像を描画
        imgRef.downloadURL { url, error in
            if let error = error {
                print(error)
            } else {
                self.shopImage.sd_setImage(with: url)
            }
        }
        
        
        if let items = categoryCell.items {
            let products = items as! [String : Any]
            print("testaaaaaaaaaaaaa:\(products.keys)")
            for product in products.keys {
                let item = products[product] as! [String:Int]
                print("\(product):\(item["price"]!)")
                print("\(product):\(item["quantity"]!)")
                self.product.append(product)
                self.product.append(item["price"]!)
                self.product.append(item["quantity"]!)
                self.products.append(self.product)
                self.product = [Any]()
            }
        }
        
//        ref.child("cars/\(user.uid)").observeSingleEvent(of: .value) { (snapshot) in
//            for items in snapshot.children {
//                let child = items as! DataSnapshot
//                let array = child.value as! NSArray
//
//                for willdic in array {
//                    let dic = willdic as! NSDictionary
//                    print(dic)
//                    self.willCart.append(dic as! [String : Any])
//                }
//            }
//        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedClose(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.products.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemsTableViewCell
        cell.itemNameLabel.text = self.products[indexPath.row][0] as? String
        cell.priceLabel.text = "¥\(String(describing: self.products[indexPath.row][1]))"
        cell.price = self.products[indexPath.row][1] as! Int
        cell.quantity = self.products[indexPath.row][2] as! Int
        cell.name = self.products[indexPath.row][0] as! String
        cell.OwnItemsViewController = self
        
        return cell
    }
    
    @IBAction func tappedCartInArea(_ sender: Any) {
        ref.child("carts").child(user.uid).childByAutoId().setValue(self.willCart)
        self.dismiss(animated: true, completion:nil)
        print("cartに入れるよ！！\(willCart)")
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
