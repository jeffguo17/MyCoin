//
//  PurchasesViewController.swift
//  MyCoin
//
//  Created by jeff on 10/29/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import Firebase
import SideMenu

class PurchasesViewController: SideMenuLogicViewController {

    var currUser: User?
    var createdCoinData = [Coin]()
    var ownedByCoinData = [Coin]()
    var leftMenuNavigationController: SideMenuNavigationController?
    var titleText = ""
    
    var transactionData = [Transaction]()
    
    let headerTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.maximumNumberOfLines = 1
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textAlignment = .left
        textView.font = .systemFont(ofSize: 15)
        textView.backgroundColor = UIColor.white
        return textView
    }()
    
    let transTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(TransactionDetailCell.self, forCellReuseIdentifier: "purchaseId")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    fileprivate let lineSeparatorAboveTableView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    fileprivate let lineSeparatorBelowTableView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = self.titleText
        view.backgroundColor = UIColor.white
        addSideMenu()
        
        view.addSubview(headerTextView)
        view.addSubview(transTableView)
        view.addSubview(lineSeparatorAboveTableView)
        view.addSubview(lineSeparatorBelowTableView)
        
        // Do any additional setup after loading the view.
        headerTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        headerTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        headerTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        headerTextView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        transTableView.topAnchor.constraint(equalTo: headerTextView.bottomAnchor).isActive = true
        transTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        transTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        transTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35).isActive = true
        
        transTableView.delegate = self
        transTableView.dataSource = self
        
        lineSeparatorAboveTableView.bottomAnchor.constraint(equalTo: transTableView.topAnchor).isActive = true
        lineSeparatorAboveTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparatorAboveTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparatorAboveTableView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        lineSeparatorBelowTableView.bottomAnchor.constraint(equalTo: transTableView.bottomAnchor).isActive = true
        lineSeparatorBelowTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparatorBelowTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparatorBelowTableView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        fetchTransactions()
    }
    
    func fetchTransactions() {
        guard let currUser = self.currUser else { return }
        
        self.transactionData = [Transaction]()
        FirebaseHelper.sharedInstance.fetchPurchasesTransactions(user: currUser, viewController: self) { (snapshot) in
            for snap in snapshot {
                if let value = snap.value as? NSDictionary {
                    self.transactionData.append(parseTransactionSnapshot(value: value, transId: snap.key))
                }
            }
            self.transTableView.reloadData()
        }
    }
    
    @objc fileprivate func showSideMenu() {
        if let leftMenuNavigationController = self.leftMenuNavigationController {
            present(leftMenuNavigationController, animated: true, completion: nil)
        }
    }
    
    fileprivate func addSideMenu() {
        let btnShowMenu = UIButton(type: .system)
        btnShowMenu.setImage(drawHamburgerIcon(), for: UIControl.State())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 22, height: 25)
        btnShowMenu.addTarget(self, action: #selector(showSideMenu), for: .touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }

}

