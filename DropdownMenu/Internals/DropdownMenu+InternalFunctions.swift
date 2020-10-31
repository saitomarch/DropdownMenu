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

extension DropdownMenu {
    // MARK: - Internal methods
    func setup() {
        contentViewController = DropdownMenuContentViewController()
        contentViewController.delegate = self
        
        // load content view
        _ = contentViewController.view
        
        transition = DropdownMenuTransition(dropdownMenu: self, contentViewController: contentViewController)
    }
    
    func setupComponents() {
        guard let dataSource = dataSource else {
            return
        }
        
        let numberOfComponents = dataSource.numberOfComponentsIn(self)
        
        components.removeAll()
        selectedRows.removeAll()
        
        for idx in 0 ..< numberOfComponents {
            let numberOfRows = dataSource.dropdownMenu(self, numberOfRowsIn: idx)
            components.append(numberOfRows)
            selectedRows.append(IndexSet())
            if buttons.count <= idx {
                let button = DropdownMenuComponentButton()
                buttons.append(button)
                addSubview(button)
                button.addTarget(self, action: #selector(selectedComponent(button:)), for: .touchUpInside)
            }
            if idx < numberOfComponents - 1 && separators.count <= 1 {
                let separator = UIView()
                separators.append(separator)
                addSubview(separator)
            }
        }
        while buttons.count > numberOfComponents {
            let button = buttons.last
            button?.removeFromSuperview()
            buttons.removeLast()
        }
        while separators.count > numberOfComponents - 1 {
            let separator = separators.last
            separator?.removeFromSuperview()
            separators.removeLast()
        }
    }
    
    func updateComponentButtons() {
        for (idx, button) in buttons.enumerated() {
            update(button: button, for: idx)
        }
        updateComponentSeparators()
    }
    
    func update(button: DropdownMenuComponentButton, for component: Int) {
        let isEnabled = delegate?.dropdownMenu?(self, shouldEnable: component) ?? true
        button.isEnabled = isEnabled
        
        button.titleLabel?.lineBreakMode = componentLineBreakMode
        switch componentLineBreakMode {
        case .byCharWrapping, .byWordWrapping:
            button.titleLabel?.numberOfLines = 0
        default:
            button.titleLabel?.numberOfLines = 1
        }
        
        button.textAlignment = componentTextAlignment
        button.set(disclosureIndicatorImage: disclosureIndicatorImage)
        button.selectedBackgroundColor = selectedComponentBackgroundColor
        button.disclosureIndicatorAngle = disclosureIndicatorSelectionRotation
        button.disclosureIndicatorFlipped = showsContentAbove
        
        let customView = delegate?.dropdownMenu?(self, viewFor: component) ?? button.currentCustomView
        
        if let customView = customView {
            button.set(customView: customView)
        } else {
            var attributedTitle = delegate?.dropdownMenu?(self, attributedTitleFor: component)
            if attributedTitle == nil {
                if let title = delegate?.dropdownMenu?(self, titleFor: component) {
                    attributedTitle = NSAttributedString(string: title)
                }
            }
            var attributedSelectedTitle: NSAttributedString?
            if attributedTitle != nil {
                attributedSelectedTitle = delegate?.dropdownMenu?(self, attributedTitleForSelected: component)
                if attributedSelectedTitle == nil {
                    if let selectedTitle = delegate?.dropdownMenu?(self, titleForSelected: component) {
                        attributedSelectedTitle = NSAttributedString(string: selectedTitle)
                    }
                }
            }
            button.set(attributedTitle: attributedTitle, selectedTitle: attributedSelectedTitle)
        }
    }
    
    func updateComponentSeparators() {
        let separatorColor = componentSeparatorColor ?? .defaultSeparator
        for separator in separators {
            separator.backgroundColor = separatorColor
            bringSubviewToFront(separator)
        }
    }
    
    func layoutComponentButtons() {
        guard buttons.count > 0 else { return }
        
        var totalCustomWidth: CGFloat = 0
        var customWidthsCount = 0
        
        var widths: [CGFloat] = []
        
        for idx in 0 ..< buttons.count {
            guard let width = delegate?.dropdownMenu?(self, widthFor: idx) else { break }
            widths.append(width)
            if width > 0 {
                totalCustomWidth += width
                customWidthsCount += 1
            }
        }
        
        var defaultWidth = bounds.size.width / CGFloat(buttons.count)
        if customWidthsCount > 0 && buttons.count < customWidthsCount {
            defaultWidth = (bounds.size.width - totalCustomWidth) / CGFloat(buttons.count - customWidthsCount)
        }
        
        assert(
            totalCustomWidth <= bounds.size.width,
            formattedMessage(
                format: .assertFailed,
                message: "Total width for components (\(totalCustomWidth)) must not be greater than view bounds " +
                    "width (\(bounds.size.width))"
            )
        )
        
        var dx: CGFloat = 0
        for (idx, button) in buttons.enumerated() {
            var width: CGFloat = 0
            if idx == buttons.count - 1 {
                width = bounds.size.width - dx
            } else {
                if idx < widths.count {
                    width = widths[idx]
                }
            }
            if width <= 0 {
                width = defaultWidth
            }
            button.frame = CGRect(x: dx, y: 0, width: width, height: bounds.size.height)
            dx += width
        }
    }
    
    func layoutComponentSeparators() {
        for (idx, separator) in separators.enumerated() {
            let buttonFrame = buttons[idx].frame
            separator.frame = CGRect(
                x: buttonFrame.maxX - 0.25,
                y: buttonFrame.minY,
                width: 0.5,
                height: buttonFrame.height
            )
        }
    }
    
    @objc func selectedComponent(button: DropdownMenuComponentButton?) {
        guard !transition.isAnimating else { return }
        if button == nil {
            closeAllComponents(animated: true)
        } else {
            if let selected = buttons.firstIndex(of: button!),
               selected != selectedComponent {
                open(component: selected, animated: true)
            } else {
                closeAllComponents(animated: true)
            }
        }
    }
    
    var contentInsetForSelectedComponent: UIEdgeInsets {
        if selectedComponent == NSNotFound { return .zero }
       
        let presenting = containerView
        let fullWidth = delegate?.dropdownMenu?(self, shouldUseFullRowWidthFor: selectedComponent) ?? true
        
        // L/R + width
        var left: CGFloat = 0.0
        var right: CGFloat = 0.0
        
        if fullWidth && useFullScreenWidth {
            left = presenting.bounds.minX + fullScreenInsetsLeft
            right = presenting.bounds.maxX - fullScreenInsetsRight
        } else if fullWidth {
            let leftButtonFrame = presenting.convert(buttons.first!.frame, from: self)
            let rightButtonFrame = presenting.convert(buttons.last!.frame, from: self)
            left = leftButtonFrame.minX
            right = rightButtonFrame.maxX
        } else {
            let buttonFrame = presenting.convert(buttons[selectedComponent].frame, from: self)
            left = buttonFrame.minX
            right = buttonFrame.maxX
        }
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: presenting.bounds.width - right + 0.5)
    }
    
