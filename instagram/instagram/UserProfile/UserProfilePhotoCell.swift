//
//  UserProfilePhotoCell.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/6.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import Foundation
import UIKit
class UserProfilePhotoCell: UICollectionViewCell {
    var post: Post?{
        didSet{
            print(post?.imageUrl ?? "")
            guard let imageUrl = post?.imageUrl else {return}
            guard let url = URL(string: imageUrl) else {return}
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                if let err = err{
                    print("Failed to catch imageUrl", err)
                }
                guard let data = data else {return}
                let image = UIImage(data: data)
                DispatchQueue.main.async {
                    self.photoImageView.image = image
                }
            }.resume()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(photoImageView)
        photoImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    let photoImageView: UIImageView = {
        let iv = UIImageView()
//        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
