//
//  Icon.swift
//  ProgressRingExample
//
//  Created by Max Konovalov on 22/10/2018.
//  Copyright © 2018 Max Konovalov. All rights reserved.
//

import UIKit
import MKRingProgressView

func generateAppIcon(scale: CGFloat = 1.0) -> UIImage {
    let size = CGSize(width: 512, height: 512)
    let rect = CGRect(origin: .zero, size: size)
    
    let icon = UIView(frame: rect)
    icon.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    let ring = RingProgressView(frame: icon.bounds.insetBy(dx: 66, dy: 66))
    ring.ringWidth = 93
    ring.startColor = #colorLiteral(red: 1, green: 0.07450980392, blue: 0.3254901961, alpha: 1)
    ring.endColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
    ring.progress = 1.0
    icon.addSubview(ring)
    
    UIGraphicsBeginImageContextWithOptions(size, true, scale)
    icon.drawHierarchy(in: rect, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return image
}
