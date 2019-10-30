//
//  NotificationViewController.swift
//  MyCoin
//
//  Created by jeff on 10/29/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import SideMenu

class NotificationViewController: SideMenuLogicViewController {
    
    var leftMenuNavigationController: SideMenuNavigationController?
    
    fileprivate let textView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addSideMenu()
        // Do any additional setup after loading the view.
        self.title = "Notifications"
        view.backgroundColor = .white
        
        view.addSubview(textView)
        
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        textView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let notificationText = NSMutableAttributedString(string: "No Notifications\n\n", attributes: [.paragraphStyle: paragraph])
        notificationText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 24), range: NSMakeRange(0, notificationText.length))
        
        let notificationMessageText = NSMutableAttributedString(string: "You can find things that require your attention here.", attributes: [.paragraphStyle: paragraph])
        notificationMessageText.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18), range: NSMakeRange(0, notificationMessageText.length))
            
        notificationText.append(notificationMessageText)
        textView.attributedText = notificationText
    }

    @objc fileprivate func showSideMenu() {
        if let leftMenuNavigationController = self.leftMenuNavigationController {
            present(leftMenuNavigationController, animated: true, completion: nil)
        }
    }
    
    fileprivate func addSideMenu() {
        let btnShowMenu = UIButton(type: .system)
        btnShowMenu.setImage(drawHamburgerIcon(), for: UIControl.State())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 22, height: 25)
        btnShowMenu.addTarget(self, action: #selector(showSideMenu), for: .touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }
}
