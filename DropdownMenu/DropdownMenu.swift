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

/// Declares dropdown menu
@objc(PFDropdownMenu)
@IBDesignable open class DropdownMenu: UIView {
    /// Index path for dropdown menu
    @objc(PFIndexPath)
    open class IndexPath: NSObject {
        /// Component of index path
        @objc public let component: Int
        
        /// Row of index path
        @objc public let row: Int
        
        /// Initializer
        /// - parameters:
        ///    - component: Component
        ///    - row: Row
        @objc public init(component: Int, row: Int) {
            self.component = component
            self.row = row
        }
        
        /// Zero index path
        @objc static let zero = IndexPath(component: 0, row: 0)
    }
    
    // MARK: - Properties

    /// Data source object
    @objc public weak var dataSource: DropdownMenuDataSource? {
        didSet {
            if window != nil { reload() }
        }
    }

    /// Delegate object
    @objc public weak var delegate: DropdownMenuDelegate?

    /// The view the dropdown to be presented in. If not specified, the dropdown will be presented in the containing window.
    @objc public var presentingView: UIView?

    /// If presented in scroll view, its vertical content offset will be updated to fit the dropdown. Default is `false`
    @objc public var adjustsContentOffset = false
    
    /// If presented in scroll view, its bottom content inset will be updated to fit the dropdown. Default is `true`
    @objc public var adjustsContentInset = true
    
    /// Shows a shadow under the dropdown. Default is `true`
    @objc public var dropsShadow: Bool {
        get { return !self.contentViewController.shadowView.isHidden }
        set { self.contentViewController.shadowView.isHidden = !newValue }
    }
    
    /// Bounces table view scroll of the dropdown. Default is `true`
    @objc public var bouncesScroll: Bool {
        get { return contentViewController.tableView.bounces }
        set { contentViewController.tableView.bounces = newValue }
    }
    
    /// Shows the separator above the first row in dropdown, Default is `true`
    @objc public var showsTopRowSeparator: Bool {
        get { return contentViewController.showsTopRowSeparator }
        set { contentViewController.showsTopRowSeparator = newValue }
    }

    /// Shows the separator below the last row in dropdown, Default is `true`
    @objc public var showsBottomRowSeparator: Bool {
        get { return contentViewController.showsBottomRowSeparator }
        set { contentViewController.showsBottomRowSeparator = newValue }
    }
    
    /// Shows the border around the dropdown. Drawn in the same color as row separators. Default is `false`
    @objc public var showsBorder: Bool {
        get { return contentViewController.showsBorder }
        set { contentViewController.showsBorder = newValue }
    }
    
    /// Shows the dropdown's content above the menu instead of normal below. Default is `false`
    @objc public var showsContentAbove: Bool {
        get { return contentViewController.showAbove }
        set { contentViewController.showAbove = newValue }
    }
    
    /// The strength of the screen dimming (black cikir) under presented dropdown. Negative values produce white dimming color instead of black. Default is `0.2`
    @objc public var backgroundDimmingOpacity: CGFloat {
        get {
            var white: CGFloat = 0.0
            var alpha: CGFloat = 0.0
            contentViewController.view.backgroundColor?.getWhite(&white, alpha: &alpha)
            return white == 1.0 ? -alpha : alpha
        }
        set {
            contentViewController.view.backgroundColor = UIColor(white: newValue < 0 ? 1.0 : 0.0, alpha: abs(newValue))
        }
    }
    
    /// The color of the header components separator lines (vertical)
    @objc public var componentSeparatorColor: UIColor? {
        didSet { updateComponentSeparators() }
    }
    
    /// The color of the dropdown rows separator (horizontal)
    @objc public var rowSeparatorColor: UIColor? {
        didSet {
            let color = rowSeparatorColor ?? .defaultSeparator
            contentViewController.tableView.separatorColor = color
            contentViewController.tableView.tableHeaderView?.backgroundColor = color
            contentViewController.borderLayer.strokeColor = color.cgColor
        }
    }
    
    /// The view to place between header component and dropdown (like an arrow in popover). The height of the view's frame is preserved, and the view itself is stretched to fit the width of the dropdown.
    @objc public var spacerView: UIView? {
        didSet { contentViewController.insert(separatorView: spacerView) }
    }
    
    /// The offset for the spacer view
    @objc public var spacerViewOffset: UIOffset {
        get { return contentViewController.separatorViewOffset }
        set { contentViewController.separatorViewOffset = newValue }
    }
    
    /// The background color of the expanded header component
    @objc public var selectedComponentBackgroundColor: UIColor? {
        didSet { updateComponentButtons() }
    }
    
    /// The background color of the dropdown rows. For semi-transparent background colors (alpha < 1), `shouldDropShadow` must be set to `false`. Defaults to white color.
    @objc public var dropdownBackgroundColor: UIColor? {
        get { return contentViewController.tableView.backgroundColor }
        set { contentViewController.tableView.backgroundColor = newValue }
    }

