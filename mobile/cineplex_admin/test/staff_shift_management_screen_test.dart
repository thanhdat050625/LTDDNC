import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class FakeShiftRepository implements ShiftRepository {
  @override
  Future<List<ShiftModel>> getAllShifts() async => [
        const ShiftModel(id: 1, name: 'Ca sáng', startTime: '08:00', endTime: '14:00', isActive: true),
        const ShiftModel(id: 2, name: 'Ca chiều', startTime: '14:00', endTime: '20:00', isActive: true),
        const ShiftModel(id: 3, name: 'Ca tối / đêm', startTime: '20:00', endTime: '02:00', isActive: true),
      ];

  @override
  Future<List<StaffScheduleModel>> getSchedules({
    int? cinemaId,
    int? staffId,
    String? startDate,
    String? endDate,
  }) async => [
        const StaffScheduleModel(
          id: 101,
          staffId: 1,
          staffName: 'Nguyễn Văn A',
          staffEmail: 'a@cineplex.vn',
          cinemaId: 1,
          cinemaName: 'CINEPLEX Đà Nẵng',
          shiftId: 1,
          shiftName: 'Ca sáng',
          startTime: '08:00',
          endTime: '14:00',
          workDate: '2026-10-10',
          assignedRole: 'TICKET_COUNTER',
          status: 'SCHEDULED',
        ),
        const StaffScheduleModel(
          id: 102,
          staffId: 2,
          staffName: 'Trần Thị B',
          staffEmail: 'b@cineplex.vn',
          cinemaId: 1,
          cinemaName: 'CINEPLEX Đà Nẵng',
          shiftId: 1,
          shiftName: 'Ca sáng',
          startTime: '08:00',
          endTime: '14:00',
          workDate: '2026-10-10',
          assignedRole: 'SCANNER_GATE',
          status: 'SCHEDULED',
        ),
      ];

  @override
  Future<List<StaffScheduleModel>> getMySchedule({String? startDate, String? endDate}) async => [];

  @override
  Future<StaffScheduleModel> createSchedule(Map<String, dynamic> data) async => const StaffScheduleModel(
        id: 999,
        staffId: 1,
        staffName: 'Staff',
        staffEmail: 's@test.com',
        cinemaId: 1,
        cinemaName: 'Cinema',
        shiftId: 1,
        shiftName: 'Ca sáng',
        startTime: '08:00',
        endTime: '16:00',
        workDate: '2026-10-10',
        assignedRole: 'GENERAL',
        status: 'SCHEDULED',
      );

  @override
  Future<StaffScheduleModel> updateSchedule(int id, Map<String, dynamic> data) async => const StaffScheduleModel(
        id: 999,
        staffId: 1,
        staffName: 'Staff',
        staffEmail: 's@test.com',
        cinemaId: 1,
        cinemaName: 'Cinema',
        shiftId: 1,
        shiftName: 'Ca sáng',
        startTime: '08:00',
        endTime: '16:00',
        workDate: '2026-10-10',
        assignedRole: 'GENERAL',
        status: 'SCHEDULED',
      );

  @override
  Future<bool> deleteSchedule(int id) async => true;

  @override
  Future<void> bulkSyncSchedules(Map<String, dynamic> data) async {}
}

class FakeStaffShiftManagementCubit extends Cubit<StaffShiftManagementState>
    implements StaffShiftManagementCubit {
  FakeStaffShiftManagementCubit(StaffShiftManagementState initialState) : super(initialState);

  @override
  Future<void> loadInitialData({int? cinemaId, DateTime? date}) async {}

  @override
  void selectCinema(int cinemaId) {}

  @override
  void selectDate(DateTime date) {}

  @override
  Future<bool> createSchedule({
    required int staffId,
    required int cinemaId,
    required int shiftId,
    required String workDate,
    required String assignedRole,
    String? note,
  }) async => true;

  @override
  Future<bool> createMultipleSchedules({
    required List<int> staffIds,
    required int cinemaId,
    required int shiftId,
    required String workDate,
    required String assignedRole,
    String? note,
  }) async => true;

  @override
  Future<bool> updateSchedule(int id, Map<String, dynamic> data) async => true;

  @override
  Future<bool> deleteSchedule(int id) async => true;

  @override
  Future<bool> syncSchedules({
    required int cinemaId,
    required List<int> shiftIds,
    required List<int> staffIds,
    required List<String> dates,
    required List<int> initialShiftIds,
    required List<int> initialStaffIds,
  }) async => true;
}

