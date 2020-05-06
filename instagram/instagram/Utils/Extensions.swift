//
//  Extensions.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/2.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import UIKit
import Firebase
extension Database{
    static func fetchUserWithUID(uid: String, completion: @escaping (User) -> ()){
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    guard let dictionary = snapshot.value as? [String: Any] else {return}
                    let user = User(uid: uid, dictionary: dictionary)
                    completion(user)
//                    fetchPostsWithUser(user: user)
                }) { (err) in
                    print("Fetch users failed", err)
                }
    }
}
extension UIColor{
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
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
