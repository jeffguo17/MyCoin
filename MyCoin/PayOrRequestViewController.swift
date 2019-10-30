//
//  PayOrRequestViewController.swift
//  MyCoin
//
//  Created by jeff on 10/1/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

class PayOrRequestViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, ShowCoinsVCDelegate {
    
    var createdCoinData = [Coin]()
    var ownedByCoinData = [Coin]()
    var selectedCoin: Coin?
    var currUser: User?
    var recipientPerson: RecentPerson?
    var showOnce = false
    
    fileprivate let recipientTextView: UITextField = {
        let view = UITextField()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    fileprivate let coinImageView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "multiCoin")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc fileprivate func coinImageTapped() {
        presentShowCoinsVC()
    }
    
    fileprivate let amountTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(string: "0", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 22.0)
            ])
        textField.textAlignment = .right
        textField.font = .systemFont(ofSize: 22.0)
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    fileprivate let lineSeparatorTwo: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    fileprivate let noteTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = "What's it for?"
        textView.textColor = UIColor.lightGray
        textView.font = .systemFont(ofSize: 22.0)

        return textView
    }()
    
    fileprivate let footerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let aboveKeyboardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let payButton = UIButton()
        payButton.backgroundColor = UIView().tintColor
        payButton.setTitle("Pay", for: .normal)
        payButton.titleLabel?.font = .systemFont(ofSize: 22)
        payButton.translatesAutoresizingMaskIntoConstraints = false
        payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        
        /*
        let requestButton = UIButton()
        requestButton.backgroundColor = UIView().tintColor
        requestButton.setTitle("Request", for: .normal)
        requestButton.titleLabel?.font = .systemFont(ofSize: 22)
        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.addTarget(self, action: #selector(requestButtonTapped), for: .touchUpInside)
        
        let lineSeparator = UIView()
        lineSeparator.translatesAutoresizingMaskIntoConstraints = false
        lineSeparator.backgroundColor = .white
        */
 
        view.addSubview(payButton)
        //view.addSubview(requestButton)
        //view.addSubview(lineSeparator)
        
        /*
        requestButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        requestButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        requestButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        requestButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        */
 
        payButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        payButton.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        /*
        lineSeparator.leadingAnchor.constraint(equalTo: requestButton.trailingAnchor).isActive = true
        lineSeparator.topAnchor.constraint(equalTo: requestButton.topAnchor, constant: 10).isActive = true
        lineSeparator.bottomAnchor.constraint(equalTo: requestButton.bottomAnchor, constant: -10).isActive = true
        lineSeparator.widthAnchor.constraint(equalToConstant: 2).isActive = true
        */
        
        return view
    }()
    
    func selectedCoin(coin: Coin) {
        selectedCoin = coin
        if coin.imageURL.isEmpty {
            coinImageView.image = #imageLiteral(resourceName: "exchange")
        } else if coin.imageURL.prefix(4) != "http" {
            coinImageView.image = #imageLiteral(resourceName: coin.imageURL)
        } else {
            coinImageView.sd_setImage(with: URL(string: coin.imageURL), placeholderImage: #imageLiteral(resourceName: "exchange"))
        }
        amountTextField.textColor = .lightGray
        amountTextField.text = getAmountStr(coin: coin)
    }
    
    fileprivate func getAmountStr(coin: Coin) -> String {
        if coin.amount == -1 {
            return "999..."
        } else {
            return roundAmountNum(amount: coin.amount)
        }
    }
    
    @objc fileprivate func footerViewTapped() {
        noteTextView.becomeFirstResponder()
    }
    
    fileprivate func checkAmountAndNote() -> Bool {
        guard let amountText = amountTextField.text, let amount = Double(amountText), amount >= 0.0000001 else {
            showAlertMessage(title: "Please enter an amount greater than 0.0000000.", message: "", actionMessage: "OK", navigationController: self.navigationController ?? nil)
            return false
        }
        
        guard noteTextView.textColor != UIColor.lightGray else {
            showAlertMessage(title: "Please enter a note.", message: "e.g, 'Kale salad with beans, onions, mushrooms, berries, and seeds.'", actionMessage: "OK", navigationController: self.navigationController ?? nil)
            return false
        }
        
        return true
    }
    
    @objc fileprivate func payButtonTapped() {
        if self.coinImageView.image == #imageLiteral(resourceName: "multiCoin") {
            self.presentShowCoinsVC()
            return
        }
        
        guard let currUser = self.currUser, let selectedCoin = self.selectedCoin else { return }
        
        if checkAmountAndNote() {
            guard let amountText = amountTextField.text, let amountNum = Double(amountText) else { return }
            
            if SubtractCoinAmount(currCoin: selectedCoin, amount: amountNum) < 0 && selectedCoin.amount != -1 {
                showAlertMessage(title: "Please enter an amount less than \(selectedCoin.amount).", message: "", actionMessage: "OK", navigationController: self.navigationController ?? nil)
                return
            }
            
            FirebaseHelper.sharedInstance.payUser(withPhoneNumber: "+14155357837", message: noteTextView.text, currUser: currUser, selectedCoin: selectedCoin, amount: amountText, viewController: self) {
                if let mainVC = self.navigationController?.viewControllers.first as? MainViewController {
                    mainVC.transUpdate = true
                }
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @objc fileprivate func requestButtonTapped() {
        showAlertMessage(title: "Coming Soon!", message: "", actionMessage: "OK", navigationController: self.navigationController ?? nil)
        if checkAmountAndNote() {
            
        }
        //FirebaseHelper.sharedInstance.payUser(withPhoneNumber: "+14155357837", message: "hello", user: currUser)
    }
    
    fileprivate func presentShowCoinsVC() {
        let showCoinsVC = ShowCoinsViewController()
        showCoinsVC.createdCoinData = self.createdCoinData
        showCoinsVC.ownedByCoinData = self.ownedByCoinData
        showCoinsVC.payOrRequest = true
        showCoinsVC.delegate = self
        self.navigationController?.pushViewController(showCoinsVC, animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if showOnce == false && amountTextField == textField && self.coinImageView.image == #imageLiteral(resourceName: "multiCoin") {
            presentShowCoinsVC()
            showOnce = true
        } else {
            if amountTextField.textColor == UIColor.lightGray {
                let endPosition: UITextPosition = amountTextField.endOfDocument
                DispatchQueue.main.async {
                    self.amountTextField.selectedTextRange = self.amountTextField.textRange(from: endPosition, to: endPosition)
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let selectedCoin = selectedCoin else { return }
        
        if amountTextField.text?.isEmpty ?? false {
            amountTextField.text = getAmountStr(coin: selectedCoin)
            amountTextField.textColor = UIColor.lightGray
            return
        }
        
        if textField == amountTextField {
            guard let amountText = amountTextField.text, let amount = Double(amountText) else { return }
        
            amountTextField.text = roundAmountNum(amount: amount)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.coinImageView.image == #imageLiteral(resourceName: "multiCoin") {
            showAlertMessage(title: "Please choose a coin.", message: "", actionMessage: "OK", navigationController: self.navigationController ?? nil)
            return true
        }
        
        if amountTextField.textColor == UIColor.lightGray {
            amountTextField.text = nil
            amountTextField.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noteTextView.textColor == UIColor.lightGray {
            let startPosition: UITextPosition = noteTextView.beginningOfDocument
            DispatchQueue.main.async {
                self.noteTextView.selectedTextRange = self.noteTextView.textRange(from: startPosition, to: startPosition)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if self.coinImageView.image == #imageLiteral(resourceName: "multiCoin") {
            showAlertMessage(title: "Please choose a coin.", message: "", actionMessage: "OK", navigationController: navigationController ?? nil)
            return true
        }
        
        if noteTextView.textColor == UIColor.lightGray {
            noteTextView.text = nil
            noteTextView.textColor = UIColor.black
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if noteTextView.text.isEmpty {
            noteTextView.text = "What's it for?"
            noteTextView.textColor = UIColor.lightGray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.title = "Pay or Request"
        
        let recipientName = self.recipientPerson?.fullName ?? "A A"
        
        recipientTextView.text = "To: " + recipientName
        
        view.addSubview(recipientTextView)
        view.addSubview(lineSeparator)
        view.addSubview(coinImageView)
        view.addSubview(amountTextField)
        view.addSubview(lineSeparatorTwo)
        view.addSubview(noteTextView)
        view.addSubview(footerView)
        
        recipientTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        recipientTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        recipientTextView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        recipientTextView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        lineSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparator.topAnchor.constraint(equalTo: recipientTextView.bottomAnchor).isActive = true
        lineSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        let coinImageViewSize = CGFloat(65)
        
        coinImageView.topAnchor.constraint(equalTo: recipientTextView.bottomAnchor, constant: 10).isActive = true
        coinImageView.heightAnchor.constraint(equalToConstant: coinImageViewSize).isActive = true
        coinImageView.widthAnchor.constraint(equalToConstant: coinImageViewSize).isActive = true
        coinImageView.layer.cornerRadius = coinImageViewSize/3
        coinImageView.clipsToBounds = true
        coinImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        coinImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(coinImageTapped)))
        
        amountTextField.topAnchor.constraint(equalTo: coinImageView.topAnchor).isActive = true
        amountTextField.leadingAnchor.constraint(equalTo: coinImageView.trailingAnchor, constant: 20).isActive = true
        amountTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        amountTextField.bottomAnchor.constraint(equalTo: coinImageView.bottomAnchor).isActive = true
        
        amountTextField.delegate = self
        
        lineSeparatorTwo.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lineSeparatorTwo.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lineSeparatorTwo.topAnchor.constraint(equalTo: coinImageView.bottomAnchor, constant: 10).isActive = true
        lineSeparatorTwo.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        noteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        noteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        noteTextView.topAnchor.constraint(equalTo: lineSeparatorTwo.bottomAnchor).isActive = true
        noteTextView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        
        aboveKeyboardView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 45)
        noteTextView.inputAccessoryView = aboveKeyboardView
        
        noteTextView.delegate = self
        
        footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        footerView.topAnchor.constraint(equalTo: noteTextView.bottomAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        footerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(footerViewTapped)))
    }

}
