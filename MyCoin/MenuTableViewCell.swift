//
//  MenuTableViewCell.swift
//  MyCoin
//
//  Created by jeff on 10/27/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    let textView: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        textField.font = .systemFont(ofSize: 15)
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(iconImageView)
        self.addSubview(textView)
        
        let iconImageViewSize = CGFloat(25)
        
        iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: iconImageViewSize).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: iconImageViewSize).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        textView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 15).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
