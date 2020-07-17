# UberSegmentedControl

<img align="right" src="Animations/UberSegmentedControl-Demo.gif?raw=true" alt="UberSegmentedControl Demo" width="300" height="300" />

A control inspired by Apple's `UISegmentedControl` that allows single or multiple selection and can display segments containing: only a title, only an image, or both at the same time.

## Features

- Allows single or multiple selection
- Segments may display titles, images or both at the same time
- Supports both light and dark appearance (only iOS / iPadOS 13+)

## Requirements

- iOS 9.0+ / iPadOS 13+
- Xcode 11+
- Swift 4.2+

<br clear="right"/>

## Usage

```swift
override func loadView() {
  let items = ["Bold", "Italics", "Underline"]

  let uberSC = UberSegmentedControl(items: items, allowsMultipleSelection: true)

  // Toggle segments 0 and 2 on
  uberSC.selectedSegmentIndexes = IndexSet([0, 2])

  // Disable segment 1
  uberSC.setEnabled(false, forSegmentAt: 1)

  // Handle value changes
  uberSC.addTarget(self, action: #selector(uberSCChanged), for: .valueChanged)
  
  view.addSubview(uberSC)
}

@objc func uberSCChanged(_ sender: UberSegmentedControl) {
    print("selectedSegmentIndexes: \(Array(sender.selectedSegmentIndexes))")
}
```

## Notes

See `TestPlayground.playground` for a full working example.

## License

UberSegmentedControl is released under the MIT license. See [LICENSE](LICENSE) for details.
