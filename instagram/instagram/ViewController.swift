//
//  ViewController.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/2.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FacebookLogin
import FBSDKLoginKit
class ViewController: UIViewController {
    let buttonAddPhoto : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        
        return button
    }()
    let emailText : UITextField = {
        let tf = UITextField()
        tf.placeholder = "email"
        
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    @objc func handleTextInputChange(){
        let isFormValid = emailText.text?.count ?? 0 > 0 && passwordText.text?.count ?? 0 > 0 &&
            usernameText.text?.count ?? 0 > 0
        if isFormValid{
            signupButton.isEnabled = true
            signupButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        }
        else{
            signupButton.isEnabled = false
            signupButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
        
    }
    let usernameText : UITextField = {
        let tf = UITextField()
        tf.placeholder = "UserName"
        
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let passwordText : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let signupButton : UIButton = {
        let button = UIButton(type: .system)
//        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.setTitle("Sign Up", for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
        
    }()
    let FBLoginButton : UIButton = {
            let button = UIButton(type: .system)
    //        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            button.setTitle("FACEBOOK LOG IN", for: .normal)
            button.layer.cornerRadius = 5
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(fbLogin), for: .touchUpInside)
            return button
            
        }()
    @objc func fbLogin(){
        let manager = LoginManager()
        manager.logIn { (result) in
           if case LoginResult.success(granted: _, declined: _, token: _) = result {
                  print("login ok")
              } else {
                  print("login fail")
              }
        }
    }
    @objc func handleSignUp(){
        guard let email = emailText.text, email.count > 0 else {
            return
        }
        guard let password = passwordText.text, password.count > 0 else {
            return
        }
        guard let username = usernameText.text, username.count > 0 else {
            return
        }
       
        Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
            if err != nil{
                print("Creat Failed")
            }
            if let user = user{
                print("Success:", user.user.uid)
            }
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(buttonAddPhoto)
        buttonAddPhoto.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
//        buttonAddPhoto.heightAnchor.constraint(equalToConstant: 150).isActive = true
//        buttonAddPhoto.widthAnchor.constraint(equalToConstant: 150).isActive = true
        buttonAddPhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        buttonAddPhoto.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        
        setupInputFields()
        //check FB login
        if let accessToken = AccessToken.current {
           Profile.loadCurrentProfile { (profile, error) in
               if let profile = profile {
                  print(profile.name)
                  print(profile.imageURL(forMode: .square, size: CGSize(width: 300, height: 300)))
               }
           }
        } else {
            print("not login")
        }
        
    }
    func setupInputFields(){
        let stackView = UIStackView(arrangedSubviews: [emailText, usernameText, passwordText, signupButton, FBLoginButton])
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        view.addSubview(stackView)
//        NSLayoutConstraint.activate([
//                    stackView.topAnchor.constraint(equalTo: buttonAddPhoto.bottomAnchor, constant: 30),
//                    stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
//                    stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
//                    stackView.heightAnchor.constraint(equalToConstant: 200)
//                ])
        stackView.anchor(top: buttonAddPhoto.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 250)
    }


}
extension UIView{
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat){
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top{
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        if let left = left{
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let right = right{
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if let bottom = bottom{
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        if width != 0{
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if height != 0{
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}
