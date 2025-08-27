# 🤝 Contributing to Kuasir POS System

Thank you for your interest in contributing to Kuasir! This document provides guidelines and information for contributors.

## 🌟 How to Contribute

### 🐛 Reporting Bugs

1. **Check existing issues** - Search for similar issues first
2. **Create detailed bug report** with:
   - Clear, descriptive title
   - Steps to reproduce the issue
   - Expected vs actual behavior
   - Screenshots or error logs
   - Device/platform information
   - Flutter and Dart version

### 💡 Suggesting Features

1. **Check roadmap** - See if feature is already planned
2. **Open feature request** with:
   - Clear description of the feature
   - Use case and benefits
   - Possible implementation approach
   - Mockups or examples (if applicable)

### 🔧 Code Contributions

#### 1. Fork and Clone
```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/yourusername/kuasir.git
cd kuasir
```

#### 2. Set Up Development Environment
```bash
# Install dependencies
flutter pub get

# Run tests
flutter test

# Run the app
flutter run
```

#### 3. Create Feature Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

#### 4. Make Changes
- Follow the coding standards below
- Write tests for new features
- Update documentation as needed
- Test both local and Firebase modes

#### 5. Commit Changes
```bash
git add .
git commit -m "feat: add search functionality to products"
# or
git commit -m "fix: resolve cart calculation issue"
```

#### 6. Push and Create PR
```bash
git push origin feature/your-feature-name
```
Then create a Pull Request on GitHub with:
- Clear title and description
- Reference related issues
- Screenshots of changes (if UI)
- Testing instructions

## 📝 Coding Standards

### Dart/Flutter Guidelines
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` for code formatting
- Run `flutter analyze` and fix all issues
- Write meaningful variable and function names

### Project Structure
```
lib/
├── main.dart                # App entry point
├── models/                  # Data models
├── providers/               # State management
├── screens/                 # UI screens
├── widgets/                 # Reusable widgets
└── utils/                   # Utility functions
```

### State Management
- Use Provider pattern consistently
- Keep state logic in providers
- Minimize widget rebuilds with Consumer

### UI/UX Guidelines
- Follow Material 3 design principles
- Maintain consistent color scheme (teal/green)
- Use provided theme and text styles
- Ensure responsive design
- Test on different screen sizes

### Code Examples

#### Good Examples ✅
```dart
// Good: Clear naming and structure
class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  
  List<Product> get products => List.unmodifiable(_products);
  
  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add(product.toMap());
      _products.add(product);
      notifyListeners();
    } catch (e) {
      throw ProductException('Failed to add product: $e');
    }
  }
}
```

```dart
// Good: Proper widget structure
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(product.category),
        trailing: Text(_formatCurrency(product.price)),
        onTap: onTap,
      ),
    );
  }
}
```

#### Avoid ❌
```dart
// Bad: Poor naming and structure
class PP extends ChangeNotifier {
  var list = [];
  
  void add(dynamic item) {
    list.add(item);
    notifyListeners();
  }
}
```

### Testing Guidelines
- Write unit tests for business logic
- Write widget tests for UI components
- Test error handling and edge cases
- Ensure tests pass in both local and Firebase modes

```dart
// Example test
void main() {
  group('ProductProvider Tests', () {
    test('should add product successfully', () async {
      final provider = ProductProvider();
      final product = Product(name: 'Test', price: 1000);
      
      await provider.addProduct(product);
      
      expect(provider.products.length, 1);
      expect(provider.products.first.name, 'Test');
    });
  });
}
```

## 🎯 Priority Areas

### High Priority
- 🐛 Bug fixes and stability improvements
- 📱 Mobile responsiveness
- 🔒 Security enhancements
- 📊 Performance optimizations

### Medium Priority
- ✨ New features from roadmap
- 🎨 UI/UX improvements
- 📝 Documentation updates
- 🧪 Test coverage improvements

### Nice to Have
- 🌍 Internationalization
- 🎯 Advanced analytics
- 🔌 Third-party integrations
- 📱 Web platform support

## 🔄 Development Workflow

### Branch Naming
- `feature/feature-name` - New features
- `fix/issue-description` - Bug fixes
- `docs/update-readme` - Documentation
- `refactor/component-name` - Code refactoring
- `test/add-unit-tests` - Testing improvements

### Commit Messages
Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add barcode scanning to product form
fix: resolve cart total calculation error
docs: update Firebase setup guide
style: format code according to Dart guidelines
refactor: extract common widgets to reusable components
test: add unit tests for transaction provider
```

### Pull Request Process
1. **Pre-submission checklist:**
   - [ ] Code follows project style guidelines
   - [ ] Tests added/updated and passing
   - [ ] Documentation updated if needed
   - [ ] No merge conflicts
   - [ ] Screenshots provided for UI changes

2. **Review process:**
   - Maintainers will review within 2-3 days
   - Address feedback promptly
   - Keep PR scope focused and small

3. **Merge requirements:**
   - At least one maintainer approval
   - All checks passing
   - Conflicts resolved

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter test integration_test/
```

### Test Requirements
- All new features must include tests
- Bug fixes should include regression tests
- Maintain or improve test coverage
- Test both success and error scenarios

## 📚 Documentation

### Code Documentation
- Document public APIs with dartdoc comments
- Include usage examples for complex functions
- Keep comments up-to-date with code changes

### Project Documentation
- Update README.md for new features
- Update FIREBASE_SETUP_TEMPLATE.md for configuration changes
- Create new guides for complex features

## 🚀 Release Process

### Version Numbering
We follow [Semantic Versioning](https://semver.org/):
- `1.0.0` - Major version (breaking changes)
- `1.1.0` - Minor version (new features)
- `1.1.1` - Patch version (bug fixes)

### Release Checklist
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Version bumped in pubspec.yaml
- [ ] Changelog updated
- [ ] APK built and tested
- [ ] Release notes prepared

## 💬 Communication

### Getting Help
- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - General questions and ideas
- **Code Reviews** - Technical discussions on PRs

### Community Guidelines
- Be respectful and constructive
- Help others learn and grow
- Focus on code quality and user experience
- Share knowledge and best practices

## 🏆 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- GitHub contributor statistics

### Types of Contributions
- 💻 Code contributions
- 📝 Documentation improvements
- 🐛 Bug reports and testing
- 💡 Feature suggestions
- 🎨 UI/UX design
- 🌍 Translations
- 📢 Community support

## 📞 Contact

- **Project Maintainer**: [GitHub Profile]
- **Issues**: Use GitHub Issues for bug reports
- **General Questions**: Use GitHub Discussions

Thank you for contributing to Kuasir! Together we're building a better POS system for small businesses everywhere. 🚀