extension PurchasesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactionData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseId", for: indexPath) as! TransactionDetailCell
        
        cell.selectionStyle = .none
        cell.bottomLineSeparator.isHidden = false
        cell.commentUIView.isHidden = true
        cell.headerView.delegate = self
        
        let sender = self.transactionData[indexPath.row].from.first
        let recipient = self.transactionData[indexPath.row].to.first
        let message = self.transactionData[indexPath.row].message
        let timeStamp = self.transactionData[indexPath.row].timeStamp.timeAgoDisplay()
        let coinImageURL = self.transactionData[indexPath.row].coinImage
        let coinAmount = self.transactionData[indexPath.row].amount
        
        setupViews(tableViewIndex: indexPath.row, sender: sender, recipient: recipient, message: message, timeStampString: timeStamp, coinImageURL: coinImageURL, coinAmount: coinAmount, profileImageView: cell.profileImageView, headerView: cell.headerView, messageTextView: cell.messageTextView, timeStampView: cell.timeStampView, coinImageView: cell.coinImageView, coinAmountTextView: cell.coinAmountTextView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currUser = self.currUser, let fromUser = self.transactionData[indexPath.row].from.first, let toUser = self.transactionData[indexPath.row].to.first else { return }
        
        let transactionDetailVC = TransactionDetailViewController()
        transactionDetailVC.sender = fromUser
        transactionDetailVC.currUser = currUser
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
    
    fileprivate func setupViews(tableViewIndex: Int, sender: CoinUser?, recipient: CoinUser?, message: String, timeStampString: String, coinImageURL: String, coinAmount: String, profileImageView: UIImageView, headerView: unselectableTextView, messageTextView: UITextView, timeStampView: UITextView, coinImageView: UIImageView, coinAmountTextView: UITextView) {
        guard let currUser = currUser, let sender = sender, let recipient = recipient else { return }
        
        if sender.profileImage == "" {
            profileImageView.setImageForName(sender.fullName, circular: true, textAttributes: nil, gradient: true)
        } else {
            profileImageView.sd_setImage(with: URL(string: sender.profileImage), completed: nil)
        }
        
        var senderNameText = NSMutableAttributedString(string: "You")
        if currUser.id != sender.id {
            senderNameText = NSMutableAttributedString(string: sender.fullName)
            senderNameText.addAttribute(NSAttributedString.Key.link, value: "senderNameTapped\(tableViewIndex)", range: NSMakeRange(0, senderNameText.length))
        }
        senderNameText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15), range: NSMakeRange(0, senderNameText.length))
        
        var recipientNameText = NSMutableAttributedString(string: "You")
        if currUser.id != recipient.id {
            recipientNameText = NSMutableAttributedString(string: recipient.fullName)
            recipientNameText.addAttribute(NSAttributedString.Key.link, value: "recipientNameTapped\(tableViewIndex)", range: NSMakeRange(0, recipientNameText.length))
        }
        recipientNameText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15), range: NSMakeRange(0, recipientNameText.length))
        
        let paidText = NSMutableAttributedString(string: " paid ")
        paidText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15), range: NSMakeRange(0, paidText.length))
        paidText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, paidText.length))
        
        senderNameText.append(paidText)
        senderNameText.append(recipientNameText)
        
        headerView.attributedText = senderNameText
        messageTextView.text = message
        messageTextView.font = .systemFont(ofSize: 18)
        
        timeStampView.text = timeStampString
        timeStampView.font = .systemFont(ofSize: 12.0)
        
        coinImageView.isHidden = false
        
        if coinImageURL.isEmpty {
            coinImageView.image = #imageLiteral(resourceName: "exchange")
        } else if coinImageURL.prefix(4) != "http" {
            coinImageView.image = #imageLiteral(resourceName: coinImageURL)
        } else {
            coinImageView.sd_setImage(with: URL(string: coinImageURL), placeholderImage: #imageLiteral(resourceName: "exchange"))
        }
        
        coinAmountTextView.isHidden = false
        coinAmountTextView.text = coinAmount
        coinAmountTextView.font = .systemFont(ofSize: 14.0)
        coinAmountTextView.textColor = UIColor.green
    }
    
}

extension PurchasesViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let currUser = self.currUser, let navigationController = self.navigationController else { return false }
        
        if URL.absoluteString.contains("senderNameTapped") {
            if let range = URL.absoluteString.range(of: "senderNameTapped"), let index = Int(URL.absoluteString[range.upperBound...]),
                let sender = self.transactionData[index].from.first {
                
                showProfileDetailVC(selectedUser: sender, createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: currUser, navigationController: navigationController)
            }
        } else if URL.absoluteString.contains("recipientNameTapped") {
            if let range = URL.absoluteString.range(of: "recipientNameTapped"), let index = Int(URL.absoluteString[range.upperBound...]),
                let recipient = self.transactionData[index].to.first {
                
                showProfileDetailVC(selectedUser: recipient, createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: currUser, navigationController: navigationController)
            }
        }
        
        return false
    }
    
}
