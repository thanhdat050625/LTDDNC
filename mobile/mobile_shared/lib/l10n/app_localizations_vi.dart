// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'CINEPLEX';

  @override
  String get appName => 'Cineplex';

  @override
  String get login => 'Đăng nhập';

  @override
  String get register => 'Đăng ký';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get sendOtp => 'Gửi mã OTP';

  @override
  String get otpCode => 'Mã OTP';

  @override
  String get otpSent => 'Mã OTP đã được gửi';

  @override
  String get otpVerify => 'Xác thực OTP';

  @override
  String get registerSuccess => 'Đăng ký thành công';

  @override
  String get resetPasswordSuccess => 'Đặt lại mật khẩu thành công';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get oldPassword => 'Mật khẩu cũ';

  @override
  String get newPassword => 'Mật khẩu mới';

  @override
  String get changePasswordSuccess => 'Đổi mật khẩu thành công';

  @override
  String get changePasswordDescription =>
      'Để bảo mật tài khoản, vui lòng nhập mật khẩu cũ và đặt mật khẩu mới có ít nhất 6 ký tự.';

  @override
  String get oldPasswordRequired => 'Vui lòng nhập mật khẩu cũ';

  @override
  String get newPasswordRequired => 'Vui lòng nhập mật khẩu mới';

  @override
  String get confirmPasswordRequired => 'Vui lòng xác nhận mật khẩu mới';

  @override
  String get newPasswordSameAsOld => 'Mật khẩu mới phải khác mật khẩu cũ';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logoutConfirm => 'Bạn có chắc chắn muốn đăng xuất?';

  @override
  String get rememberMe => 'Ghi nhớ đăng nhập';

  @override
  String get noAccount => 'Chưa có tài khoản?';

  @override
  String get haveAccount => 'Đã có tài khoản?';

  @override
  String get emailRequired => 'Email không được để trống';

  @override
  String get passwordRequired => 'Mật khẩu không được để trống';

  @override
  String get passwordMinLength => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get passwordMismatch => 'Mật khẩu không khớp';

  @override
  String get emailInvalid => 'Email không hợp lệ';

  @override
  String get home => 'Trang chủ';

  @override
  String get nowShowing => 'Đang chiếu';

  @override
  String get comingSoon => 'Sắp chiếu';

  @override
  String get audiencePick => 'Khán giả bình chọn';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get welcome => 'Xin chào';

  @override
  String get totalCinemas => 'Tổng số rạp';

  @override
  String get todayShowtimes => 'Suất chiếu hôm nay';

  @override
  String get movies => 'Phim';

  @override
  String get movieDetail => 'Chi tiết phim';

  @override
  String get duration => 'Thời lượng';

  @override
  String durationMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String get ageLimit => 'Độ tuổi';

  @override
  String get genre => 'Thể loại';

  @override
  String get director => 'Đạo diễn';

  @override
  String get cast => 'Diễn viên';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get releaseDate => 'Ngày khởi chiếu';

  @override
  String get description => 'Nội dung';

  @override
  String get trailer => 'Trailer';

  @override
  String get bookNow => 'Đặt vé ngay';

  @override
  String get noMovies => 'Không có phim nào';

  @override
  String get rating => 'Đánh giá';

  @override
  String get searchMovies => 'Tìm kiếm phim';

  @override
  String get filterByGenre => 'Lọc theo thể loại';

  @override
  String get allGenres => 'Tất cả thể loại';

  @override
  String get selectShowtime => 'Chọn suất chiếu';

  @override
  String get selectDate => 'Chọn ngày';

  @override
  String get selectCinema => 'Chọn rạp';

  @override
  String get format2D => '2D';

  @override
  String get format3D => '3D';

  @override
  String get formatIMAX => 'IMAX';

  @override
  String get noShowtimes => 'Không có suất chiếu nào';

  @override
  String showtimeAt(String time) {
    return 'Suất chiếu lúc $time';
  }

  @override
  String get seatSelection => 'Chọn ghế';

  @override
  String get selectSeats => 'Vui lòng chọn ghế';

  @override
  String get seatStandard => 'Thường';

  @override
  String get seatVIP => 'VIP';

  @override
  String get seatCouple => 'Ghế đôi';

  @override
  String get seatSelected => 'Đang chọn';

  @override
  String get seatHeld => 'Đang giữ';

  @override
  String get seatBooked => 'Đã đặt';

  @override
  String get seatAvailable => 'Trống';

  @override
  String get holdSeatExpired => 'Hết thời gian giữ ghế';

  @override
  String get holdTimerLabel => 'Thời gian giữ ghế:';

  @override
  String holdTimerMinutes(String minutes, String seconds) {
    return '$minutes:$seconds';
  }

  @override
  String get continueBtn => 'Tiếp tục';

  @override
  String get maxSeatsReached => 'Đã đạt số lượng ghế tối đa';

  @override
  String get seatHeldByOther => 'Ghế đã có người chọn';

  @override
  String get seatsSelected => 'Các ghế đã chọn:';

  @override
  String totalPrice(String price) {
    return 'Tổng tiền: $price';
  }

  @override
  String get createBooking => 'Tạo đơn hàng';

  @override
  String get concessions => 'Bắp nước';

  @override
  String get popcornDrinks => 'Bắp & Nước';

  @override
  String get addToOrder => 'Thêm vào đơn';

  @override
  String get removeFromOrder => 'Bỏ khỏi đơn';

  @override
  String get quantity => 'Số lượng';

  @override
  String get subtotal => 'Tạm tính';

  @override
  String get skipConcession => 'Bỏ qua';

  @override
  String get skip => 'Bỏ qua';

  @override
  String availableSeatsCount(int available, int total) {
    return '$available/$total ghế';
  }

  @override
  String get concessionTotal => 'Tổng bắp nước';

  @override
  String get checkout => 'Thanh toán';

  @override
  String get orderSummary => 'Tóm tắt đơn hàng';

  @override
  String get paymentMethod => 'Phương thức thanh toán';

  @override
  String get selectPaymentMethod => 'Chọn phương thức thanh toán';

  @override
  String get momo => 'Ví MoMo';

  @override
  String get vnpay => 'VNPAY';

  @override
  String get paypal => 'PayPal';

  @override
  String get cash => 'Tiền mặt';

  @override
  String get payNow => 'Thanh toán ngay';

  @override
  String get processing => 'Đang xử lý...';

  @override
  String get paymentSuccess => 'Thanh toán thành công';

  @override
  String get paymentFailed => 'Thanh toán thất bại';

  @override
  String get paymentPending => 'Đang chờ thanh toán';

  @override
  String get paymentExpired => 'Thanh toán hết hạn';

  @override
  String get bookingCode => 'Mã đặt vé';

  @override
  String secondsRemaining(int seconds) {
    return '$seconds giây';
  }

  @override
  String get loyaltyPoints => 'Điểm tích luỹ';

  @override
  String get usePoints => 'Sử dụng điểm';

  @override
  String get pointsDiscount => 'Giảm giá từ điểm';

  @override
  String get maxPointsDiscount => 'Giảm tối đa';

  @override
  String get totalAmount => 'Tổng cộng';

  @override
  String get discountAmount => 'Giảm giá';

  @override
  String get ticketTotal => 'Tổng tiền vé';

  @override
  String get concessionTotalLabel => 'Tổng tiền bắp nước';

  @override
  String get promotionCode => 'Mã khuyến mãi';

  @override
  String get applyPromotion => 'Áp dụng';

  @override
  String get promotionApplied => 'Đã áp dụng mã khuyến mãi';

  @override
  String get promotionInvalid => 'Mã khuyến mãi không hợp lệ';

  @override
  String get redeemWithPoints => 'Đổi điểm';

  @override
  String get myTickets => 'Vé của tôi';

  @override
  String get ticketDetail => 'Chi tiết vé';

  @override
  String get qrCode => 'Mã QR';

  @override
  String get seatInfo => 'Thông tin ghế';

  @override
  String get noTickets => 'Chưa có vé nào';

  @override
  String get checkedIn => 'Đã check-in';

  @override
  String checkedInAt(String time) {
    return 'Check-in lúc $time';
  }

  @override
  String get notCheckedIn => 'Chưa check-in';

  @override
  String get ticketActive => 'Khả dụng';

  @override
  String get ticketUsed => 'Đã sử dụng';

  @override
  String get ticketCancelled => 'Đã hủy';

  @override
  String get upcomingTickets => 'Sắp diễn ra';

  @override
  String get pastTickets => 'Đã qua';

  @override
  String get bookingHistory => 'Lịch sử đặt vé';

  @override
  String get notifications => 'Thông báo';

  @override
  String get noNotifications => 'Không có thông báo nào';

  @override
  String get markAllRead => 'Đánh dấu tất cả đã đọc';

  @override
  String unreadCount(int count) {
    return '$count chưa đọc';
  }

  @override
  String get notificationTicketConfirm => 'Xác nhận đặt vé';

  @override
  String get notificationPromotion => 'Khuyến mãi';

  @override
  String get notificationReminder => 'Nhắc nhở';

  @override
  String get notificationSystem => 'Hệ thống';

  @override
  String get notificationPaymentFailed => 'Thanh toán thất bại';

  @override
  String get profile => 'Tài khoản';

  @override
  String get editProfile => 'Chỉnh sửa thông tin';

  @override
  String get fullName => 'Họ và tên';

  @override
  String get phone => 'Số điện thoại';

  @override
  String get gender => 'Giới tính';

  @override
  String get dateOfBirth => 'Ngày sinh';

  @override
  String get male => 'Nam';

  @override
  String get female => 'Nữ';

  @override
  String get other => 'Khác';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get profileUpdated => 'Cập nhật thành công';

  @override
  String get loyaltyInfo => 'Thông tin thẻ thành viên';

  @override
  String get earnRate => 'Tỉ lệ tích điểm';

  @override
  String get pointValue => 'Giá trị điểm';

  @override
  String get settings => 'Cài đặt';

  @override
  String get darkMode => 'Chế độ tối';

  @override
  String get lightMode => 'Chế độ sáng';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get appVersion => 'Phiên bản ứng dụng';

  @override
  String get about => 'Về chúng tôi';

  @override
  String get staffDashboard => 'Tổng quan';

  @override
  String get qrScanner => 'Quét mã QR';

  @override
  String get scanTicket => 'Quét vé';

  @override
  String get scanResult => 'Kết quả quét';

  @override
  String get ticketValid => 'Vé hợp lệ';

  @override
  String get ticketInvalid => 'Vé không hợp lệ';

  @override
  String get ticketAlreadyChecked => 'Vé đã được kiểm tra';

  @override
  String get counterSale => 'Bán tại quầy';

  @override
  String get selectCustomer => 'Chọn khách hàng';

  @override
  String get searchCustomer => 'Tìm kiếm khách hàng';

  @override
  String get statistics => 'Thống kê';

  @override
  String get revenue => 'Doanh thu';

  @override
  String get revenueReport => 'Báo cáo doanh thu';

  @override
  String get movieStats => 'Thống kê phim';

  @override
  String get systemSummary => 'Tổng quan hệ thống';

  @override
  String get timeFrame => 'Khung thời gian';

  @override
  String get day => 'Ngày';

  @override
  String get week => 'Tuần';

  @override
  String get month => 'Tháng';

  @override
  String get year => 'Năm';

  @override
  String get ticketsSold => 'Số vé đã bán';

  @override
  String get occupancyRate => 'Tỉ lệ lấp đầy';

  @override
  String get activeMovies => 'Phim đang chiếu';

  @override
  String get totalRevenue => 'Tổng doanh thu';

  @override
  String get loading => 'Đang tải...';

  @override
  String get error => 'Đã xảy ra lỗi';

  @override
  String get retry => 'Thử lại';

  @override
  String get cancel => 'Hủy';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get save => 'Lưu';

  @override
  String get delete => 'Xóa';

  @override
  String get back => 'Quay lại';

  @override
  String get next => 'Tiếp theo';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get noData => 'Không có dữ liệu';

  @override
  String get noInternet => 'Không có kết nối mạng';

  @override
  String get serverError => 'Lỗi máy chủ';

  @override
  String get unknownError => 'Lỗi không xác định';

  @override
  String get success => 'Thành công';

  @override
  String get warning => 'Cảnh báo';

  @override
  String get info => 'Thông tin';

  @override
  String get close => 'Đóng';

  @override
  String get ok => 'Đồng ý';

  @override
  String get yes => 'Có';

  @override
  String get no => 'Không';

  @override
  String get refresh => 'Làm mới';

  @override
  String get more => 'Thêm';

  @override
  String get less => 'Ẩn bớt';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get selectAll => 'Chọn tất cả';

  @override
  String get clear => 'Xóa';

  @override
  String get apply => 'Áp dụng';

  @override
  String get reset => 'Đặt lại';

  @override
  String seatCount(int count) {
    return '$count ghế đã chọn';
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
  String get fullNameRequired => 'Vui lòng nhập họ và tên';

  @override
  String get loyaltyPolicyTitle => 'Chính sách tích & tiêu điểm';

  @override
  String get loyaltyPolicyEarn =>
      'Tích lũy: Nhận ngay 10% giá trị đơn hàng sau khi thanh toán thành công.';

  @override
  String get loyaltyPolicyDiscount =>
      'Giảm giá: Dùng điểm giảm giá tối đa 20% tổng đơn (1 điểm = 1 VNĐ).';

  @override
  String get loyaltyPolicyGifts =>
      'Đổi quà: Dùng điểm quy đổi các Combo bắp nước miễn phí.';

  @override
  String get currentPointsBalance => 'Số dư điểm hiện tại:';

  @override
  String get pointsSuffix => 'điểm';

  @override
  String get managementSection => 'Quản lý & Nghiệp vụ';

  @override
  String get userManagement => 'Quản lý người dùng';

  @override
  String get scanBookingCodeWarning =>
      'Đây là mã đặt vé (BK-), vui lòng quét mã QR của từng vé (bắt đầu bằng TKT-).';

  @override
  String get scanAlreadyCheckedIn => 'Vé này đã được soát trước đó!';

  @override
  String get scanTicketNotActive => 'Vé không còn hiệu lực!';

  @override
  String get scanTicketNotFound => 'Không tìm thấy vé trong hệ thống!';

  @override
  String get scanSuccess => 'Soát vé thành công';

  @override
  String get manualTicketInput => 'Nhập mã vé thủ công (TKT-...)';

  @override
  String get verifyTicket => 'Soát vé';

  @override
  String get searchUser => 'Tìm kiếm theo email hoặc số điện thoại';

  @override
  String get blockUser => 'Khóa tài khoản';

  @override
  String get unblockUser => 'Mở khóa';

  @override
  String get confirmBlockUser => 'Bạn có chắc chắn muốn khóa tài khoản này?';

  @override
  String get confirmUnblockUser =>
      'Bạn có chắc chắn muốn mở khóa tài khoản này?';

  @override
  String get userStatusUpdated => 'Cập nhật trạng thái người dùng thành công';

  @override
  String get revenueTrend => 'Xu hướng doanh thu';

  @override
  String get moviePerformance => 'Hiệu suất phim';

  @override
  String get ticketsSoldCol => 'Vé bán';

  @override
  String get revenueCol => 'Doanh thu';

  @override
  String get allMonths => 'Tất cả các tháng';

  @override
  String monthFormat(int month) {
    return 'Tháng $month';
  }

  @override
  String get ticketListEmptyPrompt => 'Bạn chưa có vé xem phim nào';

  @override
  String get selectGender => 'Chọn giới tính';

  @override
  String get phoneInvalid => 'Số điện thoại không hợp lệ';

  @override
  String get orderStatus => 'Trạng thái';

  @override
  String get orderCode => 'Mã đơn hàng';

  @override
  String get screeningRoom => 'Phòng chiếu';

  @override
  String totalUsersCount(int count) {
    return 'Tổng số: $count';
  }

  @override
  String blockedUsersCount(int count) {
    return 'Đã khóa: $count';
  }

  @override
  String get noMatchingUsers => 'Không tìm thấy người dùng phù hợp';

  @override
  String confirmBlockUserWithName(String name) {
    return 'Bạn có chắc chắn muốn khóa tài khoản $name? Người dùng sẽ không thể đăng nhập hoặc đặt vé.';
  }

  @override
  String confirmUnblockUserWithName(String name) {
    return 'Bạn có chắc chắn muốn mở khóa tài khoản $name?';
  }

  @override
  String get qrCodeAvailableAfterPayment =>
      'Mã QR chỉ khả dụng sau khi đơn hàng được thanh toán thành công.';

  @override
  String get noRevenueInPeriod =>
      'Không có phát sinh doanh thu trong giai đoạn này';

  @override
  String scanSuccessDetail(String successMsg, String seat, String code) {
    return '$successMsg!\nGhế: $seat • Mã: $code';
  }

  @override
  String get scanTicketSubtitle => 'Soát vé vào phòng chiếu';

  @override
  String get staffLoginTitle => 'Quản Lý Rạp';

  @override
  String get staffLoginSubtitle => 'Nhân Viên';

  @override
  String get adminLoginTitle => 'Quản Trị Hệ Thống';

  @override
  String get adminLoginSubtitle => 'Admin';

  @override
  String get userManagementSubtitle => 'Danh sách & Quản lý tài khoản';

  @override
  String get statisticsSubtitle => 'Báo cáo & Thống kê doanh thu';

  @override
  String get accessDenied => 'Truy cập bị từ chối. Không đủ quyền hạn.';

  @override
  String get counterSaleDesc => 'Bán vé & Thanh toán';

  @override
  String get screen => 'MÀN HÌNH';

  @override
  String get popcornOnly => 'Bắp rang bơ';

  @override
  String get largeDrinkOnly => 'Nước ngọt lớn';

  @override
  String get combo1Popcorn2Drinks => 'Combo 1 bắp 2 nước';

  @override
  String movieTicket(int count) {
    return 'Vé xem phim ($count ghế)';
  }

  @override
  String get discountPointsTitle => 'Giảm giá (Điểm)';

  @override
  String get enterPoints => 'Nhập số điểm';

  @override
  String loyaltyPrompt(String points) {
    return 'Khách hàng có $points điểm. Dùng điểm để giảm giá?';
  }

  @override
  String paymentSuccessPrompt(String code) {
    return 'Thanh toán thành công. Đã tạo mã vé $code.';
  }

  @override
  String get cineplexDistrict1 => 'Cineplex Quận 1';

  @override
  String get today => 'Hôm nay';

  @override
  String roomPrefix(String id) {
    return 'Phòng $id';
  }

  @override
  String get standard2D => 'Standard • 2D';

  @override
  String get manageShowtimes => 'Quản lý Suất chiếu';

  @override
  String get addShowtime => 'Thêm Suất chiếu';

  @override
  String get editShowtime => 'Chỉnh sửa Suất chiếu';

  @override
  String get filterByDate => 'Lọc theo ngày';

  @override
  String get noShowtimesFound => 'Không có suất chiếu nào.';

  @override
  String get confirmDelete => 'Xác nhận xóa';

  @override
  String get confirmDeleteShowtimeDesc =>
      'Bạn có chắc muốn xóa suất chiếu này không?';

  @override
  String get unknownMovie => 'Phim không xác định';

  @override
  String get emptyRoom => 'Phòng trống';

  @override
  String get statusScheduled => 'Sắp xếp';

  @override
  String get statusBooking => 'Mở bán';

  @override
  String get statusFull => 'Kín chỗ';

  @override
  String get statusCancelled => 'Đã hủy';

  @override
  String get statusCompleted => 'Hoàn thành';

  @override
  String get updateSuccess => 'Cập nhật thành công!';

  @override
  String get addSuccess => 'Thêm suất chiếu thành công!';

  @override
  String get fillRequiredFields => 'Vui lòng điền đầy đủ thông tin bắt buộc';

  @override
  String get movieLabel => 'Phim';

  @override
  String get selectMovieReq => 'Vui lòng chọn phim';

  @override
  String get cinemaLabel => 'Rạp';

  @override
  String get selectCinemaReq => 'Vui lòng chọn rạp';

  @override
  String get roomLabel => 'Phòng chiếu';

  @override
  String get selectRoomReq => 'Vui lòng chọn phòng chiếu';

  @override
  String get formatLabel => 'Định dạng';

  @override
  String get statusLabel => 'Trạng thái';

  @override
  String get selectStartTimeReq => 'Vui lòng chọn thời gian bắt đầu';

  @override
  String get createShowtimeBtn => 'Tạo suất chiếu';

  @override
  String get manageCinemas => 'Quản lý Rạp';

  @override
  String get addCinema => 'Thêm Rạp';

  @override
  String get editCinema => 'Sửa Rạp';

  @override
  String get cinemaName => 'Tên rạp';

  @override
  String get address => 'Địa chỉ';

  @override
  String get roomCount => 'Số phòng';

  @override
  String get manageRooms => 'Phòng chiếu';

  @override
  String get addRoom => 'Thêm phòng';

  @override
  String get editRoom => 'Sửa phòng';

  @override
  String get roomName => 'Tên phòng';

  @override
  String get roomType => 'Loại phòng';

  @override
  String get noCinemas => 'Chưa có rạp nào.';

  @override
  String get noRooms => 'Chưa có phòng nào.';

  @override
  String get confirmDeleteCinema => 'Bạn có chắc muốn xóa rạp này không?';

  @override
  String get confirmDeleteRoom => 'Bạn có chắc muốn xóa phòng chiếu này không?';

  @override
  String get managePromotions => 'Quản lý Khuyến mãi';

  @override
  String get addPromotion => 'Thêm Khuyến mãi';

  @override
  String get editPromotion => 'Sửa Khuyến mãi';

  @override
  String get promoCode => 'Mã khuyến mãi';

  @override
  String get promoDescription => 'Mô tả';

  @override
  String get discountType => 'Loại giảm giá';

  @override
  String get discountValue => 'Mức giảm';

  @override
  String get percentage => 'Phần trăm (%)';

  @override
  String get fixedAmount => 'Số tiền cố định';

  @override
  String get maxUsage => 'Số lần dùng tối đa';

  @override
  String get noPromotions => 'Chưa có khuyến mãi nào.';

  @override
  String get confirmDeletePromotion =>
      'Bạn có chắc chắn muốn xóa mã khuyến mãi này không?';

  @override
  String get startDate => 'Ngày bắt đầu';

  @override
  String get endDate => 'Ngày kết thúc';

  @override
  String get manageConcessions => 'Quản lý Bắp nước';

  @override
  String get addProduct => 'Thêm sản phẩm';

  @override
  String get editProduct => 'Sửa sản phẩm';

  @override
  String get productName => 'Tên sản phẩm';

  @override
  String get stockQuantity => 'Tồn kho';

  @override
  String get lowStock => 'Sắp hết';

  @override
  String get outOfStock => 'Hết hàng';

  @override
  String get totalProducts => 'Tổng sản phẩm';

  @override
  String get noConcessions => 'Chưa có sản phẩm nào.';

  @override
  String get confirmDeleteProduct => 'Bạn có chắc muốn xóa sản phẩm này không?';

  @override
  String get priceLabel => 'Giá';

  @override
  String get productImage => 'Ảnh sản phẩm';

  @override
  String get selectImage => 'Chọn ảnh';

  @override
  String get changeImage => 'Đổi ảnh';

  @override
  String get changeAvatar => 'Thay đổi ảnh đại diện';

  @override
  String get removeImage => 'Xóa ảnh';

  @override
  String get takePhoto => 'Chụp ảnh';

  @override
  String get chooseFromGallery => 'Chọn từ thư viện';

  @override
  String get imageUrlOptional => 'Hoặc dán URL ảnh';

  @override
  String get enterImageUrl => 'Nhập đường dẫn ảnh (URL)';

  @override
  String get searchConcessionPlaceholder => 'Tìm kiếm bắp nước...';

  @override
  String inStockCount(int count) {
    return 'Còn $count';
  }

  @override
  String lowStockCount(int count) {
    return 'Sắp hết: $count';
  }

  @override
  String get manageMovies => 'Quản lý Phim';

  @override
  String get ticketSaleAtCounter => 'Bán vé tại quầy';

  @override
  String get staffRole => 'Nhân viên';

  @override
  String get adminRole => 'Quản trị viên';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get imageUploadError => 'Không thể tải ảnh lên';

  @override
  String get noResultsFound => 'Không tìm thấy kết quả';

  @override
  String get invalidAmount => 'Giá trị không hợp lệ';

  @override
  String get customerRole => 'Khách hàng';

  @override
  String get tabAll => 'Tất cả';

  @override
  String get tabCustomers => 'Khách hàng';

  @override
  String get tabStaff => 'Nhân viên';

  @override
  String get statusAll => 'Tất cả';

  @override
  String get statusActive => 'Hoạt động';

  @override
  String get statusBlocked => 'Đã khóa';

  @override
  String totalCustomersCount(int count) {
    return 'Khách hàng: $count';
  }

  @override
  String totalStaffCount(int count) {
    return 'Nhân viên: $count';
  }

  @override
  String get addStaff => 'Thêm nhân viên';

  @override
  String get createStaffTitle => 'Tạo tài khoản nhân viên';

  @override
  String get createStaffSubtitle =>
      'Cấp tài khoản truy cập hệ thống cho nhân viên rạp';

  @override
  String get staffCreatedSuccess => 'Tạo tài khoản nhân viên thành công';

  @override
  String get fullNameLabel => 'Họ và tên';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Số điện thoại';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get confirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get saveStaffButton => 'Tạo nhân viên';

  @override
  String get accountDetailsTitle => 'Chi tiết tài khoản';

  @override
  String get joinedDateLabel => 'Ngày tham gia';

  @override
  String get loyaltyPointsTitle => 'Điểm tích lũy';

  @override
  String get cannotBlockSelf => 'Bạn không thể khóa tài khoản của chính mình';

  @override
  String pageIndicator(int current, int total) {
    return 'Trang $current / $total';
  }

  @override
  String get nextPage => 'Trang sau';

  @override
  String get prevPage => 'Trang trước';

  @override
  String get confirmPasswordMismatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get notProvided => 'Chưa cập nhật';

  @override
  String get genderLabel => 'Giới tính';

  @override
  String get dobLabel => 'Ngày sinh';

  @override
  String get accountInfo => 'Thông tin tài khoản';

  @override
  String get resetFilters => 'Đặt lại bộ lọc';

  @override
  String get totalAccounts => 'Tổng tài khoản';

  @override
  String get fieldRequired => 'Vui lòng nhập trường này';

  @override
  String get errorOccurred => 'Có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get productDescription => 'Mô tả sản phẩm';

  @override
  String get productDetail => 'Chi tiết sản phẩm';

  @override
  String get revenueStatistics => 'Thống kê Doanh thu';

  @override
  String get filterByYear => 'Theo năm';

  @override
  String get filterByMonth => 'Theo tháng';

  @override
  String get filterByDateRange => 'Khoảng ngày';

  @override
  String get selectDateRange => 'Chọn khoảng ngày';

  @override
  String get dateFrom => 'Từ ngày';

  @override
  String get dateTo => 'Đến ngày';

  @override
  String get totalRevenueLabel => 'Tổng doanh thu kỳ này';

  @override
  String get genreAll => 'Tất cả';

  @override
  String get genreAction => 'Hành động';

  @override
  String get genreComedy => 'Hài hước';

  @override
  String get genreDrama => 'Chính kịch';

  @override
  String get genreHorror => 'Kinh dị';

  @override
  String get genreSciFi => 'Khoa học viễn tưởng';

  @override
  String get genreRomance => 'Lãng mạn';

  @override
  String get genreAnimation => 'Hoạt hình';

  @override
  String get genreAdventure => 'Phiêu lưu';

  @override
  String get genreThriller => 'Giật gân';

  @override
  String get genreFantasy => 'Giả tưởng';

  @override
  String get genreDocumentary => 'Tài liệu';

  @override
  String get bookingStatusPending => 'Chờ thanh toán';

  @override
  String get bookingStatusPaid => 'Đã thanh toán';

  @override
  String get bookingStatusCancelled => 'Đã hủy';

  @override
  String get bookingStatusExpired => 'Hết hạn';

  @override
  String get bookingStatusConfirmed => 'Đã xác nhận';

  @override
  String get paymentStatusPending => 'Đang xử lý';

  @override
  String get paymentStatusSuccess => 'Thành công';

  @override
  String get paymentStatusFailed => 'Thất bại';

  @override
  String get paymentStatusCancelled => 'Đã hủy';

  @override
  String get paymentResult => 'Kết quả thanh toán';

  @override
  String get paymentSuccessful => 'Thanh toán thành công!';

  @override
  String get viewTickets => 'Xem vé của tôi';

  @override
  String bookingCodeWithParam(String code) {
    return 'Mã đặt vé: $code';
  }

  @override
  String get simulateSuccess => 'Mô phỏng thanh toán thành công';

  @override
  String get webviewPlaceholder => 'Cổng thanh toán trực tuyến';

  @override
  String get specialDiscount => 'Khuyến mãi đặc biệt';

  @override
  String get unknownCinema => 'Rạp không xác định';

  @override
  String get defaultMovieTitle => 'Phim Cineplex';

  @override
  String get concessionCombo => 'Combo bắp nước';

  @override
  String get paymentMethodMomo => 'Ví MoMo';

  @override
  String get paymentMethodVnpay => 'Cổng VNPAY';

  @override
  String get paymentMethodZaloPay => 'Ví ZaloPay';

  @override
  String get paymentMethodCard => 'Thẻ ATM / Thẻ quốc tế';

  @override
  String get paymentMethodCash => 'Tiền mặt tại quầy';

  @override
  String get epassTitle => 'Vé điện tử (E-Pass)';

  @override
  String get epassInstruction =>
      'Vui lòng xuất trình mã QR này tại cửa kiểm soát để vào rạp';

  @override
  String get ticketFormat2D => '2D';

  @override
  String get ticketFormat3D => '3D';

  @override
  String get ticketFormatIMAX => 'IMAX';

  @override
  String get checkinStatusValid => 'HỢP LỆ';

  @override
  String get checkinStatusAlreadyUsed => 'ĐÃ SOÁT TRƯỚC ĐÓ';

  @override
  String get checkinStatusInvalid => 'KHÔNG HỢP LỆ';

  @override
  String get checkinSuccessBanner => 'Soát vé thành công - Mời khách vào rạp';

  @override
  String get checkinWarningBanner => 'Cảnh báo: Vé đã được sử dụng trước đó!';

  @override
  String get checkinErrorBanner => 'Từ chối: Vé không hợp lệ hoặc đã bị hủy!';

  @override
  String get checkinTimeLabel => 'Thời gian soát vé';

  @override
  String get checkinStaffLabel => 'Nhân viên soát vé';

  @override
  String get customerNameLabel => 'Tên khách hàng';

  @override
  String get ticketCodeLabel => 'Mã vé';

  @override
  String get flashToggle => 'Bật/Tắt đèn Flash';

  @override
  String get switchCamera => 'Đổi camera';

  @override
  String get scannerPrompt => 'Hướng camera về phía mã QR trên vé của khách';

  @override
  String get scanNextTicket => 'Quét vé tiếp theo';

  @override
  String get manualCodeHint => 'Nhập mã vé (VD: TKT-12345)';

  @override
  String verifySuccessPrompt(String code) {
    return 'Vé $code đã được xác nhận thành công!';
  }

  @override
  String get shiftDashboard => 'Bảng điều khiển ca trực';

  @override
  String get shiftInfo => 'Thông tin ca trực';

  @override
  String get currentShift => 'Ca trực hiện tại';

  @override
  String get assignedCinema => 'Rạp làm việc';

  @override
  String get staffName => 'Nhân viên trực';

  @override
  String get ticketsScannedToday => 'Số vé đã soát hôm nay';

  @override
  String get counterRevenueToday => 'Doanh thu tại quầy';

  @override
  String get upcomingShowtimesCount => 'Suất chiếu sắp tới';

  @override
  String get quickActions => 'Thao tác nhanh';

  @override
  String get actionScanTicket => 'Soát vé vào rạp';

  @override
  String get actionCounterSale => 'Bán vé tại quầy';

  @override
  String get actionFastPOS => 'Bán bắp nước nhanh';

  @override
  String get actionRoomStatus => 'Tình trạng phòng chiếu';

  @override
  String get endShift => 'Kết thúc ca trực';

  @override
  String get shiftSummary => 'Tổng kết ca trực';

  @override
  String get fastPosTitle => 'Bán bắp nước nhanh';

  @override
  String get posCategoryAll => 'Tất cả';

  @override
  String get posCategoryPopcorn => 'Bắp rang bơ';

  @override
  String get posCategoryDrink => 'Nước giải khát';

  @override
  String get posCategoryCombo => 'Combo bắp nước';

  @override
  String get posCategorySnack => 'Đồ ăn nhẹ';

  @override
  String get quickOrder => 'Đơn hàng nhanh';

  @override
  String cartItemsCount(int count) {
    return '$count món';
  }

  @override
  String get clearCart => 'Xóa giỏ hàng';

  @override
  String get confirmOrder => 'Xác nhận đơn hàng';

  @override
  String get customerPhoneLookup => 'Tra cứu SĐT khách hàng';

  @override
  String get searchCustomerHint => 'Nhập số điện thoại khách hàng...';

  @override
  String customerPointsDisplay(int points) {
    return 'Điểm tích lũy: $points';
  }

  @override
  String customerNameDisplay(String name) {
    return 'Khách hàng: $name';
  }

  @override
  String get payWithCash => 'Thanh toán tiền mặt';

  @override
  String get printReceipt => 'In hóa đơn / Vé';

  @override
  String get defaultPopcorn => 'Bắp rang bơ lớn';

  @override
  String get defaultDrink => 'Nước ngọt lớn';

  @override
  String get defaultCombo => 'Combo 1 bắp 2 nước';

  @override
  String occupancyPercent(int percent) {
    return '$percent% lấp đầy';
  }

  @override
  String get roomStatusScreening => 'Đang chiếu';

  @override
  String get roomStatusPreparing => 'Chuẩn bị chiếu';

  @override
  String get roomStatusCleaning => 'Dọn dẹp';

  @override
  String get roomStatusReady => 'Sẵn sàng';

  @override
  String get roomStatusEnded => 'Đã kết thúc';

  @override
  String get showtimesAndOccupancy => 'Lịch chiếu & Tình trạng phòng';

  @override
  String get viewRoomLayout => 'Xem sơ đồ phòng';

  @override
  String totalSeatsInRoom(int total) {
    return '$total ghế';
  }

  @override
  String bookedSeatsCount(int booked, int total) {
    return '$booked/$total ghế đã đặt';
  }

  @override
  String get addMovieTitle => 'Thêm phim mới';

  @override
  String get editMovieTitle => 'Cập nhật phim';

  @override
  String get addMovieSuccess => 'Thêm phim thành công!';

  @override
  String get updateMovieSuccess => 'Cập nhật phim thành công!';

  @override
  String get selectPoster => 'Chọn poster';

  @override
  String get movieTitleLabel => 'Tên phim *';

  @override
  String get enterMovieTitle => 'Nhập tên phim';

  @override
  String get movieTitleRequired => 'Vui lòng nhập tên phim';

  @override
  String get genreLabel => 'Thể loại *';

  @override
  String get genrePlaceholder => 'Hành động, Hài hước, Kinh dị...';

  @override
  String get durationMinutesLabel => 'Thời lượng (phút) *';

  @override
  String get directorPlaceholder => 'Tên đạo diễn';

  @override
  String get castPlaceholder => 'Tên diễn viên...';

  @override
  String get languagePlaceholder => 'Tiếng Việt, Tiếng Anh...';

  @override
  String get ageLimitPlaceholder => '13, 16, 18...';

  @override
  String get releaseDateLabel => 'Ngày phát hành';

  @override
  String get screeningEndDate => 'Ngày kết thúc';

  @override
  String get selectDatePrompt => 'Chọn ngày';

  @override
  String get trailerUrl => 'Trailer URL';

  @override
  String get trailerUrlPlaceholder => 'https://youtube.com/...';

  @override
  String get movieDescriptionPlaceholder => 'Nội dung phim...';

  @override
  String get createMovieBtn => 'Tạo phim';

  @override
  String get searchMoviesPlaceholder => 'Tìm kiếm tên phim...';

  @override
  String get statusNowShowing => 'Đang chiếu';

  @override
  String get statusComingSoon => 'Sắp chiếu';

  @override
  String get statusStopped => 'Ngừng chiếu';

  @override
  String get roomTypeStandard => 'Tiêu chuẩn (Standard)';

  @override
  String get roomTypeVIP => 'Phòng VIP';

  @override
  String get roomTypeIMAX => 'Phòng IMAX';

  @override
  String get roomType4DX => 'Phòng 4DX';

  @override
  String get roomTypeCouple => 'Phòng Sweetbox';

  @override
  String get roomStatusActive => 'Đang hoạt động';

  @override
  String get roomStatusInactive => 'Tạm ngưng';

  @override
  String get roomStatusMaintenance => 'Bảo trì';

  @override
  String get viewSeatMap => 'Xem sơ đồ ghế';

  @override
  String get generateSeatsBtn => 'Tạo sơ đồ ghế tự động';

  @override
  String get generateSeatsSuccess => 'Tạo sơ đồ ghế thành công!';

  @override
  String get generateSeatsConfirm =>
      'Hành động này sẽ tạo ma trận ghế tự động cho phòng chiếu. Tiếp tục?';

  @override
  String get seatLayoutTitle => 'Sơ đồ phòng chiếu';

  @override
  String get seatMatrixRows => 'Số hàng ghế';

  @override
  String get seatMatrixCols => 'Số cột ghế';

  @override
  String get cinemaStatusActive => 'Đang hoạt động';

  @override
  String get cinemaStatusInactive => 'Tạm dừng';

  @override
  String get cinemaStatusMaintenance => 'Bảo trì';

  @override
  String get format4DX => '4DX';

  @override
  String get filterByDatePrompt => 'Lọc theo ngày';

  @override
  String millionShort(String amount) {
    return '$amount Tr';
  }

  @override
  String thousandShort(String amount) {
    return '$amount N';
  }

  @override
  String rankBadge(int rank) {
    return '#$rank';
  }

  @override
  String get topPerformingMovies => 'Top phim doanh thu cao';

  @override
  String get chartRevenueUnit => 'Đơn vị: VNĐ';

  @override
  String get noDataInPeriod => 'Không có dữ liệu trong khoảng thời gian này';

  @override
  String get adminSettings => 'Cài đặt hệ thống';

  @override
  String get adminProfile => 'Hồ sơ quản trị viên';

  @override
  String get themeModeSetting => 'Giao diện';

  @override
  String get themeModeDark => 'Giao diện tối';

  @override
  String get themeModeLight => 'Giao diện sáng';

  @override
  String get themeModeSystem => 'Theo hệ thống';

  @override
  String get systemInfo => 'Thông tin hệ thống';

  @override
  String get clearCache => 'Xóa bộ nhớ đệm';

  @override
  String get clearCacheSuccess => 'Đã xóa bộ nhớ đệm thành công';

  @override
  String get soundAndHaptic => 'Âm thanh & Rung khi quét';

  @override
  String get soundAndHapticDesc =>
      'Phát âm báo và rung khi quét mã QR thành công hoặc thất bại';

  @override
  String get weekdayMon => 'Th 2';

  @override
  String get weekdayTue => 'Th 3';

  @override
  String get weekdayWed => 'Th 4';

  @override
  String get weekdayThu => 'Th 5';

  @override
  String get weekdayFri => 'Th 6';

  @override
  String get weekdaySat => 'Th 7';

  @override
  String get weekdaySun => 'CN';

  @override
  String get cameraInitializing => 'Đang khởi động máy ảnh...';

  @override
  String get cameraPermissionDenied =>
      'Không có quyền truy cập máy ảnh. Vui lòng cấp quyền trong cài đặt thiết bị.';

  @override
  String get cameraError => 'Không thể khởi động máy ảnh';

  @override
  String get cameraErrorHint =>
      'Vui lòng kiểm tra quyền truy cập hoặc sử dụng tính năng nhập mã thủ công bên dưới.';

  @override
  String get cameraRetake => 'Chụp lại';

  @override
  String get cameraUsePhoto => 'Sử dụng ảnh';

  @override
  String get cameraCapture => 'Chụp ảnh';

  @override
  String get cameraNoCameras => 'Không tìm thấy máy ảnh trên thiết bị';

  @override
  String get cameraCircleHint => 'Căn chỉnh khuôn mặt vào giữa khung tròn';

  @override
  String get staffProfile => 'Hồ sơ nhân viên';

  @override
  String get posTabTickets => 'Vé & Bắp nước';

  @override
  String get posTabConcessions => 'Bắp nước nhanh';

  @override
  String get checkinResultTitle => 'Kết quả soát vé';

  @override
  String get cashReceived => 'Tiền khách đưa';

  @override
  String get cashChange => 'Tiền thối lại';

  @override
  String get exactAmount => 'Đủ tiền';

  @override
  String get printTicketReceipt => 'In vé & Hóa đơn';

  @override
  String get posOrderSuccess => 'Tạo đơn hàng thành công!';

  @override
  String posOrderSuccessPrompt(String code) {
    return 'Mã đơn: $code';
  }

  @override
  String get staffBadge => 'NHÂN VIÊN';

  @override
  String get seatNumber => 'Số ghế';

  @override
  String get customer => 'Khách hàng';

  @override
  String get ticketNumber => 'Mã vé';

  @override
  String get tomorrow => 'Ngày mai';

  @override
  String get cashPaymentDesc => 'Thanh toán tiền mặt trực tiếp tại quầy';

  @override
  String get momoPaymentDesc => 'Quét mã MoMo QR tại quầy';

  @override
  String get vnpayPaymentDesc => 'Thẻ ATM / VNPAY-QR';

  @override
  String get enterCashReceivedHint => 'Nhập số tiền khách đưa';

  @override
  String get insufficientCashReceived =>
      'Số tiền khách đưa không đủ thanh toán';

  @override
  String get scanSoundTitle => 'Âm báo khi quét mã';

  @override
  String get scanHapticTitle => 'Rung khi quét mã';

  @override
  String get seatUnit => 'ghế';

  @override
  String availableCountLabel(int count) {
    return 'Trống: $count';
  }

  @override
  String bookedCountLabel(int count) {
    return 'Đã đặt: $count';
  }

  @override
  String totalCountLabel(int count) {
    return 'Tổng: $count';
  }

  @override
  String get counterRevenueSubtitle => 'Doanh thu quầy';

  @override
  String get upcomingShowtimesSubtitle => 'Đang mở bán';

  @override
  String get averageSubtitle => 'Trung bình';

  @override
  String get defaultRoom => 'Phòng';

  @override
  String get format2DSubtitle => '2D Phụ đề';

  @override
  String get format2DDubbed => '2D Lồng tiếng';

  @override
  String get format3DDubbed => '3D Lồng tiếng';

  @override
  String get movieExhuma => 'Exhuma: Quật mộ trùng ma';

  @override
  String get adminBadge => 'QUẢN TRỊ VIÊN';

  @override
  String get userIdLabel => 'Mã tài khoản';

  @override
  String get roleLabel => 'Vai trò';

  @override
  String get emailPlaceholder => 'nhanvien@cineplex.vn';

  @override
  String get phonePlaceholder => '09xxxxxxxx';

  @override
  String get passwordPlaceholder => 'Nhập mật khẩu';

  @override
  String get confirmPasswordPlaceholder => 'Nhập lại mật khẩu';

  @override
  String get percentDiscountBadge => 'GIẢM %';

  @override
  String get fixedDiscountBadge => 'GIẢM TIỀN';

  @override
  String get discountTypePercentage => 'Giảm theo phần trăm (%)';

  @override
  String get discountTypeFixed => 'Giảm số tiền cố định (VNĐ)';

  @override
  String get noPromotionsSubtitle =>
      'Chưa có mã khuyến mãi nào được tạo. Nhấn nút bên dưới để tạo mã mới.';

  @override
  String get pricePlaceholder => 'Ví dụ: 65.000';

  @override
  String get stockPlaceholder => 'Ví dụ: 100';

  @override
  String get movieManagement => 'Quản lý phim';

  @override
  String get togglePasswordVisibility => 'Hiện/ẩn mật khẩu';

  @override
  String get unitVnd => 'VNĐ';

  @override
  String get unitPercent => '%';

  @override
  String get screenLabel => 'MÀN HÌNH';

  @override
  String shortMonthFormat(int month) {
    return 'T$month';
  }

  @override
  String get startTime => 'Thời gian bắt đầu';

  @override
  String get statusInactive => 'Ngưng hoạt động';

  @override
  String get exitAppTitle => 'Thoát ứng dụng';

  @override
  String get exitAppMessage => 'Bạn có chắc chắn muốn thoát ứng dụng không?';

  @override
  String get exitAppConfirm => 'Thoát';

  @override
  String get cameraPermissionRequired =>
      'Ứng dụng cần quyền truy cập máy ảnh để quét vé';

  @override
  String get grantPermission => 'Cấp quyền máy ảnh';

  @override
  String get cameraUnsupported =>
      'Thiết bị không hỗ trợ máy ảnh hoặc đang chạy giả lập. Vui lòng nhập mã vé thủ công.';

  @override
  String get addMovie => 'Thêm phim mới';

  @override
  String get updateMovie => 'Cập nhật phim';

  @override
  String get movieCreatedSuccess => 'Thêm phim thành công!';

  @override
  String get movieUpdatedSuccess => 'Cập nhật phim thành công!';

  @override
  String get movieDescription => 'Mô tả phim';

  @override
  String get enterMovieDescription => 'Nhập nội dung tóm tắt phim...';

  @override
  String get status => 'Trạng thái';

  @override
  String get stoppedShowing => 'Ngừng chiếu';

  @override
  String get editMovie => 'Chỉnh sửa phim';

  @override
  String get watchTrailer => 'Xem trailer';

  @override
  String get noTrailer => 'Chưa có trailer';

  @override
  String get movieInfo => 'Thông tin phim';

  @override
  String get copy => 'Sao chép';

  @override
  String get trailerCopied => 'Đã sao chép liên kết trailer';

  @override
  String get openInBrowser => 'Mở liên kết';

  @override
  String get cannotOpenTrailer => 'Không thể mở liên kết trailer';

  @override
  String get replayTrailer => 'Xem lại';

  @override
  String get seekBackward10s => 'Tua lại 10s';

  @override
  String get seekForward10s => 'Tua tới 10s';

  @override
  String get playPauseTrailer => 'Phát / Dừng';

  @override
  String get fullscreen => 'Toàn màn hình';

  @override
  String get exitFullscreen => 'Thu nhỏ';

  @override
  String get manageTickets => 'Quản lý vé';

  @override
  String get ticketManagement => 'Quản lý toàn bộ vé';

  @override
  String get ticketBookingList => 'Đơn đặt vé';

  @override
  String get ticketPriceConfig => 'Cấu hình giá vé';

  @override
  String get ticketBookingCode => 'Mã đơn';

  @override
  String get ticketCustomerName => 'Khách hàng';

  @override
  String get ticketShowtimeLabel => 'Suất chiếu';

  @override
  String get ticketSeatLabel => 'Ghế ngồi';

  @override
  String get ticketPaymentStatus => 'Thanh toán';

  @override
  String get ticketCheckedInStatus => 'Đã soát vé';

  @override
  String get ticketNotCheckedInStatus => 'Chưa soát vé';

  @override
  String get ticketSearchHint => 'Tìm theo mã BK, tên, SĐT...';

  @override
  String get ticketPriceWeekday => 'Ngày thường';

  @override
  String get ticketPriceWeekend => 'Cuối tuần';

  @override
  String get ticketEditPrice => 'Cập nhật giá vé';

  @override
  String get ticketPriceUpdateSuccess => 'Cập nhật giá vé thành công';

  @override
  String get ticketStatusConfirmed => 'Đã xác nhận';

  @override
  String get ticketStatusPending => 'Chờ thanh toán';

  @override
  String get ticketStatusCancelled => 'Đã hủy';

  @override
  String get ticketFilterAll => 'Tất cả';

  @override
  String get ticketConcessionsLabel => 'Bắp nước';

  @override
  String get ticketDetailTitle => 'Chi tiết đơn vé';

  @override
  String get ticketOpenScanner => 'Soát vé QR';

  @override
  String get ticketEmptyList => 'Chưa có đơn vé nào';

  @override
  String get ticketPriceEmpty => 'Chưa có cấu hình giá vé';

  @override
  String get ticketPriceEnterNew => 'Nhập giá vé mới (VNĐ)';
}
