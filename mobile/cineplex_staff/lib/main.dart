import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'app.dart';
import 'features/scanner/data/repositories/staff_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final dioClient = DioClient(storageService);
  final authRepo = AuthRepository(dioClient, storageService);
  final staffRepo = StaffRepository(dioClient);

  runApp(
    CineplexStaffApp(
      storageService: storageService,
      dioClient: dioClient,
      authRepo: authRepo,
      staffRepo: staffRepo,
    ),
  );
}
