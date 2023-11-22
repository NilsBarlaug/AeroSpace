class GlobalObserver {
    @objc private static func action() {
        refresh()
    }

    static func initObserver() {
        subscribe(NSWorkspace.didLaunchApplicationNotification)
        subscribe(NSWorkspace.didActivateApplicationNotification)
        subscribe(NSWorkspace.didHideApplicationNotification)
        subscribe(NSWorkspace.didUnhideApplicationNotification)
        subscribe(NSWorkspace.didDeactivateApplicationNotification)
        subscribe(NSWorkspace.activeSpaceDidChangeNotification)
        subscribe(NSWorkspace.didTerminateApplicationNotification)

        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { event in
            resetManipulatedWithMouseIfPossible()
            // Detect clicks on desktop of different monitors
            let focusedMonitor = mouseLocation.monitorApproximation
            if monitors.count > 1 &&
                   getNativeFocusedWindow(startup: false) == nil &&
                   focusedMonitor.rect.topLeftCorner != Workspace.focused.monitor.rect.topLeftCorner {
                setFocusSourceOfTruth(.ownModel, startup: false)
                focusedWorkspaceName = focusedMonitor.activeWorkspace.name
                refresh()
            }
        }
    }

    private static func subscribe(_ name: NSNotification.Name) {
        NSWorkspace.shared.notificationCenter.addObserver(
                self,
                selector: #selector(action),
                name: name,
                object: nil
        )
    }
}
