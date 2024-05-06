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

// swiftlint:disable type_body_length
class DropdownMenuContentViewController: UIViewController {
    // MARK: - Properties
    private var heightConstraint: NSLayoutConstraint!
    private var topConstraint: NSLayoutConstraint!
    private var leftConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    private var bottomConstraint: NSLayoutConstraint!
    private var didSetRoundedCorners = false
    
    weak var delegate: DropdownMenuContentViewControllerDelegate?
    
    var containerView: UIView!
    
    var shadowView: UIView!
    
    var borderView: UIView!
    var borderLayer: CAShapeLayer!
    var showsBorder: Bool {
        get { return !borderView.isHidden }
        set { borderView.isHidden = !newValue }
    }
    var showAbove = false {
        didSet {
            if showAbove {
                topConstraint?.isActive = false
                bottomConstraint?.isActive = true
            } else {
                bottomConstraint?.isActive = false
                topConstraint?.isActive = true
            }
        }
    }
    
    var tableContainerView: UIView!
    var tableView: UITableView!
    
    var separatorContainerView: UIView!
    var separatorViewOffset = UIOffset.zero {
        didSet { updateSeparatorViewOffset() }
    }
    var showsTopRowSeparator: Bool {
        get { return tableView.tableHeaderView != nil }
        set {
            if newValue {
                let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.5))
                header.backgroundColor = tableView.separatorColor
                tableView.tableHeaderView = header
            } else {
                tableView.tableHeaderView = nil
            }
        }
    }
    var showsBottomRowSeparator: Bool {
        get { return tableView.tableFooterView == nil }
        set {
            if newValue {
                tableView.tableFooterView = nil
            } else {
                tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.5))
            }
        }
    }
    
    var highlightColor: UIColor?
    
    var contentInset: UIEdgeInsets {
        get {
            UIEdgeInsets(
                top: topConstraint.constant,
                left: leftConstraint.constant,
                bottom: 0.0,
                right: rightConstraint.constant
            )
        }
        set {
            leftConstraint.isActive = false
            rightConstraint.isActive = false
            leftConstraint.constant = newValue.left
            rightConstraint.constant = newValue.right
            leftConstraint.isActive = true
            rightConstraint.isActive = true
            view.layoutIfNeeded()
        }
    }
    
    var textAlignment = NSTextAlignment.left
    
    var cornerRadius: CGFloat = 0.0
    private var _roundedCorners: UIRectCorner!
    var roundedCorners: UIRectCorner {
        get { return _roundedCorners }
        set {
            _roundedCorners = newValue
            didSetRoundedCorners = true
        }
    }
    
    var rowsCount = 0
    var maxRows = 0
    var maxHeight: CGFloat {
        var limit = maxRows > 0 ? maxRows : Int.max
        limit = min(limit, Int(view.bounds.size.height / tableView.rowHeight))
        return CGFloat(limit) * tableView.rowHeight
    }
    var contentHeight: CGFloat {
        return min(max(CGFloat(rowsCount) * tableView.rowHeight, 0.0), maxHeight)
            + (tableView.tableHeaderView?.frame.size.height ?? 0.0)
            + (tableView.tableFooterView?.frame.size.height ?? 0.0)
    }
    
    // MARK: Methods
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return presentingViewController?.preferredStatusBarStyle ?? .default
    }
    
    // swiftlint:disable function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0.0, alpha: defaultBackgroundDimmingOpacity)
        view.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        
        // Setup views
        
        // Container view
        containerView = UIView()
        containerView.clipsToBounds = false
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Table container view
        tableContainerView = UIView()
        tableContainerView.clipsToBounds = true
        tableContainerView.backgroundColor = .black
        tableContainerView.translatesAutoresizingMaskIntoConstraints = false
        let mask = CAShapeLayer()
        mask.frame = tableContainerView.bounds
        mask.fillColor = UIColor.white.cgColor
        tableContainerView.layer.mask = mask
        cornerRadius = defaultCornerRadius
        
        // Table view
        tableView = UITableView()
        tableView.clipsToBounds = true
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = defaultRowHeight
        tableView.layoutMargins = .zero
        tableView.separatorInset = .zero
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .defaultSeparator
        tableView.translatesAutoresizingMaskIntoConstraints = false
        showsTopRowSeparator = true
        showsBottomRowSeparator = true
        tableView.register(DropdownMenuTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        // Shadow
        shadowView = UIView()
        shadowView.clipsToBounds = false
        shadowView.backgroundColor = .clear
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = shadowOpacity
        shadowView.layer.shadowRadius = defaultCornerRadius
        
        // Separator
        separatorContainerView = UIView()
        separatorContainerView.clipsToBounds = false
        separatorContainerView.backgroundColor = .clear
        separatorContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Border
        borderView = UIView()
        borderView.backgroundColor = .clear
        borderView.isUserInteractionEnabled = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderLayer = CAShapeLayer()
        borderLayer.frame = tableContainerView.bounds
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.defaultSeparator.cgColor
        borderLayer.lineWidth = 1.0
        borderView.layer.addSublayer(borderLayer)
        borderView.isHidden = true
        
        // Add subviews
        view.addSubview(containerView)
        containerView.addSubview(shadowView)
        containerView.addSubview(borderView)
        containerView.addSubview(separatorContainerView)
        containerView.addSubview(tableContainerView)
        tableContainerView.addSubview(tableView)
        
        // Setup constraints
        heightConstraint = NSLayoutConstraint(
            item: tableContainerView!, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: defaultRowHeight
        )
        tableContainerView.addConstraint(heightConstraint)
        
        leftConstraint = NSLayoutConstraint(
            item: containerView!, attribute: .leading, relatedBy: .equal,
            toItem: view, attribute: .leading,
            multiplier: 1.0, constant: 0.0
        )
        rightConstraint = NSLayoutConstraint(
            item: view!, attribute: .trailing, relatedBy: .equal,
            toItem: containerView, attribute: .trailing,
            multiplier: 1.0, constant: 0.0
        )
        view.addConstraints([
            leftConstraint,
            rightConstraint,
            NSLayoutConstraint(
                item: containerView!, attribute: .top, relatedBy: .equal,
                toItem: view, attribute: .top,
                multiplier: 1.0, constant: 0.0
            )
        ])
        
        topConstraint = NSLayoutConstraint(
            item: separatorContainerView!, attribute: .height, relatedBy: .equal,
            toItem: nil, attribute: .notAnAttribute,
            multiplier: 1.0, constant: 0.0
        )
        separatorContainerView.addConstraint(topConstraint)
        
        containerView.addConstraints([
            NSLayoutConstraint(
                item: separatorContainerView!, attribute: .left, relatedBy: .equal,
                toItem: containerView, attribute: .left,
                multiplier: 1.0, constant: 0.0
            ),
            NSLayoutConstraint(
                item: containerView!, attribute: .right, relatedBy: .equal,
                toItem: separatorContainerView, attribute: .right,
                multiplier: 1.0, constant: 0.0
            )
        ])
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: ["v": tableContainerView!]
            )
        )
        
        bottomConstraint = NSLayoutConstraint(
            item: containerView!, attribute: .bottom, relatedBy: .equal,
            toItem: view, attribute: .bottom,
            multiplier: 1.0, constant: 0.0
        )
        view.addConstraint(bottomConstraint)
        bottomConstraint.isActive = false
        
        containerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[s][v]|", options: [], metrics: nil,
                views: ["s": separatorContainerView!, "v": tableContainerView!]
            )
        )
        
        tableContainerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[v]|", options: [], metrics: nil, views: ["v": tableView!]
            )
        )
        tableContainerView.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[v]|", options: [], metrics: nil, views: ["v": tableView!]
            )
        )
        
        containerView.addConstraints([
            NSLayoutConstraint(
                item: shadowView!, attribute: .top, relatedBy: .equal,
                toItem: tableContainerView, attribute: .top,
                multiplier: 1.0, constant: 0.0
            ),
            NSLayoutConstraint(
                item: shadowView!, attribute: .left, relatedBy: .equal,
                toItem: tableContainerView, attribute: .left,
                multiplier: 1.0, constant: 0.0
            ),
            NSLayoutConstraint(
                item: tableContainerView!, attribute: .right, relatedBy: .equal,
                toItem: shadowView, attribute: .right,
                multiplier: 1.0, constant: 0.0
            ),
            NSLayoutConstraint(
                item: tableContainerView!, attribute: .bottom, relatedBy: .equal,
                toItem: shadowView, attribute: .bottom,
                multiplier: 1.0, constant: 0.0
            )
        ])
        containerView.addConstraints([
            NSLayoutConstraint(
                item: borderView!, attribute: .top, relatedBy: .equal,
                toItem: tableContainerView, attribute: .top,
                multiplier: 1.0, constant: 0.0
            ),
            NSLayoutConstraint(
                item: borderView!, attribute: .left, relatedBy: .equal,
                toItem: tableContainerView, attribute: .left,
                multiplier: 1.0, constant: 0.0
            ),
            NSLayoutConstraint(
                item: tableContainerView!, attribute: .right, relatedBy: .equal,
                toItem: borderView, attribute: .right,
                multiplier: 1.0, constant: 0.0
            ),
            NSLayoutConstraint(
                item: tableContainerView!, attribute: .bottom, relatedBy: .equal,
                toItem: borderView, attribute: .bottom,
                multiplier: 1.0, constant: 0.0
            )
        ])
    }
    // swiftlint:enable function_body_length

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContainerHeight()
        updateShadow()
        updateMask()
    }
    
    func updateShadow() {
        let shadowPath = UIBezierPath()
        let bounds = shadowView.bounds
        let position0 = CGPoint(x: bounds.midX, y: bounds.midY)
        let position1 = CGPoint(x: bounds.minX, y: bounds.minY)
        let position2 = CGPoint(x: bounds.minX, y: bounds.maxY)
        let position3 = CGPoint(x: bounds.maxX, y: bounds.maxY)
        let position4 = CGPoint(x: bounds.maxX, y: bounds.minY)
        var pathPosition: [CGPoint]!
        if showAbove {
            pathPosition = [position3, position4, position1, position2]
        } else {
            pathPosition = [position1, position2, position3, position4]
        }
        shadowPath.move(to: position0)
        for position in pathPosition {
            shadowPath.addLine(to: position)
        }
        shadowPath.close()
        shadowView.layer.shadowPath = shadowPath.cgPath
        shadowView.layer.shadowOffset = CGSize(width: 0, height: showAbove ? -1.0 : 1.0)
    }
    
    func updateMask() {
        if !didSetRoundedCorners {
            _roundedCorners = showAbove ? [.topLeft, .topRight] : [.bottomLeft, .bottomRight]
        }
        let radius = cornerRadius
        let maskPath = UIBezierPath(
            roundedRect: tableContainerView.bounds,
            byRoundingCorners: roundedCorners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        if let mask = tableContainerView.layer.mask as? CAShapeLayer {
            mask.path = maskPath.cgPath
        }
        shadowView.layer.shadowRadius = max(radius, defaultCornerRadius)
        
        borderLayer.path = maskPath.cgPath
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        tableView.contentOffset = .zero
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.willDisappear()
    }
    
    func updateData() {
        rowsCount = delegate?.numberOfRows ?? 0
        maxRows = delegate?.maximumNumberOfRows ?? 0
        updateContainerHeight()
        tableView.reloadData()
    }
    
    func updateData(at indexes: IndexSet) {
        var indexPaths: [IndexPath] = []
        for index in indexes {
            indexPaths.append(IndexPath(row: index, section: 0))
        }
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
    
    func updateContainerHeight() {
        heightConstraint.constant = contentHeight
        containerView.layoutIfNeeded()
    }
    
    func insert(separatorView: UIView?) {
        separatorContainerView.subviews.forEach { $0.removeFromSuperview() }

        var height: CGFloat = 0
        if let separator = separatorView {
            height = separator.frame.size.height
            separator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            separator.frame = separatorContainerView.bounds
            separatorContainerView.addSubview(separator)
        }
        
        topConstraint.constant = height
        updateSeparatorViewOffset()
    }
    
    func updateSeparatorViewOffset() {
        separatorContainerView.subviews.forEach { [weak self] in
            guard let self = self else { return }
            $0.frame = self.separatorContainerView.frame.offsetBy(
                dx: self.separatorViewOffset.horizontal,
                dy: self.separatorViewOffset.vertical
            )
        }
    }
}
// swiftlint:enable type_body_length