    /// The accessory image in the header components, rotates to indicate open/closed state. Provide an image with `UIImageRenderingModeAlwaysTemplate` to respect the view's tint color.
    @objc public var disclosureIndicatorImage: UIImage? {
        didSet { updateComponentButtons() }
    }
    
    /// The rotation angle (in radians) of the disclosure indicator when the component is selected. Default is `CGFloat.pi`
    @objc public var disclosureIndicatorSelectionRotation = CGFloat.pi {
        didSet { updateComponentButtons() }
    }
    
    /// The technique to use for wrapping and truncating the component title text. Multiline title can be displayed by specifying `NSLineBreakByWordWrapping` or `NSLineBreakByCharWrapping`. Default is `NSLineBreakMode.byTruncatingMiddle`.
    @objc public var componentLineBreakMode = NSLineBreakMode.byTruncatingMiddle {
        didSet { updateComponentButtons() }
    }
    
    /// The alignment of the labels in header components. Default is `NSTextAlignment.center`.
    @objc public var componentTextAlignment = NSTextAlignment.center {
        didSet { updateComponentButtons() }
    }

    /// The alignment of the labels in rows. Default is `NSTextAlignment.left`.
    @objc public var rowTextAlignment: NSTextAlignment {
        get { return contentViewController.textAlignment }
        set {
            contentViewController.textAlignment = newValue
            contentViewController.updateData()
        }
    }

    /// The corner radius of the dropdown. Default is `2.0`.
    @objc public var dropdownCornerRadius: CGFloat {
        get { return contentViewController.cornerRadius }
        set { contentViewController.cornerRadius = newValue }
    }
    
    /// The corners to be rounded in the dropdown. If not set, the dropdown will automatically switch between `UIRectCornerBottomLeft|UIRectCornerBottomRight` for the default presentation and `UIRectCornerTopLeft|UIRectCornerTopRight` when the dropdown is shown above.
    @objc public var dropdownRoundedCorners: UIRectCorner {
        get { return contentViewController.roundedCorners }
        set { contentViewController.roundedCorners = newValue }
    }

    /// If `useFullScreenWidth = true`, the dropdown will occupy the full width of the screen for all components marked in `-dropdownMenu:shouldUseFullRowWidthForComponent:`, otherwise the width of these components will be equal to DropdownMenu's width. Default is `false`.
    @objc public var useFullScreenWidth = false

    /// When `useFullScreenWidth` is enabled, the left inset to screen edge can be specified. Default is 0.
    @objc public var fullScreenInsetsLeft: CGFloat = 0

    /// When `useFullScreenWidth` is enabled, the right inset to screen edge can be specified. Default is 0.
    @objc public var fullScreenInsetsRight: CGFloat = 0

    /// Allow multiple rows selection in dropdown. Default is `false`.
    @objc public var allowsMultipleRowsSelection = false

    /// The currently expanded component. NSNotFound when no components are selected.
    @objc internal(set) public var selectedComponent: Int = NSNotFound
    
    /// The number of components in the dropdown (cached from the data source).
    @objc public var numberOfComponents: Int {
        return components.count
    }
    
    // MARK: - Initializer
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Overrrides
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            reload()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutComponentButtons()
        layoutComponentSeparators()
        
