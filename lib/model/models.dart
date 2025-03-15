class Holiday {
  final int id;
  final String localName;
  final String englishName;
  final DateTime date;
  final bool global;
  final String types;
  final int countryId;

  Holiday({
    required this.id,
    required this.localName,
    required this.englishName,
    required this.date,
    required this.global,
    required this.types,
    required this.countryId,
  });
}

class Country {
  final int id;
  final String name;
  final String abbreviation;

  Country({required this.id, required this.name, required this.abbreviation});
}

class Region {
  final int id;
  final String name;
  final String abbreviation;
  final int countryId;

  Region(
      {required this.id,
        required this.name,
        required this.abbreviation,
        required this.countryId});
}