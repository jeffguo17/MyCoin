//
//  Constants.swift
//  MyCoin
//
//  Created by jeff on 9/20/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

struct Coin {
    var name: String
    var imageURL: String
    var id: String
    var amount: Int
}

struct User {
    var firstName: String
    var lastName: String
    var profileImage: String
    var id: String
}

struct Transaction {
    var from: String
    var fromImage: String
    var to: String
    var message: String
    var coinName: String
    var coinImage: String
    var amount: String
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
}

func showAlertMessage(title: String, message: String, actionMessage: String, navigationController: UINavigationController?) {
    guard let navigationController = navigationController else { return }
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: actionMessage, style: UIAlertAction.Style.default, handler: nil))
    navigationController.present(alert, animated: true, completion: nil)
}
