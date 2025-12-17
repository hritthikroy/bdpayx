import 'package:flutter/material.dart';

/// Professional vector-based icons that support theme colors
class CustomIcons {
  // Navigation icons
  static Widget home({Color? color, double? size}) => Icon(
    Icons.home_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget notifications({Color? color, double? size}) => Icon(
    Icons.notifications_rounded,
    color: color ?? const Color(0xFFF59E0B),
    size: size ?? 24,
  );
  
  static Widget supportAgent({Color? color, double? size}) => Icon(
    Icons.headset_mic_rounded,
    color: color ?? const Color(0xFF06B6D4),
    size: size ?? 24,
  );
  
  static Widget history({Color? color, double? size}) => Icon(
    Icons.history_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  static Widget accountCircle({Color? color, double? size}) => Icon(
    Icons.account_circle_rounded,
    color: color ?? const Color(0xFFEC4899),
    size: size ?? 24,
  );
  
  // Chart and analytics
  static Widget showChart({Color? color, double? size}) => Icon(
    Icons.show_chart_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget trendingUp({Color? color, double? size}) => Icon(
    Icons.trending_up_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  static Widget trendingDown({Color? color, double? size}) => Icon(
    Icons.trending_down_rounded,
    color: color ?? const Color(0xFFEF4444),
    size: size ?? 24,
  );
  
  // Sync and refresh
  static Widget sync({Color? color, double? size}) => Icon(
    Icons.sync_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  static Widget refresh({Color? color, double? size}) => Icon(
    Icons.refresh_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  // Financial icons
  static Widget addCard({Color? color, double? size}) => Icon(
    Icons.add_card_rounded,
    color: color ?? const Color(0xFF3B82F6),
    size: size ?? 24,
  );
  
  static Widget accountBalance({Color? color, double? size}) => Icon(
    Icons.account_balance_rounded,
    color: color ?? const Color(0xFF8B5CF6),
    size: size ?? 24,
  );
  
  static Widget cardGiftcard({Color? color, double? size}) => Icon(
    Icons.card_giftcard_rounded,
    color: color ?? const Color(0xFFF59E0B),
    size: size ?? 24,
  );
  
  static Widget currencyRupee({Color? color, double? size}) => Icon(
    Icons.currency_rupee_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  static Widget payment({Color? color, double? size}) => Icon(
    Icons.payment_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget wallet({Color? color, double? size}) => Icon(
    Icons.account_balance_wallet_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  // Security and privacy
  static Widget visibility({Color? color, double? size}) => Icon(
    Icons.visibility_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget visibilityOff({Color? color, double? size}) => Icon(
    Icons.visibility_off_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget security({Color? color, double? size}) => Icon(
    Icons.security_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget lockOutline({Color? color, double? size}) => Icon(
    Icons.lock_outline_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget login({Color? color, double? size}) => Icon(
    Icons.login_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  // Navigation arrows
  static Widget arrowForwardIos({Color? color, double? size}) => Icon(
    Icons.arrow_forward_ios_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 16,
  );
  
  static Widget arrowBack({Color? color, double? size}) => Icon(
    Icons.arrow_back_rounded,
    color: color ?? Colors.white,
    size: size ?? 24,
  );
  
  static Widget arrowForward({Color? color, double? size}) => Icon(
    Icons.arrow_forward_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  // Status and info
  static Widget info({Color? color, double? size}) => Icon(
    Icons.info_outline_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget warning({Color? color, double? size}) => Icon(
    Icons.warning_amber_rounded,
    color: color ?? const Color(0xFFF59E0B),
    size: size ?? 24,
  );
  
  static Widget error({Color? color, double? size}) => Icon(
    Icons.error_outline_rounded,
    color: color ?? const Color(0xFFEF4444),
    size: size ?? 24,
  );
  
  static Widget checkCircle({Color? color, double? size}) => Icon(
    Icons.check_circle_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  static Widget check({Color? color, double? size}) => Icon(
    Icons.check_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  // Communication
  static Widget email({Color? color, double? size}) => Icon(
    Icons.email_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget phone({Color? color, double? size}) => Icon(
    Icons.phone_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  static Widget chat({Color? color, double? size}) => Icon(
    Icons.chat_bubble_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget message({Color? color, double? size}) => Icon(
    Icons.message_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget videoCall({Color? color, double? size}) => Icon(
    Icons.videocam_rounded,
    color: color ?? const Color(0xFF8B5CF6),
    size: size ?? 24,
  );
  
  // Settings and tools
  static Widget settings({Color? color, double? size}) => Icon(
    Icons.settings_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget edit({Color? color, double? size}) => Icon(
    Icons.edit_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget delete({Color? color, double? size}) => Icon(
    Icons.delete_rounded,
    color: color ?? const Color(0xFFEF4444),
    size: size ?? 24,
  );
  
  static Widget copy({Color? color, double? size}) => Icon(
    Icons.copy_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget share({Color? color, double? size}) => Icon(
    Icons.share_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget download({Color? color, double? size}) => Icon(
    Icons.download_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  static Widget upload({Color? color, double? size}) => Icon(
    Icons.upload_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  // User and profile
  static Widget person({Color? color, double? size}) => Icon(
    Icons.person_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget people({Color? color, double? size}) => Icon(
    Icons.people_rounded,
    color: color ?? const Color(0xFF8B5CF6),
    size: size ?? 24,
  );
  
  static Widget personAdd({Color? color, double? size}) => Icon(
    Icons.person_add_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  // Documents and files
  static Widget document({Color? color, double? size}) => Icon(
    Icons.description_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget receipt({Color? color, double? size}) => Icon(
    Icons.receipt_long_rounded,
    color: color ?? const Color(0xFF8B5CF6),
    size: size ?? 24,
  );
  
  static Widget folder({Color? color, double? size}) => Icon(
    Icons.folder_rounded,
    color: color ?? const Color(0xFFF59E0B),
    size: size ?? 24,
  );
  
  // Time and calendar
  static Widget timer({Color? color, double? size}) => Icon(
    Icons.timer_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget schedule({Color? color, double? size}) => Icon(
    Icons.schedule_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget calendar({Color? color, double? size}) => Icon(
    Icons.calendar_today_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  // Misc
  static Widget star({Color? color, double? size}) => Icon(
    Icons.star_rounded,
    color: color ?? const Color(0xFFF59E0B),
    size: size ?? 24,
  );
  
  static Widget starBorder({Color? color, double? size}) => Icon(
    Icons.star_border_rounded,
    color: color ?? const Color(0xFFF59E0B),
    size: size ?? 24,
  );
  
  static Widget favorite({Color? color, double? size}) => Icon(
    Icons.favorite_rounded,
    color: color ?? const Color(0xFFEF4444),
    size: size ?? 24,
  );
  
  static Widget gift({Color? color, double? size}) => Icon(
    Icons.card_giftcard_rounded,
    color: color ?? const Color(0xFFF59E0B),
    size: size ?? 24,
  );
  
  static Widget flash({Color? color, double? size}) => Icon(
    Icons.flash_on_rounded,
    color: color ?? const Color(0xFFF59E0B),
    size: size ?? 24,
  );
  
  static Widget verified({Color? color, double? size}) => Icon(
    Icons.verified_rounded,
    color: color ?? const Color(0xFF10B981),
    size: size ?? 24,
  );
  
  static Widget shield({Color? color, double? size}) => Icon(
    Icons.shield_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget help({Color? color, double? size}) => Icon(
    Icons.help_outline_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget logout({Color? color, double? size}) => Icon(
    Icons.logout_rounded,
    color: color ?? const Color(0xFFEF4444),
    size: size ?? 24,
  );
  
  static Widget close({Color? color, double? size}) => Icon(
    Icons.close_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget add({Color? color, double? size}) => Icon(
    Icons.add_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget remove({Color? color, double? size}) => Icon(
    Icons.remove_rounded,
    color: color ?? const Color(0xFFEF4444),
    size: size ?? 24,
  );
  
  static Widget more({Color? color, double? size}) => Icon(
    Icons.more_horiz_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget moreVert({Color? color, double? size}) => Icon(
    Icons.more_vert_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget menu({Color? color, double? size}) => Icon(
    Icons.menu_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget search({Color? color, double? size}) => Icon(
    Icons.search_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget filter({Color? color, double? size}) => Icon(
    Icons.filter_list_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget sort({Color? color, double? size}) => Icon(
    Icons.sort_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget qrCode({Color? color, double? size}) => Icon(
    Icons.qr_code_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget camera({Color? color, double? size}) => Icon(
    Icons.camera_alt_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget image({Color? color, double? size}) => Icon(
    Icons.image_rounded,
    color: color ?? const Color(0xFF8B5CF6),
    size: size ?? 24,
  );
  
  static Widget location({Color? color, double? size}) => Icon(
    Icons.location_on_rounded,
    color: color ?? const Color(0xFFEF4444),
    size: size ?? 24,
  );
  
  static Widget language({Color? color, double? size}) => Icon(
    Icons.language_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget darkMode({Color? color, double? size}) => Icon(
    Icons.dark_mode_rounded,
    color: color ?? const Color(0xFF64748B),
    size: size ?? 24,
  );
  
  static Widget lightMode({Color? color, double? size}) => Icon(
    Icons.light_mode_rounded,
    color: color ?? const Color(0xFFF59E0B),
    size: size ?? 24,
  );
  
  static Widget notificationsActive({Color? color, double? size}) => Icon(
    Icons.notifications_active_rounded,
    color: color ?? const Color(0xFFF59E0B),
    size: size ?? 24,
  );
  
  static Widget notificationsOff({Color? color, double? size}) => Icon(
    Icons.notifications_off_rounded,
    color: color ?? const Color(0xFF94A3B8),
    size: size ?? 24,
  );
  
  static Widget play({Color? color, double? size}) => Icon(
    Icons.play_arrow_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget pause({Color? color, double? size}) => Icon(
    Icons.pause_rounded,
    color: color ?? const Color(0xFF6366F1),
    size: size ?? 24,
  );
  
  static Widget stop({Color? color, double? size}) => Icon(
    Icons.stop_rounded,
    color: color ?? const Color(0xFFEF4444),
    size: size ?? 24,
  );
}
