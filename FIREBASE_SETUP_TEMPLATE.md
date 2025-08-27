# 🔥 Firebase Setup Guide for Kuasir

This guide will help you set up your own Firebase project to use with Kuasir POS system.

## 📋 Prerequisites

- Google account
- Flutter development environment set up
- Kuasir project cloned and dependencies installed

## 🚀 Step 1: Create Firebase Project

1. **Go to Firebase Console**
   - Visit [Firebase Console](https://console.firebase.google.com)
   - Sign in with your Google account

2. **Create New Project**
   - Click "Create a project"
   - Enter project name (e.g., "kuasir-pos-yourname")
   - Accept terms and continue
   - Disable Google Analytics (optional for POS system)
   - Click "Create project"

## 📱 Step 2: Add Android App

1. **Register Android App**
   - Click "Add app" → Android icon
   - Package name: `id.my.naufalfarrasw.kuasir` (or change to your preference)
   - App nickname: "Kuasir POS"
   - Leave SHA-1 blank for now
   - Click "Register app"

2. **Download Configuration File**
   - Download `google-services.json`
   - Place it in `android/app/` directory of your Flutter project

3. **Configure Android Build Files**
   - Firebase will show configuration steps
   - These are already set up in the project, so you can skip
   - Click "Continue to console"

## 🔐 Step 3: Enable Authentication

1. **Go to Authentication**
   - In Firebase Console, click "Authentication" in left sidebar
   - Click "Get started"

2. **Enable Email/Password**
   - Go to "Sign-in method" tab
   - Click "Email/Password"
   - Enable "Email/Password" (first option)
   - Leave "Email link" disabled
   - Click "Save"

3. **Add Test User (Optional)**
   - Go to "Users" tab
   - Click "Add user"
   - Email: `test@kuasir.com`
   - Password: `test123456`
   - Click "Add user"

## 🗄️ Step 4: Enable Firestore Database

1. **Create Firestore Database**
   - Click "Firestore Database" in left sidebar
   - Click "Create database"

2. **Choose Security Rules**
   - Select "Start in test mode" for development
   - Or "Start in production mode" and configure rules later
   - Click "Next"

3. **Select Location**
   - Choose closest region (e.g., asia-southeast1 for Indonesia)
   - Click "Done"

4. **Configure Security Rules**
   - Go to "Rules" tab
   - For development/testing, use:
   
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```
   
   - For production, implement proper authentication rules:
   
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /barang/{document} {
         allow read, write: if request.auth != null;
       }
       match /transaksi/{document} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

## ⚙️ Step 5: Configure Flutter Project

1. **Install FlutterFire CLI** (if not already installed)
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Configure Firebase for Flutter**
   ```bash
   cd your-kuasir-project
   flutterfire configure
   ```
   
   - Select your Firebase project
   - Choose platforms: Android (and iOS if needed)
   - This will generate `lib/firebase_options.dart`

3. **Enable Firebase in App**
   - Open `lib/main.dart`
   - Find line: `const bool USE_AUTHENTICATION = false;`
   - Change to: `const bool USE_AUTHENTICATION = true;`

4. **Test Firebase Connection**
   - Run the app: `flutter run`
   - You should see "CLOUD" indicator in dashboard
   - Try creating a product in Barang tab
   - Check Firestore Console to see data

## 🧪 Step 6: Test Your Setup

### Test Firestore Database
1. **Add a Product**
   - Open Kuasir app
   - Go to "Barang" tab
   - Add a new product
   - Check Firebase Console → Firestore → `barang` collection

2. **Make a Transaction**
   - Go to "Transaksi" tab
   - Add products to cart
   - Complete checkout
   - Check Firebase Console → Firestore → `transaksi` collection

### Test Authentication
1. **Login/Register**
   - If app shows login screen, create new account
   - Or use test account created earlier
   - Check Firebase Console → Authentication → Users

## 🔒 Security Considerations

### For Development
- Test mode rules are fine for development
- Never use test mode in production

### For Production
- Implement proper authentication rules
- Validate user permissions
- Consider user roles (admin, cashier, etc.)
- Enable App Check for additional security

### Example Production Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to manage products
    match /barang/{document} {
      allow read, write: if request.auth != null;
    }
    
    // Allow authenticated users to create transactions
    match /transaksi/{document} {
      allow create: if request.auth != null;
      allow read: if request.auth != null && 
                     request.auth.uid == resource.data.kasirId;
    }
    
    // User-specific data
    match /users/{userId} {
      allow read, write: if request.auth != null && 
                           request.auth.uid == userId;
    }
  }
}
```

## 🚨 Troubleshooting

### Common Issues

1. **"CONFIGURATION_NOT_FOUND" Error**
   - Ensure `google-services.json` is in `android/app/`
   - Run `flutter clean` and `flutter pub get`
   - Rebuild the app

2. **Authentication Not Working**
   - Check if Email/Password is enabled in Firebase Console
   - Verify `USE_AUTHENTICATION = true` in main.dart
   - Check app package name matches Firebase project

3. **Firestore Permission Denied**
   - Check security rules in Firebase Console
   - Ensure user is authenticated
   - Verify rules allow the operation

4. **App Shows "LOCAL" Instead of "CLOUD"**
   - Firebase initialization failed
   - Check `firebase_options.dart` exists
   - Verify internet connection
   - Check Firebase project configuration

### Debug Steps
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check Firebase configuration
flutterfire configure --check

# View detailed logs
flutter run --verbose
```

## 📞 Support

If you encounter issues:

1. Check the [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
2. Verify your setup against this guide
3. Check Kuasir project issues on GitHub
4. Join Flutter Firebase community for help

## 🎉 Success!

Once configured successfully, you'll have:
- ✅ Real-time cloud database
- ✅ Secure user authentication  
- ✅ Multi-device synchronization
- ✅ Scalable backend infrastructure
- ✅ Professional POS system ready for business

Your Kuasir POS system is now ready for production use with your own Firebase backend!