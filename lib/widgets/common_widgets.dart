import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

void showAppToast(BuildContext context, String message, {bool success = false}) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 100,
      left: 20,
      right: 20,
      child: _ToastWidget(message: message, success: success),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(milliseconds: 2500), entry.remove);
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final bool success;
  const _ToastWidget({required this.message, required this.success});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: widget.success ? AppColors.green : AppColors.text,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Icon(widget.success ? Icons.check_circle_outline : Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.message, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Sora')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable App Bar with logo
class MediCallAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading;
  final String? title;

  const MediCallAppBar({super.key, this.actions, this.leading, this.title});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: AppColors.border,
      backgroundColor: AppColors.surface,
      leading: leading ?? (Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            )
          : null),
      title: title != null
          ? Text(title!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))
          : Row(
              children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Sora', color: AppColors.text),
                    children: [
                      TextSpan(text: 'Médi'),
                      TextSpan(text: 'Call', style: TextStyle(color: AppColors.green)),
                    ],
                  ),
                ),
              ],
            ),
      actions: actions,
    );
  }
}

// Doctor Avatar Widget
class DoctorAvatar extends StatelessWidget {
  final String initials;
  final Color bgColor;
  final Color textColor;
  final double size;
  final double fontSize;
  final double borderRadius;

  const DoctorAvatar({
    super.key,
    required this.initials,
    required this.bgColor,
    required this.textColor,
    this.size = 48,
    this.fontSize = 14,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: textColor, fontFamily: 'Sora'),
        ),
      ),
    );
  }
}

// Status Badge
class StatusBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const StatusBadge({super.key, required this.label, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}

// Card container
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: onTap != null ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: child,
      ),
    );
  }
}

// Green primary button
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isFullWidth;

  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.isFullWidth = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(label),
      ),
    );
  }
}
