import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'CINEPLEX'**
  String get appTitle;

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'Cineplex'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get login;

  /// No description provided for @register.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get register;

  /// No description provided for @email.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In vi, this message translates to:
  /// **'Quên mật khẩu?'**
  String get forgotPassword;

  /// No description provided for @sendOtp.
  ///
  /// In vi, this message translates to:
  /// **'Gửi mã OTP'**
  String get sendOtp;

  /// No description provided for @otpCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP'**
  String get otpCode;

  /// No description provided for @otpSent.
  ///
  /// In vi, this message translates to:
  /// **'Mã OTP đã được gửi'**
  String get otpSent;

  /// No description provided for @otpVerify.
  ///
  /// In vi, this message translates to:
  /// **'Xác thực OTP'**
  String get otpVerify;

  /// No description provided for @registerSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký thành công'**
  String get registerSuccess;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại mật khẩu thành công'**
  String get resetPasswordSuccess;

  /// No description provided for @changePassword.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu cũ'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới'**
  String get newPassword;

  /// No description provided for @logout.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn đăng xuất?'**
  String get logoutConfirm;

  /// No description provided for @rememberMe.
  ///
  /// In vi, this message translates to:
  /// **'Ghi nhớ đăng nhập'**
  String get rememberMe;

  /// No description provided for @noAccount.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản?'**
  String get haveAccount;

  /// No description provided for @emailRequired.
  ///
  /// In vi, this message translates to:
  /// **'Email không được để trống'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không được để trống'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu phải có ít nhất 6 ký tự'**
  String get passwordMinLength;

  /// No description provided for @passwordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu không khớp'**
  String get passwordMismatch;

  /// No description provided for @emailInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Email không hợp lệ'**
  String get emailInvalid;

  /// No description provided for @home.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get home;

  /// No description provided for @nowShowing.
  ///
  /// In vi, this message translates to:
  /// **'Đang chiếu'**
  String get nowShowing;

  /// No description provided for @comingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp chiếu'**
  String get comingSoon;

  /// No description provided for @audiencePick.
  ///
  /// In vi, this message translates to:
  /// **'Khán giả bình chọn'**
  String get audiencePick;

  /// No description provided for @seeAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get seeAll;

  /// No description provided for @welcome.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào'**
  String get welcome;

  /// No description provided for @totalCinemas.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số rạp'**
  String get totalCinemas;

  /// No description provided for @todayShowtimes.
  ///
  /// In vi, this message translates to:
  /// **'Suất chiếu hôm nay'**
  String get todayShowtimes;

  /// No description provided for @movies.
  ///
  /// In vi, this message translates to:
  /// **'Phim'**
  String get movies;

  /// No description provided for @movieDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết phim'**
  String get movieDetail;

  /// No description provided for @duration.
  ///
  /// In vi, this message translates to:
  /// **'Thời lượng'**
  String get duration;

  /// No description provided for @durationMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút'**
  String durationMinutes(int minutes);

  /// No description provided for @ageLimit.
  ///
  /// In vi, this message translates to:
  /// **'Độ tuổi'**
  String get ageLimit;

  /// No description provided for @genre.
  ///
  /// In vi, this message translates to:
  /// **'Thể loại'**
  String get genre;

  /// No description provided for @director.
  ///
  /// In vi, this message translates to:
  /// **'Đạo diễn'**
  String get director;

  /// No description provided for @cast.
  ///
  /// In vi, this message translates to:
  /// **'Diễn viên'**
  String get cast;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @releaseDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày khởi chiếu'**
  String get releaseDate;

  /// No description provided for @description.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung'**
  String get description;

  /// No description provided for @trailer.
  ///
  /// In vi, this message translates to:
  /// **'Trailer'**
  String get trailer;

  /// No description provided for @bookNow.
  ///
  /// In vi, this message translates to:
  /// **'Đặt vé ngay'**
  String get bookNow;

  /// No description provided for @noMovies.
  ///
  /// In vi, this message translates to:
  /// **'Không có phim nào'**
  String get noMovies;

  /// No description provided for @rating.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá'**
  String get rating;

  /// No description provided for @searchMovies.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm phim'**
  String get searchMovies;

  /// No description provided for @filterByGenre.
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo thể loại'**
  String get filterByGenre;

  /// No description provided for @allGenres.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả thể loại'**
  String get allGenres;

  /// No description provided for @selectShowtime.
  ///
  /// In vi, this message translates to:
  /// **'Chọn suất chiếu'**
  String get selectShowtime;

  /// No description provided for @selectDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày'**
  String get selectDate;

  /// No description provided for @selectCinema.
  ///
  /// In vi, this message translates to:
  /// **'Chọn rạp'**
  String get selectCinema;

  /// No description provided for @format2D.
  ///
  /// In vi, this message translates to:
  /// **'2D'**
  String get format2D;

  /// No description provided for @format3D.
  ///
  /// In vi, this message translates to:
  /// **'3D'**
  String get format3D;

  /// No description provided for @formatIMAX.
  ///
  /// In vi, this message translates to:
  /// **'IMAX'**
  String get formatIMAX;

  /// No description provided for @noShowtimes.
  ///
  /// In vi, this message translates to:
  /// **'Không có suất chiếu nào'**
  String get noShowtimes;

  /// No description provided for @showtimeAt.
  ///
  /// In vi, this message translates to:
  /// **'Suất chiếu lúc {time}'**
  String showtimeAt(String time);

  /// No description provided for @seatSelection.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ghế'**
  String get seatSelection;

  /// No description provided for @selectSeats.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn ghế'**
  String get selectSeats;

  /// No description provided for @seatStandard.
  ///
  /// In vi, this message translates to:
  /// **'Thường'**
  String get seatStandard;

  /// No description provided for @seatVIP.
  ///
  /// In vi, this message translates to:
  /// **'VIP'**
  String get seatVIP;

  /// No description provided for @seatCouple.
  ///
  /// In vi, this message translates to:
  /// **'Ghế đôi'**
  String get seatCouple;

  /// No description provided for @seatSelected.
  ///
  /// In vi, this message translates to:
  /// **'Đang chọn'**
  String get seatSelected;

  /// No description provided for @seatHeld.
  ///
  /// In vi, this message translates to:
  /// **'Đang giữ'**
  String get seatHeld;

  /// No description provided for @seatBooked.
  ///
  /// In vi, this message translates to:
  /// **'Đã đặt'**
  String get seatBooked;

  /// No description provided for @seatAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Trống'**
  String get seatAvailable;

  /// No description provided for @holdSeatExpired.
  ///
  /// In vi, this message translates to:
  /// **'Hết thời gian giữ ghế'**
  String get holdSeatExpired;

  /// No description provided for @holdTimerLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian giữ ghế:'**
  String get holdTimerLabel;

  /// No description provided for @holdTimerMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{minutes}:{seconds}'**
  String holdTimerMinutes(String minutes, String seconds);

  /// No description provided for @continueBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get continueBtn;

  /// No description provided for @maxSeatsReached.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt số lượng ghế tối đa'**
  String get maxSeatsReached;

  /// No description provided for @seatHeldByOther.
  ///
  /// In vi, this message translates to:
  /// **'Ghế đã có người chọn'**
  String get seatHeldByOther;

  /// No description provided for @seatsSelected.
  ///
  /// In vi, this message translates to:
  /// **'Các ghế đã chọn:'**
  String get seatsSelected;

  /// No description provided for @totalPrice.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tiền: {price}'**
  String totalPrice(String price);

  /// No description provided for @createBooking.
  ///
  /// In vi, this message translates to:
  /// **'Tạo đơn hàng'**
  String get createBooking;

  /// No description provided for @concessions.
  ///
  /// In vi, this message translates to:
  /// **'Bắp nước'**
  String get concessions;

  /// No description provided for @popcornDrinks.
  ///
  /// In vi, this message translates to:
  /// **'Bắp & Nước'**
  String get popcornDrinks;

  /// No description provided for @addToOrder.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào đơn'**
  String get addToOrder;

  /// No description provided for @removeFromOrder.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ khỏi đơn'**
  String get removeFromOrder;

  /// No description provided for @quantity.
  ///
  /// In vi, this message translates to:
  /// **'Số lượng'**
  String get quantity;

  /// No description provided for @subtotal.
  ///
  /// In vi, this message translates to:
  /// **'Tạm tính'**
  String get subtotal;

  /// No description provided for @skipConcession.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get skipConcession;

  /// No description provided for @skip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get skip;

  /// No description provided for @availableSeatsCount.
  ///
  /// In vi, this message translates to:
  /// **'{available}/{total} ghế'**
  String availableSeatsCount(int available, int total);

  /// No description provided for @concessionTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng bắp nước'**
  String get concessionTotal;

  /// No description provided for @checkout.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get checkout;

  /// No description provided for @orderSummary.
  ///
  /// In vi, this message translates to:
  /// **'Tóm tắt đơn hàng'**
  String get orderSummary;

  /// No description provided for @paymentMethod.
  ///
  /// In vi, this message translates to:
  /// **'Phương thức thanh toán'**
  String get paymentMethod;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In vi, this message translates to:
  /// **'Chọn phương thức thanh toán'**
  String get selectPaymentMethod;

  /// No description provided for @momo.
  ///
  /// In vi, this message translates to:
  /// **'Ví MoMo'**
  String get momo;

  /// No description provided for @vnpay.
  ///
  /// In vi, this message translates to:
  /// **'VNPAY'**
  String get vnpay;

  /// No description provided for @paypal.
  ///
  /// In vi, this message translates to:
  /// **'PayPal'**
  String get paypal;

  /// No description provided for @cash.
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt'**
  String get cash;

  /// No description provided for @payNow.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán ngay'**
  String get payNow;

  /// No description provided for @processing.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý...'**
  String get processing;

  /// No description provided for @paymentSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thành công'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thất bại'**
  String get paymentFailed;

  /// No description provided for @paymentPending.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ thanh toán'**
  String get paymentPending;

  /// No description provided for @paymentExpired.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán hết hạn'**
  String get paymentExpired;

  /// No description provided for @bookingCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã đặt vé'**
  String get bookingCode;

  /// No description provided for @secondsRemaining.
  ///
  /// In vi, this message translates to:
  /// **'{seconds} giây'**
  String secondsRemaining(int seconds);

  /// No description provided for @loyaltyPoints.
  ///
  /// In vi, this message translates to:
  /// **'Điểm tích luỹ'**
  String get loyaltyPoints;

  /// No description provided for @usePoints.
  ///
  /// In vi, this message translates to:
  /// **'Sử dụng điểm'**
  String get usePoints;

  /// No description provided for @pointsDiscount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá từ điểm'**
  String get pointsDiscount;

  /// No description provided for @maxPointsDiscount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm tối đa'**
  String get maxPointsDiscount;

  /// No description provided for @totalAmount.
  ///
  /// In vi, this message translates to:
  /// **'Tổng cộng'**
  String get totalAmount;

  /// No description provided for @discountAmount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá'**
  String get discountAmount;

  /// No description provided for @ticketTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tiền vé'**
  String get ticketTotal;

  /// No description provided for @concessionTotalLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tiền bắp nước'**
  String get concessionTotalLabel;

  /// No description provided for @promotionCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi'**
  String get promotionCode;

  /// No description provided for @applyPromotion.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get applyPromotion;

  /// No description provided for @promotionApplied.
  ///
  /// In vi, this message translates to:
  /// **'Đã áp dụng mã khuyến mãi'**
  String get promotionApplied;

  /// No description provided for @promotionInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi không hợp lệ'**
  String get promotionInvalid;

  /// No description provided for @redeemWithPoints.
  ///
  /// In vi, this message translates to:
  /// **'Đổi điểm'**
  String get redeemWithPoints;

  /// No description provided for @myTickets.
  ///
  /// In vi, this message translates to:
  /// **'Vé của tôi'**
  String get myTickets;

  /// No description provided for @ticketDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết vé'**
  String get ticketDetail;

  /// No description provided for @qrCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã QR'**
  String get qrCode;

  /// No description provided for @seatInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin ghế'**
  String get seatInfo;

  /// No description provided for @noTickets.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có vé nào'**
  String get noTickets;

  /// No description provided for @checkedIn.
  ///
  /// In vi, this message translates to:
  /// **'Đã check-in'**
  String get checkedIn;

  /// No description provided for @checkedInAt.
  ///
  /// In vi, this message translates to:
  /// **'Check-in lúc {time}'**
  String checkedInAt(String time);

  /// No description provided for @notCheckedIn.
  ///
  /// In vi, this message translates to:
  /// **'Chưa check-in'**
  String get notCheckedIn;

  /// No description provided for @ticketActive.
  ///
  /// In vi, this message translates to:
  /// **'Khả dụng'**
  String get ticketActive;

  /// No description provided for @ticketUsed.
  ///
  /// In vi, this message translates to:
  /// **'Đã sử dụng'**
  String get ticketUsed;

  /// No description provided for @ticketCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get ticketCancelled;

  /// No description provided for @upcomingTickets.
  ///
  /// In vi, this message translates to:
  /// **'Sắp diễn ra'**
  String get upcomingTickets;

  /// No description provided for @pastTickets.
  ///
  /// In vi, this message translates to:
  /// **'Đã qua'**
  String get pastTickets;

  /// No description provided for @bookingHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử đặt vé'**
  String get bookingHistory;

  /// No description provided for @notifications.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In vi, this message translates to:
  /// **'Không có thông báo nào'**
  String get noNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In vi, this message translates to:
  /// **'Đánh dấu tất cả đã đọc'**
  String get markAllRead;

  /// No description provided for @unreadCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} chưa đọc'**
  String unreadCount(int count);

  /// No description provided for @notificationTicketConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đặt vé'**
  String get notificationTicketConfirm;

  /// No description provided for @notificationPromotion.
  ///
  /// In vi, this message translates to:
  /// **'Khuyến mãi'**
  String get notificationPromotion;

  /// No description provided for @notificationReminder.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở'**
  String get notificationReminder;

  /// No description provided for @notificationSystem.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống'**
  String get notificationSystem;

  /// No description provided for @notificationPaymentFailed.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thất bại'**
  String get notificationPaymentFailed;

  /// No description provided for @profile.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa thông tin'**
  String get editProfile;

  /// No description provided for @fullName.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullName;

  /// No description provided for @phone.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get phone;

  /// No description provided for @gender.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get gender;

  /// No description provided for @dateOfBirth.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sinh'**
  String get dateOfBirth;

  /// No description provided for @male.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get male;

  /// No description provided for @female.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get female;

  /// No description provided for @other.
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get other;

  /// No description provided for @saveChanges.
  ///
  /// In vi, this message translates to:
  /// **'Lưu thay đổi'**
  String get saveChanges;

  /// No description provided for @profileUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật thành công'**
  String get profileUpdated;

  /// No description provided for @loyaltyInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin thẻ thành viên'**
  String get loyaltyInfo;

  /// No description provided for @earnRate.
  ///
  /// In vi, this message translates to:
  /// **'Tỉ lệ tích điểm'**
  String get earnRate;

  /// No description provided for @pointValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị điểm'**
  String get pointValue;

  /// No description provided for @settings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tối'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ sáng'**
  String get lightMode;

  /// No description provided for @vietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @english.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @appVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản ứng dụng'**
  String get appVersion;

  /// No description provided for @about.
  ///
  /// In vi, this message translates to:
  /// **'Về chúng tôi'**
  String get about;

  /// No description provided for @staffDashboard.
  ///
  /// In vi, this message translates to:
  /// **'Bảng điều khiển nhân viên'**
  String get staffDashboard;

  /// No description provided for @qrScanner.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã QR'**
  String get qrScanner;

  /// No description provided for @scanTicket.
  ///
  /// In vi, this message translates to:
  /// **'Quét vé'**
  String get scanTicket;

  /// No description provided for @scanResult.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả quét'**
  String get scanResult;

  /// No description provided for @ticketValid.
  ///
  /// In vi, this message translates to:
  /// **'Vé hợp lệ'**
  String get ticketValid;

  /// No description provided for @ticketInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Vé không hợp lệ'**
  String get ticketInvalid;

  /// No description provided for @ticketAlreadyChecked.
  ///
  /// In vi, this message translates to:
  /// **'Vé đã được kiểm tra'**
  String get ticketAlreadyChecked;

  /// No description provided for @counterSale.
  ///
  /// In vi, this message translates to:
  /// **'Bán tại quầy'**
  String get counterSale;

  /// No description provided for @selectCustomer.
  ///
  /// In vi, this message translates to:
  /// **'Chọn khách hàng'**
  String get selectCustomer;

  /// No description provided for @searchCustomer.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm khách hàng'**
  String get searchCustomer;

  /// No description provided for @statistics.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê'**
  String get statistics;

  /// No description provided for @revenue.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu'**
  String get revenue;

  /// No description provided for @revenueReport.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo doanh thu'**
  String get revenueReport;

  /// No description provided for @movieStats.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê phim'**
  String get movieStats;

  /// No description provided for @systemSummary.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan hệ thống'**
  String get systemSummary;

  /// No description provided for @timeFrame.
  ///
  /// In vi, this message translates to:
  /// **'Khung thời gian'**
  String get timeFrame;

  /// No description provided for @day.
  ///
  /// In vi, this message translates to:
  /// **'Ngày'**
  String get day;

  /// No description provided for @week.
  ///
  /// In vi, this message translates to:
  /// **'Tuần'**
  String get week;

  /// No description provided for @month.
  ///
  /// In vi, this message translates to:
  /// **'Tháng'**
  String get month;

  /// No description provided for @year.
  ///
  /// In vi, this message translates to:
  /// **'Năm'**
  String get year;

  /// No description provided for @ticketsSold.
  ///
  /// In vi, this message translates to:
  /// **'Số vé đã bán'**
  String get ticketsSold;

  /// No description provided for @occupancyRate.
  ///
  /// In vi, this message translates to:
  /// **'Tỉ lệ lấp đầy'**
  String get occupancyRate;

  /// No description provided for @activeMovies.
  ///
  /// In vi, this message translates to:
  /// **'Phim đang chiếu'**
  String get activeMovies;

  /// No description provided for @totalRevenue.
  ///
  /// In vi, this message translates to:
  /// **'Tổng doanh thu'**
  String get totalRevenue;

  /// No description provided for @loading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In vi, this message translates to:
  /// **'Đã xảy ra lỗi'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get back;

  /// No description provided for @next.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp theo'**
  String get next;

  /// No description provided for @search.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get search;

  /// No description provided for @noData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu'**
  String get noData;

  /// No description provided for @noInternet.
  ///
  /// In vi, this message translates to:
  /// **'Không có kết nối mạng'**
  String get noInternet;

  /// No description provided for @serverError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi máy chủ'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi không xác định'**
  String get unknownError;

  /// No description provided for @success.
  ///
  /// In vi, this message translates to:
  /// **'Thành công'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin'**
  String get info;

  /// No description provided for @close.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In vi, this message translates to:
  /// **'Đồng ý'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In vi, this message translates to:
  /// **'Có'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In vi, this message translates to:
  /// **'Không'**
  String get no;

  /// No description provided for @refresh.
  ///
  /// In vi, this message translates to:
  /// **'Làm mới'**
  String get refresh;

  /// No description provided for @more.
  ///
  /// In vi, this message translates to:
  /// **'Thêm'**
  String get more;

  /// No description provided for @less.
  ///
  /// In vi, this message translates to:
  /// **'Ẩn bớt'**
  String get less;

  /// No description provided for @viewAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get viewAll;

  /// No description provided for @selectAll.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tất cả'**
  String get selectAll;

  /// No description provided for @clear.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại'**
  String get reset;

  /// No description provided for @seatCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} ghế đã chọn'**
  String seatCount(int count);

  /// No description provided for @priceFormat.
  ///
  /// In vi, this message translates to:
  /// **'{price}'**
  String priceFormat(String price);

  /// No description provided for @dateFormat.
  ///
  /// In vi, this message translates to:
  /// **'{date}'**
  String dateFormat(String date);

  /// No description provided for @fullNameRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ và tên'**
  String get fullNameRequired;

  /// No description provided for @loyaltyPolicyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách tích & tiêu điểm'**
  String get loyaltyPolicyTitle;

  /// No description provided for @loyaltyPolicyEarn.
  ///
  /// In vi, this message translates to:
  /// **'Tích lũy: Nhận ngay 10% giá trị đơn hàng sau khi thanh toán thành công.'**
  String get loyaltyPolicyEarn;

  /// No description provided for @loyaltyPolicyDiscount.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá: Dùng điểm giảm giá tối đa 20% tổng đơn (1 điểm = 1 VNĐ).'**
  String get loyaltyPolicyDiscount;

  /// No description provided for @loyaltyPolicyGifts.
  ///
  /// In vi, this message translates to:
  /// **'Đổi quà: Dùng điểm quy đổi các Combo bắp nước miễn phí.'**
  String get loyaltyPolicyGifts;

  /// No description provided for @currentPointsBalance.
  ///
  /// In vi, this message translates to:
  /// **'Số dư điểm hiện tại:'**
  String get currentPointsBalance;

  /// No description provided for @pointsSuffix.
  ///
  /// In vi, this message translates to:
  /// **'điểm'**
  String get pointsSuffix;

  /// No description provided for @managementSection.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý & Nghiệp vụ'**
  String get managementSection;

  /// No description provided for @userManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý người dùng'**
  String get userManagement;

  /// No description provided for @scanBookingCodeWarning.
  ///
  /// In vi, this message translates to:
  /// **'Đây là mã đặt vé (BK-), vui lòng quét mã QR của từng vé (bắt đầu bằng TKT-).'**
  String get scanBookingCodeWarning;

  /// No description provided for @scanAlreadyCheckedIn.
  ///
  /// In vi, this message translates to:
  /// **'Vé này đã được soát trước đó!'**
  String get scanAlreadyCheckedIn;

  /// No description provided for @scanTicketNotActive.
  ///
  /// In vi, this message translates to:
  /// **'Vé không còn hiệu lực!'**
  String get scanTicketNotActive;

  /// No description provided for @scanTicketNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy vé trong hệ thống!'**
  String get scanTicketNotFound;

  /// No description provided for @scanSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Soát vé thành công'**
  String get scanSuccess;

  /// No description provided for @manualTicketInput.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã vé thủ công (TKT-...)'**
  String get manualTicketInput;

  /// No description provided for @verifyTicket.
  ///
  /// In vi, this message translates to:
  /// **'Soát vé'**
  String get verifyTicket;

  /// No description provided for @searchUser.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm theo email hoặc số điện thoại'**
  String get searchUser;

  /// No description provided for @blockUser.
  ///
  /// In vi, this message translates to:
  /// **'Khóa tài khoản'**
  String get blockUser;

  /// No description provided for @unblockUser.
  ///
  /// In vi, this message translates to:
  /// **'Mở khóa'**
  String get unblockUser;

  /// No description provided for @confirmBlockUser.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn khóa tài khoản này?'**
  String get confirmBlockUser;

  /// No description provided for @confirmUnblockUser.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn mở khóa tài khoản này?'**
  String get confirmUnblockUser;

  /// No description provided for @userStatusUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật trạng thái người dùng thành công'**
  String get userStatusUpdated;

  /// No description provided for @revenueTrend.
  ///
  /// In vi, this message translates to:
  /// **'Xu hướng doanh thu'**
  String get revenueTrend;

  /// No description provided for @moviePerformance.
  ///
  /// In vi, this message translates to:
  /// **'Hiệu suất phim'**
  String get moviePerformance;

  /// No description provided for @ticketsSoldCol.
  ///
  /// In vi, this message translates to:
  /// **'Vé bán'**
  String get ticketsSoldCol;

  /// No description provided for @revenueCol.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu'**
  String get revenueCol;

  /// No description provided for @allMonths.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả các tháng'**
  String get allMonths;

  /// No description provided for @monthFormat.
  ///
  /// In vi, this message translates to:
  /// **'Tháng {month}'**
  String monthFormat(int month);

  /// No description provided for @ticketListEmptyPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có vé xem phim nào'**
  String get ticketListEmptyPrompt;

  /// No description provided for @selectGender.
  ///
  /// In vi, this message translates to:
  /// **'Chọn giới tính'**
  String get selectGender;

  /// No description provided for @phoneInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại không hợp lệ'**
  String get phoneInvalid;

  /// No description provided for @orderStatus.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get orderStatus;

  /// No description provided for @orderCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã đơn hàng'**
  String get orderCode;

  /// No description provided for @screeningRoom.
  ///
  /// In vi, this message translates to:
  /// **'Phòng chiếu'**
  String get screeningRoom;

  /// No description provided for @totalUsersCount.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số: {count}'**
  String totalUsersCount(int count);

  /// No description provided for @blockedUsersCount.
  ///
  /// In vi, this message translates to:
  /// **'Đã khóa: {count}'**
  String blockedUsersCount(int count);

  /// No description provided for @noMatchingUsers.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy người dùng phù hợp'**
  String get noMatchingUsers;

  /// No description provided for @confirmBlockUserWithName.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn khóa tài khoản {name}? Người dùng sẽ không thể đăng nhập hoặc đặt vé.'**
  String confirmBlockUserWithName(String name);

  /// No description provided for @confirmUnblockUserWithName.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn mở khóa tài khoản {name}?'**
  String confirmUnblockUserWithName(String name);

  /// No description provided for @qrCodeAvailableAfterPayment.
  ///
  /// In vi, this message translates to:
  /// **'Mã QR chỉ khả dụng sau khi đơn hàng được thanh toán thành công.'**
  String get qrCodeAvailableAfterPayment;

  /// No description provided for @noRevenueInPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Không có phát sinh doanh thu trong giai đoạn này'**
  String get noRevenueInPeriod;

  /// No description provided for @scanSuccessDetail.
  ///
  /// In vi, this message translates to:
  /// **'{successMsg}!\nGhế: {seat} • Mã: {code}'**
  String scanSuccessDetail(String successMsg, String seat, String code);

  /// No description provided for @scanTicketSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Soát vé vào phòng chiếu'**
  String get scanTicketSubtitle;

  /// No description provided for @userManagementSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách & Quản lý tài khoản'**
  String get userManagementSubtitle;

  /// No description provided for @statisticsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo & Thống kê doanh thu'**
  String get statisticsSubtitle;

  /// No description provided for @accessDenied.
  ///
  /// In vi, this message translates to:
  /// **'Truy cập bị từ chối. Không đủ quyền hạn.'**
  String get accessDenied;

  /// No description provided for @adminDashboard.
  ///
  /// In vi, this message translates to:
  /// **'Bảng điều khiển Quản trị'**
  String get adminDashboard;

  /// No description provided for @adminPortal.
  ///
  /// In vi, this message translates to:
  /// **'Cổng Quản trị Hệ thống'**
  String get adminPortal;

  /// No description provided for @counterSaleDesc.
  ///
  /// In vi, this message translates to:
  /// **'Bán vé & Thanh toán'**
  String get counterSaleDesc;

  /// No description provided for @screen.
  ///
  /// In vi, this message translates to:
  /// **'MÀN HÌNH'**
  String get screen;

  /// No description provided for @popcornOnly.
  ///
  /// In vi, this message translates to:
  /// **'Bắp rang bơ'**
  String get popcornOnly;

  /// No description provided for @largeDrinkOnly.
  ///
  /// In vi, this message translates to:
  /// **'Nước ngọt lớn'**
  String get largeDrinkOnly;

  /// No description provided for @combo1Popcorn2Drinks.
  ///
  /// In vi, this message translates to:
  /// **'Combo 1 bắp 2 nước'**
  String get combo1Popcorn2Drinks;

  /// No description provided for @movieTicket.
  ///
  /// In vi, this message translates to:
  /// **'Vé xem phim ({count} ghế)'**
  String movieTicket(int count);

  /// No description provided for @discountPointsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giảm giá (Điểm)'**
  String get discountPointsTitle;

  /// No description provided for @enterPoints.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số điểm'**
  String get enterPoints;

  /// No description provided for @loyaltyPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng có {points} điểm. Dùng điểm để giảm giá?'**
  String loyaltyPrompt(String points);

  /// No description provided for @paymentSuccessPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thành công. Đã tạo mã vé {code}.'**
  String paymentSuccessPrompt(String code);

  /// No description provided for @cineplexDistrict1.
  ///
  /// In vi, this message translates to:
  /// **'Cineplex Quận 1'**
  String get cineplexDistrict1;

  /// No description provided for @today.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get today;

  /// No description provided for @roomPrefix.
  ///
  /// In vi, this message translates to:
  /// **'Phòng {id}'**
  String roomPrefix(String id);

  /// No description provided for @standard2D.
  ///
  /// In vi, this message translates to:
  /// **'Standard • 2D'**
  String get standard2D;

  /// No description provided for @manageShowtimes.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý Suất chiếu'**
  String get manageShowtimes;

  /// No description provided for @addShowtime.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Suất chiếu'**
  String get addShowtime;

  /// No description provided for @editShowtime.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa Suất chiếu'**
  String get editShowtime;

  /// No description provided for @filterByDate.
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo ngày'**
  String get filterByDate;

  /// No description provided for @noShowtimesFound.
  ///
  /// In vi, this message translates to:
  /// **'Không có suất chiếu nào.'**
  String get noShowtimesFound;

  /// No description provided for @confirmDelete.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận xóa'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteShowtimeDesc.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa suất chiếu này không?'**
  String get confirmDeleteShowtimeDesc;

  /// No description provided for @unknownMovie.
  ///
  /// In vi, this message translates to:
  /// **'Phim không xác định'**
  String get unknownMovie;

  /// No description provided for @emptyRoom.
  ///
  /// In vi, this message translates to:
  /// **'Phòng trống'**
  String get emptyRoom;

  /// No description provided for @statusScheduled.
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp'**
  String get statusScheduled;

  /// No description provided for @statusBooking.
  ///
  /// In vi, this message translates to:
  /// **'Mở bán'**
  String get statusBooking;

  /// No description provided for @statusFull.
  ///
  /// In vi, this message translates to:
  /// **'Kín chỗ'**
  String get statusFull;

  /// No description provided for @statusCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get statusCancelled;

  /// No description provided for @statusCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get statusCompleted;

  /// No description provided for @updateSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật thành công!'**
  String get updateSuccess;

  /// No description provided for @addSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thêm suất chiếu thành công!'**
  String get addSuccess;

  /// No description provided for @fillRequiredFields.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng điền đầy đủ thông tin bắt buộc'**
  String get fillRequiredFields;

  /// No description provided for @movieLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phim'**
  String get movieLabel;

  /// No description provided for @selectMovieReq.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn phim'**
  String get selectMovieReq;

  /// No description provided for @cinemaLabel.
  ///
  /// In vi, this message translates to:
  /// **'Rạp'**
  String get cinemaLabel;

  /// No description provided for @selectCinemaReq.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn rạp'**
  String get selectCinemaReq;

  /// No description provided for @roomLabel.
  ///
  /// In vi, this message translates to:
  /// **'Phòng chiếu'**
  String get roomLabel;

  /// No description provided for @selectRoomReq.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn phòng chiếu'**
  String get selectRoomReq;

  /// No description provided for @formatLabel.
  ///
  /// In vi, this message translates to:
  /// **'Định dạng'**
  String get formatLabel;

  /// No description provided for @statusLabel.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get statusLabel;

  /// No description provided for @selectStartTimeReq.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng chọn thời gian bắt đầu'**
  String get selectStartTimeReq;

  /// No description provided for @createShowtimeBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tạo suất chiếu'**
  String get createShowtimeBtn;

  /// No description provided for @manageCinemas.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý Rạp'**
  String get manageCinemas;

  /// No description provided for @addCinema.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Rạp'**
  String get addCinema;

  /// No description provided for @editCinema.
  ///
  /// In vi, this message translates to:
  /// **'Sửa Rạp'**
  String get editCinema;

  /// No description provided for @cinemaName.
  ///
  /// In vi, this message translates to:
  /// **'Tên rạp'**
  String get cinemaName;

  /// No description provided for @address.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ'**
  String get address;

  /// No description provided for @roomCount.
  ///
  /// In vi, this message translates to:
  /// **'Số phòng'**
  String get roomCount;

  /// No description provided for @manageRooms.
  ///
  /// In vi, this message translates to:
  /// **'Phòng chiếu'**
  String get manageRooms;

  /// No description provided for @addRoom.
  ///
  /// In vi, this message translates to:
  /// **'Thêm phòng'**
  String get addRoom;

  /// No description provided for @editRoom.
  ///
  /// In vi, this message translates to:
  /// **'Sửa phòng'**
  String get editRoom;

  /// No description provided for @roomName.
  ///
  /// In vi, this message translates to:
  /// **'Tên phòng'**
  String get roomName;

  /// No description provided for @roomType.
  ///
  /// In vi, this message translates to:
  /// **'Loại phòng'**
  String get roomType;

  /// No description provided for @noCinemas.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có rạp nào.'**
  String get noCinemas;

  /// No description provided for @noRooms.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có phòng nào.'**
  String get noRooms;

  /// No description provided for @confirmDeleteCinema.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa rạp này không?'**
  String get confirmDeleteCinema;

  /// No description provided for @confirmDeleteRoom.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa phòng chiếu này không?'**
  String get confirmDeleteRoom;

  /// No description provided for @managePromotions.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý Khuyến mãi'**
  String get managePromotions;

  /// No description provided for @addPromotion.
  ///
  /// In vi, this message translates to:
  /// **'Thêm Khuyến mãi'**
  String get addPromotion;

  /// No description provided for @editPromotion.
  ///
  /// In vi, this message translates to:
  /// **'Sửa Khuyến mãi'**
  String get editPromotion;

  /// No description provided for @promoCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi'**
  String get promoCode;

  /// No description provided for @promoDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả'**
  String get promoDescription;

  /// No description provided for @discountType.
  ///
  /// In vi, this message translates to:
  /// **'Loại giảm giá'**
  String get discountType;

  /// No description provided for @discountValue.
  ///
  /// In vi, this message translates to:
  /// **'Mức giảm'**
  String get discountValue;

  /// No description provided for @percentage.
  ///
  /// In vi, this message translates to:
  /// **'Phần trăm (%)'**
  String get percentage;

  /// No description provided for @fixedAmount.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền cố định'**
  String get fixedAmount;

  /// No description provided for @maxUsage.
  ///
  /// In vi, this message translates to:
  /// **'Số lần dùng tối đa'**
  String get maxUsage;

  /// No description provided for @noPromotions.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có khuyến mãi nào.'**
  String get noPromotions;

  /// No description provided for @confirmDeletePromotion.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn xóa mã khuyến mãi này không?'**
  String get confirmDeletePromotion;

  /// No description provided for @startDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc'**
  String get endDate;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
