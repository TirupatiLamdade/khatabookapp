enum AppLanguage { en, hi, mr }

class AppStrings {
  static const Map<AppLanguage, Map<String, String>> _localizedValues = {
    AppLanguage.en: {
      'welcome_title': 'Khatabook Smart',
      'welcome_subtitle': 'Secure Enterprise Ledger Book',
      'get_started': 'Get Started',
      'login_title': 'Secure Access Framework',
      'email_gate': 'Email Gate',
      'phone_otp': 'Phone OTP',
      'email_label': 'Registered Business Email',
      'password_label': 'Password',
      'phone_label': 'Mobile Number',
      'otp_label': 'Enter 6-Digit OTP',
      'btn_login': 'Verified Sign In',
      'btn_send_otp': 'Generate Mobile OTP',
      'btn_google': 'Synchronize via Google Account',
      'dashboard': 'Khatabook Smart Dashboard',
    },
    AppLanguage.hi: {
      'welcome_title': 'Khatabook Smart',
      'welcome_subtitle': 'Secure Enterprise Ledger Book',
      'get_started': 'Get Started',
      'login_title': 'Secure Access Framework',
      'email_gate': 'Email Gate',
      'phone_otp': 'Phone OTP',
      'email_label': 'Registered Business Email',
      'password_label': 'Password',
      'phone_label': 'Mobile Number',
      'otp_label': 'Enter 6-Digit OTP',
      'btn_login': 'Verified Sign In',
      'btn_send_otp': 'Generate Mobile OTP',
      'btn_google': 'Synchronize via Google Account',
      'dashboard': 'Khatabook Smart Dashboard',
    },
    AppLanguage.mr: {
      'welcome_title': 'Khatabook Smart',
      'welcome_subtitle': 'Secure Enterprise Ledger Book',
      'get_started': 'Get Started',
      'login_title': 'Secure Access Framework',
      'email_gate': 'Email Gate',
      'phone_otp': 'Phone OTP',
      'email_label': 'Registered Business Email',
      'password_label': 'Password',
      'phone_label': 'Mobile Number',
      'otp_label': 'Enter 6-Digit OTP',
      'btn_login': 'Verified Sign In',
      'btn_send_otp': 'Generate Mobile OTP',
      'btn_google': 'Synchronize via Google Account',
      'dashboard': 'Khatabook Smart Dashboard',
    }
  };

  static String getString(AppLanguage lang, String key) {
    return _localizedValues[lang]?[key] ?? _localizedValues[AppLanguage.en]![key]!;
  }
}