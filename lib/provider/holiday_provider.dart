import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../model/models.dart';
import '../utils/constants.dart';

class HolidayProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  List<Country> _countries = [];
  List<Region> _regions = [];
  List<Holiday> _holidays = [];

  String _selectedCountryCode = 'DE';
  String _selectedRegionCode = 'DE-BW';
  int _selectedYear = DateTime.now().year;

  // Getters
  List<Country> get countries => _countries;
  List<Region> get regions => _regions;
  List<Holiday> get holidays => _holidays;
  String get selectedCountryCode => _selectedCountryCode;
  String get selectedRegionCode => _selectedRegionCode;
  int get selectedYear => _selectedYear;
  int get selectedCountryId => _countries
      .firstWhere((c) => c.abbreviation == _selectedCountryCode)
      .id;

  int get selectedRegionId => _regions
      .firstWhere((r) => r.abbreviation == _selectedRegionCode)
      .id ?? 0;
  bool _hasRegionalHolidays = false;
  bool get showRegionSelector => _hasRegionalHolidays;

  // Initialize
  Future<void> init() async {
    await loadCountries();
    await checkForRegionalHolidays();
    if (_hasRegionalHolidays) {
      await loadRegions();
    }
    await loadHolidays();
  }

  // Load data
  Future<void> loadCountries() async {
    _countries = await _db.getCountries();
    notifyListeners();
  }

  Future<void> loadRegions() async {
    if (_countries.isNotEmpty) {
      int countryId = _countries.firstWhere(
              (c) => c.abbreviation == _selectedCountryCode
      ).id;
      _regions = await _db.getRegionsByCountry(countryId);
      notifyListeners();
    }
  }

  Future<void> loadHolidays() async {
    if (_countries.isNotEmpty) {

      if(_regions.isEmpty)
      {
        _holidays = await _db.getHolidaysByYear(
          selectedCountryId,
          _selectedYear,
        );
      } else {
        _holidays = await _db.getHolidaysByYearAndRegion(
          selectedCountryId,
          selectedRegionId,
          _selectedYear,
        );
      }

      notifyListeners();
    }
  }

  Future<void> checkForRegionalHolidays() async {
    final countryId = selectedCountryId;
    final count = await _db.countNonGlobalHolidays(countryId, _selectedYear);
    _hasRegionalHolidays = count > 0;
    notifyListeners();
  }

  // Setters
  Future<void> setCountry(String countryCode) async {
    _selectedCountryCode = countryCode;

    await checkForRegionalHolidays();

    // Only load regions if there are non-global holidays
    if (_hasRegionalHolidays) {
      await loadRegions();
      if (_regions.isNotEmpty) {
        _selectedRegionCode = _regions.first.abbreviation;
      }
    } else {
      _regions = [];
      _selectedRegionCode = '';
    }

    await loadHolidays();
    notifyListeners();
  }

  void setRegion(String regionCode) async {
    _selectedRegionCode = regionCode;
    await loadHolidays();
    notifyListeners();
  }

  void setYear(int year) async {
    _selectedYear = year;
    await checkForRegionalHolidays();
    await loadHolidays();
    notifyListeners();
  }


  void setCountryCode(String countryCode) {
    _selectedCountryCode = countryCode;
  }

  void setRegionCode(String regionCode) {
    _selectedRegionCode = regionCode;
  }

  // Update your increment/decrement year methods to use setYear
  void incrementYear() {
    if(_selectedYear == MAX_YEAR)
    {
      return;
    }
    setYear(_selectedYear + 1);
  }

  void decrementYear() {
    if(_selectedYear == MIN_YEAR)
    {
      return;
    }
    setYear(_selectedYear - 1);
  }
}
