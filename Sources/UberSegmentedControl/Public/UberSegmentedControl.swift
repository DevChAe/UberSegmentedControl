//
//  UberSegmentedControl.swift
//
//
//  Created by Ruben Nine on 14/07/2020.
//

import UIKit

/// A control made of multiple segments, each segment functioning as a discrete button with support for single or
/// multiple selection mode.
open class UberSegmentedControl: UIControl {
    // MARK: - Public Properties

    /// A segment index value indicating that there is no selected segment. See `selectedSegmentIndex` for further information.
    public class var noSegment: Int { -1 }

    /// Whether this segmented control allows multiple selection.
    private(set) public var allowsMultipleSelection: Bool {
        get { config.allowsMultipleSelection }
        set { config.allowsMultipleSelection = newValue }
    }

    /// A Boolean value that determines whether segments in the receiver show selected state.
    open var isMomentary: Bool = false {
        didSet {
            gestureHandler.isMomentary = isMomentary

            if isMomentary && allowsMultipleSelection {
                allowsMultipleSelection = false
            }
            
            let color = isMomentary || allowsMultipleSelection ? selectedSegmentTintColor : nil

            for segment in segments {
                segment.selectedBackgroundColor = color
            }
        }
    }

    /// Returns the number of segments the receiver has.
    open var numberOfSegments: Int { segmentsStackView.arrangedSubviews.count }

