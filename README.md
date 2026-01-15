# AlgoBotix Inventory Management

A robust, offline-first mobile application developed using Flutter for the AlgoBotix technical assessment. This app provides a complete solution for tracking inventory, managing stock levels, and monitoring product history with a modern "Glassmorphic" user interface.

## 📱 App Overview

**AlgoBotix Inventory** is designed to be fast, reliable, and aesthetically pleasing. It leverages **Hive** for high-performance local storage, ensuring the app works perfectly without an internet connection. It features real-time search, barcode scanning integration, and detailed audit logs for stock movements.

## ✨ Key Features

### 📦 Product Management (CRUD)
* **Add Items:** Create new inventory items with a unique 5-character ID, Name, Description, and Stock count.
* **Media Support:** Attach images to products using the Device Camera or Gallery.
* **Edit & Delete:** Full capability to modify product details or remove items from the database.
* **Validation:** Enforces strict validation rules (e.g., unique 5-char alphanumeric IDs).

### 🔍 Search & Scan
* **Smart Search:** Real-time filtering of the product list by Product ID directly from the Home Screen.
* **QR/Barcode Scanner:** Accessible via the AppBar, this feature allows users to scan a product code.
    * *Found:* Instantly navigates to the Product Details screen.
    * *Not Found:* Prompts the user to add the new item, preserving the scanned barcode in the description.

### 📊 Stock Control & History
* **Quick Updates:** Increment or decrement stock levels instantly from the details page.
* **Audit Log:** Automatically records every stock change (Date, Time, Operation, Amount) in a chronological history log.
* **Universal History:** A global view aggregating activity from all products into a single timeline.

### 🎨 Modern UI/UX
* **Glassmorphism:** Custom widgets featuring blurred backgrounds, soft gradients, and rounded corners.
* **Immersive Design:** Bouncing scroll physics and high-quality interactions.

---

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **State Management:** Provider
* **Local Database:** Hive (NoSQL, fast & lightweight)
* **Scanning:** mobile_scanner
* **Hardware Access:** image_picker (Camera/Gallery)
* **Utilities:** intl (Formatting), lucide_icons (Iconography), path_provider (Storage paths).

---

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites
* Flutter SDK installed (Channel stable).
* Android Studio or VS Code configured.
* An Android Emulator or Physical Device.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/algobotix-inventory.git](https://github.com/your-username/algobotix-inventory.git)
    cd algobotix-inventory
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 📂 Project Structure

The project follows a clean, feature-based architecture:

```text
lib/
├── main.dart             # Entry point & App Theme
├── models/               # Hive Data Models (Product, StockHistory)
├── providers/            # State Management Logic (InventoryProvider)
├── screens/
│   ├── home_screen.dart           # Main Dashboard
│   ├── add_edit_screen.dart       # Form for Create/Update
│   ├── product_details_screen.dart# Item View & Stock Control
│   ├── stock_history_screen.dart  # Specific Product Log
│   ├── universal_history_screen.dart # Global Activity Log
│   └── qr_scanner_screen.dart     # Camera Scanner Logic
└── widgets/
    └── glass_card.dart   # Reusable Glassmorphic Container
