//
//  Icon.swift
//  MKRingProgressViewExample
//
//  Created by Max Konovalov on 25/05/2018.
//  Copyright © 2018 Max Konovalov. All rights reserved.
//

import UIKit

func generateAppIcon(scale: CGFloat = 1.0) -> UIImage {
    let size = CGSize(width: 512, height: 512)
    let rect = CGRect(origin: .zero, size: size)

    let icon = UIView(frame: rect)
    icon.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1176470588, blue: 0.1254901961, alpha: 1)

    let group = RingProgressGroupView(frame: icon.bounds.insetBy(dx: 33, dy: 33))
    group.ringWidth = 50
    group.ringSpacing = 10
    group.ring1StartColor = #colorLiteral(red: 0.8823529412, green: 0, blue: 0.07843137255, alpha: 1)
    group.ring1EndColor = #colorLiteral(red: 1, green: 0.1960784314, blue: 0.5294117647, alpha: 1)
    group.ring2StartColor = #colorLiteral(red: 0.2156862745, green: 0.862745098, blue: 0, alpha: 1)
    group.ring2EndColor = #colorLiteral(red: 0.7176470588, green: 1, blue: 0, alpha: 1)
    group.ring3StartColor = #colorLiteral(red: 0, green: 0.7294117647, blue: 0.8823529412, alpha: 1)
    group.ring3EndColor = #colorLiteral(red: 0, green: 0.9803921569, blue: 0.8156862745, alpha: 1)
    group.ring1.progress = 1.0
    group.ring2.progress = 1.0
    group.ring3.progress = 1.0
    icon.addSubview(group)

    UIGraphicsBeginImageContextWithOptions(size, true, scale)
    icon.drawHierarchy(in: rect, afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()

    return image
}
