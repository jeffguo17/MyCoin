//
//  SideMenuLogicViewController.swift
//  MyCoin
//
//  Created by jeff on 10/29/19.
//  Copyright © 2019 jeff. All rights reserved.
//

import UIKit
import SideMenu

class SideMenuLogicViewController: UIViewController, SideMenuNavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        //print("SideMenu Appearing! (animated: \(animated))")
        if let lastVC = getLastVC() {
            lastVC.view.alpha = 0.4
        }
        self.navigationController?.navigationBar.alpha = 0.4
    }
    
    func sideMenuDidAppear(menu: SideMenuNavigationController, animated: Bool) {
        //print("SideMenu Appeared! (animated: \(animated))")
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        //print("SideMenu Disappearing! (animated: \(animated))")
    }
    
    func sideMenuDidDisappear(menu: SideMenuNavigationController, animated: Bool) {
        //print("SideMenu Disappeared! (animated: \(animated))")
        if let lastVC = getLastVC() {
            lastVC.view.alpha = 1
        }
        self.navigationController?.navigationBar.alpha = 1
    }
    
    func getLastVC() -> UIViewController? {
        guard let viewControllers = self.navigationController?.viewControllers else { return nil }
        
        if (viewControllers.count - 1) >= 0 {
            let lastVC = viewControllers[viewControllers.count - 1]
            
            return lastVC
        }
        
        return nil
    }
    
}
