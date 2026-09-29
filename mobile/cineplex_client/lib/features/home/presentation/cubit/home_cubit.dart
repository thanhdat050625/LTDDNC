import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_shared/mobile_shared.dart';
import 'package:cineplex_client/features/home/data/repositories/home_repository.dart';

abstract class HomeState extends Equatable { const HomeState(); @override List<Object> get props => []; }
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final HomeDataModel data;
  const HomeLoaded(this.data);
  @override List<Object> get props => [data];
}
class HomeError extends HomeState {
  final String error;
  const HomeError(this.error);
  @override List<Object> get props => [error];
}

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository _repo;
  HomeCubit(this._repo) : super(HomeInitial());

  Future<void> load() async {
    emit(HomeLoading());
    try {
      final data = await _repo.getHomeData();
      emit(HomeLoaded(data));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
