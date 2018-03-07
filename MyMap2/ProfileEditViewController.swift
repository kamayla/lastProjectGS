//
//  ProfileEditViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/02/28.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage


class ProfileEditViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //グローバル変数の宣言
    var userID = String()
    var defaultStore : Firestore!
    //グローバル変数の宣言end
    
    
    
    //IBOutlet宣言
    @IBOutlet weak var textName: UITextField!
    @IBOutlet weak var textAge: UITextField!
    @IBOutlet weak var textBirthday: UITextField!
    @IBOutlet weak var textPr: UITextField!
    @IBOutlet weak var careerTextView: UITextView!
    @IBOutlet weak var myMainThumbnail: UIImageView!
    //IBOutlet宣言end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //layout
        
        // 枠のカラー
        careerTextView.layer.borderColor = UIColor.red.cgColor
        // 枠の幅
        careerTextView.layer.borderWidth = 1.0
        // 枠を角丸にする場合
        careerTextView.layer.cornerRadius = 10.0
        careerTextView.layer.masksToBounds = true
        
        //endlayout
        
        defaultStore = Firestore.firestore()
        textName.delegate = self
        textAge.delegate = self
        textBirthday.delegate = self
        textPr.delegate = self
        let ref = defaultStore.collection("UserProfile").document(userID)
        ref.getDocument { (document, error) in
            if let dic = document!.data() {
                print(dic["name"]!)
                self.textName.text = dic["name"] as? String
                self.textAge.text = dic["age"] as? String
                self.textBirthday.text = dic["birthday"] as? String
                self.textPr.text = dic["pr"] as? String
                self.careerTextView.text = dic["career"] as! String
            }else{
                print("ねぇよ")
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setMyMainThumbnail()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        defaultStore.collection("UserProfile").document(userID).setData([
            "name": textName.text!,
            "age": textAge.text!,
            "pr": textPr.text!,
            "birthday": textBirthday.text!,
            "career": careerTextView.text!
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //テキストフィールドでリターンを押したらキーボードを隠す
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func save(_ sender: UIButton) {
        defaultStore.collection("UserProfile").document(userID).setData([
            "name": textName.text!,
            "age": textAge.text!,
            "pr": textPr.text!,
            "birthday": textBirthday.text!,
            "career": careerTextView.text!
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    @IBAction func tappedView(_ sender: Any) {
        careerTextView.resignFirstResponder()
    }
    
    @IBAction func imgUpTapped(_ sender: Any) {
        let library = UIImagePickerControllerSourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(library) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            present(controller, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://mymap2-2e551.appspot.com")
        if let data = UIImagePNGRepresentation(resizeImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage, width: 200.0)) {
            
            let reference = storageRef.child("image/" + self.userID + "/" + "mainThumbnail" + ".jpg")
            reference.putData(data, metadata: nil, completion: { metaData, error in
                print(metaData as Any)
                print(error as Any)
                self.setMyMainThumbnail()
            })
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    /*画像のリサイズアルゴリズム********************************************************/
    func resizeImage(image: UIImage, width: CGFloat) -> UIImage {
        let ratioSize = image.size.height / image.size.width
        UIGraphicsBeginImageContext(CGSize(width: width, height: width * ratioSize))
        image.draw(in: CGRect(x: 0, y: 0,width: width, height: width * ratioSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
    /******************************************************************************/
    
    /*Storage内の画像データをダウンロードしてViewに表示*******************************************/
    func setMyMainThumbnail() {
        let storage = Storage.storage()
        let storageRef = storage.reference(forURL: "gs://mymap2-2e551.appspot.com")
        let islandRef = storageRef.child("image/\(userID)/mainThumbnail.jpg")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            print(data as Any)
            if let error = error {
                print("だめだこりゃ\(error)")
                // Uh-oh, an error occurred!
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                
                self.myMainThumbnail.image = image
            }
        }
    }
    /************************************************************************************/
}
