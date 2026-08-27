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
  String _query = '';

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
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Search CSV',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      Expanded(
        child: FutureBuilder<List<List<String>>>(
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
            if (rows.isEmpty) {
              return const Center(child: Text('CSV file is empty'));
            }
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
                        label: _highlightedText(
                          index < rows.first.length ? rows.first[index] : '',
                        ),
                      ),
                    ),
                    rows: rows.skip(1).map(
                      (row) => DataRow(
                        cells: List.generate(
                          columnCount,
                          (index) => DataCell(
                            _highlightedText(
                              index < row.length ? row[index] : '',
                            ),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _highlightedText(String text) {
    if (_query.isEmpty) return Text(text);
    final spans = <InlineSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = _query.toLowerCase();
    var start = 0;
    while (true) {
      final match = lowerText.indexOf(lowerQuery, start);
      if (match < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (match > start) {
        spans.add(TextSpan(text: text.substring(start, match)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match, match + _query.length),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = match + _query.length;
    }
    return Text.rich(TextSpan(children: spans));
  }
}
