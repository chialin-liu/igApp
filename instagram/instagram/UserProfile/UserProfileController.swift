//
//  UserProfileController.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/3.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    var isGridView = true
    func didChangeToListView() {
        isGridView = false
        collectionView.reloadData()
    }
    
    func didChangeToGridView() {
        isGridView = true
        collectionView.reloadData()
    }
    
    var user: User?
    let cellId = "cellId"
    var posts = [Post]()
    var userId: String?
    let userProfileGridCellId = "UserProfileGridCellId"
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .white
        
        collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView.register(UserProfileGridCell.self, forCellWithReuseIdentifier: userProfileGridCellId)
        setupLogOutButton()
        fetchUser()
        
    }
    var isFinishedPaging = false
    func paginatePosts() {
        guard let uid = user?.uid else { return }
        print("User id", uid)
        let ref = Database.database().reference().child("posts").child(uid)
        var query = ref.queryOrdered(byChild: "creationDate")
        if posts.count > 0 {
            let value = posts.last?.creationDate.timeIntervalSince1970
            query = query.queryEnding(atValue: value)
        }
        query.queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
            guard var allOjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
            allOjects.reverse()
            if allOjects.count < 4 {
                self.isFinishedPaging = true
            }
            if self.posts.count > 0 && allOjects.count > 0 {
                allOjects.removeFirst()
            }
            guard let user = self.user else { return }
            for obj in allOjects {
                guard let dictionary = obj.value as? [String: Any] else { return }
                var post = Post(user: user, dictionary: dictionary)
                post.id = obj.key
                self.posts.append(post)
            }
            self.collectionView.reloadData()
        }
    }
    fileprivate func fetchOrderedPosts(){
        guard let uid = self.user?.uid else {return}
        let ref = Database.database().reference().child("posts").child(uid)
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            guard let user = self.user else {return}
            let post = Post(user: user, dictionary: dictionary)
            self.posts.insert(post, at: 0)
            self.collectionView.reloadData()
        }) { (err) in
            print("Failed to fetch posts", err)
        }
    }
    fileprivate func setupLogOutButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "gear")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    @objc func handleLogOut(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do{
                try Auth.auth().signOut()
                let logincontroller = LoginController()
                let navController = UINavigationController(rootViewController: logincontroller)
                self.present(navController, animated: true, completion: nil)
            }catch let signOuErr{
                print("Failed to sign out", signOuErr)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == posts.count - 1 && !isFinishedPaging {
            paginatePosts()
        }
        if isGridView{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? UserProfilePhotoCell else {return UICollectionViewCell()}
            cell.post = posts[indexPath.item]
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: userProfileGridCellId, for: indexPath) as? UserProfileGridCell else {return UICollectionViewCell()}
            cell.post = posts[indexPath.item]
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isGridView{
            let width = (view.frame.width - 2)/3
            return CGSize(width: width, height: width)
        }
        else{
            var height: CGFloat = 40 + 8 + 8 + view.frame.width
            height += 50
            height += 60
            return CGSize(width: view.frame.width, height: height)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as? UserProfileHeader
        header?.user = self.user
        header?.delegate = self
        if let header = header{
            return header
        }
        return UICollectionReusableView()
    }
    fileprivate func fetchUser(){
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
//        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            self.collectionView.reloadData()
//            self.fetchOrderedPosts()
            self.paginatePosts()
        }
    }
}

