//
//  ViewController.swift
//  MKRingProgressViewExample
//
//  Created by Max Konovalov on 20/10/15.
//  Copyright © 2015 Max Konovalov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var groupContainerView: UIView!
    @IBOutlet weak var progressGroup: MKRingProgressGroupView!
    
    @IBOutlet weak var iconsHeightConstraint: NSLayoutConstraint!
    
    var buttons = [MKRingProgressGroupButton]()
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let containerView = UIView(frame: navigationController!.navigationBar.bounds)
        navigationController!.navigationBar.addSubview(containerView)
        
        let n = 7
        for i in 0..<n {
            let w = (containerView.bounds.width - 16) / CGFloat(n)
            let h = containerView.bounds.height
            let button = MKRingProgressGroupButton(frame: CGRect(x: 8 + CGFloat(i) * w, y: 0, width: w, height: h))
            button.contentView.ringWidth = 4.5
            button.contentView.ringSpacing = 1
            button.contentView.ring1StartColor = progressGroup.ring1StartColor
            button.contentView.ring1EndColor = progressGroup.ring1EndColor
            button.contentView.ring2StartColor = progressGroup.ring2StartColor
            button.contentView.ring2EndColor = progressGroup.ring2EndColor
            button.contentView.ring3StartColor = progressGroup.ring3StartColor
            button.contentView.ring3EndColor = progressGroup.ring3EndColor
            containerView.addSubview(button)
            buttons.append(button)
            button.addTarget(self, action: #selector(ViewController.buttonTapped(_:)), for: .touchUpInside)
        }
        
        buttons[0].isSelected = true
        
        randomize()
        
        
        delay(0.5) {
            self.updateMainGroupProgress()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        progressGroup.ringWidth = view.bounds.width * 0.08
        iconsHeightConstraint.constant = progressGroup.ringWidth * 3 + progressGroup.ringSpacing * 2
    }
    
    func buttonTapped(_ sender: MKRingProgressGroupButton) {
        let newIndex = buttons.index(of: sender) ?? 0
        if newIndex == selectedIndex {
            return
        }
        
        let dx = (newIndex > selectedIndex) ? -self.view.frame.width : self.view.frame.width
        
        buttons[selectedIndex].isSelected = false
        sender.isSelected = true
        selectedIndex = newIndex
        
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
            self.groupContainerView.transform = CGAffineTransform(translationX: dx, y: 0)
            }) { (_) -> Void in
                self.groupContainerView.transform = CGAffineTransform(translationX: -dx, y: 0)
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.0)
                self.progressGroup.ring1.progress = 0.0
                self.progressGroup.ring2.progress = 0.0
                self.progressGroup.ring3.progress = 0.0
                CATransaction.commit()
                UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                    self.groupContainerView.transform = CGAffineTransform.identity
                    }, completion: { (_) -> Void in
                        self.updateMainGroupProgress()
                })
        }
    }
    
    private func updateMainGroupProgress() {
        let selectedGroup = buttons[selectedIndex]
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.0)
        self.progressGroup.ring1.progress = selectedGroup.contentView.ring1.progress
        self.progressGroup.ring2.progress = selectedGroup.contentView.ring2.progress
        self.progressGroup.ring3.progress = selectedGroup.contentView.ring3.progress
        CATransaction.commit()
    }
    
    @IBAction func randomize(_ sender: AnyObject? = nil) {
        for button in buttons {
            button.contentView.ring1.progress = Double(arc4random() % 200) / 100.0
            button.contentView.ring2.progress = Double(arc4random() % 200) / 100.0
            button.contentView.ring3.progress = Double(arc4random() % 200) / 100.0
        }
        updateMainGroupProgress()
    }
    
    
}

func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
