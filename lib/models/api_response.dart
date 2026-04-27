/// Generic wrapper for all API responses matching the standard shape:
/// ```json
/// { "success": true, "data": { ... }, "message": "..." }
/// { "success": false, "error": "What went wrong" }
/// ```
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromData,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromData != null
          ? fromData(json['data'])
          : json['data'] as T?,
      message: json['message'],
      error: json['error'],
    );
  }
}

/// Paginated list response:
/// ```json
/// { "success": true, "data": [...], "total": 42, "page": 1, "pageSize": 20, "hasMore": true }
/// ```
class PaginatedResponse<T> {
  final bool success;
  final List<T> data;
  final int total;
  final int page;
  final int pageSize;
  final bool hasMore;
  final String? error;

  PaginatedResponse({
    required this.success,
    required this.data,
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.hasMore = false,
    this.error,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final rawData = json['data'];
    List<T> items = [];
    if (rawData is List) {
      items = rawData
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList();
    }
    return PaginatedResponse<T>(
      success: json['success'] ?? false,
      data: items,
      total: json['total'] ?? items.length,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      hasMore: json['hasMore'] ?? false,
      error: json['error'],
    );
  }
}
