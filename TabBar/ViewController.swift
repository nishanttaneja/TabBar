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
//        view.backgroundColor = .blue
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        TabBarController.shared.dataSource = self
        TabBarController.shared.delegate = self
        TabBarController.shared.delegateLayout = self
        TabBarController.shared.showTabBar(on: self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        TabBarController.shared.setMoreOptions(isVisible: false)
    }
}

extension ViewController: TabBarDataSource {
    func tabBarNumberOfViews() -> Int {
        5
    }
    
    func tabBar(viewForItemAt index: Int) -> UIView {
        let button = UIButton(type: .system)
        button.setBackgroundImage([#imageLiteral(resourceName: "blue_like"), #imageLiteral(resourceName: "red_heart"), #imageLiteral(resourceName: "surprised"), #imageLiteral(resourceName: "cry_laugh"), #imageLiteral(resourceName: "cry"), #imageLiteral(resourceName: "cry"), #imageLiteral(resourceName: "cry")][index], for: .normal)
        button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        return button
    }
    
    @objc private func handleButton() {
        print(#function)
    }
}

extension ViewController: TabBarDelegate {
    func tabBar(willDisplay views: [UIView]) {
        print(#function)
    }
    
    func tabBar(didSelectViewAt index: Int, on controller: UIViewController) {
        print(#function, index)
        guard index != tabBarNumberOfViews()/2 else { return }
        TabBarController.shared.hideTabBar()
        if controller == self {
            performSegue(withIdentifier: "show", sender: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
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

