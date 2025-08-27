# 🏪 Kuasir - Modern POS System

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Material3](https://img.shields.io/badge/Material%203-6200EE?style=for-the-badge&logo=materialdesign&logoColor=white)

Kuasir is a modern Point of Sale (POS) system built with Flutter and Firebase, designed specifically for small and medium businesses. Features a clean Material 3 design, real-time inventory management, barcode scanning, and Bluetooth receipt printing.

## ✨ Key Features

### 🔐 **Authentication System**
- Firebase Authentication integration
- Email/password login
- User session management
- Secure route protection
- **No-auth mode** available for immediate testing

### 📦 **Inventory Management**
- Complete CRUD operations for products
- Real-time stock tracking
- Product categories with filtering
- Barcode integration (scan & generate)
- Low stock alerts
- Search functionality with category filters

### 🛒 **Transaction System**
- Professional checkout workflow
- Real-time cart management
- Barcode scanning for quick product addition
- Stock validation to prevent overselling
- Search and filter products during transactions
- Professional transaction history

### 📄 **Receipt Printing**
- Bluetooth thermal printer support
- Professional receipt formatting
- Print after checkout or reprint from history
- Test printing functionality
- ESC/POS compatible

### 📊 **Dashboard & Analytics**
- Sales overview dashboard
- Daily and total sales statistics
- Complete transaction history
- Date-based filtering
- Real-time data synchronization

### 🎨 **Modern UI/UX**
- Material 3 Design System
- Teal/green color scheme
- Responsive design
- Smooth animations
- Professional POS interface
- FloatingActionButtons for better UX

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Android Studio or VS Code
- Android device/emulator for testing
- Firebase project (for cloud features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/kuasir.git
   cd kuasir
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app** (Local mode - no Firebase required)
   ```bash
   flutter run
   ```
   
   The app will run in local mode with demo data for immediate testing.

### 🔥 Firebase Setup (Optional but Recommended)

To enable cloud features and real-time synchronization:

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project
   - Enable **Authentication** and **Firestore Database**

2. **Configure Firebase for Flutter**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

3. **Enable Firestore Security Rules**
   ```javascript
   // For development/testing - Update for production
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```

4. **Update Authentication Config**
   - In `lib/main.dart`, set `USE_AUTHENTICATION = true`
   - Enable Email/Password in Firebase Console

## 📱 App Structure

```
lib/
├── main.dart                    # App entry point with no-auth mode
├── models/                      # Data models
│   ├── barang.dart             # Product model
│   ├── cart_item.dart          # Cart item model
│   └── transaksi.dart          # Transaction model
├── providers/                   # State management (Provider pattern)
│   ├── auth_provider.dart      # Authentication logic
│   ├── barang_provider.dart    # Product management
│   ├── cart_provider.dart      # Shopping cart
│   ├── transaksi_provider.dart # Transaction handling
│   └── no_auth_barang_provider.dart # Local-only mode
├── screens/                     # UI screens
│   ├── login_screen.dart       # Authentication
│   ├── dashboard_screen.dart   # Main dashboard
│   └── firebase_test_screen.dart # Firebase testing
└── widgets/                     # Reusable components
    ├── barcode_scanner_widget.dart    # Camera barcode scanning
    ├── bluetooth_printer_widget.dart  # Thermal printing
    └── barcode_generator_widget.dart  # Barcode generation
```

## 🛠 Technology Stack

### Core Framework
- **Flutter 3.x** - Cross-platform UI framework
- **Dart** - Programming language
- **Material 3** - Modern design system

### State Management
- **Provider** - Simple and efficient state management

### Backend & Database
- **Firebase Firestore** - NoSQL real-time database
- **Firebase Auth** - Authentication service
- **Local Storage** - Offline/local-only mode

### Hardware Integration
- **mobile_scanner** - Camera barcode scanning
- **blue_thermal_printer** - Bluetooth thermal printing
- **permission_handler** - Device permissions

### Utilities
- **barcode** - Barcode generation
- **intl** - Number formatting and localization
- **uuid** - Unique ID generation

## 📊 Database Schema

### Firestore Collections

#### `barang` (Products)
```json
{
  "namaBarang": "string",      // Product name
  "kategori": "string",        // Category
  "kodeBarcode": "string?",    // Barcode (optional)
  "harga": "number",           // Price
  "stok": "number",            // Stock quantity
  "createdAt": "timestamp",    // Creation date
  "updatedAt": "timestamp"     // Last update
}
```

#### `transaksi` (Transactions)
```json
{
  "items": [
    {
      "barangId": "string",      // Product ID
      "namaBarang": "string",    // Product name
      "harga": "number",         // Unit price
      "quantity": "number",      // Quantity sold
      "totalHarga": "number"     // Total for item
    }
  ],
  "totalHarga": "number",       // Total transaction amount
  "tanggalTransaksi": "timestamp", // Transaction date
  "kasirId": "string",          // Cashier ID
  "notes": "string?"            // Optional notes
}
```

## 🎯 How to Use

### 1. **Product Management**
- Navigate to **Barang** tab
- Use FloatingActionButton (+) to add new products
- Scan barcodes directly in the add product form
- Edit or delete existing products
- Products are categorized for easy filtering

### 2. **Making Transactions**
- Go to **Transaksi** tab
- Use search bar to find products by name or barcode
- Filter products by category using filter chips
- Scan barcodes for quick product addition
- Review cart and checkout
- Print receipts via Bluetooth

### 3. **Receipt Printing**
- After checkout, tap "Cetak Struk" (Print Receipt)
- Connect to Bluetooth thermal printer
- Print professional receipts
- Reprint from transaction history

### 4. **Analytics & History**
- **Dashboard** shows sales overview
- **Riwayat** tab displays all transactions
- View detailed transaction breakdowns
- Track daily and total sales

## 📱 Supported Barcode Formats

- **EAN-13** - International product codes
- **EAN-8** - Compact product codes  
- **UPC-A** - North American products
- **Code 128** - Alphanumeric codes
- **Code 39** - Legacy format support
- **QR Codes** - 2D barcode support

## 🖨 Printer Compatibility

### Supported Printers
- ESC/POS compatible thermal printers
- Bluetooth connectivity required
- Paper width: 58mm or 80mm
- Common brands: Epson, Star Micronics, Citizen

### Setup Instructions
1. Pair printer with Android device
2. Open Kuasir app
3. Complete a transaction
4. Tap "Cetak Struk"
5. Select printer from list
6. Test and print receipt

## 🔧 Development Setup

### Local Development
```bash
# Clone repository
git clone https://github.com/yourusername/kuasir.git
cd kuasir

# Install dependencies
flutter pub get

# Run in local mode (no Firebase required)
flutter run

# Or run with Firebase
# Set USE_AUTHENTICATION = true in main.dart
flutter run
```

### Building APK
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# The APK will be in: build/app/outputs/flutter-apk/
```

### Required Permissions (Android)
The following permissions are required in `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Camera for barcode scanning -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Bluetooth for receipt printing -->
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Internet for Firebase -->
<uses-permission android:name="android.permission.INTERNET" />
```

## 🎨 Design System

### Color Palette
- **Primary**: Teal (#00BCD4)
- **Secondary**: Light Blue
- **Surface**: White
- **Background**: Light Grey
- **Success**: Green
- **Error**: Red
- **Warning**: Orange

### Typography
- **Font Family**: Roboto (Material 3 default)
- **Headings**: Bold variants
- **Body Text**: Regular weight
- **Captions**: Light weight

## 🔄 App Modes

### 1. Local Mode (Default)
- No Firebase configuration required
- Runs with demo data
- Perfect for testing and development
- Data stored locally on device

### 2. Firebase Mode
- Real-time cloud synchronization
- Multi-device support
- Secure authentication
- Scalable for business growth

## 🚀 Roadmap

- [ ] **Multi-language Support** - Indonesian and English
- [ ] **Advanced Analytics** - Sales reports and charts
- [ ] **Multi-store Support** - Chain store management
- [ ] **Employee Management** - Role-based access control
- [ ] **Inventory Alerts** - Low stock notifications
- [ ] **Custom Receipt Templates** - Branded receipts
- [ ] **API Integration** - Third-party services
- [ ] **Web Dashboard** - Manager web interface

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines
- Follow Flutter/Dart best practices
- Maintain Material 3 design consistency
- Add tests for new features
- Update documentation as needed
- Ensure compatibility with both local and Firebase modes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/kuasir/issues) page
2. Create a new issue with:
   - Detailed problem description
   - Steps to reproduce
   - Error logs (if any)
   - Device and Flutter version info

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for backend-as-a-service
- Material Design team for the design system
- Open source community for the packages used
- Indonesian small business community for inspiration

---

**Made with ❤️ using Flutter and Firebase**

**Perfect for:** Small businesses, retail stores, cafes, restaurants, and any business needing a modern POS system.
