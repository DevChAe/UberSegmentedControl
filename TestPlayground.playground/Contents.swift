//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import UberSegmentedControl

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()

        view.backgroundColor = .systemYellow
        view.overrideUserInterfaceStyle = .light

        let items = ["Bold", "Italics", "Underline"]

        let uiSC = UISegmentedControl(items: items)
        let uberSC = UberSegmentedControl(items: items)
        let uberMultiSC = UberSegmentedControl(items: items, allowsMultipleSelection: true)

        let imageItems = [
            UIImage(named: "ic_mail_outline_18pt")!,
            UIImage(named: "ic_import_contacts_18pt")!,
            UIImage(named: "ic_contact_phone_18pt")!,
        ]

        let uiImageSC = UISegmentedControl(items: imageItems)
        let uberImageSC = UberSegmentedControl(items: imageItems)
        let uberMultiImageSC = UberSegmentedControl(items: imageItems, allowsMultipleSelection: true)

        let uberImageAndLabelSC = UberSegmentedControl(items: imageItems, allowsMultipleSelection: true)

        for (idx, label) in ["Mail", "Book", "Phone"].enumerated() {
            uberImageAndLabelSC.setTitle(label, forSegmentAt: idx)
        }

        let stackView = UIStackView(arrangedSubviews: [
            label(titled: "UISegmentedControl"),
            uiSC,
            uiImageSC,
            UIView(),
            label(titled: "UberSegmentedControl"),
            uberSC,
            uberImageSC,
            label(titled: "With Multiple Selection", fontSize: UIFont.smallSystemFontSize),
            uberMultiSC,
            uberMultiImageSC,
            label(titled: "With Image and Title", fontSize: UIFont.smallSystemFontSize),
            uberImageAndLabelSC
        ])

        // Toggle segments 0 and 2 on
        uberMultiImageSC.selectedSegmentIndexes = IndexSet([0, 2])

        // Disable segment 1
        uberMultiImageSC.setEnabled(false, forSegmentAt: 1)

        // Handle value changes
        uberMultiImageSC.addTarget(self, action: #selector(uberSCChanged), for: .valueChanged)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10

        view.addSubview(stackView)

        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        self.view = view
    }
}

// MARK: - Actions

extension MyViewController {
    @objc func uberSCChanged(_ sender: UberSegmentedControl) {
        print("selectedSegmentIndexes: \(Array(sender.selectedSegmentIndexes))")
    }
}

// MARK: - Private Functions

private extension MyViewController {
    func label(titled title: String, fontSize: CGFloat = UIFont.labelFontSize) -> UILabel {
        let label = UILabel()

        label.text = title
        label.font = .systemFont(ofSize: fontSize)
        label.textColor = .label
        label.textAlignment = .center

        return label
    }
}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
