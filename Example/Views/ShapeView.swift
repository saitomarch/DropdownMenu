/*
 Copyright (C) 2020 SAITO Tomomi

 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:

 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
import UIKit

class ShapeView: UIView {
    var sidesCount: UInt = 0 {
        didSet { setNeedsDisplay() }
    }
    
    var fillColor: UIColor? {
        didSet { setNeedsDisplay() }
    }
    
    var strokeColor: UIColor? {
        didSet { setNeedsDisplay() }
    }
    
    var lineWidth: CGFloat = 0.0 {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, (rect.height / 2) - lineWidth)
        
        var path: UIBezierPath!
        
        if sidesCount < 3 {
            path = UIBezierPath(
                ovalIn: CGRect(x: center.x - radius, y: center.y - radius, width: 2 * radius, height: 2 * radius)
            )
        } else {
            path = UIBezierPath()
            path.move(to: CGPoint(x: center.x, y: center.y - radius))
            
            let angleStep = 2 * CGFloat.pi / CGFloat(sidesCount)
            
            for idx in 1 ..< sidesCount {
                let angle = angleStep * CGFloat(idx) - (CGFloat.pi / 2)
                path.addLine(to: CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle)))
            }
            
            path.close()
        }
        
        fillColor?.setFill()
        path.fill()
        
        path.lineWidth = lineWidth
        strokeColor?.setStroke()
        path.stroke()
    }
}
