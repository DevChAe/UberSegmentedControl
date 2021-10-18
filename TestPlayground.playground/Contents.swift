//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import UberSegmentedControl

class MyViewController : UIViewController {
    let items = ["Bold", "Italics", "Underline"]

    let imageItems = [
        UIImage(named: "ic_mail_outline_18pt")!,
        UIImage(named: "ic_import_contacts_18pt")!,
        UIImage(named: "ic_contact_phone_18pt")!,
    ]

    lazy var uiSC = UISegmentedControl(items: items)
    lazy var uiImageSC = UISegmentedControl(items: imageItems)

    lazy var uiMomentarySC: UISegmentedControl = {
        let control = UISegmentedControl(items: items)

        control.isMomentary = true
        control.addTarget(self, action: #selector(uiSCChanged), for: .valueChanged)

        return control
    }()

    lazy var customConfig = UberSegmentedControl.Config(
        font: .monospacedSystemFont(ofSize: 10, weight: .bold),
        tintColor: .systemRed,
        allowsMultipleSelection: false
    )

    lazy var uberSC = UberSegmentedControl(items: items)
    lazy var uberMultiSC = UberSegmentedControl(items: items, config: UberSegmentedControl.Config(allowsMultipleSelection: true))
    lazy var uberImageSC = UberSegmentedControl(items: imageItems)
    lazy var uberSCWithCustomConfig = UberSegmentedControl(items: items, config: customConfig)

    lazy var uberMultiImageSC: UberSegmentedControl = {
        let control = UberSegmentedControl(items: imageItems, config: UberSegmentedControl.Config(allowsMultipleSelection: true))

        control.addTarget(self, action: #selector(uberSCChanged), for: .valueChanged)

        // Toggle segments 0 and 2 on
        control.selectedSegmentIndexes = IndexSet([0, 2])

        // Disable segment 1
        control.setEnabled(false, forSegmentAt: 1)

        return control
    }()

    lazy var uberImageAndLabelSC: UberSegmentedControl = {
        let control = UberSegmentedControl(items: imageItems, config: UberSegmentedControl.Config(allowsMultipleSelection: true))

        for (idx, label) in ["Mail", "Book", "Phone"].enumerated() {
            control.setTitle(label, forSegmentAt: idx)
        }

        return control
    }()

    lazy var uberMomentarySC: UberSegmentedControl = {
        let control = UberSegmentedControl(items: items)

        control.isMomentary = true
        control.addTarget(self, action: #selector(uberSCChanged), for: .valueChanged)

        return control
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            label(titled: "UISegmentedControl"),
            uiSC,
            uiImageSC,
            uiMomentarySC,
            UIView(),
            label(titled: "UberSegmentedControl"),
            uberSC,
            uberImageSC,
            label(titled: "With Multiple Selection", fontSize: UIFont.smallSystemFontSize),
            uberMultiSC,
            uberMultiImageSC,
            label(titled: "With Image and Title", fontSize: UIFont.smallSystemFontSize),
            uberImageAndLabelSC,
            label(titled: "Momentary", fontSize: UIFont.smallSystemFontSize),
            uberMomentarySC,
            label(titled: "Custom Config", fontSize: UIFont.smallSystemFontSize),
            uberSCWithCustomConfig
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10

        return stackView
    }()

    var observers: [NSKeyValueObservation] = []

    override func loadView() {
        let view = UIView()

        view.backgroundColor = .systemBackground
        view.overrideUserInterfaceStyle = .light

        self.view = view
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupObservers()

        view.addSubview(stackView)

        stackView.removeConstraints(stackView.constraints)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeObservers()
        stackView.removeFromSuperview()
    }
}

// MARK: - Actions

extension MyViewController {
    @objc func uiSCChanged(_ sender: UISegmentedControl) {
        print("selectedSegmentIndex: \(sender.selectedSegmentIndex)")
    }

    @objc func uberSCChanged(_ sender: UberSegmentedControl) {
        print("selectedSegmentIndexes: \(Array(sender.selectedSegmentIndexes))")
    }
}

// MARK: - Private Functions

private extension MyViewController {
    func setupObservers() {
        // Observe changes on `uberMomentarySC.selectedSegmentIndexes`.
        observers.append(uberMomentarySC.observe(\.selectedSegmentIndex, options: [.new, .old]) { (control, change) in
            if let oldIndex = change.oldValue, let newIndex = change.newValue {
                print("oldIndex: \(oldIndex), newIndex: \(newIndex)")
            }
        })

        // Observe changes on `uberMomentarySC.selectedSegmentIndexes`.
        observers.append(uberMultiImageSC.observe(\.selectedSegmentIndexes, options: [.new, .old]) { (control, change) in
            if let oldIndexes = change.oldValue, let newIndexes = change.newValue {
                print("oldIndexes: \(Array(oldIndexes)), newIndexes: \(Array(newIndexes))")
            }
        })
    }

    func removeObservers() {
        observers.removeAll()
    }

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
