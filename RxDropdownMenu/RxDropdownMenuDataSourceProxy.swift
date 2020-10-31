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

import DropdownMenu
import RxSwift
import RxCocoa

extension DropdownMenu: HasDataSource {
    public typealias DataSource = DropdownMenuDataSource
}

private let dropdownMenuDataSourceNotSet = DropdownMenuDataSourceNotSet()

private final class DropdownMenuDataSourceNotSet: DropdownMenuDataSource {
    func numberOfComponentsIn(_ dropdownMenu: DropdownMenu) -> Int {
        return 0
    }
    
    func dropdownMenu(_ dropdownMenu: DropdownMenu, numberOfRowsIn component: Int) -> Int {
        return 0
    }
}

open class RxDropdownMenuDataSourceProxy: DelegateProxy<DropdownMenu, DropdownMenuDataSource>,
                                          DelegateProxyType, DropdownMenuDataSource {
    /// Typed parent object
    public weak private(set) var dropdownMenu: DropdownMenu!
    
    /// Parameter dropdownMenu: Parent object for delegate proxy
    public init(dropdownMenu: ParentObject) {
        self.dropdownMenu = dropdownMenu
        super.init(parentObject: dropdownMenu, delegateProxy: RxDropdownMenuDataSourceProxy.self)
    }
    
    /// Register known implementations
    public static func registerKnownImplementations() {
        register { RxDropdownMenuDataSourceProxy(dropdownMenu: $0) }
    }
    
    private weak var requiredMethodDataSource: DropdownMenuDataSource? = dropdownMenuDataSourceNotSet
    
    public func numberOfComponentsIn(_ dropdownMenu: DropdownMenu) -> Int {
        return (requiredMethodDataSource ?? dropdownMenuDataSourceNotSet).numberOfComponentsIn(dropdownMenu)
    }
    
    public func dropdownMenu(_ dropdownMenu: DropdownMenu, numberOfRowsIn component: Int) -> Int {
        return (requiredMethodDataSource ?? dropdownMenuDataSourceNotSet)
            .dropdownMenu(dropdownMenu, numberOfRowsIn: component)
    }
    
    open override func setForwardToDelegate(
        _ delegate: DelegateProxy<DropdownMenu, DropdownMenuDataSource>.Delegate?,
        retainDelegate: Bool) {
        requiredMethodDataSource = delegate ?? dropdownMenuDataSourceNotSet
        super.setForwardToDelegate(delegate, retainDelegate: retainDelegate)
    }
}