void main() {
  final sampleCinemas = [
    const CinemaModel(
      id: 1,
      name: 'CINEPLEX Đà Nẵng',
      address: '123 Lê Duẩn',
      phone: '0123456789',
      email: 'dn@cineplex.vn',
      status: 'ACTIVE',
    ),
  ];

  final sampleShifts = [
    const ShiftModel(id: 1, name: 'Ca sáng', startTime: '08:00', endTime: '16:00', isActive: true),
    const ShiftModel(id: 2, name: 'Ca chiều', startTime: '16:00', endTime: '23:00', isActive: true),
  ];

  final List<UserModel> sampleStaff = [
    const UserModel(id: 1, fullName: 'Nguyễn Văn A', email: 'a@cineplex.vn', role: 'STAFF', status: 'ACTIVE', cinemaId: 1),
    const UserModel(id: 2, fullName: 'Trần Thị B', email: 'b@cineplex.vn', role: 'STAFF', status: 'ACTIVE', cinemaId: 1),
    const UserModel(id: 3, fullName: 'Lê Văn C', email: 'c@cineplex.vn', role: 'STAFF', status: 'ACTIVE', cinemaId: 2),
  ];

  final sampleSchedules = [
    const StaffScheduleModel(
      id: 101,
      staffId: 1,
      staffName: 'Nguyễn Văn A',
      staffEmail: 'a@cineplex.vn',
      cinemaId: 1,
      cinemaName: 'CINEPLEX Đà Nẵng',
      shiftId: 1,
      shiftName: 'Ca sáng',
      startTime: '08:00',
      endTime: '16:00',
      workDate: '2026-10-10',
      assignedRole: 'TICKET_COUNTER',
      status: 'SCHEDULED',
    ),
    const StaffScheduleModel(
      id: 102,
      staffId: 2,
      staffName: 'Trần Thị B',
      staffEmail: 'b@cineplex.vn',
      cinemaId: 1,
      cinemaName: 'CINEPLEX Đà Nẵng',
      shiftId: 1,
      shiftName: 'Ca sáng',
      startTime: '08:00',
      endTime: '16:00',
      workDate: '2026-10-10',
      assignedRole: 'SCANNER_GATE',
      status: 'SCHEDULED',
    ),
  ];

  Widget buildTestWidget({
    required Widget child,
    ThemeMode themeMode = ThemeMode.dark,
    StaffShiftManagementCubit? cubit,
  }) {
    final effectiveCubit = cubit ??
        FakeStaffShiftManagementCubit(
          StaffShiftManagementLoaded(
            shifts: sampleShifts,
            cinemas: sampleCinemas,
            staffList: sampleStaff,
            schedules: sampleSchedules,
            selectedCinemaId: 1,
            selectedDate: DateTime(2026, 10, 10),
          ),
        );

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('vi'),
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: BlocProvider<StaffShiftManagementCubit>.value(
        value: effectiveCubit,
        child: child,
      ),
    );
  }

  group('StaffShiftManagementScreen Redesign Tests', () {
    testWidgets('renders compact toolbar, shift headers with + Thêm button and headcount', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(buildTestWidget(child: const StaffShiftManagementScreen()));
      await tester.pumpAndSettle();

      // Cinema dropdown rendered
      expect(find.text('CINEPLEX Đà Nẵng'), findsOneWidget);

      // Date formatted
      expect(find.text('10/10/2026'), findsOneWidget);

      // Shift headers rendered
      expect(find.text('Ca sáng'), findsOneWidget);
      expect(find.text('Ca chiều'), findsOneWidget);

      // Quick action "+ Thêm" button appears on headers
      expect(find.text('Thêm'), findsNWidgets(2));

      // Headcount badge on Ca sáng (2 staff)
      expect(find.text('2 nhân viên'), findsOneWidget);

      // Headcount badge on Ca chiều (0 staff)
      expect(find.text('0 nhân viên'), findsOneWidget);

      // Roles are removed from shift management
      expect(find.text('Bán vé tại quầy'), findsNothing);
      expect(find.text('Soát vé tại cửa'), findsNothing);

      // Dense staff rows
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('Trần Thị B'), findsOneWidget);

      // Empty state on Ca chiều
      expect(find.text('Chưa có nhân viên nào được phân ca trong ngày này'), findsOneWidget);
      expect(find.text('Phân ca mới'), findsOneWidget);
    });

    testWidgets('renders cleanly in Light Mode without contrast issues or overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      await tester.pumpWidget(
        buildTestWidget(
          child: const StaffShiftManagementScreen(),
          themeMode: ThemeMode.light,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Ca sáng'), findsOneWidget);
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
    });

    testWidgets('renders cleanly on ultra-small viewport 320x640 without any overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      await tester.pumpWidget(
        buildTestWidget(
          child: const StaffShiftManagementScreen(),
          themeMode: ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Ca sáng'), findsOneWidget);
      expect(find.text('Thêm'), findsNWidgets(2));
    });

    testWidgets('AssignShiftDialog renders multi-staff checkboxes and headcount', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(
        buildTestWidget(
          child: AssignShiftDialog(
            shifts: sampleShifts,
            cinemas: sampleCinemas,
            staffList: sampleStaff,
            schedules: sampleSchedules,
            initialCinemaId: 1,
            initialShiftId: 1,
            initialDate: DateTime(2026, 10, 10),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title
      expect(find.text('Phân ca mới'), findsOneWidget);

      // Cinema selection dropdown is removed from dialog
      expect(find.text('Chọn cụm rạp'), findsNothing);

      // Staff from other cinemas (Lê Văn C belongs to cinema 2) are filtered out
      expect(find.text('Lê Văn C'), findsNothing);

      // Shows cinema badge in header
      expect(find.text('CINEPLEX Đà Nẵng'), findsOneWidget);

      // Shift checkboxes rendered with counter
      expect(find.text('Đã chọn 1 ca'), findsOneWidget);

      // Note is completely removed
      expect(find.text('Ghi chú'), findsNothing);

      // Multi-staff selector label & counter synchronized with reality (both A and B are in shift 1)
      expect(find.text('Chọn nhân viên'), findsOneWidget);
      expect(find.text('Đã chọn 2 nhân viên'), findsOneWidget);

      // Staff list checkboxes for cinema 1
      expect(find.text('Nguyễn Văn A'), findsOneWidget);
      expect(find.text('Trần Thị B'), findsOneWidget);

      // Save button is initially DISABLED because no checkmarks have changed
      final saveBtnBefore = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Lưu'));
      expect(saveBtnBefore.onPressed, isNull);

      // Toggle off second staff member (Trần Thị B)
      await tester.tap(find.text('Trần Thị B'));
      await tester.pumpAndSettle();

      expect(find.text('Đã chọn 1 nhân viên'), findsOneWidget);

      // Save button is now ENABLED because checkmarks changed
      final saveBtnAfter = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Lưu'));
      expect(saveBtnAfter.onPressed, isNotNull);
    });

    testWidgets('enforces read-only on current and past shifts, only editable from next shift onwards', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      // Simulate now is 10:00 AM on 2026-10-10:
      // Ca sáng (08:00 - 16:00) is the current shift (started at 08:00 <= 10:00).
      // Ca chiều (16:00 - 23:00) is the next shift (starts at 16:00 > 10:00).
      await tester.pumpWidget(
        buildTestWidget(
          child: StaffShiftManagementScreen(
            nowProvider: () => DateTime(2026, 10, 10, 10, 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ca sáng is current shift -> read-only:
      // Shows "Chỉ xem" lock badge
      expect(find.text('Chỉ xem'), findsOneWidget);

      // Only Ca chiều has the "+ Thêm" button
      expect(find.text('Thêm'), findsOneWidget);

      // Staff in Ca sáng cannot be edited or deleted (no pencil or trash icons)
      expect(find.byIcon(LucideIcons.pencil), findsNothing);
      expect(find.byIcon(LucideIcons.trash2), findsNothing);

      // Empty state button "Phân ca mới" is available only for Ca chiều
      expect(find.text('Phân ca mới'), findsOneWidget);
    });

    testWidgets('when all shifts are in the past, all are read-only with zero modify actions', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      // Simulate now is 23:30 on 2026-10-10 (all shifts of today have started/ended)
      await tester.pumpWidget(
        buildTestWidget(
          child: StaffShiftManagementScreen(
            nowProvider: () => DateTime(2026, 10, 10, 23, 30),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Both Ca sáng and Ca chiều show "Chỉ xem"
      expect(find.text('Chỉ xem'), findsNWidgets(2));

      // Zero "+ Thêm" buttons
      expect(find.text('Thêm'), findsNothing);

      // Zero edit / delete buttons
      expect(find.byIcon(LucideIcons.pencil), findsNothing);
      expect(find.byIcon(LucideIcons.trash2), findsNothing);

      // Zero "Phân ca mới" buttons
      expect(find.text('Phân ca mới'), findsNothing);
    });

    testWidgets('AssignShiftDialog filters out current/past shifts when now is 10:00', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      // Simulate now is 10:00 AM on 2026-10-10
      await tester.pumpWidget(
        buildTestWidget(
          child: AssignShiftDialog(
            shifts: sampleShifts,
            cinemas: sampleCinemas,
            staffList: sampleStaff,
            initialCinemaId: 1,
            initialDate: DateTime(2026, 10, 10),
            nowProvider: () => DateTime(2026, 10, 10, 10, 0),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ca sáng (08:00) is disabled with 'Chỉ xem' badge because it is current/past.
      // Default selected shift is Ca chiều (16:00) -> 1 ca selected.
      expect(find.text('Chỉ xem'), findsOneWidget);
      expect(find.text('Đã chọn 1 ca'), findsOneWidget);
    });

    testWidgets('AssignShiftDialog shows empty staff notice when cinema has no staff', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(
        buildTestWidget(
          child: AssignShiftDialog(
            shifts: sampleShifts,
            cinemas: sampleCinemas,
            staffList: sampleStaff, // has staff for cinema 1 and 2
            initialCinemaId: 99, // cinema with no staff
            initialDate: DateTime(2026, 10, 10),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chưa có nhân viên thuộc cụm rạp này'), findsOneWidget);
      expect(find.text('Đã chọn 0 nhân viên'), findsOneWidget);
    });

    testWidgets('AssignShiftDialog supports selecting multiple shifts and activates Save button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      await tester.pumpWidget(
        buildTestWidget(
          child: AssignShiftDialog(
            shifts: sampleShifts,
            cinemas: sampleCinemas,
            staffList: sampleStaff,
            schedules: sampleSchedules,
            initialCinemaId: 1,
            initialDate: DateTime(2026, 10, 10),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially only Ca sáng is selected -> 1 ca
      expect(find.text('Đã chọn 1 ca'), findsOneWidget);

      // Toggle Ca chiều on -> now both Ca sáng and Ca chiều are selected
      await tester.tap(find.text('Ca chiều'));
      await tester.pumpAndSettle();

      expect(find.text('Đã chọn 2 ca'), findsOneWidget);

      // Save button is now active
      final saveBtn = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Lưu'));
      expect(saveBtn.onPressed, isNotNull);
    });

    test('StaffScheduleModel.fromJson normalizes ISO strings to YYYY-MM-DD', () {
      final model = StaffScheduleModel.fromJson({
        'id': 1,
        'staffId': 2,
        'cinemaId': 3,
        'shiftId': 4,
        'workDate': '2026-10-10',
      });
      expect(model.workDate, '2026-10-10');

      final isoModel = StaffScheduleModel.fromJson({
        'id': 2,
        'staffId': 2,
        'cinemaId': 3,
        'shiftId': 4,
        'workDate': '2026-10-10T00:00:00.000Z',
      });
      expect(isoModel.workDate.isNotEmpty, isTrue);
      expect(isoModel.workDate.length, 10);
      expect(isoModel.workDate.contains('T'), isFalse);
    });
  });
}