        if selectedComponent != NSNotFound {
            contentViewController.contentInset = contentInsetForSelectedComponent
        }
    }
        
    // MARK: - Other Methods

    /// The number of rows in a component in the dropdown (cached from the data source).
    /// - parameters:
    ///    - component: The component of dropdown menu
    /// - returns: The number of rows in a component in the dropdown.
    @objc(numberOfRowsInComponent:) public func numberOfRows(in component: Int) -> Int {
        assert(
            component >= 0 && component < components.count,
            formattedMessage(format: .assertFailed, message: "Invalid component: \(component)")
        )
        return components[component]
    }
    
    /// The view provided by the delegate via `dropdownMenu(_:viewFor:reusing:)` or nil if the indexPath is not visible.
    /// - parameters:
    ///    - indexPath: The index path
    /// - returns: The view provided by the deleate method if visible. Otherwise `nil`
    @objc(viewForIndexPath:) public func view(for indexPath: DropdownMenu.IndexPath) -> UIView? {
        if selectedComponent == NSNotFound || indexPath.component != selectedComponent {
            return nil
        }
        let indexPath = Foundation.IndexPath(row: indexPath.row, section: 0)
        if contentViewController.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
            let cell = contentViewController.tableView.cellForRow(at: indexPath) as? DropdownMenuTableViewCell
            return cell?.currentCustomView
        }
        return nil
    }

    /// Reload all data from scratch.
    @objc public func reload() {
        setupComponents()
        updateComponentButtons()
        setNeedsLayout()
        contentViewController.updateData()
    }
    
    /// Reload the component header and rows, keeps rows selection.
    /// - parameters:
    ///    - component: The component of the dropdown menu.
    @objc(reloadComponent:) public func reload(component: Int) {
        assert(
            component >= 0 && component < components.count,
            formattedMessage(format: .assertFailed, message: "Invalid component: \(component)")
        )
        guard let dataSource = dataSource else {
            return
        }
        
        let numberOfRows = dataSource.dropdownMenu(self, numberOfRowsIn: component)
        components[component] = numberOfRows
        
        update(button: buttons[component], for: component)
        
        if selectedComponent != NSNotFound && component == selectedComponent {
            contentViewController.updateData()
        }
    }
    
    /// Selecting / deselecting index path, makes the corresponding rows reload. Provide visual feedback by implementing the desired behavior in appropriate delegate methods, e.g. `dropdownMenu(_:accessoryViewFor:)`
    /// - parameters:
    ///    - indexPath: The index path for the dropdown menu
    @objc(selectIndexPath:) public func select(indexPath: DropdownMenu.IndexPath) {
        assert(
            indexPath.component >= 0 && indexPath.component < components.count &&
                indexPath.row >= 0 && indexPath.row < components[indexPath.component],
            formattedMessage(
                format: .assertFailed,
                message: "Invalid indexPath: (component: \(indexPath.component), row: \(indexPath.row))"
            )
        )
        var indexesToUpdate = IndexSet()
        if !allowsMultipleRowsSelection {
            for idx in selectedRows[indexPath.component] {
                indexesToUpdate.insert(idx)
            }
            selectedRows[indexPath.component].removeAll()
        }
        
        selectedRows[indexPath.component].insert(indexPath.row)
        indexesToUpdate.insert(indexPath.row)
        
        if indexPath.component == selectedComponent {
            contentViewController.updateData(at: indexesToUpdate)
        }
    }
    
    /// Deselecting index path, makes the corresponding rows reload. Provide visual feedback by implementing the desired behavior in appropriate delegate methods, e.g. `dropdownMenu(_:accessoryViewFor:)`
    /// - parameters:
    ///    - indexPath: The index path for the dropdown menu
    @objc(deselectIndexPath:) public func deselect(indexPath: DropdownMenu.IndexPath) {
        assert(
            indexPath.component >= 0 && indexPath.component < components.count &&
                indexPath.row >= 0 && indexPath.row < components[indexPath.component],
            formattedMessage(
                format: .assertFailed,
                message: "Invalid indexPath: (component: \(indexPath.component), row: \(indexPath.row))"
            )
        )
        
        selectedRows[indexPath.component].remove(indexPath.row)
        
        if indexPath.component == selectedComponent {
            contentViewController.updateData(at: IndexSet(integer: indexPath.row))
        }
    }

    /// Indexes of selected rows in the specified component or empty set if nothing is selected.
    /// - parameters:
    ///    - component: The component of the dropdown menu.
    /// - returns: Indexes of selected rows in the specified component or empty set.
    @objc(selectedRowsInComponent:) public func selectedRows(in component: Int) -> IndexSet {
        assert(
            component >= 0 && component < components.count,
            formattedMessage(format: .assertFailed, message: "Invalid component: \(component)")
        )
        return selectedRows[component]
    }
    
    /// Open the specified component. If other component is open, it will be closed first.
    /// - parameters:
    ///    - component: The component of the dropdown menu.
    ///    - animated: Whether animated.
    @objc(openComponent:animated:) public func open(component: Int, animated: Bool) {
        assert(
            component >= 0 && component < components.count,
            formattedMessage(format: .assertFailed, message: "Invalid component: \(component)")
        )
        
        let previous = selectedComponent
        
        func presentation() {
            selectedComponent = component
            presentDropdownForSelectedComponent(animated: animated, completion: nil)
            if component != NSNotFound {
                delegate?.dropdownMenu?(self, didOpen: component)
            }
        }
        
        if previous != NSNotFound {
            dismissDropdown(animated: animated) {
                presentation()
            }
            delegate?.dropdownMenu?(self, didClose: previous)
        } else {
            presentation()
        }
    }
    
    /// Close all components
    /// - parameters:
    ///    - animated: Whether animated.
    @objc(closeAllComponentsAnimated:) public func closeAllComponents(animated: Bool) {
        dismissDropdown(animated: animated, completion: nil)
        cleanupSelectedComponents()
    }

    /// Moves the dropdown view so that it appears on top of all other subviews in presenting view.
    @objc public func bringDropdownViewToFront() {
        contentViewController.view.superview?.bringSubviewToFront(self)
    }
    
    // MARK: - Internal properties
    var transition: DropdownMenuTransition!
    var contentViewController: DropdownMenuContentViewController!
    var buttons: [DropdownMenuComponentButton] = []
    var separators: [UIView] = []
    
    var components: [Int] = []
    var selectedRows: [IndexSet] = []
}
