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

extension DropdownMenu: DropdownMenuContentViewControllerDelegate {
    var numberOfRows: Int {
        guard selectedComponent != NSNotFound else { return 0 }
        return numberOfRows(in: selectedComponent)
    }
    
    var maximumNumberOfRows: Int {
        guard selectedComponent != NSNotFound else { return 0 }
        let maxRows = delegate?.dropdownMenu?(self, maximumNumberOfRowsIn: selectedComponent) ?? 0
        return max(0, maxRows)
    }
    
    func attributedTitle(for row: Int) -> NSAttributedString? {
        let indexPath = IndexPath(component: selectedComponent, row: row)
        var attributedTitle = delegate?.dropdownMenu?(self, attributedTitleFor: indexPath)
        if attributedTitle == nil {
            if let title = delegate?.dropdownMenu?(self, titleFor: indexPath) {
                attributedTitle = NSAttributedString(string: title)
            }
        }
        return attributedTitle
    }
    
    func customView(for row: Int, reusing view: UIView?) -> UIView? {
        return delegate?.dropdownMenu?(self, viewFor: IndexPath(component: selectedComponent, row: row), reusing: view)
    }
    
    func accessoryView(for row: Int) -> UIView? {
        return delegate?.dropdownMenu?(self, accessoryViewFor: IndexPath(component: selectedComponent, row: row))
    }
    
    func backgroundColor(for row: Int) -> UIColor {
        return delegate?.dropdownMenu?(self, backgroundColorFor: IndexPath(component: selectedComponent, row: row))
            ?? .clear
    }
    
    func didSelect(row: Int) {
        if row == NSNotFound {
            selectedComponent(button: nil)
        } else {
            delegate?.dropdownMenu?(self, didSelect: IndexPath(component: selectedComponent, row: row))
        }
    }
    
    func willDisappear() {
        if selectedComponent != NSNotFound {
            cleanupSelectedComponents()
            updateComponentButtons(selected: false)
        }
    }
}
