#  DropdownMenu (PFDropdownMenu)

Dropdown menu for iOS.

## License

`DropdownMenu` is available under the MIT License. See the LICENSE file for more info.

## Installation

DropdownMenu supports to install Swift Package Manager (SwiftPM), Cartahge and CocoaPods.

### SwiftPM

#### via Xcode

You can add this framework via Xcode.

#### via Package.swift

Edit `Package.swift` to add dependencies.

Example:

```
dependencies: [
    .package(url: "https://github.com/saitomarch/DropdownMenu.git", .upToNextMajor(from: "0.4.0"))
]
```

### Carthage

You can add this framework via Carthage by adding below to `Cartfile`.

```
github "saitomarch/DropdownMenu"
```

### CocoaPods

You can add this framework via CocoaPods by adding below to `Podfile`.

```
pod 'PFDropdownMenu', git => 'https://github.com/saitomarch/DropdownMenu'
```

## Usage

```swift
let dropdownMenu = DropdownMenu(frame: CGRect(x: 0.0, y: 0.0, width: view.bounds.size.width, height: 44.0)
dropdownMenu.dataSource = self
dropdownMenu.delegate = self
view.addSubview(dropdownMenu)
```

```objc
PFDropdownMenu *dropdownMenu = [[PFDropdownMenu alloc] initWithFrame: CGRectMane(0.0, 0,0, self.view.bounds.size.width, 44.0];
dropdownMenu.dataSource = self;
dropdownMenu.delegate = self;
[self.view addSubview: dropdownMenu]
```

## Acknowledgment

`DropdonwMenu` is inspired by [MKDropdownMenu](https://github.com/maxkonovalov/MKDropdownMenu).
