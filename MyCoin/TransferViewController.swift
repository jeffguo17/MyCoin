//
//  TransferViewController.swift
//  MyCoin
//
//  Created by jeff on 9/3/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

class TransferViewController: UIViewController, UITextFieldDelegate {
    
    var createdCoinData = [Coin]()
    var ownedByCoinData = [Coin]()
    var currUser: User?
    
    fileprivate let searchView: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: "Name, Phone Number", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 15.0)
            ])
        return textField
    }()
    
    fileprivate let lineSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    fileprivate let recipientTableViewCellId = "recipCell"
    
    fileprivate let recipientTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        self.title = "Add Recipients"
        navigationController?.navigationBar.shadowImage = nil
        
        view.addSubview(searchView)
        view.addSubview(lineSeparator)
        view.addSubview(recipientTableView)
        
        searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        searchView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        searchView.delegate = self
        
        lineSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparator.topAnchor.constraint(equalTo: searchView.bottomAnchor).isActive = true
        lineSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        recipientTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        recipientTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        recipientTableView.topAnchor.constraint(equalTo: lineSeparator.bottomAnchor).isActive = true
        recipientTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        recipientTableView.register(ShowRecipientTableViewCell.self, forCellReuseIdentifier: recipientTableViewCellId)
        
        recipientTableView.dataSource = self
        recipientTableView.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    
        guard let text = textField.text else { return true }
        
        if text.isPhoneNumber {
            let payOrRequestVC = PayOrRequestViewController()
            payOrRequestVC.createdCoinData = self.createdCoinData
            payOrRequestVC.ownedByCoinData = self.ownedByCoinData
            payOrRequestVC.currUser = self.currUser
            self.navigationController?.pushViewController(payOrRequestVC, animated: false)
        }
        
        return true
    }

}

extension TransferViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
        headerTitle.text = "Recent Transactions"
        headerTitle.font = .systemFont(ofSize: 20)
        
        headerView.addSubview(headerTitle)
        
        headerTitle.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        headerTitle.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10).isActive = true
        headerTitle.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        headerTitle.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: recipientTableViewCellId) as! ShowRecipientTableViewCell
        cell.nameText = "Evan Biava"
        cell.profileImage = #imageLiteral(resourceName: "person")
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
 
}
