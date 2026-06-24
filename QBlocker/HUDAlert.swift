//
//  HUDAlert.swift
//  QBlocker
//
//  Created by Stephen Radford on 03/05/2016.
//  Modernized without storyboard dependencies.
//

import AppKit
import CoreImage
import QuartzCore

final class HUDAlert: @unchecked Sendable {
    static let shared = HUDAlert()

    private static let blurFilterName = "presentationBlur"

    private let windowSize = NSSize(width: 300, height: 60)
    private let topGap: CGFloat = 16
    private let offscreenPadding: CGFloat = 16
    @MainActor private var presentationID = 0

    @MainActor
    private lazy var panel: NSPanel = {
        let contentSize = NSSize(
            width: windowSize.width,
            height: windowSize.height + topGap
        )
        let panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.assistiveTechHighWindow)))
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .canJoinAllApplications,
            .transient,
            .ignoresCycle
        ]
        panel.isFloatingPanel = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true
        panel.isReleasedWhenClosed = false
        panel.becomesKeyOnlyIfNeeded = false

        let contentView = HUDContainerView(hudSize: windowSize)
        contentView.autoresizingMask = [.width, .height]
        panel.contentView = contentView
        return panel
    }()

    private init() {}

    func prepare() {
        performOnMainSync { @MainActor in
            self.prepareOnMain()
        }
    }

    func showHUD(holdDuration: TimeInterval? = nil) {
        performOnMainSync { @MainActor in
            self.showHUDOnMain(holdDuration: holdDuration)
        }
    }

    @MainActor
    private func prepareOnMain() {
        _ = panel
    }

    @MainActor
    private func showHUDOnMain(holdDuration: TimeInterval?) {
        guard let screen = targetScreen() else {
            return
        }

        presentationID += 1
        let currentPresentationID = presentationID

        let frames = hudFrames(on: screen)
        let contentView = panel.contentView as? HUDContainerView
        let hudView = contentView?.hudView

        hudView?.stopProgress(reset: true)
        contentView?.alphaValue = 0
        contentView?.prepareForEntrance(offscreenPadding: offscreenPadding)
        setBlur(on: hudView?.capsuleLayer, radius: 12)

        panel.setFrame(frames.shown, display: false)
        panel.orderFrontRegardless()
        panel.displayIfNeeded()
        hudView?.startProgress(duration: holdDuration)

        let duration = 0.36
        contentView?.animateEntrance(duration: duration)
        animateBlur(on: hudView?.capsuleLayer, from: 12, to: 0, duration: duration, timingFunctionName: .easeOut)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            contentView?.animator().alphaValue = 1
        } completionHandler: {
            Task { @MainActor in
                guard self.presentationID == currentPresentationID else {
                    return
                }

                self.setBlur(on: hudView?.capsuleLayer, radius: 0)
            }
        }
    }

    @MainActor
    private func targetScreen() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { screen in
            NSMouseInRect(mouseLocation, screen.frame, false)
        } ?? NSScreen.main ?? NSScreen.screens.first
    }

    func dismissHUD(fade: Bool = true) {
        performOnMainSync { @MainActor in
            self.dismissHUDOnMain(fade: fade)
        }
    }

    @MainActor
    private func dismissHUDOnMain(fade: Bool) {
        presentationID += 1
        let currentPresentationID = presentationID

        guard fade else {
            (panel.contentView as? HUDContainerView)?.hudView.stopProgress(reset: true)
            panel.orderOut(nil)
            return
        }

        guard panel.isVisible else {
            return
        }

        let contentView = panel.contentView as? HUDContainerView
        let hudView = contentView?.hudView

        hudView?.stopProgress(reset: false)

        let duration = 0.24
        contentView?.animateExit(duration: duration, offscreenPadding: offscreenPadding)
        animateBlur(on: hudView?.capsuleLayer, from: 0, to: 9, duration: duration, timingFunctionName: .easeIn)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            contentView?.animator().alphaValue = 0
        } completionHandler: {
            Task { @MainActor in
                guard self.presentationID == currentPresentationID else {
                    return
                }

                self.panel.orderOut(nil)
                hudView?.stopProgress(reset: true)
                contentView?.alphaValue = 1
                hudView?.layer?.transform = CATransform3DIdentity
                self.setBlur(on: hudView?.capsuleLayer, radius: 0)
            }
        }
    }

    @MainActor
    private func hudFrames(on screen: NSScreen) -> (shown: NSRect, hidden: NSRect) {
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        let contentHeight = windowSize.height + topGap
        let shownFrame = NSRect(
            x: screenFrame.midX - (windowSize.width / 2),
            y: visibleFrame.maxY - contentHeight,
            width: windowSize.width,
            height: contentHeight
        )
        let hiddenFrame = NSRect(
            x: shownFrame.minX,
            y: screenFrame.maxY + 12,
            width: shownFrame.width,
            height: shownFrame.height
        )

        return (shownFrame, hiddenFrame)
    }

    @MainActor
    private func animateLayerTransform(
        on view: NSView?,
        from startTransform: CATransform3D,
        to endTransform: CATransform3D,
        duration: TimeInterval,
        timingFunctionName: CAMediaTimingFunctionName
    ) {
        guard let layer = view?.layer else {
            return
        }

        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = startTransform
        animation.toValue = endTransform
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: timingFunctionName)

        layer.transform = endTransform
        layer.add(animation, forKey: "hudTransform")
    }

    @MainActor
    private func setBlur(on layer: CALayer?, radius: Double) {
        guard
            let layer,
            radius > 0,
            let filter = CIFilter(name: "CIGaussianBlur")
        else {
            layer?.filters = nil
            return
        }

        filter.name = Self.blurFilterName
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        layer.filters = [filter]
    }

    @MainActor
    private func animateBlur(
        on layer: CALayer?,
        from startRadius: Double,
        to endRadius: Double,
        duration: TimeInterval,
        timingFunctionName: CAMediaTimingFunctionName
    ) {
        guard let layer else {
            return
        }

        setBlur(on: layer, radius: startRadius)

        let animation = CABasicAnimation(keyPath: "filters.\(Self.blurFilterName).inputRadius")
        animation.fromValue = startRadius
        animation.toValue = endRadius
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: timingFunctionName)

        layer.add(animation, forKey: Self.blurFilterName)

        if endRadius <= 0 {
            return
        }

        (layer.filters?.first as? CIFilter)?.setValue(endRadius, forKey: kCIInputRadiusKey)
    }

    private func performOnMainSync(_ work: @MainActor @escaping () -> Void) {
        if Thread.isMainThread {
            MainActor.assumeIsolated {
                work()
            }
        } else {
            DispatchQueue.main.sync {
                MainActor.assumeIsolated {
                    work()
                }
            }
        }
    }
}

