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

let defaultAnimationDuration: TimeInterval = 0.25

let defaultRowHeight: CGFloat = 44.0
let defaultDisclosureIndicatorSize: CGFloat = 8.0
let defaultCornerRadius:CGFloat = 2.0
let defaultBackgroundDimmingOpacity: CGFloat = 0.2

let shadowOpacity: Float = 0.2

let cellIdentifier = "DropdownMenuCellIdentifier"

extension UIColor {
    static let defaultSeparator = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0)
}

var defaultDisclosureIndicatorImage: UIImage {
    let a = defaultDisclosureIndicatorSize
    let h = a * 0.866
    let rect = CGRect(x: 0, y: a - h, width: a, height: h)
    UIGraphicsBeginImageContextWithOptions(CGSize(width: a, height: a), false, 0)
    let path = UIBezierPath()
    path.move(to: CGPoint(x: rect.minX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
    path.close()
    UIColor.black.setFill()
    path.fill()
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!.withRenderingMode(.alwaysTemplate)
}

let scrollViewBottomSpace: CGFloat = 5.0

enum MessageFormat {
    case assertFailed
    case fatalError
    case error
    case warning
    case info
    case debug
}

func formattedMessage(format: MessageFormat, message: String) -> String {
    var prefix = ""
    switch format {
    case .assertFailed:
        prefix = "[DropdownMenu] ASSERTION_FAILED: "
    case .fatalError:
        prefix = "[DropdownMenu] FATAL_ERROR: "
    case .error:
        prefix = "[DropdownMenu] ERROR: "
    case .warning:
        prefix = "[DropdownMenu] WARNING: "
    case .info:
        prefix = "[DropdownMenu] INFO: "
    case .debug:
        prefix = "[DropdownMenu] DEBUG: "
    }
    return prefix + message
}
