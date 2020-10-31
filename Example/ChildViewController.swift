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

class ChildViewController: UIViewController {
    enum DropdownComponent: Int, CaseIterable {
        case shape, color, lineWidth
    }
    
    @IBOutlet weak var dropdownMenu: DropdownMenu!
    @IBOutlet weak var shapeView: ShapeView!
    
    let componentTitles = ["Shape", "Color", "LineWidth"]
    let shapeTitles = ["Circle", "Triangle", "Rectangle", "Pentagon", "Hexagon"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up dropdown menu loaded from storyboard
        // Note that `dataSource` and `delegate` outlets are connected in storyboard or code
        dropdownMenu.delegate = self
        dropdownMenu.dataSource = self
        
        dropdownMenu.layer.borderColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1.0).cgColor
        dropdownMenu.layer.borderWidth = 0.5
        
        let selectedBackgroundColor = UIColor(red: 0.91, green: 0.92, blue: 0.94, alpha: 1.0)
        dropdownMenu.selectedComponentBackgroundColor = selectedBackgroundColor
        dropdownMenu.dropdownBackgroundColor = selectedBackgroundColor
        
        dropdownMenu.showsTopRowSeparator = false
        dropdownMenu.showsBottomRowSeparator = false
        dropdownMenu.showsBorder = true
        
        dropdownMenu.backgroundDimmingOpacity = 0.05
        
        // Set up shape view
        shapeView.sidesCount = 2
        shapeView.fillColor = .lightGray
        shapeView.strokeColor = .darkGray
        shapeView.lineWidth = 1.0
    }
}

extension ChildViewController: DropdownMenuDataSource {
    func numberOfComponentsIn(_ dropdownMenu: DropdownMenu) -> Int {
        return DropdownComponent.allCases.count
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, numberOfRowsIn component: Int) -> Int {
        switch DropdownComponent.allCases[component] {
        case .shape:
            return shapeTitles.count
        case .color:
            return 64
        case .lineWidth:
            return 8
        }
    }
}

extension ChildViewController: DropdownMenuDelegate {
    func dropdownMenu(_ dropdownMenu: DropdownMenu, rowHeightFor component: Int) -> CGFloat {
        if DropdownComponent.allCases[component] == .color {
            return 20.0
        }
        return 0 // use default row height
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, widthFor component: Int) -> CGFloat {
        switch DropdownComponent.allCases[component] {
        case .shape, .lineWidth:
            return max(dropdownMenu.bounds.size.width / 3, 125)
        default:
            return 0 // use automatic width
        }
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, shouldUseFullRowWidthFor component: Int) -> Bool {
        return false
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, attributedTitleFor component: Int) -> NSAttributedString? {
        return NSAttributedString(string: componentTitles[component], attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .light),
            .foregroundColor: view.tintColor!
        ])
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, attributedTitleForSelected component: Int) -> NSAttributedString? {
        return NSAttributedString(string: componentTitles[component], attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: view.tintColor!
        ])
    }
    
    func dropdownMenu(
        _ dropdownMenu: DropdownMenu,
        viewFor indexPath: DropdownMenu.IndexPath,
        reusing view: UIView?
    ) -> UIView? {
        switch DropdownComponent.allCases[indexPath.component] {
        case .shape:
            var shapeSelectView: ShapeSelectView! = view as? ShapeSelectView
            if shapeSelectView == nil {
                let nib = UINib(nibName: "ShapeSelectView", bundle: nil)
                shapeSelectView = nib.instantiate(withOwner: nil, options: nil).first as? ShapeSelectView
            }
            shapeSelectView.shapeView.sidesCount = UInt(indexPath.row + 2)
            shapeSelectView.textLabel.text = shapeTitles[indexPath.row]
            shapeSelectView.isSelected = shapeSelectView.shapeView.sidesCount == shapeView.sidesCount
            return shapeSelectView
        case .lineWidth:
            var lineWidthSelectView: LineWidthSelectView! = view as? LineWidthSelectView
            if lineWidthSelectView == nil {
                lineWidthSelectView = LineWidthSelectView()
                lineWidthSelectView.backgroundColor = .clear
            }
            lineWidthSelectView.lineColor = self.view.tintColor
            lineWidthSelectView.lineWidth = CGFloat(indexPath.row * 2 + 1)
            return lineWidthSelectView
        default:
            return nil
        }
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, backgroundColorFor indexPath: DropdownMenu.IndexPath) -> UIColor? {
        guard DropdownComponent.allCases[indexPath.component] == .color else { return nil }
        return color(for: indexPath.row)
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelect indexPath: DropdownMenu.IndexPath) {
        switch DropdownComponent.allCases[indexPath.component] {
        case .shape:
            shapeView.sidesCount = UInt(indexPath.row + 2)
        case .color:
            shapeView.fillColor = color(for: indexPath.row)
        case .lineWidth:
            shapeView.lineWidth = CGFloat(indexPath.row * 2 + 1)
        }
    }
}

extension ChildViewController {
    func color(for row: Int) -> UIColor {
        return UIColor(
            hue: CGFloat(row) / CGFloat(
                dropdownMenu.numberOfRows(in: DropdownComponent.allCases.firstIndex(of: .color)!)
            ),
            saturation: 1.0,
            brightness: 1.0,
            alpha: 1.0
        )
    }
}
