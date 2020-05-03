//
//  UserProfileHeader.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/3.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
class UserProfileHeader: UICollectionViewCell {
    var user: User?{
        didSet{
            setupProfileImage()
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        self.addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80/2
        profileImageView.clipsToBounds = true
        
        
        
    }
    fileprivate func setupProfileImage(){
        guard let profileImageUrl = user?.profileImageUrl else {return}
        guard let url = URL(string: profileImageUrl) else {return}
         URLSession.shared.dataTask(with: url) { (data, response, err) in
             guard let data = data else {return}
             if let err = err{
                 print("Failed to fetch profile image", err)
                 return
             }
             let image = UIImage(data: data)
             DispatchQueue.main.async {
                 self.profileImageView.image = image
             }
             
         }.resume()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
