//
//  HUDView.swift
//  QBlocker
//
//  Created by Stephen Radford on 03/05/2016.
//  Modernized without storyboard dependencies.
//

import AppKit
import QuartzCore

final class HUDView: NSView {
    private let titleLabel = NSTextField(labelWithString: "Hold ⌘ Q to Quit")
    private let backgroundLayer = CALayer()
    private let progressTrack = CALayer()
    private let progressFill = CALayer()
    private var progress: CGFloat = 0

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.masksToBounds = true

        backgroundLayer.backgroundColor = NSColor.black.cgColor
        backgroundLayer.masksToBounds = true
        layer?.addSublayer(backgroundLayer)

        progressTrack.backgroundColor = NSColor.clear.cgColor
        progressTrack.masksToBounds = true
        progressFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressFill.backgroundColor = accentColor
        progressFill.masksToBounds = true
        layer?.addSublayer(progressTrack)
        progressTrack.addSublayer(progressFill)

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.alignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 28),
            trailingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 28)
        ])
    }

    override func layout() {
        super.layout()

        let barHeight: CGFloat = 3
        let barFrame = CGRect(x: 0, y: 0, width: bounds.width, height: barHeight)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer?.cornerRadius = bounds.height / 2
        backgroundLayer.cornerRadius = bounds.height / 2
        backgroundLayer.frame = bounds
        progressTrack.cornerRadius = barHeight / 2
        progressTrack.frame = barFrame
        progressFill.cornerRadius = barHeight / 2
        progressFill.backgroundColor = accentColor
        progressFill.position = CGPoint(x: 0, y: barHeight / 2)
        progressFill.bounds = CGRect(x: 0, y: 0, width: bounds.width * progress, height: barHeight)
        CATransaction.commit()
    }

    func startProgress(duration: TimeInterval?) {
        progressFill.removeAnimation(forKey: "holdProgress")

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progress = 0
        needsLayout = true
        layoutSubtreeIfNeeded()
        CATransaction.commit()

        guard let duration, duration > 0 else {
            return
        }

        progress = 1
        progressFill.bounds.size.width = bounds.width

        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.fromValue = 0
        animation.toValue = bounds.width
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressFill.add(animation, forKey: "holdProgress")
    }

    func stopProgress(reset: Bool) {
        if !reset, bounds.width > 0 {
            let currentWidth = progressFill.presentation()?.bounds.width ?? progressFill.bounds.width
            progress = min(max(currentWidth / bounds.width, 0), 1)
        }

        progressFill.removeAnimation(forKey: "holdProgress")

        if reset {
            progress = 0
        }

        needsLayout = true
        layoutSubtreeIfNeeded()
    }

    private var accentColor: CGColor {
        NSColor.controlAccentColor.cgColor
    }

    var capsuleLayer: CALayer {
        backgroundLayer
    }
}
