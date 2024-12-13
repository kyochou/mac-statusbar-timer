import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var startTime: Date?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBar()
        setupScreenLockNotification()
        startTimer()
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "00:00"
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    private func setupScreenLockNotification() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(screenDidSleep),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )
    }
    
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
    }
    
    private func updateTime() {
        guard let startTime = startTime else { return }
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        statusItem.button?.title = String(format: "%02d:%02d", minutes, seconds)
    }
    
    @objc private func screenDidSleep() {
        startTime = Date()
        updateTime()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}