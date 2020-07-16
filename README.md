# UberSegmentedControl

A control based on `UISegmentedControl` that supports single or multiple selected segments. 

<p align="center">
    <img src="Animations/UberSegmentedControl-Demo.gif?raw=true" alt="UberSegmentedControl Demo" width="375" height="667" />
</p>

## Requirements

- iOS 9.0+ / iPadOS 13+
- Xcode 11+
- Swift 4.2+

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
