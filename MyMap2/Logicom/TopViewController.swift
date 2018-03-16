//
//  TopViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/10.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage
import FirebaseAuth


class TopViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //グローバル変数宣言
    var defaultStore : Firestore!
    var shopsArray = [[Any]]()
    var shopArray = [Any]()
    var cartNow = [[String:Any]]()
    var user: User!
    var ref: DatabaseReference!
    //グローバル変数宣言end
    
    
    
    //IBOutlet宣言
    @IBOutlet weak var shopitems: UICollectionView!
    @IBOutlet weak var cartLookArea: UIView!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var paySumLabel: UILabel!
    //IBOutlet宣言end
    
    
    
   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        shopitems.dataSource = self
        self.shopitems.layer.borderColor = UIColor.gray.cgColor
        self.shopitems.layer.borderWidth = 1
        
        //お店の情報をfirestoreから取得
        defaultStore = Firestore.firestore()
        let storage = Storage.storage().reference()
        let FSref = defaultStore.collection("shops")
        FSref.getDocuments { (querySnapshot, err) in
            self.shopsArray = [[Any]]()
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let dic = document.data()
                    self.shopArray.append(dic["name"] as Any)
                    self.shopArray.append(dic["place"] as Any)
                    self.shopArray.append(storage.child("shopimg/\(document.documentID)/\(dic["image"] as! String)"))
                    self.shopArray.append(document.documentID)
                    print(self.shopArray)
                    self.shopsArray.append(self.shopArray)
                    self.shopArray = [Any]()
                }
                print(self.shopsArray)
                
            }
            self.shopitems.reloadData()
        }
        
        //お店の情報をfirestoreから取得end
        
        //firebaseからcarts情報を取得
        self.ref.child("carts").child(user.uid).observe(.value) { (snapshot) in
            self.cartNow = [[String:Any]]()
            for item in snapshot.children {
                let child = item as! DataSnapshot
                let array = child.value as! NSArray
                for arrayChild in array {
                    self.cartNow.append(arrayChild as! [String:Any])
                    print(arrayChild as! [String:Any])
                }
            }
            if self.cartNow.count > 0 {
                self.cartLookArea.isHidden = false
            }else {
                self.cartLookArea.isHidden = true
            }
            self.totalOutput()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shopsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : CustomCellCollectionViewCell = shopitems.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCellCollectionViewCell
        cell.lbl.text = self.shopsArray[indexPath.row][0] as? String
        let imgRef = self.shopsArray[indexPath.row][2] as! StorageReference
        imgRef.downloadURL { url, error in
            if let error = error {
                print(error)
            } else {
                //imageViewに描画、SDWebImageライブラリを使用して描画
                
                cell.img.sd_setImage(with: url)
            }
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goCart" {
            
        }else {
            if let indexPath = self.shopitems.indexPathsForSelectedItems {
                let vc = segue.destination as! ShopDetailViewController
                vc.shopName = shopsArray[indexPath[0][1]][0] as! String
                vc.shopID = shopsArray[indexPath[0][1]][3] as! String
                vc.imgRef = shopsArray[indexPath[0][1]][2] as! StorageReference
            }
        }
    }
    
    func totalOutput() {
        var sumQuantity = 0
        var sumPay = 0
        for i in cartNow {
            sumQuantity += i["quantity"] as! Int
            sumPay += (i["price"] as! Int) * (i["quantity"] as! Int)
        }
        quantityLabel.text = String(sumQuantity)
        paySumLabel.text = "¥\(String(sumPay))"
    }
    
    @IBAction func tappedCartGo(_ sender: Any) {
        performSegue(withIdentifier: "goCart", sender: nil)
    }
    

}
