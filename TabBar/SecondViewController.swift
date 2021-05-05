//
//  SecondViewController.swift
//  TabBar
//
//  Created by Nishant Taneja on 05/05/21.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TabBarController.shared.showTabBar(on: self)
    }
}
