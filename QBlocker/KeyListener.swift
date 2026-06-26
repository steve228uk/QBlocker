//
//  KeyListener.swift
//  QBlocker
//
//  Copyright © 2026 Churro Studio. All rights reserved.
//

@preconcurrency import AppKit
@preconcurrency import ApplicationServices

private func keyDownCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else {
        return Unmanaged.passUnretained(event)
    }

    let listener = Unmanaged<KeyListener>.fromOpaque(userInfo).takeUnretainedValue()
    return MainActor.assumeIsolated {
        listener.handleKeyDown(type: type, event: event)
    }
}

private func keyUpCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    userInfo: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    guard let userInfo else {
        return Unmanaged.passUnretained(event)
    }

    let listener = Unmanaged<KeyListener>.fromOpaque(userInfo).takeUnretainedValue()
    return MainActor.assumeIsolated {
        listener.handleKeyUp(type: type, event: event)
    }
}

@MainActor
final class KeyListener: ObservableObject {
    static let shared = KeyListener()

    private enum CommandQState {
        case idle
        case holding(processIdentifier: pid_t, keyCode: CGKeyCode, workItem: CancelableDelay)
        case quitForwarded
    }

    @Published private(set) var isRunning = false
    @Published private(set) var lastError: String?

    private weak var settings: AppSettings?
    private var keyDownTap: CFMachPort?
    private var keyDownRunLoopSource: CFRunLoopSource?
    private var keyUpTap: CFMachPort?
    private var keyUpRunLoopSource: CFRunLoopSource?
    private var commandQState = CommandQState.idle

    private init() {}

    func configure(settings: AppSettings) {
        preconditionMainThread()
        self.settings = settings
    }

