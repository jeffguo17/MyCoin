//
//  TransactionDetailCell.swift
//  MyCoin
//
//  Created by jeff on 10/21/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

class TransactionDetailCell: UITableViewCell {
    
    let headerView: unselectableTextView = {
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
    
     let timeStampView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.font = .systemFont(ofSize: 12)
        return textView
    }()
    
    let messageTextView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        return textView
    }()
    
    let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.isHidden = true
        return imageView
    }()
    
    let coinAmountTextView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.isHidden = true
        textView.textAlignment = .center
        return textView
    }()
    
    let bottomLineSeparator: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.isHidden = true
        return view
    }()
    
    let commentUIView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let lineSeparatorAbove = UIView()
        lineSeparatorAbove.translatesAutoresizingMaskIntoConstraints = false
        lineSeparatorAbove.backgroundColor = .lightGray
        
        let commentTextView = UITextView()
        commentTextView.isUserInteractionEnabled = false
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.isScrollEnabled = false
        commentTextView.text = "Comments"
        commentTextView.font = .systemFont(ofSize: 17)
        commentTextView.textContainer.lineBreakMode = .byTruncatingTail
        
        let lineSeparatorBelow = UIView()
        lineSeparatorBelow.translatesAutoresizingMaskIntoConstraints = false
        lineSeparatorBelow.backgroundColor = .lightGray
        
        view.addSubview(lineSeparatorAbove)
        view.addSubview(commentTextView)
        view.addSubview(lineSeparatorBelow)
        
        lineSeparatorAbove.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        lineSeparatorAbove.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparatorAbove.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparatorAbove.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        commentTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 1).isActive = true
        commentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        commentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        commentTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -1).isActive = true
        
        lineSeparatorBelow.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        lineSeparatorBelow.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparatorBelow.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparatorBelow.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(headerView)
        self.addSubview(profileImageView)
        self.addSubview(timeStampView)
        self.addSubview(messageTextView)
        self.addSubview(coinImageView)
        self.addSubview(coinAmountTextView)
        self.addSubview(commentUIView)
        self.addSubview(bottomLineSeparator)
        
        let profileImageViewHeight = CGFloat(50)
        
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewHeight).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        profileImageView.layer.cornerRadius = profileImageViewHeight/2
        profileImageView.clipsToBounds = true
        
        headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10).isActive = true
        headerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -70).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        
        timeStampView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        timeStampView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        timeStampView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        timeStampView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        messageTextView.topAnchor.constraint(equalTo: timeStampView.bottomAnchor, constant: 5).isActive = true
        messageTextView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        messageTextView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15).isActive = true
        messageTextView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let coinImageViewSize = CGFloat(50)
        coinImageView.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        coinImageView.leadingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: coinImageViewSize).isActive = true
        coinImageView.widthAnchor.constraint(equalToConstant: coinImageViewSize).isActive = true
        coinImageView.layer.cornerRadius = coinImageViewSize/2
        coinImageView.layer.borderColor = UIColor.lightGray.cgColor
        coinImageView.layer.borderWidth = 1
        coinImageView.clipsToBounds = true
        
        coinAmountTextView.topAnchor.constraint(equalTo: coinImageView.bottomAnchor).isActive = true
        coinAmountTextView.leadingAnchor.constraint(equalTo: coinImageView.leadingAnchor, constant: -5).isActive = true
        coinAmountTextView.trailingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 5).isActive = true
        coinAmountTextView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        commentUIView.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 15).isActive = true
        commentUIView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        commentUIView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        commentUIView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        bottomLineSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -0.5).isActive = true
        bottomLineSeparator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        bottomLineSeparator.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        bottomLineSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.profileImageView.sd_cancelCurrentImageLoad()
        self.profileImageView.image = nil
        
        self.headerView.attributedText = nil
        
        self.messageTextView.text = nil
        
        self.timeStampView.text = nil
        
        self.coinImageView.sd_cancelCurrentImageLoad()
        self.coinImageView.image = nil
        self.coinImageView.isHidden = true
        
        self.coinAmountTextView.text = nil
        self.coinAmountTextView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
