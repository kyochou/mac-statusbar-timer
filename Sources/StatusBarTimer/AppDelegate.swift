import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var startTime: Date?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.setupStatusBar()
            self?.setupScreenLockNotification()
            self?.startTimer()
        }
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.labelColor
            ]
            button.attributedTitle = NSAttributedString(
                string: "working[00:00]",
                attributes: attributes
            )
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    private func setupScreenLockNotification() {
        let workspace = NSWorkspace.shared
        let notificationCenter = workspace.notificationCenter
        
        notificationCenter.addObserver(
            self,
            selector: #selector(resetTimer),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(resetTimer),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(resetTimer),
            name: NSWorkspace.sessionDidResignActiveNotification,
            object: nil
        )
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(resetTimer),
            name: NSNotification.Name("com.apple.screenIsLocked"),
            object: nil
        )
        
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(resetTimer),
            name: NSNotification.Name("com.apple.screenIsUnlocked"),
            object: nil
        )
    }
    
    @objc private func resetTimer(_ notification: Notification) {
        startTime = Date()
        updateTime()
    }
    
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateTime()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func updateTime() {
        guard let startTime = startTime else { return }
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let hours = elapsed / 3600
        let minutes = (elapsed % 3600) / 60
        
        if let button = statusItem.button {
            let timeString = String(format: "working[%02d:%02d]", hours, minutes)
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: hours >= 1 ? NSColor.systemRed : NSColor.labelColor
            ]
            button.attributedTitle = NSAttributedString(
                string: timeString,
                attributes: attributes
            )
        }
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}