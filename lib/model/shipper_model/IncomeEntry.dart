class IncomeEntry {
  final String day;
  final double income;
  IncomeEntry({required this.day, required this.income});
  @override
  String toString() => '[$day] thu_nhap=$income';
}
