import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/screens/check%20IN-OUT/bloc/check_in_bloc.dart';

class CheckInCheckOutCard extends StatelessWidget {
  final CheckInState state;
  final int employeeId;
  final String createdBy;

  const CheckInCheckOutCard({
    super.key,
    required this.state,
    required this.employeeId,
    required this.createdBy,
  });



  void _onCheckIn(BuildContext context) {
    if (state.isCheckedIn ||
        state.loadingStatus == CheckInLoadingStatus.loading) {
      return;
    }

    context.read<CheckInBloc>().add(
          PerformCheckIn(
            employeeId: employeeId,
            createdBy: createdBy,
            captureImage: true,
            imageRequired: false,
            startTimer: true,
          ),
        );
  }

  void _onCheckOut(BuildContext context) {
    if (!state.isCheckedIn ||
        state.loadingStatus == CheckInLoadingStatus.loading) {
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Check Out'),
        content: Text(
          'Are you sure you want to check out?\n\nWorked time: ${_formatDuration(state.elapsedTime)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CheckInBloc>().add(
                    PerformCheckOut(
                      captureImage: true,
                      imageRequired: false, // Set to true if image is mandatory
                      updatedBy: createdBy,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final elapsed = state.elapsedTime;
    final hours = elapsed.inHours.toString().padLeft(2, '0');
    final minutes = (elapsed.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _decoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          const Text(
            'Working Time',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // Timer Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timeBox(hours),
              _colon(),
              _timeBox(minutes),
              _colon(),
              _timeBox(seconds),
            ],
          ),

          const SizedBox(height: 12),

          // Status Message
          if (state.isCheckedIn)
            Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
                const SizedBox(height: 4),
                const Text(
                  'You are checked in',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (state.checkInTime != null)
                  Text(
                    'Since ${_formatTime(state.checkInTime!)}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),

          // Error Message
          if (state.errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          if (!state.isCheckedIn)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.loadingStatus == CheckInLoadingStatus.loading
                    ? null
                    : () => _onCheckIn(context),
                icon: state.loadingStatus == CheckInLoadingStatus.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  state.loadingStatus == CheckInLoadingStatus.loading
                      ? 'Checking In...'
                      : 'Check In',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            )
          else
            // Check-Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.loadingStatus == CheckInLoadingStatus.loading
                    ? null
                    : () => _onCheckOut(context),
                icon: state.loadingStatus == CheckInLoadingStatus.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.logout),
                label: Text(
                  state.loadingStatus == CheckInLoadingStatus.loading
                      ? 'Checking Out...'
                      : 'Check Out',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

          // Check-out info
          if (state.checkOutTime != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Checked out at ${_formatTime(state.checkOutTime!)}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────

  Widget _timeBox(String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );

  Widget _colon() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          ':',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );

  BoxDecoration _decoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}