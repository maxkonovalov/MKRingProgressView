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
public class MKRingProgressView: UIView {
    
    /* The ring color for lowest progress values (closer to 0.0). */
    
    @IBInspectable public var startColor: UIColor {
        get {
            return UIColor(CGColor: (layer as! MKRingProgressLayer).startColor)
        }
        set {
            (layer as! MKRingProgressLayer).startColor = newValue.CGColor
        }
    }
    
    /* The ring color for highest progress values (closer to 1.0) */
    
    @IBInspectable public var endColor: UIColor {
        get {
            return UIColor(CGColor: (layer as! MKRingProgressLayer).endColor)
        }
        set {
            (layer as! MKRingProgressLayer).endColor = newValue.CGColor
        }
    }
    
    /* The color of backdrop circle, visible at progress values between 0.0 and 1.0.
    * If not specified, `startColor` with 15% opacity will be used. */
    
    @IBInspectable public var backgroundRingColor: UIColor? {
        get {
            if let color = (layer as! MKRingProgressLayer).backgroundRingColor {
                return UIColor(CGColor: color)
            }
            return nil
        }
        set {
            (layer as! MKRingProgressLayer).backgroundRingColor = newValue?.CGColor
        }
    }
    
    /* The width of the progress ring. Defaults to 20. */
    
    @IBInspectable public var ringWidth: CGFloat {
        get {
            return (layer as! MKRingProgressLayer).ringWidth
        }
        set {
            (layer as! MKRingProgressLayer).ringWidth = newValue
        }
    }
    
    /* The opacity of the shadow below progress line end. Defaults to 1.
    * Values outside the [0,1] range will be clamped. */

    @IBInspectable public var shadowOpacity: CGFloat {
        get {
            return (layer as! MKRingProgressLayer).endShadowOpacity
        }
        set {
            (layer as! MKRingProgressLayer).endShadowOpacity = newValue
        }
    }
    
    /* The progress. Can be any nonnegative number, every whole number corresponding to 
    * one full revolution, i.e. 1.0 -> 360°, 2.0 -> 720°, etc. Defaults to 0.
    * Progress animation duration can be adjusted using `CATransaction.setAnimationDuration()` */
    
    public var progress: Double {
        get {
            return Double((layer as! MKRingProgressLayer).progress)
        }
        set {
            (layer as! MKRingProgressLayer).progress = CGFloat(newValue)
        }
    }
    
    public override class func layerClass() -> AnyClass {
        return MKRingProgressLayer.self
    }
    
}


// MARK: Ring Progress Layer

public class MKRingProgressLayer: CALayer {
    
    public var startColor = UIColor.redColor().CGColor {
        didSet {
            setNeedsRedrawContents()
        }
    }
    
    public var endColor = UIColor.blueColor().CGColor {
        didSet {
            setNeedsRedrawContents()
        }
    }
    
    public var backgroundRingColor: CGColorRef? = nil {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var ringWidth: CGFloat = 20 {
        didSet {
            setNeedsRedrawContents()
        }
    }
    
    public var endShadowOpacity: CGFloat = 1.0 {
        didSet {
            endShadowOpacity = min(max(endShadowOpacity, 0), 1)
            setNeedsDisplay()
        }
    }
    
    
    @NSManaged var progress: CGFloat
    
    override public static func needsDisplayForKey(key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplayForKey(key)
    }
    
    override public func actionForKey(event: String) -> CAAction? {
        if event == "progress" {
            let animation = CABasicAnimation(keyPath: event)
            animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.0, 0.1, 1.0)
            animation.fromValue = presentationLayer()?.valueForKey(event)
            animation.duration = max(0.01, CATransaction.animationDuration())
            return animation
        }
        return super.actionForKey(event)
    }
    
    
    override init() {
        super.init()
        setup()
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.contentsScale = UIScreen.mainScreen().scale
    }
    
    
    private func setNeedsRedrawContents() {
        _gradientImage = nil
        setNeedsDisplay()
    }
    
    override public func display() {
        self.contents = contentImage()
    }
    
    private var _gradientImage: CGImageRef?
    
