//
//  ViewController.swift
//  MyMap2
//
//  Created by 上村一平 on 2018/02/10.
//  Copyright © 2018年 上村一平. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseAuth
import Firebase



class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MKMapViewDelegate{
    
    //IBOutlet宣言
    @IBOutlet weak var ckoutButton: UIBarButtonItem!
    @IBOutlet weak var ckinButton: UIBarButtonItem!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var displayMap: MKMapView!
    //IBOutlet宣言end
    
    //グローバル変数宣言
    var ref: DatabaseReference!
    var defaultStore : Firestore!
    var user: User!
    var contentsArray = [String: Any]()
    var myName = "名無し"
    var uName = "名無し"
    var myLocationManager: CLLocationManager!
    var girlsList: [String: String] = [:]
    var gPinArray: [MKPointAnnotation] = []
    var myPlace: MyMKPointAnnotation!
    //グローバル変数宣言end
    
    @IBAction func tappedSingOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "signOut", sender: nil)
        } catch let error {
            assertionFailure("Error signing out: \(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let ref = defaultStore.collection("UserProfile").document(user.uid)
        ref.getDocument { (document, error) in
            if let dic = document!.data() {
                print(dic["name"]!)
                self.myName = dic["name"] as! String
                self.ref.child("usersPlace/\(self.user.uid)").observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if snapshot.hasChild("latitude"){
                        print("要素あり")
                        self.ref.child("usersPlace/\(self.user.uid)").updateChildValues(["name": self.myName])
                    }else{
                        print("要素なし")
                    }
                })
                
            }else{
                print("ねぇよ")
            }
        }
    }


    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        defaultStore = Firestore.firestore()
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        

        inputText.delegate = self
        myLocationManager = CLLocationManager()
        myLocationManager.requestWhenInUseAuthorization()
        myLocationManager.startUpdatingLocation()
        myLocationManager.delegate = self
        
        
        ref.child("usersPlace").observe(.value) { (snap) in
            self.displayMap.removeAnnotations(self.gPinArray)
            
            for item in snap.children {
                let child = item as! DataSnapshot
                let user = child.key
                let dic = child.value as! NSDictionary
                if user == self.user.uid {
                    if self.myPlace != nil {
                        self.displayMap.removeAnnotation(self.myPlace)
                    }
                    self.myPlace = MyMKPointAnnotation()
                    let y = dic["latitude"] as! Double
                    let x = dic["longitude"] as! Double
                    let gCenter = CLLocationCoordinate2DMake(y, x)
                    self.myPlace.title = dic["name"] as? String
                    self.myPlace.subtitle = "I`m here"
                    self.myPlace.coordinate = gCenter
                    self.myPlace.pinColor = UIColor.purple
                    self.displayMap.addAnnotation(self.myPlace)
                    self.gPinArray.append(self.myPlace)
                    self.displayMap.delegate = self
                }else{
                    let gPin = GirlMKPointAnnotation()
                    let y = dic["latitude"] as! Double
                    let x = dic["longitude"] as! Double
                    let gCenter = CLLocationCoordinate2DMake(y, x)
                    gPin.title = dic["name"] as? String
                    gPin.subtitle = "I`m here"
                    gPin.userID = user
                    gPin.coordinate = gCenter
                    self.displayMap.addAnnotation(gPin)
                    self.gPinArray.append(gPin)
                    self.displayMap.delegate = self
                }
            }
        }
//        self.displayMap.region = MKCoordinateRegionMakeWithDistance((myLocationManager.location!.coordinate),500.0,500.0)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //現在地の座標を変数centerに取得
        let center = myLocationManager.location!.coordinate
        //マップをcenterに移動させる。
        displayMap.region = MKCoordinateRegionMakeWithDistance(center, 2000.0, 2000.0)
        myLocationManager.stopUpdatingLocation()
    }
    

        
    @IBAction func tappedNow(_ sender: Any) {
        self.displayMap.region = MKCoordinateRegionMakeWithDistance(myLocationManager.location!.coordinate, 2000.0, 2000.0)
        
    }
    
    @IBAction func profileEditTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goProfileEdit", sender: user.uid)
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let searchKeyword = textField.text
        print(searchKeyword!)
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchKeyword!, completionHandler: {(placemarks:[CLPlacemark]?, error: Error?) in
            if let placemark = placemarks?[0] {
                if let targetCoordinate = placemark.location?.coordinate{
                    print(targetCoordinate)
                    
                    let pin = MKPointAnnotation()
                    pin.coordinate = targetCoordinate
                    pin.title = searchKeyword
                    
                    self.displayMap.addAnnotation(pin)
                    self.displayMap.region = MKCoordinateRegionMakeWithDistance(targetCoordinate,500.0,500.0)
                }
            }
        })
        
        return true
    }
    
   
    
    
    @IBAction func tappedCHeckin(_ sender: UIBarButtonItem) {
        ckinButton.isEnabled = false
        if myPlace != nil{
            self.ref.child("usersPlace/\(user.uid)").removeValue()
            self.displayMap.removeAnnotation(myPlace)
        }
        contentsArray = ["name": myName,"latitude": myLocationManager.location!.coordinate.latitude, "longitude": myLocationManager.location!.coordinate.longitude]
        print(contentsArray)
        print(user.uid)
        self.ref.child("usersPlace").child(self.user.uid).setValue(contentsArray)
        print(myLocationManager.location!.coordinate)
        
        //現在地の座標を変数centerに取得
        let center = myLocationManager.location!.coordinate
        
        //マップをcenterに移動させる。
        displayMap.region = MKCoordinateRegionMakeWithDistance(center, 500.0, 500.0)
        
        //ピンを生成
        myPlace = MyMKPointAnnotation()
        myPlace.coordinate = center
        myPlace.title = myName
        myPlace.subtitle = "I`m here."
        myPlace.pinColor = UIColor.purple
        myPlace.userID = self.user.uid
        displayMap.addAnnotation(myPlace)
        displayMap.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pin = MyMKPinAnnotationView()
        pin.annotation = annotation
        if let test = annotation as? MyMKPointAnnotation {
            pin.pinTintColor = test.pinColor
        }else if let test = annotation as? GirlMKPointAnnotation{
            pin.usreID = test.userID
            pin.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
        }
        
        pin.canShowCallout = true
        
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("私はここだ")
        performSegue(withIdentifier: "DetailGo", sender: view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailGo" {
            let vc = segue.destination as! DetailViewController
            let a = sender as! MyMKPinAnnotationView
            vc.name = a.annotation?.title as! String
            vc.latitude = a.annotation?.coordinate.latitude as! Double
            vc.longitude = a.annotation?.coordinate.longitude as! Double
            vc.userID = a.usreID
        }else if segue.identifier == "goProfileEdit" {
            let vc = segue.destination as! ProfileEditViewController
            vc.userID = sender as! String
        }
    }
    

    @IBAction func tappedCheckOut(_ sender: Any) {
        ckinButton.isEnabled = true
        ckoutButton.isEnabled = false
        self.ref.child("usersPlace/\(user.uid)").removeValue()
        self.displayMap.removeAnnotation(myPlace)
    }
    
    @IBAction func tappedMsgListGo(_ sender: Any) {
        performSegue(withIdentifier: "goMsgList", sender: nil)
    }
    
    
        
    
    
    
}

