//
//  HomeController.swift
//  instagram
//
//  Created by Chialin Liu on 2020/5/6.
//  Copyright © 2020 Chialin Liu. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    
    let cellId = "cellId"
    var posts = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhotoController.updateFeedNotificationName, object: nil)
        collectionView.backgroundColor = .white
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        setupNavigationItems()
        handleAllPosts()
    }
    @objc fileprivate func handleUpdateFeed(){
        handleRefresh()
    }
    @objc fileprivate func handleRefresh(){
        print("Refreshing...")
        posts.removeAll()
        handleAllPosts()
    }
    fileprivate func handleAllPosts(){
        fetchPosts()
        fetchFollowingUserIds()
    }
    fileprivate func fetchFollowingUserIds(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let userIdsDictionary = snapshot.value as? [String: Any] else{ return }
            for(key, _) in userIdsDictionary{
                Database.fetchUserWithUID(uid: key) { (user) in
                    self.fetchPostsWithUser(user: user)
                }
            }
            
            
        }) { (err) in
            print("Failed to fetch followers", err)
        }
    }
    func setupNavigationItems(){
        navigationController?.navigationBar.barTintColor = .lightGray
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "camera3")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
    }
    @objc fileprivate func handleCamera(){
        let cameraController = CameraController()
        cameraController.modalPresentationStyle = .fullScreen
//        navigationController?.pushViewController(cameraController, animated: true)
        present(cameraController, animated: true, completion: nil)
    }
    fileprivate func fetchPosts(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostsWithUser(user: user)
        }
        
    }
    fileprivate func fetchPostsWithUser(user: User){
        let ref = Database.database().reference().child("posts").child(user.uid)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            self.collectionView.refreshControl?.endRefreshing()
            guard let dictionaries = snapshot.value as? [String: Any] else {
                return
            }
            for (key, value) in dictionaries{
                guard let dictionary = value as? [String: Any] else {return}
                var post = Post(user: user, dictionary: dictionary)
                post.id = key
                guard let uid = Auth.auth().currentUser?.uid else {return}
                Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let value = snapshot.value as? Int, value == 1{
                        post.hasLiked = true
                    }else{
                        post.hasLiked = false
                    }
                    self.posts.append(post)
                    self.posts.sort { (p1, p2) -> Bool in
                        return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                    }
                    self.collectionView.reloadData()
                }) { (err) in
                    print("Failed ", err)
                }
                
                
            }
            
            
        }) { (err) in
            
                print("Failed to fetch posts", err)
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 40 + 8 + 8 + view.frame.width
            height += 50
            height += 60
        return CGSize(width: view.frame.width, height: height)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? HomePostCell else {return UICollectionViewCell()}
        if indexPath.item < posts.count {
            cell.post = posts[indexPath.item]
        }
        cell.delegate = self
        return cell
    }
    func didTapComment(post: Post) {
        print("Message from homeVC")
        print(post.caption)
        let commentController = CommentController(collectionViewLayout: UICollectionViewFlowLayout())
        commentController.post = post
        navigationController?.pushViewController(commentController, animated: true)
//        present(commentController, animated: true, completion: nil)
    }
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {return}
        var post = self.posts[indexPath.item]
        print(post.caption)
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let values = [uid: post.hasLiked == true ? 0: 1]
        guard let postId = post.id else {return}
        Database.database().reference().child("likes").child(postId).updateChildValues(values) { (err, ref) in
            if let err = err{
                print("Failed to like posts", err)
                return
            }
            print("Successfully like posts")
            post.hasLiked = !post.hasLiked
            self.posts[indexPath.item] = post
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
}
