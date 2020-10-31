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

class DropdownMenuComponentButton: UIButton {
    // MARK: - Properties
    private(set) var disclosureIndicatorView: UIImageView!
    private(set) var containerView: UIView!
    var currentCustomView: UIView? {
        return containerView.subviews.last
    }
    var textAlignment: NSTextAlignment {
        get {
            switch contentHorizontalAlignment {
            case .left:
                return .left
            case .right:
                return .right
            default:
                return .center
            }
        }
        set {
            switch newValue {
            case .left:
                contentHorizontalAlignment = .left
            case .right:
                contentHorizontalAlignment = .right
            default:
                contentHorizontalAlignment = .center
            }
        }
    }
    var selectedBackgroundColor: UIColor!
    var disclosureIndicatorAngle: CGFloat = 0.0
    var disclosureIndicatorFlipped = false {
        didSet {
            let selected = isSelected
            isSelected = selected
        }
    }

    static var disclosureIndicatorImage: UIImage?
    
    // MARK: Overrides (Property)
    override var isSelected: Bool {
        didSet {
            var angle = isSelected ? disclosureIndicatorAngle : 0.0
            if disclosureIndicatorFlipped {
                angle += CGFloat.pi
            }
            disclosureIndicatorView.transform = CGAffineTransform(rotationAngle: angle)
            backgroundColor = isSelected ? selectedBackgroundColor : nil
        }
    }
    
    override var isEnabled: Bool {
        didSet { disclosureIndicatorView.isHidden = !isEnabled }
    }

    // MARK: - Methods
    
    // MARK: UIButton lifecycle related methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        clipsToBounds = true
        
        // container view
        containerView = UIView(frame: bounds)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(containerView)
        
        // disclosure indicator view
        disclosureIndicatorView = UIImageView()
        disclosureIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(disclosureIndicatorView)
        addConstraints([
            NSLayoutConstraint(
                item: self,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: disclosureIndicatorView,
                attribute: .trailing,
                multiplier: 1.0,
                constant: 8.0
            ),
            NSLayoutConstraint(
                item: disclosureIndicatorView!,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerY,
                multiplier: 1.0,
                constant: 0.0
            )
        ])
    }
        
    // MARK: Other methods
    func set(attributedTitle: NSAttributedString?, selectedTitle: NSAttributedString?) {
        setAttributedTitle(attributedTitle, for: .normal)
        setAttributedTitle(selectedTitle, for: .selected)
        setAttributedTitle(selectedTitle, for: [.selected, .highlighted])
        if attributedTitle != nil {
            currentCustomView?.removeFromSuperview()
            containerView.isHidden = true
        }
    }
    
    func set(customView: UIView) {
        if currentCustomView != customView {
            currentCustomView?.removeFromSuperview()
            customView.frame = containerView.bounds
            customView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(customView)
        }
        containerView.isHidden = false
        accessibilityLabel = customView.accessibilityLabel
        set(attributedTitle: nil, selectedTitle: nil)
    }
    
    func set(disclosureIndicatorImage: UIImage?) {
        var image: UIImage! = disclosureIndicatorImage
        if image == nil {
            if DropdownMenuComponentButton.disclosureIndicatorImage == nil {
                DropdownMenuComponentButton.disclosureIndicatorImage = defaultDisclosureIndicatorImage
            }
            image = DropdownMenuComponentButton.disclosureIndicatorImage
        }
        
        disclosureIndicatorView.image = image
        disclosureIndicatorView.sizeToFit()
        let insetLeft: CGFloat = 8.0
        let insetRight: CGFloat = (image.size.width > 0) ? image.size.width + 4 + insetLeft : insetLeft
        contentEdgeInsets = UIEdgeInsets(top: 0.0, left: insetLeft, bottom: 0.0, right: insetRight)
        setNeedsLayout()
    }
    
    // MARK: Overrides (Mehtod)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let target = super.hitTest(point, with: event)
        if bounds.contains(point) && !(target?.isKind(of: UIControl.self) ?? false) {
            return self
        }
        return target
    }
}
