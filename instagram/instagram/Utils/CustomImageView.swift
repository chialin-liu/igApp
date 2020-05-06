//
//  CustomImageView.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/6.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import Foundation
import UIKit
var imageCache = [String: UIImage]()
class CustomImageView: UIImageView {
    var lastURLUsedToLoadImage: String?
    func loadImage(urlString: String){
        lastURLUsedToLoadImage = urlString
        if let cachedImage = imageCache[urlString]{
            self.image = cachedImage
            return
        }
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err{
                print("Failed to catch imageUrl", err)
            }
            //begin Purpose: to prevent images loading incorrectly
            if url.absoluteString != self.lastURLUsedToLoadImage{
                return
            }
            //end
            guard let data = data else {return}
            let image = UIImage(data: data)
            imageCache[url.absoluteString] = image
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
