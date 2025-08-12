class ValidationUtils {
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }
  
  static bool isValidPassword(String password) {
    // At least 8 characters, one uppercase, one lowercase, one number
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }
  
  static bool isValidUsername(String username) {
    // 3-20 characters, alphanumeric and underscores only
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,20}$');
    return usernameRegex.hasMatch(username);
  }
  
  static bool isValidName(String name) {
    // At least 2 characters, letters and spaces only
    final nameRegex = RegExp(r'^[a-zA-Z\s]{2,}$');
    return nameRegex.hasMatch(name);
  }
  
  static bool isValidPhone(String phone) {
    // Basic phone validation (10-15 digits)
    final phoneRegex = RegExp(r'^\d{10,15}$');
    return phoneRegex.hasMatch(phone);
  }
  
  static bool isValidChallengeTitle(String title) {
    // 3-50 characters
    return title.length >= 3 && title.length <= 50;
  }
  
  static bool isValidChallengeDescription(String description) {
    // 10-200 characters
    return description.length >= 10 && description.length <= 200;
  }
  
  static bool isValidJournalEntry(String entry) {
    // At least 10 characters
    return entry.length >= 10;
  }
  
  static bool isValidGoalTitle(String title) {
    // 3-50 characters
    return title.length >= 3 && title.length <= 50;
  }
  
  static bool isValidGoalReason(String reason) {
    // 5-100 characters
    return reason.length >= 5 && reason.length <= 100;
  }
  
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }
  
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(password)) {
      return 'Password must be at least 8 characters with uppercase, lowercase, and number';
    }
    return null;
  }
  
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required';
    }
    if (!isValidUsername(username)) {
      return 'Username must be 3-20 characters (alphanumeric and underscores only)';
    }
    return null;
  }
  
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    if (!isValidName(name)) {
      return 'Please enter a valid name';
    }
    return null;
  }
}