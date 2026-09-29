import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'app.dart';
import 'features/statistics/data/repositories/statistics_repository.dart';
import 'features/users/data/repositories/user_management_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final dioClient = DioClient(storageService);
  final authRepo = AuthRepository(dioClient, storageService);
  final statisticsRepo = StatisticsRepository(dioClient);
  final userManagementRepo = UserManagementRepository(dioClient);

  runApp(
    CineplexAdminApp(
      storageService: storageService,
      dioClient: dioClient,
      authRepo: authRepo,
      statisticsRepo: statisticsRepo,
      userManagementRepo: userManagementRepo,
    ),
  );
}
