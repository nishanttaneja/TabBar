//
//  ViewController.swift
//  TabBar
//
//  Created by Nishant Taneja on 05/05/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TabBarController.shared.dataSource = self
        TabBarController.shared.delegateLayout = self
        TabBarController.shared.showTabBar(on: self.view)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TabBarController.shared.setMoreOptions(false)
    }
}

extension ViewController: TabBarDataSource {
    func tabBar(viewForItemAt index: Int, moreOptionState isVisible: Bool) -> UIView {
        let button = UIButton(type: .system)
        button.setBackgroundImage([#imageLiteral(resourceName: "blue_like"), #imageLiteral(resourceName: "red_heart"), #imageLiteral(resourceName: "surprised"), #imageLiteral(resourceName: "cry_laugh"), #imageLiteral(resourceName: "cry"), #imageLiteral(resourceName: "cry"), #imageLiteral(resourceName: "cry")][index], for: .normal)
        return button
    }
    
    func tabBarNumberOfViews() -> Int {
        5
    }
}

extension ViewController: TabBarDelegateLayout {
    func tabBarContentViewHeight() -> CGFloat {
        40
    }
    
    func tabBarContentViewMargin() -> CGFloat {
        8
    }
    
    func tabBarInterViewSpacing() -> CGFloat {
        16
    }
    
    func tabBarBackgroundColor() -> UIColor {
        .red
    }
}

