import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/shipper_model/IncomeEntry.dart';
import '../../../service/shipper_service/Profile/chart.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  // Data source
  final List<int> _years = List.generate(6, (i) =>
  DateTime
      .now()
      .year - 2 + i);
  final List<int> _weeks = List.generate(52, (i) => i + 1);

  // State filters
  int _selectedYear = DateTime
      .now()
      .year;
  DateTime _selectedDate = DateTime.now();
  int _selectedWeek = 1;

  // Future để fetch data
  Future<List<IncomeEntry>>? _futureIncome;

  @override
  void initState() {
    super.initState();
    _selectedWeek = _weekOfYear(_selectedDate);
    _fetchData();
  }

  int _weekOfYear(DateTime date) {
    final firstJan = DateTime(date.year, 1, 1);
    final days = date
        .difference(firstJan)
        .inDays;
    return (days / 7).ceil() + 1;
  }

  void _fetchData() {
    setState(() {
      _futureIncome = getIncomeByFilters(
        year:      _selectedYear,
        date:      _selectedDate,
        week:      _selectedWeek,
        shipperId: 1,    // ← ví dụ shipper_id = 1
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thu nhập')),
      body: Column(
        children: [
          // ---------- Row filters ----------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Năm
                  DropdownButton<int>(
                    value: _selectedYear,
                    items: _years
                        .map((y) =>
                        DropdownMenuItem(
                          value: y,
                          child: Text('Năm $y'),
                        ))
                        .toList(),
                    onChanged: (y) {
                      if (y == null) return;
                      setState(() => _selectedYear = y);
                      _fetchData();
                    },
                  ),
                  const SizedBox(width: 24),

                  // Ngày
                  TextButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      'Ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(_selectedYear - 1),
                        lastDate: DateTime(_selectedYear + 1),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _selectedWeek = _weekOfYear(picked);
                        });
                        _fetchData();
                      }
                    },
                  ),
                  const SizedBox(width: 24),

                  // Tuần
                  DropdownButton<int>(
                    value: _selectedWeek,
                    items: _weeks
                        .map((w) =>
                        DropdownMenuItem(
                          value: w,
                          child: Text('Tuần $w'),
                        ))
                        .toList(),
                    onChanged: (w) {
                      if (w == null) return;
                      setState(() => _selectedWeek = w);
                      _fetchData();
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(),

          // ---------- Kết quả ----------
          Expanded(
            child: FutureBuilder<List<IncomeEntry>>(
              future: _futureIncome,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }
                final list = snapshot.data ?? [];
                if (list.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu thu nhập'));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final entry = list[i];
                    final date = DateTime.parse(entry.day);
                    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
                    return ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: Text('Ngày $formattedDate'),
                      subtitle: Text('Thu nhập: ${entry.income.toStringAsFixed(
                          2)}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}