    /// The natural size for the control.
    open override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: config.segmentHeight)
    }

    // MARK: - Private Properties

    private var segments: [SegmentButton] { segmentsStackView.arrangedSubviews.compactMap { $0 as? SegmentButton } }
    private var selectionButton: SegmentButton?
    private lazy var gestureHandler = StackViewGestureHandler(stackView: segmentsStackView, tracksMultiple: allowsMultipleSelection, isMomentary: isMomentary)

    private let longPressGestureRecognizer = UILongPressGestureRecognizer()
    private let panGestureRecognizer = UIPanGestureRecognizer()

    private let buttonObservers = NSMapTable<SegmentButton, NSKeyValueObservation>(keyOptions: .weakMemory,
                                                                                   valueOptions: .strongMemory)

    private let dividersStackView: UIStackView = {
        let stackView = UIStackView()

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.layoutMargins = Constants.Margins.dividerInsets
        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
    }()

    private let segmentsStackView: UIStackView = {
        let stackView = UIStackView()

        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.Measure.spacingBetweenSegments
        stackView.layoutMargins = Constants.Margins.segmentInsets
        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
    }()

    public private(set) var config: Config

    // MARK: - Lifecycle

    /// Initializes and returns a segmented control with segments having the given titles or images.
    ///
    /// - Parameter items: An array of NSString objects (for segment titles) or UIImage objects (for segment images).
    /// - Parameter config: A `Config` object.
    public init(items: [Any]? = nil, config: Config = Config()) {
        self.config = config

        super.init(frame: .zero)

        setup()

        if let items = items {
            for (idx, item) in items.enumerated() {
                switch item {
                case let title as String:
                    insertSegment(withTitle: title, at: idx, animated: false)
                case let image as UIImage:
                    insertSegment(with: image, at: idx, animated: false)
                default:
                    break
                }
            }
        }
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - View Overrides

extension UberSegmentedControl {
    open override func layoutSubviews() {
        super.layoutSubviews()

        if !allowsMultipleSelection && !isMomentary {
            // Ensure `selectionButton` is setup when single selection mode is used and a segment is selected.
            if selectionButton == nil, let segmentIndex = selectedSegmentIndexes.first {
                let segment = segments[segmentIndex]

                if segment.isSelected {
                    updateSelectionButton(using: segment)
                }
            }
        }
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()

        addGestureRecognizer(longPressGestureRecognizer)
        if !config.denyPanGesture {
            addGestureRecognizer(panGestureRecognizer)
        }

        if !allowsMultipleSelection {
            buttonObservers.removeAllObjects()

            // Keep `isHighlighted` state synchronized between `selectionButton` and `button` when using
            // single selection mode.
            for segment in segments {
                buttonObservers.setObject(segment.observe(\.isHighlighted, changeHandler: { (button, change) in
                    if self.selectionButton?.center == button.center {
                        self.selectionButton?.isHighlighted = button.isHighlighted
                    }
                }), forKey: segment)
            }
        }
    }

    open override func removeFromSuperview() {
        super.removeFromSuperview()

        removeGestureRecognizer(longPressGestureRecognizer)
        if !config.denyPanGesture {
            removeGestureRecognizer(panGestureRecognizer)
        }

        buttonObservers.removeAllObjects()
    }
}

// MARK: - Open Functions and Properties

extension UberSegmentedControl {
    /// Inserts a segment at a specific position in the receiver and gives it a title as content.
    ///
    /// - Parameter title: A string to use as the segment’s title.
    /// - Parameter segment: An index number identifying a segment in the control.
    /// - Parameter animated: true if the insertion of the new segment should be animated, otherwise false.
    public func insertSegment(withTitle title: String?, at segment: Int, animated: Bool) {
        let button = SegmentButton(font: config.font, tintColor: config.tintColor)

        button.setTitle(title, for: .normal)
        button.accessibilityLabel = title

        insertSegment(withButton: button, at: segment, animated: animated)
    }

    /// Inserts a segment at a specified position in the receiver and gives it an image as content.
    ///
    /// - Parameter image: An image object to use as the content of the segment.
    /// - Parameter segment: An index number identifying a segment in the control.
    /// - Parameter animated: true if the insertion of the new segment should be animated, otherwise false.
    public func insertSegment(with image: UIImage?, at segment: Int, animated: Bool) {
        let button = SegmentButton(font: config.font, tintColor: config.tintColor)

        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .highlighted)

        insertSegment(withButton: button, at: segment, animated: animated)
    }

    /// Removes the specified segment from the receiver, optionally animating the transition.
    ///
    /// - Parameter segment: An index number identifying a segment in the control.
    /// - Parameter animated: true if the removal of the segment should be animated, otherwise false.
    public func removeSegment(at segment: Int, animated: Bool) {
        guard segment < segmentsStackView.arrangedSubviews.count else { return }

        let view = segmentsStackView.arrangedSubviews[segment]

        if let view = dividersStackView.arrangedSubviews.last {
            view.removeFromSuperview()
            dividersStackView.removeArrangedSubview(view)
        }

        let onCompletion: () -> () = {
            view.removeFromSuperview()
            self.segmentsStackView.removeArrangedSubview(view)
        }

        if animated {
            UIView.animate(withDuration: Constants.Duration.regular, animations: {
                view.isHidden = true
            }, completion: { _ in
                onCompletion()
            })
        } else {
            onCompletion()
        }
    }

    /// Removes all segments of the receiver.
    public func removeAllSegments() {
        while numberOfSegments > 0 {
            removeSegment(at: numberOfSegments - 1, animated: false)
        }
    }

    /// Sets the title of a segment.
    ///
    /// - Parameter title: A string to display in the segment as its title.
    /// - Parameter segment: An index number identifying a segment in the control.
    public func setTitle(_ title: String?, forSegmentAt segment: Int) {
        guard segment < segments.count else { return }

        let button = segments[segment]

        button.setTitle(title, for: .normal)
        button.accessibilityLabel = title

        updateSegmentInsets(for: button)
    }

    /// Returns the title of the specified segment.
    ///
    /// - Parameter segment: An index number identifying a segment in the control.
    public func titleForSegment(at segment: Int) -> String? {
        guard segment < segments.count else { return nil }

        return segments[segment].title(for: .normal)
    }

    /// Sets the content of a segment to a given image.
    ///
    /// - Parameter image: An image object to display in the segment.
    /// - Parameter segment: An index number identifying a segment in the control.
    public func setImage(_ image: UIImage?, forSegmentAt segment: Int) {
        guard segment < segments.count else { return }

        let button = segments[segment]

        button.setImage(image, for: .normal)

        updateSegmentInsets(for: button)
    }

    /// Returns the image for a specific segment.
    ///
    /// - Parameter segment: An index number identifying a segment in the control.
    public func imageForSegment(at segment: Int) -> UIImage? {
        guard segment < segments.count else { return nil }

        return segments[segment].image(for: .normal)
    }

    /// Enables the specified segment.
    ///
    /// - Parameter enabled: true to enable the specified segment or false to disable the segment. By default,
    /// segments are enabled.
    /// - Parameter segment: An index number identifying a segment in the control.
    public func setEnabled(_ enabled: Bool, forSegmentAt segment: Int) {
        guard segment < segments.count else { return }

        segments[segment].isEnabled = enabled
    }

    /// Returns whether the indicated segment is enabled.
    ///
    /// - Parameter segment: An index number identifying a segment in the control.
    public func isEnabledForSegment(at segment: Int) -> Bool {
        guard segment < segments.count else { return false }

        return segments[segment].isEnabled
    }

    /// Sets the semantic content attribute for a given segment.
    ///
    /// - Parameter segment: An index number identifying a segment in the control.
    /// - Parameter attribute: A `UISemanticContentAttribute` to apply to the segment.
    public func setSegmentSemanticContentAttribute(at segment: Int, attribute: UISemanticContentAttribute) {
        let button = segments[segment]

        button.semanticContentAttribute = attribute
    }

    /// Sets the default image edge inset for a given segment.
    ///
    /// - Parameter segment: An index number identifying a segment in the control.
    /// - Parameter insets: The `UIEdgeInsets` to apply to the segment's image.
    public func setSegmentImageEdgeInsets(at segment: Int, insets: UIEdgeInsets) {
        let button = segments[segment]

        button.imageEdgeInsets = insets
    }

    /// Sets the default title edge inset for a given segment.
    ///
    /// - Parameter segment: An index number identifying a segment in the control.
    /// - Parameter insets: The `UIEdgeInsets` to apply to the segment's title.
    public func setSegmentTitleEdgeInsets(at segment: Int, insets: UIEdgeInsets) {
        let button = segments[segment]

        button.titleEdgeInsets = insets
    }

    /// The color to use for highlighting the currently selected segment.
    public var selectedSegmentTintColor: UIColor? {
        return config.selectedSegmentTint
    }

    /// Indexes of selected segments (can be more than one if `allowsMultipleSelection` is `true`.)
    @objc open var selectedSegmentIndexes: IndexSet {
        get { IndexSet(segments.enumerated().filter { $1.isSelected }.map { $0.offset }) }

        set {
            guard !isMomentary else { return }

            var shouldDeselectOtherSegments = false

            if newValue.isEmpty {
                selectionButton?.alpha = 0
            }

            for (i, segment) in segments.enumerated() {
                if shouldDeselectOtherSegments {
                    segment.isSelected = false
                } else {
                    segment.isSelected = newValue.contains(i)
                }

                if !allowsMultipleSelection, segment.isSelected {
                    shouldDeselectOtherSegments = true
                    updateSelectionButton(using: segment)
                }
            }

            updateDividers()
        }
    }

    /// The index number identifying the selected segment (that is, the last segment touched).
    ///
    /// - Note: When `allowsMultipleSelection` is enabled, this property returns `UberSegmentedControl.noSegment` and setting a new value does nothing.
    @objc open var selectedSegmentIndex: Int {
        get {
            guard !allowsMultipleSelection else { return UberSegmentedControl.noSegment }

            if let first = selectedSegmentIndexes.first {
                return first
            } else {
                return UberSegmentedControl.noSegment
            }
        }

        set {
            guard !allowsMultipleSelection,
                  newValue >= UberSegmentedControl.noSegment,
                  newValue < numberOfSegments
            else {
                return
            }

            if newValue == UberSegmentedControl.noSegment {
                selectedSegmentIndexes = []
            } else {
                selectedSegmentIndexes = [newValue]
            }
        }
    }
}

