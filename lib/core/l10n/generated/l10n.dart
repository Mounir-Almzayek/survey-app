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
