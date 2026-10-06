import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_shared/mobile_shared.dart';

import '../cubit/staff_cubit.dart';
import '../widgets/scan_result_sheet.dart';

class StaffScannerScreen extends StatefulWidget {
  const StaffScannerScreen({super.key});

  @override
  State<StaffScannerScreen> createState() => _StaffScannerScreenState();
}

class _StaffScannerScreenState extends State<StaffScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  final TextEditingController _manualCodeController = TextEditingController();
  late final AnimationController _laserController;
  bool _isNavigatingToTicketSale = false;
  bool _isRetryingCamera = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _scannerController.addListener(_onScannerStateChanged);
  }

  void _onScannerStateChanged() {
    final state = _scannerController.value;
    if (state.isInitialized && state.isRunning && !_laserController.isAnimating) {
      _laserController.repeat(reverse: true);
    } else if ((!state.isRunning || state.error != null) && _laserController.isAnimating) {
      _laserController.stop();
    }
    debugPrint(
      '[QR_SCAN] State changed -> '
      'isInitialized: ${state.isInitialized}, '
      'isRunning: ${state.isRunning}, '
      'isStarting: ${state.isStarting}, '
      'cameraDirection: ${state.cameraDirection}, '
      'torchState: ${state.torchState}, '
      'size: ${state.size}, '
      'error: ${state.error?.errorCode.name} (${state.error?.errorDetails?.message ?? "no message"})',
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    debugPrint('[QR_SCAN] StaffScannerScreen: dispose');
    _scannerController.removeListener(_onScannerStateChanged);
    _scannerController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  void _onScanDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        context.read<StaffCubit>().checkin(code);
        break;
      }
    }
  }

  void _submitManualCode() {
    final code = _manualCodeController.text.trim();
    if (code.isNotEmpty) {
      context.read<StaffCubit>().checkin(code);
      _manualCodeController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _retryScanner() async {
    if (_isRetryingCamera) return;

    setState(() => _isRetryingCamera = true);
    try {
      await _scannerController.start();
    } on MobileScannerException {
      // Handled by MobileScanner error builder
    } finally {
      if (mounted) {
        setState(() => _isRetryingCamera = false);
      }
    }
  }

  void _showResultModal(
    StaffState state,
    BuildContext context,
    AppLocalizations l10n,
  ) {
    if (state is StaffCheckinSuccess) {
      HapticFeedback.lightImpact();
      final ticket = state.ticket;
      final seatStr = ticket.seatLabel ?? ticket.seatId;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetCtx) => ScanResultSheet(
          status: ScanStatusType.valid,
          movieTitle: ticket.movieTitle ?? 'Cineplex Movie',
          roomName: ticket.roomName,
          cinemaName: ticket.cinemaName ?? 'Cineplex',
          showtime: ticket.startTime,
          seatLabel: seatStr,
          customerName: ticket.customerName,
          ticketCode: ticket.qrCode,
          bookingCode: ticket.bookingCode,
          message: l10n.scanSuccess,
          checkinTime: DateTime.now(),
          onScanNext: () {
            Navigator.pop(bottomSheetCtx);
            context.read<StaffCubit>().reset();
          },
          onClose: () {
            Navigator.pop(bottomSheetCtx);
            context.read<StaffCubit>().reset();
          },
        ),
      );
    } else if (state is StaffCheckinError) {
      HapticFeedback.heavyImpact();
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (bottomSheetCtx) => ScanResultSheet(
          status: state.isWarning
              ? ScanStatusType.alreadyUsed
              : ScanStatusType.invalid,
          message: state.message,
          checkinTime: DateTime.now(),
          onScanNext: () {
            Navigator.pop(bottomSheetCtx);
            context.read<StaffCubit>().reset();
          },
          onClose: () {
            Navigator.pop(bottomSheetCtx);
            context.read<StaffCubit>().reset();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final colors = CineplexColors.of(context);

    return BlocListener<StaffCubit, StaffState>(
      listener: (context, state) {
        if (state is StaffCheckinSuccess || state is StaffCheckinError) {
          _showResultModal(state, context, l10n);
        }
      },
      child: AppScaffold(
        title: l10n.scanTicket,
        drawer: const StaffDrawer(),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.monitorSmartphone),
            tooltip: l10n.counterSale,
            onPressed: _isNavigatingToTicketSale
                ? null
                : () async {
                    setState(() => _isNavigatingToTicketSale = true);
                    try {
                      await _scannerController.stop();
                      if (!context.mounted) return;
                      await context.push('/pos');
                      if (!mounted) return;
                      await _scannerController.start();
                    } finally {
                      if (mounted) {
                        setState(() => _isNavigatingToTicketSale = false);
                      }
                    }
                  },
          ),
        ],
        body: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                // Scanner Camera View
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onScanDetect,
                        placeholderBuilder: (context) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.cameraInitializing,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        errorBuilder: (context, error) {
                          final isPermission =
                              error.errorCode ==
                              MobileScannerErrorCode.permissionDenied;
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPermission
                                        ? Icons.videocam_off_outlined
                                        : Icons.error_outline_rounded,
                                    size: 48,
                                    color: colors.error,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    isPermission
                                        ? l10n.cameraPermissionDenied
                                        : l10n.cameraError,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.cameraErrorHint,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AppButton(
                                    text: l10n.retry,
                                    width: null,
                                    isLoading: _isRetryingCamera,
                                    onPressed: _isRetryingCamera
                                        ? null
                                        : _retryScanner,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Rich Viewfinder with Corner Brackets & Laser Line
                      ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _scannerController,
                        builder: (context, state, child) {
                          if (!state.isInitialized || state.error != null) {
                            return const SizedBox.shrink();
                          }
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Viewfinder Box with 4 Corner Brackets
                              CustomPaint(
                                size: const Size(260, 260),
                                painter: _ScannerCornerPainter(
                                  color: colorScheme.primary,
                                  cornerLength: 32,
                                  strokeWidth: 4,
                                ),
                              ),
                              // Laser Sweep Line
                              SizedBox(
                                width: 240,
                                height: 240,
                                child: AnimatedBuilder(
                                  animation: _laserController,
                                  builder: (context, child) {
                                    return Align(
                                      alignment: Alignment(
                                        0,
                                        _laserController.value * 2 - 1,
                                      ),
                                      child: Container(
                                        height: 2.5,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              colorScheme.primary.withValues(
                                                alpha: 0.1,
                                              ),
                                              colorScheme.primary,
                                              colorScheme.primary.withValues(
                                                alpha: 0.1,
                                              ),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colorScheme.primary
                                                  .withValues(alpha: 0.6),
                                              blurRadius: 6,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // Floating Top Controls (Torch & Flip)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: ValueListenableBuilder<MobileScannerState>(
                          valueListenable: _scannerController,
                          builder: (context, state, child) {
                            if (!state.isInitialized || state.error != null) {
                              return const SizedBox.shrink();
                            }
                            return Row(
                              children: [
                                _ScannerGlassButton(
                                  icon: _isTorchOn
                                      ? Icons.flash_on
                                      : Icons.flash_off,
                                  isActive: _isTorchOn,
                                  activeColor: colors.warning,
                                  onTap: () async {
                                    await _scannerController.toggleTorch();
                                    setState(() => _isTorchOn = !_isTorchOn);
                                  },
                                ),
                                const SizedBox(width: 10),
                                _ScannerGlassButton(
                                  icon: Icons.flip_camera_ios_outlined,
                                  isActive: false,
                                  onTap: () =>
                                      _scannerController.switchCamera(),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Manual Input Section at Bottom
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(top: BorderSide(color: colors.borderSubtle)),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _manualCodeController,
                          textCapitalization: TextCapitalization.characters,
                          style: TextStyle(color: colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: l10n.manualCodeHint,
                            hintStyle: TextStyle(color: colors.textMuted),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colors.borderSubtle,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _submitManualCode(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AppButton(
                        text: l10n.verifyTicket,
                        onPressed: _submitManualCode,
                        width: 105,
                        backgroundColor: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Loading overlay during check-in API call
            BlocBuilder<StaffCubit, StaffState>(
              buildWhen: (prev, current) =>
                  (prev is StaffScanning) != (current is StaffScanning),
              builder: (context, state) {
                if (state is StaffScanning) {
                  return Container(
                    color: colorScheme.scrim.withValues(alpha: 0.45),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerCornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  const _ScannerCornerPainter({
    required this.color,
    this.cornerLength = 32,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Top-Left
    canvas.drawLine(Offset(0, cornerLength), const Offset(0, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(cornerLength, 0), paint);

    // Top-Right
    canvas.drawLine(Offset(w - cornerLength, 0), Offset(w, 0), paint);
    canvas.drawLine(Offset(w, 0), Offset(w, cornerLength), paint);

    // Bottom-Left
    canvas.drawLine(Offset(0, h - cornerLength), Offset(0, h), paint);
    canvas.drawLine(Offset(0, h), Offset(cornerLength, h), paint);

    // Bottom-Right
    canvas.drawLine(Offset(w - cornerLength, h), Offset(w, h), paint);
    canvas.drawLine(Offset(w, h), Offset(w, h - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerCornerPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _ScannerGlassButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ScannerGlassButton({
    required this.icon,
    required this.isActive,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlight = activeColor ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? highlight.withValues(alpha: 0.3)
              : colorScheme.surface.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? highlight
                : colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? highlight : colorScheme.onSurface,
        ),
      ),
    );
  }
}
