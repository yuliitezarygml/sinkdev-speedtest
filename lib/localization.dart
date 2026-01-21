class AppStrings {
  static const String appName = 'Speed Test';
  static const String settingsTitle = 'settings_title';
  static const String historyTitle = 'history_title';
  static const String serverSelectionTitle = 'server_selection_title';
  static const String startButton = 'start_button';
  static const String downloadLabel = 'download_label';
  static const String uploadLabel = 'upload_label';
  static const String pingLabel = 'ping_label';
  static const String jitterLabel = 'jitter_label';
  static const String loadingText = 'loading_text';
  static const String preparingText = 'preparing_text';
  static const String errorConnection = 'error_connection';
  static const String providerLabel = 'provider_label';
  static const String serverLabel = 'server_label';
  static const String unitsSection = 'units_section';
  static const String aboutSection = 'about_section';
  static const String versionLabel = 'version_label';
  static const String developerLabel = 'developer_label';
  static const String clearHistoryTitle = 'clear_history_title';
  static const String clearHistoryConfirm = 'clear_history_confirm';
  static const String cancelButton = 'cancel_button';
  static const String clearButton = 'clear_button';
  static const String historyEmpty = 'history_empty';
  static const String searchHint = 'search_hint';
  static const String serversNotFound = 'servers_not_found';
  static const String retryButton = 'retry_button';
  static const String languageLabel = 'language_label';
  static const String idleStatus = 'idle_status';
  static const String pingStatus = 'ping_status';
  static const String downloadStatus = 'download_status';
  static const String uploadStatus = 'upload_status';
  static const String locationLabel = 'location_label';
  static const String rateProvider = 'rate_provider';
  static const String lastTestLabel = 'last_test_label';
}

