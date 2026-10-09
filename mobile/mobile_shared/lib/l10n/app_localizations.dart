import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

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
  static const List<Locale> supportedLocales = <Locale>[Locale('vi')];

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

  /// No description provided for @changePasswordSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đổi mật khẩu thành công'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordDescription.
  ///
  /// In vi, this message translates to:
  /// **'Để bảo mật tài khoản, vui lòng nhập mật khẩu cũ và đặt mật khẩu mới có ít nhất 6 ký tự.'**
  String get changePasswordDescription;

  /// No description provided for @oldPasswordRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu cũ'**
  String get oldPasswordRequired;

  /// No description provided for @newPasswordRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập mật khẩu mới'**
  String get newPasswordRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xác nhận mật khẩu mới'**
  String get confirmPasswordRequired;

  /// No description provided for @newPasswordSameAsOld.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu mới phải khác mật khẩu cũ'**
  String get newPasswordSameAsOld;

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

  /// No description provided for @movieSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm phim...'**
  String get movieSearchHint;

  /// No description provided for @movieNowShowing.
  ///
  /// In vi, this message translates to:
  /// **'Đang chiếu'**
  String get movieNowShowing;

  /// No description provided for @movieComingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp chiếu'**
  String get movieComingSoon;

  /// No description provided for @movieAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get movieAll;

  /// No description provided for @movieNoResults.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy phim phù hợp'**
  String get movieNoResults;

  /// No description provided for @movieSearchError.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi khi tải danh sách phim'**
  String get movieSearchError;

  /// No description provided for @movieFilterStatus.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get movieFilterStatus;

  /// No description provided for @movieFilterGenre.
  ///
  /// In vi, this message translates to:
  /// **'Thể loại'**
  String get movieFilterGenre;

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

  /// No description provided for @seatMapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sơ đồ phòng chiếu'**
  String get seatMapTitle;

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

  /// No description provided for @seatNormal.
  ///
  /// In vi, this message translates to:
  /// **'Thường'**
  String get seatNormal;

  /// No description provided for @seatVIP.
  ///
  /// In vi, this message translates to:
  /// **'VIP'**
  String get seatVIP;

  /// No description provided for @seatVip.
  ///
  /// In vi, this message translates to:
  /// **'VIP'**
  String get seatVip;

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

  /// No description provided for @seatMaxSelection.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chỉ có thể chọn tối đa 8 ghế.'**
  String get seatMaxSelection;

  /// No description provided for @seatLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải sơ đồ ghế'**
  String get seatLoadError;

  /// No description provided for @seatEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy sơ đồ ghế cho suất chiếu này.'**
  String get seatEmpty;

  /// No description provided for @seatReleaseError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể nhả ghế, vui lòng thử lại'**
  String get seatReleaseError;

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

  /// No description provided for @bookingSeatAlreadyHeld.
  ///
  /// In vi, this message translates to:
  /// **'Ghế đã có người giữ hoặc đã được đặt'**
  String get bookingSeatAlreadyHeld;

  /// No description provided for @bookingMaxSeatsExceeded.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ được chọn tối đa 8 ghế mỗi đơn hàng'**
  String get bookingMaxSeatsExceeded;

  /// No description provided for @bookingShowtimeExpired.
  ///
  /// In vi, this message translates to:
  /// **'Suất chiếu đã bắt đầu hoặc không còn khả dụng'**
  String get bookingShowtimeExpired;

  /// No description provided for @bookingSeatRoomMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Ghế được chọn không thuộc phòng chiếu này'**
  String get bookingSeatRoomMismatch;

  /// No description provided for @bookingHoldExpired.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đặt vé đã hết thời gian giữ chỗ'**
  String get bookingHoldExpired;

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

  /// No description provided for @removePromotion.
  ///
  /// In vi, this message translates to:
  /// **'Gỡ bỏ'**
  String get removePromotion;

  /// No description provided for @promotionApplied.
  ///
  /// In vi, this message translates to:
  /// **'Đã áp dụng mã khuyến mãi'**
  String get promotionApplied;

  /// No description provided for @promotionRemoved.
  ///
  /// In vi, this message translates to:
  /// **'Đã gỡ bỏ mã khuyến mãi'**
  String get promotionRemoved;

  /// No description provided for @promotionInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi không hợp lệ'**
  String get promotionInvalid;

  /// No description provided for @promoNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi không tồn tại'**
  String get promoNotFound;

  /// No description provided for @promoInactive.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi đã ngưng hoạt động'**
  String get promoInactive;

  /// No description provided for @promoExpired.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi đã hết hạn hoặc chưa bắt đầu'**
  String get promoExpired;

  /// No description provided for @promoMaxUsage.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi đã hết lượt sử dụng'**
  String get promoMaxUsage;

  /// No description provided for @promoMovieMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi không áp dụng cho phim này'**
  String get promoMovieMismatch;

  /// No description provided for @promoOrderTotalZero.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng có tổng tiền bằng 0 không thể áp dụng mã'**
  String get promoOrderTotalZero;

  /// No description provided for @promoBookingNotPending.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng không ở trạng thái chờ thanh toán'**
  String get promoBookingNotPending;

  /// No description provided for @promoBookingExpired.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng đã hết hạn thanh toán'**
  String get promoBookingExpired;

  /// No description provided for @retryPayment.
  ///
  /// In vi, this message translates to:
  /// **'Đổi phương thức thanh toán'**
  String get retryPayment;

  /// No description provided for @reselectSeats.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại chọn ghế'**
  String get reselectSeats;

  /// No description provided for @concessionUpdateFailed.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật bắp nước thất bại'**
  String get concessionUpdateFailed;

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

  /// No description provided for @notificationAccount.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get notificationAccount;

  /// No description provided for @notificationDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết thông báo'**
  String get notificationDetail;

  /// No description provided for @notificationOpenLink.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết liên kết'**
  String get notificationOpenLink;

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
  /// **'Tổng quan'**
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

  /// No description provided for @loyaltyPolicyRefund.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn điểm: Điểm đã dùng sẽ được tự động hoàn trả 100% khi đơn hàng bị hủy hoặc quá thời gian giữ chỗ.'**
  String get loyaltyPolicyRefund;

  /// No description provided for @loyaltyPolicyVoucher.
  ///
  /// In vi, this message translates to:
  /// **'Ưu đãi kép: Được phép áp dụng đồng thời điểm tích lũy và mã voucher giảm giá.'**
  String get loyaltyPolicyVoucher;

  /// No description provided for @loyaltyTabHistory.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử điểm'**
  String get loyaltyTabHistory;

  /// No description provided for @loyaltyTabPolicy.
  ///
  /// In vi, this message translates to:
  /// **'Quy chế tích & tiêu'**
  String get loyaltyTabPolicy;

  /// No description provided for @loyaltyNoHistory.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có giao dịch điểm nào'**
  String get loyaltyNoHistory;

  /// No description provided for @loyaltyNoHistorySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hãy đặt vé xem phim để bắt đầu tích lũy điểm thưởng nhé!'**
  String get loyaltyNoHistorySubtitle;

  /// No description provided for @loyaltyCardSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thành viên thân thiết'**
  String get loyaltyCardSubtitle;

  /// No description provided for @loyaltyTotalPoints.
  ///
  /// In vi, this message translates to:
  /// **'Tổng điểm khả dụng'**
  String get loyaltyTotalPoints;

  /// No description provided for @loyaltyTransactionDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết giao dịch điểm'**
  String get loyaltyTransactionDetail;

  /// No description provided for @loyaltyViewTicket.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết vé'**
  String get loyaltyViewTicket;

  /// No description provided for @loyaltyPointsChange.
  ///
  /// In vi, this message translates to:
  /// **'Biến động điểm'**
  String get loyaltyPointsChange;

  /// No description provided for @loyaltyOrderCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã đơn hàng'**
  String get loyaltyOrderCode;

  /// No description provided for @loyaltyTransactionTime.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian giao dịch'**
  String get loyaltyTransactionTime;

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

  /// No description provided for @moviePerformance.
  ///
  /// In vi, this message translates to:
  /// **'Top phim bán chạy'**
  String get moviePerformance;

  /// No description provided for @ticketsSoldCol.
  ///
  /// In vi, this message translates to:
  /// **'Vé bán'**
  String get ticketsSoldCol;

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

  /// No description provided for @staffLoginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản Lý Rạp'**
  String get staffLoginTitle;

  /// No description provided for @staffLoginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhân Viên'**
  String get staffLoginSubtitle;

  /// No description provided for @adminLoginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản Trị Hệ Thống'**
  String get adminLoginTitle;

  /// No description provided for @adminLoginSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Admin'**
  String get adminLoginSubtitle;

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

  /// No description provided for @showtimeTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng suất chiếu'**
  String get showtimeTotal;

  /// No description provided for @showtimeBooking.
  ///
  /// In vi, this message translates to:
  /// **'Đang mở bán'**
  String get showtimeBooking;

  /// No description provided for @showtimeScheduled.
  ///
  /// In vi, this message translates to:
  /// **'Sắp chiếu'**
  String get showtimeScheduled;

  /// No description provided for @showtimeCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get showtimeCancelled;

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
  /// **'Đã lên lịch'**
  String get statusScheduled;

  /// No description provided for @statusBooking.
  ///
  /// In vi, this message translates to:
  /// **'Đang chiếu'**
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
  /// **'Đã kết thúc'**
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

  /// No description provided for @showtimeBulkCreate.
  ///
  /// In vi, this message translates to:
  /// **'Tạo lịch tự động'**
  String get showtimeBulkCreate;

  /// No description provided for @showtimeBulkCreateTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo Lịch Chiếu Hàng Loạt'**
  String get showtimeBulkCreateTitle;

  /// No description provided for @showtimeBulkStartDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày bắt đầu'**
  String get showtimeBulkStartDate;

  /// No description provided for @showtimeBulkEndDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc'**
  String get showtimeBulkEndDate;

  /// No description provided for @showtimeBulkSelectDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày'**
  String get showtimeBulkSelectDate;

  /// No description provided for @showtimeBulkPrimaryRoom.
  ///
  /// In vi, this message translates to:
  /// **'Phòng ưu tiên (Tùy chọn)'**
  String get showtimeBulkPrimaryRoom;

  /// No description provided for @showtimeBulkAutoAssignRoom.
  ///
  /// In vi, this message translates to:
  /// **'Tự động phân phòng'**
  String get showtimeBulkAutoAssignRoom;

  /// No description provided for @showtimeBulkPreShowMinutes.
  ///
  /// In vi, this message translates to:
  /// **'QC/Trailer (phút)'**
  String get showtimeBulkPreShowMinutes;

  /// No description provided for @showtimeBulkPostBufferMinutes.
  ///
  /// In vi, this message translates to:
  /// **'Dọn rạp (phút)'**
  String get showtimeBulkPostBufferMinutes;

  /// No description provided for @showtimeBulkTimeSlots.
  ///
  /// In vi, this message translates to:
  /// **'Khung giờ chiếu'**
  String get showtimeBulkTimeSlots;

  /// No description provided for @showtimeBulkAddTimeSlot.
  ///
  /// In vi, this message translates to:
  /// **'Thêm khung giờ'**
  String get showtimeBulkAddTimeSlot;

  /// No description provided for @showtimeBulkSelectTime.
  ///
  /// In vi, this message translates to:
  /// **'Chọn giờ'**
  String get showtimeBulkSelectTime;

  /// No description provided for @showtimeBulkPreview.
  ///
  /// In vi, this message translates to:
  /// **'Xem trước'**
  String get showtimeBulkPreview;

  /// No description provided for @showtimeBulkPreviewDesc.
  ///
  /// In vi, this message translates to:
  /// **'{days} ngày × {slots} khung giờ = {total} suất dự kiến'**
  String showtimeBulkPreviewDesc(int days, int slots, int total);

  /// No description provided for @showtimeBulkSubmitBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tạo lịch hàng loạt'**
  String get showtimeBulkSubmitBtn;

  /// No description provided for @showtimeBulkSubmitting.
  ///
  /// In vi, this message translates to:
  /// **'Đang tạo lịch chiếu...'**
  String get showtimeBulkSubmitting;

  /// No description provided for @showtimeBulkSuccessSummary.
  ///
  /// In vi, this message translates to:
  /// **'Tạo thành công {count} suất chiếu'**
  String showtimeBulkSuccessSummary(int count);

  /// No description provided for @showtimeBulkFailedSummary.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại {count} suất chiếu'**
  String showtimeBulkFailedSummary(int count);

  /// No description provided for @showtimeBulkResultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả tạo lịch tự động'**
  String get showtimeBulkResultTitle;

  /// No description provided for @showtimeBulkDateRangeError.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc phải sau hoặc bằng ngày bắt đầu'**
  String get showtimeBulkDateRangeError;

  /// No description provided for @showtimeBulkTimeSlotsEmptyError.
  ///
  /// In vi, this message translates to:
  /// **'Cần ít nhất một khung giờ chiếu'**
  String get showtimeBulkTimeSlotsEmptyError;

  /// No description provided for @showtimeBulkDone.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất'**
  String get showtimeBulkDone;

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

  /// No description provided for @roomTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số phòng'**
  String get roomTotal;

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

  /// No description provided for @promotionSearchPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm theo mã, mô tả...'**
  String get promotionSearchPlaceholder;

  /// No description provided for @promotionTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng khuyến mãi'**
  String get promotionTotal;

  /// No description provided for @promotionActive.
  ///
  /// In vi, this message translates to:
  /// **'Đang áp dụng'**
  String get promotionActive;

  /// No description provided for @promotionExpired.
  ///
  /// In vi, this message translates to:
  /// **'Đã hết hạn'**
  String get promotionExpired;

  /// No description provided for @promotionPaused.
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng'**
  String get promotionPaused;

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

  /// No description provided for @manageConcessions.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý Bắp nước'**
  String get manageConcessions;

  /// No description provided for @addProduct.
  ///
  /// In vi, this message translates to:
  /// **'Thêm sản phẩm'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In vi, this message translates to:
  /// **'Sửa sản phẩm'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In vi, this message translates to:
  /// **'Tên sản phẩm'**
  String get productName;

  /// No description provided for @stockQuantity.
  ///
  /// In vi, this message translates to:
  /// **'Tồn kho'**
  String get stockQuantity;

  /// No description provided for @lowStock.
  ///
  /// In vi, this message translates to:
  /// **'Sắp hết'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In vi, this message translates to:
  /// **'Hết hàng'**
  String get outOfStock;

  /// No description provided for @totalProducts.
  ///
  /// In vi, this message translates to:
  /// **'Tổng sản phẩm'**
  String get totalProducts;

  /// No description provided for @noConcessions.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có sản phẩm nào.'**
  String get noConcessions;

  /// No description provided for @confirmDeleteProduct.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa sản phẩm này không?'**
  String get confirmDeleteProduct;

  /// No description provided for @priceLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giá'**
  String get priceLabel;

  /// No description provided for @productImage.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh sản phẩm'**
  String get productImage;

  /// No description provided for @selectImage.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh'**
  String get selectImage;

  /// No description provided for @changeImage.
  ///
  /// In vi, this message translates to:
  /// **'Đổi ảnh'**
  String get changeImage;

  /// No description provided for @changeAvatar.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi ảnh đại diện'**
  String get changeAvatar;

  /// No description provided for @removeImage.
  ///
  /// In vi, this message translates to:
  /// **'Xóa ảnh'**
  String get removeImage;

  /// No description provided for @takePhoto.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In vi, this message translates to:
  /// **'Chọn từ thư viện'**
  String get chooseFromGallery;

  /// No description provided for @imageUrlOptional.
  ///
  /// In vi, this message translates to:
  /// **'Hoặc dán URL ảnh'**
  String get imageUrlOptional;

  /// No description provided for @enterImageUrl.
  ///
  /// In vi, this message translates to:
  /// **'Nhập đường dẫn ảnh (URL)'**
  String get enterImageUrl;

  /// No description provided for @searchConcessionPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm bắp nước...'**
  String get searchConcessionPlaceholder;

  /// No description provided for @inStockCount.
  ///
  /// In vi, this message translates to:
  /// **'Còn {count}'**
  String inStockCount(int count);

  /// No description provided for @lowStockCount.
  ///
  /// In vi, this message translates to:
  /// **'Sắp hết: {count}'**
  String lowStockCount(int count);

  /// No description provided for @manageMovies.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý Phim'**
  String get manageMovies;

  /// No description provided for @ticketSaleAtCounter.
  ///
  /// In vi, this message translates to:
  /// **'Bán vé tại quầy'**
  String get ticketSaleAtCounter;

  /// No description provided for @staffRole.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên'**
  String get staffRole;

  /// No description provided for @adminRole.
  ///
  /// In vi, this message translates to:
  /// **'Quản trị viên'**
  String get adminRole;

  /// No description provided for @filterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get filterAll;

  /// No description provided for @imageUploadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải ảnh lên'**
  String get imageUploadError;

  /// No description provided for @noResultsFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy kết quả'**
  String get noResultsFound;

  /// No description provided for @invalidAmount.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị không hợp lệ'**
  String get invalidAmount;

  /// No description provided for @customerRole.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get customerRole;

  /// No description provided for @tabAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get tabAll;

  /// No description provided for @tabCustomers.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get tabCustomers;

  /// No description provided for @tabStaff.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên'**
  String get tabStaff;

  /// No description provided for @statusAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get statusAll;

  /// No description provided for @statusActive.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động'**
  String get statusActive;

  /// No description provided for @statusBlocked.
  ///
  /// In vi, this message translates to:
  /// **'Đã khóa'**
  String get statusBlocked;

  /// No description provided for @totalCustomersCount.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng: {count}'**
  String totalCustomersCount(int count);

  /// No description provided for @totalStaffCount.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên: {count}'**
  String totalStaffCount(int count);

  /// No description provided for @addStaff.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nhân viên'**
  String get addStaff;

  /// No description provided for @createStaffTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản nhân viên'**
  String get createStaffTitle;

  /// No description provided for @createStaffSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cấp tài khoản truy cập hệ thống cho nhân viên rạp'**
  String get createStaffSubtitle;

  /// No description provided for @staffCreatedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản nhân viên thành công'**
  String get staffCreatedSuccess;

  /// No description provided for @fullNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Họ và tên'**
  String get fullNameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get phoneLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận mật khẩu'**
  String get confirmPasswordLabel;

  /// No description provided for @saveStaffButton.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhân viên'**
  String get saveStaffButton;

  /// No description provided for @accountDetailsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết tài khoản'**
  String get accountDetailsTitle;

  /// No description provided for @joinedDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày tham gia'**
  String get joinedDateLabel;

  /// No description provided for @loyaltyPointsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Điểm tích lũy'**
  String get loyaltyPointsTitle;

  /// No description provided for @cannotBlockSelf.
  ///
  /// In vi, this message translates to:
  /// **'Bạn không thể khóa tài khoản của chính mình'**
  String get cannotBlockSelf;

  /// No description provided for @pageIndicator.
  ///
  /// In vi, this message translates to:
  /// **'Trang {current} / {total}'**
  String pageIndicator(int current, int total);

  /// No description provided for @nextPage.
  ///
  /// In vi, this message translates to:
  /// **'Trang sau'**
  String get nextPage;

  /// No description provided for @prevPage.
  ///
  /// In vi, this message translates to:
  /// **'Trang trước'**
  String get prevPage;

  /// No description provided for @confirmPasswordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu xác nhận không khớp'**
  String get confirmPasswordMismatch;

  /// No description provided for @notProvided.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cập nhật'**
  String get notProvided;

  /// No description provided for @genderLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get genderLabel;

  /// No description provided for @dobLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sinh'**
  String get dobLabel;

  /// No description provided for @accountInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin tài khoản'**
  String get accountInfo;

  /// No description provided for @resetFilters.
  ///
  /// In vi, this message translates to:
  /// **'Đặt lại bộ lọc'**
  String get resetFilters;

  /// No description provided for @totalAccounts.
  ///
  /// In vi, this message translates to:
  /// **'Tổng tài khoản'**
  String get totalAccounts;

  /// No description provided for @fieldRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập trường này'**
  String get fieldRequired;

  /// No description provided for @errorOccurred.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi xảy ra. Vui lòng thử lại.'**
  String get errorOccurred;

  /// No description provided for @productDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả sản phẩm'**
  String get productDescription;

  /// No description provided for @productDetail.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết sản phẩm'**
  String get productDetail;

  /// No description provided for @revenueStatistics.
  ///
  /// In vi, this message translates to:
  /// **'Thống kê Doanh thu'**
  String get revenueStatistics;

  /// No description provided for @filterByYear.
  ///
  /// In vi, this message translates to:
  /// **'Theo năm'**
  String get filterByYear;

  /// No description provided for @filterByMonth.
  ///
  /// In vi, this message translates to:
  /// **'Theo tháng'**
  String get filterByMonth;

  /// No description provided for @filterByDateRange.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng ngày'**
  String get filterByDateRange;

  /// No description provided for @selectDateRange.
  ///
  /// In vi, this message translates to:
  /// **'Chọn khoảng ngày'**
  String get selectDateRange;

  /// No description provided for @dateFrom.
  ///
  /// In vi, this message translates to:
  /// **'Từ ngày'**
  String get dateFrom;

  /// No description provided for @dateTo.
  ///
  /// In vi, this message translates to:
  /// **'Đến ngày'**
  String get dateTo;

  /// No description provided for @totalRevenueLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng doanh thu kỳ này'**
  String get totalRevenueLabel;

  /// No description provided for @genreAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get genreAll;

  /// No description provided for @genreAction.
  ///
  /// In vi, this message translates to:
  /// **'Hành động'**
  String get genreAction;

  /// No description provided for @genreComedy.
  ///
  /// In vi, this message translates to:
  /// **'Hài hước'**
  String get genreComedy;

  /// No description provided for @genreDrama.
  ///
  /// In vi, this message translates to:
  /// **'Chính kịch'**
  String get genreDrama;

  /// No description provided for @genreHorror.
  ///
  /// In vi, this message translates to:
  /// **'Kinh dị'**
  String get genreHorror;

  /// No description provided for @genreSciFi.
  ///
  /// In vi, this message translates to:
  /// **'Khoa học viễn tưởng'**
  String get genreSciFi;

  /// No description provided for @genreRomance.
  ///
  /// In vi, this message translates to:
  /// **'Lãng mạn'**
  String get genreRomance;

  /// No description provided for @genreAnimation.
  ///
  /// In vi, this message translates to:
  /// **'Hoạt hình'**
  String get genreAnimation;

  /// No description provided for @genreAdventure.
  ///
  /// In vi, this message translates to:
  /// **'Phiêu lưu'**
  String get genreAdventure;

  /// No description provided for @genreThriller.
  ///
  /// In vi, this message translates to:
  /// **'Giật gân'**
  String get genreThriller;

  /// No description provided for @genreFantasy.
  ///
  /// In vi, this message translates to:
  /// **'Giả tưởng'**
  String get genreFantasy;

  /// No description provided for @genreDocumentary.
  ///
  /// In vi, this message translates to:
  /// **'Tài liệu'**
  String get genreDocumentary;

  /// No description provided for @bookingStatusPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ thanh toán'**
  String get bookingStatusPending;

  /// No description provided for @bookingStatusPaid.
  ///
  /// In vi, this message translates to:
  /// **'Đã thanh toán'**
  String get bookingStatusPaid;

  /// No description provided for @bookingStatusCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get bookingStatusCancelled;

  /// No description provided for @bookingStatusExpired.
  ///
  /// In vi, this message translates to:
  /// **'Hết hạn'**
  String get bookingStatusExpired;

  /// No description provided for @bookingStatusConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận'**
  String get bookingStatusConfirmed;

  /// No description provided for @paymentStatusPending.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thành công'**
  String get paymentStatusSuccess;

  /// No description provided for @paymentStatusFailed.
  ///
  /// In vi, this message translates to:
  /// **'Thất bại'**
  String get paymentStatusFailed;

  /// No description provided for @paymentStatusCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get paymentStatusCancelled;

  /// No description provided for @paymentResult.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả thanh toán'**
  String get paymentResult;

  /// No description provided for @paymentSuccessful.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán thành công!'**
  String get paymentSuccessful;

  /// No description provided for @viewTickets.
  ///
  /// In vi, this message translates to:
  /// **'Xem vé của tôi'**
  String get viewTickets;

  /// No description provided for @bookingCodeWithParam.
  ///
  /// In vi, this message translates to:
  /// **'Mã đặt vé: {code}'**
  String bookingCodeWithParam(String code);

  /// No description provided for @simulateSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Mô phỏng thanh toán thành công'**
  String get simulateSuccess;

  /// No description provided for @webviewPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Cổng thanh toán trực tuyến'**
  String get webviewPlaceholder;

  /// No description provided for @specialDiscount.
  ///
  /// In vi, this message translates to:
  /// **'Khuyến mãi đặc biệt'**
  String get specialDiscount;

  /// No description provided for @unknownCinema.
  ///
  /// In vi, this message translates to:
  /// **'Rạp không xác định'**
  String get unknownCinema;

  /// No description provided for @defaultMovieTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phim Cineplex'**
  String get defaultMovieTitle;

  /// No description provided for @concessionCombo.
  ///
  /// In vi, this message translates to:
  /// **'Combo bắp nước'**
  String get concessionCombo;

  /// No description provided for @paymentMethodMomo.
  ///
  /// In vi, this message translates to:
  /// **'Ví MoMo'**
  String get paymentMethodMomo;

  /// No description provided for @paymentMethodVnpay.
  ///
  /// In vi, this message translates to:
  /// **'Cổng VNPAY'**
  String get paymentMethodVnpay;

  /// No description provided for @paymentMethodZaloPay.
  ///
  /// In vi, this message translates to:
  /// **'Ví ZaloPay'**
  String get paymentMethodZaloPay;

  /// No description provided for @paymentMethodCard.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ ATM / Thẻ quốc tế'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodCash.
  ///
  /// In vi, this message translates to:
  /// **'Tiền mặt tại quầy'**
  String get paymentMethodCash;

  /// No description provided for @paymentSelectVoucher.
  ///
  /// In vi, this message translates to:
  /// **'Chọn voucher'**
  String get paymentSelectVoucher;

  /// No description provided for @paymentAvailableVouchers.
  ///
  /// In vi, this message translates to:
  /// **'Mã khuyến mãi khả dụng'**
  String get paymentAvailableVouchers;

  /// No description provided for @paymentNoVouchers.
  ///
  /// In vi, this message translates to:
  /// **'Không có mã khuyến mãi khả dụng'**
  String get paymentNoVouchers;

  /// No description provided for @paymentEarnedPointsNotice.
  ///
  /// In vi, this message translates to:
  /// **'Tích lũy +{points} điểm khi hoàn tất'**
  String paymentEarnedPointsNotice(int points);

  /// No description provided for @paymentUseLoyaltyPoints.
  ///
  /// In vi, this message translates to:
  /// **'Dùng điểm tích lũy ({points} điểm)'**
  String paymentUseLoyaltyPoints(int points);

  /// No description provided for @paymentSeatsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghế: {seats}'**
  String paymentSeatsLabel(String seats);

  /// No description provided for @paymentTicketsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} vé xem phim'**
  String paymentTicketsCount(int count);

  /// No description provided for @epassTitle.
  ///
  /// In vi, this message translates to:
  /// **'Vé điện tử (E-Pass)'**
  String get epassTitle;

  /// No description provided for @epassInstruction.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng xuất trình mã QR này tại cửa kiểm soát để vào rạp'**
  String get epassInstruction;

  /// No description provided for @ticketFormat2D.
  ///
  /// In vi, this message translates to:
  /// **'2D'**
  String get ticketFormat2D;

  /// No description provided for @ticketFormat3D.
  ///
  /// In vi, this message translates to:
  /// **'3D'**
  String get ticketFormat3D;

  /// No description provided for @ticketFormatIMAX.
  ///
  /// In vi, this message translates to:
  /// **'IMAX'**
  String get ticketFormatIMAX;

  /// No description provided for @checkinStatusValid.
  ///
  /// In vi, this message translates to:
  /// **'HỢP LỆ'**
  String get checkinStatusValid;

  /// No description provided for @checkinStatusAlreadyUsed.
  ///
  /// In vi, this message translates to:
  /// **'ĐÃ SOÁT TRƯỚC ĐÓ'**
  String get checkinStatusAlreadyUsed;

  /// No description provided for @checkinStatusInvalid.
  ///
  /// In vi, this message translates to:
  /// **'KHÔNG HỢP LỆ'**
  String get checkinStatusInvalid;

  /// No description provided for @checkinSuccessBanner.
  ///
  /// In vi, this message translates to:
  /// **'Soát vé thành công - Mời khách vào rạp'**
  String get checkinSuccessBanner;

  /// No description provided for @checkinWarningBanner.
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo: Vé đã được sử dụng trước đó!'**
  String get checkinWarningBanner;

  /// No description provided for @checkinErrorBanner.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối: Vé không hợp lệ hoặc đã bị hủy!'**
  String get checkinErrorBanner;

  /// No description provided for @checkinTimeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian soát vé'**
  String get checkinTimeLabel;

  /// No description provided for @checkinStaffLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên soát vé'**
  String get checkinStaffLabel;

  /// No description provided for @customerNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên khách hàng'**
  String get customerNameLabel;

  /// No description provided for @ticketCodeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã vé'**
  String get ticketCodeLabel;

  /// No description provided for @flashToggle.
  ///
  /// In vi, this message translates to:
  /// **'Bật/Tắt đèn Flash'**
  String get flashToggle;

  /// No description provided for @switchCamera.
  ///
  /// In vi, this message translates to:
  /// **'Đổi camera'**
  String get switchCamera;

  /// No description provided for @scannerPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Hướng camera về phía mã QR trên vé của khách'**
  String get scannerPrompt;

  /// No description provided for @scanNextTicket.
  ///
  /// In vi, this message translates to:
  /// **'Quét vé tiếp theo'**
  String get scanNextTicket;

  /// No description provided for @manualCodeHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã vé (VD: TKT-12345)'**
  String get manualCodeHint;

  /// No description provided for @verifySuccessPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Vé {code} đã được xác nhận thành công!'**
  String verifySuccessPrompt(String code);

  /// No description provided for @shiftDashboard.
  ///
  /// In vi, this message translates to:
  /// **'Bảng điều khiển ca trực'**
  String get shiftDashboard;

  /// No description provided for @shiftInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin ca trực'**
  String get shiftInfo;

  /// No description provided for @currentShift.
  ///
  /// In vi, this message translates to:
  /// **'Ca trực hiện tại'**
  String get currentShift;

  /// No description provided for @assignedCinema.
  ///
  /// In vi, this message translates to:
  /// **'Rạp làm việc'**
  String get assignedCinema;

  /// No description provided for @staffName.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên trực'**
  String get staffName;

  /// No description provided for @ticketsScannedToday.
  ///
  /// In vi, this message translates to:
  /// **'Số vé đã soát hôm nay'**
  String get ticketsScannedToday;

  /// No description provided for @counterRevenueToday.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu tại quầy'**
  String get counterRevenueToday;

  /// No description provided for @upcomingShowtimesCount.
  ///
  /// In vi, this message translates to:
  /// **'Suất chiếu sắp tới'**
  String get upcomingShowtimesCount;

  /// No description provided for @quickActions.
  ///
  /// In vi, this message translates to:
  /// **'Thao tác nhanh'**
  String get quickActions;

  /// No description provided for @actionScanTicket.
  ///
  /// In vi, this message translates to:
  /// **'Soát vé vào rạp'**
  String get actionScanTicket;

  /// No description provided for @actionCounterSale.
  ///
  /// In vi, this message translates to:
  /// **'Bán vé tại quầy'**
  String get actionCounterSale;

  /// No description provided for @actionFastPOS.
  ///
  /// In vi, this message translates to:
  /// **'Bán bắp nước nhanh'**
  String get actionFastPOS;

  /// No description provided for @actionRoomStatus.
  ///
  /// In vi, this message translates to:
  /// **'Tình trạng phòng chiếu'**
  String get actionRoomStatus;

  /// No description provided for @endShift.
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc ca trực'**
  String get endShift;

  /// No description provided for @shiftSummary.
  ///
  /// In vi, this message translates to:
  /// **'Tổng kết ca trực'**
  String get shiftSummary;

  /// No description provided for @fastPosTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bán bắp nước nhanh'**
  String get fastPosTitle;

  /// No description provided for @posCategoryAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get posCategoryAll;

  /// No description provided for @posCategoryPopcorn.
  ///
  /// In vi, this message translates to:
  /// **'Bắp rang bơ'**
  String get posCategoryPopcorn;

  /// No description provided for @posCategoryDrink.
  ///
  /// In vi, this message translates to:
  /// **'Nước giải khát'**
  String get posCategoryDrink;

  /// No description provided for @posCategoryCombo.
  ///
  /// In vi, this message translates to:
  /// **'Combo bắp nước'**
  String get posCategoryCombo;

  /// No description provided for @posCategorySnack.
  ///
  /// In vi, this message translates to:
  /// **'Đồ ăn nhẹ'**
  String get posCategorySnack;

  /// No description provided for @quickOrder.
  ///
  /// In vi, this message translates to:
  /// **'Đơn hàng nhanh'**
  String get quickOrder;

  /// No description provided for @cartItemsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} món'**
  String cartItemsCount(int count);

  /// No description provided for @clearCart.
  ///
  /// In vi, this message translates to:
  /// **'Xóa giỏ hàng'**
  String get clearCart;

  /// No description provided for @confirmOrder.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận đơn hàng'**
  String get confirmOrder;

  /// No description provided for @customerPhoneLookup.
  ///
  /// In vi, this message translates to:
  /// **'Tra cứu SĐT khách hàng'**
  String get customerPhoneLookup;

  /// No description provided for @searchCustomerHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số điện thoại khách hàng...'**
  String get searchCustomerHint;

  /// No description provided for @customerPointsDisplay.
  ///
  /// In vi, this message translates to:
  /// **'Điểm tích lũy: {points}'**
  String customerPointsDisplay(int points);

  /// No description provided for @customerNameDisplay.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng: {name}'**
  String customerNameDisplay(String name);

  /// No description provided for @payWithCash.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán tiền mặt'**
  String get payWithCash;

  /// No description provided for @printReceipt.
  ///
  /// In vi, this message translates to:
  /// **'In hóa đơn / Vé'**
  String get printReceipt;

  /// No description provided for @defaultPopcorn.
  ///
  /// In vi, this message translates to:
  /// **'Bắp rang bơ lớn'**
  String get defaultPopcorn;

  /// No description provided for @defaultDrink.
  ///
  /// In vi, this message translates to:
  /// **'Nước ngọt lớn'**
  String get defaultDrink;

  /// No description provided for @defaultCombo.
  ///
  /// In vi, this message translates to:
  /// **'Combo 1 bắp 2 nước'**
  String get defaultCombo;

  /// No description provided for @occupancyPercent.
  ///
  /// In vi, this message translates to:
  /// **'{percent}% lấp đầy'**
  String occupancyPercent(int percent);

  /// No description provided for @roomStatusScreening.
  ///
  /// In vi, this message translates to:
  /// **'Đang chiếu'**
  String get roomStatusScreening;

  /// No description provided for @roomStatusPreparing.
  ///
  /// In vi, this message translates to:
  /// **'Chuẩn bị chiếu'**
  String get roomStatusPreparing;

  /// No description provided for @roomStatusCleaning.
  ///
  /// In vi, this message translates to:
  /// **'Dọn dẹp'**
  String get roomStatusCleaning;

  /// No description provided for @roomStatusReady.
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng'**
  String get roomStatusReady;

  /// No description provided for @roomStatusEnded.
  ///
  /// In vi, this message translates to:
  /// **'Đã kết thúc'**
  String get roomStatusEnded;

  /// No description provided for @showtimesAndOccupancy.
  ///
  /// In vi, this message translates to:
  /// **'Lịch chiếu & Tình trạng phòng'**
  String get showtimesAndOccupancy;

  /// No description provided for @viewRoomLayout.
  ///
  /// In vi, this message translates to:
  /// **'Xem sơ đồ phòng'**
  String get viewRoomLayout;

  /// No description provided for @totalSeatsInRoom.
  ///
  /// In vi, this message translates to:
  /// **'{total} ghế'**
  String totalSeatsInRoom(int total);

  /// No description provided for @bookedSeatsCount.
  ///
  /// In vi, this message translates to:
  /// **'{booked}/{total} ghế đã đặt'**
  String bookedSeatsCount(int booked, int total);

  /// No description provided for @addMovieTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm phim mới'**
  String get addMovieTitle;

  /// No description provided for @editMovieTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật phim'**
  String get editMovieTitle;

  /// No description provided for @addMovieSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thêm phim thành công!'**
  String get addMovieSuccess;

  /// No description provided for @updateMovieSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật phim thành công!'**
  String get updateMovieSuccess;

  /// No description provided for @selectPoster.
  ///
  /// In vi, this message translates to:
  /// **'Chọn poster'**
  String get selectPoster;

  /// No description provided for @movieTitleLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên phim *'**
  String get movieTitleLabel;

  /// No description provided for @enterMovieTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhập tên phim'**
  String get enterMovieTitle;

  /// No description provided for @movieTitleRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập tên phim'**
  String get movieTitleRequired;

  /// No description provided for @genreLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thể loại *'**
  String get genreLabel;

  /// No description provided for @genrePlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Hành động, Hài hước, Kinh dị...'**
  String get genrePlaceholder;

  /// No description provided for @durationMinutesLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thời lượng (phút) *'**
  String get durationMinutesLabel;

  /// No description provided for @directorPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tên đạo diễn'**
  String get directorPlaceholder;

  /// No description provided for @castPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tên diễn viên...'**
  String get castPlaceholder;

  /// No description provided for @languagePlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt, Tiếng Anh...'**
  String get languagePlaceholder;

  /// No description provided for @ageLimitPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'13, 16, 18...'**
  String get ageLimitPlaceholder;

  /// No description provided for @releaseDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngày phát hành'**
  String get releaseDateLabel;

  /// No description provided for @screeningEndDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày kết thúc'**
  String get screeningEndDate;

  /// No description provided for @selectDatePrompt.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày'**
  String get selectDatePrompt;

  /// No description provided for @trailerUrl.
  ///
  /// In vi, this message translates to:
  /// **'Trailer URL'**
  String get trailerUrl;

  /// No description provided for @trailerUrlPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'https://youtube.com/...'**
  String get trailerUrlPlaceholder;

  /// No description provided for @movieDescriptionPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung phim...'**
  String get movieDescriptionPlaceholder;

  /// No description provided for @createMovieBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tạo phim'**
  String get createMovieBtn;

  /// No description provided for @searchMoviesPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm tên phim...'**
  String get searchMoviesPlaceholder;

  /// No description provided for @movieTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng số phim'**
  String get movieTotal;

  /// No description provided for @statusNowShowing.
  ///
  /// In vi, this message translates to:
  /// **'Đang chiếu'**
  String get statusNowShowing;

  /// No description provided for @statusComingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp chiếu'**
  String get statusComingSoon;

  /// No description provided for @statusStopped.
  ///
  /// In vi, this message translates to:
  /// **'Ngừng chiếu'**
  String get statusStopped;

  /// No description provided for @roomTypeStandard.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu chuẩn (Standard)'**
  String get roomTypeStandard;

  /// No description provided for @roomTypeVIP.
  ///
  /// In vi, this message translates to:
  /// **'Phòng VIP'**
  String get roomTypeVIP;

  /// No description provided for @roomTypeIMAX.
  ///
  /// In vi, this message translates to:
  /// **'Phòng IMAX'**
  String get roomTypeIMAX;

  /// No description provided for @roomType4DX.
  ///
  /// In vi, this message translates to:
  /// **'Phòng 4DX'**
  String get roomType4DX;

  /// No description provided for @roomTypeCouple.
  ///
  /// In vi, this message translates to:
  /// **'Phòng Sweetbox'**
  String get roomTypeCouple;

  /// No description provided for @roomStatusActive.
  ///
  /// In vi, this message translates to:
  /// **'Đang hoạt động'**
  String get roomStatusActive;

  /// No description provided for @roomStatusInactive.
  ///
  /// In vi, this message translates to:
  /// **'Tạm ngưng'**
  String get roomStatusInactive;

  /// No description provided for @roomStatusMaintenance.
  ///
  /// In vi, this message translates to:
  /// **'Bảo trì'**
  String get roomStatusMaintenance;

  /// No description provided for @viewSeatMap.
  ///
  /// In vi, this message translates to:
  /// **'Xem sơ đồ ghế'**
  String get viewSeatMap;

  /// No description provided for @generateSeatsBtn.
  ///
  /// In vi, this message translates to:
  /// **'Tạo sơ đồ ghế tự động'**
  String get generateSeatsBtn;

  /// No description provided for @generateSeatsSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Tạo sơ đồ ghế thành công!'**
  String get generateSeatsSuccess;

  /// No description provided for @generateSeatsConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Hành động này sẽ tạo ma trận ghế tự động cho phòng chiếu. Tiếp tục?'**
  String get generateSeatsConfirm;

  /// No description provided for @seatLayoutTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sơ đồ phòng chiếu'**
  String get seatLayoutTitle;

  /// No description provided for @seatMatrixRows.
  ///
  /// In vi, this message translates to:
  /// **'Số hàng ghế'**
  String get seatMatrixRows;

  /// No description provided for @seatMatrixCols.
  ///
  /// In vi, this message translates to:
  /// **'Số cột ghế'**
  String get seatMatrixCols;

  /// No description provided for @cinemaStatusActive.
  ///
  /// In vi, this message translates to:
  /// **'Đang hoạt động'**
  String get cinemaStatusActive;

  /// No description provided for @cinemaStatusInactive.
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng'**
  String get cinemaStatusInactive;

  /// No description provided for @cinemaStatusMaintenance.
  ///
  /// In vi, this message translates to:
  /// **'Bảo trì'**
  String get cinemaStatusMaintenance;

  /// No description provided for @format4DX.
  ///
  /// In vi, this message translates to:
  /// **'4DX'**
  String get format4DX;

  /// No description provided for @filterByDatePrompt.
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo ngày'**
  String get filterByDatePrompt;

  /// No description provided for @millionShort.
  ///
  /// In vi, this message translates to:
  /// **'{amount} Tr'**
  String millionShort(String amount);

  /// No description provided for @thousandShort.
  ///
  /// In vi, this message translates to:
  /// **'{amount} N'**
  String thousandShort(String amount);

  /// No description provided for @rankBadge.
  ///
  /// In vi, this message translates to:
  /// **'#{rank}'**
  String rankBadge(int rank);

  /// No description provided for @topPerformingMovies.
  ///
  /// In vi, this message translates to:
  /// **'Top phim doanh thu cao'**
  String get topPerformingMovies;

  /// No description provided for @chartRevenueUnit.
  ///
  /// In vi, this message translates to:
  /// **'Đơn vị: VNĐ'**
  String get chartRevenueUnit;

  /// No description provided for @noDataInPeriod.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu trong khoảng thời gian này'**
  String get noDataInPeriod;

  /// No description provided for @adminSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt hệ thống'**
  String get adminSettings;

  /// No description provided for @adminProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ quản trị viên'**
  String get adminProfile;

  /// No description provided for @themeModeSetting.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get themeModeSetting;

  /// No description provided for @themeModeDark.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện tối'**
  String get themeModeDark;

  /// No description provided for @themeModeLight.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện sáng'**
  String get themeModeLight;

  /// No description provided for @themeModeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get themeModeSystem;

  /// No description provided for @systemInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin hệ thống'**
  String get systemInfo;

  /// No description provided for @clearCache.
  ///
  /// In vi, this message translates to:
  /// **'Xóa bộ nhớ đệm'**
  String get clearCache;

  /// No description provided for @clearCacheSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa bộ nhớ đệm thành công'**
  String get clearCacheSuccess;

  /// No description provided for @soundAndHaptic.
  ///
  /// In vi, this message translates to:
  /// **'Âm thanh & Rung khi quét'**
  String get soundAndHaptic;

  /// No description provided for @soundAndHapticDesc.
  ///
  /// In vi, this message translates to:
  /// **'Phát âm báo và rung khi quét mã QR thành công hoặc thất bại'**
  String get soundAndHapticDesc;

  /// No description provided for @weekdayMon.
  ///
  /// In vi, this message translates to:
  /// **'Th 2'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In vi, this message translates to:
  /// **'Th 3'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In vi, this message translates to:
  /// **'Th 4'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In vi, this message translates to:
  /// **'Th 5'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In vi, this message translates to:
  /// **'Th 6'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In vi, this message translates to:
  /// **'Th 7'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In vi, this message translates to:
  /// **'CN'**
  String get weekdaySun;

  /// No description provided for @cameraInitializing.
  ///
  /// In vi, this message translates to:
  /// **'Đang khởi động máy ảnh...'**
  String get cameraInitializing;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In vi, this message translates to:
  /// **'Không có quyền truy cập máy ảnh. Vui lòng cấp quyền trong cài đặt thiết bị.'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể khởi động máy ảnh'**
  String get cameraError;

  /// No description provided for @cameraErrorHint.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng kiểm tra quyền truy cập hoặc sử dụng tính năng nhập mã thủ công bên dưới.'**
  String get cameraErrorHint;

  /// No description provided for @cameraRetake.
  ///
  /// In vi, this message translates to:
  /// **'Chụp lại'**
  String get cameraRetake;

  /// No description provided for @cameraUsePhoto.
  ///
  /// In vi, this message translates to:
  /// **'Sử dụng ảnh'**
  String get cameraUsePhoto;

  /// No description provided for @cameraCapture.
  ///
  /// In vi, this message translates to:
  /// **'Chụp ảnh'**
  String get cameraCapture;

  /// No description provided for @cameraNoCameras.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy máy ảnh trên thiết bị'**
  String get cameraNoCameras;

  /// No description provided for @cameraCircleHint.
  ///
  /// In vi, this message translates to:
  /// **'Căn chỉnh khuôn mặt vào giữa khung tròn'**
  String get cameraCircleHint;

  /// No description provided for @staffProfile.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ nhân viên'**
  String get staffProfile;

  /// No description provided for @posTabTickets.
  ///
  /// In vi, this message translates to:
  /// **'Vé & Bắp nước'**
  String get posTabTickets;

  /// No description provided for @posTabConcessions.
  ///
  /// In vi, this message translates to:
  /// **'Bắp nước nhanh'**
  String get posTabConcessions;

  /// No description provided for @checkinResultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả soát vé'**
  String get checkinResultTitle;

  /// No description provided for @cashReceived.
  ///
  /// In vi, this message translates to:
  /// **'Tiền khách đưa'**
  String get cashReceived;

  /// No description provided for @cashChange.
  ///
  /// In vi, this message translates to:
  /// **'Tiền thối lại'**
  String get cashChange;

  /// No description provided for @exactAmount.
  ///
  /// In vi, this message translates to:
  /// **'Đủ tiền'**
  String get exactAmount;

  /// No description provided for @printTicketReceipt.
  ///
  /// In vi, this message translates to:
  /// **'In vé & Hóa đơn'**
  String get printTicketReceipt;

  /// No description provided for @posOrderSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Tạo đơn hàng thành công!'**
  String get posOrderSuccess;

  /// No description provided for @posOrderSuccessPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Mã đơn: {code}'**
  String posOrderSuccessPrompt(String code);

  /// No description provided for @staffBadge.
  ///
  /// In vi, this message translates to:
  /// **'NHÂN VIÊN'**
  String get staffBadge;

  /// No description provided for @seatNumber.
  ///
  /// In vi, this message translates to:
  /// **'Số ghế'**
  String get seatNumber;

  /// No description provided for @customer.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get customer;

  /// No description provided for @ticketNumber.
  ///
  /// In vi, this message translates to:
  /// **'Mã vé'**
  String get ticketNumber;

  /// No description provided for @tomorrow.
  ///
  /// In vi, this message translates to:
  /// **'Ngày mai'**
  String get tomorrow;

  /// No description provided for @cashPaymentDesc.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán tiền mặt trực tiếp tại quầy'**
  String get cashPaymentDesc;

  /// No description provided for @momoPaymentDesc.
  ///
  /// In vi, this message translates to:
  /// **'Quét mã MoMo QR tại quầy'**
  String get momoPaymentDesc;

  /// No description provided for @vnpayPaymentDesc.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ ATM / VNPAY-QR'**
  String get vnpayPaymentDesc;

  /// No description provided for @enterCashReceivedHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tiền khách đưa'**
  String get enterCashReceivedHint;

  /// No description provided for @insufficientCashReceived.
  ///
  /// In vi, this message translates to:
  /// **'Số tiền khách đưa không đủ thanh toán'**
  String get insufficientCashReceived;

  /// No description provided for @posPointsAvailable.
  ///
  /// In vi, this message translates to:
  /// **'Điểm hiện có'**
  String get posPointsAvailable;

  /// No description provided for @posPointsToUse.
  ///
  /// In vi, this message translates to:
  /// **'Điểm sử dụng'**
  String get posPointsToUse;

  /// No description provided for @posPointsRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Điểm còn lại'**
  String get posPointsRemaining;

  /// No description provided for @posDiscountValue.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị giảm'**
  String get posDiscountValue;

  /// No description provided for @posUsingPointsBadge.
  ///
  /// In vi, this message translates to:
  /// **'Đang sử dụng {points} điểm'**
  String posUsingPointsBadge(String points);

  /// No description provided for @posCancelPoints.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get posCancelPoints;

  /// No description provided for @posSearchCustomer.
  ///
  /// In vi, this message translates to:
  /// **'Tìm'**
  String get posSearchCustomer;

  /// No description provided for @posSearchCustomerHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập email hoặc số điện thoại...'**
  String get posSearchCustomerHint;

  /// No description provided for @posCustomerNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy khách hàng'**
  String get posCustomerNotFound;

  /// No description provided for @posChangeCustomer.
  ///
  /// In vi, this message translates to:
  /// **'Đổi khách hàng'**
  String get posChangeCustomer;

  /// No description provided for @posPointsExceedBalance.
  ///
  /// In vi, this message translates to:
  /// **'Số điểm sử dụng không được vượt quá số dư hiện có'**
  String get posPointsExceedBalance;

  /// No description provided for @posPointsExceedLimit.
  ///
  /// In vi, this message translates to:
  /// **'Số điểm sử dụng vượt quá giới hạn giảm giá (tối đa 20% tổng đơn)'**
  String get posPointsExceedLimit;

  /// No description provided for @posPointsInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Số điểm phải là số nguyên dương'**
  String get posPointsInvalid;

  /// No description provided for @posCustomerLoyaltyBalance.
  ///
  /// In vi, this message translates to:
  /// **'Điểm tích lũy: {points}'**
  String posCustomerLoyaltyBalance(String points);

  /// No description provided for @posWaitingMomoPayment.
  ///
  /// In vi, this message translates to:
  /// **'Đang chờ thanh toán MoMo'**
  String get posWaitingMomoPayment;

  /// No description provided for @posOpenMomo.
  ///
  /// In vi, this message translates to:
  /// **'Mở cổng thanh toán MoMo'**
  String get posOpenMomo;

  /// No description provided for @posCheckingPayment.
  ///
  /// In vi, this message translates to:
  /// **'Đang kiểm tra thanh toán...'**
  String get posCheckingPayment;

  /// No description provided for @posPaymentPendingHint.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng quét mã trên cổng MoMo, sau đó bấm Kiểm tra thanh toán.'**
  String get posPaymentPendingHint;

  /// No description provided for @posCheckPaymentStatus.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra thanh toán'**
  String get posCheckPaymentStatus;

  /// No description provided for @posPaymentFailedPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán không thành công. Quý khách có thể thử lại.'**
  String get posPaymentFailedPrompt;

  /// No description provided for @posRetryPayment.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại thanh toán'**
  String get posRetryPayment;

  /// No description provided for @posPaymentCancelledPrompt.
  ///
  /// In vi, this message translates to:
  /// **'Giao dịch thanh toán đã bị hủy.'**
  String get posPaymentCancelledPrompt;

  /// No description provided for @posContinueSale.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục bán vé'**
  String get posContinueSale;

  /// No description provided for @posViewTickets.
  ///
  /// In vi, this message translates to:
  /// **'Xem quản lý vé'**
  String get posViewTickets;

  /// No description provided for @posEarnedPointsSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Tích lũy +{points} điểm thành công'**
  String posEarnedPointsSuccess(int points);

  /// No description provided for @scanSoundTitle.
  ///
  /// In vi, this message translates to:
  /// **'Âm báo khi quét mã'**
  String get scanSoundTitle;

  /// No description provided for @scanHapticTitle.
  ///
  /// In vi, this message translates to:
  /// **'Rung khi quét mã'**
  String get scanHapticTitle;

  /// No description provided for @seatUnit.
  ///
  /// In vi, this message translates to:
  /// **'ghế'**
  String get seatUnit;

  /// No description provided for @availableCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'Trống: {count}'**
  String availableCountLabel(int count);

  /// No description provided for @bookedCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'Đã đặt: {count}'**
  String bookedCountLabel(int count);

  /// No description provided for @totalCountLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tổng: {count}'**
  String totalCountLabel(int count);

  /// No description provided for @counterRevenueSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Doanh thu quầy'**
  String get counterRevenueSubtitle;

  /// No description provided for @upcomingShowtimesSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đang mở bán'**
  String get upcomingShowtimesSubtitle;

  /// No description provided for @averageSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Trung bình'**
  String get averageSubtitle;

  /// No description provided for @defaultRoom.
  ///
  /// In vi, this message translates to:
  /// **'Phòng'**
  String get defaultRoom;

  /// No description provided for @format2DSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'2D Phụ đề'**
  String get format2DSubtitle;

  /// No description provided for @format2DDubbed.
  ///
  /// In vi, this message translates to:
  /// **'2D Lồng tiếng'**
  String get format2DDubbed;

  /// No description provided for @format3DDubbed.
  ///
  /// In vi, this message translates to:
  /// **'3D Lồng tiếng'**
  String get format3DDubbed;

  /// No description provided for @movieExhuma.
  ///
  /// In vi, this message translates to:
  /// **'Exhuma: Quật mộ trùng ma'**
  String get movieExhuma;

  /// No description provided for @adminBadge.
  ///
  /// In vi, this message translates to:
  /// **'QUẢN TRỊ VIÊN'**
  String get adminBadge;

  /// No description provided for @userIdLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã tài khoản'**
  String get userIdLabel;

  /// No description provided for @roleLabel.
  ///
  /// In vi, this message translates to:
  /// **'Vai trò'**
  String get roleLabel;

  /// No description provided for @emailPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'nhanvien@cineplex.vn'**
  String get emailPlaceholder;

  /// No description provided for @phonePlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'09xxxxxxxx'**
  String get phonePlaceholder;

  /// No description provided for @passwordPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mật khẩu'**
  String get passwordPlaceholder;

  /// No description provided for @confirmPasswordPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu'**
  String get confirmPasswordPlaceholder;

  /// No description provided for @percentDiscountBadge.
  ///
  /// In vi, this message translates to:
  /// **'GIẢM %'**
  String get percentDiscountBadge;

  /// No description provided for @fixedDiscountBadge.
  ///
  /// In vi, this message translates to:
  /// **'GIẢM TIỀN'**
  String get fixedDiscountBadge;

  /// No description provided for @discountTypePercentage.
  ///
  /// In vi, this message translates to:
  /// **'Giảm theo phần trăm (%)'**
  String get discountTypePercentage;

  /// No description provided for @discountTypeFixed.
  ///
  /// In vi, this message translates to:
  /// **'Giảm số tiền cố định (VNĐ)'**
  String get discountTypeFixed;

  /// No description provided for @noPromotionsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có mã khuyến mãi nào được tạo. Nhấn nút bên dưới để tạo mã mới.'**
  String get noPromotionsSubtitle;

  /// No description provided for @pricePlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: 65.000'**
  String get pricePlaceholder;

  /// No description provided for @stockPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: 100'**
  String get stockPlaceholder;

  /// No description provided for @movieManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý phim'**
  String get movieManagement;

  /// No description provided for @togglePasswordVisibility.
  ///
  /// In vi, this message translates to:
  /// **'Hiện/ẩn mật khẩu'**
  String get togglePasswordVisibility;

  /// No description provided for @unitVnd.
  ///
  /// In vi, this message translates to:
  /// **'VNĐ'**
  String get unitVnd;

  /// No description provided for @unitPercent.
  ///
  /// In vi, this message translates to:
  /// **'%'**
  String get unitPercent;

  /// No description provided for @screenLabel.
  ///
  /// In vi, this message translates to:
  /// **'MÀN HÌNH'**
  String get screenLabel;

  /// No description provided for @shortMonthFormat.
  ///
  /// In vi, this message translates to:
  /// **'T{month}'**
  String shortMonthFormat(int month);

  /// No description provided for @startTime.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian bắt đầu'**
  String get startTime;

  /// No description provided for @statusInactive.
  ///
  /// In vi, this message translates to:
  /// **'Ngưng hoạt động'**
  String get statusInactive;

  /// No description provided for @exitAppTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thoát ứng dụng'**
  String get exitAppTitle;

  /// No description provided for @exitAppMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn thoát ứng dụng không?'**
  String get exitAppMessage;

  /// No description provided for @exitAppConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Thoát'**
  String get exitAppConfirm;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng cần quyền truy cập máy ảnh để quét vé'**
  String get cameraPermissionRequired;

  /// No description provided for @grantPermission.
  ///
  /// In vi, this message translates to:
  /// **'Cấp quyền máy ảnh'**
  String get grantPermission;

  /// No description provided for @cameraUnsupported.
  ///
  /// In vi, this message translates to:
  /// **'Thiết bị không hỗ trợ máy ảnh hoặc đang chạy giả lập. Vui lòng nhập mã vé thủ công.'**
  String get cameraUnsupported;

  /// No description provided for @addMovie.
  ///
  /// In vi, this message translates to:
  /// **'Thêm phim mới'**
  String get addMovie;

  /// No description provided for @updateMovie.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật phim'**
  String get updateMovie;

  /// No description provided for @movieCreatedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thêm phim thành công!'**
  String get movieCreatedSuccess;

  /// No description provided for @movieUpdatedSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật phim thành công!'**
  String get movieUpdatedSuccess;

  /// No description provided for @movieDescription.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả phim'**
  String get movieDescription;

  /// No description provided for @enterMovieDescription.
  ///
  /// In vi, this message translates to:
  /// **'Nhập nội dung tóm tắt phim...'**
  String get enterMovieDescription;

  /// No description provided for @status.
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get status;

  /// No description provided for @stoppedShowing.
  ///
  /// In vi, this message translates to:
  /// **'Ngừng chiếu'**
  String get stoppedShowing;

  /// No description provided for @editMovie.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa phim'**
  String get editMovie;

  /// No description provided for @watchTrailer.
  ///
  /// In vi, this message translates to:
  /// **'Xem trailer'**
  String get watchTrailer;

  /// No description provided for @noTrailer.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có trailer'**
  String get noTrailer;

  /// No description provided for @movieInfo.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin phim'**
  String get movieInfo;

  /// No description provided for @copy.
  ///
  /// In vi, this message translates to:
  /// **'Sao chép'**
  String get copy;

  /// No description provided for @trailerCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép liên kết trailer'**
  String get trailerCopied;

  /// No description provided for @openInBrowser.
  ///
  /// In vi, this message translates to:
  /// **'Mở liên kết'**
  String get openInBrowser;

  /// No description provided for @cannotOpenTrailer.
  ///
  /// In vi, this message translates to:
  /// **'Không thể mở liên kết trailer'**
  String get cannotOpenTrailer;

  /// No description provided for @replayTrailer.
  ///
  /// In vi, this message translates to:
  /// **'Xem lại'**
  String get replayTrailer;

  /// No description provided for @seekBackward10s.
  ///
  /// In vi, this message translates to:
  /// **'Tua lại 10s'**
  String get seekBackward10s;

  /// No description provided for @seekForward10s.
  ///
  /// In vi, this message translates to:
  /// **'Tua tới 10s'**
  String get seekForward10s;

  /// No description provided for @playPauseTrailer.
  ///
  /// In vi, this message translates to:
  /// **'Phát / Dừng'**
  String get playPauseTrailer;

  /// No description provided for @fullscreen.
  ///
  /// In vi, this message translates to:
  /// **'Toàn màn hình'**
  String get fullscreen;

  /// No description provided for @exitFullscreen.
  ///
  /// In vi, this message translates to:
  /// **'Thu nhỏ'**
  String get exitFullscreen;

  /// No description provided for @manageTickets.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý vé'**
  String get manageTickets;

  /// No description provided for @ticketManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý toàn bộ vé'**
  String get ticketManagement;

  /// No description provided for @ticketBookingList.
  ///
  /// In vi, this message translates to:
  /// **'Đơn đặt vé'**
  String get ticketBookingList;

  /// No description provided for @ticketPriceConfig.
  ///
  /// In vi, this message translates to:
  /// **'Cấu hình giá vé'**
  String get ticketPriceConfig;

  /// No description provided for @ticketBookingCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã đơn'**
  String get ticketBookingCode;

  /// No description provided for @ticketCustomerName.
  ///
  /// In vi, this message translates to:
  /// **'Khách hàng'**
  String get ticketCustomerName;

  /// No description provided for @ticketShowtimeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Suất chiếu'**
  String get ticketShowtimeLabel;

  /// No description provided for @ticketSeatLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghế ngồi'**
  String get ticketSeatLabel;

  /// No description provided for @ticketPaymentStatus.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get ticketPaymentStatus;

  /// No description provided for @ticketCheckedInStatus.
  ///
  /// In vi, this message translates to:
  /// **'Đã soát vé'**
  String get ticketCheckedInStatus;

  /// No description provided for @ticketNotCheckedInStatus.
  ///
  /// In vi, this message translates to:
  /// **'Chưa soát vé'**
  String get ticketNotCheckedInStatus;

  /// No description provided for @ticketSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo mã BK, tên, SĐT...'**
  String get ticketSearchHint;

  /// No description provided for @ticketPriceWeekday.
  ///
  /// In vi, this message translates to:
  /// **'Ngày thường'**
  String get ticketPriceWeekday;

  /// No description provided for @ticketPriceWeekend.
  ///
  /// In vi, this message translates to:
  /// **'Cuối tuần'**
  String get ticketPriceWeekend;

  /// No description provided for @ticketEditPrice.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật giá vé'**
  String get ticketEditPrice;

  /// No description provided for @ticketPriceUpdateSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật giá vé thành công'**
  String get ticketPriceUpdateSuccess;

  /// No description provided for @ticketStatusConfirmed.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác nhận'**
  String get ticketStatusConfirmed;

  /// No description provided for @ticketStatusPending.
  ///
  /// In vi, this message translates to:
  /// **'Chờ thanh toán'**
  String get ticketStatusPending;

  /// No description provided for @ticketStatusCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get ticketStatusCancelled;

  /// No description provided for @ticketFilterAll.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get ticketFilterAll;

  /// No description provided for @ticketConcessionsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bắp nước'**
  String get ticketConcessionsLabel;

  /// No description provided for @ticketDetailTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết đơn vé'**
  String get ticketDetailTitle;

  /// No description provided for @ticketOpenScanner.
  ///
  /// In vi, this message translates to:
  /// **'Soát vé QR'**
  String get ticketOpenScanner;

  /// No description provided for @ticketEmptyList.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đơn vé nào'**
  String get ticketEmptyList;

  /// No description provided for @ticketPriceEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có cấu hình giá vé'**
  String get ticketPriceEmpty;

  /// No description provided for @ticketPriceEnterNew.
  ///
  /// In vi, this message translates to:
  /// **'Nhập giá vé mới (VNĐ)'**
  String get ticketPriceEnterNew;

  /// No description provided for @shiftTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ca làm việc'**
  String get shiftTitle;

  /// No description provided for @shiftManagement.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý ca làm việc'**
  String get shiftManagement;

  /// No description provided for @shiftSchedule.
  ///
  /// In vi, this message translates to:
  /// **'Lịch ca nhân viên'**
  String get shiftSchedule;

  /// No description provided for @shiftMySchedule.
  ///
  /// In vi, this message translates to:
  /// **'Lịch làm việc của tôi'**
  String get shiftMySchedule;

  /// No description provided for @shiftAssignNew.
  ///
  /// In vi, this message translates to:
  /// **'Phân ca mới'**
  String get shiftAssignNew;

  /// No description provided for @shiftEdit.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa ca làm'**
  String get shiftEdit;

  /// No description provided for @shiftDelete.
  ///
  /// In vi, this message translates to:
  /// **'Hủy phân ca'**
  String get shiftDelete;

  /// No description provided for @shiftDeleteConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc chắn muốn hủy phân ca làm việc này?'**
  String get shiftDeleteConfirm;

  /// No description provided for @shiftAssignSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Phân ca làm việc thành công'**
  String get shiftAssignSuccess;

  /// No description provided for @shiftUpdateSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật phân ca thành công'**
  String get shiftUpdateSuccess;

  /// No description provided for @shiftDeleteSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Hủy phân ca thành công'**
  String get shiftDeleteSuccess;

  /// No description provided for @shiftSelectStaff.
  ///
  /// In vi, this message translates to:
  /// **'Chọn nhân viên'**
  String get shiftSelectStaff;

  /// No description provided for @shiftSelectCinema.
  ///
  /// In vi, this message translates to:
  /// **'Chọn cụm rạp'**
  String get shiftSelectCinema;

  /// No description provided for @shiftSelectShift.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ca làm'**
  String get shiftSelectShift;

  /// No description provided for @shiftSelectRole.
  ///
  /// In vi, this message translates to:
  /// **'Vị trí phân công'**
  String get shiftSelectRole;

  /// No description provided for @shiftSelectDate.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngày làm việc'**
  String get shiftSelectDate;

  /// No description provided for @shiftNote.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú phân công'**
  String get shiftNote;

  /// No description provided for @shiftNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập ghi chú cho nhân viên (không bắt buộc)...'**
  String get shiftNoteHint;

  /// No description provided for @shiftRoleTicketCounter.
  ///
  /// In vi, this message translates to:
  /// **'Bán vé tại quầy'**
  String get shiftRoleTicketCounter;

  /// No description provided for @shiftRoleScannerGate.
  ///
  /// In vi, this message translates to:
  /// **'Soát vé tại cửa'**
  String get shiftRoleScannerGate;

  /// No description provided for @shiftRoleConcession.
  ///
  /// In vi, this message translates to:
  /// **'Quầy bắp nước'**
  String get shiftRoleConcession;

  /// No description provided for @shiftRoleGeneral.
  ///
  /// In vi, this message translates to:
  /// **'Nhân viên tổng hợp'**
  String get shiftRoleGeneral;

  /// No description provided for @shiftStatusScheduled.
  ///
  /// In vi, this message translates to:
  /// **'Đã lên lịch'**
  String get shiftStatusScheduled;

  /// No description provided for @shiftStatusCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get shiftStatusCompleted;

  /// No description provided for @shiftStatusCancelled.
  ///
  /// In vi, this message translates to:
  /// **'Đã hủy'**
  String get shiftStatusCancelled;

  /// No description provided for @shiftEmptyList.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có nhân viên nào được phân ca trong ngày này'**
  String get shiftEmptyList;

  /// No description provided for @shiftEmptyMySchedule.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có ca làm việc nào trong tuần này'**
  String get shiftEmptyMySchedule;

  /// No description provided for @shiftCurrentWeek.
  ///
  /// In vi, this message translates to:
  /// **'Tuần này'**
  String get shiftCurrentWeek;

  /// No description provided for @shiftNextWeek.
  ///
  /// In vi, this message translates to:
  /// **'Tuần sau'**
  String get shiftNextWeek;

  /// No description provided for @shiftPreviousWeek.
  ///
  /// In vi, this message translates to:
  /// **'Tuần trước'**
  String get shiftPreviousWeek;

  /// No description provided for @shiftAssignedBy.
  ///
  /// In vi, this message translates to:
  /// **'Người phân ca'**
  String get shiftAssignedBy;
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
      <String>['vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
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
