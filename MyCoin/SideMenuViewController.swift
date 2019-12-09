//
//  SideMenuViewController.swift
//  MyCoin
//
//  Created by jeff on 10/27/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuViewController: UIViewController {
    
    var profileImageURL = ""
    var userFullName = "A A"
    var totalNumCoins = 0
    var menuIconsText = ["Home", "My Wallet", "Purchases", "Receives", "Notifications"]
    var menuiConsImage = [#imageLiteral(resourceName: "home"),#imageLiteral(resourceName: "money"),#imageLiteral(resourceName: "receipt"),#imageLiteral(resourceName: "present"),#imageLiteral(resourceName: "notification"),#imageLiteral(resourceName: "incomplete")]
    weak var delegate: SideMenuViewControllerDelegate?
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    let nameTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.maximumNumberOfLines = 1
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 22)
        return textView
    }()

    let numCoinsUIView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let lineSeparatorAbove = UIView()
        lineSeparatorAbove.translatesAutoresizingMaskIntoConstraints = false
        lineSeparatorAbove.backgroundColor = .lightGray
        
        let numCoinTextView = UITextView()
        numCoinTextView.isUserInteractionEnabled = false
        numCoinTextView.translatesAutoresizingMaskIntoConstraints = false
        numCoinTextView.isScrollEnabled = false
        numCoinTextView.text = "0"
        numCoinTextView.font = .systemFont(ofSize: 16)
        numCoinTextView.textContainer.lineBreakMode = .byTruncatingTail
        
        let numCoinText = UITextView()
        numCoinText.isUserInteractionEnabled = false
        numCoinText.translatesAutoresizingMaskIntoConstraints = false
        numCoinText.isScrollEnabled = false
        numCoinText.text = "Coins"
        numCoinText.font = .systemFont(ofSize: 16)
        numCoinText.textContainer.lineBreakMode = .byTruncatingTail
        numCoinText.textAlignment = .right
        
        let lineSeparatorBelow = UIView()
        lineSeparatorBelow.translatesAutoresizingMaskIntoConstraints = false
        lineSeparatorBelow.backgroundColor = .lightGray
        
        view.addSubview(lineSeparatorAbove)
        view.addSubview(numCoinTextView)
        view.addSubview(numCoinText)
        view.addSubview(lineSeparatorBelow)
        
        lineSeparatorAbove.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        lineSeparatorAbove.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparatorAbove.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparatorAbove.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        numCoinText.topAnchor.constraint(equalTo: view.topAnchor, constant: 1).isActive = true
        numCoinText.widthAnchor.constraint(equalToConstant: 60).isActive = true
        numCoinText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        numCoinText.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -1).isActive = true
        
        numCoinTextView.topAnchor.constraint(equalTo: view.topAnchor, constant: 1).isActive = true
        numCoinTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        numCoinTextView.trailingAnchor.constraint(equalTo: numCoinText.leadingAnchor).isActive = true
        numCoinTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -1).isActive = true
        
        lineSeparatorBelow.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        lineSeparatorBelow.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparatorBelow.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparatorBelow.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return view
    }()
    
    let menuTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(MenuTableViewCell.self, forCellReuseIdentifier: "menuCell")
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    let creditTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.maximumNumberOfLines = 1
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.textAlignment = .left
        textView.font = .systemFont(ofSize: 12)
        textView.text = (Bundle.main.displayName ?? "This App") + " is made by Jeff Guo."
        textView.textColor = UIColor.gray
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.isOpaque = false
        
        view.addSubview(profileImageView)
        view.addSubview(nameTextView)
        view.addSubview(numCoinsUIView)
        view.addSubview(menuTableView)
        view.addSubview(creditTextView)
        
        let profileImageViewSize = CGFloat(100)
        
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60).isActive = true
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: profileImageViewSize).isActive = true
        profileImageView.layer.cornerRadius = profileImageViewSize/2
        profileImageView.clipsToBounds = true
        
        nameTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10).isActive = true
        nameTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        nameTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        nameTextView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        numCoinsUIView.topAnchor.constraint(equalTo: nameTextView.bottomAnchor, constant: 10).isActive = true
        numCoinsUIView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        numCoinsUIView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        numCoinsUIView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let creditTextViewHeight = CGFloat(40)
        
        menuTableView.topAnchor.constraint(equalTo: numCoinsUIView.bottomAnchor).isActive = true
        menuTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        menuTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        menuTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: (-1 * creditTextViewHeight)).isActive = true
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        creditTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        creditTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        creditTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        creditTextView.heightAnchor.constraint(equalToConstant: creditTextViewHeight).isActive = true
        
        setupViews()
    }
    
    fileprivate func setupViews() {
        if self.profileImageURL == "" {
            self.profileImageView.setImageForName(self.userFullName, circular: true, textAttributes: nil, gradient: true)
        } else {
            self.profileImageView.sd_setImage(with: URL(string: self.profileImageURL), completed: nil)
        }
        
        self.nameTextView.text = self.userFullName
        
        self.updateTotalNumCoins(totalNumCoins: self.totalNumCoins)
    }
    
    func updateTotalNumCoins(totalNumCoins: Int) {
        if let numCoinsTextView = self.numCoinsUIView.subviews[1] as? UITextView {
            numCoinsTextView.text = String(totalNumCoins)
        }
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuIconsText.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell
        
        cell.textView.text = menuIconsText[indexPath.row]
        cell.iconImageView.image = menuiConsImage[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (menuIconsText[indexPath.row]) {
        case "Home": delegate?.homePressed()
        case "My Wallet": delegate?.coinsPressed()
        case "Purchases": delegate?.purchasesPressed()
        case "Receives": delegate?.receivesPressed()
        case "Notifications": delegate?.notificationsPressed()
        //case "SignOut":  delegate?.signOut()
        //case "Incomplete": delegate?.incompletePressed()
        default: print()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
}

protocol SideMenuViewControllerDelegate: class {
    func homePressed()
    func coinsPressed()
    func purchasesPressed()
    func receivesPressed()
    func notificationsPressed()
    //func incompletePressed()
    //func signOut()
}
