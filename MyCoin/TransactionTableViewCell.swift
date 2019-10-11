//
//  TransactionTableViewCell.swift
//  MyCoin
//
//  Created by jeff on 8/27/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import Foundation
import UIKit

class TransactionTableViewCell: UITableViewCell {
    var headerMessage: String?
    var profileImage: UIImage?
    var message: String?
    
    fileprivate let headerView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .gray
        textView.font = .systemFont(ofSize: 17)
        textView.textContainer.lineBreakMode = .byTruncatingTail
        return textView
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()
    
    fileprivate let messageView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.font = .systemFont(ofSize: 18)
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(headerView)
        self.addSubview(profileImageView)
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
        
        messageView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        messageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        messageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15).isActive = true
        messageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let headerMessage = headerMessage {
            headerView.text = headerMessage
        }
        
        if let message = message {
            messageView.text = message
        }
        if let profileImage = profileImage {
            profileImageView.image = profileImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
