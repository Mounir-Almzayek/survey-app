// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Welcome to the Survey Platform`
  String get welcome {
    return Intl.message(
      'Welcome to the Survey Platform',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get get_started {
    return Intl.message(
      'Get Started',
      name: 'get_started',
      desc: '',
      args: [],
    );
  }

  /// `Your voice matters.. Share your feedback to contribute to continuous development and improvement`
  String get welcome_subtitle {
    return Intl.message(
      'Your voice matters.. Share your feedback to contribute to continuous development and improvement',
      name: 'welcome_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Please log in`
  String get login_message {
    return Intl.message(
      'Please log in',
      name: 'login_message',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Login successful`
  String get login_success {
    return Intl.message(
      'Login successful',
      name: 'login_success',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your email`
  String get no_user_name {
    return Intl.message(
      'Please enter your email',
      name: 'no_user_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get no_password {
    return Intl.message(
      'Please enter your password',
      name: 'no_password',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Surveys`
  String get surveys {
    return Intl.message(
      'Surveys',
      name: 'surveys',
      desc: '',
      args: [],
    );
  }

  /// `Custody`
  String get custody {
    return Intl.message(
      'Custody',
      name: 'custody',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Queued requests`
  String get queue_summary_title {
    return Intl.message(
      'Queued requests',
      name: 'queue_summary_title',
      desc: '',
      args: [],
    );
  }

  /// `Processing`
  String get queue_status_processing {
    return Intl.message(
      'Processing',
      name: 'queue_status_processing',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get queue_status_completed {
    return Intl.message(
      'Completed',
      name: 'queue_status_completed',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get queue_status_failed {
    return Intl.message(
      'Failed',
      name: 'queue_status_failed',
      desc: '',
      args: [],
    );
  }

  /// `Body`
  String get queue_detail_body {
    return Intl.message(
      'Body',
      name: 'queue_detail_body',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get queue_detail_error {
    return Intl.message(
      'Error',
      name: 'queue_detail_error',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Please select`
  String get please_select {
    return Intl.message(
      'Please select',
      name: 'please_select',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get select_date {
    return Intl.message(
      'Select Date',
      name: 'select_date',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get upload_image {
    return Intl.message(
      'Upload Image',
      name: 'upload_image',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get camera {
    return Intl.message(
      'Camera',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `Gallery`
  String get gallery {
    return Intl.message(
      'Gallery',
      name: 'gallery',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Failed to pick image, please try again later!`
  String get failed_pick_image {
    return Intl.message(
      'Failed to pick image, please try again later!',
      name: 'failed_pick_image',
      desc: '',
      args: [],
    );
  }

  /// `Storage permission denied`
  String get storage_permission_denied {
    return Intl.message(
      'Storage permission denied',
      name: 'storage_permission_denied',
      desc: '',
      args: [],
    );
  }

  /// `Image saved successfully to gallery`
  String get image_saved_successfully {
    return Intl.message(
      'Image saved successfully to gallery',
      name: 'image_saved_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Failed to save image`
  String get failed_to_save_image {
    return Intl.message(
      'Failed to save image',
      name: 'failed_to_save_image',
      desc: '',
      args: [],
    );
  }

  /// `No data`
  String get no_data {
    return Intl.message(
      'No data',
      name: 'no_data',
      desc: '',
      args: [],
    );
  }

  /// `An error occurred`
  String get error_occurred {
    return Intl.message(
      'An error occurred',
      name: 'error_occurred',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Arabic`
  String get arabic {
    return Intl.message(
      'Arabic',
      name: 'arabic',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get language_dialog_title {
    return Intl.message(
      'Select Language',
      name: 'language_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get language_dialog_cancel {
    return Intl.message(
      'Cancel',
      name: 'language_dialog_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get language_dialog_confirm {
    return Intl.message(
      'Confirm',
      name: 'language_dialog_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get select_language {
    return Intl.message(
      'Select Language',
      name: 'select_language',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Downloading...`
  String get downloading {
    return Intl.message(
      'Downloading...',
      name: 'downloading',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Download`
  String get cancel_download {
    return Intl.message(
      'Cancel Download',
      name: 'cancel_download',
      desc: '',
      args: [],
    );
  }

  /// `File downloaded to:`
  String get file_downloaded_colon {
    return Intl.message(
      'File downloaded to:',
      name: 'file_downloaded_colon',
      desc: '',
      args: [],
    );
  }

  /// `File is ready`
  String get file_ready {
    return Intl.message(
      'File is ready',
      name: 'file_ready',
      desc: '',
      args: [],
    );
  }

  /// `File downloaded successfully`
  String get file_downloaded_successfully {
    return Intl.message(
      'File downloaded successfully',
      name: 'file_downloaded_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Download File`
  String get download_file {
    return Intl.message(
      'Download File',
      name: 'download_file',
      desc: '',
      args: [],
    );
  }

  /// `Main Menu`
  String get main_menu {
    return Intl.message(
      'Main Menu',
      name: 'main_menu',
      desc: '',
      args: [],
    );
  }

  /// `Statistics`
  String get statistics {
    return Intl.message(
      'Statistics',
      name: 'statistics',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get log_out {
    return Intl.message(
      'Log Out',
      name: 'log_out',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get logout_title {
    return Intl.message(
      'Log Out',
      name: 'logout_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get logout_message {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'logout_message',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `No user data found`
  String get no_user_data {
    return Intl.message(
      'No user data found',
      name: 'no_user_data',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Company`
  String get company {
    return Intl.message(
      'Company',
      name: 'company',
      desc: '',
      args: [],
    );
  }

  /// `Position`
  String get position {
    return Intl.message(
      'Position',
      name: 'position',
      desc: '',
      args: [],
    );
  }

  /// `Entity`
  String get entity {
    return Intl.message(
      'Entity',
      name: 'entity',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get code {
    return Intl.message(
      'Code',
      name: 'code',
      desc: '',
      args: [],
    );
  }

  /// `Nationality`
  String get nationality {
    return Intl.message(
      'Nationality',
      name: 'nationality',
      desc: '',
      args: [],
    );
  }

  /// `ID Number`
  String get id_number {
    return Intl.message(
      'ID Number',
      name: 'id_number',
      desc: '',
      args: [],
    );
  }

  /// `Viewing offline data`
  String get offline_mode {
    return Intl.message(
      'Viewing offline data',
      name: 'offline_mode',
      desc: '',
      args: [],
    );
  }

  /// `Researcher Login`
  String get researcher_login {
    return Intl.message(
      'Researcher Login',
      name: 'researcher_login',
      desc: '',
      args: [],
    );
  }

  /// `Enter your login details`
  String get enter_details {
    return Intl.message(
      'Enter your login details',
      name: 'enter_details',
      desc: '',
      args: [],
    );
  }

  /// `Remember me`
  String get remember_me {
    return Intl.message(
      'Remember me',
      name: 'remember_me',
      desc: '',
      args: [],
    );
  }

  /// `Forgot your password?`
  String get forgot_password {
    return Intl.message(
      'Forgot your password?',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Login as Admin`
  String get login_as_admin {
    return Intl.message(
      'Login as Admin',
      name: 'login_as_admin',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get or {
    return Intl.message(
      'or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR Code`
  String get scan_qr_code {
    return Intl.message(
      'Scan QR Code',
      name: 'scan_qr_code',
      desc: '',
      args: [],
    );
  }

  /// `Point camera at QR code`
  String get point_camera_at_qr_code {
    return Intl.message(
      'Point camera at QR code',
      name: 'point_camera_at_qr_code',
      desc: '',
      args: [],
    );
  }

  /// `Position the QR code within the frame to scan`
  String get scan_qr_code_instruction {
    return Intl.message(
      'Position the QR code within the frame to scan',
      name: 'scan_qr_code_instruction',
      desc: '',
      args: [],
    );
  }

  /// `Invalid QR code. Please try again.`
  String get invalid_qr_code {
    return Intl.message(
      'Invalid QR code. Please try again.',
      name: 'invalid_qr_code',
      desc: '',
      args: [],
    );
  }

  /// `Processing...`
  String get processing {
    return Intl.message(
      'Processing...',
      name: 'processing',
      desc: '',
      args: [],
    );
  }

  /// `Device registered successfully`
  String get device_registered_successfully {
    return Intl.message(
      'Device registered successfully',
      name: 'device_registered_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Register Device`
  String get register_device {
    return Intl.message(
      'Register Device',
      name: 'register_device',
      desc: '',
      args: [],
    );
  }

  /// `Receive Custody`
  String get receive_custody {
    return Intl.message(
      'Receive Custody',
      name: 'receive_custody',
      desc: '',
      args: [],
    );
  }

  /// `Complete the device registration process in the system`
  String get complete_device_registration {
    return Intl.message(
      'Complete the device registration process in the system',
      name: 'complete_device_registration',
      desc: '',
      args: [],
    );
  }

  /// `Device Name`
  String get device_name {
    return Intl.message(
      'Device Name',
      name: 'device_name',
      desc: '',
      args: [],
    );
  }

  /// `Device Type`
  String get device_type {
    return Intl.message(
      'Device Type',
      name: 'device_type',
      desc: '',
      args: [],
    );
  }

  /// `Zone`
  String get zone {
    return Intl.message(
      'Zone',
      name: 'zone',
      desc: '',
      args: [],
    );
  }

  /// `Information Extracted from the Device`
  String get device_information {
    return Intl.message(
      'Information Extracted from the Device',
      name: 'device_information',
      desc: '',
      args: [],
    );
  }

  /// `Browser`
  String get browser {
    return Intl.message(
      'Browser',
      name: 'browser',
      desc: '',
      args: [],
    );
  }

  /// `Operating System`
  String get operating_system {
    return Intl.message(
      'Operating System',
      name: 'operating_system',
      desc: '',
      args: [],
    );
  }

  /// `Screen Resolution`
  String get screen_resolution {
    return Intl.message(
      'Screen Resolution',
      name: 'screen_resolution',
      desc: '',
      args: [],
    );
  }

  /// `RAM`
  String get ram {
    return Intl.message(
      'RAM',
      name: 'ram',
      desc: '',
      args: [],
    );
  }

  /// `GB`
  String get gb {
    return Intl.message(
      'GB',
      name: 'gb',
      desc: '',
      args: [],
    );
  }

  /// `Processor Cores`
  String get processor_cores {
    return Intl.message(
      'Processor Cores',
      name: 'processor_cores',
      desc: '',
      args: [],
    );
  }

  /// `Maximum Touch Points`
  String get max_touch_points {
    return Intl.message(
      'Maximum Touch Points',
      name: 'max_touch_points',
      desc: '',
      args: [],
    );
  }

  /// `Not Available`
  String get not_available {
    return Intl.message(
      'Not Available',
      name: 'not_available',
      desc: '',
      args: [],
    );
  }

  /// `Cookie-based method will be used for device registration`
  String get cookie_based_method_description {
    return Intl.message(
      'Cookie-based method will be used for device registration',
      name: 'cookie_based_method_description',
      desc: '',
      args: [],
    );
  }

  /// `Secure registration (device-bound key)`
  String get registration_method_device_bound_key_title {
    return Intl.message(
      'Secure registration (device-bound key)',
      name: 'registration_method_device_bound_key_title',
      desc: '',
      args: [],
    );
  }

  /// `Using a device-specific cryptographic key stored only on this device`
  String get registration_method_device_bound_key_description {
    return Intl.message(
      'Using a device-specific cryptographic key stored only on this device',
      name: 'registration_method_device_bound_key_description',
      desc: '',
      args: [],
    );
  }

  /// `Standard registration (cookie-based)`
  String get registration_method_cookie_based_title {
    return Intl.message(
      'Standard registration (cookie-based)',
      name: 'registration_method_cookie_based_title',
      desc: '',
      args: [],
    );
  }

  /// `Using a secure cookie stored in the app's secure storage for this device`
  String get registration_method_cookie_based_description {
    return Intl.message(
      'Using a secure cookie stored in the app\'s secure storage for this device',
      name: 'registration_method_cookie_based_description',
      desc: '',
      args: [],
    );
  }

  /// `Link Device`
  String get link_device {
    return Intl.message(
      'Link Device',
      name: 'link_device',
      desc: '',
      args: [],
    );
  }

  /// `QR Scanner`
  String get qr_scanner {
    return Intl.message(
      'QR Scanner',
      name: 'qr_scanner',
      desc: '',
      args: [],
    );
  }

  /// `Camera permission is required to scan QR codes`
  String get camera_permission_required {
    return Intl.message(
      'Camera permission is required to scan QR codes',
      name: 'camera_permission_required',
      desc: '',
      args: [],
    );
  }

  /// `Grant Permission`
  String get grant_permission {
    return Intl.message(
      'Grant Permission',
      name: 'grant_permission',
      desc: '',
      args: [],
    );
  }

  /// `Place the QR code within the frame to scan`
  String get place_qr_code {
    return Intl.message(
      'Place the QR code within the frame to scan',
      name: 'place_qr_code',
      desc: '',
      args: [],
    );
  }

  /// `Select File`
  String get select_file {
    return Intl.message(
      'Select File',
      name: 'select_file',
      desc: '',
      args: [],
    );
  }

  /// `Upload File`
  String get upload_file {
    return Intl.message(
      'Upload File',
      name: 'upload_file',
      desc: '',
      args: [],
    );
  }

  /// `Upload Files`
  String get upload_files {
    return Intl.message(
      'Upload Files',
      name: 'upload_files',
      desc: '',
      args: [],
    );
  }

  /// `Uploading...`
  String get uploading {
    return Intl.message(
      'Uploading...',
      name: 'uploading',
      desc: '',
      args: [],
    );
  }

  /// `Uploaded`
  String get uploaded {
    return Intl.message(
      'Uploaded',
      name: 'uploaded',
      desc: '',
      args: [],
    );
  }

  /// `Upload failed`
  String get upload_failed {
    return Intl.message(
      'Upload failed',
      name: 'upload_failed',
      desc: '',
      args: [],
    );
  }

  /// `File uploaded successfully`
  String get upload_success {
    return Intl.message(
      'File uploaded successfully',
      name: 'upload_success',
      desc: '',
      args: [],
    );
  }

  /// `File selected`
  String get file_selected {
    return Intl.message(
      'File selected',
      name: 'file_selected',
      desc: '',
      args: [],
    );
  }

  /// `Remove File`
  String get remove_file {
    return Intl.message(
      'Remove File',
      name: 'remove_file',
      desc: '',
      args: [],
    );
  }

  /// `Retry Upload`
  String get retry_upload {
    return Intl.message(
      'Retry Upload',
      name: 'retry_upload',
      desc: '',
      args: [],
    );
  }

  /// `Cancel Upload`
  String get cancel_upload {
    return Intl.message(
      'Cancel Upload',
      name: 'cancel_upload',
      desc: '',
      args: [],
    );
  }

  /// `Location permission denied`
  String get location_permission_denied {
    return Intl.message(
      'Location permission denied',
      name: 'location_permission_denied',
      desc: '',
      args: [],
    );
  }

  /// `Location tracking started`
  String get location_tracking_started {
    return Intl.message(
      'Location tracking started',
      name: 'location_tracking_started',
      desc: '',
      args: [],
    );
  }

  /// `Location tracking stopped`
  String get location_tracking_stopped {
    return Intl.message(
      'Location tracking stopped',
      name: 'location_tracking_stopped',
      desc: '',
      args: [],
    );
  }

  /// `Location updated`
  String get location_updated {
    return Intl.message(
      'Location updated',
      name: 'location_updated',
      desc: '',
      args: [],
    );
  }

  /// `Location update failed`
  String get location_update_failed {
    return Intl.message(
      'Location update failed',
      name: 'location_update_failed',
      desc: '',
      args: [],
    );
  }

  /// `Warning: You are outside the allowed zone. Logging out...`
  String get location_warning_logout {
    return Intl.message(
      'Warning: You are outside the allowed zone. Logging out...',
      name: 'location_warning_logout',
      desc: '',
      args: [],
    );
  }

  /// `Request Location Permission`
  String get request_location_permission {
    return Intl.message(
      'Request Location Permission',
      name: 'request_location_permission',
      desc: '',
      args: [],
    );
  }

  /// `Start Location Tracking`
  String get start_location_tracking {
    return Intl.message(
      'Start Location Tracking',
      name: 'start_location_tracking',
      desc: '',
      args: [],
    );
  }

  /// `Stop Location Tracking`
  String get stop_location_tracking {
    return Intl.message(
      'Stop Location Tracking',
      name: 'stop_location_tracking',
      desc: '',
      args: [],
    );
  }

  /// `Public Links`
  String get public_links {
    return Intl.message(
      'Public Links',
      name: 'public_links',
      desc: '',
      args: [],
    );
  }

  /// `No Public Links`
  String get no_public_links {
    return Intl.message(
      'No Public Links',
      name: 'no_public_links',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any public links assigned yet`
  String get no_public_links_description {
    return Intl.message(
      'You don\'t have any public links assigned yet',
      name: 'no_public_links_description',
      desc: '',
      args: [],
    );
  }

  /// `Copy Link`
  String get copy_link {
    return Intl.message(
      'Copy Link',
      name: 'copy_link',
      desc: '',
      args: [],
    );
  }

  /// `Link copied to clipboard`
  String get link_copied {
    return Intl.message(
      'Link copied to clipboard',
      name: 'link_copied',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share_link {
    return Intl.message(
      'Share',
      name: 'share_link',
      desc: '',
      args: [],
    );
  }

  /// `Survey Link: {title}`
  String share_link_subject(String title) {
    return Intl.message(
      'Survey Link: $title',
      name: 'share_link_subject',
      desc: '',
      args: [title],
    );
  }

  /// `Show QR Code`
  String get show_qr_code {
    return Intl.message(
      'Show QR Code',
      name: 'show_qr_code',
      desc: '',
      args: [],
    );
  }

  /// `QR Code`
  String get qr_code {
    return Intl.message(
      'QR Code',
      name: 'qr_code',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Location Required`
  String get location_required {
    return Intl.message(
      'Location Required',
      name: 'location_required',
      desc: '',
      args: [],
    );
  }

  /// `Verify Custody`
  String get verify_custody {
    return Intl.message(
      'Verify Custody',
      name: 'verify_custody',
      desc: '',
      args: [],
    );
  }

  /// `To User Email`
  String get to_user_email {
    return Intl.message(
      'To User Email',
      name: 'to_user_email',
      desc: '',
      args: [],
    );
  }

  /// `Enter email address`
  String get enter_email {
    return Intl.message(
      'Enter email address',
      name: 'enter_email',
      desc: '',
      args: [],
    );
  }

  /// `Please enter email address`
  String get please_enter_email {
    return Intl.message(
      'Please enter email address',
      name: 'please_enter_email',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get invalid_email {
    return Intl.message(
      'Invalid email address',
      name: 'invalid_email',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message(
      'Notes',
      name: 'notes',
      desc: '',
      args: [],
    );
  }

  /// `Enter notes (optional)`
  String get enter_notes_optional {
    return Intl.message(
      'Enter notes (optional)',
      name: 'enter_notes_optional',
      desc: '',
      args: [],
    );
  }

  /// `Start Transfer`
  String get start_transfer {
    return Intl.message(
      'Start Transfer',
      name: 'start_transfer',
      desc: '',
      args: [],
    );
  }

  /// `No Custody Records`
  String get no_custody_records {
    return Intl.message(
      'No Custody Records',
      name: 'no_custody_records',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any custody records yet`
  String get no_custody_records_description {
    return Intl.message(
      'You don\'t have any custody records yet',
      name: 'no_custody_records_description',
      desc: '',
      args: [],
    );
  }

  /// `Transfer initiated successfully`
  String get transfer_initiated_successfully {
    return Intl.message(
      'Transfer initiated successfully',
      name: 'transfer_initiated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Enter the email of the researcher who will receive the device. A verification code will be sent to both users.`
  String get transfer_info_message {
    return Intl.message(
      'Enter the email of the researcher who will receive the device. A verification code will be sent to both users.',
      name: 'transfer_info_message',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the 6-digit verification code`
  String get please_enter_verification_code {
    return Intl.message(
      'Please enter the 6-digit verification code',
      name: 'please_enter_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Custody verified successfully`
  String get custody_verified_successfully {
    return Intl.message(
      'Custody verified successfully',
      name: 'custody_verified_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Verification code resent successfully`
  String get verification_code_resent {
    return Intl.message(
      'Verification code resent successfully',
      name: 'verification_code_resent',
      desc: '',
      args: [],
    );
  }

  /// `Enter the verification code sent to your email to complete the custody transfer.`
  String get verification_info_message {
    return Intl.message(
      'Enter the verification code sent to your email to complete the custody transfer.',
      name: 'verification_info_message',
      desc: '',
      args: [],
    );
  }

  /// `Enter Verification Code`
  String get enter_verification_code {
    return Intl.message(
      'Enter Verification Code',
      name: 'enter_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Verify`
  String get verify {
    return Intl.message(
      'Verify',
      name: 'verify',
      desc: '',
      args: [],
    );
  }

  /// `Resend Code`
  String get resend_code {
    return Intl.message(
      'Resend Code',
      name: 'resend_code',
      desc: '',
      args: [],
    );
  }

  /// `{count} Active Links`
  String active_links_count(int count) {
    return Intl.message(
      '$count Active Links',
      name: 'active_links_count',
      desc: '',
      args: [count],
    );
  }

  /// `Tap to view`
  String get tap_to_view {
    return Intl.message(
      'Tap to view',
      name: 'tap_to_view',
      desc: '',
      args: [],
    );
  }

  /// `Sync`
  String get sync {
    return Intl.message(
      'Sync',
      name: 'sync',
      desc: '',
      args: [],
    );
  }

  /// `Public link not found`
  String get public_link_not_found {
    return Intl.message(
      'Public link not found',
      name: 'public_link_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Code: {code}`
  String code_colon(String code) {
    return Intl.message(
      'Code: $code',
      name: 'code_colon',
      desc: '',
      args: [code],
    );
  }

  /// `Created: {date}`
  String created_at_colon(String date) {
    return Intl.message(
      'Created: $date',
      name: 'created_at_colon',
      desc: '',
      args: [date],
    );
  }

  /// `{count} Sections`
  String sections_count(int count) {
    return Intl.message(
      '$count Sections',
      name: 'sections_count',
      desc: '',
      args: [count],
    );
  }

  /// `{count} Questions`
  String questions_count(int count) {
    return Intl.message(
      '$count Questions',
      name: 'questions_count',
      desc: '',
      args: [count],
    );
  }

  /// `+{count} Mins`
  String minutes_count(int count) {
    return Intl.message(
      '+$count Mins',
      name: 'minutes_count',
      desc: '',
      args: [count],
    );
  }

  /// `View Details`
  String get view_details {
    return Intl.message(
      'View Details',
      name: 'view_details',
      desc: '',
      args: [],
    );
  }

  /// `Survey Link`
  String get survey_link {
    return Intl.message(
      'Survey Link',
      name: 'survey_link',
      desc: '',
      args: [],
    );
  }

  /// `Max Responses`
  String get max_responses {
    return Intl.message(
      'Max Responses',
      name: 'max_responses',
      desc: '',
      args: [],
    );
  }

  /// `Expires At`
  String get expires_at {
    return Intl.message(
      'Expires At',
      name: 'expires_at',
      desc: '',
      args: [],
    );
  }

  /// `Enter Survey Code`
  String get enter_survey_code {
    return Intl.message(
      'Enter Survey Code',
      name: 'enter_survey_code',
      desc: '',
      args: [],
    );
  }

  /// `e.g. ABC-123`
  String get survey_code_placeholder {
    return Intl.message(
      'e.g. ABC-123',
      name: 'survey_code_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `Scan QR`
  String get scan_qr {
    return Intl.message(
      'Scan QR',
      name: 'scan_qr',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Active Responses`
  String get active_responses {
    return Intl.message(
      'Active Responses',
      name: 'active_responses',
      desc: '',
      args: [],
    );
  }

  /// `In-Progress Surveys`
  String get in_progress_surveys {
    return Intl.message(
      'In-Progress Surveys',
      name: 'in_progress_surveys',
      desc: '',
      args: [],
    );
  }

  /// `Total Sections Touched`
  String get total_sections_touched {
    return Intl.message(
      'Total Sections Touched',
      name: 'total_sections_touched',
      desc: '',
      args: [],
    );
  }

  /// `Avg.`
  String get avg {
    return Intl.message(
      'Avg.',
      name: 'avg',
      desc: '',
      args: [],
    );
  }

  /// `{count} Drafts Available`
  String drafts_available(int count) {
    return Intl.message(
      '$count Drafts Available',
      name: 'drafts_available',
      desc: '',
      args: [count],
    );
  }

  /// `Resume`
  String get resume_survey {
    return Intl.message(
      'Resume',
      name: 'resume_survey',
      desc: '',
      args: [],
    );
  }

  /// `No active responses found`
  String get no_active_responses {
    return Intl.message(
      'No active responses found',
      name: 'no_active_responses',
      desc: '',
      args: [],
    );
  }

  /// `Delete Draft`
  String get delete_draft_title {
    return Intl.message(
      'Delete Draft',
      name: 'delete_draft_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this survey draft?`
  String get delete_draft_message {
    return Intl.message(
      'Are you sure you want to delete this survey draft?',
      name: 'delete_draft_message',
      desc: '',
      args: [],
    );
  }

  /// `Hide Details`
  String get hide_details {
    return Intl.message(
      'Hide Details',
      name: 'hide_details',
      desc: '',
      args: [],
    );
  }

  /// `View Survey Drafts`
  String get view_survey_drafts {
    return Intl.message(
      'View Survey Drafts',
      name: 'view_survey_drafts',
      desc: '',
      args: [],
    );
  }

  /// `Last updated: {date}`
  String last_updated_at(String date) {
    return Intl.message(
      'Last updated: $date',
      name: 'last_updated_at',
      desc: '',
      args: [date],
    );
  }

  /// `Welcome back, Researcher`
  String get welcome_back_researcher {
    return Intl.message(
      'Welcome back, Researcher',
      name: 'welcome_back_researcher',
      desc: '',
      args: [],
    );
  }

  /// `Here is what's happening with your surveys today.`
  String get home_survey_status_subtitle {
    return Intl.message(
      'Here is what\'s happening with your surveys today.',
      name: 'home_survey_status_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `Location permission required`
  String get location_permission_required_title {
    return Intl.message(
      'Location permission required',
      name: 'location_permission_required_title',
      desc: '',
      args: [],
    );
  }

  /// `To use this app, you must allow access to your device location.`
  String get location_permission_required_message {
    return Intl.message(
      'To use this app, you must allow access to your device location.',
      name: 'location_permission_required_message',
      desc: '',
      args: [],
    );
  }

  /// `Allow location access`
  String get allow_location_access {
    return Intl.message(
      'Allow location access',
      name: 'allow_location_access',
      desc: '',
      args: [],
    );
  }

  /// `Responses`
  String get responses_title {
    return Intl.message(
      'Responses',
      name: 'responses_title',
      desc: '',
      args: [],
    );
  }

  /// `Response details`
  String get response_details_title {
    return Intl.message(
      'Response details',
      name: 'response_details_title',
      desc: '',
      args: [],
    );
  }

  /// `No responses found`
  String get no_responses_found {
    return Intl.message(
      'No responses found',
      name: 'no_responses_found',
      desc: '',
      args: [],
    );
  }

  /// `Synced`
  String get response_status_synced {
    return Intl.message(
      'Synced',
      name: 'response_status_synced',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get response_status_pending {
    return Intl.message(
      'Pending',
      name: 'response_status_pending',
      desc: '',
      args: [],
    );
  }

  /// `Flagged`
  String get response_status_flagged {
    return Intl.message(
      'Flagged',
      name: 'response_status_flagged',
      desc: '',
      args: [],
    );
  }

  /// `Rejected`
  String get response_status_rejected {
    return Intl.message(
      'Rejected',
      name: 'response_status_rejected',
      desc: '',
      args: [],
    );
  }

  /// `This device is already registered`
  String get device_already_registered {
    return Intl.message(
      'This device is already registered',
      name: 'device_already_registered',
      desc: '',
      args: [],
    );
  }

  /// `Verifying device key...`
  String get verifying_device_key {
    return Intl.message(
      'Verifying device key...',
      name: 'verifying_device_key',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an active account?`
  String get no_active_account {
    return Intl.message(
      'Don\'t have an active account?',
      name: 'no_active_account',
      desc: '',
      args: [],
    );
  }

  /// `Activate`
  String get activate {
    return Intl.message(
      'Activate',
      name: 'activate',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get reset_password {
    return Intl.message(
      'Reset Password',
      name: 'reset_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter Code`
  String get enter_code {
    return Intl.message(
      'Enter Code',
      name: 'enter_code',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email to receive a reset code`
  String get enter_email_reset {
    return Intl.message(
      'Enter your email to receive a reset code',
      name: 'enter_email_reset',
      desc: '',
      args: [],
    );
  }

  /// `Enter the code sent to {email}`
  String enter_code_sent(String email) {
    return Intl.message(
      'Enter the code sent to $email',
      name: 'enter_code_sent',
      desc: '',
      args: [email],
    );
  }

  /// `Verification Code`
  String get verification_code {
    return Intl.message(
      'Verification Code',
      name: 'verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Please enter code`
  String get please_enter_code {
    return Intl.message(
      'Please enter code',
      name: 'please_enter_code',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get new_password {
    return Intl.message(
      'New Password',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `Password too short`
  String get password_too_short {
    return Intl.message(
      'Password too short',
      name: 'password_too_short',
      desc: '',
      args: [],
    );
  }

  /// `Send Code`
  String get send_code {
    return Intl.message(
      'Send Code',
      name: 'send_code',
      desc: '',
      args: [],
    );
  }

  /// `Password reset successful`
  String get password_reset_success {
    return Intl.message(
      'Password reset successful',
      name: 'password_reset_success',
      desc: '',
      args: [],
    );
  }

  /// `Activate Account`
  String get activate_account {
    return Intl.message(
      'Activate Account',
      name: 'activate_account',
      desc: '',
      args: [],
    );
  }

  /// `Enter the verification code sent to your email`
  String get enter_verification_code_instruction {
    return Intl.message(
      'Enter the verification code sent to your email',
      name: 'enter_verification_code_instruction',
      desc: '',
      args: [],
    );
  }

  /// `Email verified successfully`
  String get email_verified_success {
    return Intl.message(
      'Email verified successfully',
      name: 'email_verified_success',
      desc: '',
      args: [],
    );
  }

  /// `Device successfully linked to your account`
  String get device_registered_success {
    return Intl.message(
      'Device successfully linked to your account',
      name: 'device_registered_success',
      desc: '',
      args: [],
    );
  }

  /// `By tapping 'Link Device', this device will be unique to your researcher profile.`
  String get complete_registration_tap_notice {
    return Intl.message(
      'By tapping \'Link Device\', this device will be unique to your researcher profile.',
      name: 'complete_registration_tap_notice',
      desc: '',
      args: [],
    );
  }

  /// `This device ID is already associated with another profile or has been previously linked.`
  String get device_already_registered_desc {
    return Intl.message(
      'This device ID is already associated with another profile or has been previously linked.',
      name: 'device_already_registered_desc',
      desc: '',
      args: [],
    );
  }

  /// `Security Violation`
  String get zone_violation_title {
    return Intl.message(
      'Security Violation',
      name: 'zone_violation_title',
      desc: '',
      args: [],
    );
  }

  /// `You have transitioned outside the authorized geographical perimeter. Your session will be terminated for security compliance.`
  String get zone_violation_message {
    return Intl.message(
      'You have transitioned outside the authorized geographical perimeter. Your session will be terminated for security compliance.',
      name: 'zone_violation_message',
      desc: '',
      args: [],
    );
  }

  /// `Available Surveys`
  String get available_surveys {
    return Intl.message(
      'Available Surveys',
      name: 'available_surveys',
      desc: '',
      args: [],
    );
  }

  /// `No surveys available at the moment`
  String get no_surveys_available {
    return Intl.message(
      'No surveys available at the moment',
      name: 'no_surveys_available',
      desc: '',
      args: [],
    );
  }

  /// `New response started successfully`
  String get new_response_success {
    return Intl.message(
      'New response started successfully',
      name: 'new_response_success',
      desc: '',
      args: [],
    );
  }

  /// `Error: {message}`
  String error_with_message(String message) {
    return Intl.message(
      'Error: $message',
      name: 'error_with_message',
      desc: '',
      args: [message],
    );
  }

  /// `Local Responses ({count})`
  String local_responses_count(int count) {
    return Intl.message(
      'Local Responses ($count)',
      name: 'local_responses_count',
      desc: '',
      args: [count],
    );
  }

  /// `New Response`
  String get new_response {
    return Intl.message(
      'New Response',
      name: 'new_response',
      desc: '',
      args: [],
    );
  }

  /// `Response ID: {id}`
  String response_number(int id) {
    return Intl.message(
      'Response ID: $id',
      name: 'response_number',
      desc: '',
      args: [id],
    );
  }

  /// `Delete Confirmation`
  String get confirm_delete_title {
    return Intl.message(
      'Delete Confirmation',
      name: 'confirm_delete_title',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete this response (ID: {id})? This action cannot be undone.`
  String confirm_delete_message(int id) {
    return Intl.message(
      'Are you sure you want to delete this response (ID: $id)? This action cannot be undone.',
      name: 'confirm_delete_message',
      desc: '',
      args: [id],
    );
  }

  /// `Pending`
  String get custody_status_pending {
    return Intl.message(
      'Pending',
      name: 'custody_status_pending',
      desc: '',
      args: [],
    );
  }

  /// `Verified`
  String get custody_status_verified {
    return Intl.message(
      'Verified',
      name: 'custody_status_verified',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get custody_status_cancelled {
    return Intl.message(
      'Cancelled',
      name: 'custody_status_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Read more`
  String get read_more {
    return Intl.message(
      'Read more',
      name: 'read_more',
      desc: '',
      args: [],
    );
  }

  /// `Show less`
  String get show_less {
    return Intl.message(
      'Show less',
      name: 'show_less',
      desc: '',
      args: [],
    );
  }

  /// `Availability: {start} / {end}`
  String availability_period(String start, String end) {
    return Intl.message(
      'Availability: $start / $end',
      name: 'availability_period',
      desc: '',
      args: [start, end],
    );
  }

  /// `Publish Date: {date}`
  String publish_date(String date) {
    return Intl.message(
      'Publish Date: $date',
      name: 'publish_date',
      desc: '',
      args: [date],
    );
  }

  /// `Last Update: {date}`
  String last_update(String date) {
    return Intl.message(
      'Last Update: $date',
      name: 'last_update',
      desc: '',
      args: [date],
    );
  }

  /// `Survey Overview`
  String get survey_overview {
    return Intl.message(
      'Survey Overview',
      name: 'survey_overview',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message(
      'Total',
      name: 'total',
      desc: '',
      args: [],
    );
  }

  /// `Assignments`
  String get assignments {
    return Intl.message(
      'Assignments',
      name: 'assignments',
      desc: '',
      args: [],
    );
  }

  /// `Offline Drafts`
  String get offline_drafts {
    return Intl.message(
      'Offline Drafts',
      name: 'offline_drafts',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: '',
      args: [],
    );
  }

  /// `Completion Rate`
  String get completion_rate {
    return Intl.message(
      'Completion Rate',
      name: 'completion_rate',
      desc: '',
      args: [],
    );
  }

  /// `Active Tasks`
  String get active_tasks {
    return Intl.message(
      'Active Tasks',
      name: 'active_tasks',
      desc: '',
      args: [],
    );
  }

  /// `Start Survey`
  String get start_survey {
    return Intl.message(
      'Start Survey',
      name: 'start_survey',
      desc: '',
      args: [],
    );
  }

  /// `Survey Completed`
  String get survey_completed {
    return Intl.message(
      'Survey Completed',
      name: 'survey_completed',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for your response`
  String get thank_you_for_response {
    return Intl.message(
      'Thank you for your response',
      name: 'thank_you_for_response',
      desc: '',
      args: [],
    );
  }

  /// `Back to Assignments`
  String get back_to_assignments {
    return Intl.message(
      'Back to Assignments',
      name: 'back_to_assignments',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get previous {
    return Intl.message(
      'Previous',
      name: 'previous',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `This field is required`
  String get field_required {
    return Intl.message(
      'This field is required',
      name: 'field_required',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active_surveys {
    return Intl.message(
      'Active',
      name: 'active_surveys',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get expired_surveys {
    return Intl.message(
      'Expired',
      name: 'expired_surveys',
      desc: '',
      args: [],
    );
  }

  /// `Upcoming`
  String get upcoming_surveys {
    return Intl.message(
      'Upcoming',
      name: 'upcoming_surveys',
      desc: '',
      args: [],
    );
  }

  /// `Drafts`
  String get draft_responses {
    return Intl.message(
      'Drafts',
      name: 'draft_responses',
      desc: '',
      args: [],
    );
  }

  /// `Pending Sync`
  String get pending_sync {
    return Intl.message(
      'Pending Sync',
      name: 'pending_sync',
      desc: '',
      args: [],
    );
  }

  /// `Synced`
  String get synced_responses {
    return Intl.message(
      'Synced',
      name: 'synced_responses',
      desc: '',
      args: [],
    );
  }

  /// `Survey Availability`
  String get survey_availability {
    return Intl.message(
      'Survey Availability',
      name: 'survey_availability',
      desc: '',
      args: [],
    );
  }

  /// `Sync Status`
  String get sync_status {
    return Intl.message(
      'Sync Status',
      name: 'sync_status',
      desc: '',
      args: [],
    );
  }

  /// `Retry All`
  String get retry_all {
    return Intl.message(
      'Retry All',
      name: 'retry_all',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get clear_all {
    return Intl.message(
      'Clear All',
      name: 'clear_all',
      desc: '',
      args: [],
    );
  }

  /// `View Completed Responses`
  String get view_completed_responses {
    return Intl.message(
      'View Completed Responses',
      name: 'view_completed_responses',
      desc: '',
      args: [],
    );
  }

  /// `To`
  String get to {
    return Intl.message(
      'To',
      name: 'to',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message(
      'From',
      name: 'from',
      desc: '',
      args: [],
    );
  }

  /// `Respondent Demographics`
  String get demographics_title {
    return Intl.message(
      'Respondent Demographics',
      name: 'demographics_title',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get gender_male {
    return Intl.message(
      'Male',
      name: 'gender_male',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get gender_female {
    return Intl.message(
      'Female',
      name: 'gender_female',
      desc: '',
      args: [],
    );
  }

  /// `Supervisor`
  String get supervisor {
    return Intl.message(
      'Supervisor',
      name: 'supervisor',
      desc: '',
      args: [],
    );
  }

  /// `No supervisor assigned`
  String get noSupervisorAssigned {
    return Intl.message(
      'No supervisor assigned',
      name: 'noSupervisorAssigned',
      desc: '',
      args: [],
    );
  }

  /// `No assignments available`
  String get noAssignments {
    return Intl.message(
      'No assignments available',
      name: 'noAssignments',
      desc: '',
      args: [],
    );
  }

  /// `Bounded Device`
  String get boundedDevice {
    return Intl.message(
      'Bounded Device',
      name: 'boundedDevice',
      desc: '',
      args: [],
    );
  }

  /// `Unbounded Device`
  String get unboundedDevice {
    return Intl.message(
      'Unbounded Device',
      name: 'unboundedDevice',
      desc: '',
      args: [],
    );
  }

  /// `Progress`
  String get progress {
    return Intl.message(
      'Progress',
      name: 'progress',
      desc: '',
      args: [],
    );
  }

  /// `Age Group`
  String get age_group {
    return Intl.message(
      'Age Group',
      name: 'age_group',
      desc: '',
      args: [],
    );
  }

  /// `Select Gender`
  String get select_gender {
    return Intl.message(
      'Select Gender',
      name: 'select_gender',
      desc: '',
      args: [],
    );
  }

  /// `Select Age Group`
  String get select_age_group {
    return Intl.message(
      'Select Age Group',
      name: 'select_age_group',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
