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
class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        if index == 2{
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let navController = UINavigationController(rootViewController: photoSelectorController)
            present(navController, animated: true, completion: nil)
            return false
        }
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        if Auth.auth().currentUser == nil{
            DispatchQueue.main.async {
                let logincontroller = LoginController()
                let navController = UINavigationController(rootViewController: logincontroller)
                self.present(navController, animated: true, completion: nil)
            }
            
            return
        }
        setupViewControllers()

    }
    func setupViewControllers(){
        //home
        let homeNavController = templateNavController(unselectedImage: UIImage(named: "home_unselected") ?? UIImage(), selectedImage: UIImage(named: "home_selected") ?? UIImage(), rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        //search
        let searchNavController = templateNavController(unselectedImage: UIImage(named: "search_unselected") ?? UIImage(), selectedImage: UIImage(named: "search_selected") ?? UIImage())
        //plus
        let plusNavController = templateNavController(unselectedImage: UIImage(named: "plus_unselected") ?? UIImage(), selectedImage: UIImage(named: "plus_unselected") ?? UIImage())
        //like
        let likeNavController = templateNavController(unselectedImage: UIImage(named: "like_unselected") ?? UIImage(), selectedImage: UIImage(named: "like_selected") ?? UIImage())
        //user profile
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        
        let userProfileNavController = UINavigationController(rootViewController: userProfileController)
        userProfileNavController.tabBarItem.image = UIImage(named: "profile_unselected")
        userProfileNavController.tabBarItem.selectedImage = UIImage(named: "profile_selected")
        tabBar.tintColor = .black
        viewControllers = [homeNavController,
                           searchNavController,
                           plusNavController,
                           likeNavController,
                           userProfileNavController]
        guard let items = tabBar.items else {return}
        for item in items{
            item.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController{
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
}
