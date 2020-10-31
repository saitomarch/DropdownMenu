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

import Foundation

/// Declares data source for dropdown menu
@objc(PFDropdownMenuDataSource)
public protocol DropdownMenuDataSource: class {
    /// Number of component items in menu
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu
    /// - returns: Number of components of items in menu
    @objc(numberOfComponentsInDropdownMenu:)
    func numberOfComponentsIn(_ dropdownMenu: DropdownMenu) -> Int
    
    /// Number of rows in each component
    /// - parameters:
    ///    - dropdownMenu: The dropdown menu
    ///    - component:The component for dropdown menu
    /// - returns: Number of components of items in menu
    @objc(dropdownMenu:numberOfRowsInComponent:)
    func dropdownMenu(_ dropdownMenu: DropdownMenu, numberOfRowsIn component: Int) -> Int
}
