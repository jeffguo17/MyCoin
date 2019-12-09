//
//  ShowCoinDetailsViewController.swift
//  MyCoin
//
//  Created by jeff on 9/10/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import InitialsImageView

class ShowCoinDetailsViewController: UIViewController {

    var currCoin: Coin?
    var createdByUsers = [CoinUser]()
    var ownedByUsers = [CoinUser]()
    var usersData = [[CoinUser]]()
    var currUser: User?
    var createdCoinData = [Coin]()
    var ownedByCoinData = [Coin]()
    
    let ownershipCellId = "ownershipCell"
    
    fileprivate let coinImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleToFill
        return view
    }()
    
    fileprivate let nameTextView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = ""
        view.font = .systemFont(ofSize: 20)
        view.textColor = UIColor.black
        view.textContainer.maximumNumberOfLines = 1
        view.textContainer.lineBreakMode = .byTruncatingTail
        return view
    }()
    
    fileprivate let createrTextView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = ""
        view.font = .systemFont(ofSize: 8)
        view.textColor = UIColor.white
        view.textContainer.maximumNumberOfLines = 1
        view.textAlignment = .right
        view.textContainer.lineBreakMode = .byTruncatingTail
        return view
    }()
    
    fileprivate let paymentTextView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "\nPayment"
        view.font = .systemFont(ofSize: 17)
        view.textColor = .lightGray
        view.textContainer.maximumNumberOfLines = 2
        view.textAlignment = .center
        return view
    }()
    
    fileprivate let userTextView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "\nUser"
        view.font = .systemFont(ofSize: 17)
        view.textColor = .lightGray
        view.textContainer.maximumNumberOfLines = 2
        view.textAlignment = .center
        view.textContainer.lineBreakMode = .byTruncatingTail
        return view
    }()
    
    fileprivate let amountTextView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "\nAmount"
        view.font = .systemFont(ofSize: 17)
        view.textColor = .lightGray
        view.textContainer.maximumNumberOfLines = 2
        view.textAlignment = .center
        return view
    }()
    
    fileprivate let lineSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    fileprivate let ownershipTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        
        return tableView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        if let index = self.ownershipTableView.indexPathForSelectedRow {
            self.ownershipTableView.deselectRow(at: index, animated: true)
        }
    
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.orange]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        // Do any additional setup after loading the view.
        view.addSubview(coinImageView)
        view.addSubview(nameTextView)
        view.addSubview(lineSeparator)
        view.addSubview(ownershipTableView)
        view.addSubview(paymentTextView)
        view.addSubview(userTextView)
        view.addSubview(createrTextView)
        view.addSubview(amountTextView)
        
        guard let currCoin = self.currCoin else { return }
        
        self.title = formatAmountToStr(amount: currCoin.amount)
        
        if currCoin.imageURL.isEmpty {
            coinImageView.image = #imageLiteral(resourceName: "exchange")
        } else if currCoin.imageURL.prefix(4) != "http" {
            coinImageView.image = #imageLiteral(resourceName: currCoin.imageURL)
        } else {
            coinImageView.sd_setImage(with: URL(string: currCoin.imageURL), placeholderImage: #imageLiteral(resourceName: "exchange"))
        }
        
        let coinImageViewSize = CGFloat(100)
        
        coinImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        coinImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: coinImageViewSize).isActive = true
        coinImageView.widthAnchor.constraint(equalToConstant: coinImageViewSize).isActive = true
        coinImageView.layer.cornerRadius = coinImageViewSize/3
        coinImageView.clipsToBounds = true
        
        createrTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        createrTextView.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor).isActive = true
        createrTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        createrTextView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        nameTextView.topAnchor.constraint(equalTo: coinImageView.bottomAnchor).isActive = true
        nameTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        nameTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        nameTextView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        nameTextView.textAlignment = .center
        nameTextView.text = currCoin.name
        
        userTextView.topAnchor.constraint(equalTo: nameTextView.bottomAnchor).isActive = true
        userTextView.centerXAnchor.constraint(equalTo: coinImageView.centerXAnchor).isActive = true
        userTextView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        userTextView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        userTextView.text = "1\nUser"
        
        paymentTextView.topAnchor.constraint(equalTo: userTextView.topAnchor).isActive = true
        paymentTextView.widthAnchor.constraint(equalTo: userTextView.widthAnchor).isActive = true
        paymentTextView.heightAnchor.constraint(equalTo: userTextView.heightAnchor).isActive = true
        paymentTextView.trailingAnchor.constraint(equalTo: userTextView.leadingAnchor, constant: 15).isActive = true
        paymentTextView.text = "0\nPayment"
        
        amountTextView.topAnchor.constraint(equalTo: userTextView.topAnchor).isActive = true
        amountTextView.widthAnchor.constraint(equalTo: userTextView.widthAnchor).isActive = true
        amountTextView.heightAnchor.constraint(equalTo: userTextView.heightAnchor).isActive = true
        amountTextView.leadingAnchor.constraint(equalTo: userTextView.trailingAnchor, constant: -15).isActive = true
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let amountNumString = NSMutableAttributedString(string: "∞", attributes: [.paragraphStyle: paragraph])
        
        amountNumString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, amountNumString.length))
        amountNumString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, amountNumString.length))
        
        let amountWordString = NSMutableAttributedString(string: "\nAmount", attributes: [.paragraphStyle: paragraph])
        amountWordString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, amountWordString.length))
        amountWordString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSMakeRange(0, amountWordString.length))
        
        amountNumString.append(amountWordString)
        
        amountTextView.attributedText = amountNumString
        
        lineSeparator.topAnchor.constraint(equalTo: paymentTextView.bottomAnchor).isActive = true
        lineSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        ownershipTableView.topAnchor.constraint(equalTo: lineSeparator.bottomAnchor).isActive = true
        ownershipTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        ownershipTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        ownershipTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        ownershipTableView.register(ShowRecipientTableViewCell.self, forCellReuseIdentifier: ownershipCellId)
        ownershipTableView.dataSource = self
        ownershipTableView.delegate = self
        
        self.fetchCurrCoin()
    }

    override func willMove(toParent parent: UIViewController?) {
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    fileprivate func fetchCurrCoin() {
        guard let currCoin = self.currCoin else { return }
        guard let currUser = self.currUser else { return }
        
        createdByUsers = [CoinUser]()
        ownedByUsers = [CoinUser]()
        usersData = [[CoinUser]]()
        
        FirebaseHelper.sharedInstance.fetchCoin(withId: currCoin.id) { (snapshot) in
            if !snapshot.exists() {
                let fullName = FirebaseHelper.sharedInstance.getPrettyName(firstName: currUser.firstName, lastName: currUser.lastName)
                let user = CoinUser(fullName: fullName, profileImage: currUser.profileImage, id: currUser.id, phoneNumber: currUser.phoneNumber)
                self.createdByUsers.append(user)
                self.usersData.append(self.createdByUsers)
                self.ownershipTableView.reloadData()
                
                return
            }
            
            let snapshotValue = snapshot.value as! [String: Any]
            
            let createdByUsers = snapshotValue["createdBy"] as? [String: Any]
            for user in createdByUsers ?? [String: Any]() {
                let userValue = user.value as? [String: Any]
                
                let user = CoinUser(fullName: userValue?["name"] as? String ?? "", profileImage: userValue?["image"] as? String ?? "", id: user.key, phoneNumber: userValue?["phoneNumber"] as? String ?? "")
                self.createrTextView.text = user.fullName
                self.createdByUsers.append(user)
            }
            
            let ownedByUsers = snapshotValue["ownedBy"] as? [String: Any]
            for user in ownedByUsers ?? [String: Any]() {
                let userValue = user.value as? [String: Any]
                
                let user = CoinUser(fullName: userValue?["name"] as? String ?? "", profileImage: userValue?["image"] as? String ?? "", id: user.key, phoneNumber: userValue?["phoneNumber"] as? String ?? "")
                self.ownedByUsers.append(user)
            }
            
            self.usersData.append(self.createdByUsers)
            if self.ownedByUsers.count > 0 {
                self.usersData.append(self.ownedByUsers)
            }
            
            let paymentNum = (snapshotValue["paymentNum"] as? Int) ?? 0
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            
            let paymentNumString = NSMutableAttributedString(string: String(paymentNum), attributes: [.paragraphStyle: paragraph])
            
            paymentNumString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, paymentNumString.length))
            paymentNumString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, paymentNumString.length))
            
            let paymentWordString = NSMutableAttributedString(string: "\nPayment", attributes: [.paragraphStyle: paragraph])
            paymentWordString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, paymentWordString.length))
            paymentWordString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSMakeRange(0, paymentWordString.length))
            
            paymentNumString.append(paymentWordString)
            
            self.paymentTextView.attributedText = paymentNumString
            
            let userNumString = NSMutableAttributedString(string: String(self.createdByUsers.count + self.ownedByUsers.count), attributes: [.paragraphStyle: paragraph])
            
            userNumString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, userNumString.length))
            userNumString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, userNumString.length))
            
            let userWordString = NSMutableAttributedString(string: "\nUser", attributes: [.paragraphStyle: paragraph])
            userWordString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, userWordString.length))
            userWordString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSMakeRange(0, userWordString.length))
            
            userNumString.append(userWordString)
            
            self.userTextView.attributedText = userNumString
            
            self.ownershipTableView.reloadData()
        }
    }
    
    

}

extension ShowCoinDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersData[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.usersData.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.usersData[indexPath.section][indexPath.row]
        
        showProfileDetailVC(selectedUser: user, createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: self.currUser, navigationController: self.navigationController)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let headerTitle = UILabel()
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        
        headerTitle.textColor = .black
    
        if section == 0 {
            headerTitle.text = "Creator"
        } else {
            headerTitle.text = "Owner"
        }
        
        headerTitle.font = .systemFont(ofSize: 20)
        
        headerView.addSubview(headerTitle)
        
        headerTitle.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        headerTitle.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10).isActive = true
        headerTitle.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        headerTitle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ownershipCellId) as! ShowRecipientTableViewCell
        
        cell.nameText = self.usersData[indexPath.section][indexPath.row].fullName
    
        if self.usersData[indexPath.section][indexPath.row].profileImage == "" {
            cell.profileImageView.setImageForName(self.usersData[indexPath.section][indexPath.row].fullName, circular: true, textAttributes: nil, gradient: true)
        } else {
            cell.profileImageView.sd_setImage(with: URL(string: self.usersData[indexPath.section][indexPath.row].profileImage), completed: nil)
        }
        
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
}
