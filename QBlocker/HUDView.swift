//
//  HUDView.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

import AppKit
import QuartzCore
import SwiftUI

final class HUDView: NSView {
    private let materialView = NSVisualEffectView()
    private let titleLabel = NSTextField(labelWithString: "Keep holding ⌘Q")
    private let backgroundLayer = CALayer()
    private let progressTrack = CAShapeLayer()
    private let progressFill = CAShapeLayer()
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

        materialView.material = .hudWindow
        materialView.blendingMode = .withinWindow
        materialView.state = .active
        materialView.translatesAutoresizingMaskIntoConstraints = false
        materialView.wantsLayer = true
        addSubview(materialView)

        backgroundLayer.backgroundColor = NSColor.black.withAlphaComponent(0.38).cgColor
        backgroundLayer.masksToBounds = true
        backgroundLayer.zPosition = 0
        layer?.addSublayer(backgroundLayer)

        progressTrack.fillColor = nil
        progressTrack.lineCap = .round
        progressTrack.lineJoin = .round
        progressTrack.strokeColor = NSColor.labelColor.withAlphaComponent(0.18).cgColor
        progressTrack.zPosition = 20
        layer?.addSublayer(progressTrack)

        progressFill.fillColor = nil
        progressFill.lineCap = .round
        progressFill.lineJoin = .round
        progressFill.strokeColor = accentColor
        progressFill.strokeStart = 0
        progressFill.strokeEnd = 0
        progressFill.zPosition = 21
        layer?.addSublayer(progressFill)

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.alignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            materialView.leadingAnchor.constraint(equalTo: leadingAnchor),
            materialView.trailingAnchor.constraint(equalTo: trailingAnchor),
            materialView.topAnchor.constraint(equalTo: topAnchor),
            materialView.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -1),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 18),
            trailingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 18)
        ])
    }

    override func layout() {
        super.layout()

        let borderWidth: CGFloat = 3
        let borderRect = bounds.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
        let borderPath = progressBorderPath(in: borderRect)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer?.cornerRadius = bounds.height / 2
        materialView.layer?.cornerRadius = bounds.height / 2
        materialView.layer?.masksToBounds = true
        backgroundLayer.cornerRadius = bounds.height / 2
        backgroundLayer.frame = bounds
        progressTrack.frame = bounds
        progressTrack.lineWidth = borderWidth
        progressTrack.path = borderPath
        progressFill.frame = bounds
        progressFill.lineWidth = borderWidth
        progressFill.path = borderPath
        progressFill.strokeColor = accentColor
        progressFill.strokeEnd = progress
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
        progressFill.strokeEnd = 1

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        progressFill.add(animation, forKey: "holdProgress")
    }

    func stopProgress(reset: Bool) {
        if !reset {
            let currentStrokeEnd = progressFill.presentation()?.strokeEnd ?? progressFill.strokeEnd
            progress = min(max(currentStrokeEnd, 0), 1)
        }

        progressFill.removeAnimation(forKey: "holdProgress")

        if reset {
            progress = 0
        }

        needsLayout = true
        layoutSubtreeIfNeeded()
    }

    private func progressBorderPath(in rect: CGRect) -> CGPath {
        let radius = min(rect.width, rect.height) / 2
        let minX = rect.minX
        let maxX = rect.maxX
        let minY = rect.minY
        let maxY = rect.maxY
        let midX = rect.midX

        let path = CGMutablePath()
        path.move(to: CGPoint(x: midX, y: maxY))
        path.addLine(to: CGPoint(x: maxX - radius, y: maxY))
        path.addArc(
            center: CGPoint(x: maxX - radius, y: maxY - radius),
            radius: radius,
            startAngle: .pi / 2,
            endAngle: 0,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: maxX, y: minY + radius))
        path.addArc(
            center: CGPoint(x: maxX - radius, y: minY + radius),
            radius: radius,
            startAngle: 0,
            endAngle: -.pi / 2,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: minX + radius, y: minY))
        path.addArc(
            center: CGPoint(x: minX + radius, y: minY + radius),
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: -.pi,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: minX, y: maxY - radius))
        path.addArc(
            center: CGPoint(x: minX + radius, y: maxY - radius),
            radius: radius,
            startAngle: .pi,
            endAngle: .pi / 2,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: midX, y: maxY))
        return path
    }

    private var accentColor: CGColor {
        NSColor.controlAccentColor.cgColor
    }

    var capsuleLayer: CALayer {
        backgroundLayer
    }
}

private struct HUDViewPreview: NSViewRepresentable {
    func makeNSView(context: Context) -> HUDView {
        let view = HUDView(frame: NSRect(x: 0, y: 0, width: 198, height: 46))
        view.startProgress(duration: 4)
        return view
    }

    func updateNSView(_ nsView: HUDView, context: Context) {}
}

#Preview {
    HUDViewPreview()
        .frame(width: 198, height: 46)
        .padding(40)
}
