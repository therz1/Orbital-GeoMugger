# Clean up old build artifacts
flutter clean

# Get the latest dependencies
flutter pub get

# Build the production release (no renderer flags needed)
flutter build web --release
