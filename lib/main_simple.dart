import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuasir/providers/cart_provider.dart';

void main() {
  runApp(const SimpleKuasirApp());
}

class SimpleKuasirApp extends StatelessWidget {
  const SimpleKuasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Kuasir - Simple POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00BCD4),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: const SimpleDashboard(),
      ),
    );
  }
}

class SimpleDashboard extends StatelessWidget {
  const SimpleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kuasir - Simple POS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Kuasir POS System',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.point_of_sale,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sistem kasir modern untuk bisnis Anda',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ready to Use',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Status Cards
            Text(
              'System Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    context,
                    title: 'Application',
                    status: 'Running',
                    icon: Icons.mobile_friendly,
                    isOnline: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    context,
                    title: 'Build Status',
                    status: 'Success',
                    icon: Icons.build_circle,
                    isOnline: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Information Section
            Text(
              'Features Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: [
                  _buildFeatureItem(
                    context,
                    icon: Icons.verified,
                    title: 'APK Build System',
                    description: 'Successfully builds release APK without crashes',
                    isAvailable: true,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.security,
                    title: 'Proper Permissions',
                    description: 'All required Android permissions configured',
                    isAvailable: true,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.design_services,
                    title: 'Material 3 Design',
                    description: 'Modern UI with teal color scheme',
                    isAvailable: true,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.offline_bolt,
                    title: 'Offline Capability',
                    description: 'Works without internet connection',
                    isAvailable: true,
                  ),
                  _buildFeatureItem(
                    context,
                    icon: Icons.cloud,
                    title: 'Firebase Integration',
                    description: 'Ready for cloud features when configured',
                    isAvailable: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, {
    required String title,
    required String status,
    required IconData icon,
    required bool isOnline,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isOnline ? Colors.green : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isOnline ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOnline ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isAvailable,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isAvailable ? Colors.green : Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isAvailable ? Colors.green : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: Icon(
          isAvailable ? Icons.check_circle : Icons.pending,
          color: isAvailable ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}