class Localization {
  static final Map<String, String> languages = {
    'en': 'English',
    'ru': 'Русский',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'pt': 'Português',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
    'ar': 'العربية',
    'hi': 'हिन्दी',
    'tr': 'Türkçe',
    'nl': 'Nederlands',
    'sv': 'Svenska',
    'pl': 'Polski',
    'vi': 'Tiếng Việt',
    'th': 'ไทย',
    'id': 'Bahasa Indonesia',
    'uk': 'Українська',
  };

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      AppStrings.settingsTitle: 'Settings',
      AppStrings.historyTitle: 'History',
      AppStrings.serverSelectionTitle: 'Select Server',
      AppStrings.startButton: 'START',
      AppStrings.downloadLabel: 'DOWNLOAD',
      AppStrings.uploadLabel: 'UPLOAD',
      AppStrings.pingLabel: 'Ping',
      AppStrings.jitterLabel: 'Jitter',
      AppStrings.loadingText: 'Searching...',
      AppStrings.preparingText: 'Preparing...',
      AppStrings.errorConnection: 'Connection Error',
      AppStrings.providerLabel: 'Provider',
      AppStrings.serverLabel: 'Server',
      AppStrings.unitsSection: 'Units',
      AppStrings.aboutSection: 'About',
      AppStrings.versionLabel: 'Version',
      AppStrings.developerLabel: 'Developer',
      AppStrings.clearHistoryTitle: 'Clear History?',
      AppStrings.clearHistoryConfirm: 'This action cannot be undone.',
      AppStrings.cancelButton: 'Cancel',
      AppStrings.clearButton: 'Clear',
      AppStrings.historyEmpty: 'History is empty',
      AppStrings.searchHint: 'Search...',
      AppStrings.serversNotFound: 'No servers found',
      AppStrings.retryButton: 'Retry',
      AppStrings.languageLabel: 'Language',
      AppStrings.idleStatus: 'IDLE',
      AppStrings.pingStatus: 'PING',
      AppStrings.downloadStatus: 'Downloading...',
      AppStrings.uploadStatus: 'Uploading...',
      AppStrings.locationLabel: 'Location',
      AppStrings.rateProvider: 'RATE YOUR PROVIDER',
      AppStrings.lastTestLabel: 'LAST TEST',
    },
    'ru': {
      AppStrings.settingsTitle: 'Настройки',
      AppStrings.historyTitle: 'История',
      AppStrings.serverSelectionTitle: 'Выбор сервера',
      AppStrings.startButton: 'НАЧАТЬ',
      AppStrings.downloadLabel: 'ЗАГРУЗКА',
      AppStrings.uploadLabel: 'ВЫГРУЗКА',
      AppStrings.pingLabel: 'Ping',
      AppStrings.jitterLabel: 'Jitter',
      AppStrings.loadingText: 'Поиск...',
      AppStrings.preparingText: 'Подготовка...',
      AppStrings.errorConnection: 'Ошибка подключения',
      AppStrings.providerLabel: 'Провайдер',
      AppStrings.serverLabel: 'Сервер',
      AppStrings.unitsSection: 'Единицы измерения',
      AppStrings.aboutSection: 'О приложении',
      AppStrings.versionLabel: 'Версия',
      AppStrings.developerLabel: 'Разработчик',
      AppStrings.clearHistoryTitle: 'Очистить историю?',
      AppStrings.clearHistoryConfirm: 'Это действие нельзя отменить.',
      AppStrings.cancelButton: 'Отмена',
      AppStrings.clearButton: 'Очистить',
      AppStrings.historyEmpty: 'История пуста',
      AppStrings.searchHint: 'Поиск...',
      AppStrings.serversNotFound: 'Серверы не найдены',
      AppStrings.retryButton: 'Повторить',
      AppStrings.languageLabel: 'Язык',
      AppStrings.idleStatus: 'ГОТОВ',
      AppStrings.pingStatus: 'ПИНГ',
      AppStrings.downloadStatus: 'Загрузка...',
      AppStrings.uploadStatus: 'Выгрузка...',
      AppStrings.locationLabel: 'Локация',
      AppStrings.rateProvider: 'ОЦЕНИТЬ ПРОВАЙДЕРА',
      AppStrings.lastTestLabel: 'ПОСЛЕДНИЙ ТЕСТ',
    },
    // Adding minimal translations for others to avoid compilation errors if keys missing
    // In a real app, fill these out
     'es': {
      AppStrings.settingsTitle: 'Configuración',
      AppStrings.lastTestLabel: 'ÚLTIMO TEST',
      // ... others
    },
     'uk': {
      AppStrings.settingsTitle: 'Налаштування',
      AppStrings.lastTestLabel: 'ОСТАННІЙ ТЕСТ',
       AppStrings.historyTitle: 'Історія',
      AppStrings.serverSelectionTitle: 'Вибір сервера',
      AppStrings.startButton: 'ПОЧАТИ',
      AppStrings.downloadLabel: 'ЗАВАНТАЖЕННЯ',
      AppStrings.uploadLabel: 'ВИВАНТАЖЕННЯ',
      AppStrings.pingLabel: 'Ping',
      AppStrings.jitterLabel: 'Jitter',
      AppStrings.loadingText: 'Пошук...',
      AppStrings.preparingText: 'Підготовка...',
      AppStrings.errorConnection: 'Помилка з\'єднання',
      AppStrings.providerLabel: 'Провайдер',
      AppStrings.serverLabel: 'Сервер',
      AppStrings.unitsSection: 'Одиниці вимірювання',
      AppStrings.aboutSection: 'Про додаток',
      AppStrings.versionLabel: 'Версія',
      AppStrings.developerLabel: 'Розробник',
      AppStrings.clearHistoryTitle: 'Очистити історію?',
      AppStrings.clearHistoryConfirm: 'Цю дію не можна скасувати.',
      AppStrings.cancelButton: 'Скасувати',
      AppStrings.clearButton: 'Очистити',
      AppStrings.historyEmpty: 'Історія порожня',
      AppStrings.searchHint: 'Пошук...',
      AppStrings.serversNotFound: 'Сервери не знайдено',
      AppStrings.retryButton: 'Повторити',
      AppStrings.languageLabel: 'Мова',
      AppStrings.idleStatus: 'ГОТОВИЙ',
      AppStrings.pingStatus: 'ПІНГ',
      AppStrings.downloadStatus: 'Завантаження...',
      AppStrings.uploadStatus: 'Вивантаження...',
      AppStrings.locationLabel: 'Локація',
      AppStrings.rateProvider: 'ОЦІНИТИ ПРОВАЙДЕРА',
    },
  };

  static String get(String code, String key) {
    if (_localizedValues.containsKey(code) && _localizedValues[code]!.containsKey(key)) {
      return _localizedValues[code]![key]!;
    }
    // Fallback to English
    return _localizedValues['en']?[key] ?? key;
  }
}