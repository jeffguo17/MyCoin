//
//  ViewController.swift
//  MyCoin
//
//  Created by jeff on 8/19/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationController()
        // Here we can check for network stability
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FirebaseHelper.sharedInstance.userIsLoggedIn(viewController: self)
        self.performSegue(withIdentifier: "showMainPage", sender: nil)
    }

}

