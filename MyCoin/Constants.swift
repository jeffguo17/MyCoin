//
//  Constants.swift
//  MyCoin
//
//  Created by jeff on 9/20/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import SideMenu

struct Coin {
    var name: String
    var imageURL: String
    var id: String
    var amount: Double
}

struct User {
    var firstName: String
    var lastName: String
    var profileImage: String
    var id: String
    var phoneNumber: String
}

struct CoinUser {
    var fullName: String
    var profileImage: String
    var id: String
    var phoneNumber: String
}

struct CommentUser {
    var user: CoinUser
    var message: String
    var timeStamp: String
}

struct RecentPerson {
    var fullName: String
    var profileImage: String
    var id: String
    var phoneNumber: String
}

struct Transaction {
    var from: [CoinUser]
    var to: [CoinUser]
    var message: String
    var coinName: String
    var coinImage: String
    var amount: String
    var id: String
    var timeStamp: Double
}

extension UITableView {
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

extension Double {
    func timeAgoDisplay() -> String {
        let converted = Date(timeIntervalSince1970: self / 1000)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd,yyyy 'at' h:mm a"
        let time = dateFormatter.string(from: converted)
        return time
    }
}

extension String {
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count && self.count == 10
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func trimLeadingAndTrailingSpaces() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    var isSingleEmoji: Bool {
        return count == 1 && containsEmoji
    }
    
    var containsEmoji: Bool {
        return contains { $0.isEmoji }
    }
    
    var containsOnlyEmoji: Bool {
        return !isEmpty && !contains { !$0.isEmoji }
    }
    
    var emojiString: String {
        return emojis.map { String($0) }.reduce("", +)
    }
    
    var emojis: [Character] {
        return filter { $0.isEmoji }
    }
    
    var emojiScalars: [UnicodeScalar] {
        return filter{ $0.isEmoji }.flatMap { $0.unicodeScalars }
    }
}

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        return unicodeScalars.count == 1 && unicodeScalars.first?.properties.isEmojiPresentation ?? false
    }
    
    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool {
        return unicodeScalars.count > 1 &&
            unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector }
    }
    
    var isEmoji: Bool {
        return isSimpleEmoji || isCombinedIntoEmoji
    }
}

func SubtractCoinAmount(currCoin: Coin, amount: Double) -> Double {
    let diff = Double(currCoin.amount) - amount
    if diff < 0 {
        return -1.0
    }
    return diff
}

func roundAmountNum(amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 7
    formatter.minimumIntegerDigits = 1
    
    return formatter.string(from: NSNumber(value: amount)) ?? ""
}

func formatAmountToStr(amount: Double) -> String {
    var amountStr = "∞"
    if amount != -1 {
        amountStr = roundAmountNum(amount: amount)
    }
    return amountStr
}

func showAlertMessage(title: String, message: String, actionMessage: String, navigationController: UINavigationController?) {
    guard let navigationController = navigationController else { return }
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: actionMessage, style: UIAlertAction.Style.default, handler: nil))
    navigationController.present(alert, animated: true, completion: nil)
}

func showPayOrRequestVC(createdCoinData: [Coin], ownedByCoinData: [Coin], currUser: User?, recipientPerson: RecentPerson, navigationController: UINavigationController?) {
    guard let navigationController = navigationController, let currUser = currUser else { return }
    let payOrRequestVC = PayOrRequestViewController()
    payOrRequestVC.createdCoinData = createdCoinData
    payOrRequestVC.ownedByCoinData = ownedByCoinData
    payOrRequestVC.currUser = currUser
    payOrRequestVC.recipientPerson = recipientPerson
    navigationController.pushViewController(payOrRequestVC, animated: false)
}

