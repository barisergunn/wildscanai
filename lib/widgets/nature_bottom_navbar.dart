import 'package:flutter/material.dart';

class NatureBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NatureNavBarItem> items;

  const NatureBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // 70'ten 56'ya düşürüldü
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1), // Modern indigo
            Color(0xFF8B5CF6), // Modern violet
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // vertical padding 4
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == currentIndex;
            
            return GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), // padding azaltıldı
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: isSelected ? 40 : 32, // 48/40 -> 40/32
                      height: isSelected ? 40 : 32,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.18)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(isSelected ? 20 : 16),
                        border: isSelected
                            ? Border.all(color: Colors.white.withOpacity(0.25), width: 1.5)
                            : null,
                      ),
                      child: Icon(
                        item.icon,
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                        size: isSelected ? 24 : 22, // 26/22 -> 24/22
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NatureNavBarItem {
  final IconData icon;
  final String label;

  const NatureNavBarItem({
    required this.icon,
    required this.label,
  });
} 