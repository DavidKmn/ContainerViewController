//
//  ViewController.swift
//  ContainerViewController
//
//  Created by David on 20/10/2018.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    let colors: [UIColor] = [.red, .blue, .green, .yellow, .gray, .purple, .magenta]
    let allAvailableChilderVCs = [ChildViewController1(), ChildViewController2(), ChildViewController3()]

    lazy var height = view.frame.height / 3
    
    let explanationLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap on the white space to add a VC \n Tap on the VC to remove it"
        label.textAlignment = .center
        label.textColor = UIColor.black 
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(explanationLabel)
        explanationLabel.center = view.center
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAddVCTap)))
    }
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool { return false }
    
    @objc func handleAddVCTap() {
        var vcToAdd: UIViewController?
        guard self.children != allAvailableChilderVCs else { return }
        if !(self.children.isEmpty) {
            allAvailableChilderVCs.forEach({ if children.contains($0) == false {
                vcToAdd = $0
            } })
        } else {
            vcToAdd = allAvailableChilderVCs.first
        }
        
        if let vcToAdd = vcToAdd {
            _ = addViewController(vc: setup(vc: vcToAdd), withHeight: height)
        }
    }
    
    @objc func handleRemoveVCTap() {
        guard !(self.children.isEmpty) else { return }
        if let vcToRemove = getLastAddedViewController() {
            _ = removeViewController(vc: vcToRemove)
        }
    }
    
    func setup(vc: UIViewController) -> UIViewController {
        vc.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleRemoveVCTap)))
        vc.view.backgroundColor = colors.randomElement()
        return vc
    }
    
    func addViewController(vc: UIViewController, withHeight height: CGFloat) -> UIViewController {
        let yOriginPoint: CGFloat
        if let lastVCEndYPoint = getLastAddedViewController()?.view.frame.maxY {
            yOriginPoint = lastVCEndYPoint
        } else {
            yOriginPoint = self.view.frame.minY
        }
        self.addChild(vc)
        vc.view.frame = CGRect(x: view.frame.origin.x, y: yOriginPoint, width: view.frame.width, height: height)
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
        return vc
    }
    
    func getLastAddedViewController() -> UIViewController? {
        return self.children.last
    }
    
    func removeViewController(vc: UIViewController) -> UIViewController {
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
        return vc
    }
    
}

extension ContainerViewController {
    func transition(fromVC: UIViewController, toVC: UIViewController) {
        fromVC.willMove(toParent: nil)
        self.addChild(toVC)
        
        toVC.view.frame = CGRect(x: self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let endFrame = CGRect(x: 0 - self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        transition(from: fromVC, to: toVC, duration: 0.25, options: [.transitionCrossDissolve,.curveEaseOut], animations: {
            toVC.view.frame = fromVC.view.frame
            fromVC.view.frame = endFrame
        }) { (completed) in
            fromVC.removeFromParent()
            toVC.didMove(toParent: self)
        }
    }
}

