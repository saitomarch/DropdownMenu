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
    @objc private(set) public var selectedComponent: Int = NSNotFound
    
    /// The number of components in the dropdown (cached from the data source).
    @objc public var numberOfComponents: Int {
        return components.count
    }
    
    // MARK: Initializer
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        contentViewController = DropdownMenuContentViewController()
        contentViewController.delegate = self
        
        // load content view
        _ = contentViewController.view
        
        transition = DropdownMenuTransition(dropdownMenu: self, contentViewController: contentViewController)
    }
    
    // MARK: Methods

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
                indexPath.row >= 0 && indexPath.row < components[indexPath.component]
            , formattedMessage(
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
                indexPath.row >= 0 && indexPath.row < components[indexPath.component]
            , formattedMessage(
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
    
    // MARK: - Internal methods
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
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            reload()
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
                message: "Total width for components (\(totalCustomWidth)) must not be greater than view bounds width (\(bounds.size.width))"
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutComponentButtons()
        layoutComponentSeparators()
        
        if selectedComponent != NSNotFound {
            contentViewController.contentInset = contentInsetForSelectedComponent
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
        return delegate?.dropdownMenu?(self, backgroundColorFor: IndexPath(component: selectedComponent, row: row)) ?? .clear
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
