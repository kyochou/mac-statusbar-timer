import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var startTime: Date?
    private var hasAlerted = false
    private var currentAlert: NSAlert?
    
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
                string: "[00:00]",
                attributes: attributes
            )
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "重新计时", action: #selector(resetTimerManually), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
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
    
    @objc private func resetTimer(_ notification: Notification?) {
        dismissAlertIfNeeded()
        startTime = Date()
        hasAlerted = false
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
            let timeString = String(format: "[%02d:%02d]", hours, minutes)
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: hours >= 1 ? NSColor.systemRed : NSColor.labelColor
            ]
            button.attributedTitle = NSAttributedString(
                string: timeString,
                attributes: attributes
            )
        }

        // 超过1小时时弹窗提醒（每次计时周期仅一次）
        if hours >= 1 && !hasAlerted {
            hasAlerted = true
            showAlert(hours: hours, minutes: minutes)
        }
    }

    private func showAlert(hours: Int, minutes: Int) {
        let alert = NSAlert()
        alert.messageText = "⏰ 该休息了！"
        alert.informativeText = "你已经连续工作了 \(hours) 小时 \(minutes) 分钟，起来活动一下吧！"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "好的")
        alert.addButton(withTitle: "重新计时")
        currentAlert = alert
        let response = alert.runModal()
        currentAlert = nil
        if response == .alertSecondButtonReturn {
            resetTimerManually()
        }
    }

    private func dismissAlertIfNeeded() {
        guard let alert = currentAlert else { return }
        currentAlert = nil
        NSApp.abortModal()
        alert.window.close()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc private func resetTimerManually() {
        dismissAlertIfNeeded()
        startTime = Date()
        hasAlerted = false
        updateTime()
    }
}