class Constants {
  // TAGS
  static const MAIN_TAG = 'Main';
  static const HOME_SCREEN_TAG = 'HomeScreen';
  static const HOME_VIEW_MODEL_TAG = 'HomeViewModel';
  static const EDIT_TASK_SCREEN_TAG = 'EditTaskScreen';
  static const EDIT_TASK_VIEW_MODEL_TAG = 'EditTaskViewModel';
  static const LOGIN_SCREEN_TAG = 'LoginScreen';
  static const LOGIN_VIEW_MODEL_TAG = 'LoginViewModel';
  static const PROFILE_SCREEN_TAG = 'ProfileScreen';
  static const PROFILE_VIEW_MODEL_TAG = 'ProfileViewModel';
  static const SIGN_IN_SCREEN_TAG = 'SignInScreen';
  static const SIGN_IN_VIEW_MODEL_TAG = 'SignInViewModel';
  static const SIGN_UP_SCREEN_TAG = 'SignUpScreen';
  static const SIGN_UP_VIEW_MODEL_TAG = 'SignUpViewModel';
  static const ATTACHMENT_SCREEN_TAG = 'AttachmentScreen';

  static const USERNAME_PROFILE_PIC_WIDGET_TAG = 'UserNameProfilePicWidget';
  static const TASK_WIDGET_TAG = 'TaskWidget';

  static const DB_HELPER_TAG = 'DbHelper';
  static const AUTH_PROVIDER_TAG = 'AuthProvider';
  static const CONNECTION_PROVIDER_TAG = 'ConnectionProvider';
  static const APP_CHECK_PROVIDER_TAG = 'AppCheckProvider';

  // SERVICES NAME AND ID
  static const SYNC_SERVICE_NOTIFICATION_ID = 1001;
  static const GET_DATA_SYNC_MANAGER = 'GET_DATA_SYNC_MANAGER';
  static const NOTIFICATION_SERVICE = 'NOTIFICATION_SERVICE';
  static const FETCH_DATA_SERVICE = 'FETCH_DATA_SERVICE';
}

class ImageStorage {
  static const BASE_URL = 'que';
}

enum HomeScreenEnums {
  LOGOUT,
  DELETE,
}

extension HomeScreenEnumsExtension on HomeScreenEnums {
  int get value {
    switch (this) {
      case HomeScreenEnums.LOGOUT:
        return 0;
      case HomeScreenEnums.DELETE:
        return 1;
    }
  }
}

enum PriorityEnum {
  Blocker,
  Highest,
  High,
  Medium,
  Normal,
  Latest,
  Oldest,
}

enum TaskStatusEnum {
  Start,
  In_Progress,
  On_Hold,
  Complete,
}

enum TaskTimeUnitEnum {
  Hours,
  Days,
  Weeks,
}

enum NotificationIdEnum {
  VERIFY_EMAIL,
}

enum QueUserFields {
  queUserId,
  email,
  displayName,
  mobileNo,
  photoUrl,
  company,
  role
}

enum TaskFields {
  taskId,
  title,
  description,
  timeUnit,
  timeValue,
  assignee,
  assignedTo,
  createdOn,
  priority,
  status,
  company,
  isNotified,
}