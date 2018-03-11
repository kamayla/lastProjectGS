//
//  ShopDetailViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/10.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage

class ShopDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    //グローバル変数宣言
    var shopName: String!
    var shopID: String!
    var imgRef: StorageReference!
    var defaultStore : Firestore!
    var categoryArray = [Any]()
    var categorysArray = [[Any]]()
    //グローバル変数宣言end
    
    //IBOutlet宣言
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var shopImage: UIImageView!
    //IBOutlet宣言end
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        menuTableView.dataSource = self
        shopNameLabel.text = shopName
        
        //SDWebImageライブラリで画像を描画
        imgRef.downloadURL { url, error in
            if let error = error {
                print(error)
            } else {
                self.shopImage.sd_setImage(with: url)
            }
        }
        
        //firestoreから商品カテゴリー一覧を作る
        defaultStore = Firestore.firestore()
        let ref = defaultStore.collection("products").document(shopID)
        ref.getDocument { (document, err) in
            if let err = err {
                print("\(err)")
            }else {
                if let dic = document!.data() {
                    for k in dic {
                        
                        
                        self.categoryArray.append(k.key)
                        let a = k.value as! [String : Any]
                        self.categoryArray.append(a)
                        print("testtttttttttt:\(a)")
                        for i in a.keys {
                            if let b = a[i] {
                                let g = b as! [String : Int]
                                print("test:\(g["price"]!)")
                            }
                        }
                        
                        self.categorysArray.append(self.categoryArray)
                        self.categoryArray = [Any]()
                    }
                }else{
                    print("ねぇよ")
                }
            }
            print(self.categorysArray)
            self.menuTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedClose(_ sender: Any) {
        self.dismiss(animated: true, completion:nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categorysArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = menuTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.lbl.text = categorysArray[indexPath.row][0] as? String
        cell.items = categorysArray[indexPath.row][1]
        
        
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = self.menuTableView.indexPathForSelectedRow{
            let cell = self.menuTableView.cellForRow(at:indexPath) as! CustomTableViewCell
            let vc = segue.destination as! ItemsViewController
            vc.shopID = self.shopID
            vc.imgRef = self.imgRef
            vc.shopName = self.shopName
            vc.category = self.categorysArray[indexPath.row][0] as! String
            vc.categoryCell = cell
        }
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
