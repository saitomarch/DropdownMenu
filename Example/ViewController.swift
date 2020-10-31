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

class ViewController: UIViewController {
    @IBOutlet weak var textLabel: UILabel!
    
    var navBarMenu: DropdownMenu!
    
    let colors = ["#0F4C81", "#166BB5", "#1B86E3"]
    
    var childViewController: ChildViewController! {
        return children.first as? ChildViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textLabel.text = colors[0]
        view.backgroundColor = UIColor.color(hex: colors[0])
        
        // Create dropdown menu in code
        navBarMenu = DropdownMenu(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        navBarMenu.dataSource = self
        navBarMenu.delegate = self
        
        // Make background light instead of dark when presenting the dropdown
        navBarMenu.backgroundDimmingOpacity = -0.67
        
        // Set custom disclosure indicator image
        let indicator = UIImage(named: "indicator")!
        navBarMenu.disclosureIndicatorImage = indicator
        
        // Add an arrow between the menu header and the dropdown
        let spacer = UIImageView(image: #imageLiteral(resourceName: "triangle"))
        spacer.contentMode = .center
        
        navBarMenu.spacerView = spacer
        
        // Offset the arrow to align with the disclosure indicator
        navBarMenu.spacerViewOffset = UIOffset(
            horizontal: navBarMenu.bounds.size.width / 2 - indicator.size.width / 2 - 8,
            vertical: 1
        )
        
        // Hide top row separator to blend with the arrow
        navBarMenu.showsTopRowSeparator = false
        navBarMenu.bouncesScroll = false
        navBarMenu.rowSeparatorColor = UIColor(white: 1.0, alpha: 0.2)
        navBarMenu.rowTextAlignment = .center
        
        // Round all corners (by default only bottom corners are rounded
        navBarMenu.dropdownRoundedCorners = .allCorners
        
        // Let the dropdown take the whole width of the screen with 10pt insets
        navBarMenu.useFullScreenWidth = true
        navBarMenu.fullScreenInsetsLeft = 10.0
        navBarMenu.fullScreenInsetsRight = 10.0
        
        // Add the dropdown menu to navigation bar
        navigationItem.titleView = navBarMenu
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navBarMenu.closeAllComponents(animated: false)
        childViewController.dropdownMenu.closeAllComponents(animated: true)
    }
}

extension ViewController: DropdownMenuDataSource {
    func numberOfComponentsIn(_ dropdownMenu: DropdownMenu) -> Int {
        return 1
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, numberOfRowsIn component: Int) -> Int {
        return 3
    }
}

extension ViewController: DropdownMenuDelegate {
    func dropdownMenu(_ dropdownMenu: DropdownMenu, rowHeightFor component: Int) -> CGFloat {
        return 60.0
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, attributedTitleFor component: Int) -> NSAttributedString? {
        return NSAttributedString(string: "DropdownMenu", attributes: [
            .font: UIFont.systemFont(ofSize: 18.0, weight: .light),
            .foregroundColor: UIColor.systemBlue
        ])
    }
    
    func dropdownMenu(
        _ dropdownMenu: DropdownMenu,
        attributedTitleFor indexPath: DropdownMenu.IndexPath
    ) -> NSAttributedString? {
        let string = NSMutableAttributedString(string: "Color \(indexPath.row + 1): ", attributes: [
            .font: UIFont.systemFont(ofSize: 20.0, weight: .light),
            .foregroundColor: UIColor.white
        ])
        string.append(NSAttributedString(string: colors[indexPath.row], attributes: [
            .font: UIFont.systemFont(ofSize: 20.0, weight: .medium),
            .foregroundColor: UIColor.white
        ]))
        return string
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, backgroundColorFor indexPath: DropdownMenu.IndexPath) -> UIColor? {
        return UIColor.color(hex: colors[indexPath.row])
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, backgroundColorForHighlightedRowsIn component: Int) -> UIColor? {
        return UIColor(white: 0.0, alpha: 0.5)
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelect indexPath: DropdownMenu.IndexPath) {
        let colorString = colors[indexPath.row]
        textLabel.text = colorString
        
        let color = UIColor.color(hex: colorString)
        view.backgroundColor = color
        // childViewController.
    }
}
