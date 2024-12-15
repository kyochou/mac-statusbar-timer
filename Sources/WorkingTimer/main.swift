import AppKit

autoreleasepool {
    // 创建应用实例
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate

    // 设置为代理
    NSApp.setActivationPolicy(.accessory)

    // 运行应用
    app.run()
}