    func cleanupSelectedComponents() {
        let previous = selectedComponent
        selectedComponent = NSNotFound
        if previous != NSNotFound {
            delegate?.dropdownMenu?(self, didClose: previous)
        }
    }
    
    func updateComponentButtons(selected: Bool) {
        func animation() {
            if selected && selectedComponent != NSNotFound {
                buttons[selectedComponent].isSelected = true
            } else {
                for button in buttons {
                    button.isSelected = false
                }
            }
        }
        
        if contentViewController.transitionCoordinator != nil {
            contentViewController.transitionCoordinator?.animate(
                alongsideTransition: { (_) in
                    animation()
                },
                completion: nil
            )
        } else {
            UIView.animate(withDuration: defaultAnimationDuration) {
                animation()
            }
        }
    }
    
    // MARK: - Dropdown presenting & dismissing
    var containerView: UIView {
        return presentingView ?? window!
    }
    
    func presentDropdownForSelectedComponent(animated: Bool, completion: (() -> Void)?) {
        guard selectedComponent != NSNotFound else {
            completion?()
            return
        }
        
        let presenting = containerView

        contentViewController.updateData()
        contentViewController.contentInset = contentInsetForSelectedComponent
        
        let rowHeight = delegate?.dropdownMenu?(self, rowHeightFor: selectedComponent) ?? 0.0
        contentViewController.tableView.rowHeight = rowHeight > 0 ? rowHeight : defaultRowHeight
        
        let highlightColor = delegate?.dropdownMenu?(self, backgroundColorForHighlightedRowsIn: selectedComponent)
        contentViewController.highlightColor = highlightColor
        
        transition.presentDropdown(in: presenting, animated: animated) {
            completion?()
        }
        
        updateComponentButtons()
    }
    
    func dismissDropdown(animated: Bool, completion: (() -> Void)?) {
        guard contentViewController.view.window != nil else {
            completion?()
            return
        }
        
        transition.dismissDropdown(animated: animated) {
            completion?()
        }
        
        updateComponentButtons(selected: false)
    }
}
