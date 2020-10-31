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

class DropdownMenuTableViewCell: UITableViewCell {
    private(set) var containerView: UIView!
    var currentCustomView: UIView? {
        return containerView.subviews.last
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        clipsToBounds = true
        
        containerView = UIView(frame: contentView.bounds)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.isUserInteractionEnabled = true
        addSubview(containerView)
    }
    
    func set(customView: UIView?) {
        if let customView = customView {
            if currentCustomView != customView {
                currentCustomView?.removeFromSuperview()
                customView.frame = containerView.bounds
                customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                containerView.addSubview(customView)
            }
        } else {
            currentCustomView?.removeFromSuperview()
            containerView.isHidden = true
        }
        containerView.isHidden = false
        setAttributedTitle(nil)
    }
    
    func setAttributedTitle(_ attributedTitle: NSAttributedString?) {
        textLabel?.attributedText = attributedTitle
    }
    
    func setHighlightColor(_ color: UIColor?) {
        if color != nil {
            let selectionView = UIView()
            selectionView.backgroundColor = color
            selectedBackgroundView = selectionView
        } else {
            selectedBackgroundView = nil
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentCustomView?.removeFromSuperview()
        containerView.isHidden = true
    }
}
