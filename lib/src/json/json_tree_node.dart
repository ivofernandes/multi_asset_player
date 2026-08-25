import 'package:flutter/material.dart';

/// A recursive, expandable node in a JSON navigation tree.
class JsonTreeNode extends StatelessWidget {
  const JsonTreeNode({
    super.key,
    this.name,
    required this.value,
    this.expanded = false,
  });

  final String? name;
  final Object? value;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final prefix = name == null ? '' : '$name: ';
    if (value is Map) {
      final entries = (value! as Map).entries.toList();
      return ExpansionTile(
        initiallyExpanded: expanded,
        title: Text('$prefix{${entries.length}}'),
        children: entries
            .map(
              (entry) => JsonTreeNode(
                name: '${entry.key}',
                value: entry.value,
              ),
            )
            .toList(),
      );
    }
    if (value is List) {
      final items = value! as List;
      return ExpansionTile(
        initiallyExpanded: expanded,
        title: Text('$prefix[${items.length}]'),
        children: List.generate(
          items.length,
          (index) => JsonTreeNode(name: '[$index]', value: items[index]),
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
      title: Text.rich(
        TextSpan(
          children: [
            if (name != null) TextSpan(text: '$name: '),
            TextSpan(text: _label(value), style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }

  String _label(Object? value) => value is String ? '"$value"' : '$value';
}
