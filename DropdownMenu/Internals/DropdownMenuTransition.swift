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

class DropdownMenuTransition {
    var previousScrollViewBottomInset = CGFloat.greatestFiniteMagnitude
    var animationDuration = defaultAnimationDuration
    private(set) var isAnimating = false
    weak var menu: DropdownMenu!
    weak var controller: DropdownMenuContentViewController!
    weak var containerView: UIView!
    
    init(dropdownMenu: DropdownMenu, contentViewController: DropdownMenuContentViewController) {
        menu = dropdownMenu
        controller = contentViewController
    }
    
    func presentDropdown(in containerView: UIView, animated: Bool, completion: (() -> Void)?) {
        self.containerView = containerView
        
        controller.beginAppearanceTransition(true, animated: animated)
        
        let frame = containerView.convert(menu.bounds, from: menu)
        var topOffset = frame.maxY
        let contentHeight = controller.contentHeight
        let contentY = topOffset - contentHeight - menu.frame.size.height
        
        // Adjust scrollview + height
        var height = containerView.bounds.height
        var scrollViewAdjustBlock = {}
        
        if let scrollView = containerView as? UIScrollView {
            let contentMaxY = topOffset + contentHeight + scrollViewBottomSpace
            let inset = contentMaxY - scrollView.contentSize.height - scrollView.contentInset.bottom
            var offset: CGFloat = 0.0
            
            if controller.showAbove {
                height = frame.origin.y
                // No scroll => adjust top
                let offsetVal = contentY < scrollView.contentOffset.y ? contentY : scrollView.contentOffset.y
                topOffset = offsetVal
                offset = offsetVal
            } else {
                offset = contentMaxY - scrollView.bounds.size.height
                height = max(
                    height - scrollView.contentInset.top,
                    scrollView.contentSize.height + scrollView.contentInset.bottom
                )
                
                if menu.adjustsContentInset {
                    height = max(height, contentMaxY)
                }
            }
            
            scrollViewAdjustBlock =  { [weak self] in
                guard let self = self else { return }
                if self.menu.adjustsContentInset && inset > 0 {
                    self.previousScrollViewBottomInset = scrollView.contentInset.bottom
                    var contentInset = scrollView.contentInset
                    contentInset.bottom += inset
                    scrollView.contentInset = contentInset
                }
                if self.menu.adjustsContentOffset &&
                    self.controller.showAbove ?
                    offset < scrollView.contentOffset.y :
                    scrollView.contentOffset.y < offset {
                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: offset)
                }
            }
        } else if controller.showAbove {
            topOffset = 0
            height = frame.origin.y
        }
        
        // Set frame to dropdown's content table view
        controller.view.frame = CGRect(
            x: containerView.bounds.minX,
            y: topOffset,
            width: containerView.bounds.width,
            height: height - topOffset
        )
        
        // Show dropdown
        containerView.addSubview(controller.view)
        controller.view.layoutIfNeeded()
        
        if !animated {
            scrollViewAdjustBlock()
            controller.endAppearanceTransition()
            completion?()
            return
        }
        
        var transform = CGAffineTransform(scaleX: 1.0, y: 0.5)
        let tyScale: CGFloat = controller.showAbove ? 0.5 : -2
        transform = transform.translatedBy(x: 0, y: tyScale * controller.containerView.frame.height)
        controller.containerView.transform = transform
        
        controller.view.alpha = 0.0
        
        isAnimating = true
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [],
            animations: { [weak self] in
                guard let self = self else { return }
                self.controller.view.alpha = 1.0
                self.controller.containerView.transform = .identity
                scrollViewAdjustBlock()
            },
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.controller.endAppearanceTransition()
                self.isAnimating = false
                completion?()
            }
        )
    }
    
    func dismissDropdown(animated: Bool, completion: (() -> Void)?) {
        controller.beginAppearanceTransition(false, animated: true)
        var scrollViewResetBlock = {}
        if let scrollView = containerView as? UIScrollView {
            scrollViewResetBlock = { [weak self] in
                guard let self = self else { return }
                if self.previousScrollViewBottomInset != CGFloat.greatestFiniteMagnitude {
                    var contentInset = scrollView.contentInset
                    contentInset.bottom = self.previousScrollViewBottomInset
                    scrollView.contentInset = contentInset
                    self.previousScrollViewBottomInset = CGFloat.greatestFiniteMagnitude
                }
                if self.menu.adjustsContentOffset && scrollView.contentOffset.y < 0 {
                    scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
                }
            }
        }
        
        if !animated {
            scrollViewResetBlock()
            containerView.removeFromSuperview()
            controller.endAppearanceTransition()
            completion?()
            return
        }

        var transform = CGAffineTransform(scaleX: 1.0, y: 0.5)
        let tyScale: CGFloat = controller.showAbove ? 0.5 : -2
        transform = transform.translatedBy(x: 0, y: tyScale * controller.containerView.frame.height)
        
        isAnimating = true
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [],
            animations: { [weak self] in
                guard let self = self else { return }
                self.controller.view.alpha = 0.0
                self.controller.containerView.transform = transform
                scrollViewResetBlock()
            },
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.controller.view.removeFromSuperview()
                self.controller.view.alpha = 1.0
                self.controller.containerView.transform = .identity
                self.controller.endAppearanceTransition()
                self.isAnimating = false
                completion?()
            }
        )
        containerView = nil
    }
}
