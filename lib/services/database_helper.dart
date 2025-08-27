import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:kuasir/models/barang.dart';
import 'package:kuasir/models/cart_item.dart';
import 'package:kuasir/models/transaksi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'kuasir.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create barang table
    await db.execute('''
      CREATE TABLE barang (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        nama_barang TEXT NOT NULL,
        kategori TEXT NOT NULL,
        kode_barcode TEXT,
        harga REAL NOT NULL,
        stok INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create transaksi table
    await db.execute('''
      CREATE TABLE transaksi (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        total REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create transaksi_items table
    await db.execute('''
      CREATE TABLE transaksi_items (
        id TEXT PRIMARY KEY,
        transaksi_id TEXT NOT NULL,
        barang_id TEXT NOT NULL,
        nama_barang TEXT NOT NULL,
        harga REAL NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transaksi_id) REFERENCES transaksi (id),
        FOREIGN KEY (barang_id) REFERENCES barang (id)
      )
    ''');
  }

  // User operations
  Future<bool> createUser(String email, String password) async {
    try {
      final db = await database;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      
      await db.insert('users', {
        'id': id,
        'email': email,
        'password': password, // In production, hash this password
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      final db = await database;
      final users = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, password],
      );
      
      if (users.isNotEmpty) {
        return users.first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Barang operations
  Future<List<Barang>> getBarangList(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'barang',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Barang(
        id: maps[i]['id'],
        namaBarang: maps[i]['nama_barang'],
        kategori: maps[i]['kategori'],
        kodeBarcode: maps[i]['kode_barcode'],
        harga: maps[i]['harga'],
        stok: maps[i]['stok'],
        createdAt: DateTime.parse(maps[i]['created_at']),
        updatedAt: DateTime.parse(maps[i]['updated_at']),
      );
    });
  }

  Future<bool> insertBarang(Barang barang, String userId) async {
    try {
      final db = await database;
      await db.insert('barang', {
        'id': barang.id,
        'user_id': userId,
        'nama_barang': barang.namaBarang,
        'kategori': barang.kategori,
        'kode_barcode': barang.kodeBarcode,
        'harga': barang.harga,
        'stok': barang.stok,
        'created_at': barang.createdAt.toIso8601String(),
        'updated_at': barang.updatedAt.toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBarang(Barang barang, String userId) async {
    try {
      final db = await database;
      await db.update(
        'barang',
        {
          'nama_barang': barang.namaBarang,
          'kategori': barang.kategori,
          'kode_barcode': barang.kodeBarcode,
          'harga': barang.harga,
          'stok': barang.stok,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ? AND user_id = ?',
        whereArgs: [barang.id, userId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBarang(String barangId, String userId) async {
    try {
      final db = await database;
      await db.delete(
        'barang',
        where: 'id = ? AND user_id = ?',
        whereArgs: [barangId, userId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Barang?> findBarangByBarcode(String barcode, String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'barang',
        where: 'kode_barcode = ? AND user_id = ?',
        whereArgs: [barcode, userId],
      );

      if (maps.isNotEmpty) {
        return Barang(
          id: maps[0]['id'],
          namaBarang: maps[0]['nama_barang'],
          kategori: maps[0]['kategori'],
          kodeBarcode: maps[0]['kode_barcode'],
          harga: maps[0]['harga'],
          stok: maps[0]['stok'],
          createdAt: DateTime.parse(maps[0]['created_at']),
          updatedAt: DateTime.parse(maps[0]['updated_at']),
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Transaksi operations
  Future<bool> insertTransaksi(Transaksi transaksi, String userId) async {
    try {
      final db = await database;
      
      // Insert transaksi
      await db.insert('transaksi', {
        'id': transaksi.id,
        'user_id': userId,
        'total': transaksi.total,
        'created_at': transaksi.createdAt.toIso8601String(),
      });

      // Insert transaksi items
      for (var item in transaksi.items) {
        await db.insert('transaksi_items', {
          'id': DateTime.now().millisecondsSinceEpoch.toString() + item.barang.id!,
          'transaksi_id': transaksi.id,
          'barang_id': item.barang.id!,
          'nama_barang': item.barang.namaBarang,
          'harga': item.barang.harga,
          'quantity': item.quantity,
          'subtotal': item.subtotal,
        });
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Transaksi>> getTransaksiList(String userId) async {
    try {
      final db = await database;
      
      // Get transaksi list
      final List<Map<String, dynamic>> transaksiMaps = await db.query(
        'transaksi',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      List<Transaksi> transaksiList = [];

      for (var transaksiMap in transaksiMaps) {
        // Get items for each transaksi
        final List<Map<String, dynamic>> itemMaps = await db.query(
          'transaksi_items',
          where: 'transaksi_id = ?',
          whereArgs: [transaksiMap['id']],
        );

        List<CartItem> items = itemMaps.map((itemMap) {
          return CartItem(
            barang: Barang(
              id: itemMap['barang_id'],
              namaBarang: itemMap['nama_barang'],
              kategori: '', // Not stored in transaksi_items
              harga: itemMap['harga'],
              stok: 0, // Not relevant for completed transactions
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            quantity: itemMap['quantity'],
          );
        }).toList();

        transaksiList.add(Transaksi(
          id: transaksiMap['id'],
          items: items,
          total: transaksiMap['total'],
          createdAt: DateTime.parse(transaksiMap['created_at']),
        ));
      }

      return transaksiList;
    } catch (e) {
      return [];
    }
  }

  // Analytics operations
  Future<Map<String, dynamic>> getSalesSummary(String userId) async {
    try {
      final db = await database;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      // Today's sales
      final todayResult = await db.rawQuery('''
        SELECT COUNT(*) as count, COALESCE(SUM(total), 0) as total
        FROM transaksi 
        WHERE user_id = ? AND created_at >= ?
      ''', [userId, today.toIso8601String()]);

      // Monthly sales
      final monthlyResult = await db.rawQuery('''
        SELECT COUNT(*) as count, COALESCE(SUM(total), 0) as total
        FROM transaksi 
        WHERE user_id = ? AND created_at >= ?
      ''', [userId, monthStart.toIso8601String()]);

      return {
        'todaySales': todayResult[0]['total'] ?? 0.0,
        'todayTransactions': todayResult[0]['count'] ?? 0,
        'monthlySales': monthlyResult[0]['total'] ?? 0.0,
        'totalTransactions': monthlyResult[0]['count'] ?? 0,
      };
    } catch (e) {
      return {
        'todaySales': 0.0,
        'todayTransactions': 0,
        'monthlySales': 0.0,
        'totalTransactions': 0,
      };
    }
  }
}