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

class MainViewController: UIViewController {
    
    var currUser: User?
    fileprivate var createdCoinData = [Coin(name: "Ride", imageURL: "car", id: "0", amount: -1), Coin(name: "Gas", imageURL: "gas", id: "1", amount: -1), Coin(name: "Grocery", imageURL: "groceries", id: "2", amount: -1), Coin(name: "Dinner", imageURL: "dinner", id: "3", amount: -1), Coin(name: "Lawn Mower", imageURL: "lawn-mower", id: "4", amount: -1)]
    fileprivate var transactionData = [Transaction]()
    fileprivate var ownedByCoinData = [Coin]()
    
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
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "transCell")
        
        return tableView
    }()
    
    fileprivate let lineSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    fileprivate let exchangeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: nil)
        button.action = #selector(payOrRequest)
        return button
    }()

    @objc func payOrRequest() {
        let transferViewController = TransferViewController()
        transferViewController.createdCoinData = self.createdCoinData
        transferViewController.ownedByCoinData = self.ownedByCoinData
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        transferViewController.currUser = self.currUser
        navigationItem.backBarButtonItem = backItem
        self.navigationController?.pushViewController(transferViewController, animated: true)
    }
    
    @objc func coinsViewTapped() {
        let showCoinsVC = ShowCoinsViewController()
        showCoinsVC.createdCoinData = self.createdCoinData
        showCoinsVC.ownedByCoinData = self.ownedByCoinData
        self.navigationController?.pushViewController(showCoinsVC, animated: true)
    }
    
    fileprivate func fetchCoins(completion: @escaping () -> Void) {
        let userId = self.currUser?.id ?? ""
        self.createdCoinData = [Coin(name: "Ride", imageURL: "car", id: "\(userId)_0", amount: -1), Coin(name: "Gas", imageURL: "gas", id: "\(userId)_1", amount: -1), Coin(name: "Grocery", imageURL: "groceries", id: "\(userId)_2", amount: -1), Coin(name: "Dinner", imageURL: "dinner", id: "\(userId)_3", amount: -1), Coin(name: "Lawn Mower", imageURL: "lawn-mower", id: "\(userId)_4", amount: -1)]
        self.ownedByCoinData = [Coin]()
        
        FirebaseHelper.sharedInstance.fetchUserCoins(viewController: self) { (createdCoinsSnapshot, ownedByCoinsSnapshot) in
            for snap in createdCoinsSnapshot {
                let value = snap.value as? NSDictionary
                
                let name = value?["name"] as? String ?? ""
                let imageURL = value?["image"] as? String ?? ""
                let amount = value?["amount"] as? Int ?? -1
                
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
                let amount = value?["amount"] as? Int ?? -1
                
                let coin = Coin(name: name, imageURL: imageURL, id: snap.key, amount: amount)
                self.ownedByCoinData.append(coin)
            }
            
            self.coinsView.reloadData()
            completion()
        }
    }
    
    fileprivate func fetchTrans(completion: @escaping () -> Void) {
        self.transactionData = [Transaction]()
        
        FirebaseHelper.sharedInstance.fetchTransactions(viewController: self) { (snapshot) in
            for snap in snapshot {
                let value = snap.value as? NSDictionary
                
                let from = value?["from"] as? String ?? ""
                let fromImage = value?["fromImage"] as? String ?? ""
                let to = value?["to"] as? String ?? ""
                let message = value?["message"] as? String ?? ""
                let coinName = value?["coinName"] as? String ?? ""
                let coinImage = value?["coinImage"] as? String ?? ""
                let amount = value?["amount"] as? String ?? ""
                
                let transaction = Transaction(from: from, fromImage: fromImage, to: to, message: message, coinName: coinName, coinImage: coinImage, amount: amount)
                
                
                self.transactionData.append(transaction)
            }
            
            self.transactionView.reloadData()
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
            self.currUser = User(firstName: snapshotValue["firstName"] as? String ?? "", lastName: snapshotValue["lastName"] as? String ?? "", profileImage: snapshotValue["image"] as? String ?? "", id: userId)
            completion()
        }
    }
    
    fileprivate func fetchAllUserData() {
        self.fetchProfile() {
            self.fetchCoins() {
                self.fetchTrans() {
                    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "MyCoin"
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(payOrRequest))
        
        view.addSubview(coinsView)
        view.addSubview(transactionView)
        view.addSubview(lineSeparator)
        
        coinsView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        coinsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        coinsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        coinsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        coinsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coinsViewTapped)))
        
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
        
        self.fetchAllUserData()
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
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transCell", for: indexPath) as! TransactionTableViewCell
        
        cell.message = self.transactionData[indexPath.row].message
        cell.headerMessage = self.transactionData[indexPath.row].from + " paid " + self.transactionData[indexPath.row].to
        
        if self.transactionData[indexPath.row].fromImage == "" {
            cell.profileImageView.setImageForName(self.transactionData[indexPath.row].from, circular: true, textAttributes: nil, gradient: true)
        } else {
            cell.profileImageView.sd_setImage(with: URL(string: self.transactionData[indexPath.row].fromImage), completed: nil)
        }
        
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
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
