# Ring Slint iOS Guide

Build iOS applications with Ring Slint.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Building for iOS](#building-for-ios)
- [Project Structure](#project-structure)
- [Asset Management](#asset-management)
- [Platform Differences](#platform-differences)
- [Deploying](#deploying)
- [Troubleshooting](#troubleshooting)

---

## Overview

Ring Slint supports iOS with the following characteristics:

| Feature | iOS Support |
|---------|-------------|
| **Rendering** | GPU-accelerated via Skia (Metal) |
| **Min iOS** | 14.0 |
| **Architectures** | arm64 (device), arm64-sim (simulator) |

### Platform Limitations

The following desktop features are **not available** on iOS:

- File dialogs (`fileOpen`, `fileSave`, `folderOpen`)
- Message boxes (`msgbox`, `msgboxWarning`, `msgboxError`, `confirm`, `yesno`)
- Desktop notifications (`notify`)
- Clipboard operations (`clipboardGet`, `clipboardSet`, `clipboardClear`)
- Global hotkeys (`hotkeyRegister`)
- System tray (`trayCreate`)
- Window drag (`windowDrag`)
- Always-on-top (`windowSetAlwaysOnTop`)
- Window icon (`windowSetIcon`)

---

## Prerequisites

### Required Tools

1. **macOS** with Xcode installed
   - Xcode Command Line Tools: `sudo xcodebuild -runFirstLaunch`

2. **Rust with iOS targets**
   ```sh
   rustup target add aarch64-apple-ios        # Device
   rustup target add aarch64-apple-ios-sim    # Simulator
   ```

3. **iOS Simulator Runtime** (for simulator testing)
   - Install via Xcode: `Settings → Platforms → iOS Simulator`
   - Or manually: `xcrun simctl runtime add <path-to-runtime.dmg>`

4. **Optional: XcodeGen** (for Xcode project generation)
   ```sh
   brew install xcodegen
   ```

5. **Optional: ios-deploy** (for device installation from terminal)
   ```sh
   brew install ios-deploy
   ```

---

## Building for iOS

The iOS project is located at `ios/` within the Ring Slint repository.

### Terminal (build.sh)

```sh
cd ios/

# Release build for simulator
./build.sh --simulator

# Debug build for simulator
./build.sh --simulator --debug

# Release build for device
./build.sh

# Build and install on device
./build.sh --install

# Build, install, and run on device
./build.sh --run
```

### Xcode (via XcodeGen)

1. Generate the Xcode project:
   ```sh
   cd ios/
   xcodegen generate
   ```

2. Open in Xcode:
   ```sh
   open RingSlint.xcodeproj
   ```

3. Select your target device/simulator and build (⌘B).

### Manual Build Steps

```sh
cd ios/

# 1. Build for simulator
cargo build --release --target aarch64-apple-ios-sim --bin ring-slint-ios

# 2. Create .app bundle
mkdir -p RingSlint.app
cp target/aarch64-apple-ios-sim/release/ring-slint-ios RingSlint.app/
cp Info.plist RingSlint.app/
cp resources/*.ring RingSlint.app/

# 3. Sign
codesign --force --sign - RingSlint.app

# 4. Install on simulator
xcrun simctl install booted RingSlint.app
xcrun simctl launch booted dev.ring.slint.app
```

For device builds, use `aarch64-apple-ios` instead of `aarch64-apple-ios-sim`.

---

## Project Structure

```
ring-slint/
├── ios/                    # iOS project
│   ├── Cargo.toml          # Rust dependencies & build config
│   ├── Cargo.lock
│   ├── Info.plist          # iOS app metadata
│   ├── build.sh            # Terminal build script
│   ├── build.rs            # Cargo build script
│   ├── project.yml         # XcodeGen project definition
│   ├── src/
│   │   └── main.rs         # Rust entry point
│   └── resources/
│       ├── main.ring       # Ring app entry point
│       └── slint.ring      # Ring Slint bindings
├── src/
│   ├── rust_src/           # Ring Slint library (shared)
│   └── slint.ring          # Source slint.ring bindings
├── examples/
└── docs/
    ├── IOS.md
    └── ANDROID.md
```

### Cargo.toml

```toml
[package]
name = "ring-slint-ios"
version = "0.1.0"
edition = "2024"

[[bin]]
name = "ring-slint-ios"
path = "src/main.rs"

[dependencies]
ring_slint = { path = "../src/rust_src" }
ring-lang-rs = "0.1"
libc = "0.2"

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
panic = "abort"
strip = true
```

### src/main.rs

The Rust entry point registers the Ring Slint extension and runs `main.ring`:

```rust
use ring_lang_rs::*;
use std::path::PathBuf;

fn main() {
    // Register slint extension (static linking)
    ring_register_extension(ring_slint::ringlib_init);

    let script_path = get_script_path();

    let state = ring_state_new();
    if state.is_null() {
        eprintln!("Failed to create Ring state");
        return;
    }

    ring_state_runfile_str(state, script_path.to_str().unwrap());
    ring_state_delete(state);
}

fn get_script_path() -> PathBuf {
    // On iOS, the executable is inside AppName.app/
    // Resources are in the same bundle directory
    if let Ok(exe) = std::env::current_exe() {
        if let Some(bundle_dir) = exe.parent() {
            let script = bundle_dir.join("main.ring");
            if script.exists() {
                let _ = std::env::set_current_dir(bundle_dir);
                return script;
            }
        }
    }
    PathBuf::from("resources/main.ring")
}
```

### Required Files in Bundle

| File | Required | Description |
|------|----------|-------------|
| `ring-slint-ios` | **Yes** | Compiled binary |
| `Info.plist` | **Yes** | iOS app metadata |
| `main.ring` | **Yes** | Ring app entry point |
| `slint.ring` | **Yes** | Ring Slint bindings (copy from `src/slint.ring`) |

---

## Asset Management

### Ring Scripts

Place your Ring scripts in `ios/resources/`. They are copied into the `.app` bundle during build.

**resources/main.ring:**
```ring
load "slint.ring"

oApp = new SlintApp {
    loadUIString('
import { Button, VerticalBox } from "std-widgets.slint";

export component App inherits Window {
    title: "My iOS App";
    
    callback tapped();
    in-out property <string> message: "Hello from Ring on iOS!";
    
    VerticalBox {
        padding: 20px;
        padding-top: 60px;  // Safe area for notch/Dynamic Island
        
        Text {
            text: message;
            font-size: 24px;
            horizontal-alignment: center;
        }
        
        Button {
            text: "Tap Me!";
            clicked => { tapped(); }
        }
    }
}
', "app.slint")
    setCallback("tapped", :onTapped)
    show()
    run()
}

func onTapped
    oApp.setString("message", "Tapped!")
```

### Safe Areas

On iOS, account for the notch/Dynamic Island by adding top padding:

```slint
VerticalBox {
    padding-top: 60px;  // Clears the notch/Dynamic Island
    // ... your content
}
```

---

## Platform Differences

### Conditional Code

```ring
if ismacosx()  // Also true on iOS
    // iOS/macOS specific logic
ok
```

### Available Features on iOS

| Category | Available | Not Available |
|----------|-----------|---------------|
| **UI** | All Slint components | - |
| **Properties** | All property methods | - |
| **Callbacks** | All callback methods | - |
| **Timers** | All timer methods | - |
| **Models** | All model methods | - |
| **Styles** | All styles | - |
| **Window** | Basic window management | `windowDrag`, `windowSetAlwaysOnTop`, `windowSetIcon` |
| **File Dialogs** | - | All file dialog methods |
| **Message Boxes** | - | All message box methods |
| **Notifications** | - | All notification methods |
| **Clipboard** | - | All clipboard methods |
| **Hotkeys** | - | All hotkey methods |
| **System Tray** | - | All tray methods |

All unavailable methods are excluded at compile time and will cause "Calling Function without definition" errors if called.

---

## Deploying

### Simulator

```sh
# Boot a simulator
xcrun simctl boot "iPhone 16"
open -a Simulator

# Install and launch
xcrun simctl install booted RingSlint.app
xcrun simctl launch booted dev.ring.slint.app
```

### Cloud Simulator (Appetize.io)

1. Build for simulator: `./build.sh --simulator`
2. Create zip: `cd ios && zip -r RingSlint.zip RingSlint.app`
3. Upload to [appetize.io/upload](https://appetize.io/upload)
4. Select **ARM simulator build** when prompted

### Device (Sideloading, No Developer Account)

You can install on a real device without a paid Apple Developer account using sideloading tools like [AltStore](https://altstore.io/) or [Sideloadly](https://sideloadly.io/). These tools re-sign the app with your free Apple ID.

1. Build for device: `./build.sh`
2. Create an IPA from the `.app` bundle:
   ```sh
   mkdir -p Payload
   cp -r RingSlint.app Payload/
   zip -r RingSlint.ipa Payload
   rm -rf Payload
   ```
3. Install using Sideloadly:
   - Open Sideloadly and connect your iOS device
   - Drag `RingSlint.ipa` into Sideloadly
   - Enter your Apple ID (a free account works)
   - Click Start

> **Note:** Free Apple ID signing expires after 7 days. You'll need to re-sideload periodically. A paid Developer account ($99/year) gives 1 year signing.

### Device (Apple Developer Account)

With a paid Apple Developer account ($99/year), you can sign and install directly:

1. Build for device: `./build.sh`
2. Create a provisioning profile in [Apple Developer Portal](https://developer.apple.com/account/resources/profiles/list):
   - Register your app's Bundle ID (`dev.ring.slint.app`)
   - Register your test device's UDID
   - Create a Development provisioning profile
3. Sign with your certificate and profile:
   ```sh
   # Copy provisioning profile into bundle
   cp ~/Library/MobileDevice/Provisioning\ Profiles/YOUR_PROFILE.mobileprovision RingSlint.app/embedded.mobileprovision
   
   # Sign with your development identity
   codesign --force --sign "Apple Development: your@email.com" \
     --entitlements entitlements.plist \
     RingSlint.app
   ```
4. Install via `ios-deploy`:
   ```sh
   ios-deploy --bundle RingSlint.app
   ```

> **Tip:** Using Xcode is often easier for device deployment — it handles signing automatically. Generate an Xcode project with `xcodegen generate` and build from there.

---

## Troubleshooting

### Common Issues

#### Missing iOS Targets

```
error: target 'aarch64-apple-ios-sim' not found
```

**Solution:**
```sh
rustup target add aarch64-apple-ios aarch64-apple-ios-sim
```

#### CoreSimulator Not Found

```
/Library/Developer/PrivateFrameworks/CoreSimulator.framework/... No such file
```

**Solution:** Run first launch setup:
```sh
sudo xcodebuild -runFirstLaunch
```

#### Simulator Runtime Not Installed

```
No devices available for runtime
```

**Solution:** Install iOS Simulator runtime via Xcode Settings → Platforms, or:
```sh
xcrun simctl runtime add /path/to/iOS_Simulator_Runtime.dmg
```

#### App Crashes on Launch

1. Check the simulator console:
   ```sh
   xcrun simctl spawn booted log stream --predicate 'process == "ring-slint-ios"'
   ```

2. Verify all `.ring` files are in the `.app` bundle:
   ```sh
   ls -la RingSlint.app/
   ```

3. Ensure `main.ring` starts with `load "slint.ring"`.

### Debugging Tips

1. **Add eprintln! in main.rs** for Rust-side debugging
2. **Use `? "debug message"`** in Ring code for print debugging
3. **Check bundle contents**: `ls -la RingSlint.app/`
4. **Test locally first**: Run on local simulator before Appetize

---

## Example: Complete iOS App

**resources/main.ring:**
```ring
load "slint.ring"

cSlintSource = '
import { Button, LineEdit, VerticalBox, HorizontalBox } from "std-widgets.slint";

export component App inherits Window {
    title: "Ring Slint on iOS";
    
    callback greet(string);
    callback update-message(string);
    callback clear-form();
    
    in-out property <string> greeting: "Enter your name and tap Greet!";
    
    VerticalBox {
        padding: 16px;
        padding-top: 60px;
        spacing: 12px;
        
        HorizontalLayout {
            alignment: center;
            spacing: 8px;
            
            Path {
                width: 24px;
                height: 24px;
                viewbox-width: 24;
                viewbox-height: 24;
                fill: #f59e0b;
                commands: "M13 2L3 14h9l-1 8 10-12h-9l1-8z";
            }
            
            Text {
                text: "Ring Slint on iOS";
                font-size: 24px;
                font-weight: 700;
                vertical-alignment: center;
            }
        }
        
        Rectangle {
            vertical-stretch: 1;
            Text {
                text: greeting;
                font-size: 18px;
                horizontal-alignment: center;
                vertical-alignment: center;
                wrap: word-wrap;
            }
        }
        
        VerticalBox {
            spacing: 8px;
            
            name-input := LineEdit {
                placeholder-text: "Enter your name...";
                font-size: 16px;
            }
            
            Button {
                text: "Greet";
                primary: true;
                clicked => { greet(name-input.text); }
            }
            
            HorizontalBox {
                spacing: 8px;
                
                Button {
                    text: "Hello";
                    clicked => { update-message("Hello!"); }
                }
                
                Button {
                    text: "Goodbye";
                    clicked => { update-message("Goodbye!"); }
                }
                
                Button {
                    text: "Clear";
                    clicked => { clear-form(); }
                }
            }
        }
    }
}
'

oApp = new SlintApp {
    loadUIString(cSlintSource, "dynamic://app.slint")
    setCallback("greet", :onGreet)
    setCallback("update-message", :onUpdateMessage)
    setCallback("clear-form", :onClearForm)
    show()
    run()
}

func onGreet
    cName = oApp.callbackArg(1)
    if len(cName) > 0
        oApp.setString("greeting", "Hello, " + cName + "!")
    else
        oApp.setString("greeting", "Please enter your name first!")
    ok

func onUpdateMessage
    cMessage = oApp.callbackArg(1)
    oApp.setString("greeting", cMessage)

func onClearForm
    oApp.setString("greeting", "Enter your name and tap Greet!")
```

Build and run:
```sh
cd ios/
./build.sh --simulator
xcrun simctl install booted RingSlint.app
xcrun simctl launch booted dev.ring.slint.app
```

---

## Resources

- [Slint Documentation](https://docs.slint.dev/)
- [Slint Rust API](https://docs.slint.dev/latest/docs/rust/slint/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Rust iOS Target Support](https://doc.rust-lang.org/rustc/platform-support.html)
- [Ring Slint Examples](../examples/)
- [Ring Slint Android Guide](ANDROID.md)