// MARK: - Private Functions

private extension UberSegmentedControl {
    func updateSegmentInsets(for segment: SegmentButton) {
        if segment.currentImage != nil, segment.currentTitle != nil {
            segment.titleEdgeInsets = Constants.Margins.titleEdgeInsets
        } else {
            segment.titleEdgeInsets = .zero
        }

        segment.contentEdgeInsets = suggestedContentEdgeInsets(for: segment)
    }

    func suggestedContentEdgeInsets(for segment: SegmentButton) -> UIEdgeInsets {
        if segment.currentTitle != nil, segment.currentImage != nil {
            var insets = Constants.Margins.segmentContentEdgeInsets

            insets.right = segment.titleEdgeInsets.left - (segment.titleEdgeInsets.right * 2)

            return insets
        } else {
            return Constants.Margins.segmentContentEdgeInsets
        }
    }

    func insertSegment(withButton button: SegmentButton, at segment: Int, animated: Bool) {
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false

        updateSegmentInsets(for: button)

        if allowsMultipleSelection || isMomentary {
            button.selectedBackgroundColor = selectedSegmentTintColor
        }

        if animated { button.isHidden = true }

        segmentsStackView.insertArrangedSubview(button, at: segment)
        dividersStackView.addArrangedSubview(DividerView())
        updateDividers()

        if animated { UIView.animate(withDuration: Constants.Duration.regular) { button.isHidden = false } }
    }

    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Constants.Color.background
        layer.cornerRadius = Constants.Measure.cornerRadius

