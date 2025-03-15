import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/models.dart';
import '../provider/holiday_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// Main stateful widget for the Home Page.
class _HomePageState extends State<HomePage> {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();

    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    var selectedCountry = prefs.getString('selectedCountry');
    var selectedRegion = prefs.getString('selectedRegion');
    print(selectedCountry);
    print(selectedRegion);
    if(selectedCountry != null && selectedRegion != null)
    {
      Provider.of<HolidayProvider>(context, listen: false).setCountryCode(selectedCountry);
      Provider.of<HolidayProvider>(context, listen: false).setRegion(selectedRegion);
    }

    await Provider.of<HolidayProvider>(context, listen: false).init();

  }

  Future<void> _savePreferences() async {
    await prefs.setString('selectedCountry', Provider.of<HolidayProvider>(context, listen: false).selectedCountryCode);
    await prefs.setString('selectedRegion', Provider.of<HolidayProvider>(context, listen: false).selectedRegionCode);
  }

  // Dummy method to load holidays.
  // In your app, query the SQLite database (using sqflite) for holidays matching the selected country, region, and year.
  Future<void> _loadHolidays() async {
    // For example purposes, we create two dummy holidays.
    Provider.of<HolidayProvider>(context, listen: false).loadHolidays();
  }

  void _incrementYear() {
    Provider.of<HolidayProvider>(context, listen: false).incrementYear();
  }

  void _decrementYear() {
    Provider.of<HolidayProvider>(context, listen: false).decrementYear();
  }

  // Summary stats.
  int get totalHolidays => Provider.of<HolidayProvider>(context, listen: false).holidays.length;
  int get weekendHolidays => Provider.of<HolidayProvider>(context, listen: false).holidays.where((holiday) {
    int wd = holiday.date.weekday;
    return wd == DateTime.saturday || wd == DateTime.sunday;
  }).length;

  // Builds the calendar grid showing all 12 months (3 per row).
  Widget buildCalendar() {
    return Consumer<HolidayProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: EdgeInsets.all(3),
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1 / 1.17,
              children: List.generate(12, (index) {
                int month = index + 1;
                return Padding(
                  padding: EdgeInsets.all(3),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          monthName(month),
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight
                              .bold),
                        ),
                      ),
                      Expanded(
                        child: MonthCalendar(
                          year: provider.selectedYear,
                          month: month,
                          holidays: provider.holidays
                              .where((h) => h.date.month == month)
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          );
        }
    );
  }

  // Returns the full month name.
  String monthName(int month) {
    List<String> months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month];
  }

  // Format date as dd MMM.
  String formatDate(DateTime date) {
    return "${date.day} ${monthName(date.month).substring(0, 3)}";
  }

  // Returns abbreviated weekday name (Monday is first).
  String weekdayName(int weekday) {
    List<String> weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return weekdays[(weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HolidayProvider>(
        builder: (context, provider, child)
    {

      return Scaffold(
        appBar: AppBar(
          title: Text("Holiday Calendar"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // --- Top Controls ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Year selector with arrows
                    Column(
                      children: [
                        Text('Year', style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_left),
                              onPressed: _decrementYear,
                            ),
                            Text("${provider.selectedYear}",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.arrow_right),
                              onPressed: _incrementYear,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Country', style: TextStyle(fontSize: 12,
                              color: Colors.grey[600])),
                          DropdownButton<String>(
                            value: provider.selectedCountryCode,
                            isExpanded: true,
                            underline: SizedBox(),
                            icon: Icon(Icons.arrow_drop_down, color: Colors.tealAccent),
                            items: provider.countries
                                .map((country) =>
                                DropdownMenuItem<String>(
                                  value: country.abbreviation,
                                  child: Text(country.name,
                                      style: TextStyle(fontSize: 13)),
                                ))
                                .toList(),
                            onChanged: (value) async {
                              if (value != null) {
                                await provider.setCountry(value);
                                _savePreferences();
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 16),
                    if (provider.showRegionSelector)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Region', style: TextStyle(fontSize: 12,
                                color: Colors.grey[600])),
                            DropdownButton<String>(
                              value: provider.selectedRegionCode,
                              isExpanded: true,
                              underline: SizedBox(),
                              icon: Icon(Icons.arrow_drop_down, color: Colors.tealAccent),
                              items: provider.regions
                                  .map((region) =>
                                  DropdownMenuItem<String>(
                                    value: region.abbreviation,
                                    child: Text(region.name,
                                        style: TextStyle(fontSize: 13)),
                                  ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  provider.setRegion(value);
                                  _savePreferences();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // --- Calendar Grid ---
              buildCalendar(),
              // --- Summary Section ---
              Text("Public Holidays: $totalHolidays"),
              Text("Public Holidays on weekend: $weekendHolidays"),
              SizedBox(height: 16),
              // --- List of Holiday Cards ---
              HolidayList(holidays: provider.holidays)
            ],
          ),
        ),
      );
    });
  }
}

// A custom widget that displays a month calendar.
class MonthCalendar extends StatefulWidget {
  final int year;
  final int month;
  final List<Holiday> holidays;


  MonthCalendar(
      {required this.year, required this.month, required this.holidays});

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  bool showCalendarWeek = true;
  double weekdayTextSize = 8;
  double dayTextSize = 8;
  double calendarWeekTextSize = 8;

  int getWeekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat('D').format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = getWeekNumber(DateTime(date.year - 1, 12, 31));
    } else if (woy > 52) {
      woy = 1;
    }
    return woy;
  }

  @override
  Widget build(BuildContext context) {
    DateTime firstDayOfMonth = DateTime(widget.year, widget.month, 1);
    // Calculate leading empty cells. Weekdays in Dart: Monday=1 ... Sunday=7.
    int firstWeekday = firstDayOfMonth.weekday;
    int leadingEmptyCells = (firstWeekday + 6) % 7; // Adjust to make Monday first.
    int daysInMonth = DateTime(widget.year, widget.month + 1, 0).day;

    List<Widget> cells = [];

    if(showCalendarWeek)
    {
      // week number header
      cells.add(Container(
        alignment: Alignment.center,
        child: Text('CW',
            style: TextStyle(
                color: Colors.white.withAlpha(127),
                fontWeight: FontWeight.bold,
                fontSize: calendarWeekTextSize)),
      ));
    }

    // Weekday header row.
    List<String> weekdays = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"];
    for (String wd in weekdays) {
      cells.add(Container(
        alignment: Alignment.center,
        child: Text(wd,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: weekdayTextSize)),
      ));
    }

    // Current date for week number calculation
    DateTime currentDate = firstDayOfMonth.subtract(Duration(days: leadingEmptyCells));

    if(showCalendarWeek)
    {
      // Week number for the first row
      cells.add(Container(
        alignment: Alignment.center,
        child: Text(
          '${getWeekNumber(currentDate)}',
          style: TextStyle(
              color: Colors.white.withAlpha(127),
              fontSize: calendarWeekTextSize),
        ),
      ));
    }

    int currentWeek = getWeekNumber(currentDate);
    int dayCount = 0;

    // Leading empty cells.
    for (int i = 0; i < leadingEmptyCells; i++) {
      cells.add(Container());
      dayCount++;
    }

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    // Day cells.
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(widget.year, widget.month, day);
      bool isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      bool isHoliday = widget.holidays.any((holiday) =>
      holiday.date.year == date.year &&
          holiday.date.month == date.month &&
          holiday.date.day == date.day);
      // Highlight weekends: Saturday and Sunday.
      bool isWeekend = date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday;
      Color backgroundColor =
      isWeekend ? Colors.red.withValues(alpha: 0.15) : Colors.transparent;

      if(showCalendarWeek)
      {
        // Add week number at the start of each new week
        if (dayCount > 0 && date.weekday == DateTime.monday) {
          currentWeek = getWeekNumber(date);
          cells.add(Container(
            alignment: Alignment.center,
            child: Text(
              '$currentWeek',
              style: TextStyle(
                  color: Colors.white.withAlpha(127),
                  fontSize: calendarWeekTextSize),
            ),
          ));
        }
      }

      Widget dayWidget = Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isHoliday ? Colors.red.withValues(alpha: 0.8) : backgroundColor,
          borderRadius: BorderRadius.circular(isHoliday || isToday ? 10 : 0),
          border: isToday ? Border.all(
            color: Colors.orange, // Change to any color you want
            width: 1, // Set border width (small)
          ) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          "$day",
          style: TextStyle(color: Colors.white, fontSize: dayTextSize),
        ),
      );
      cells.add(dayWidget);
      dayCount++;
    }

    return GridView.count(
      crossAxisCount: showCalendarWeek ? 8 : 7,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: cells,
    );
  }
}

class HolidayList extends StatelessWidget {
  final List<Holiday> holidays;

  HolidayList({required this.holidays});

  @override
  Widget build(BuildContext context) {
    // Group holidays by month
    Map<int, List<Holiday>> groupedHolidays = {};

    for (var holiday in holidays) {
      int month = holiday.date.month;
      if (groupedHolidays.containsKey(month)) {
        groupedHolidays[month]!.add(holiday);
      } else {
        groupedHolidays[month] = [holiday];
      }
    }

    // Sort months
    List<int> sortedMonths = groupedHolidays.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: groupedHolidays.length,
        itemBuilder: (context, index) {
          int month = sortedMonths[index];
          String monthName = DateFormat('MMMM').format(DateTime(0, month));
          List<Holiday> holidaysForMonth = groupedHolidays[month]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                child: Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Holidays for the month
              ...holidaysForMonth.map((holiday) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(holiday.englishName, style: TextStyle(fontSize: 14)),
                    subtitle: Text(
                      holiday.localName,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    trailing: Text('${formatDateSimple(holiday.date)}'),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String formatDateSimple(DateTime date) {
    return DateFormat('d MMM').format(date);
  }
}
