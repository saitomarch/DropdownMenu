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
import Foundation

extension Reactive where Base: DropdownMenu {
    /// Reactive wrapper for `delegate`
    public var delegate: DelegateProxy<DropdownMenu, DropdownMenuDelegate> {
        return RxDropdownMenuDelegateProxy.proxy(for: base)
    }
    
    /// Reactive wrapper for `dataSource`
    public var dataSource: DelegateProxy<DropdownMenu, DropdownMenuDataSource> {
        return RxDropdownMenuDataSourceProxy.proxy(for: base)
    }
    
    /// Installs data source as forwarning delegate on `rx.dataSource`.
    /// Data source won't be installed
    ///
    /// It enables using normal delegate mechanism, with reactive delegate mechanism.
    ///
    /// - parameter dataSource: Data source object.
    /// - returns: Disposable object that can be used to unbind the data source
    public func setDataSource(_ dataSource: DropdownMenuDataSource) -> Disposable {
        return RxDropdownMenuDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: base)
    }
    
    // MARK: - Events
    
    /// Reactive wrapper for `delegate` message `dropdownMenu(_:didSelect:)`
    public var itemSelected: ControlEvent<DropdownMenu.IndexPath> {
        let source = delegate
            .methodInvoked(#selector(DropdownMenuDelegate.dropdownMenu(_:didSelect:)))
            .map { try castOrThrow(object: $0[1], resultType: DropdownMenu.IndexPath.self) }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `dropdownMenu(_:didOpen:)`
    public var open: ControlEvent<Int> {
        let source = delegate
            .methodInvoked(#selector(DropdownMenuDelegate.dropdownMenu(_:didOpen:)))
            .map { try castOrThrow(object: $0[1], resultType: Int.self) }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `dropdownMenu(_:didClose:)`
    public var close: ControlEvent<Int> {
        let source = delegate
            .methodInvoked(#selector(DropdownMenuDelegate.dropdownMenu(_:didClose:)))
            .map { try castOrThrow(object: $0[1], resultType: Int.self) }
        return ControlEvent(events: source)
    }
}
