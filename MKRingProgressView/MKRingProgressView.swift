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

// MARK: - Ring Progress View

@IBDesignable
open class MKRingProgressView: UIView {
    
    /* The ring color for lowest progress values (closer to 0.0). */
    
    @IBInspectable open var startColor: UIColor {
        get {
            return UIColor(cgColor: (layer as! MKRingProgressLayer).startColor)
        }
        set {
            (layer as! MKRingProgressLayer).startColor = newValue.cgColor
        }
    }
    
    /* The ring color for highest progress values (closer to 1.0) */
    
    @IBInspectable open var endColor: UIColor {
        get {
            return UIColor(cgColor: (layer as! MKRingProgressLayer).endColor)
        }
        set {
            (layer as! MKRingProgressLayer).endColor = newValue.cgColor
        }
    }
    
    /* The color of backdrop circle, visible at progress values between 0.0 and 1.0.
    * If not specified, `startColor` with 15% opacity will be used. */
    
    @IBInspectable open var backgroundRingColor: UIColor? {
        get {
            if let color = (layer as! MKRingProgressLayer).backgroundRingColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            (layer as! MKRingProgressLayer).backgroundRingColor = newValue?.cgColor
        }
    }
    
    /* The width of the progress ring. Defaults to 20. */
    
    @IBInspectable open var ringWidth: CGFloat {
        get {
            return (layer as! MKRingProgressLayer).ringWidth
        }
        set {
            (layer as! MKRingProgressLayer).ringWidth = newValue
        }
    }
    
    /* The opacity of the shadow below progress line end. Defaults to 1.
    * Values outside the [0,1] range will be clamped. */

    @IBInspectable open var shadowOpacity: CGFloat {
        get {
            return (layer as! MKRingProgressLayer).endShadowOpacity
        }
        set {
            (layer as! MKRingProgressLayer).endShadowOpacity = newValue
        }
    }
    
    /* The Antialiasing switch. Defaults to true. */
    
    @IBInspectable open var allowsAntialiasing: Bool {
        get {
            return (layer as! MKRingProgressLayer).allowsAntialiasing
        }
        set {
            (layer as! MKRingProgressLayer).allowsAntialiasing = newValue
        }
    }
    
    /* The progress. Can be any nonnegative number, every whole number corresponding to 
    * one full revolution, i.e. 1.0 -> 360°, 2.0 -> 720°, etc. Defaults to 0.
    * Progress animation duration can be adjusted using `CATransaction.setAnimationDuration()` */
    
    open var progress: Double {
        get {
            return Double((layer as! MKRingProgressLayer).progress)
        }
        set {
            (layer as! MKRingProgressLayer).progress = CGFloat(newValue)
        }
    }
    
    open override class var layerClass: AnyClass {
        return MKRingProgressLayer.self
    }
    
}


// MARK: Ring Progress Layer

open class MKRingProgressLayer: CALayer {
    
    open var startColor = UIColor.red.cgColor {
        didSet {
            setNeedsRedrawContents()
        }
    }
    
    open var endColor = UIColor.blue.cgColor {
        didSet {
            setNeedsRedrawContents()
        }
    }
    
    open var backgroundRingColor: CGColor? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    open var ringWidth: CGFloat = 20 {
        didSet {
            setNeedsRedrawContents()
        }
    }
    
    open var endShadowOpacity: CGFloat = 1.0 {
        didSet {
            endShadowOpacity = min(max(endShadowOpacity, 0), 1)
            setNeedsDisplay()
        }
    }
    
    open var allowsAntialiasing: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @NSManaged var progress: CGFloat
    
    override open static func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override open func action(forKey event: String) -> CAAction? {
        if event == "progress" {
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.0, 0.1, 1.0)
            animation.fromValue = presentation()?.value(forKey: event)
            animation.duration = max(0.01, CATransaction.animationDuration())
            return animation
        }
        return super.action(forKey: event)
    }
    
    
    override init() {
        super.init()
        setup()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
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
            let s = Float(1.5 * ringWidth / (2 * π * r2))
            _gradientImage = MKGradientGenerator.gradientImage(type: .conical, size: CGSize(width: r, height: r), colors: [endColor, endColor, startColor, startColor], locations: [0.0, s, (1.0 - s), 1.0], endPoint: CGPoint(x: 0.5 - CGFloat(2 * s), y: 1.0), scale: 1)
        }
        return _gradientImage!
    }
    
    func contentImage() -> CGImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        
        ctx.setShouldAntialias(allowsAntialiasing)
        ctx.setAllowsAntialiasing(allowsAntialiasing)
        
        let w: CGFloat = ringWidth
        let r = min(bounds.width, bounds.height)/2 - w/2
        let c = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let p = self.presentation()?.progress ?? 0.0
        let angleOffset = π / 2
        let angle = 2 * π * p - angleOffset
        let minAngle = 1.1 * atan(0.5 * w / r)
        let maxAngle = 2 * π - 3 * minAngle - angleOffset
        
        let circleRect = CGRect(x: bounds.width/2 - r, y: bounds.height/2 - r, width: 2*r, height: 2*r)
        let circlePath = UIBezierPath(ovalIn: circleRect)
        
        let angle1 = angle > maxAngle ? maxAngle : angle
        let arc1Path = UIBezierPath(arcCenter: c, radius: r, startAngle: -angleOffset, endAngle: angle1, clockwise: true)
        
        
        ctx.setLineWidth(w)
        ctx.setLineCap(.round)
        
        
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
        let shadowPath = UIBezierPath(ovalIn: CGRect(x: arcEnd.x - w/2, y: arcEnd.y - w/2, width: w, height: w))
        ctx.addPath(shadowPath.cgPath)
        ctx.setFillColor(startColor)
        ctx.fillPath()
        
        ctx.restoreGState()
        
        
        // Draw gradient arc
        
        ctx.saveGState()
        
        ctx.addPath(CGPath(__byStroking: arc1Path.cgPath, transform: nil, lineWidth: w, lineCap: .round, lineJoin: .round, miterLimit: 0)!)
        ctx.clip()
        
        ctx.draw(gradientImage(), in: circleRect.insetBy(dx: -w/2, dy: -w/2))

        ctx.restoreGState()
        
        
        ///////
        
        let img = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
        UIGraphicsEndImageContext()
        
        return img
    }
}

fileprivate let π = CGFloat(M_PI)
