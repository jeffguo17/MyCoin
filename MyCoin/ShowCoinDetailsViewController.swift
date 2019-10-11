//
//  ShowCoinDetailsViewController.swift
//  MyCoin
//
//  Created by jeff on 9/10/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

class ShowCoinDetailsViewController: UIViewController {

    var coinImageURL: String = ""
    var coinName: String = ""
    
    fileprivate let coinImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    fileprivate let nameTextView: UITextView = {
        let view = UITextView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = ""
        view.font = .systemFont(ofSize: 24)
        view.textColor = .black
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
        
        return tableView
    }()
    
    let ownershipCellId = "ownershipCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        // Do any additional setup after loading the view.
        view.addSubview(coinImageView)
        view.addSubview(nameTextView)
        view.addSubview(lineSeparator)
        view.addSubview(ownershipTableView)
        
        if self.coinImageURL.isEmpty {
            coinImageView.image = #imageLiteral(resourceName: "exchange")
        } else if self.coinImageURL.prefix(4) != "http" {
            coinImageView.image = #imageLiteral(resourceName: self.coinImageURL)
        } else {
            coinImageView.sd_setImage(with: URL(string: self.coinImageURL), placeholderImage: #imageLiteral(resourceName: "exchange"))
        }
        
        coinImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        coinImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        coinImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        nameTextView.topAnchor.constraint(equalTo: coinImageView.bottomAnchor, constant: 5).isActive = true
        nameTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        nameTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        nameTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        nameTextView.textAlignment = .center
        nameTextView.text = self.coinName
        
        lineSeparator.topAnchor.constraint(equalTo: nameTextView.bottomAnchor).isActive = true
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
    }

}

extension ShowCoinDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
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
        cell.nameText = "Evan Biava"
        cell.profileImage = #imageLiteral(resourceName: "person")
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
}
