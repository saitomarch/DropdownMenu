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
import DropdownMenu

class TableViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
                as? MenuTableViewCell else { fatalError() }
        cell.dropdownMenu.dataSource = self
        cell.dropdownMenu.delegate = self
        cell.dropdownMenu.presentingView = tableView
        cell.dropdownMenu.adjustsContentOffset = true
        cell.dropdownMenu.backgroundDimmingOpacity = 0.05
        cell.dropdownMenu.showsContentAbove = indexPath.row % 2 != 0
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,
                            forRowAt indexPath: IndexPath) {
        guard let cell = cell as? MenuTableViewCell else { return }
        cell.dropdownMenu.reload()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for cell in tableView.visibleCells {
            guard let cell = cell as? MenuTableViewCell else { continue }
            cell.dropdownMenu.closeAllComponents(animated: true)
        }
    }
}

extension TableViewController: DropdownMenuDataSource {
    func numberOfComponentsIn(_ dropdownMenu: DropdownMenu) -> Int {
        return 3
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, numberOfRowsIn component: Int) -> Int {
        return 5
    }
}

extension TableViewController: DropdownMenuDelegate {
    func dropdownMenu(_ dropdownMenu: DropdownMenu, titleFor component: Int) -> String? {
        let tableViewIndexPath = tableView.indexPathForRow(
            at: tableView.convert(CGPoint(x: dropdownMenu.bounds.minX, y: dropdownMenu.bounds.minY), from: dropdownMenu)
        )
        return "\((tableViewIndexPath?.row ?? 0) + 1)-\(component + 1)"
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, titleFor indexPath: DropdownMenu.IndexPath) -> String? {
        let tableViewIndexPath = tableView.indexPathForRow(
            at: tableView.convert(CGPoint(x: dropdownMenu.bounds.minX, y: dropdownMenu.bounds.minY), from: dropdownMenu)
        )
        return "\((tableViewIndexPath?.row ?? 0) + 1)-\(indexPath.component + 1)-\(indexPath.row + 1)"
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, shouldUseFullRowWidthFor component: Int) -> Bool {
        return false
    }
}
