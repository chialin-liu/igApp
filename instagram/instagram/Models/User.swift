//
//  User.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/6.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import Foundation
struct User{
    let uid: String
    let username: String
    let profileImageUrl: String
    init(uid: String, dictionary: [String: Any]){
        self.uid = uid
        self.username = dictionary["username"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
}
