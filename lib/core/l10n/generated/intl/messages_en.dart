// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(count) => "${count} Active Links";

  static String m1(start, end) => "Availability: ${start} / ${end}";

  static String m2(code) => "Code: ${code}";

  static String m3(id) =>
      "Are you sure you want to delete this response (ID: ${id})? This action cannot be undone.";

  static String m4(date) => "Created: ${date}";

  static String m5(count) => "${count} Drafts Available";

  static String m6(email) => "Enter the code sent to ${email}";

  static String m7(message) => "Error: ${message}";

  static String m8(date) => "Last Update: ${date}";

  static String m9(date) => "Last updated: ${date}";

  static String m10(count) => "Local Responses (${count})";

  static String m11(count) => "+${count} Mins";

  static String m12(date) => "Publish Date: ${date}";

  static String m13(count) => "${count} Questions";

  static String m14(id) => "Response ID: ${id}";

  static String m15(count) => "${count} Sections";

  static String m16(title) => "Survey Link: ${title}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "activate": MessageLookupByLibrary.simpleMessage("Activate"),
        "activate_account":
            MessageLookupByLibrary.simpleMessage("Activate Account"),
        "active_links_count": m0,
        "active_responses":
            MessageLookupByLibrary.simpleMessage("Active Responses"),
        "active_surveys": MessageLookupByLibrary.simpleMessage("Active"),
        "active_tasks": MessageLookupByLibrary.simpleMessage("Active Tasks"),
        "allow_location_access":
            MessageLookupByLibrary.simpleMessage("Allow location access"),
        "arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
        "assignments": MessageLookupByLibrary.simpleMessage("Assignments"),
        "availability_period": m1,
        "available_surveys":
            MessageLookupByLibrary.simpleMessage("Available Surveys"),
        "avg": MessageLookupByLibrary.simpleMessage("Avg."),
        "back_to_assignments":
            MessageLookupByLibrary.simpleMessage("Back to Assignments"),
        "browser": MessageLookupByLibrary.simpleMessage("Browser"),
        "camera": MessageLookupByLibrary.simpleMessage("Camera"),
        "camera_permission_required": MessageLookupByLibrary.simpleMessage(
            "Camera permission is required to scan QR codes"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancel_download":
            MessageLookupByLibrary.simpleMessage("Cancel Download"),
        "cancel_upload": MessageLookupByLibrary.simpleMessage("Cancel Upload"),
        "clear_all": MessageLookupByLibrary.simpleMessage("Clear All"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "code": MessageLookupByLibrary.simpleMessage("Code"),
        "code_colon": m2,
        "company": MessageLookupByLibrary.simpleMessage("Company"),
        "complete_device_registration": MessageLookupByLibrary.simpleMessage(
            "Complete the device registration process in the system"),
        "complete_registration_tap_notice": MessageLookupByLibrary.simpleMessage(
            "By tapping \'Link Device\', this device will be unique to your researcher profile."),
        "completed": MessageLookupByLibrary.simpleMessage("Completed"),
        "completion_rate":
            MessageLookupByLibrary.simpleMessage("Completion Rate"),
        "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "confirm_delete_message": m3,
        "confirm_delete_title":
            MessageLookupByLibrary.simpleMessage("Delete Confirmation"),
        "cookie_based_method_description": MessageLookupByLibrary.simpleMessage(
            "Cookie-based method will be used for device registration"),
        "copy_link": MessageLookupByLibrary.simpleMessage("Copy Link"),
        "created_at_colon": m4,
        "custody": MessageLookupByLibrary.simpleMessage("Custody"),
        "custody_status_cancelled":
            MessageLookupByLibrary.simpleMessage("Cancelled"),
        "custody_status_pending":
            MessageLookupByLibrary.simpleMessage("Pending"),
        "custody_status_verified":
            MessageLookupByLibrary.simpleMessage("Verified"),
        "custody_verified_successfully": MessageLookupByLibrary.simpleMessage(
            "Custody verified successfully"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "delete_draft_message": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this survey draft?"),
        "delete_draft_title":
            MessageLookupByLibrary.simpleMessage("Delete Draft"),
        "device_already_registered": MessageLookupByLibrary.simpleMessage(
            "This device is already registered"),
        "device_already_registered_desc": MessageLookupByLibrary.simpleMessage(
            "This device ID is already associated with another profile or has been previously linked."),
        "device_information": MessageLookupByLibrary.simpleMessage(
            "Information Extracted from the Device"),
        "device_name": MessageLookupByLibrary.simpleMessage("Device Name"),
        "device_registered_success": MessageLookupByLibrary.simpleMessage(
            "Device successfully linked to your account"),
        "device_registered_successfully": MessageLookupByLibrary.simpleMessage(
            "Device registered successfully"),
        "device_type": MessageLookupByLibrary.simpleMessage("Device Type"),
        "download_file": MessageLookupByLibrary.simpleMessage("Download File"),
        "downloading": MessageLookupByLibrary.simpleMessage("Downloading..."),
        "draft_responses": MessageLookupByLibrary.simpleMessage("Drafts"),
        "drafts_available": m5,
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "email_verified_success":
            MessageLookupByLibrary.simpleMessage("Email verified successfully"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "enter_code": MessageLookupByLibrary.simpleMessage("Enter Code"),
        "enter_code_sent": m6,
        "enter_details":
            MessageLookupByLibrary.simpleMessage("Enter your login details"),
        "enter_email":
            MessageLookupByLibrary.simpleMessage("Enter email address"),
        "enter_email_reset": MessageLookupByLibrary.simpleMessage(
            "Enter your email to receive a reset code"),
        "enter_notes_optional":
            MessageLookupByLibrary.simpleMessage("Enter notes (optional)"),
        "enter_survey_code":
            MessageLookupByLibrary.simpleMessage("Enter Survey Code"),
        "enter_verification_code":
            MessageLookupByLibrary.simpleMessage("Enter Verification Code"),
        "enter_verification_code_instruction":
            MessageLookupByLibrary.simpleMessage(
                "Enter the verification code sent to your email"),
        "entity": MessageLookupByLibrary.simpleMessage("Entity"),
        "error_occurred":
            MessageLookupByLibrary.simpleMessage("An error occurred"),
        "error_with_message": m7,
        "expired_surveys": MessageLookupByLibrary.simpleMessage("Expired"),
        "expires_at": MessageLookupByLibrary.simpleMessage("Expires At"),
        "failed_pick_image": MessageLookupByLibrary.simpleMessage(
            "Failed to pick image, please try again later!"),
        "failed_to_save_image":
            MessageLookupByLibrary.simpleMessage("Failed to save image"),
        "field_required":
            MessageLookupByLibrary.simpleMessage("This field is required"),
        "file_downloaded_colon":
            MessageLookupByLibrary.simpleMessage("File downloaded to:"),
        "file_downloaded_successfully": MessageLookupByLibrary.simpleMessage(
            "File downloaded successfully"),
        "file_ready": MessageLookupByLibrary.simpleMessage("File is ready"),
        "file_selected": MessageLookupByLibrary.simpleMessage("File selected"),
        "forgot_password":
            MessageLookupByLibrary.simpleMessage("Forgot your password?"),
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
        "gb": MessageLookupByLibrary.simpleMessage("GB"),
        "get_started": MessageLookupByLibrary.simpleMessage("Get Started"),
        "grant_permission":
            MessageLookupByLibrary.simpleMessage("Grant Permission"),
        "hide_details": MessageLookupByLibrary.simpleMessage("Hide Details"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "home_survey_status_subtitle": MessageLookupByLibrary.simpleMessage(
            "Here is what\'s happening with your surveys today."),
        "id_number": MessageLookupByLibrary.simpleMessage("ID Number"),
        "image_saved_successfully": MessageLookupByLibrary.simpleMessage(
            "Image saved successfully to gallery"),
        "in_progress_surveys":
            MessageLookupByLibrary.simpleMessage("In-Progress Surveys"),
        "invalid_email":
            MessageLookupByLibrary.simpleMessage("Invalid email address"),
        "invalid_qr_code": MessageLookupByLibrary.simpleMessage(
            "Invalid QR code. Please try again."),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "language_dialog_cancel":
            MessageLookupByLibrary.simpleMessage("Cancel"),
        "language_dialog_confirm":
            MessageLookupByLibrary.simpleMessage("Confirm"),
        "language_dialog_title":
            MessageLookupByLibrary.simpleMessage("Select Language"),
        "last_update": m8,
        "last_updated_at": m9,
        "link_copied":
            MessageLookupByLibrary.simpleMessage("Link copied to clipboard"),
        "link_device": MessageLookupByLibrary.simpleMessage("Link Device"),
        "local_responses_count": m10,
        "location_permission_denied":
            MessageLookupByLibrary.simpleMessage("Location permission denied"),
        "location_permission_required_message":
            MessageLookupByLibrary.simpleMessage(
                "To use this app, you must allow access to your device location."),
        "location_permission_required_title":
            MessageLookupByLibrary.simpleMessage(
                "Location permission required"),
        "location_required":
            MessageLookupByLibrary.simpleMessage("Location Required"),
        "location_tracking_started":
            MessageLookupByLibrary.simpleMessage("Location tracking started"),
        "location_tracking_stopped":
            MessageLookupByLibrary.simpleMessage("Location tracking stopped"),
        "location_update_failed":
            MessageLookupByLibrary.simpleMessage("Location update failed"),
        "location_updated":
            MessageLookupByLibrary.simpleMessage("Location updated"),
        "location_warning_logout": MessageLookupByLibrary.simpleMessage(
            "Warning: You are outside the allowed zone. Logging out..."),
        "log_out": MessageLookupByLibrary.simpleMessage("Log Out"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "login_as_admin":
            MessageLookupByLibrary.simpleMessage("Login as Admin"),
        "login_message": MessageLookupByLibrary.simpleMessage("Please log in"),
        "login_success":
            MessageLookupByLibrary.simpleMessage("Login successful"),
        "logout_message": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to log out?"),
        "logout_title": MessageLookupByLibrary.simpleMessage("Log Out"),
        "main_menu": MessageLookupByLibrary.simpleMessage("Main Menu"),
        "max_responses": MessageLookupByLibrary.simpleMessage("Max Responses"),
        "max_touch_points":
            MessageLookupByLibrary.simpleMessage("Maximum Touch Points"),
        "minutes_count": m11,
        "nationality": MessageLookupByLibrary.simpleMessage("Nationality"),
        "new_password": MessageLookupByLibrary.simpleMessage("New Password"),
        "new_response": MessageLookupByLibrary.simpleMessage("New Response"),
        "new_response_success": MessageLookupByLibrary.simpleMessage(
            "New response started successfully"),
        "next": MessageLookupByLibrary.simpleMessage("Next"),
        "no_active_account": MessageLookupByLibrary.simpleMessage(
            "Don\'t have an active account?"),
        "no_active_responses":
            MessageLookupByLibrary.simpleMessage("No active responses found"),
        "no_custody_records":
            MessageLookupByLibrary.simpleMessage("No Custody Records"),
        "no_custody_records_description": MessageLookupByLibrary.simpleMessage(
            "You don\'t have any custody records yet"),
        "no_data": MessageLookupByLibrary.simpleMessage("No data"),
        "no_password":
            MessageLookupByLibrary.simpleMessage("Please enter your password"),
        "no_public_links":
            MessageLookupByLibrary.simpleMessage("No Public Links"),
        "no_public_links_description": MessageLookupByLibrary.simpleMessage(
            "You don\'t have any public links assigned yet"),
        "no_responses_found":
            MessageLookupByLibrary.simpleMessage("No responses found"),
        "no_surveys_available": MessageLookupByLibrary.simpleMessage(
            "No surveys available at the moment"),
        "no_user_data":
            MessageLookupByLibrary.simpleMessage("No user data found"),
        "no_user_name":
            MessageLookupByLibrary.simpleMessage("Please enter your email"),
        "not_available": MessageLookupByLibrary.simpleMessage("Not Available"),
        "notes": MessageLookupByLibrary.simpleMessage("Notes"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "offline_drafts":
            MessageLookupByLibrary.simpleMessage("Offline Drafts"),
        "offline_mode":
            MessageLookupByLibrary.simpleMessage("Viewing offline data"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "operating_system":
            MessageLookupByLibrary.simpleMessage("Operating System"),
        "or": MessageLookupByLibrary.simpleMessage("or"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "password_reset_success":
            MessageLookupByLibrary.simpleMessage("Password reset successful"),
        "password_too_short":
            MessageLookupByLibrary.simpleMessage("Password too short"),
        "pending_sync": MessageLookupByLibrary.simpleMessage("Pending Sync"),
        "phone": MessageLookupByLibrary.simpleMessage("Phone"),
        "place_qr_code": MessageLookupByLibrary.simpleMessage(
            "Place the QR code within the frame to scan"),
        "please_enter_code":
            MessageLookupByLibrary.simpleMessage("Please enter code"),
        "please_enter_email":
            MessageLookupByLibrary.simpleMessage("Please enter email address"),
        "please_enter_verification_code": MessageLookupByLibrary.simpleMessage(
            "Please enter the 6-digit verification code"),
        "please_select": MessageLookupByLibrary.simpleMessage("Please select"),
        "point_camera_at_qr_code":
            MessageLookupByLibrary.simpleMessage("Point camera at QR code"),
        "position": MessageLookupByLibrary.simpleMessage("Position"),
        "previous": MessageLookupByLibrary.simpleMessage("Previous"),
        "processing": MessageLookupByLibrary.simpleMessage("Processing..."),
        "processor_cores":
            MessageLookupByLibrary.simpleMessage("Processor Cores"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "public_link_not_found":
            MessageLookupByLibrary.simpleMessage("Public link not found"),
        "public_links": MessageLookupByLibrary.simpleMessage("Public Links"),
        "publish_date": m12,
        "qr_code": MessageLookupByLibrary.simpleMessage("QR Code"),
        "qr_scanner": MessageLookupByLibrary.simpleMessage("QR Scanner"),
        "questions_count": m13,
        "queue_detail_body": MessageLookupByLibrary.simpleMessage("Body"),
        "queue_detail_error": MessageLookupByLibrary.simpleMessage("Error"),
        "queue_status_completed":
            MessageLookupByLibrary.simpleMessage("Completed"),
        "queue_status_failed": MessageLookupByLibrary.simpleMessage("Failed"),
        "queue_status_processing":
            MessageLookupByLibrary.simpleMessage("Processing"),
        "queue_summary_title":
            MessageLookupByLibrary.simpleMessage("Queued requests"),
        "ram": MessageLookupByLibrary.simpleMessage("RAM"),
        "read_more": MessageLookupByLibrary.simpleMessage("Read more"),
        "receive_custody":
            MessageLookupByLibrary.simpleMessage("Receive Custody"),
        "register_device":
            MessageLookupByLibrary.simpleMessage("Register Device"),
        "registration_method_cookie_based_description":
            MessageLookupByLibrary.simpleMessage(
                "Using a secure cookie stored in the app\'s secure storage for this device"),
        "registration_method_cookie_based_title":
            MessageLookupByLibrary.simpleMessage(
                "Standard registration (cookie-based)"),
        "registration_method_device_bound_key_description":
            MessageLookupByLibrary.simpleMessage(
                "Using a device-specific cryptographic key stored only on this device"),
        "registration_method_device_bound_key_title":
            MessageLookupByLibrary.simpleMessage(
                "Secure registration (device-bound key)"),
        "remember_me": MessageLookupByLibrary.simpleMessage("Remember me"),
        "remove_file": MessageLookupByLibrary.simpleMessage("Remove File"),
        "request_location_permission":
            MessageLookupByLibrary.simpleMessage("Request Location Permission"),
        "researcher_login":
            MessageLookupByLibrary.simpleMessage("Researcher Login"),
        "resend_code": MessageLookupByLibrary.simpleMessage("Resend Code"),
        "reset_password":
            MessageLookupByLibrary.simpleMessage("Reset Password"),
        "response_details_title":
            MessageLookupByLibrary.simpleMessage("Response details"),
        "response_number": m14,
        "response_status_flagged":
            MessageLookupByLibrary.simpleMessage("Flagged"),
        "response_status_pending":
            MessageLookupByLibrary.simpleMessage("Pending"),
        "response_status_rejected":
            MessageLookupByLibrary.simpleMessage("Rejected"),
        "response_status_synced":
            MessageLookupByLibrary.simpleMessage("Synced"),
        "responses_title": MessageLookupByLibrary.simpleMessage("Responses"),
        "resume_survey": MessageLookupByLibrary.simpleMessage("Resume"),
        "retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "retry_all": MessageLookupByLibrary.simpleMessage("Retry All"),
        "retry_upload": MessageLookupByLibrary.simpleMessage("Retry Upload"),
        "scan_qr": MessageLookupByLibrary.simpleMessage("Scan QR"),
        "scan_qr_code": MessageLookupByLibrary.simpleMessage("Scan QR Code"),
        "scan_qr_code_instruction": MessageLookupByLibrary.simpleMessage(
            "Position the QR code within the frame to scan"),
        "screen_resolution":
            MessageLookupByLibrary.simpleMessage("Screen Resolution"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "sections_count": m15,
        "select_date": MessageLookupByLibrary.simpleMessage("Select Date"),
        "select_file": MessageLookupByLibrary.simpleMessage("Select File"),
        "select_language":
            MessageLookupByLibrary.simpleMessage("Select Language"),
        "send_code": MessageLookupByLibrary.simpleMessage("Send Code"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "share_link": MessageLookupByLibrary.simpleMessage("Share"),
        "share_link_subject": m16,
        "show_less": MessageLookupByLibrary.simpleMessage("Show less"),
        "show_qr_code": MessageLookupByLibrary.simpleMessage("Show QR Code"),
        "start_location_tracking":
            MessageLookupByLibrary.simpleMessage("Start Location Tracking"),
        "start_survey": MessageLookupByLibrary.simpleMessage("Start Survey"),
        "start_transfer":
            MessageLookupByLibrary.simpleMessage("Start Transfer"),
        "statistics": MessageLookupByLibrary.simpleMessage("Statistics"),
        "stop_location_tracking":
            MessageLookupByLibrary.simpleMessage("Stop Location Tracking"),
        "storage_permission_denied":
            MessageLookupByLibrary.simpleMessage("Storage permission denied"),
        "submit": MessageLookupByLibrary.simpleMessage("Submit"),
        "survey_availability":
            MessageLookupByLibrary.simpleMessage("Survey Availability"),
        "survey_code_placeholder":
            MessageLookupByLibrary.simpleMessage("e.g. ABC-123"),
        "survey_completed":
            MessageLookupByLibrary.simpleMessage("Survey Completed"),
        "survey_link": MessageLookupByLibrary.simpleMessage("Survey Link"),
        "survey_overview":
            MessageLookupByLibrary.simpleMessage("Survey Overview"),
        "surveys": MessageLookupByLibrary.simpleMessage("Surveys"),
        "sync": MessageLookupByLibrary.simpleMessage("Sync"),
        "sync_status": MessageLookupByLibrary.simpleMessage("Sync Status"),
        "synced_responses": MessageLookupByLibrary.simpleMessage("Synced"),
        "tap_to_view": MessageLookupByLibrary.simpleMessage("Tap to view"),
        "thank_you_for_response":
            MessageLookupByLibrary.simpleMessage("Thank you for your response"),
        "to": MessageLookupByLibrary.simpleMessage("To"),
        "to_user_email": MessageLookupByLibrary.simpleMessage("To User Email"),
        "total": MessageLookupByLibrary.simpleMessage("Total"),
        "total_sections_touched":
            MessageLookupByLibrary.simpleMessage("Total Sections Touched"),
        "transfer_info_message": MessageLookupByLibrary.simpleMessage(
            "Enter the email of the researcher who will receive the device. A verification code will be sent to both users."),
        "transfer_initiated_successfully": MessageLookupByLibrary.simpleMessage(
            "Transfer initiated successfully"),
        "upcoming_surveys": MessageLookupByLibrary.simpleMessage("Upcoming"),
        "upload_failed": MessageLookupByLibrary.simpleMessage("Upload failed"),
        "upload_file": MessageLookupByLibrary.simpleMessage("Upload File"),
        "upload_files": MessageLookupByLibrary.simpleMessage("Upload Files"),
        "upload_image": MessageLookupByLibrary.simpleMessage("Upload Image"),
        "upload_success":
            MessageLookupByLibrary.simpleMessage("File uploaded successfully"),
        "uploaded": MessageLookupByLibrary.simpleMessage("Uploaded"),
        "uploading": MessageLookupByLibrary.simpleMessage("Uploading..."),
        "verification_code":
            MessageLookupByLibrary.simpleMessage("Verification Code"),
        "verification_code_resent": MessageLookupByLibrary.simpleMessage(
            "Verification code resent successfully"),
        "verification_info_message": MessageLookupByLibrary.simpleMessage(
            "Enter the verification code sent to your email to complete the custody transfer."),
        "verify": MessageLookupByLibrary.simpleMessage("Verify"),
        "verify_custody":
            MessageLookupByLibrary.simpleMessage("Verify Custody"),
        "verifying_device_key":
            MessageLookupByLibrary.simpleMessage("Verifying device key..."),
        "view_completed_responses":
            MessageLookupByLibrary.simpleMessage("View Completed Responses"),
        "view_details": MessageLookupByLibrary.simpleMessage("View Details"),
        "view_survey_drafts":
            MessageLookupByLibrary.simpleMessage("View Survey Drafts"),
        "welcome": MessageLookupByLibrary.simpleMessage(
            "Welcome to the Survey Platform"),
        "welcome_back_researcher":
            MessageLookupByLibrary.simpleMessage("Welcome back, Researcher"),
        "welcome_subtitle": MessageLookupByLibrary.simpleMessage(
            "Your voice matters.. Share your feedback to contribute to continuous development and improvement"),
        "zone": MessageLookupByLibrary.simpleMessage("Zone"),
        "zone_violation_message": MessageLookupByLibrary.simpleMessage(
            "You have transitioned outside the authorized geographical perimeter. Your session will be terminated for security compliance."),
        "zone_violation_title":
            MessageLookupByLibrary.simpleMessage("Security Violation")
      };
}
