//
//  AcountEditViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/25.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage
import FirebaseAuth

class AcountEditViewController: UIViewController, UITextFieldDelegate {
    
    //グローバル変数宣言
    var defaultStore : Firestore!
    var shopsArray = [[Any]]()
    var shopArray = [Any]()
    var cartNow = [[String:Any]]()
    var user: User!
    var ref: DatabaseReference!
    var userProfileFiled: String!
    //グローバル変数宣言end

    @IBOutlet weak var editTitleLabel: UILabel!
    @IBOutlet weak var editTextField: UITextField!
    @IBOutlet weak var editbutton: UIButton!
    
    var titleName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editTextField.delegate = self
        editTitleLabel.text = titleName!
        editbutton.setTitle("\(titleName!)を変更する", for: .normal)
        editbutton.setTitleColor(UIColor.white, for: .normal)
        editbutton.backgroundColor = UIColor(red: 0, green: 0.47843137, blue: 1.0, alpha: 1.0)
        user = Auth.auth().currentUser
        defaultStore = Firestore.firestore()
        
        if titleName == "名前" {
            userProfileFiled = "name"
        } else if titleName == "電話番号" {
            userProfileFiled = "tel"
        } else if titleName == "住所" {
            userProfileFiled = "address"
        }
        
        defaultStore.collection("UserProfile").document(user.uid).getDocument { (snapshot, err) in
            if let dic = snapshot!.data() {
                self.editTextField.text = dic[self.userProfileFiled] as? String
            } else {
                print("データがねぇよ")
                let data = ["name":"","address":"","tel":""]
                self.defaultStore.collection("UserProfile").document(self.user.uid).setData(data)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedUpdate(_ sender: Any) {
        defaultStore.collection("UserProfile").document(user.uid).updateData([userProfileFiled : self.editTextField.text as Any])
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tappedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
