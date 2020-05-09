//
//  SharePhotoController.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/5.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
class SharePhotoController: UIViewController {
    static let updateFeedNotificationName = NSNotification.Name("updateFeed")
    var selectedImage: UIImage? {
        didSet{
            self.imageView.image = selectedImage
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        setupImageAndTextViews()
        
    }
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    let textView: UITextView = {
        let tv = UITextView()
        tv.textColor = .black
        tv.backgroundColor = .white
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    fileprivate func setupImageAndTextViews(){
        let containerView = UIView()
        containerView.backgroundColor = .white
        let width = containerView.frame.width
        view.addSubview(containerView)
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        containerView.addSubview(imageView)
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 300)
        containerView.addSubview(textView)
        textView.anchor(top: imageView.bottomAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    @objc func handleShare(){
        guard let caption = textView.text, !caption.isEmpty else {return}
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        guard let image = selectedImage else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.5) else {return}
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err{
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload image", err)
                return
            }
            
            storageRef.downloadURL { (downloadURL, err) in
                if let err = err{
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print("Failed to download url", err)
                    return
                }
                guard let imageUrl = downloadURL?.absoluteString else {return}
                print("Successfully uploaded post image:", imageUrl)
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
            }
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String){
        guard let caption = textView.text else {return}
        guard let postImage = selectedImage else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err{
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to save db", err)
                return
            }
            print("Successfully save to DB")
//myself idea            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
            //auto refresh
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
