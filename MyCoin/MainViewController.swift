//
//  MainViewController.swift
//  MyCoin
//
//  Created by jeff on 8/24/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import SDWebImage
import InitialsImageView
import FirebaseDatabase
import SideMenu

class MainViewController: SideMenuLogicViewController {
    
    var currUser: User?
    fileprivate var createdCoinData = [Coin(name: "Ride", imageURL: "car", id: "0", amount: -1), Coin(name: "Gas", imageURL: "gas", id: "1", amount: -1), Coin(name: "Grocery", imageURL: "groceries", id: "2", amount: -1), Coin(name: "Dinner", imageURL: "dinner", id: "3", amount: -1), Coin(name: "Lawn Mower", imageURL: "lawn-mower", id: "4", amount: -1)]
    var transactionData = [Transaction]()
    fileprivate var ownedByCoinData = [Coin]()
    fileprivate var recentPeopleData = [RecentPerson]()
    var transUpdate = false
    var leftMenuNavigationController: SideMenuNavigationController?
    
    fileprivate let coinsView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.register(CoinViewCell.self, forCellWithReuseIdentifier: "coinsCell")
        
        return collectionView
    }()
    
    fileprivate let transactionView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "transCell")
        
        return tableView
    }()
    
    fileprivate let lineSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    @objc fileprivate func showSideMenu() {
        if let leftMenuNavigationController = self.leftMenuNavigationController {
            present(leftMenuNavigationController, animated: true, completion: nil)
        }
    }
    
    fileprivate func addNavigationBarItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(payOrRequest))
        
        let btnShowMenu = UIButton(type: .system)
        btnShowMenu.setImage(drawHamburgerIcon(), for: UIControl.State())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 22, height: 25)
        btnShowMenu.addTarget(self, action: #selector(showSideMenu), for: .touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
    
    @objc func payOrRequest() {
        let transferViewController = TransferViewController()
        transferViewController.createdCoinData = self.createdCoinData
        transferViewController.ownedByCoinData = self.ownedByCoinData
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        transferViewController.currUser = self.currUser
        transferViewController.recentPeopleData = self.recentPeopleData
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(transferViewController, animated: true)
    }
    
    @objc func coinsViewTapped() {
        let showCoinsVC = ShowCoinsViewController()
        showCoinsVC.createdCoinData = self.createdCoinData
        showCoinsVC.ownedByCoinData = self.ownedByCoinData
        showCoinsVC.currUser = self.currUser
        showCoinsVC.leftMenuNavigationController = self.leftMenuNavigationController
        self.navigationController?.pushViewController(showCoinsVC, animated: true)
    }
    
    fileprivate func fetchCoins(completion: @escaping () -> Void) {
        let userId = self.currUser?.id ?? ""
        self.createdCoinData = [Coin(name: "Ride", imageURL: "car", id: "\(userId)_0", amount: -1), Coin(name: "Gas", imageURL: "gas", id: "\(userId)_1", amount: -1), Coin(name: "Grocery", imageURL: "groceries", id: "\(userId)_2", amount: -1), Coin(name: "Dinner", imageURL: "dinner", id: "\(userId)_3", amount: -1), Coin(name: "Lawn Mower", imageURL: "lawn-mower", id: "\(userId)_4", amount: -1)]
        self.ownedByCoinData = [Coin]()
        
        FirebaseHelper.sharedInstance.fetchUserCoins(viewController: self) { (createdCoinsSnapshot, ownedByCoinsSnapshot) in
            for snap in createdCoinsSnapshot {
                /*
                if snap.key.contains(userId) {
                    let coinId = snap.key.replacingOccurrences(of: "\(userId)_", with: "")
                    if let coinIdNum = Int(coinId) {
                        self.createdCoinData[coinIdNum].id = snap.key
                        print(self.createdCoinData[coinIdNum].id)
                    }
                }
                */
                let value = snap.value as? NSDictionary
                
                let name = value?["name"] as? String ?? ""
                let imageURL = value?["image"] as? String ?? ""
                
                var amount = -1.0
                if let amountStr = value?["amount"] as? String {
                    amount = Double(amountStr) ?? -1.0
                }
                
                let coin = Coin(name: name, imageURL: imageURL, id: snap.key, amount: amount)
                self.createdCoinData.append(coin)
            }
            
            if self.createdCoinData.count == 5 {
                self.createdCoinData.append(Coin(name: "", imageURL: "addCoin", id: "", amount: -1))
            }
            
            for snap in ownedByCoinsSnapshot {
                let value = snap.value as? NSDictionary
                
                let name = value?["name"] as? String ?? ""
                let imageURL = value?["image"] as? String ?? ""
                
                var amount = -1.0
                if let amountStr = value?["amount"] as? String {
                    amount = Double(amountStr) ?? -1.0
                }
                let coin = Coin(name: name, imageURL: imageURL, id: snap.key, amount: amount)
                self.ownedByCoinData.append(coin)
            }
            
            self.coinsView.reloadData()
            completion()
        }
    }
    
    func fetchTrans(completion: @escaping () -> Void) {
        self.transactionData = [Transaction]()
        
        FirebaseHelper.sharedInstance.fetchTransactions(viewController: self) { (snapshot) in
            for snap in snapshot {
                if let value = snap.value as? NSDictionary {
                    self.transactionData.append(parseTransactionSnapshot(value: value, transId: snap.key))
                }
            }
            
            self.transactionView.reloadData()
            completion()
        }
    }
    
    fileprivate func fetchProfile(completion: @escaping () -> Void) {
        FirebaseHelper.sharedInstance.fetchUserProfile(viewController: self) { (snapshot, userId) in
            
            if !snapshot.exists() {
                //New Profile
                self.navigationController?.pushViewController(NewProfileViewController(), animated: true)
                return
            }
            let snapshotValue = snapshot.value as! [String: Any]
            self.currUser = User(firstName: snapshotValue["firstName"] as? String ?? "", lastName: snapshotValue["lastName"] as? String ?? "", profileImage: snapshotValue["image"] as? String ?? "", id: userId, phoneNumber: snapshotValue["phoneNumber"] as? String ?? "")
            completion()
        }
    }
    
    fileprivate func fetchRecentPeople(completion: @escaping () -> Void) {
        self.recentPeopleData = [RecentPerson]()
        FirebaseHelper.sharedInstance.fetchRecentPeople { (snapshot) in
            for snap in snapshot {
                let value = snap.value as? NSDictionary
                
                let fullName = value?["name"] as? String ?? ""
                let profileImage = value?["image"] as? String ?? ""
                
                let recentPerson = RecentPerson(fullName: fullName, profileImage: profileImage, id: snap.key)
                self.recentPeopleData.append(recentPerson)
            }
            completion()
        }
    }
    
    fileprivate func fetchAllUserData(completion: @escaping () -> Void) {
        self.fetchProfile() {
            self.fetchRecentPeople() {
                self.fetchCoins() {
                    self.fetchTrans() {
                        completion()
                    }
                }
            }
        }
    }
    
    fileprivate func scrollToLastItemCoinViews() {
        let lastItemIndex = self.coinsView.numberOfItems(inSection: 0) - 1
        let indexPath:IndexPath = IndexPath(item: lastItemIndex, section: 0)
        self.coinsView.scrollToItem(at: indexPath, at: .right, animated: false)
    }
    
    func addNewCoin(coin: Coin) {
        if self.createdCoinData.last?.imageURL == "addCoin" {
            _ = self.createdCoinData.popLast()
        }
        
        self.createdCoinData.append(coin)
        self.coinsView.reloadData()
        self.scrollToLastItemCoinViews()
        self.updateSideMenuTotalNumCoins()
    }
    
    fileprivate func updateMainVC(completion: @escaping () -> Void) {
        self.fetchRecentPeople() {
            self.fetchCoins() {
                self.fetchTrans() {
                    self.updateSideMenuTotalNumCoins()
                    completion()
                }
            }
        }
    }
    
    fileprivate func updateSideMenuTotalNumCoins() {
        if let leftMenuNavigationController = self.leftMenuNavigationController {
            if let sideMenuVC = leftMenuNavigationController.viewControllers.first as? SideMenuViewController {
                sideMenuVC.updateTotalNumCoins(totalNumCoins: self.createdCoinData.count + self.ownedByCoinData.count)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
        if transUpdate {
            self.updateMainVC() {
                self.transactionView.scrollToTop()
                self.transUpdate = false
            }
        }
        
        if let index = self.transactionView.indexPathForSelectedRow {
            self.transactionView.deselectRow(at: index, animated: true)
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "MyCoin"
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
        
        addNavigationBarItems()
        
        view.addSubview(coinsView)
        view.addSubview(transactionView)
        view.addSubview(lineSeparator)
        
        coinsView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        coinsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        coinsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        coinsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        //coinsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coinsViewTapped)))
        
        coinsView.delegate = self
        coinsView.dataSource = self
        
        lineSeparator.topAnchor.constraint(equalTo: coinsView.bottomAnchor).isActive = true
        lineSeparator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lineSeparator.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.6).isActive = true
        lineSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        transactionView.topAnchor.constraint(equalTo: lineSeparator.bottomAnchor, constant: 10).isActive = true
        transactionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        transactionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        transactionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        transactionView.delegate = self
        transactionView.dataSource = self
        
        self.fetchAllUserData() {
            self.setupSideMenu()
        }
    }
    
    fileprivate func setupSideMenu() {
        // Define the menus
        guard let currUser = self.currUser else { return }
        
        let sideMenuVC = SideMenuViewController()
        sideMenuVC.delegate = self
        sideMenuVC.profileImageURL = currUser.profileImage
        sideMenuVC.userFullName = FirebaseHelper.sharedInstance.getPrettyName(firstName: currUser.firstName, lastName: currUser.lastName)
        sideMenuVC.totalNumCoins = self.createdCoinData.count + self.ownedByCoinData.count
        
        self.leftMenuNavigationController = SideMenuNavigationController(rootViewController: sideMenuVC)
        
        var settings = SideMenuSettings()
        settings.presentationStyle = .menuSlideIn
        settings.statusBarEndAlpha = 0
        settings.menuWidth = UIScreen.main.bounds.width * 0.75
        
        self.leftMenuNavigationController!.leftSide = true
        self.leftMenuNavigationController!.isNavigationBarHidden = true
        self.leftMenuNavigationController!.settings = settings
        
        SideMenuManager.default.leftMenuNavigationController = leftMenuNavigationController
        
        // Setup gestures: the left and/or right menus must be set up (above) for these to work.
        // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: self.navigationController!.view, forMenu: .left)
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 55 , height: 55)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.createdCoinData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "coinsCell", for: indexPath) as! CoinViewCell
        
        if self.createdCoinData[indexPath.row].imageURL.isEmpty {
            cell.coinImage = #imageLiteral(resourceName: "exchange")
        } else if self.createdCoinData[indexPath.row].imageURL.prefix(4) != "http" {
            cell.coinImage = #imageLiteral(resourceName: self.createdCoinData[indexPath.row].imageURL)
        } else {
            cell.coinImageView.sd_setImage(with: URL(string: self.createdCoinData[indexPath.row].imageURL), placeholderImage: #imageLiteral(resourceName: "exchange"))
        }
        
        cell.backgroundColor = .white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let showCoinDetailsVC = ShowCoinDetailsViewController()
        showCoinDetailsVC.currCoin = self.createdCoinData[indexPath.row]
        showCoinDetailsVC.currUser = self.currUser
        showCoinDetailsVC.createdCoinData = self.createdCoinData
        showCoinDetailsVC.ownedByCoinData = self.ownedByCoinData
        self.navigationController?.pushViewController(showCoinDetailsVC, animated: true)
    }
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transCell", for: indexPath) as! TransactionTableViewCell
        
        guard let fromUser = self.transactionData[indexPath.row].from.first, let toUser = self.transactionData[indexPath.row].to.first else { return cell }
        
        cell.message = self.transactionData[indexPath.row].message
        cell.sender = fromUser
        cell.recipient = toUser
        cell.createdCoinData = self.createdCoinData
        cell.ownedByCoinData = self.ownedByCoinData
        cell.currUser = self.currUser
        cell.navigationController = self.navigationController
        cell.timeStampString = self.transactionData[indexPath.row].timeStamp.timeAgoDisplay()
        
        if fromUser.profileImage == "" {
            cell.profileImageView.setImageForName(fromUser.fullName, circular: true, textAttributes: nil, gradient: true)
        } else {
            cell.profileImageView.sd_setImage(with: URL(string: fromUser.profileImage), completed: nil)
        }
        
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let fromUser = self.transactionData[indexPath.row].from.first, let toUser = self.transactionData[indexPath.row].to.first else { return }
        
        let transactionDetailVC = TransactionDetailViewController()
        transactionDetailVC.sender = fromUser
        transactionDetailVC.currUser = self.currUser
        transactionDetailVC.recipient = toUser
        transactionDetailVC.createdCoinData = self.createdCoinData
        transactionDetailVC.ownedByCoinData = self.ownedByCoinData
        transactionDetailVC.message = self.transactionData[indexPath.row].message
        transactionDetailVC.transId = self.transactionData[indexPath.row].id
        transactionDetailVC.timeStampString = self.transactionData[indexPath.row].timeStamp.timeAgoDisplay()
        transactionDetailVC.coinImageURL = self.transactionData[indexPath.row].coinImage
        transactionDetailVC.transAmount = self.transactionData[indexPath.row].amount
        transactionDetailVC.commentUsersRef = Database.database().reference().child("trans").child(self.transactionData[indexPath.row].id).child("comments")
        self.navigationController?.pushViewController(transactionDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
}

extension MainViewController: SideMenuViewControllerDelegate {
    
    fileprivate func dismissSideMenu(finishedDismissing: @escaping () -> Void) {
        guard let leftMenuNavigationController = self.leftMenuNavigationController else { return }
        
        if self.navigationController?.presentedViewController is SideMenuNavigationController {
            leftMenuNavigationController.dismiss(animated: true) {
                finishedDismissing()
            }
        }
    }
    
    func homePressed() {
        self.dismissSideMenu {
            let lastVC = self.getLastVC()
            
            if lastVC is MainViewController {
                self.updateMainVC {}
            } else if lastVC != nil {
                self.navigationController?.popViewController(animated: true)
                self.updateMainVC {}
            }
        }
    }
    
    func coinsPressed() {
        self.dismissSideMenu {
            let lastVC = self.getLastVC()
            
            if !(lastVC is ShowCoinsViewController) {
                self.navigationController?.popViewController(animated: false)
                self.coinsViewTapped()
            }
        }
    }
    
    func purchasesPressed() {
        self.dismissSideMenu {
            let lastVC = self.getLastVC()
            if let lastVC = lastVC, !lastVC.isMember(of: PurchasesViewController.self) {
                self.navigationController?.popViewController(animated: false)
                
                let purchasesVC = PurchasesViewController()
                purchasesVC.titleText = "Purchases"
                purchasesVC.createdCoinData = self.createdCoinData
                purchasesVC.ownedByCoinData = self.ownedByCoinData
                purchasesVC.currUser = self.currUser
                purchasesVC.headerTextView.text = "COMPLETED PURCHASES"
                purchasesVC.leftMenuNavigationController = self.leftMenuNavigationController
                self.navigationController?.pushViewController(purchasesVC, animated: true)
            }
        }
    }
    
    func receivesPressed() {
        self.dismissSideMenu {
            let lastVC = self.getLastVC()
            
            if !(lastVC is ReceivesViewController) {
                self.navigationController?.popViewController(animated: false)
                
                let receivesVC = ReceivesViewController()
                receivesVC.titleText = "Receives"
                receivesVC.createdCoinData = self.createdCoinData
                receivesVC.ownedByCoinData = self.ownedByCoinData
                receivesVC.currUser = self.currUser
                receivesVC.headerTextView.text = "COMPLETED RECEIVES"
                receivesVC.leftMenuNavigationController = self.leftMenuNavigationController
                self.navigationController?.pushViewController(receivesVC, animated: true)
            }
        }
    }
    
    func notificationsPressed() {
        self.dismissSideMenu {
            let lastVC = self.getLastVC()
            
            if !(lastVC is NotificationViewController) {
                self.navigationController?.popViewController(animated: false)
                
                let notificationVC = NotificationViewController()
                notificationVC.leftMenuNavigationController = self.leftMenuNavigationController
                self.navigationController?.pushViewController(notificationVC, animated: true)
            }
        }
    }
    
    func incompletePressed() {
        self.dismissSideMenu {
            showAlertMessage(title: "Coming Soon", message: "", actionMessage: "OK", navigationController: self.navigationController)
        }
    }
}

class CoinViewCell: UICollectionViewCell {

    var coinImage: UIImage?
    
    fileprivate let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.addSubview(coinImageView)
        
        let coinImageSize = CGFloat(45)
        
        coinImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        coinImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        coinImageView.widthAnchor.constraint(equalToConstant: coinImageSize).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: coinImageSize).isActive = true
        coinImageView.layer.cornerRadius = coinImageSize/3
        coinImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.coinImageView.sd_cancelCurrentImageLoad()
        self.coinImageView.image = nil
        self.coinImage = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let coinImage = coinImage {
            coinImageView.image = coinImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
