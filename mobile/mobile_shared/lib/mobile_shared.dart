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

// Utils
export 'utils/format_utils.dart';
export 'utils/validators.dart';

// Widgets
export 'widgets/app_loading.dart';
export 'widgets/app_error_view.dart';
export 'widgets/app_scaffold.dart';
export 'widgets/app_button.dart';
export 'widgets/app_text_field.dart';
export 'widgets/app_card.dart';
export 'widgets/app_cached_image.dart';
export 'widgets/shimmer_skeleton.dart';
export 'widgets/staggered_list.dart';

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

// Repositories
export 'repositories/auth_repository.dart';

// Bloc
export 'bloc/auth_bloc.dart';

// L10n
export 'l10n/app_localizations.dart';

// Features (Shared Screens)
export 'features/ticket_sale/presentation/screens/ticket_sale_screen.dart';
export 'features/ticket_sale/presentation/screens/seat_selection_screen.dart';
export 'features/ticket_sale/presentation/screens/checkout_screen.dart';

export 'features/movies/presentation/widgets/movie_list_item.dart';
export 'features/movies/data/repositories/movie_management_repository.dart';
export 'features/movies/cubit/movie_management_cubit.dart';
export 'features/movies/cubit/movie_management_state.dart';
export 'features/movies/cubit/movie_form_cubit.dart';
export 'features/movies/presentation/screens/movie_management_screen.dart';
export 'features/movies/presentation/screens/movie_form_screen.dart';
