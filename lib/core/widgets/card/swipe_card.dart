import 'package:flutter/material.dart';

class SwipeActionButton extends StatefulWidget {
  final bool isCheckedIn;
  final bool isLoading;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const SwipeActionButton({
    super.key,
    required this.isCheckedIn,
    required this.isLoading,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

class _SwipeActionButtonState extends State<SwipeActionButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  bool _isDragging = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (widget.isLoading) return;

    setState(() {
      _isDragging = true;
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxWidth);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxWidth) {
    if (widget.isLoading) return;

    // Check if dragged past 70% threshold
    if (_dragPosition > maxWidth * 0.7) {
      setState(() => _dragPosition = maxWidth);

      // Trigger action after animation
      Future.delayed(const Duration(milliseconds: 200), () {
        if (widget.isCheckedIn) {
          widget.onCheckOut();
        } else {
          widget.onCheckIn();
        }
      });
    } else {
      // Reset if not dragged enough
      setState(() {
        _dragPosition = 0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - 72;
        final progress = _dragPosition / maxDrag;

        return Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.isCheckedIn
                  ? [const Color(0xFFFF6B6B), const Color(0xFFEE5A6F)]
                  : [
                      const Color.fromARGB(255, 8, 94, 243),
                      const Color.fromARGB(255, 172, 56, 239),
                    ],
            ),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color:
                    (widget.isCheckedIn
                            ? const Color(0xFFFF6B6B)
                            : const Color(0xFF11998E))
                        .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (!_isDragging)
                AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0),
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0),
                          ],
                          stops: [
                            _shimmerController.value - 0.3,
                            _shimmerController.value,
                            _shimmerController.value + 0.3,
                          ],
                        ),
                      ),
                    );
                  },
                ),

              AnimatedContainer(
                duration: _isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: _dragPosition + 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(32),
                ),
              ),

              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: progress < 0.5 ? 1.0 : 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.isCheckedIn
                            ? Icons.logout_rounded
                            : Icons.login_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isCheckedIn
                            ? 'Slide to Check Out'
                            : 'Slide to Check In',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Success text
              Center(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: progress >= 0.7 ? 1.0 : 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.isCheckedIn
                            ? 'Checking Out...'
                            : 'Checking In...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: _isDragging
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                left: _dragPosition,
                top: 4,
                bottom: 4,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) =>
                      _onHorizontalDragUpdate(details, maxDrag),
                  onHorizontalDragEnd: (details) =>
                      _onHorizontalDragEnd(details, maxDrag),
                  child: Container(
                    width: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: widget.isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF11998E),
                                ),
                              ),
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward_rounded,
                            color: widget.isCheckedIn
                                ? const Color(0xFFFF6B6B)
                                : const Color(0xFF11998E),
                            size: 28,
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
