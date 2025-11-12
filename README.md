# 📸 SnapChat / WhatsApp / Instagram Text Editor

[![Swift](https://img.shields.io/badge/Swift-5.0+-F05138?logo=swift&logoColor=white)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS-blue?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Project_Status-Active-brightgreen)]()

---

## 🧩 Overview

**SnapChatTextEditor** is a custom iOS photo editing app inspired by **Snapchat, WhatsApp, and Instagram** story editors.  
It allows users to take or select photos and **add stylish text, emojis, drawings, stickers, and colors** directly onto the image — just like the text editing tools in popular social media apps.

Built using **UIKit**, **CoreGraphics**, and **AVFoundation**, this project demonstrates real-world-level text and drawing editing functionalities inside a simple, elegant interface.

---

## 🚀 Features

- 🖊️ Add and edit text over photos  
- 🎨 Dynamic **color slider** for text and brush color selection  
- 📷 Capture or import images directly from **camera** or **photo library**  
- ✏️ Freehand drawing using **touch gestures**  
- 🔤 Custom fonts and font styling  
- 🧩 Layer-based object handling (move, scale, rotate text or drawings)  
- 💾 Save edited images to the gallery  
- 🌈 WhatsApp/Snapchat-like text input and alignment  
- 🧠 MVVM + UIKit clean project structure  

---

## 📂 Project Structure

SnapChatTextEditor/
├── Assets.xcassets/
├── Camera/
│ ├── CameraViewController.swift
│ └── PhotoCaptureHandler.swift
├── Fonts/
│ ├── CustomFontManager.swift
│ └── FontLoader.swift
├── Helper/
│ ├── Extensions.swift
│ ├── Utilities.swift
│ └── ColorSlider.swift
├── Storyboard/
│ └── Base.lproj/
│ └── Main.storyboard
├── ViewController/
│ ├── EditorViewController.swift
│ ├── TextToolView.swift
│ ├── BrushToolView.swift
│ └── StickerView.swift
├── WhatsappPhoto.xcdatamodeld/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Info.plist
└── Podfile


---

## ⚙️ Requirements

- Xcode 14.0 or later  
- iOS 14.0+  
- Swift 5+  
- UIKit-based project  

---

## 🧠 Key Concepts

- **CoreGraphics & CoreImage** for rendering drawings and text overlays  
- **AVFoundation** for camera and media handling  
- **Gesture Recognizers** for moving, scaling, and rotating elements  
- **CoreData** for optional local photo metadata storage  
- **Pod Dependencies** managed via CocoaPods  

---

## ▶️ How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/RahulSohaliya1/SnapChatTextEditor.git
   
2. Navigate to the project directory:
cd SnapChatTextEditor

3. Install dependencies:
pod install

4. Open the workspace:
open WhatsappPhoto.xcworkspace

5. Build and run the project in Xcode on any iOS simulator or real device.

🧑‍💻 Contributors
👨‍💻 Rahul Sohaliya

🪪 License

This project is licensed under the MIT License — see the LICENSE
 file for details.

⭐️ If you like this project, give it a star on GitHub — it helps support open-source iOS development!
