//
//  ViewController.swift
//  FakeAPICallTests
//
//  Created by Giwon Seo on 2023/03/18.
//

import UIKit
import Combine

class ViewController: UIViewController {

    @IBOutlet weak var friendsListView: UICollectionView!
    @IBOutlet weak var strangersListView: UICollectionView!
    
    @IBOutlet weak var checkImageView: UIImageView!
    @IBOutlet weak var numOfToggleTaskLabel: UILabel!
    private var numOfOngoingToggleTask: Int = 0 {
        didSet {
            numOfToggleTaskLabel.text = "\(numOfOngoingToggleTask)"
        }
    }
    
    
    private var friendsListDataSource: UICollectionViewDiffableDataSource<Int, User>!
    private var strangersListDataSource: UICollectionViewDiffableDataSource<Int, User>!
    private var users = [User]() {
        didSet {
            updateSnapshot(isAnimated: true)
        }
    }
    
    var friendlyUsers: [User] {
        return users.filter({$0.isFriend == true})
    }
    
    var strangers: [User] {
        return users.filter({$0.isFriend == false})
    }
    
    private var userController = UserController()
    
    private var subscriptions = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureDataSource()
        friendsListView.collectionViewLayout = createLayout()
        strangersListView.collectionViewLayout = createLayout()
        
        // connect chain
        userController.getAllUsersOutput
            .assign(to: \.users, on: self)
            .store(in: &subscriptions)
        
        userController.postToggleUsersOutput
            .sink { completion in
                
            } receiveValue: { [weak self] value in
                
                self?.numOfOngoingToggleTask -= 1
                
                print("toggle failure")
                self?.userController.getAllUsers()

            }
            .store(in: &subscriptions)
        
        // ask data source
        userController.getAllUsers()
        
        // run updateServerAppDataMatchStatus
        let timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(updateServerAppDataMatchStatus), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    private func configureDataSource() {
        
        friendsListDataSource = UICollectionViewDiffableDataSource<Int, User>.init(collectionView: friendsListView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
            cell.configure(userInfo: self.friendlyUsers[indexPath.item])
            
            return cell
        })
        
        strangersListDataSource = UICollectionViewDiffableDataSource<Int, User>.init(collectionView: strangersListView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserInfoCell", for: indexPath) as! UserInfoCell
            cell.configure(userInfo: self.strangers[indexPath.item])
            
            return cell
        })

        // initial data snapshot
        updateSnapshot(isAnimated: false)
    }
    
    private func updateSnapshot(isAnimated: Bool) {
        
        func snapshot(users: [User]) -> NSDiffableDataSourceSnapshot<Int, User> {
            var snapshot = NSDiffableDataSourceSnapshot<Int, User>()
            snapshot.appendSections([0])
            snapshot.appendItems(users)
            return snapshot
        }
        
        let friendlySnapshot = snapshot(users: friendlyUsers)
        let strangersSnapshot = snapshot(users: strangers)
        
        friendsListDataSource.apply(friendlySnapshot, animatingDifferences: isAnimated) {
            self.friendsListView.reloadData()
        }
        
        strangersListDataSource.apply(strangersSnapshot, animatingDifferences: isAnimated) {
            self.strangersListView.reloadData()
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(0.25))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                         subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
        
    }
    
    @objc private func updateServerAppDataMatchStatus() {
        // match data between server and app for comparison
        var isValid = true
        
        for relationship in DataStorage.shared.contacts.relationships {
            
            if let user = users.first(where: {$0.id == relationship.id}),
                user.isFriend == relationship.isFriend {
                continue
            }
            
            isValid = false
        }
        
        if isValid == true {
            checkImageView.image = UIImage.init(named: "Check.png")
        } else {
            checkImageView.image = UIImage.init(named: "No.png")
        }
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // toggle befriend
        if collectionView === friendsListView {
            
            let userId = friendlyUsers[indexPath.row].id
            userController.toggleUserBeingFriend(id: userId)
            
            // update data source first assuing that the api call succeeds
            // if api call ends up failure, revert it
            toggleUser(id: userId)
            
        } else if collectionView === strangersListView {
            
            let strangersId = strangers[indexPath.row].id
            userController.toggleUserBeingFriend(id: strangersId)
            
            // update data source first assuing that the api call succeeds
            // if api call ends up failure, revert it
            toggleUser(id: strangersId)
        }
    }
    
    private func toggleUser(id: String) {
        if let index = users.firstIndex(where: {$0.id == id}) {
            users[index].isFriend.toggle()
            
            numOfOngoingToggleTask += 1
        }
    }
}