func parseTransactionSnapshot(value: NSDictionary, transId: String) -> Transaction {
    
    var fromUsers = [CoinUser]()
    if let fromSnapshot = value["from"] as? [String: NSDictionary] {
        for user in fromSnapshot {
            if let userValue = user.value as? [String: Any] {
                let coinUser = CoinUser(fullName: userValue["name"] as? String ?? "", profileImage: userValue["image"] as? String ?? "", id: user.key, phoneNumber: userValue["phoneNumber"] as? String ?? "")
                
                fromUsers.append(coinUser)
            }
        }
    }
    
    var toUsers = [CoinUser]()
    if let toSnapshot = value["to"] as? [String: NSDictionary] {
        for user in toSnapshot {
            if let userValue = user.value as? [String: Any] {
                let coinUser = CoinUser(fullName: userValue["name"] as? String ?? "", profileImage: userValue["image"] as? String ?? "", id: user.key, phoneNumber: userValue["phoneNumber"] as? String ?? "")
                
                toUsers.append(coinUser)
            }
        }
    }
    
    let message = value["message"] as? String ?? ""
    let coinName = value["coinName"] as? String ?? ""
    let coinImage = value["coinImage"] as? String ?? ""
    let amount = value["amount"] as? String ?? ""
    let timeStamp = value["timeStamp"] as? Double ?? 0.0
    
    let transaction = Transaction(from: fromUsers, to: toUsers, message: message, coinName: coinName, coinImage: coinImage, amount: amount, id: transId, timeStamp: timeStamp)
    
    return transaction
}

func showProfileDetailVC(selectedUser: CoinUser, createdCoinData: [Coin], ownedByCoinData: [Coin], currUser: User?, navigationController: UINavigationController?) {
    guard let navigationController = navigationController, let currUser = currUser else { return }
    let profileDetailVC = ProfileDetailViewController()
    profileDetailVC.selectedUser = selectedUser
    profileDetailVC.createdCoinData = createdCoinData
    profileDetailVC.ownedByCoinData = ownedByCoinData
    profileDetailVC.currUser = currUser
    navigationController.pushViewController(profileDetailVC, animated: true)
}

extension Bundle {
    // Name of the app - title under the icon.
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
            object(forInfoDictionaryKey: "CFBundleName") as? String
    }
}

class unselectableTextView: UITextView {
    override func becomeFirstResponder() -> Bool {
        return false
    }
}

func drawHamburgerIcon() -> UIImage {
    var defaultMenuImage = UIImage()
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: 22, height: 25), false, 0.0)
    
    UIColor.black.setFill()
    UIBezierPath(rect: CGRect(x: 0, y: 4, width: 20, height: 1)).fill()
    UIBezierPath(rect: CGRect(x: 0, y: 11, width: 20, height: 1)).fill()
    UIBezierPath(rect: CGRect(x: 0, y: 18, width: 20, height: 1)).fill()
    
    UIColor.white.setFill()
    UIBezierPath(rect: CGRect(x: 0, y: 5, width: 20, height: 1)).fill()
    UIBezierPath(rect: CGRect(x: 0, y: 12, width: 20, height: 1)).fill()
    UIBezierPath(rect: CGRect(x: 0, y: 19, width: 20, height: 1)).fill()
    defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
    
    UIGraphicsEndImageContext()
    
    return defaultMenuImage;
}

class ReceivesViewController: PurchasesViewController {
    override func fetchTransactions() {
        guard let currUser = self.currUser else { return }
        
        self.transactionData = [Transaction]()
        FirebaseHelper.sharedInstance.fetchReceivesTransactions(user: currUser, viewController: self) { (snapshot) in
            for snap in snapshot {
                if let value = snap.value as? NSDictionary {
                    self.transactionData.append(parseTransactionSnapshot(value: value, transId: snap.key))
                }
            }
            self.transTableView.reloadData()
        }
    }
}

class HamburgerIconButton: UIButton {
    
    override func draw(_ rect: CGRect) {
        
        // thickness of your line
        let lineThick:CGFloat = 1.0
        
        // length of your line relative to your button
        let lineLength:CGFloat = min(bounds.width, bounds.height) * 0.8
        
        // color of your line
        let lineColor: UIColor = UIColor.black
        
        // this will add small padding from button border to your first line and other lines
        let marginGap: CGFloat = 5.0
        
        // we need three line
        for line in 0...2 {
            // create path
            let linePath = UIBezierPath()
            linePath.lineWidth = lineThick
            
            //start point of line
            linePath.move(to: CGPoint(
                x: bounds.width/2 - lineLength/2,
                y: 6.0 * CGFloat(line) + marginGap
            ))
            
            //end point of line
            linePath.addLine(to: CGPoint(
                x: bounds.width/2 + lineLength/2,
                y: 6.0 * CGFloat(line) + marginGap
            ))
            //set line color
            lineColor.setStroke()
            
            //draw the line
            linePath.stroke()
        }
        
    }
}
