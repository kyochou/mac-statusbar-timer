PRODUCT_NAME = StatusBarTimer
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
APP_DIR = $(PRODUCT_NAME).app
INSTALL_DIR = /Applications

.PHONY: all clean build install uninstall

all: build

# 编译项目
build:
	swift build -c release
	@echo "Build complete: $(RELEASE_DIR)/$(PRODUCT_NAME)"

# 创建 .app 包
app: build
	@mkdir -p $(APP_DIR)/Contents/MacOS
	@cp $(RELEASE_DIR)/$(PRODUCT_NAME) $(APP_DIR)/Contents/MacOS/
	@echo '<?xml version="1.0" encoding="UTF-8"?>\
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\
	<plist version="1.0">\
	<dict>\
		<key>CFBundleExecutable</key>\
		<string>$(PRODUCT_NAME)</string>\
		<key>CFBundleIdentifier</key>\
		<string>com.example.$(PRODUCT_NAME)</string>\
		<key>CFBundleName</key>\
		<string>$(PRODUCT_NAME)</string>\
		<key>CFBundlePackageType</key>\
		<string>APPL</string>\
		<key>CFBundleShortVersionString</key>\
		<string>1.0</string>\
		<key>LSMinimumSystemVersion</key>\
		<string>12.0</string>\
		<key>LSUIElement</key>\
		<true/>\
	</dict>\
	</plist>' > $(APP_DIR)/Contents/Info.plist

# 安装到应用程序目录
install: app
	@if [ -d "$(INSTALL_DIR)/$(APP_DIR)" ]; then\
		rm -rf "$(INSTALL_DIR)/$(APP_DIR)";\
	fi
	@cp -R $(APP_DIR) $(INSTALL_DIR)/
	@echo "Installed to $(INSTALL_DIR)/$(APP_DIR)"

# 卸载应用
uninstall:
	@if [ -d "$(INSTALL_DIR)/$(APP_DIR)" ]; then\
		rm -rf "$(INSTALL_DIR)/$(APP_DIR)";\
		echo "Uninstalled $(PRODUCT_NAME)";\
	else\
		echo "$(PRODUCT_NAME) is not installed";\
	fi

# 清理构建文件
clean:
	rm -rf $(BUILD_DIR) $(APP_DIR)
	swift package clean

# 运行开发版本
run:
	swift run

# 运行发布版本
run-release: build
	$(RELEASE_DIR)/$(PRODUCT_NAME) 