        fill(with: dividersStackView, shouldAutoActivate: true)
        fill(with: segmentsStackView, shouldAutoActivate: true)

        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = 0
        longPressGestureRecognizer.addTarget(self, action: #selector(handleGesture(recognizer:)))

        if !config.denyPanGesture {
            panGestureRecognizer.delegate = self
            panGestureRecognizer.addTarget(self, action: #selector(handleGesture(recognizer:)))
        }
    }

    func updateDividers() {
        let buttons = self.segments

        for (idx, separator) in dividersStackView.arrangedSubviews.enumerated() {
            var nextButton: UIButton?

            if let nextIndex = idx < max(0, segmentsStackView.arrangedSubviews.endIndex - 1) ? idx + 1 : nil {
                nextButton = segmentsStackView.arrangedSubviews[nextIndex] as? UIButton
            }

            if separator == dividersStackView.arrangedSubviews.last {
                separator.alpha = 0
            } else if buttons[idx].isSelected || nextButton?.isSelected == true {
                separator.alpha = 0
            } else {
                separator.alpha = 1
            }
        }
    }

    func handleMultipleSelectionButtonTap(using button: UIButton) {
        button.isSelected = !button.isSelected
    }

    func handleSingleSelectionButtonTap(using button: UIButton) {
        guard !isMomentary else { return }

        updateSelectionButton(using: button)

        for segment in segments {
            segment.isSelected = button == segment
        }
    }

    func handleMomentarySelectionButtonTap(using button: UIButton) {
        let previousSelectedState = button.isSelected
        let previousUserInteractionEnabled = segmentsStackView.isUserInteractionEnabled

        segmentsStackView.isUserInteractionEnabled = false
        button.isSelected = !previousSelectedState

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Duration.snappy) {
            button.isSelected = previousSelectedState
            self.segmentsStackView.isUserInteractionEnabled = previousUserInteractionEnabled

            UIView.animate(withDuration: Constants.Duration.regular) {
                self.updateDividers()
            }
        }
    }

