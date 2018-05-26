/*
 The MIT License (MIT)
 
 Copyright (c) 2015 Max Konovalov
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit

@available(*, unavailable, renamed: "RingProgressLayer")
public final class MKRingProgressLayer {}

@objc(MKRingProgressLayer)
open class RingProgressLayer: CALayer {
    
    /// The progress ring start color.
    @objc open var startColor = UIColor.red.cgColor {
        didSet {
            setNeedsRedrawContents()
        }
    }
    
    /// The progress ring end color.
    @objc open var endColor = UIColor.blue.cgColor {
        didSet {
            setNeedsRedrawContents()
        }
    }
    
    /// The color of the background ring.
    @objc open var backgroundRingColor: CGColor? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The width of the progress ring.
    @objc open var ringWidth: CGFloat = 20 {
        didSet {
            setNeedsRedrawContents()
        }
    }
    
    /// The style of the progress line end (rounded or straight).
    @objc open var progressStyle: RingProgressViewStyle = .round {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The opacity of the shadow under the progress end.
    @objc open var endShadowOpacity: CGFloat = 1.0 {
        didSet {
            endShadowOpacity = min(max(endShadowOpacity, 0), 1)
            setNeedsDisplay()
        }
    }
    
    /// Whether or not to allow anti-aliasing for the generated image.
    @objc open var allowsAntialiasing: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// The scale of the generated gradient image.
    /// Use lower values for better performance and higher values for more precise gradients.
    @objc open var gradientImageScale: CGFloat = 1.0 {
        didSet {
            setNeedsRedrawContents()
        }
    }
    
    /// The current progress shown by the view.
    /// Values less than 0.0 are clamped. Values greater than 1.0 present multiple revolutions of the progress ring.
    @NSManaged public var progress: CGFloat
    
    override open static func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override open func action(forKey event: String) -> CAAction? {
        if event == "progress" {
            if let action = super.action(forKey: "opacity") as? CABasicAnimation {
                let animation = action.copy() as! CABasicAnimation
                animation.keyPath = event
                animation.fromValue = presentation()?.value(forKey: event)
                animation.toValue = nil
                return animation
            } else {
                let animation = CABasicAnimation(keyPath: event)
                animation.duration = 0.001
                return animation
            }
        }
        return super.action(forKey: event)
    }
    
    override init() {
        super.init()
        setup()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        if let layer = layer as? RingProgressLayer {
            self.progress = layer.progress
        }
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.contentsScale = UIScreen.main.scale
    }
    
    
    private func setNeedsRedrawContents() {
        _gradientImage = nil
        setNeedsDisplay()
    }
    
    override open func display() {
        self.contents = contentImage()
    }
    
    private var _gradientImage: CGImage?
    
    private func gradientImage() -> CGImage {
        if _gradientImage == nil {
            let r = min(bounds.width, bounds.height)/2
            let r2 = r - ringWidth/2
            let s = Float(1.5 * ringWidth / (2 * .pi * r2))
            _gradientImage = GradientGenerator.gradientImage(type: .conical,
                                                             size: CGSize(width: r, height: r),
                                                             colors: [endColor, endColor, startColor, startColor],
                                                             locations: [0.0, s, (1.0 - s), 1.0],
                                                             endPoint: CGPoint(x: 0.5 - CGFloat(2 * s), y: 1.0),
                                                             scale: gradientImageScale)
        }
        return _gradientImage!
    }
    
    func contentImage() -> CGImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        ctx.setShouldAntialias(allowsAntialiasing)
        ctx.setAllowsAntialiasing(allowsAntialiasing)
        
        let w = ringWidth
        let r = min(bounds.width, bounds.height)/2 - w/2
        let c = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let p = max(0.0, presentation()?.progress ?? 0.0)
        let angleOffset = CGFloat.pi / 2
        let angle = 2 * .pi * p - angleOffset
        let minAngle = 1.1 * atan(0.5 * w / r)
        let maxAngle = 2 * .pi - 3 * minAngle - angleOffset
        
        let circleRect = CGRect(x: bounds.width/2 - r, y: bounds.height/2 - r, width: 2*r, height: 2*r)
        let circlePath = UIBezierPath(ovalIn: circleRect)
        
        let angle1 = angle > maxAngle ? maxAngle : angle
        let arc1Path = UIBezierPath(arcCenter: c, radius: r, startAngle: -angleOffset, endAngle: angle1, clockwise: true)
        
        ctx.setLineWidth(w)
        ctx.setLineCap(progressStyle.lineCap)
        
        // Draw backdrop circle
        
        ctx.addPath(circlePath.cgPath)
        let bgColor = backgroundRingColor ?? startColor.copy(alpha: 0.15)
        ctx.setStrokeColor(bgColor!)
        ctx.strokePath()
        
        // Draw solid arc
        
        if angle > maxAngle {
            let offset = angle - maxAngle
            
            let arc2Path = UIBezierPath(arcCenter: c, radius: r, startAngle: -angleOffset, endAngle: offset, clockwise: true)
            ctx.addPath(arc2Path.cgPath)
            ctx.setStrokeColor(startColor)
            ctx.strokePath()
            
            ctx.translateBy(x: circleRect.midX, y: circleRect.midY)
            ctx.rotate(by: offset)
            ctx.translateBy(x: -circleRect.midX, y: -circleRect.midY)
        }
        
        // Draw shadow
        
        ctx.saveGState()
        
        ctx.addPath(CGPath(__byStroking: circlePath.cgPath, transform: nil, lineWidth: w, lineCap: .round, lineJoin: .round, miterLimit: 0)!)
        ctx.clip()
        
        let shadowOffset = CGSize(width: w/10 * cos(angle + angleOffset), height: w/10 * sin(angle + angleOffset))
        ctx.setShadow(offset: shadowOffset, blur: w/3, color: UIColor(white: 0.0, alpha: endShadowOpacity).cgColor)
        let arcEnd = CGPoint(x: c.x + r * cos(angle1), y: c.y + r * sin(angle1))
        
        let shadowPath: UIBezierPath = {
            switch progressStyle {
            case .round:
                return UIBezierPath(ovalIn: CGRect(x: arcEnd.x - w/2, y: arcEnd.y - w/2, width: w, height: w))
            case .square:
                let path = UIBezierPath(rect: CGRect(x: arcEnd.x - w/2, y: arcEnd.y - 2, width: w, height: 2))
                path.apply(CGAffineTransform(translationX: -arcEnd.x, y: -arcEnd.y))
                path.apply(CGAffineTransform(rotationAngle: angle1))
                path.apply(CGAffineTransform(translationX: arcEnd.x, y: arcEnd.y))
                return path
            }
        }()
        
        ctx.addPath(shadowPath.cgPath)
        ctx.setFillColor(startColor)
        ctx.fillPath()
        
        ctx.restoreGState()
        
        // Draw gradient arc
        
        ctx.saveGState()
        
        ctx.addPath(CGPath(__byStroking: arc1Path.cgPath,
                           transform: nil,
                           lineWidth: w,
                           lineCap: progressStyle.lineCap,
                           lineJoin: progressStyle.lineJoin,
                           miterLimit: 0)!)
        ctx.clip()
        
        // TODO: Detect same start/end color
        ctx.draw(gradientImage(), in: circleRect.insetBy(dx: -w/2, dy: -w/2))
        
        ctx.restoreGState()
        
        ///////
        
        let img = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
        UIGraphicsEndImageContext()
        
        return img
    }
    
}

fileprivate extension RingProgressViewStyle {
    
    var lineCap: CGLineCap {
        switch self {
        case .round:
            return .round
        case .square:
            return .butt
        }
    }
    
    var lineJoin: CGLineJoin {
        switch self {
        case .round:
            return .round
        case .square:
            return .miter
        }
    }
    
}

