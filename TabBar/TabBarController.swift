//
//  TabBarController.swift
//  TabBar
//
//  Created by Nishant Taneja on 05/05/21.
//

import UIKit

//MARK:- DataSource
protocol TabBarDataSource: AnyObject {
    func tabBarNumberOfViews() -> Int
    func tabBar(viewForItemAt index: Int, moreOptionState isVisible: Bool) -> UIView
}

//MARK:- Delegate
@objc protocol TabBarDelegate: AnyObject {
    @objc optional func tabBar(didSelectViewAt index: Int)
    @objc optional func tabBar(willDisplay views: [UIView])
}

//MARK:- DelegateLayout
@objc protocol TabBarDelegateLayout: AnyObject {
    @objc optional func tabBarContentViewHeight() -> CGFloat
    @objc optional func tabBarContentViewMargin() -> CGFloat
    @objc optional func tabBarInterViewSpacing() -> CGFloat
    @objc optional func tabBarBackgroundColor() -> UIColor
}

//MARK:- Controller
final class TabBarController: UIViewController {
    static let shared = TabBarController()

    // Views
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = .clear
        view.clipsToBounds = true
        let iconsCount = CGFloat(numberOfIcons)
        let width = (iconsCount * iconHeight) + (iconsCount - 1)*spacing + 2*margin
        view.frame.size = .init(width: width, height: iconHeight + 2*margin)
        self.view.frame.size.height = view.frame.height + iconHeight
        view.frame.origin.y = self.view.frame.height - view.frame.height
        view.frame.origin.x = (self.view.frame.width - view.frame.width)/2
        return view
    }()
    private lazy var iconsContainerView: UIView = {
        let view = UIView()
        view.frame = self.view.frame
        view.backgroundColor = .clear
        guard dataSource != nil else { return view }
        for index in 0..<numberOfIcons {
            let icon = dataSource!.tabBar(viewForItemAt: index, moreOptionState: isTransformed)
            icon.layer.cornerRadius = iconHeight/2
            icon.isUserInteractionEnabled = true
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewSelection(_:))))
            icon.tag = index
            // Frame
            let size: CGSize = .init(width: iconHeight, height: iconHeight)
            let originX: CGFloat = (view.frame.width - backgroundView.frame.width)/2 + margin + CGFloat(index)*spacing + CGFloat(index)*iconHeight
            let originY: CGFloat = view.frame.height - backgroundView.frame.height + margin
            icon.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
            // Mid
            if index == numberOfIcons/2 {
                icon.transform = .init(translationX: 0, y: -self.iconHeight).scaledBy(x: 1.1, y: 1.1)
                icon.backgroundColor = shapeLayerFillColor
            }
            view.addSubview(icon)
        }
        return view
    }()
    
    private func updateIcons() {
        guard dataSource != nil else { return }
        for index in 0..<numberOfIcons {
            let icon = dataSource!.tabBar(viewForItemAt: index, moreOptionState: !isTransformed)
            icon.layer.cornerRadius = iconHeight/2
            icon.isUserInteractionEnabled = true
            icon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleViewSelection(_:))))
            icon.tag = index
            // Frame
            let oldIcon = iconsContainerView.subviews[0]
            icon.frame = oldIcon.frame
            iconsContainerView.addSubview(icon)
            oldIcon.removeFromSuperview()
        }
    }
    
    // Delegates/DataSource
    weak var dataSource: TabBarDataSource? {
        didSet {
            numberOfIcons = dataSource?.tabBarNumberOfViews() ?? numberOfIcons
        }
    }
    weak var delegate: TabBarDelegate?
    weak var delegateLayout: TabBarDelegateLayout? {
        didSet {
            iconHeight = delegateLayout?.tabBarContentViewHeight?() ?? iconHeight
            margin = delegateLayout?.tabBarContentViewMargin?() ?? margin
            spacing = delegateLayout?.tabBarInterViewSpacing?() ?? spacing
            shapeLayerFillColor = delegateLayout?.tabBarBackgroundColor?() ?? shapeLayerFillColor
        }
    }
    // Constants
    private var numberOfIcons: Int = 3
    private var iconHeight: CGFloat = 48
    private var margin: CGFloat = 12
    private var spacing: CGFloat = 16
    private var shapeLayerFillColor: UIColor = UIColor.white
    // Layer
    private var shapeLayer: CAShapeLayer!
    // Properties
    private var isTransformed: Bool = false
}

//MARK:- View
extension TabBarController {
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
        view.backgroundColor = .clear
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
        shapeLayer.fillColor = shapeLayerFillColor.cgColor
        shapeLayer.shadowOffset = .zero
        shapeLayer.shadowRadius = 5
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

//MARK:- Interaction
extension TabBarController {
    @objc private func handleViewSelection(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        if view.tag == numberOfIcons/2 {
            setMoreOptions(isTransformed ? false : true)
        }
        else if isTransformed { setMoreOptions(false) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.delegate?.tabBar?(didSelectViewAt: view.tag)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isTransformed { setMoreOptions(false) }
        else if let point = touches.first?.location(in: backgroundView), !backgroundView.point(inside: point, with: event) {
            view.superview?.touchesBegan(touches, with: event)
        }
    }
}

//MARK:- Animations
extension TabBarController {
    func showTabBar(on view: UIView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.view.frame.origin = .init(x: (view.frame.width - self.view.frame.width)/2, y: view.frame.height)
            self.view.alpha = 0
            view.addSubview(self.view)
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut) {
                self.view.alpha = 1
                let bottomInset = view.safeAreaInsets.bottom == 0 ? 16 : view.safeAreaInsets.bottom
                self.view.frame.origin.y = view.frame.height - self.view.frame.height - bottomInset
            }
        }
    }
    
    func setMoreOptions(_ bool: Bool) {
        guard isTransformed != bool else { return }
        updateIcons()
        delegate?.tabBar?(willDisplay: iconsContainerView.subviews)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.backgroundView.transform = self.isTransformed ? .identity : .init(scaleX: 0, y: 0)
            let midIndex = self.numberOfIcons/2
            var translationY: CGFloat = 0
            for (index, icon) in self.iconsContainerView.subviews.enumerated() {
                if index == midIndex {
                    translationY = self.isTransformed ? -self.iconHeight : self.iconHeight
                } else if index < midIndex {
                    let value = 0.6*CGFloat(index + 1)*self.iconHeight
                    translationY = self.isTransformed ? value : -value
                } else if index > midIndex {
                    let value = 0.6*CGFloat(self.numberOfIcons - index)*self.iconHeight
                    translationY = self.isTransformed ? value : -value
                }
                icon.transform = .init(translationX: 0, y: translationY)
                icon.backgroundColor = self.isTransformed ? .clear : self.shapeLayerFillColor
                if index == midIndex {
                    icon.backgroundColor = self.shapeLayerFillColor
                } else {
                    icon.backgroundColor = self.isTransformed ? .clear : self.shapeLayerFillColor
                }
            }
        } completion: { _ in
            self.isTransformed = !self.isTransformed
        }
    }
}
