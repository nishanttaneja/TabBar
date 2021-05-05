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
    private let iconHeight: CGFloat = 48
    private let padding: CGFloat = 16
    // Layer
    private var shapeLayer: CAShapeLayer!
    // Views
    private let backgroundView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var iconsStackView: UIStackView = {
        var arrangedSubViews = [UIView]()
        if dataSource != nil {
            for index in 0..<5 {
                let view = dataSource!.tabBar(controller: self, viewFor: index)
                view.layer.cornerRadius = iconHeight/2
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewSelection(_:))))
                view.tag = index
                if index == 2 {
                    view.transform = CGAffineTransform(translationX: 0, y: -2*iconHeight/3)
                }
                arrangedSubViews.append(view)
            }
        }
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        stackView.layoutMargins = .init(top: padding, left: padding, bottom: padding, right: padding)
        stackView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(stackView)
        let numberOfIcons = CGFloat(arrangedSubViews.count)
        stackView.frame.size = CGSize(width:  numberOfIcons * iconHeight + (numberOfIcons + 1)*padding, height: iconHeight + (2 * padding))
        view.frame.size = stackView.frame.size
        backgroundView.frame = stackView.frame
        return stackView
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        initBackgroundView()
        initIconsStackView()
        initShapeLayer()
    }
}

extension TabBarController {
    // View
    private func updateView() {
        view.backgroundColor = .clear
        view.layer.cornerRadius = iconHeight / 2
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowRadius = iconHeight/2
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
    }
    
    // BackgroundView
    private func initBackgroundView() {
        view.addSubview(backgroundView)
        backgroundView.layer.cornerRadius = iconHeight/2
    }
    
    // IconsStack
    private func initIconsStackView() {
        view.addSubview(iconsStackView)
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
        shapeLayer.shadowRadius = iconHeight/2
        shapeLayer.shadowColor = UIColor.darkGray.cgColor
        shapeLayer.shadowOpacity = 0.2
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
