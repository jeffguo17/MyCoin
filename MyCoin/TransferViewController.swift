//
//  TransferViewController.swift
//  MyCoin
//
//  Created by jeff on 9/3/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import PhoneNumberKit

class TransferViewController: UIViewController, UITextFieldDelegate {
    
    var createdCoinData = [Coin]()
    var ownedByCoinData = [Coin]()
    var recentPeopleData = [RecentPerson]()
    var currUser: User?
    
    fileprivate let searchView: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: "Phone Number", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 15.0)
            ])
        textField.returnKeyType = UIReturnKeyType.search
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
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let index = self.recipientTableView.indexPathForSelectedRow {
            self.recipientTableView.deselectRow(at: index, animated: true)
        }
        
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
        
        // TODO:
        //let index = text.index(text.startIndex, offsetBy: 0)
        //let firstCharacter = text[index]
        //if (firstCharacter >= "a" && firstCharacter <= "z") || (firstCharacter >= "A" && firstCharacter <= "Z") {
        //
        //}
        
        do {
            let phoneNumberKit = PhoneNumberKit()
            let phoneNumber = try phoneNumberKit.parse(text, withRegion: "US")
            //let formattedNumber: String = phoneNumberKit.format(phoneNumber, toType: .national)
            
            
            let firebaseNumber = "+1" + String(phoneNumber.nationalNumber)
            
            //Check if number is yourself
            
            FirebaseHelper.sharedInstance.getUserProfile(withPhoneNumber: firebaseNumber) { (recipientUser) in
                guard let recipientUser = recipientUser else {
                    textField.becomeFirstResponder()
                    showAlertMessage(title: "Phone number is not registered in our system", message: "", actionMessage: "OK", navigationController: self.navigationController)
                    return
                }
                
                guard let currUser = self.currUser else { return }
                if recipientUser.id == currUser.id {
                    textField.becomeFirstResponder()
                    showAlertMessage(title: "You cannot charge yourself", message: "", actionMessage: "OK", navigationController: self.navigationController)
                    return
                }
                
                let recipientPerson = RecentPerson(fullName: FirebaseHelper.sharedInstance.getPrettyName(firstName: recipientUser.firstName, lastName: recipientUser.lastName), profileImage: recipientUser.profileImage, id: recipientUser.id, phoneNumber: recipientUser.phoneNumber)
                
                showPayOrRequestVC(createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: self.currUser, recipientPerson: recipientPerson, navigationController: self.navigationController)
            }
        } catch {
            textField.becomeFirstResponder()
            showAlertMessage(title: "Please enter a valid US phone number", message: "", actionMessage: "OK", navigationController: self.navigationController)
        }
        
        return true
    }
}

extension TransferViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentPeopleData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        showPayOrRequestVC(createdCoinData: self.createdCoinData, ownedByCoinData: self.ownedByCoinData, currUser: self.currUser, recipientPerson: self.recentPeopleData[indexPath.row], navigationController: self.navigationController)
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
        cell.nameText = self.recentPeopleData[indexPath.row].fullName
        
        if self.recentPeopleData[indexPath.row].profileImage == "" {
            cell.profileImageView.setImageForName(self.recentPeopleData[indexPath.row].fullName, circular: true, textAttributes: nil, gradient: true)
        } else {
            cell.profileImageView.sd_setImage(with: URL(string: self.recentPeopleData[indexPath.row].profileImage), completed: nil)
        }
        
        cell.layoutSubviews()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
 
}
