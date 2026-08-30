import 'package:flutter/material.dart';

/// A recursive, expandable node in a JSON navigation tree.
class JsonTreeNode extends StatelessWidget {
  const JsonTreeNode({
    super.key,
    this.name,
    required this.value,
    this.expanded = false,
    this.query = '',
  });

  final String? name;
  final Object? value;
  final bool expanded;
  final String query;

  @override
  Widget build(BuildContext context) {
    final prefix = name == null ? '' : '$name: ';
    final expandForSearch = query.isNotEmpty && _containsQuery(name, value);
    if (value is Map) {
      final entries = (value! as Map).entries.toList();
      return ExpansionTile(
        initiallyExpanded: expanded || expandForSearch,
        title: _highlightedText(context, '$prefix{${entries.length}}'),
        children: entries
            .map(
              (entry) => JsonTreeNode(
                name: '${entry.key}',
                value: entry.value,
                query: query,
              ),
            )
            .toList(),
      );
    }
    if (value is List) {
      final items = value! as List;
      return ExpansionTile(
        initiallyExpanded: expanded || expandForSearch,
        title: _highlightedText(context, '$prefix[${items.length}]'),
        children: List.generate(
          items.length,
          (index) =>
              JsonTreeNode(name: '[$index]', value: items[index], query: query),
        ),
      );
    }
    final color = value == null
        ? Colors.grey
        : value is bool
        ? Colors.purple
        : value is num
        ? Colors.blue
        : Colors.green.shade700;
    return ListTile(
      dense: true,
      title: _highlightedText(
        context,
        '$prefix${_label(value)}',
        baseColor: color,
      ),
    );
  }

  String _label(Object? value) => value is String ? '"$value"' : '$value';

  bool _containsQuery(String? name, Object? value) {
    final lowerQuery = query.toLowerCase();
    if (name?.toLowerCase().contains(lowerQuery) ?? false) return true;
    if (value is Map) {
      return value.entries.any(
        (entry) => _containsQuery('${entry.key}', entry.value),
      );
    }
    if (value is List) {
      return value.asMap().entries.any(
        (entry) => _containsQuery('[${entry.key}]', entry.value),
      );
    }
    return _label(value).toLowerCase().contains(lowerQuery);
  }

  Widget _highlightedText(
    BuildContext context,
    String text, {
    Color? baseColor,
  }) {
    if (query.isEmpty) return Text(text, style: TextStyle(color: baseColor));
    final spans = <InlineSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
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
          text: text.substring(match, match + query.length),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = match + query.length;
    }
    return Text.rich(
      TextSpan(
        style: TextStyle(color: baseColor),
        children: spans,
      ),
    );
  }
}
