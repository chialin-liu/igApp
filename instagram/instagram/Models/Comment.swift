//
//  Comment.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/8.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import Foundation
import UIKit
struct Comment {
    let text: String
    let uid: String
    let user: User
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
    }
}