    private func gradientImage() -> CGImageRef {
        if _gradientImage == nil {
            let r = min(bounds.width, bounds.height)/2
            let r2 = r - ringWidth/2
            let s = Float(1.5 * ringWidth / (2 * π * r2))
            _gradientImage = MKGradientGenerator.gradientImageWithType(.Conical, size: CGSize(width: r, height: r), colors: [endColor, endColor, startColor, startColor], locations: [0.0, s, (1.0 - s), 1.0], endPoint: CGPoint(x: 0.5 - CGFloat(2 * s), y: 1.0), scale: 1)
        }
        return _gradientImage!
    }
    
    func contentImage() -> CGImageRef {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        
        
        let w: CGFloat = ringWidth
        let r = min(bounds.width, bounds.height)/2 - w/2
        let c = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let p = (self.presentationLayer() as? MKRingProgressLayer)?.progress ?? 0.0
        let angleOffset = π / 2
        let angle = 2 * π * p - angleOffset
        let minAngle = 1.1 * atan(0.5 * w / r)
        let maxAngle = 2 * π - 3 * minAngle - angleOffset
        
        let circleRect = CGRect(x: bounds.width/2 - r, y: bounds.height/2 - r, width: 2*r, height: 2*r)
        let circlePath = UIBezierPath(ovalInRect: circleRect)
        
        let angle1 = angle > maxAngle ? maxAngle : angle
        let arc1Path = UIBezierPath(arcCenter: c, radius: r, startAngle: -angleOffset, endAngle: angle1, clockwise: true)
        
        
        CGContextSetLineWidth(ctx, w)
        CGContextSetLineCap(ctx, .Round)
        
        
        // Draw backdrop circle
        
        CGContextAddPath(ctx, circlePath.CGPath)
        let bgColor = backgroundRingColor ?? CGColorCreateCopyWithAlpha(startColor, 0.15)
        CGContextSetStrokeColorWithColor(ctx, bgColor)
        CGContextStrokePath(ctx)
        
        
        // Draw solid arc
        
        if angle > maxAngle {
            
            let offset = angle - maxAngle
            
            let arc2Path = UIBezierPath(arcCenter: c, radius: r, startAngle: -angleOffset, endAngle: offset, clockwise: true)
            CGContextAddPath(ctx, arc2Path.CGPath)
            CGContextSetStrokeColorWithColor(ctx, startColor)
            CGContextStrokePath(ctx)
            
            CGContextTranslateCTM(ctx, circleRect.midX, circleRect.midY)
            CGContextRotateCTM(ctx, offset)
            CGContextTranslateCTM(ctx, -circleRect.midX, -circleRect.midY)
            
        }
        
        
        // Draw shadow
        
        CGContextSaveGState(ctx)
        
        CGContextAddPath(ctx, CGPathCreateCopyByStrokingPath(circlePath.CGPath, nil, w, .Round, .Round, 0))
        CGContextClip(ctx)
        
        let shadowOffset = CGSize(width: w/10 * cos(angle + angleOffset), height: w/10 * sin(angle + angleOffset))
        CGContextSetShadowWithColor(ctx, shadowOffset, w/3, UIColor(white: 0.0, alpha: endShadowOpacity).CGColor)
        let arcEnd = CGPoint(x: c.x + r * cos(angle1), y: c.y + r * sin(angle1))
        let shadowPath = UIBezierPath(ovalInRect: CGRect(x: arcEnd.x - w/2, y: arcEnd.y - w/2, width: w, height: w))
        CGContextAddPath(ctx, shadowPath.CGPath)
        CGContextSetFillColorWithColor(ctx, startColor)
        CGContextFillPath(ctx)
        
        CGContextRestoreGState(ctx)
        
        
        // Draw gradient arc
        
        CGContextSaveGState(ctx)
        
        CGContextAddPath(ctx, CGPathCreateCopyByStrokingPath(arc1Path.CGPath, nil, w, .Round, .Round, 0))
        CGContextClip(ctx)
        
        CGContextDrawImage(ctx, circleRect.insetBy(dx: -w/2, dy: -w/2), gradientImage())

        CGContextRestoreGState(ctx)
        
        
        ///////
        
        let img = UIGraphicsGetImageFromCurrentImageContext().CGImage!
        UIGraphicsEndImageContext()
        
        return img
    }
}
