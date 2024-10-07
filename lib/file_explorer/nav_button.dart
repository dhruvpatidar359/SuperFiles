import 'package:flutter/material.dart';

class NavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const NavButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  _NavButtonState createState() => _NavButtonState();
}

class _NavButtonState extends State<NavButton> {
  bool _isHovered = false; // Track hover state

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: ListTile(
        leading: Icon(
          widget.icon,
          color: _isHovered
              ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.7) // Lightened on hover
              : Theme.of(context).colorScheme.primary, // Normal color
        ),
        title: Text(
          widget.label,
          style: TextStyle(
            color: _isHovered
                ? Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.7) // Lightened on hover
                : Theme.of(context).colorScheme.onSurface, // Normal color
          ),
        ),
        onTap: widget.onTap,
        tileColor: _isHovered
            ? Colors.grey.withOpacity(0.1) // Light background on hover
            : Colors.transparent, // Normal background
      ),
    );
  }
}
