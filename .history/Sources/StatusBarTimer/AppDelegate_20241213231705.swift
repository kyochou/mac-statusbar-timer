import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var startTime: Date?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("应用启动") // 调试输出
        
        // 确保在主线程上运行
        DispatchQueue.main.async { [weak self] in
            self?.setupStatusBar()
            self?.setupScreenLockNotification()
            self?.startTimer()
        }
    }
    
    private func setupStatusBar() {
        print("设置状态栏") // 调试输出
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "00:00"
        }
        
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
        print("启动计时器") // 调试输出
        startTime = Date()
        
        // 使用 RunLoop 的主线程模式
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateTime()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func updateTime() {
        guard let startTime = startTime else { return }
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        
        if let button = statusItem.button {
            button.title = String(format: "%02d:%02d", minutes, seconds)
            print("更新时间: \(button.title)") // 调试输出
        }
    }
    
    @objc private func screenDidSleep() {
        startTime = Date()
        updateTime()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}