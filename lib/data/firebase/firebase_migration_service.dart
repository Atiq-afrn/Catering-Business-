import 'dart:convert';
import '../repositories/catering_repository.dart';

/// Firebase Migration & Cloud Firestore Integration Service
/// Formats and prepares all local company-scoped data for Firebase Cloud Firestore
class FirebaseMigrationService {
  final ICateringRepository _repository;

  FirebaseMigrationService(this._repository);

  /// Generates the complete multi-tenant Firestore JSON package for a specific company
  Future<Map<String, dynamic>> generateCompanyFirestoreBundle(String companyId) async {
    final company = await _repository.getCompanyById(companyId);
    if (company == null) {
      throw Exception('Company with ID $companyId not found');
    }

    final ingredients = await _repository.getIngredients(companyId);
    final recipes = await _repository.getRecipes(companyId);
    final functions = await _repository.getFunctions(companyId);
    final staff = await _repository.getStaffList(companyId);
    final expenses = await _repository.getExpenses(companyId);

    return {
      'firestore_path': '/companies/$companyId',
      'company_metadata': company.toFirestore(),
      'collections': {
        'ingredients': {
          for (var item in ingredients) item.id: item.toFirestore(),
        },
        'recipes': {
          for (var item in recipes) item.id: item.toFirestore(),
        },
        'functions': {
          for (var item in functions) item.id: item.toFirestore(),
        },
        'staff': {
          for (var item in staff) item.id: item.toMap(),
        },
        'expenses': {
          for (var item in expenses) item.id: item.toMap(),
        },
      },
      'migration_timestamp': DateTime.now().toIso8601String(),
      'sync_status': 'ready_to_upload',
    };
  }

  /// Returns the formatted JSON string for export
  Future<String> exportCompanyJsonString(String companyId) async {
    final bundle = await generateCompanyFirestoreBundle(companyId);
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(bundle);
  }

  /// Official Cloud Firestore Security Rules ensuring company data isolation
  static String getFirestoreSecurityRules() {
    return '''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Check if user is authenticated and belongs to the requested company
    function belongsToCompany(companyId) {
      return request.auth != null && 
        (request.auth.token.companyId == companyId || 
         request.auth.token.email == resource.data.email ||
         request.auth.token.email == get(/databases/\$(database)/documents/companies/\$(companyId)).data.email);
    }

    // Top-level Company document
    match /companies/{companyId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if belongsToCompany(companyId);

      // Subcollections scoped to this company
      match /ingredients/{ingredientId} {
        allow read, write: if belongsToCompany(companyId);
      }
      
      match /recipes/{recipeId} {
        allow read, write: if belongsToCompany(companyId);
      }
      
      match /functions/{functionId} {
        allow read, write: if belongsToCompany(companyId);
      }
      
      match /inventory/{movementId} {
        allow read, write: if belongsToCompany(companyId);
      }
      
      match /staff/{staffId} {
        allow read, write: if belongsToCompany(companyId);
      }
      
      match /expenses/{expenseId} {
        allow read, write: if belongsToCompany(companyId);
      }
    }
  }
}
''';
  }
}
