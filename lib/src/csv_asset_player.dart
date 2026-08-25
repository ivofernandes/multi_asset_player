import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'asset_message.dart';

/// Displays CSV data in a horizontally and vertically scrollable table.
class CsvAssetPlayer extends StatefulWidget {
  const CsvAssetPlayer({super.key, required this.asset, this.bundle});

  final String asset;
  final AssetBundle? bundle;

  @override
  State<CsvAssetPlayer> createState() => _CsvAssetPlayerState();
}

class _CsvAssetPlayerState extends State<CsvAssetPlayer> {
  late final Future<List<List<String>>> _rows = _loadRows();

  Future<List<List<String>>> _loadRows() async {
    final text = await (widget.bundle ?? rootBundle).loadString(widget.asset);
    return const LineSplitter()
        .convert(text)
        .where((line) => line.isNotEmpty)
        .map(_parseCsvRow)
        .toList();
  }

  List<String> _parseCsvRow(String row) {
    final cells = <String>[];
    final value = StringBuffer();
    var quoted = false;
    for (var index = 0; index < row.length; index++) {
      final character = row[index];
      if (character == '"') {
        if (quoted && index + 1 < row.length && row[index + 1] == '"') {
          value.write('"');
          index++;
        } else {
          quoted = !quoted;
        }
      } else if (character == ',' && !quoted) {
        cells.add(value.toString());
        value.clear();
      } else {
        value.write(character);
      }
    }
    cells.add(value.toString());
    return cells;
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<List<List<String>>>(
    future: _rows,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return AssetMessage(
          icon: Icons.error_outline,
          message: 'Unable to load ${widget.asset}',
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final rows = snapshot.data!;
      if (rows.isEmpty) return const Center(child: Text('CSV file is empty'));
      final columnCount = rows
          .map((row) => row.length)
          .reduce((a, b) => a > b ? a : b);
      return Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              columns: List.generate(
                columnCount,
                (index) => DataColumn(
                  label: Text(
                    index < rows.first.length ? rows.first[index] : '',
                  ),
                ),
              ),
              rows: rows.skip(1).map(
                (row) => DataRow(
                  cells: List.generate(
                    columnCount,
                    (index) => DataCell(
                      Text(index < row.length ? row[index] : ''),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        ),
      );
    },
  );
}
