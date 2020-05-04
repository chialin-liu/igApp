//
//  MainTabBarController.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/3.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser == nil{
            DispatchQueue.main.async {
                let logincontroller = LoginController()
                let navController = UINavigationController(rootViewController: logincontroller)
                self.present(navController, animated: true, completion: nil)
            }
            
            return
        }
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        
        let navController = UINavigationController(rootViewController: userProfileController)
        navController.tabBarItem.image = UIImage(named: "profile_unselected")
        navController.tabBarItem.selectedImage = UIImage(named: "profile_selected")
        tabBar.tintColor = .black
        viewControllers = [navController, UIViewController()]
    }
}
