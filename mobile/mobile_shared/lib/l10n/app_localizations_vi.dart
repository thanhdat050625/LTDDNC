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
  String get staffDashboard => 'Bảng điều khiển nhân viên';

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
  String get userManagementSubtitle => 'Danh sách & Quản lý tài khoản';

  @override
  String get statisticsSubtitle => 'Báo cáo & Thống kê doanh thu';

  @override
  String get accessDenied => 'Truy cập bị từ chối. Không đủ quyền hạn.';

  @override
  String get adminDashboard => 'Bảng điều khiển Quản trị';

  @override
  String get adminPortal => 'Cổng Quản trị Hệ thống';

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
}
