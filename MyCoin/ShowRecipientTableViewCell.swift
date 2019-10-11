//
//  showReceipientTableViewCell.swift
//  MyCoin
//
//  Created by jeff on 9/6/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

class ShowRecipientTableViewCell: UITableViewCell {
    
    var nameText: String?
    var profileImage: UIImage?
    
    fileprivate let nameView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.font = .systemFont(ofSize: 17)
        return view
    }()
    
    fileprivate let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(nameView)
        self.addSubview(profileImageView)
        
        let profileImageViewSize = CGFloat(40)
        
        profileImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        profileImageView.layer.cornerRadius = profileImageViewSize/2
        profileImageView.clipsToBounds = true
        
        nameView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15).isActive = true
        nameView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        nameView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nameView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let nameText = nameText {
            nameView.text = nameText
        }
        
        if let profileImage = profileImage {
            profileImageView.image = profileImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
