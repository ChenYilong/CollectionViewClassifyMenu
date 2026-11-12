//
//  CYLAndroidSampleSupport.swift
//  CYLMenuExample
//
//  What the three Android sample ports share: a toast (Android's Toast), the samples' filled buttons and text fields,
//  and the pictures of the TagViewGroup sample (its photos were remote; these are drawn).
//

import UIKit

enum CYLAndroidSample {

    /// A message at the bottom of `view` for two seconds, as Android's Toast.LENGTH_SHORT.
    static func toast(_ text: String, in view: UIView) {
        view.viewWithTag(Self.toastTag)?.removeFromSuperview()
        let label = CYLPaddedLabel()
        label.tag = Self.toastTag
        label.text = text
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .white
        label.backgroundColor = UIColor(white: 0.2, alpha: 0.85)
        label.layer.cornerRadius = 18
        label.layer.masksToBounds = true
        label.accessibilityIdentifier = "CYLAndroidSampleToast"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -48),
            label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -48),
        ])
        UIAccessibility.post(notification: .announcement, argument: text)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak label] in
            UIView.animate(withDuration: 0.25, animations: { label?.alpha = 0 }, completion: { _ in label?.removeFromSuperview() })
        }
    }

    /// The text of the toast shown in `view`, or nil.
    static func toastText(in view: UIView) -> String? {
        (view.viewWithTag(toastTag) as? UILabel)?.text
    }

    private static let toastTag = 0x7A57

    /// A filled button, as the samples' buttons.
    /// A filled button, as the samples' buttons: a localized `title` (also its label, read by VoiceOver and spoken
    /// for Voice Control), a stable `identifier`, a title that grows with Dynamic Type and wraps.
    static func button(_ title: String, identifier: String, color: UIColor, action: @escaping () -> Void) -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = title
        configuration.titleLineBreakMode = .byWordWrapping
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = UIFont.preferredFont(forTextStyle: .body)
            return attributes
        }
        configuration.baseBackgroundColor = color
        configuration.baseForegroundColor = .white
        configuration.cornerStyle = .small
        let button = UIButton(configuration: configuration, primaryAction: UIAction { _ in action() })
        button.accessibilityIdentifier = identifier
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        return button
    }

    /// A text field with a bottom line, as Android's EditText; `label` is what VoiceOver reads (a placeholder
    /// disappears once there is text).
    static func textField(placeholder: String, label: String) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.accessibilityLabel = label
        field.font = .preferredFont(forTextStyle: .body)
        field.adjustsFontForContentSizeCategory = true
        field.borderStyle = .none
        field.returnKeyType = .done
        let line = UIView()
        line.backgroundColor = .systemTeal
        line.translatesAutoresizingMaskIntoConstraints = false
        field.addSubview(line)
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: field.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: field.trailingAnchor),
            line.bottomAnchor.constraint(equalTo: field.bottomAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
            field.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
        ])
        return field
    }

    /// A picture of the TagViewGroup sample: a gradient and a large symbol, `index` choosing the colors and the symbol.
    static func picture(_ index: Int, size: CGSize = CGSize(width: 750, height: 750)) -> UIImage {
        let palettes: [(UIColor, UIColor, String, String)] = [
            (UIColor(red: 0.55, green: 0.42, blue: 0.33, alpha: 1), UIColor(red: 0.85, green: 0.76, blue: 0.66, alpha: 1), "shoeprints.fill", "鞋子图片"),
            (UIColor(red: 0.25, green: 0.35, blue: 0.5, alpha: 1), UIColor(red: 0.7, green: 0.8, blue: 0.9, alpha: 1), "handbag.fill", "包图片"),
            (UIColor(red: 0.3, green: 0.45, blue: 0.35, alpha: 1), UIColor(red: 0.78, green: 0.88, blue: 0.75, alpha: 1), "tshirt.fill", "衣服图片"),
        ]
        let (dark, light, symbol, labelKey) = palettes[index % palettes.count]
        let image = UIGraphicsImageRenderer(size: size).image { context in
            let colors = [light.cgColor, dark.cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil) {
                context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            }
            let configuration = UIImage.SymbolConfiguration(pointSize: size.width * 0.42, weight: .regular)
            if let image = UIImage(systemName: symbol, withConfiguration: configuration)?.withTintColor(UIColor(white: 1, alpha: 0.55), renderingMode: .alwaysOriginal) {
                image.draw(at: CGPoint(x: (size.width - image.size.width) / 2, y: (size.height - image.size.height) / 2))
            }
        }
        // CYLImageTagView reads it as the picture's label.
        image.accessibilityLabel = CYLExampleLocalizedString(labelKey)
        return image
    }
}

/// A label with padding (the toast).
final class CYLPaddedLabel: UILabel {
    var insets = UIEdgeInsets(top: 9, left: 18, bottom: 9, right: 18)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }
}
