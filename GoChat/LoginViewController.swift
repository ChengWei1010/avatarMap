
//
//  LoginViewController.swift
//  GoChat
//
//  Created by 鄭薇 on 2016/12/4.
//  Copyright © 2016年 LilyCheng. All rights reserved.
//
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController{
    
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var userImg: UIImageView!
    
    var isSetPhoto:Bool = false
    let uuid: String =  UIDevice.current.identifierForVendor!.uuidString
    var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://tripgif-b205b.appspot.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //點logo即可選照片的東東
        //MainImg.isUserInteractionEnabled = true
        //self.MainImg.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(handleSelectProfileImageView)))
        print("我裝置的uuid: \(uuid)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        print(FIRAuth.auth()?.currentUser)
        //        FIRAuth.auth()?.addStateDidChangeListener({(auth:FIRAuth, user:FIRUser?)in
        //            if user !=nil{
        //                print(user)
        //                Helper.helper.switchToNavigationViewController()
        //            }else{
        //                print("Unauthorized")
        //            }
        //        })
        print("現在這人的uid是: \(FIRAuth.auth()?.currentUser?.uid)")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func NickNameButton(_ sender: Any) {
        if Name?.text != "" {
            FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
                if error != nil{
                    print("create user error " + error!.localizedDescription)
                }else{
                    print("我的暱稱是: " + self.Name.text!)
                    print((FIRAuth.auth()?.currentUser?.uid)!)
                    let userName: String = self.Name.text!
                    let userId:String = (FIRAuth.auth()?.currentUser?.uid)!
                    let userRef = FIRDatabase.database().reference().child("TripGifUsers")

                    //預設不設定個人照片，如果有設定個人照片
                    let imageName = self.uuid
                    let userImgRef = FIRStorage.storage().reference().child("\(imageName).png")
                    
                    if let uploadData = UIImagePNGRepresentation(self.userImg.image!){
                        userImgRef.put(uploadData, metadata: nil, completion:
                            {(metadata, error)in
                                if error != nil{
                                    print(error!)
                                    return
                                }
                                //新增User到資料庫
                                let newUser = userRef.child(self.uuid)
                                //if let userImgUrl = metadata?.downloadURL()?.absoluteString{
                                if let userImgUrl = metadata?.downloadURLs![0].absoluteString{
                                    let newUserData = ["NickName":userName, "uid":userId, "uuid":self.uuid, "UserImgUrl":userImgUrl]
                                    newUser.setValue(newUserData)
                                }
                        })
                    }
                }
            })
        }else{
            //創建失敗小視窗
            let alert = UIAlertController(title: "請務必輸入暱稱", message: "您輸入的名字會作為同夥模式暱稱", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    //先沒用到
    func setUserImage(picture:UIImage?){
            print (picture!)
            print(FIRStorage.storage().reference())
            if let picture = picture{ //Media是照片
                let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate)"
                //用目前使用者和時間來區別不同的filePath
                print(filePath)
                let data = UIImagePNGRepresentation(picture)// return image as JPEG, 1表示不壓縮，把UIImage轉成NSData
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/png"
                
                FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata){(metadata, error) in
                    //child:存照片的地方, put:上傳照片到storage
                    if error != nil{
                        print(error?.localizedDescription)
                        return
                    }
                    //print(metadata)
                    let fileUrl = metadata!.downloadURLs![0].absoluteString //!:not nil, Get the URL string from URL
                    
                    //在firebase新增使用者(郭郭之後要改掉這段)
                    let userName: String = self.Name.text!
                    let userId:String = (FIRAuth.auth()?.currentUser?.uid)!
                    let userRef = FIRDatabase.database().reference().child("TripGifUsers")
                    
                    let newUser = userRef.child(self.uuid)
                    if let userImgUrl = metadata?.downloadURLs![0].absoluteString{
                        let newUserData = ["NickName":userName, "uid":userId, "uuid":self.uuid, "UserImgUrl":fileUrl]
                        newUser.setValue(newUserData)
                    }
                    //在firebase新增使用者(郭郭之後要改掉這段)
                }
            }
    }
    @IBAction func SetPhotoButton(_ sender: Any) {
        handleSelectProfileImageView()
        self.isSetPhoto = true
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "LoginToApp"){
            super.prepare(for: segue, sender: sender)
            let navVc = segue.destination as! UINavigationController // 1
            let roomVc = navVc.viewControllers.first as! RoomsViewController // 2
            roomVc.senderDisplayName = (Name?.text)! // 3
        }
    }
}
extension LoginViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated:true, completion:nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            //先沒用到
            //setUserImage(picture:selectedImage)
            self.userImg.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancel")
        dismiss(animated: true, completion: nil)
    }
}
