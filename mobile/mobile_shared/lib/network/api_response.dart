class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final PaginationInfo? pagination;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.pagination,
  });

  factory ApiResponse.fromJson(dynamic json, [T Function(dynamic)? parser]) {
    if (json is! Map<String, dynamic>) {
      if (json is List && parser != null) {
        return ApiResponse(success: true, data: parser(json));
      }
      return ApiResponse(success: false);
    }
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && parser != null ? parser(json['data']) : json['data'] as T?,
      pagination: json['pagination'] != null ? PaginationInfo.fromJson(json['pagination']) : null,
    );
  }
}

class PaginationInfo {
  final int page;
  final int pageSize;
  final int totalItems;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
