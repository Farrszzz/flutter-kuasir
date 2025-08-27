# Kuasir - Sistem Kasir Tanpa Autentikasi

## 🎉 Solusi untuk Error "CONFIGURATION_NOT_FOUND"

Karena aplikasi ini akan digunakan sendiri di toko, fitur login/registrasi telah dihilangkan untuk mengatasi error Firebase Authentication. Firebase hanya digunakan untuk penyimpanan data barang dan transaksi.

## 📱 Cara Menjalankan Aplikasi

### Opsi 1: Menggunakan File Terpisah (Recommended)
```bash
flutter run lib/main_no_auth.dart
```

### Opsi 2: Menggunakan Main.dart yang Telah Dimodifikasi
```bash
flutter run
```
> **Catatan**: `main.dart` telah disetel ke mode `USE_AUTHENTICATION = false` secara default.

## ✨ Fitur Aplikasi Tanpa Autentikasi

### 🏪 Dashboard Utama
- ✅ Tampilan selamat datang
- ✅ Indikator status koneksi (CLOUD/LOCAL)
- ✅ Menu navigasi cepat
- ✅ Akses langsung ke semua fitur

### 📦 Manajemen Barang
- ✅ Daftar semua barang
- ✅ Tambah barang baru
- ✅ Edit informasi barang
- ✅ Hapus barang
- ✅ Pencarian barang
- ✅ Kategori dan stok
- ✅ Support barcode

### 💾 Penyimpanan Data
- ✅ **Mode Cloud**: Data disimpan di Firebase Firestore
- ✅ **Mode Local**: Data demo untuk testing offline
- ✅ **Fallback otomatis**: Jika Firebase gagal, gunakan mode local

### 🔄 Sinkronisasi Real-time
- ✅ Update otomatis saat data berubah (mode cloud)
- ✅ Refresh manual tersedia
- ✅ Error handling yang baik

## 🗂️ Struktur File

### File Utama
- **`lib/main_no_auth.dart`** - Aplikasi lengkap tanpa autentikasi
- **`lib/main.dart`** - Versi dengan switch auth/no-auth
- **`lib/providers/no_auth_barang_provider.dart`** - Provider tanpa autentikasi

### Kelebihan Arsitektur Baru
1. **No Authentication Required** - Langsung masuk ke dashboard
2. **Firebase Optional** - Tetap berfungsi jika Firebase tidak tersedia
3. **Demo Data** - Ada data contoh untuk testing
4. **Clean UI** - Material 3 design dengan UX yang baik

## 🛠️ Setup Firebase (Opsional)

Jika ingin menggunakan Firebase untuk penyimpanan cloud:

1. **Buat Collection** di Firestore Console:
   ```
   Collection: barang
   Security Rules: 
   allow read, write: if true;
   ```

2. **Struktur Data Barang**:
   ```json
   {
     "namaBarang": "Indomie Goreng",
     "kategori": "Makanan", 
     "kodeBarcode": "8992388113032",
     "harga": 3000,
     "stok": 50,
     "createdAt": "timestamp",
     "updatedAt": "timestamp"
   }
   ```

## 🚀 Penggunaan di Toko

### Mode Cloud (Firebase)
- Data tersimpan di cloud
- Bisa diakses dari multiple device
- Backup otomatis
- Perlu koneksi internet

### Mode Local (Demo)
- Data tersimpan lokal di device
- Tidak perlu internet
- Data contoh sudah tersedia
- Cocok untuk testing/demo

## 📋 Fitur yang Akan Datang

- ✅ **Manajemen Barang** - Sudah tersedia lengkap
- 🔄 **Transaksi POS** - Sedang dikembangkan
- 🔄 **Riwayat Penjualan** - Sedang dikembangkan  
- 🔄 **Scan Barcode** - Sedang dikembangkan
- 🔄 **Print Receipt** - Sedang dikembangkan

## 🎯 Keuntungan Solusi Ini

### 1. **Mengatasi Error Authentication**
- ❌ Tidak ada lagi "CONFIGURATION_NOT_FOUND"
- ❌ Tidak perlu setup Firebase Auth
- ✅ Langsung bisa digunakan

### 2. **Sesuai Kebutuhan Toko**
- ✅ Tidak perlu login/registrasi
- ✅ Akses langsung ke fitur kasir
- ✅ Cocok untuk penggunaan pribadi

### 3. **Fleksibilitas Tinggi**
- ✅ Bisa dengan/tanpa internet
- ✅ Firebase opsional
- ✅ Fallback ke mode demo

### 4. **User Experience Terbaik**
- ✅ Loading screen yang menarik
- ✅ Error handling yang baik
- ✅ UI modern dengan Material 3

## 🔧 Troubleshooting

### Jika Error "Provider not found":
```bash
flutter clean
flutter pub get
flutter run lib/main_no_auth.dart
```

### Jika Ingin Mengaktifkan Kembali Authentication:
Edit `lib/main.dart`, ubah:
```dart
const bool USE_AUTHENTICATION = true;  // Set ke true
```

### Jika Firebase Connection Error:
- App akan otomatis fallback ke mode local
- Data demo tetap tersedia untuk testing

## 📞 Support

Aplikasi sudah siap digunakan di toko Anda! 

- **Mode Default**: Tanpa autentikasi
- **Firebase**: Opsional untuk cloud storage
- **Demo Data**: Tersedia untuk testing

Selamat menggunakan Kuasir! 🎉