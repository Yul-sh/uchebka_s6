import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int size;
  final bool hasPrevious;
  final bool hasNext;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onSize;

  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.size,
    required this.hasPrevious,
    required this.hasNext,
    required this.onPage,
    required this.onSize,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            IconButton(
              tooltip: 'Первая страница',
              onPressed: hasPrevious ? () => onPage(1) : null,
              icon: const Icon(Icons.first_page),
            ),
            IconButton(
              tooltip: 'Предыдущая',
              onPressed: hasPrevious ? () => onPage(page - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text('Страница $page из $totalPages · $total записей'),
            IconButton(
              tooltip: 'Следующая',
              onPressed: hasNext ? () => onPage(page + 1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
            IconButton(
              tooltip: 'Последняя страница',
              onPressed: hasNext ? () => onPage(totalPages) : null,
              icon: const Icon(Icons.last_page),
            ),
            const SizedBox(width: 8),
            const Text('На странице'),
            DropdownButton<int>(
              value: const [10, 25, 50].contains(size) ? size : 10,
              items: const [
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 25, child: Text('25')),
                DropdownMenuItem(value: 50, child: Text('50')),
              ],
              onChanged: (value) {
                if (value != null) onSize(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
