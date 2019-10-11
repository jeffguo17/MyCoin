//
//  ShowCoinTableViewCell.swift
//  MyCoin
//
//  Created by jeff on 9/10/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

class ShowCoinTableViewCell: UITableViewCell {

    var nameText: String?
    var coinImage: UIImage?
    
    fileprivate let nameView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.font = .systemFont(ofSize: 17)
        return view
    }()
    
    let coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(nameView)
        self.addSubview(coinImageView)
        
        let coinImageViewSize = CGFloat(45)
        
        coinImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: coinImageViewSize).isActive = true
        coinImageView.widthAnchor.constraint(equalToConstant: coinImageViewSize).isActive = true
        coinImageView.layer.cornerRadius = coinImageViewSize/3
        coinImageView.clipsToBounds = true
        coinImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        nameView.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 15).isActive = true
        nameView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        nameView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nameView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.coinImageView.sd_cancelCurrentImageLoad()
        self.coinImageView.image = nil
        self.coinImage = nil
        
        self.nameView.text = nil
        self.nameText = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let nameText = nameText {
            nameView.text = nameText
        }
        
        if let coinImage = coinImage {
            coinImageView.image = coinImage
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
