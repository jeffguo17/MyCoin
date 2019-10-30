//
//  ShowCoinTableViewCell.swift
//  MyCoin
//
//  Created by jeff on 9/10/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import ChameleonFramework

class ShowCoinTableViewCell: UITableViewCell {

    var nameText: String?
    var coinImage: UIImage?
    var amountNum: String?
    
    fileprivate let nameView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.font = .systemFont(ofSize: 17)
        view.textColor = UIColor.flatBlack
        return view
    }()
    
    let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    fileprivate let amountView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.font = .systemFont(ofSize: 17)
        view.textAlignment = .right
        view.textColor = UIColor.flatOrange
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(nameView)
        self.addSubview(coinImageView)
        self.addSubview(amountView)
        
        let coinImageViewSize = CGFloat(45)
        
        coinImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: coinImageViewSize).isActive = true
        coinImageView.widthAnchor.constraint(equalToConstant: coinImageViewSize).isActive = true
        coinImageView.layer.cornerRadius = coinImageViewSize/3
        coinImageView.clipsToBounds = true
        coinImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        nameView.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 15).isActive = true
        nameView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -90).isActive = true
        nameView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nameView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        amountView.leadingAnchor.constraint(equalTo: nameView.trailingAnchor).isActive = true
        amountView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        amountView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        amountView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.coinImageView.sd_cancelCurrentImageLoad()
        self.coinImageView.image = nil
        self.coinImage = nil
        
        self.nameView.text = nil
        self.nameText = nil
        
        self.amountView.text = nil
        self.amountNum = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let nameText = nameText {
            nameView.text = nameText
        }
        
        if let coinImage = coinImage {
            coinImageView.image = coinImage
        }
        
        if let amountNum = amountNum {
            amountView.text = "\(amountNum)"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
