import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_shared/mobile_shared.dart';
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
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      title: l10n.scanTicket,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.monitorSmartphone),
          tooltip: l10n.counterSale,
          onPressed: () => context.push('/ticket-sale'),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: l10n.logout,
          onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
        ),
      ],
      body: Stack(
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

                    // Controls (Flash & Switch Camera)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Row(
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.flash_on),
                            onPressed: () => _scannerController.toggleTorch(),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.flip_camera_ios),
                            onPressed: () => _scannerController.switchCamera(),
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
                        AppButton(
                          text: l10n.verifyTicket,
                          onPressed: _submitManualCode,
                          width: null, // wrap content
                          backgroundColor: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Scan Result Overlay
          BlocBuilder<StaffCubit, StaffState>(
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
        ],
      ),
    );
  }
}
