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

/// Delegate protocol for dropdown menu
@objc(PFDropdownMenuDelegate)
public protocol DropdownMenuDelegate: class {
    /// Width for component
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu
    ///    - component: The component for dropdown menu
    /// - returns: Width for component
    @objc(dropdownMenu:widthForCompnent:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, widthFor component: Int) -> CGFloat
    
    /// Return `true` if the dropdown for this component should occupy the full width of the menu, otherwise its width will be equal to its header component's width. If `useFullScreenWidth = true`, the width of the dropdown for the specified component will be equal to screen width minus `fullScreenInsetLeft` and `fullScreenInsetRight`. Default is `true`.
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu
    ///    - component: The component for dropdown menu
    /// - returns: `true` or `false`
    @objc(dropdownMenu:shouldUseFullRowWidthForComponent:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, shouldUseFullRowWidthFor component: Int) -> Bool
    
    /// The maximum rows limit
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu
    ///    - component: The component for dropdown menu
    /// - returns:The maximum rows limit.
    @objc(dropdownMenu:maximumNumberOfRowInComponent:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, maximumNumberOfRowsIn component: Int) -> Int
    
    /// Row height for component
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu
    ///    - component: The component for dropdown menu
    /// - returns: Row height for component
    @objc(dropdownMenu:rowHeightForComponent:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, rowHeightFor component: Int) -> CGFloat
    
    /// Title for a header component
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu
    ///    - component:The component for dropdown menu
    /// - returns: Title for a header component
    @objc(dropdownMenu:titleForComponent:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, titleFor component: Int) -> String?
    
    /// Title for a selected header component
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu
    ///    - component:The component for dropdown menu
    /// - returns: Title for a selected header component
    @objc(dropdownMenu:titleForSelectedComponent:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, titleForSelected component: Int) -> String?

    /// Attributed title for a header component
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu
    ///    - component:The component for dropdown menu
    /// - returns: Title for a header component
    @objc(dropdownMenu:attributedTitleForComponent:)
    optional func dropdownMenu(
        _ dropdownMenu: DropdownMenu,
        attributedTitleFor component: Int
    ) -> NSAttributedString?
    
    /// Attributed title for a selected header component
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu
    ///    - component:The component for dropdown menu
    /// - returns: Title for a selected header component
    @objc(dropdownMenu:attributedTitleForSelectedCoopnent:)
    optional func dropdownMenu(
        _ dropdownMenu: DropdownMenu,
        attributedTitleForSelected component: Int
    ) -> NSAttributedString?
    
    /// The custom view for a header component
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - component: The component for dropdown menu
    /// - returns:The custom view for a header component
    @objc(dropdownMenu:viewForComponent:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, viewFor component: Int) -> UIView?
    
    /// Title for a index path
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - indexPath: The index oath for dropdown menu
    /// - returns: Title for a index path
    @objc(dropdownMenu:titleForIndexPath:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, titleFor indexPath: DropdownMenu.IndexPath) -> String?

    /// Attributed title for a index path
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - indexPath: The index oath for dropdown menu
    /// - returns: Attributed title for a index path
    @objc(dropdownMenu:attributedTitleForIndexPath:)
    optional func dropdownMenu(
        _ dropdownMenu: DropdownMenu,
        attributedTitleFor indexPath: DropdownMenu.IndexPath
    ) -> NSAttributedString?

    /// The custom view for a index path
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - indexPath: The index oath for dropdown menu
    ///    - view: The reusing view
    /// - returns: The custom view for a index path
    @objc(dropdownMenu:viewForIndexPath:reusingView:)
    optional func dropdownMenu(
        _ dropdownMenu: DropdownMenu,
        viewFor indexPath: DropdownMenu.IndexPath,
        reusing view: UIView?
    ) -> UIView?
    
    /// The accessory view for index path, e,g, selection indicator
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - indexPath: The index oath for dropdown menu
    /// - returns: The accessory view for index path
    @objc(dropdownMenu:accessoryViewForIndexPath:)
    optional func dropdownMenu(
        _ dropdownMenu: DropdownMenu,
        accessoryViewFor indexPath: DropdownMenu.IndexPath
    ) -> UIView?
    
    /// The background color for the index path
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - indexPath: The index oath for dropdown menu
    /// - returns: The background color for the index path
    @objc(dropdownMenu:backgroundColorForIndexPath:)
    optional func dropdownMenu(
        _ dropdownMenu: DropdownMenu,
        backgroundColorFor indexPath: DropdownMenu.IndexPath
    ) -> UIColor?
    
    /// The background color for the hilighted index path
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - component: The component for dropdown menu
    /// - returns: The background color for the highlighted index path
    @objc(dropdownMenu:backgroundColorForHighlughtedRowsInComponent:)
    optional func dropdownMenu(
        _ dropdownMenu: DropdownMenu,
        backgroundColorForHighlightedRowsIn component: Int
    ) -> UIColor?
    
    /// Return `true` if the component is used as a dummy space for other components and should not be interacted with. The disclosure indicator is hidden for such components. Default is `true`.
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - component: The component for dropdown menu
    /// - returns: `true` if enabled, otherwise `false`
    @objc(dropdownMenu:shouldEnableComponent:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, shouldEnable component: Int) -> Bool
    
    /// Called when a row was tapped. If selection needs to be handled, use `(de)select(_:)` as appropritate.
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - indexPath: The index oath for dropdown menu
    @objc(dropdownMenu:didSelectIndexPath:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, didSelect indexPath: DropdownMenu.IndexPath)
    
    /// Called when the component was opened
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - component: The component for dropdown menu
    @objc(dropdownMenu:didOpenComponent:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, didOpen component: Int)
    
    /// Called when the component was closed
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu.
    ///    - component: The component for dropdown menu
    @objc(dropdownMenu:didCloseComponent:)
    optional func dropdownMenu(_ dropdownMenu: DropdownMenu, didClose component: Int)
 }
