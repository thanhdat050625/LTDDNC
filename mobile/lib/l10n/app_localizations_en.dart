// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CINEPLEX';

  @override
  String get appName => 'Cineplex';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get otpCode => 'OTP Code';

  @override
  String get otpSent => 'OTP Sent';

  @override
  String get otpVerify => 'Verify OTP';

  @override
  String get registerSuccess => 'Registered successfully';

  @override
  String get resetPasswordSuccess => 'Password reset successfully';

  @override
  String get changePassword => 'Change Password';

  @override
  String get oldPassword => 'Old Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get emailInvalid => 'Invalid email address';

  @override
  String get home => 'Home';

  @override
  String get nowShowing => 'Now Showing';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get audiencePick => 'Audience Pick';

  @override
  String get seeAll => 'See All';

  @override
  String get welcome => 'Welcome';

  @override
  String get totalCinemas => 'Total Cinemas';

  @override
  String get todayShowtimes => 'Today\'s Showtimes';

  @override
  String get movies => 'Movies';

  @override
  String get movieDetail => 'Movie Detail';

  @override
  String get duration => 'Duration';

  @override
  String durationMinutes(int minutes) {
    return '$minutes minutes';
  }

  @override
  String get ageLimit => 'Age Limit';

  @override
  String get genre => 'Genre';

  @override
  String get director => 'Director';

  @override
  String get cast => 'Cast';

  @override
  String get language => 'Language';

  @override
  String get releaseDate => 'Release Date';

  @override
  String get description => 'Description';

  @override
  String get trailer => 'Trailer';

  @override
  String get bookNow => 'Book Now';

  @override
  String get noMovies => 'No movies available';

  @override
  String get rating => 'Rating';

  @override
  String get searchMovies => 'Search Movies';

  @override
  String get filterByGenre => 'Filter by Genre';

  @override
  String get allGenres => 'All Genres';

  @override
  String get selectShowtime => 'Select Showtime';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectCinema => 'Select Cinema';

  @override
  String get format2D => '2D';

  @override
  String get format3D => '3D';

  @override
  String get formatIMAX => 'IMAX';

  @override
  String get noShowtimes => 'No showtimes available';

  @override
  String showtimeAt(String time) {
    return 'Showtime at $time';
  }

  @override
  String get seatSelection => 'Seat Selection';

  @override
  String get selectSeats => 'Please select seats';

  @override
  String get seatStandard => 'Standard';

  @override
  String get seatVIP => 'VIP';

  @override
  String get seatCouple => 'Couple';

  @override
  String get seatSelected => 'Selected';

  @override
  String get seatHeld => 'Held';

  @override
  String get seatBooked => 'Booked';

  @override
  String get seatAvailable => 'Available';

  @override
  String get holdSeatExpired => 'Seat hold expired';

  @override
  String get holdTimerLabel => 'Seat hold time:';

  @override
  String holdTimerMinutes(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get continueBtn => 'Continue';

  @override
  String get maxSeatsReached => 'Maximum seats reached';

  @override
  String get seatHeldByOther => 'Seat is held by another user';

  @override
  String get seatsSelected => 'Selected Seats:';

  @override
  String totalPrice(String price) {
    return 'Total Price: $price';
  }

  @override
  String get createBooking => 'Create Booking';

  @override
  String get concessions => 'Concessions';

  @override
  String get popcornDrinks => 'Popcorn & Drinks';

  @override
  String get addToOrder => 'Add to Order';

  @override
  String get removeFromOrder => 'Remove';

  @override
  String get quantity => 'Quantity';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get skipConcession => 'Skip';

  @override
  String get concessionTotal => 'Concession Total';

  @override
  String get checkout => 'Checkout';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get selectPaymentMethod => 'Select Payment Method';

  @override
  String get momo => 'MoMo Wallet';

  @override
  String get vnpay => 'VNPAY';

  @override
  String get paypal => 'PayPal';

  @override
  String get cash => 'Cash';

  @override
  String get payNow => 'Pay Now';

  @override
  String get processing => 'Processing...';

  @override
  String get paymentSuccess => 'Payment Successful';

  @override
  String get paymentFailed => 'Payment Failed';

  @override
  String get paymentPending => 'Payment Pending';

  @override
  String get paymentExpired => 'Payment Expired';

  @override
  String get bookingCode => 'Booking Code';

  @override
  String secondsRemaining(int seconds) {
    return '$seconds seconds';
  }

  @override
  String get loyaltyPoints => 'Loyalty Points';

  @override
  String get usePoints => 'Use Points';

  @override
  String get pointsDiscount => 'Points Discount';

  @override
  String get maxPointsDiscount => 'Max Discount';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get discountAmount => 'Discount Amount';

  @override
  String get ticketTotal => 'Ticket Total';

  @override
  String get concessionTotalLabel => 'Concession Total';

  @override
  String get promotionCode => 'Promotion Code';

  @override
  String get applyPromotion => 'Apply';

  @override
  String get promotionApplied => 'Promotion applied';

  @override
  String get promotionInvalid => 'Invalid promotion code';

  @override
  String get redeemWithPoints => 'Redeem';

  @override
  String get myTickets => 'My Tickets';

  @override
  String get ticketDetail => 'Ticket Detail';

  @override
  String get qrCode => 'QR Code';

  @override
  String get seatInfo => 'Seat Info';

  @override
  String get noTickets => 'No tickets found';

  @override
  String get checkedIn => 'Checked In';

  @override
  String checkedInAt(String time) {
    return 'Checked in at $time';
  }

  @override
  String get notCheckedIn => 'Not checked in';

  @override
  String get ticketActive => 'Active';

  @override
  String get ticketUsed => 'Used';

  @override
  String get ticketCancelled => 'Cancelled';

  @override
  String get upcomingTickets => 'Upcoming';

  @override
  String get pastTickets => 'Past';

  @override
  String get bookingHistory => 'Booking History';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String unreadCount(int count) {
    return '$count unread';
  }

  @override
  String get notificationTicketConfirm => 'Booking Confirmation';

  @override
  String get notificationPromotion => 'Promotion';

  @override
  String get notificationReminder => 'Reminder';

  @override
  String get notificationSystem => 'System';

  @override
  String get notificationPaymentFailed => 'Payment Failed';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get phone => 'Phone Number';

  @override
  String get gender => 'Gender';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get loyaltyInfo => 'Loyalty Info';

  @override
  String get earnRate => 'Earn Rate';

  @override
  String get pointValue => 'Point Value';

  @override
  String get settings => 'Settings';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get appVersion => 'App Version';

  @override
  String get about => 'About Us';

  @override
  String get staffDashboard => 'Staff Dashboard';

  @override
  String get qrScanner => 'QR Scanner';

  @override
  String get scanTicket => 'Scan Ticket';

  @override
  String get scanResult => 'Scan Result';

  @override
  String get ticketValid => 'Ticket Valid';

  @override
  String get ticketInvalid => 'Ticket Invalid';

  @override
  String get ticketAlreadyChecked => 'Ticket Already Checked';

  @override
  String get counterSale => 'Counter Sale';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get searchCustomer => 'Search Customer';

  @override
  String get statistics => 'Statistics';

  @override
  String get revenue => 'Revenue';

  @override
  String get revenueReport => 'Revenue Report';

  @override
  String get movieStats => 'Movie Stats';

  @override
  String get systemSummary => 'System Summary';

  @override
  String get timeFrame => 'Time Frame';

  @override
  String get day => 'Day';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get ticketsSold => 'Tickets Sold';

  @override
  String get occupancyRate => 'Occupancy Rate';

  @override
  String get activeMovies => 'Active Movies';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get search => 'Search';

  @override
  String get noData => 'No data available';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get serverError => 'Server error';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get refresh => 'Refresh';

  @override
  String get more => 'More';

  @override
  String get less => 'Less';

  @override
  String get viewAll => 'View All';

  @override
  String get selectAll => 'Select All';

  @override
  String get clear => 'Clear';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String seatCount(int count) {
    return '$count seats selected';
  }

  @override
  String priceFormat(String price) {
    return '$price';
  }

  @override
  String dateFormat(String date) {
    return '$date';
  }

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get loyaltyPolicyTitle => 'Loyalty Points Policy';

  @override
  String get loyaltyPolicyEarn =>
      'Earn: Receive 10% of order value into points upon successful payment.';

  @override
  String get loyaltyPolicyDiscount =>
      'Discount: Redeem points for up to 20% discount on total order (1 point = 1 VND).';

  @override
  String get loyaltyPolicyGifts =>
      'Gifts: Redeem points for free popcorn & drink combos.';

  @override
  String get currentPointsBalance => 'Current points balance:';

  @override
  String get pointsSuffix => 'pts';

  @override
  String get managementSection => 'Management & Operations';

  @override
  String get userManagement => 'User Management';

  @override
  String get scanBookingCodeWarning =>
      'This is a booking code (BK-), please scan ticket QR code (starts with TKT-).';

  @override
  String get scanAlreadyCheckedIn => 'This ticket has already been checked in!';

  @override
  String get scanTicketNotActive => 'Ticket is not active!';

  @override
  String get scanTicketNotFound => 'Ticket not found in system!';

  @override
  String get scanSuccess => 'Check-in Successful';

  @override
  String get manualTicketInput => 'Enter ticket code manually (TKT-...)';

  @override
  String get verifyTicket => 'Check-in';

  @override
  String get searchUser => 'Search by email or phone number';

  @override
  String get blockUser => 'Block User';

  @override
  String get unblockUser => 'Unblock';

  @override
  String get confirmBlockUser => 'Are you sure you want to block this user?';

  @override
  String get confirmUnblockUser =>
      'Are you sure you want to unblock this user?';

  @override
  String get userStatusUpdated => 'User status updated successfully';

  @override
  String get revenueTrend => 'Revenue Trend';

  @override
  String get moviePerformance => 'Movie Performance';

  @override
  String get ticketsSoldCol => 'Tickets Sold';

  @override
  String get revenueCol => 'Revenue';

  @override
  String get allMonths => 'All months';

  @override
  String monthFormat(int month) {
    return 'Month $month';
  }

  @override
  String get ticketListEmptyPrompt => 'You do not have any tickets yet';

  @override
  String get selectGender => 'Select gender';

  @override
  String get phoneInvalid => 'Invalid phone number';

  @override
  String get orderStatus => 'Status';

  @override
  String get orderCode => 'Order Code';

  @override
  String get screeningRoom => 'Screening Room';

  @override
  String totalUsersCount(int count) {
    return 'Total: $count';
  }

  @override
  String blockedUsersCount(int count) {
    return 'Blocked: $count';
  }

  @override
  String get noMatchingUsers => 'No matching users found';

  @override
  String confirmBlockUserWithName(String name) {
    return 'Are you sure you want to block $name? The user will not be able to log in or book tickets.';
  }

  @override
  String confirmUnblockUserWithName(String name) {
    return 'Are you sure you want to unblock $name?';
  }

  @override
  String get qrCodeAvailableAfterPayment =>
      'QR code will be available once the order is paid successfully.';

  @override
  String get noRevenueInPeriod => 'No revenue generated in this period';

  @override
  String scanSuccessDetail(String successMsg, String seat, String code) {
    return '$successMsg!\nSeat: $seat • Code: $code';
  }

  @override
  String get scanTicketSubtitle => 'Check-in tickets for screening rooms';

  @override
  String get userManagementSubtitle => 'List & manage user accounts';

  @override
  String get statisticsSubtitle => 'Reports & revenue analytics';
}
