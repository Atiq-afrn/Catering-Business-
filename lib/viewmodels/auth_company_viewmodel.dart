import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../data/models/company_model.dart';
import '../data/repositories/catering_repository.dart';
import '../data/local/database_helper.dart';

class AuthCompanyViewModel extends ChangeNotifier {
  final ICateringRepository _repository;
  CompanyModel? _activeCompany;
  List<CompanyModel> _companies = [];
  String _currentLanguage = 'en';
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _errorMessage;

  AuthCompanyViewModel(this._repository);

  CompanyModel? get activeCompany => _activeCompany;
  List<CompanyModel> get companies => _companies;
  String get currentLanguage => _currentLanguage;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String? get errorMessage => _errorMessage;

  // ─────────────────────────────────────────────────────────
  // INITIALIZE — Restore session & language from SharedPrefs
  // ─────────────────────────────────────────────────────────
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('pref_language') ?? 'en';
      _isLoggedIn = prefs.getBool('pref_is_logged_in') ?? false;

      _companies = await _repository.getCompanies();

      final savedCompanyId = prefs.getString('pref_active_company_id');
      if (_isLoggedIn &&
          savedCompanyId != null &&
          _companies.any((c) => c.id == savedCompanyId)) {
        _activeCompany =
            _companies.firstWhere((c) => c.id == savedCompanyId);
      } else if (_isLoggedIn && _companies.isNotEmpty) {
        _activeCompany = _companies.first;
      } else {
        _isLoggedIn = false;
        _activeCompany = null;
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      _isLoggedIn = false;
      _activeCompany = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // SWITCH COMPANY (multi-restaurant support)
  // ─────────────────────────────────────────────────────────
  Future<void> switchCompany(CompanyModel company) async {
    _activeCompany = company;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pref_active_company_id', company.id);
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────

  /// Normalise phone: strip spaces, dashes, +, (, )
  String _normalizePhone(String raw) {
    return raw.replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
  }

  /// Returns last N digits of a phone number for flexible match
  bool _phoneMatch(String inputPhone, String storedPhone) {
    final input = _normalizePhone(inputPhone);
    final stored = _normalizePhone(storedPhone);
    if (input.isEmpty || stored.isEmpty) return false;
    if (input == stored) return true;
    // Match last 10 digits
    if (input.length >= 10 && stored.endsWith(input.substring(input.length - 10))) return true;
    if (stored.length >= 10 && input.endsWith(stored.substring(stored.length - 10))) return true;
    return false;
  }

  // ─────────────────────────────────────────────────────────
  // LOGIN — Email or Phone + Password
  // ─────────────────────────────────────────────────────────
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanId = identifier.trim().toLowerCase();
      final cleanPass = password.trim();

      if (cleanId.isEmpty) {
        throw 'Please enter your email or mobile number.';
      }
      if (cleanPass.isEmpty) {
        throw 'Please enter your password.';
      }

      _companies = await _repository.getCompanies();

      if (_companies.isEmpty) {
        throw 'No restaurant account found. Please register your restaurant first.';
      }

      CompanyModel? matched;
      bool foundIdentifier = false;

      for (final comp in _companies) {
        final compEmail = comp.email.trim().toLowerCase();
        final compPhone = comp.phone.trim();
        final compOwnerPhone = comp.ownerPhone.trim();

        // Determine if input looks like email or phone
        final isEmailInput = cleanId.contains('@');

        bool identifierMatches = false;
        if (isEmailInput) {
          identifierMatches = compEmail.isNotEmpty && compEmail == cleanId;
        } else {
          identifierMatches =
              _phoneMatch(cleanId, compPhone) ||
              _phoneMatch(cleanId, compOwnerPhone);
        }

        if (identifierMatches) {
          foundIdentifier = true;
          final expectedPass = comp.password.isNotEmpty ? comp.password : '123456';

          if (cleanPass == expectedPass) {
            matched = comp;
            break;
          } else {
            throw 'Incorrect password. Please check and try again.';
          }
        }
      }

      if (!foundIdentifier) {
        throw 'No restaurant account found with this email or mobile number. Please register your restaurant.';
      }

      if (matched == null) {
        throw 'Login failed. Please check your credentials.';
      }

      _activeCompany = matched;
      _isLoggedIn = true;
      _currentLanguage = matched.defaultLanguage;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_active_company_id', matched.id);
      await prefs.setBool('pref_is_logged_in', true);
      await prefs.setString('pref_language', matched.defaultLanguage);

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // LOGOUT — Clear session and persist
  // ─────────────────────────────────────────────────────────
  Future<void> logout() async {
    _isLoggedIn = false;
    _activeCompany = null;
    _errorMessage = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_is_logged_in', false);
    await prefs.remove('pref_active_company_id');

    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // REGISTER — New Restaurant Account
  // ─────────────────────────────────────────────────────────
  Future<CompanyModel> registerNewCompany({
    required String name,
    required String ownerName,
    String phone = '',
    String? ownerPhone,
    String? email,
    required String address,
    String? gstin,
    String password = '123456',
    String defaultLanguage = 'en',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cleanPhone = phone.trim();
      final cleanEmail = (email ?? '').trim().toLowerCase();

      // Validate required fields
      if (name.trim().isEmpty) throw 'Restaurant name is required.';
      if (ownerName.trim().isEmpty) throw 'Owner name is required.';
      if (cleanPhone.isEmpty && cleanEmail.isEmpty) {
        throw 'Mobile number or email is required.';
      }
      if (cleanPhone.isNotEmpty && cleanPhone.length < 10) {
        throw 'Please enter a valid 10-digit mobile number.';
      }
      if (cleanEmail.isNotEmpty && !cleanEmail.contains('@')) {
        throw 'Please enter a valid email address.';
      }
      if (address.trim().isEmpty) throw 'Location / address is required.';
      if (password.trim().length < 4) throw 'Password must be at least 4 characters.';

      // Check for duplicate phone or email
      _companies = await _repository.getCompanies();
      for (final comp in _companies) {
        if (cleanPhone.isNotEmpty &&
            (_phoneMatch(cleanPhone, comp.phone) ||
                _phoneMatch(cleanPhone, comp.ownerPhone))) {
          throw 'A restaurant with this mobile number is already registered. Please login instead.';
        }
        if (cleanEmail.isNotEmpty &&
            comp.email.trim().toLowerCase() == cleanEmail) {
          throw 'A restaurant with this email address is already registered. Please login instead.';
        }
      }

      final now = DateTime.now().toIso8601String();
      final uniqueCompanyId = 'comp_${const Uuid().v4().substring(0, 8)}';

      final newCompany = CompanyModel(
        id: uniqueCompanyId,
        name: name.trim(),
        ownerName: ownerName.trim(),
        phone: cleanPhone,
        ownerPhone: (ownerPhone ?? cleanPhone).trim(),
        email: cleanEmail,
        address: address.trim(),
        gstin: gstin?.trim(),
        password: password.trim().isNotEmpty ? password.trim() : '123456',
        defaultLanguage: defaultLanguage,
        createdAt: now,
        updatedAt: now,
      );

      // Register in SQLite and seed ingredient catalogue
      await DatabaseHelper.instance.registerNewCompany(newCompany);

      _companies = await _repository.getCompanies();
      _activeCompany = newCompany;
      _isLoggedIn = true;
      _currentLanguage = defaultLanguage;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_active_company_id', newCompany.id);
      await prefs.setBool('pref_is_logged_in', true);
      await prefs.setString('pref_language', defaultLanguage);

      return newCompany;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // UPDATE PROFILE
  // ─────────────────────────────────────────────────────────
  Future<void> updateCompanyProfile({
    required String name,
    required String ownerName,
    required String phone,
    required String ownerPhone,
    required String address,
    String? gstin,
  }) async {
    if (_activeCompany == null) return;

    final updated = _activeCompany!.copyWith(
      name: name.trim(),
      ownerName: ownerName.trim(),
      phone: phone.trim(),
      ownerPhone: ownerPhone.trim(),
      address: address.trim(),
      gstin: gstin?.trim(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    await _repository.saveCompany(updated);
    _activeCompany = updated;
    _companies = await _repository.getCompanies();
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────
  // CHANGE LANGUAGE
  // ─────────────────────────────────────────────────────────
  Future<void> changeLanguage(String langCode) async {
    if (['en', 'hi', 'mr', 'gu'].contains(langCode)) {
      _currentLanguage = langCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pref_language', langCode);
      if (_activeCompany != null) {
        final updated = _activeCompany!.copyWith(defaultLanguage: langCode);
        await _repository.saveCompany(updated);
        _activeCompany = updated;
      }
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────────────────
  // CLEAR ERROR
  // ─────────────────────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
