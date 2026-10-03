import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_shared/mobile_shared.dart';
import '../../../home/presentation/widgets/staff_drawer.dart';
import '../cubit/staff_cubit.dart';
import '../widgets/scan_result_overlay.dart';

class StaffScannerScreen extends StatefulWidget {
  const StaffScannerScreen({super.key});

  @override
  State<StaffScannerScreen> createState() => _StaffScannerScreenState();
}

class _StaffScannerScreenState extends State<StaffScannerScreen> {
  late final MobileScannerController _scannerController;
  final TextEditingController _manualCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint('[QR_SCAN] StaffScannerScreen: initState');
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _scannerController.addListener(_onScannerStateChanged);
  }

  void _onScannerStateChanged() {
    final state = _scannerController.value;
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
    debugPrint('[QR_SCAN] StaffScannerScreen: dispose');
    _scannerController.removeListener(_onScannerStateChanged);
    _scannerController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  void _onScanDetect(BarcodeCapture capture) {
    debugPrint('[QR_SCAN] onDetect: ${capture.barcodes.length} barcode(s) found');
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      debugPrint('[QR_SCAN] Detected barcode: $code (format: ${barcode.format})');
      if (code != null && code.isNotEmpty) {
        context.read<StaffCubit>().checkin(code);
        break;
      }
    }
  }

  void _submitManualCode() {
    final code = _manualCodeController.text.trim();
    if (code.isNotEmpty) {
      debugPrint('[QR_SCAN] Manual ticket submitted: $code');
      context.read<StaffCubit>().checkin(code);
      _manualCodeController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: l10n.scanTicket,
      drawer: const StaffDrawer(),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.monitorSmartphone),
          onPressed: () async {
            debugPrint('[QR_SCAN] Navigating to /ticket-sale, stopping camera');
            // Dừng camera trước khi chuyển trang để tránh lỗi mouse_tracker assertion do MobileScanner
            await _scannerController.stop();
            if (context.mounted) {
              await context.push('/ticket-sale');
              // Khởi động lại camera khi quay lại màn hình này
              if (mounted) {
                debugPrint('[QR_SCAN] Returned to scanner, restarting camera');
                _scannerController.start();
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
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
                      fit: BoxFit.cover,
                      onDetect: _onScanDetect,
                      onDetectError: (error, stackTrace) {
                        debugPrint('[QR_SCAN] [ERROR] onDetectError: $error\n$stackTrace');
                      },
                      placeholderBuilder: (context) {
                        debugPrint('[QR_SCAN] placeholderBuilder: camera initializing or stopped');
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error) {
                        final isPermissionDenied = error.errorCode == MobileScannerErrorCode.permissionDenied;
                        final isUnsupported = error.errorCode == MobileScannerErrorCode.unsupported;

                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPermissionDenied ? Icons.no_photography_outlined : Icons.error_outline,
                                  color: colorScheme.error,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isPermissionDenied
                                      ? l10n.cameraPermissionRequired
                                      : (isUnsupported ? l10n.cameraUnsupported : l10n.errorOccurred),
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (isPermissionDenied) ...[
                                  const SizedBox(height: 16),
                                  FilledButton.icon(
                                    onPressed: () => _scannerController.start(),
                                    icon: const Icon(Icons.camera_alt, size: 20),
                                    label: Text(l10n.grantPermission),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: colorScheme.primary,
                                      foregroundColor: colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Scanner Viewfinder Overlay
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.primary, width: 3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          _ScannerButton(
                            icon: Icons.flash_on,
                            onTap: () {
                              debugPrint('[QR_SCAN] Torch button tapped');
                              _scannerController.toggleTorch();
                            },
                          ),
                          const SizedBox(width: 8),
                          _ScannerButton(
                            icon: Icons.flip_camera_ios,
                            onTap: () {
                              debugPrint('[QR_SCAN] Switch camera button tapped');
                              _scannerController.switchCamera();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Manual Input Section at Bottom
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.manualTicketInput,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _manualCodeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'TKT-...',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              prefixIcon: const Icon(Icons.keyboard_outlined, size: 20),
                            ),
                            onSubmitted: (_) => _submitManualCode(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: _submitManualCode,
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            child: Text(
                              l10n.verifyTicket,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Scan Result Overlay
          Positioned(
            bottom: 100,
            left: 16,
            right: 16,
            child: BlocBuilder<StaffCubit, StaffState>(
              builder: (context, state) {
                if (state is StaffCheckinSuccess) {
                  final seat = state.ticket.seatLabel ?? state.ticket.seatId;
                  return ScanResultOverlay(
                    isSuccess: true,
                    message: l10n.scanSuccessDetail(l10n.scanSuccess, seat, state.ticket.qrCode),
                    onDismiss: () => context.read<StaffCubit>().reset(),
                  );
                }
                if (state is StaffCheckinError) {
                  return ScanResultOverlay(
                    isSuccess: false,
                    isWarning: state.isWarning,
                    message: state.message,
                    onDismiss: () => context.read<StaffCubit>().reset(),
                  );
                }
                if (state is StaffScanning) {
                  return const Center(child: CircularProgressIndicator());
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple tappable icon button that avoids mouse_tracker hover events.
/// Used inside MobileScanner view where continuous device updates cause
/// [IconButton] hover tracking to crash in debug mode.
class _ScannerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ScannerButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }
}
