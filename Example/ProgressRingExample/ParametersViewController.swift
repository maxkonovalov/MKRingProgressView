//
//  ParametersViewController.swift
//  ProgressRingExample
//
//  Created by Max Konovalov on 22/10/2018.
//  Copyright © 2018 Max Konovalov. All rights reserved.
//

import MKRingProgressView
import UIKit

protocol ParametersViewControllerDelegate: class {
    func parametersViewControllerDidChangeProgress(_ progress: Double)
    func parametersViewControllerDidChangeStyle(_ style: RingProgressViewStyle)
    func parametersViewControllerDidChangeShadowOpacity(_ shadowOpacity: CGFloat)
    func parametersViewControllerDidChangeHidesRingForZeroProgressValue(_ hidesRingForZeroProgress: Bool)
}

class ParametersViewController: UITableViewController {
    weak var delegate: ParametersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func progressChanged(_ sender: UISlider) {
        let progress = Double(sender.value)
        delegate?.parametersViewControllerDidChangeProgress(progress)
    }
    
    @IBAction func styleChanged(_ sender: UISegmentedControl) {
        guard let style = RingProgressViewStyle(rawValue: sender.selectedSegmentIndex) else {
            return
        }
        delegate?.parametersViewControllerDidChangeStyle(style)
    }
    
    @IBAction func shadowChanged(_ sender: UISwitch) {
        let shadowOpacity: CGFloat = sender.isOn ? 1.0 : 0.0
        delegate?.parametersViewControllerDidChangeShadowOpacity(shadowOpacity)
    }
    
    @IBAction func hidesRingForZeroProgressChanged(_ sender: UISwitch) {
        let hidesRingForZeroProgress = sender.isOn
        delegate?.parametersViewControllerDidChangeHidesRingForZeroProgressValue(hidesRingForZeroProgress)
    }
}
