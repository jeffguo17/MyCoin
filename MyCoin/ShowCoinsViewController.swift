//
//  ShowCoinsViewController.swift
//  MyCoin
//
//  Created by jeff on 9/10/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

class ShowCoinsViewController: UIViewController {
    
    let coinsCellId = "coinsCell"
    var createdCoinData = [Coin]()
    var ownedByCoinData = [Coin]()
    var coinData = [[Coin]]()
    var payOrRequest = false
    
    weak var delegate: ShowCoinsVCDelegate?
    
    fileprivate let coinsTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    @objc func addCoin() {
        self.navigationController?.pushViewController(AddCoinViewController(), animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if self.createdCoinData.last?.imageURL == "addCoin" {
            _ = self.createdCoinData.popLast()
        }
        
        self.coinData.append(self.createdCoinData)
        self.coinData.append(self.ownedByCoinData)
        
        view.backgroundColor = UIColor.white
        self.title = "Coins"
        
        if payOrRequest == false {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCoin))
        }
        
        view.addSubview(coinsTableView)
        
        coinsTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        coinsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        coinsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        coinsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        coinsTableView.register(ShowCoinTableViewCell.self, forCellReuseIdentifier: coinsCellId)
        
        coinsTableView.delegate = self
        coinsTableView.dataSource = self
        
        coinsTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let index = self.coinsTableView.indexPathForSelectedRow {
            self.coinsTableView.deselectRow(at: index, animated: true)
        }
    }
}

extension ShowCoinsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coinData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: coinsCellId, for: indexPath) as! ShowCoinTableViewCell
        
        cell.nameText = self.coinData[indexPath.section][indexPath.row].name
        
        if self.coinData[indexPath.section][indexPath.row].imageURL.isEmpty {
            cell.coinImage = #imageLiteral(resourceName: "exchange")
        } else if self.coinData[indexPath.section][indexPath.row].imageURL.prefix(4) != "http" {
            cell.coinImage = #imageLiteral(resourceName: self.coinData[indexPath.section][indexPath.row].imageURL)
        } else {
            cell.coinImageView.sd_setImage(with: URL(string: self.coinData[indexPath.section][indexPath.row].imageURL), placeholderImage: #imageLiteral(resourceName: "exchange"))
        }
        
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.coinData.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if payOrRequest {
            self.delegate?.selectedCoin(coin: self.coinData[indexPath.section][indexPath.row])
            self.navigationController?.popViewController(animated: true)
            return 
        }
        
        let showCoinDetailsVC = ShowCoinDetailsViewController()
        showCoinDetailsVC.coinImageURL = self.coinData[indexPath.section][indexPath.row].imageURL
        showCoinDetailsVC.coinName = self.coinData[indexPath.section][indexPath.row].name
            
        self.navigationController?.pushViewController(showCoinDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        //headerView.backgroundColor = .darkGray
        let headerTitle = UILabel()
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        
        headerTitle.textColor = .black
        if section == 0 {
            headerTitle.text = "Created"
        } else {
            headerTitle.text = "Owned"
        }
        headerTitle.font = .systemFont(ofSize: 28)
        
        headerView.addSubview(headerTitle)
        
        headerTitle.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        headerTitle.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10).isActive = true
        headerTitle.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        headerTitle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        return headerView
    }
}

protocol ShowCoinsVCDelegate: class {
    func selectedCoin(coin: Coin)
}
