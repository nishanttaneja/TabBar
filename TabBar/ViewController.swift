//
//  ViewController.swift
//  TabBar
//
//  Created by Nishant Taneja on 05/05/21.
//

import UIKit

class ViewController: UIViewController {
    private let tabBarC = TabBarController(nibName: nil, bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        initTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showTabBar()
    }
}

extension ViewController {
    private func initTabBar() {
        addChild(tabBarC)
        tabBarC.view.frame.size = CGSize(width: 400, height: 100)   // Should not be required
        tabBarC.view.frame.origin = .init(x: (self.view.frame.width - self.tabBarC.view.frame.width)/2, y: view.frame.height)
        tabBarC.view.alpha = 0
        view.addSubview(tabBarC.view)
    }
    
    private func showTabBar() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.tabBarC.view.alpha = 1
            self.tabBarC.view.frame.origin.y = self.view.frame.height - self.tabBarC.view.frame.height - self.view.safeAreaInsets.bottom
        }
    }
}

final class TabBarController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
}
