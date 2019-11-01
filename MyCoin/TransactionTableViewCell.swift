//
//  TransactionTableViewCell.swift
//  MyCoin
//
//  Created by jeff on 8/27/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import Foundation
import UIKit

class TransactionTableViewCell: UITableViewCell, UITextViewDelegate {
    var headerMessage: String?
    var profileImage: UIImage?
    var message: String?
    var sender: CoinUser?
    var recipient: CoinUser?
    var createdCoinData = [Coin]()
    var ownedByCoinData = [Coin]()
    var timeStampString = "100 weeks ago"
    var currUser: User?
    var navigationController: UINavigationController?
    
    fileprivate let headerView: unselectableTextView = {
        let textView = unselectableTextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        return textView
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()
    
    fileprivate let timeStampView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.font = .systemFont(ofSize: 12)
        return textView
    }()
    
    let messageView: UILabel = {
        let textLabel = UILabel()
        textLabel.isUserInteractionEnabled = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 2
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.textAlignment = .left
        return textLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(headerView)
        self.addSubview(profileImageView)
        self.addSubview(timeStampView)
        self.addSubview(messageView)
        
        let profileImageViewHeight = CGFloat(50)
        
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewHeight).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.layer.cornerRadius = profileImageViewHeight/2
        profileImageView.clipsToBounds = true
        
        headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: self.profileImageView.trailingAnchor, constant: 10).isActive = true
        headerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        timeStampView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        timeStampView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        timeStampView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        timeStampView.heightAnchor.constraint(equalToConstant: 22.0).isActive = true
        
        messageView.topAnchor.constraint(equalTo: timeStampView.bottomAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 5).isActive = true
        messageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15).isActive = true
        messageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        headerView.delegate = self
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        guard let sender = self.sender, let recipient = self.recipient, let currUser = self.currUser, let navigationController = self.navigationController else { return false }
        if URL.absoluteString == "senderNameTapped" {
            showProfileDetailVC(selectedUser: sender, createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: currUser, navigationController: navigationController)
        } else if URL.absoluteString == "recipientNameTapped" {
            showProfileDetailVC(selectedUser: recipient, createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: currUser, navigationController: navigationController)
        }
        return false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let sender = self.sender, let recipient = recipient, let currUser = self.currUser else { return }
        
        let senderName = sender.fullName
        let recipientName = recipient.fullName
        
        var senderNameText = NSMutableAttributedString(string: "You")
        if sender.id != currUser.id {
            senderNameText = NSMutableAttributedString(string: senderName)
        }
        senderNameText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, senderNameText.length))
        senderNameText.addAttribute(NSAttributedString.Key.link, value: "senderNameTapped", range: NSMakeRange(0, senderNameText.length))
            
        var recipientNameText = NSMutableAttributedString(string: "You")
        if recipient.id != currUser.id {
            recipientNameText = NSMutableAttributedString(string : recipientName)
        }
        recipientNameText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, recipientNameText.length))
        recipientNameText.addAttribute(NSAttributedString.Key.link, value: "recipientNameTapped", range: NSMakeRange(0, recipientNameText.length))
            
        let message = NSMutableAttributedString(string: " paid ")
        message.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 17), range: NSMakeRange(0, message.length))
        message.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.gray, range: NSMakeRange(0, message.length))
            
        senderNameText.append(message)
        senderNameText.append(recipientNameText)
            
        headerView.attributedText = senderNameText
        
        if let message = self.message {
            messageView.text = message
            
            if message.containsOnlyEmoji {
                messageView.font = .systemFont(ofSize: 30.0)
            } else {
                messageView.font = .systemFont(ofSize: 18.0)
            }
        }
        
        if let profileImage = profileImage {
            profileImageView.image = profileImage
        }
        
        timeStampView.text = timeStampString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