private final class HUDContainerView: NSView {
    let hudView: HUDView
    private let hudSize: NSSize

    init(hudSize: NSSize) {
        self.hudSize = hudSize
        hudView = HUDView(frame: NSRect(origin: .zero, size: hudSize))
        super.init(frame: NSRect(origin: .zero, size: hudSize))
        configure()
    }

    required init?(coder: NSCoder) {
        return nil
    }

    private func configure() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.masksToBounds = true

        hudView.autoresizingMask = []
        addSubview(hudView)
    }

    override func layout() {
        super.layout()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        hudView.frame = NSRect(origin: hudView.frame.origin, size: hudSize)
        CATransaction.commit()
    }

    @MainActor
    func prepareForEntrance(offscreenPadding: CGFloat) {
        guard let layer = hudView.layer else {
            hudView.frame.origin = .zero
            return
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        hudView.frame = NSRect(origin: .zero, size: hudSize)
        layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.position = hiddenLayerPosition(offscreenPadding: offscreenPadding)
        layer.transform = startTransform
        layer.opacity = 0
        CATransaction.commit()
    }

    @MainActor
    func animateEntrance(duration: TimeInterval) {
        guard let layer = hudView.layer else {
            hudView.animator().frame.origin = .zero
            return
        }

        let positionAnimation = CABasicAnimation(keyPath: "position")
        positionAnimation.fromValue = layer.position
        positionAnimation.toValue = finalLayerPosition
        positionAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.fromValue = startTransform
        transformAnimation.toValue = CATransform3DIdentity
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0
        opacityAnimation.toValue = 1
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)

        let group = CAAnimationGroup()
        group.animations = [positionAnimation, transformAnimation, opacityAnimation]
        group.duration = duration

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.position = finalLayerPosition
        layer.transform = CATransform3DIdentity
        layer.opacity = 1
        CATransaction.commit()

        layer.add(group, forKey: "hudEntrance")
    }

    @MainActor
    func animateExit(duration: TimeInterval, offscreenPadding: CGFloat) {
        guard let layer = hudView.layer else {
            return
        }

        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = layer.position
        animation.toValue = hiddenLayerPosition(offscreenPadding: offscreenPadding)
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)

        let transformAnimation = CABasicAnimation(keyPath: "transform")
        transformAnimation.fromValue = CATransform3DIdentity
        transformAnimation.toValue = CATransform3DMakeScale(0.72, 0.82, 1)
        transformAnimation.duration = duration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.position = hiddenLayerPosition(offscreenPadding: offscreenPadding)
        layer.transform = CATransform3DMakeScale(0.72, 0.82, 1)
        CATransaction.commit()

        layer.add(animation, forKey: "hudExitPosition")
        layer.add(transformAnimation, forKey: "hudExitTransform")
    }

    private var finalLayerPosition: CGPoint {
        CGPoint(x: hudSize.width / 2, y: hudSize.height / 2)
    }

    private func hiddenLayerPosition(offscreenPadding: CGFloat) -> CGPoint {
        CGPoint(
            x: hudSize.width / 2,
            y: bounds.height + (hudSize.height / 2) + offscreenPadding
        )
    }

    private var startTransform: CATransform3D {
        CATransform3DMakeScale(50 / hudSize.width, 0.72, 1)
    }

}
