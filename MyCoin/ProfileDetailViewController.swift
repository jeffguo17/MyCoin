//
//  ProfileDetailViewController.swift
//  MyCoin
//
//  Created by jeff on 10/17/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import Firebase

class ProfileDetailViewController: UIViewController {

    var selectedUser: CoinUser?
    var createdCoinData = [Coin]()
    var ownedByCoinData = [Coin]()
    var currUser: User?
    fileprivate var transactionData = [Transaction]()
    
    fileprivate let profileImageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill
        return view
    }()
    
    fileprivate let nameTextView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = ""
        view.font = .systemFont(ofSize: 24)
        view.textColor = .black
        return view
    }()
    
    fileprivate let lineSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    fileprivate let payOrRequestButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Pay or Request", for: .normal)
        button.addTarget(self, action: #selector(payOrRequestTapped), for: .touchUpInside)
        button.backgroundColor = UIView().tintColor
        return button
    }()
    
    fileprivate let transactionView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "transCell")
        
        return tableView
    }()
    
    @objc func payOrRequestTapped() {
        guard let selectedUser = selectedUser else { return }
        
        let selectedPerson = RecentPerson(fullName: selectedUser.fullName, profileImage: selectedUser.profileImage, id: selectedUser.id)
        
        showPayOrRequestVC(createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: self.currUser, recipientPerson: selectedPerson, navigationController: self.navigationController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let index = self.transactionView.indexPathForSelectedRow {
            self.transactionView.deselectRow(at: index, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.flatBlack]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        self.title = selectedUser?.fullName
        
        view.addSubview(profileImageView)
        view.addSubview(nameTextView)
        view.addSubview(lineSeparator)
        view.addSubview(payOrRequestButton)
        view.addSubview(transactionView)
        
        let profileImageViewSize = CGFloat(120)
        
        if selectedUser?.profileImage == "" {
            profileImageView.setImageForName(selectedUser?.fullName ?? "A A", circular: true, textAttributes: nil, gradient: true)
        } else {
            profileImageView.sd_setImage(with: URL(string: self.selectedUser?.profileImage ?? ""), completed: nil)
        }
        
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        profileImageView.layer.cornerRadius = profileImageViewSize/2
        profileImageView.clipsToBounds = true
        
        nameTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10).isActive = true
        nameTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        nameTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        nameTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameTextView.textAlignment = .center
        nameTextView.text = selectedUser?.fullName
        
        lineSeparator.topAnchor.constraint(equalTo: nameTextView.bottomAnchor).isActive = true
        lineSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        viewLayoutIfCurrUser()
        
        transactionView.delegate = self
        transactionView.dataSource = self
        
        fetchRecentTransactions()
    }

    fileprivate func viewLayoutIfCurrUser() {
        guard let selectedUser = selectedUser, let currUser = currUser else { return }
        if selectedUser.id != currUser.id {
            payOrRequestButton.isHidden = true
            transactionView.topAnchor.constraint(equalTo: lineSeparator.bottomAnchor).isActive = true
        } else {
            payOrRequestButton.topAnchor.constraint(equalTo: lineSeparator.bottomAnchor, constant: 15).isActive = true
            payOrRequestButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
            payOrRequestButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
            payOrRequestButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            payOrRequestButton.layer.cornerRadius = 10
            
            transactionView.topAnchor.constraint(equalTo: payOrRequestButton.bottomAnchor, constant: 10).isActive = true
        }
        transactionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        transactionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        transactionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
    }
    
    fileprivate func fetchRecentTransactions() {
        guard let selectedUser = selectedUser else { return }
        FirebaseHelper.sharedInstance.fetchTransactions(withUserId: selectedUser.id) { (transactionData) in
            self.transactionData = transactionData
            self.transactionView.reloadData()
        }
    }
}

extension ProfileDetailViewController: UITableViewDelegate, UITableViewDataSource {
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
