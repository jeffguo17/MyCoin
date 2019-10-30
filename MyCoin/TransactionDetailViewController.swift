//
//  TransactionDetailViewController.swift
//  MyCoin
//
//  Created by jeff on 10/19/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import MessageViewController
import Firebase

class TransactionDetailViewController: MessageViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {

    var transId: String?
    var currUser: User?
    var sender: CoinUser?
    var recipient: CoinUser?
    var createdCoinData = [Coin]()
    var ownedByCoinData = [Coin]()
    var timeStampString = "100 weeks ago"
    var message = ""
    var commentUsers = [CommentUser]()
    var coinImageURL = ""
    var transAmount = ""
    var commentUsersRef: DatabaseReference?
    var firebaseHandle: UInt!
    var finishedLoading = false
    
    fileprivate let commentsCellId = "commentsCell"
    
    fileprivate let commentsTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    @objc fileprivate func sendButtonTapped() {
        guard let currUser = currUser, let transId = transId, let navigationController = self.navigationController else { return }
        
        let messageViewText = messageView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if messageViewText.isEmpty {
            showAlertMessage(title: "Please enter a valid comment", message: "", actionMessage: "OK", navigationController: navigationController)
            return
        }
        FirebaseHelper.sharedInstance.addComment(transId: transId, currUser: currUser, message: messageViewText)
        
        messageView.text = ""
        messageView.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.commentUsers.removeAll()
        guard let commentUsersRef = commentUsersRef else { return }
        firebaseHandle = commentUsersRef.observe(.childAdded) { (snapshot) in
            let commentValue = snapshot.value as? [String: Any]
            
            let userFullname = commentValue?["name"] as? String ?? ""
            let userId = commentValue?["id"] as? String ?? ""
            let userImage = commentValue?["image"] as? String ?? ""
            let userMessage = commentValue?["message"] as? String ?? ""
            let userPhoneNumber = commentValue?["phoneNumber"] as? String ?? ""
            let timeStamp = commentValue?["timeStamp"] as? Double ?? 0.0
            
            let commentUser = CommentUser(user: CoinUser(fullName: userFullname, profileImage: userImage, id: userId, phoneNumber: userPhoneNumber), message: userMessage, timeStamp: timeStamp.timeAgoDisplay())
            self.commentUsers.append(commentUser)
            
            self.commentsTableView.reloadData()
            if self.finishedLoading {
                self.commentsTableView.scrollToRow(at: IndexPath(row: self.commentUsers.count, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.finishedLoading = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let commentUsersRef = commentUsersRef else { return }
        commentUsersRef.removeObserver(withHandle: firebaseHandle)
        
        self.finishedLoading = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        self.title = "Payment"
        
        view.addSubview(commentsTableView)
        
        commentsTableView.register(TransactionDetailCell.self, forCellReuseIdentifier: commentsCellId)
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        
        commentsTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        commentsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        commentsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        commentsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        setupCommentsTableView()
    }
    
    fileprivate func setupViews(profileImageView: UIImageView, headerView: unselectableTextView, messageTextView: UITextView, timeStampView: UITextView, coinImageView: UIImageView, coinAmountTextView: UITextView) {
        guard let currUser = currUser, let sender = sender, let recipient = recipient else { return }
        
        if sender.profileImage == "" {
            profileImageView.setImageForName(sender.fullName, circular: true, textAttributes: nil, gradient: true)
        } else {
            profileImageView.sd_setImage(with: URL(string: sender.profileImage), completed: nil)
        }
        
        var senderNameText = NSMutableAttributedString(string: "You")
        if currUser.id != sender.id {
            senderNameText = NSMutableAttributedString(string: sender.fullName)
            senderNameText.addAttribute(NSAttributedString.Key.link, value: "senderNameTapped", range: NSMakeRange(0, senderNameText.length))
        }
        senderNameText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, senderNameText.length))
        
        let recipientNameText = NSMutableAttributedString(string: recipient.fullName)
        recipientNameText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, recipientNameText.length))
        recipientNameText.addAttribute(NSAttributedString.Key.link, value: "recipientNameTapped", range: NSMakeRange(0, recipientNameText.length))
        
        let message = NSMutableAttributedString(string: " paid ")
        message.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, message.length))
        message.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, message.length))
        
        senderNameText.append(message)
        senderNameText.append(recipientNameText)
        
        headerView.attributedText = senderNameText
        messageTextView.text = self.message
        messageTextView.font = .systemFont(ofSize: 24)
        
        timeStampView.text = self.timeStampString
        timeStampView.font = .systemFont(ofSize: 12.0)
        
        coinImageView.isHidden = false
        
        if self.coinImageURL.isEmpty {
            coinImageView.image = #imageLiteral(resourceName: "exchange")
        } else if self.coinImageURL.prefix(4) != "http" {
            coinImageView.image = #imageLiteral(resourceName: self.coinImageURL)
        } else {
            coinImageView.sd_setImage(with: URL(string: self.coinImageURL), placeholderImage: #imageLiteral(resourceName: "exchange"))
        }
        
        coinAmountTextView.isHidden = false
        coinAmountTextView.text = self.transAmount
        coinAmountTextView.font = .systemFont(ofSize: 14.0)
        coinAmountTextView.textColor = UIColor.flatGreenDark
    }
    
    fileprivate func setupCommentViews(commentUsersIndex: Int, profileImageView: UIImageView, headerView: unselectableTextView, messageTextView: UITextView, timeStampView: UITextView) {
        guard let currUser = self.currUser else { return }
        
        let commentUser = self.commentUsers[commentUsersIndex].user
        
        if commentUser.profileImage == "" {
            profileImageView.setImageForName(commentUser.fullName, circular: true, textAttributes: nil, gradient: true)
        } else {
            profileImageView.sd_setImage(with: URL(string: commentUser.profileImage), completed: nil)
        }
        
        var commentNameText = NSMutableAttributedString(string: "You")
        if currUser.id != commentUser.id {
            commentNameText = NSMutableAttributedString(string: commentUser.fullName)
            commentNameText.addAttribute(NSAttributedString.Key.link, value: "commentNameTapped\(commentUsersIndex)", range: NSMakeRange(0, commentNameText.length))
        }
        commentNameText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15), range: NSMakeRange(0, commentNameText.length))
        
        headerView.attributedText = commentNameText
        messageTextView.text = self.commentUsers[commentUsersIndex].message
        messageTextView.font = .systemFont(ofSize: 14.0)
        
        timeStampView.text = self.commentUsers[commentUsersIndex].timeStamp
        timeStampView.font = .systemFont(ofSize: 8.0)
    }
    
    fileprivate func setupCommentsTableView() {
        // Border between the text view and the scroll view
        borderColor = .lightGray
        
        // Change the appearance of the text view and its content
        messageView.inset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 18)
        messageView.textView.placeholderText = "Write a comment"
        messageView.textView.placeholderTextColor = .lightGray
        messageView.font = .systemFont(ofSize: 17)
        
        // Setup the button using text or an icon
        messageView.setButton(font: .systemFont(ofSize: 17), position: .right)
        messageView.setButton(title: "Send", for: .normal, position: .right)
        messageView.addButton(target: self, action: #selector(sendButtonTapped), position: .right)
        messageView.rightButtonTint = UIView().tintColor
        
        setup(scrollView: commentsTableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (1 + commentUsers.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: commentsCellId, for: indexPath) as! TransactionDetailCell
        cell.selectionStyle = .none
        cell.headerView.delegate = self
        //Sender and Recipient
        if indexPath.row == 0 {
            setupViews(profileImageView: cell.profileImageView, headerView: cell.headerView, messageTextView: cell.messageTextView, timeStampView: cell.timeStampView, coinImageView: cell.coinImageView, coinAmountTextView: cell.coinAmountTextView)
            cell.bottomLineSeparator.isHidden = true
            if let commentTextView = cell.commentUIView.subviews[1] as? UITextView {
                if self.commentUsers.count == 0 {
                    commentTextView.text = "Be the first person to comment this."
                } else {
                    commentTextView.text = "Comments"
                }
            }
        } else {
           //Comments
            setupCommentViews(commentUsersIndex: indexPath.row-1, profileImageView: cell.profileImageView, headerView: cell.headerView, messageTextView: cell.messageTextView, timeStampView: cell.timeStampView)
            cell.commentUIView.isHidden = true
            cell.bottomLineSeparator.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 150.0
        }
        
        return 85.0
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let sender = self.sender, let recipient = self.recipient, let currUser = self.currUser, let navigationController = self.navigationController else { return false }
        if URL.absoluteString == "senderNameTapped" {
            showProfileDetailVC(selectedUser: sender, createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: currUser, navigationController: navigationController)
        } else if URL.absoluteString == "recipientNameTapped" {
            showProfileDetailVC(selectedUser: recipient, createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: currUser, navigationController: navigationController)
        } else if URL.absoluteString.contains("commentNameTapped") {
            if let range = URL.absoluteString.range(of: "commentNameTapped") {
                if let index = Int(URL.absoluteString[range.upperBound...]) {
                    let commentUser = self.commentUsers[index].user
                    showProfileDetailVC(selectedUser: commentUser, createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: currUser, navigationController: navigationController)
                }
            }
        }
        return false
    }
}