    func updateSelectionButton(using button: UIButton) {
        if button.bounds.size == .zero {
            // Layout segment subviews
            segmentsStackView.layoutSubviews()
        }

        // Ensure button has a size.
        guard button.bounds.size != .zero else { return }

        if selectionButton == nil {
            UIView.setAnimationsEnabled(false)

            let selectionButton = SegmentButton(font: config.font, tintColor: config.tintColor)

            selectionButton.isUserInteractionEnabled = false
            selectionButton.selectedBackgroundColor = selectedSegmentTintColor
            selectionButton.isSelected = true
            selectionButton.center = button.center
            selectionButton.bounds = button.bounds
            selectionButton.alpha = 0

            insertSubview(selectionButton, belowSubview: segmentsStackView)

            UIView.setAnimationsEnabled(true)

            self.selectionButton = selectionButton
        }

        selectionButton?.center = button.center
        selectionButton?.bounds = button.bounds
        selectionButton?.alpha = 1
    }
}

// MARK: - Button Actions

extension UberSegmentedControl {
    @objc func buttonTapped(_ button: UIButton) {
        guard button.isEnabled else { return }

        willChangeValue(for: \.selectedSegmentIndexes)

        if !allowsMultipleSelection {
            willChangeValue(for: \.selectedSegmentIndex)
        }

        if isMomentary {
            UIView.animate(withDuration: Constants.Duration.snappy) {
                self.handleMomentarySelectionButtonTap(using: button)
            }
        } else if allowsMultipleSelection {
            UIView.animate(withDuration: Constants.Duration.snappy) {
                self.handleMultipleSelectionButtonTap(using: button)
            }
        } else {
            UIView.animate(withDuration: Constants.Duration.regular,
                           delay: 0,
                           usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseOut, animations: {
                self.handleSingleSelectionButtonTap(using: button)
            }, completion: { _ in
                /* NO-OP */
            })
        }

        didChangeValue(for: \.selectedSegmentIndexes)

        if !allowsMultipleSelection {
            didChangeValue(for: \.selectedSegmentIndex)
        }

        sendActions(for: .valueChanged)

        UIView.animate(withDuration: Constants.Duration.regular) {
            self.updateDividers()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate Conformance

extension UberSegmentedControl: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Gesture Recognizer Actions

extension UberSegmentedControl {
    @objc func handleGesture(recognizer: UIGestureRecognizer) {
        if let button = gestureHandler.handle(recognizer: recognizer) {
            buttonTapped(button)
        }
    }
}

// MARK: - Config

public extension UberSegmentedControl {
    /// A config object that may be provided to `UberSegmentedControl` upon initialization.
    struct Config: Equatable {
        /// The `UIFont` to use for each segment in the `UberSegmentedControl`.
        public let font: UIFont

        /// The `UIColor` to use for each segment in the `UberSegmentedControl`.
        public let tintColor: UIColor

        /// Whether the `UberSegmentedControl` supports multiple selection.
        public internal(set) var allowsMultipleSelection: Bool
        
        public let segmentHeight: CGFloat
        
        public let selectedSegmentTint: UIColor
        
        public let denyPanGesture: Bool

        /// Default font.
        public static let defaultFont = Constants.Font.segmentTitleLabel

        /// Default tint color.
        public static let defaultTintColor = Constants.Color.label
        
        public static let defaultSegmentHeight = Constants.Measure.segmentHeight
        public static let defaultSelectedSegmentTint = Constants.Color.selectedSegmentTint

        /// Initializes a new `Config` object with any user-provided options.
        public init(font: UIFont = Config.defaultFont,
                    tintColor: UIColor = Config.defaultTintColor,
                    segmentHeight: CGFloat = Config.defaultSegmentHeight,
                    selectedSegmentTint: UIColor = Config.defaultSelectedSegmentTint,
                    denyPanGesture: Bool = false,
                    allowsMultipleSelection: Bool = false) {
            self.font = font
            self.tintColor = tintColor
            self.segmentHeight = segmentHeight
            self.selectedSegmentTint = selectedSegmentTint
            self.denyPanGesture = denyPanGesture
            self.allowsMultipleSelection = allowsMultipleSelection
        }
    }
}