    func start() throws {
        preconditionMainThread()

        guard AccessibilityPermission.isTrusted else {
            lastError = KeyListenerError.accessibilityPermissionDenied.localizedDescription
            throw KeyListenerError.accessibilityPermissionDenied
        }

        stop()

        let userInfo = Unmanaged.passUnretained(self).toOpaque()

        keyDownTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.keyDown.rawValue),
            callback: keyDownCallback,
            userInfo: userInfo
        )

        keyUpTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(
                (1 << CGEventType.keyUp.rawValue) |
                (1 << CGEventType.flagsChanged.rawValue)
            ),
            callback: keyUpCallback,
            userInfo: userInfo
        )

        guard let keyDownTap, let keyUpTap else {
            stop()
            lastError = KeyListenerError.couldNotCreateEventTap.localizedDescription
            throw KeyListenerError.couldNotCreateEventTap
        }

        keyDownRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyDownTap, 0)
        keyUpRunLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, keyUpTap, 0)

        if let keyDownRunLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), keyDownRunLoopSource, .commonModes)
        }

        if let keyUpRunLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), keyUpRunLoopSource, .commonModes)
        }

        CGEvent.tapEnable(tap: keyDownTap, enable: true)
        CGEvent.tapEnable(tap: keyUpTap, enable: true)
        isRunning = true
        lastError = nil
    }

    func stop() {
        preconditionMainThread()
        cancelCommandQHold(logAccidentalQuit: false)

        if let keyDownRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), keyDownRunLoopSource, .commonModes)
        }

        if let keyUpRunLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), keyUpRunLoopSource, .commonModes)
        }

        keyDownRunLoopSource = nil
        keyUpRunLoopSource = nil
        keyDownTap = nil
        keyUpTap = nil
        isRunning = false
    }

    func restartIfPossible() {
        preconditionMainThread()

        guard AccessibilityPermission.isTrusted else {
            stop()
            return
        }

        try? start()
    }

    fileprivate func handleKeyDown(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        preconditionMainThread()

        if handleDisabledEventTap(type: type) {
            return nil
        }

        guard type == .keyDown else {
            return Unmanaged.passUnretained(event)
        }

        guard isCommandQ(event), !isShiftModified(event) else {
            return Unmanaged.passUnretained(event)
        }

        if case .quitForwarded = commandQState {
            return Unmanaged.passUnretained(event)
        }

        guard case .idle = commandQState else {
            return nil
        }

        guard let app = NSWorkspace.shared.menuBarOwningApplication else {
            return Unmanaged.passUnretained(event)
        }

        guard shouldProtect(app) else {
            return Unmanaged.passUnretained(event)
        }

        beginCommandQHold(for: app, event: event)

        return nil
    }

    fileprivate func handleKeyUp(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        preconditionMainThread()

        if handleDisabledEventTap(type: type) {
            return nil
        }

        if type == .flagsChanged {
            if !event.flags.contains(.maskCommand) {
                switch commandQState {
                case .holding:
                    cancelCommandQHold(logAccidentalQuit: true)
                case .quitForwarded:
                    commandQState = .idle
                case .idle:
                    break
                }
            }

            return Unmanaged.passUnretained(event)
        }

        guard type == .keyUp else {
            return Unmanaged.passUnretained(event)
        }

        guard !isShiftModified(event) else {
            return Unmanaged.passUnretained(event)
        }

        switch commandQState {
        case let .holding(_, heldKeyCode, _) where eventKeyCode(event) == heldKeyCode:
            cancelCommandQHold(logAccidentalQuit: true)
            return nil
        case .quitForwarded:
            guard isQKey(event) else {
                return Unmanaged.passUnretained(event)
            }

            commandQState = .idle
            return Unmanaged.passUnretained(event)
        case .holding, .idle:
            return Unmanaged.passUnretained(event)
        }
    }

    private func isCommandQ(_ event: CGEvent) -> Bool {
        event.flags.contains(.maskCommand)
            && isQKey(event)
    }

    private func isQKey(_ event: CGEvent) -> Bool {
        if let keyValue = keyValue(for: event), !keyValue.isEmpty {
            return keyValue.lowercased() == "q"
        }

        return eventKeyCode(event) == 12
    }

    private func eventKeyCode(_ event: CGEvent) -> CGKeyCode {
        CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
    }

    private func isShiftModified(_ event: CGEvent) -> Bool {
        event.flags.contains(.maskShift)
    }

    private func keyValue(for event: CGEvent) -> String? {
        NSEvent(cgEvent: event)?.charactersIgnoringModifiers
    }

    private func shouldProtect(_ app: NSRunningApplication) -> Bool {
        guard
            let bundleIdentifier = app.bundleIdentifier,
            let settings
        else {
            return true
        }

        return settings.listMode.shouldProtect(
            bundleIdentifier: bundleIdentifier,
            listedBundleIdentifiers: settings.listedBundleIdentifiers
        )
    }

    private func beginCommandQHold(for app: NSRunningApplication, event: CGEvent) {
        let processIdentifier = app.processIdentifier
        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

        NSLog("QBlocker: starting Cmd-Q hold for pid \(processIdentifier)")
        HUDPresenter.shared.showHUD(holdDuration: holdDuration)

        let workItem = delay(holdDuration) { [weak self] in
            self?.forwardCommandQ(to: processIdentifier)
        }

        commandQState = .holding(processIdentifier: processIdentifier, keyCode: keyCode, workItem: workItem)
    }

    private var holdDuration: TimeInterval {
        TimeInterval(max(1, settings?.delayPresses ?? 4))
    }

    private func cancelCommandQHold(logAccidentalQuit: Bool) {
        guard case let .holding(_, _, workItem) = commandQState else {
            return
        }

        NSLog("QBlocker: cancelling Cmd-Q hold")
        cancelDelay(workItem)
        commandQState = .idle
        HUDPresenter.shared.dismissHUD()

        if logAccidentalQuit {
            settings?.logAccidentalQuit()
        }
    }

    private func forwardCommandQ(to processIdentifier: pid_t) {
        guard
            case let .holding(heldProcessIdentifier, heldKeyCode, _) = commandQState,
            heldProcessIdentifier == processIdentifier,
              NSRunningApplication(processIdentifier: processIdentifier) != nil
        else {
            return
        }

        HUDPresenter.shared.dismissHUD()
        commandQState = .quitForwarded

        if postSyntheticCommandQ(keyCode: heldKeyCode) {
            NSLog("QBlocker: forwarded Cmd-Q via synthetic keyboard event for pid \(processIdentifier)")
            return
        }

        NSLog("QBlocker: failed to forward Cmd-Q for pid \(processIdentifier)")
        commandQState = .idle
    }

    private func postSyntheticCommandQ(keyCode: CGKeyCode) -> Bool {
        guard
            let source = CGEventSource(stateID: .hidSystemState),
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        else {
            return false
        }

        keyDown.flags = .maskCommand
        keyUp.flags = .maskCommand

        setEventTapsEnabled(false)
        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)

        delay(0.05) { [weak self] in
            self?.finishSyntheticCommandQForwarding()
        }

        return true
    }

    private func finishSyntheticCommandQForwarding() {
        setEventTapsEnabled(true)
        resetQuitForwardedStateIfNeeded()
    }

    private func resetQuitForwardedStateIfNeeded() {
        guard case .quitForwarded = commandQState else {
            return
        }

        commandQState = .idle
    }

    private func setEventTapsEnabled(_ enabled: Bool) {
        if let keyDownTap {
            CGEvent.tapEnable(tap: keyDownTap, enable: enabled)
        }

        if let keyUpTap {
            CGEvent.tapEnable(tap: keyUpTap, enable: enabled)
        }
    }

    private func handleDisabledEventTap(type: CGEventType) -> Bool {
        guard type == .tapDisabledByTimeout || type == .tapDisabledByUserInput else {
            return false
        }

        NSLog("QBlocker: event tap disabled by macOS; re-enabling")
        setEventTapsEnabled(true)
        isRunning = keyDownTap != nil && keyUpTap != nil
        lastError = nil
        return true
    }

    private func preconditionMainThread() {
        precondition(Thread.isMainThread, "KeyListener must be used from the main thread")
    }
}
