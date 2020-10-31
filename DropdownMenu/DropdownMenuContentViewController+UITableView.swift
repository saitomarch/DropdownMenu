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

extension DropdownMenuContentViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
                as? DropdownMenuTableViewCell else {
            fatalError("Invalid cell loaded")
        }
        
        var customView = cell.currentCustomView
        customView = delegate?.customView(for: indexPath.row, reusing: customView)
        
        cell.set(customView: customView)
        if customView == nil {
            let attributedTitle = delegate?.attributedTitle(for: indexPath.row)
            cell.setAttributedTitle(attributedTitle)
        }
        
        cell.setHighlightColor(highlightColor)
        
        cell.backgroundColor = delegate?.backgroundColor(for: indexPath.row)
        
        cell.accessoryView = delegate?.accessoryView(for: indexPath.row)
        
        cell.textLabel?.textAlignment = textAlignment
        
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = .zero
        cell.separatorInset = .zero
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(row: indexPath.row)
    }
}
