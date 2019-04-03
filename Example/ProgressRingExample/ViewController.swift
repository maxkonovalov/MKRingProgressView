//
//  ViewController.swift
//  RingProgressExample
//
//  Created by Max Konovalov on 21/10/2018.
//  Copyright © 2018 Max Konovalov. All rights reserved.
//

import MKRingProgressView
import UIKit

class ViewController: UIViewController {
    @IBOutlet var ringProgressView: RingProgressView!
    @IBOutlet var valueLabel: UILabel!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ringProgressView.ringWidth = ringProgressView.bounds.width * 0.2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if case let parametersViewController as ParametersViewController = segue.destination {
            parametersViewController.delegate = self
        }
    }
}

extension ViewController: ParametersViewControllerDelegate {
    func parametersViewControllerDidChangeProgress(_ progress: Double) {
        ringProgressView.progress = progress
        valueLabel.text = String(format: "%.2f", progress)
    }
    
    func parametersViewControllerDidChangeStyle(_ style: RingProgressViewStyle) {
        ringProgressView.style = style
    }
    
    func parametersViewControllerDidChangeShadowOpacity(_ shadowOpacity: CGFloat) {
        ringProgressView.shadowOpacity = shadowOpacity
    }
    
    func parametersViewControllerDidChangeHidesRingForZeroProgressValue(_ hidesRingForZeroProgress: Bool) {
        ringProgressView.hidesRingForZeroProgress = hidesRingForZeroProgress
    }
}
