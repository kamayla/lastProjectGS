//
//  EditViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/03/21.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import SDWebImage
import FirebaseAuth


class EditViewController: UIViewController {
    //IBOutlet宣言
    @IBOutlet weak var userNameLabel: UILabel!
    
    //グローバル変数宣言
    var defaultStore : Firestore!
    var user: User!
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        defaultStore = Firestore.firestore()
        
        defaultStore.collection("UserProfile").document(user.uid).getDocument { (snapshot, err) in
            if let dic = snapshot!.data() {
                self.userNameLabel.text = (dic["name"] as! String)
            } else {
                print("データがねぇよ")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
