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
import CoreLocation

class CartViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate {
    
    //グローバル変数宣言
    var user: User!
    var userName: String!
    var name: String!
    var price: Int!
    var quantity: Int!
    var myPlace: String!
    var shopID: String!
    var shopPlace: String!
    var shopName: String!
    var selectedQuantity = 0
    var cartNow = [[String : Any]]()
    var ref: DatabaseReference!
    var defaultStore : Firestore!
    let sendPay = 380
    var contentsArray = [String: Any]()
    //グローバル変数宣言end
    
    //IBOutlet宣言
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var sendArea: UILabel!
    //IBOutlet宣言end
    override func viewDidLoad() {
        super.viewDidLoad()
        cartTableView.dataSource = self
        cartTableView.delegate = self
        user = Auth.auth().currentUser
        
        if let tableView = self.cartTableView {
            tableView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "cell1")
            tableView.register(UINib(nibName: "PaySumTableViewCell", bundle: nil), forCellReuseIdentifier: "cell2")
        }
        
        
        ref = Database.database().reference()
        //firebaseからcarts情報を取得
        self.ref.child("carts").child(user.uid).observe(.value) { (snapshot) in
            self.cartNow = [[String:Any]]()
            for item in snapshot.children {
                let child = item as! DataSnapshot
                let array = child.value as! NSArray
                for arrayChild in array {
                    var arrayChildDic = arrayChild as! [String : Any]
                    self.shopID = arrayChildDic["shopID"] as! String
                    arrayChildDic.updateValue(child.key, forKey: "orderKey")
                    arrayChildDic.updateValue(self.user.uid, forKey: "userID")
                    arrayChildDic.updateValue(array.index(of: arrayChild), forKey: "indexNum")
                    self.cartNow.append(arrayChildDic)
                }
            }
            
            if self.cartNow.count == 0 {
                self.dismiss(animated: true, completion: nil)
            }
            self.defaultStore.collection("shops").document(self.shopID).getDocument { (document, err) in
                if let dic = document!.data() {
                    self.shopPlace = dic["place"] as! String
                    self.shopName = dic["name"] as! String
                }
            }
            self.cartTableView.reloadData()
        }
        
        defaultStore = Firestore.firestore()
        defaultStore.collection("UserProfile").document(user.uid).getDocument { (document, err) in
            if let dic = document!.data() {
                self.sendArea.text = dic["address"] as? String
                self.myPlace = dic["address"] as? String
                self.userName = dic["name"] as? String
            }
        }
        
        defaultStore.collection("orders").document(user.uid).getDocument { (document, err) in
            if let dic = document!.data() {
                print(dic)
            } else {
                let order = self.defaultStore.collection("orders").document(self.user.uid)
                order.setData([:])
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("バグ調べ\(self.cartNow.count)")
        if section == 0 {
            
            return cartNow.count
        } else if section == 1 {
            
            return 1
        } else {
            return 0
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! ProductTableViewCell
            cell.name.text = self.cartNow[indexPath.row]["name"] as? String
            cell.price.text = "¥\(String(self.cartNow[indexPath.row]["price"] as! Int))"
            cell.quantity.text = String(self.cartNow[indexPath.row]["quantity"] as! Int)
            cell.orderKey = self.cartNow[indexPath.row]["orderKey"] as! String
            cell.userID = self.cartNow[indexPath.row]["userID"] as! String
            cell.indexNum = self.cartNow[indexPath.row]["indexNum"] as! Int
            cell.CartViewController = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! PaySumTableViewCell
            var paySum = 0
            for i in self.cartNow {
                paySum += (i["price"] as! Int) * (i["quantity"] as! Int)
            }
            cell.paySumLabel.text = "¥\(paySum)"
            cell.paySendLabel.text = "¥\(self.sendPay)"
            cell.totalLabel.text = "¥\(paySum + self.sendPay)"
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
        

    }
    
    @IBAction func tappedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func tappedOrder(_ sender: Any) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(shopPlace, completionHandler: {(placemarks:[CLPlacemark]?, error: Error?) in
            if let placemark = placemarks?[0] {
                if let targetCoordinate = placemark.location?.coordinate{
                    print(targetCoordinate)
                    self.contentsArray = ["name": self.shopName,"latitude": targetCoordinate.latitude, "longitude": targetCoordinate.longitude]
                    self.ref.child("usersPlace").child(self.shopID).setValue(self.contentsArray)
                }
            }
        })
        
        let now = NSDate() // 現在日時の取得
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale! // ロケールの設定
        dateFormatter.dateFormat = "yyyyMMddHHmmss" // 日付フォーマットの設定
        
        print(dateFormatter.string(from: now as Date)) // -> 2014/06/25 02:13:18
        
        let date = dateFormatter.string(from: now as Date) + "\(user.uid)"
        let order = self.defaultStore.collection("orders").document(user.uid)
        var dic = [String:Any]()
        var ArrayData = [date:[String:Any]()]
        for i in 0..<cartNow.count {
            dic.updateValue(cartNow[i],forKey: "\(i)")
        }
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let orderDate = dateFormatter.string(from: now as Date)
        ArrayData.updateValue(["items":dic], forKey: date)
        order.updateData(ArrayData)
        order.updateData(["orderDate":orderDate])
        order.updateData(["shopID":cartNow[0]["shopID"] as Any])
        order.updateData(["orderKey":date])
        order.updateData(["userID":cartNow[0]["userID"]])
        
        ref.child("carts").child(user.uid).removeValue()
        ref.child("orderManager").child(cartNow[0]["shopID"] as! String).childByAutoId().setValue(["orderID":date])
        self.dismiss(animated: true, completion: nil)
    }
}
