/// Auth feature barrel export
///
/// Provides authentication functionality including:
/// - Login with email/password
/// - PIN setup and verification
/// - Biometric authentication
/// - Session management
library;

// Data layer
export 'data/data.dart';

// Domain models
export 'domain/models/models.dart';

// Presentation
export 'presentation/providers/providers.dart';
export 'presentation/screens/screens.dart';
export 'presentation/widgets/widgets.dart';

// Pages (using design tokens)
export 'presentation/pages/pages.dart';
