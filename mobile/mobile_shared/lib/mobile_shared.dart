library;

// Network & API
export 'network/dio_client.dart';
export 'network/api_response.dart';

// Services
export 'services/storage_service.dart';
export 'services/socket_service.dart';

// Constants
export 'constants/app_constants.dart';
export 'constants/socket_events.dart';

// Errors
export 'errors/app_exception.dart';

// Theme
export 'theme/app_colors.dart';
export 'theme/cineplex_colors.dart';
export 'theme/app_theme.dart';
export 'theme/app_text_styles.dart';
export 'theme/theme_cubit.dart';

// Utils
export 'utils/format_utils.dart';
export 'utils/validators.dart';

export 'package:image_picker/image_picker.dart';

// Widgets
export 'widgets/app_loading.dart';
export 'widgets/app_error_view.dart';
export 'widgets/app_empty_view.dart';
export 'widgets/app_scaffold.dart';
export 'widgets/app_button.dart';
export 'widgets/app_text_field.dart';
export 'widgets/app_card.dart';
export 'widgets/app_cached_image.dart';
export 'widgets/shimmer_skeleton.dart';
export 'widgets/staggered_list.dart';
export 'widgets/seat_widget.dart';
export 'widgets/seat_layout_widget.dart';
export 'widgets/screen_painter.dart';
export 'widgets/app_exit_dialog.dart';
export 'widgets/app_drawer.dart';
export 'navigation/app_back_handler.dart';

// Models
export 'models/user_model.dart';
export 'models/movie_model.dart';
export 'models/cinema_model.dart';
export 'models/seat_model.dart';
export 'models/showtime_model.dart';
export 'models/booking_model.dart';
export 'models/ticket_model.dart';
export 'models/concession_model.dart';
export 'models/home_data_model.dart';
export 'models/statistics_model.dart';
export 'models/shift_model.dart';
export 'models/staff_schedule_model.dart';

// Repositories
export 'repositories/auth_repository.dart';
export 'features/shifts/data/repositories/shift_repository.dart';
export 'features/ticket_sale/data/repositories/booking_management_repository.dart';

// Bloc
export 'bloc/auth_bloc.dart';

// L10n
export 'l10n/app_localizations.dart';

// Features (Shared Screens)

export 'features/movies/presentation/widgets/movie_list_item.dart';
export 'features/movies/data/repositories/movie_management_repository.dart';
export 'features/movies/cubit/movie_management_cubit.dart';
export 'features/movies/cubit/movie_management_state.dart';
export 'features/movies/cubit/movie_form_cubit.dart';
export 'features/movies/presentation/screens/movie_management_screen.dart';
export 'features/movies/presentation/screens/movie_form_screen.dart';
export 'features/movies/presentation/screens/movie_management_detail_screen.dart';
export 'features/movies/presentation/screens/trailer_player_screen.dart';

// Showtimes
export 'features/showtimes/data/repositories/showtime_management_repository.dart';

export 'features/showtimes/cubit/showtime_management_cubit.dart';
export 'features/showtimes/cubit/showtime_management_state.dart';
export 'features/showtimes/cubit/showtime_form_cubit.dart';
export 'features/showtimes/cubit/showtime_form_state.dart';
export 'features/showtimes/presentation/screens/showtime_management_screen.dart';
export 'features/showtimes/presentation/widgets/showtime_list_item.dart';
export 'features/showtimes/presentation/screens/showtime_form_screen.dart';
export 'features/showtimes/cubit/showtime_bulk_create_cubit.dart';
export 'features/showtimes/cubit/showtime_bulk_create_state.dart';
export 'features/showtimes/presentation/screens/showtime_bulk_create_screen.dart';
export 'features/showtimes/presentation/screens/showtime_occupancy_screen.dart';

// Cinemas
export 'features/cinemas/data/repositories/cinema_management_repository.dart';
export 'features/cinemas/cubit/cinema_management_cubit.dart';
export 'features/cinemas/cubit/cinema_management_state.dart';
export 'features/cinemas/cubit/cinema_form_cubit.dart';
export 'features/cinemas/cubit/cinema_form_state.dart';
export 'features/cinemas/cubit/room_management_cubit.dart';
export 'features/cinemas/cubit/room_management_state.dart';
export 'features/cinemas/cubit/room_form_cubit.dart';
export 'features/cinemas/cubit/room_form_state.dart';
export 'features/cinemas/presentation/screens/cinema_management_screen.dart';
export 'features/cinemas/presentation/screens/cinema_form_screen.dart';
export 'features/cinemas/presentation/screens/room_management_screen.dart';
export 'features/cinemas/presentation/screens/room_form_screen.dart';
export 'features/cinemas/presentation/widgets/cinema_list_item.dart';
export 'features/cinemas/presentation/widgets/room_list_item.dart';

// Promotions
export 'features/promotions/data/repositories/promotion_management_repository.dart';
export 'features/promotions/cubit/promotion_management_cubit.dart';
export 'features/promotions/cubit/promotion_management_state.dart';
export 'features/promotions/cubit/promotion_form_cubit.dart';
export 'features/promotions/cubit/promotion_form_state.dart';
export 'features/promotions/presentation/widgets/promotion_list_item.dart';
export 'features/promotions/presentation/screens/promotion_management_screen.dart';
export 'features/promotions/presentation/screens/promotion_form_screen.dart';
export 'models/promotion_model.dart';

// Concessions
export 'features/concessions/data/repositories/concession_management_repository.dart';
export 'features/concessions/cubit/concession_management_cubit.dart';
export 'features/concessions/cubit/concession_management_state.dart';
export 'features/concessions/cubit/concession_form_cubit.dart';
export 'features/concessions/cubit/concession_form_state.dart';
export 'features/concessions/presentation/widgets/concession_list_item.dart';
export 'features/concessions/presentation/screens/concession_management_screen.dart';
export 'features/concessions/presentation/screens/concession_form_screen.dart';

// Settings
export 'features/settings/presentation/screens/app_settings_screen.dart';

// Tickets
export 'features/tickets/presentation/cubit/ticket_management_cubit.dart';
export 'features/tickets/presentation/cubit/ticket_management_state.dart';
export 'features/tickets/presentation/screens/ticket_management_screen.dart';
export 'features/tickets/presentation/widgets/booking_ticket_card.dart';
export 'features/tickets/presentation/widgets/booking_detail_bottom_sheet.dart';
export 'features/tickets/presentation/widgets/ticket_price_table.dart';

// Shifts Management
export 'features/shifts/cubit/staff_shift_management_cubit.dart';
export 'features/shifts/cubit/staff_shift_management_state.dart';
export 'features/shifts/cubit/staff_my_schedule_cubit.dart';
export 'features/shifts/cubit/staff_my_schedule_state.dart';
export 'features/shifts/presentation/screens/staff_shift_management_screen.dart';
export 'features/shifts/presentation/screens/staff_my_schedule_screen.dart';
export 'features/shifts/presentation/widgets/assign_shift_dialog.dart';
