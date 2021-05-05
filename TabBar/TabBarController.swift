//
//  TabBarController.swift
//  TabBar
//
//  Created by Nishant Taneja on 05/05/21.
//

import UIKit

protocol TabBarControllerDataSource: AnyObject {
    func tabBar(controller: TabBarController, viewFor index: Int) -> UIView
}

protocol TabBarControllerDelegate: AnyObject {
    func tabBar(_ tabBar: TabBarController, didSelectViewAt index: Int, on controller: UIViewController)
}

final class TabBarController: UIViewController {
    static let shared = TabBarController()
    // Delegate/DataSource
    weak var dataSource: TabBarControllerDataSource?
    weak var delegate: TabBarControllerDelegate?
    // Controller
    weak var controller: UIViewController!
    // Constants
    private let numberOfIcons:CGFloat = 5
    private let iconHeight: CGFloat = 48
    private let padding: CGFloat = 20
    // Layer
    private var shapeLayer: CAShapeLayer!
    // Views
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        let width = (numberOfIcons * iconHeight) + (numberOfIcons + 1)*padding
        view.frame.size = .init(width: width, height: iconHeight + 2*padding)
        view.frame.origin.y = self.view.frame.height - view.frame.height
        view.frame.origin.x = (self.view.frame.width - view.frame.width)/2
        return view
    }()
    private lazy var iconsContainerView: UIView = {
        let view = UIView()
        view.frame = self.view.frame
        view.backgroundColor = .clear
        guard dataSource != nil else { return view }
        for index in 0..<Int(numberOfIcons) {
            let icon = dataSource!.tabBar(controller: self, viewFor: index)
            icon.layer.cornerRadius = iconHeight/2
            icon.isUserInteractionEnabled = true
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewSelection(_:))))
            icon.tag = index
            // Frame
            let size: CGSize = .init(width: iconHeight, height: iconHeight)
            let originX: CGFloat = (view.frame.width - backgroundView.frame.width)/2 + CGFloat(index + 1)*padding + CGFloat(index)*iconHeight
            let originY: CGFloat = view.frame.height - backgroundView.frame.height + padding
            icon.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
            view.addSubview(icon)
        }
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBackgroundView()
        view.addSubview(iconsContainerView)
        updateView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        initShapeLayer()
    }
}

extension TabBarController {
    // View
    private func updateView() {
        view.layer.cornerRadius = iconHeight / 2
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowRadius = 5
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = .zero
    }
    
    // BackgroundView
    private func initBackgroundView() {
        view.addSubview(backgroundView)
        backgroundView.layer.cornerRadius = iconHeight/2
    }
    
    // ShapeLayer
    private var shapeLayerPath: CGPath {
        let height = backgroundView.frame.height
        let path = UIBezierPath()
        let centerWidth = backgroundView.frame.width / 2
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: (centerWidth - height ), y: 0))
        path.addCurve(to: CGPoint(x: centerWidth, y: height/2),
                      controlPoint1: CGPoint(x: (centerWidth - 30), y: 0), controlPoint2: CGPoint(x: centerWidth - 35, y: height/2))
        path.addCurve(to: CGPoint(x: (centerWidth + height), y: 0),
                      controlPoint1: CGPoint(x: centerWidth + 35, y: height/2), controlPoint2: CGPoint(x: (centerWidth + 30), y: 0))
        path.addLine(to: CGPoint(x: backgroundView.frame.width, y: 0))
        path.addLine(to: CGPoint(x: backgroundView.frame.width, y: backgroundView.frame.height))
        path.addLine(to: CGPoint(x: 0, y: backgroundView.frame.height))
        path.close()
        return path.cgPath
    }
    
    private func initShapeLayer() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = shapeLayerPath
        shapeLayer.frame = backgroundView.bounds
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 0.5
        shapeLayer.shadowOffset = .zero
        shapeLayer.shadowRadius = 5
        shapeLayer.shadowColor = UIColor.darkGray.cgColor
        shapeLayer.shadowOpacity = 0.5
        if let oldShapeLayer = self.shapeLayer {
            backgroundView.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            backgroundView.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }
}

extension TabBarController {
    @objc private func handleViewSelection(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        delegate?.tabBar(self, didSelectViewAt: view.tag, on: controller)
    }
}

extension TabBarController {
    func showTabBar(on controller: UIViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.controller = controller
            self.view.frame.origin = .init(x: (controller.view.frame.width - self.view.frame.width)/2, y: controller.view.frame.height)
            self.view.alpha = 0
            controller.addChild(self)
            controller.view.addSubview(self.view)
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut) {
                self.view.alpha = 1
                self.view.frame.origin.y = controller.view.frame.height - self.view.frame.height - controller.view.safeAreaInsets.bottom
                self.iconsContainerView.subviews[Int(self.numberOfIcons/2)].transform = .init(translationX: 0, y: -self.iconHeight)
            }
        }
    }
    
    func hideTabBar() {
        guard controller != nil else { return }
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.alpha = 10
            self.view.frame.origin.y = self.controller!.view.frame.height + self.iconHeight
        } completion: { _ in
            self.removeFromParent()
            self.view.removeFromSuperview()
        }
    }
}
