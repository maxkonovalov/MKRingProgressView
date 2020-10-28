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

import MKRingProgressView
import UIKit

@IBDesignable
class RingProgressGroupView: UIView {
    let ring1 = RingProgressView()
    let ring2 = RingProgressView()
    let ring3 = RingProgressView()
    
    @IBInspectable var ring1StartColor: UIColor = .red {
        didSet {
            ring1.startColor = ring1StartColor
        }
    }
    
    @IBInspectable var ring1EndColor: UIColor = .blue {
        didSet {
            ring1.endColor = ring1EndColor
        }
    }
    
    @IBInspectable var ring2StartColor: UIColor = .red {
        didSet {
            ring2.startColor = ring2StartColor
        }
    }
    
    @IBInspectable var ring2EndColor: UIColor = .blue {
        didSet {
            ring2.endColor = ring2EndColor
        }
    }
    
    @IBInspectable var ring3StartColor: UIColor = .red {
        didSet {
            ring3.startColor = ring3StartColor
        }
    }
    
    @IBInspectable var ring3EndColor: UIColor = .blue {
        didSet {
            ring3.endColor = ring3EndColor
        }
    }
    
    @IBInspectable var ringWidth: CGFloat = 20 {
        didSet {
            ring1.ringWidth = ringWidth
            ring2.ringWidth = ringWidth
            ring3.ringWidth = ringWidth
            setNeedsLayout()
        }
    }
    
    @IBInspectable var ringSpacing: CGFloat = 2 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(ring1)
        addSubview(ring2)
        addSubview(ring3)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ring1.frame = bounds
        ring2.frame = bounds.insetBy(dx: ringWidth + ringSpacing, dy: ringWidth + ringSpacing)
        ring3.frame = bounds.insetBy(dx: 2 * ringWidth + 2 * ringSpacing, dy: 2 * ringWidth + 2 * ringSpacing)
    }
}
