# LumenFocus .NET MAUI

Это версия приложения LumenFocus, переписанная на .NET MAUI для кроссплатформенной работы.

## Возможности

- **Таймер фокусировки** с настраиваемыми пресетами (Pomodoro, Quick Focus)
- **Управление задачами** с тегами, цветами и иконками
- **Отслеживание сессий** фокусировки
- **Виртуальный сад** для мотивации
- **Статистика** продуктивности
- **Настройки** приложения

## Технологии

- **.NET MAUI 8.0** - кроссплатформенный UI фреймворк
- **Entity Framework Core** - ORM для работы с данными
- **SQLite** - локальная база данных
- **MVVM** архитектура с CommunityToolkit.Mvvm
- **XAML** для пользовательского интерфейса

## Поддерживаемые платформы

- ✅ Windows 10/11
- ✅ macOS
- ✅ iOS
- ✅ Android

## Требования для разработки

- **Visual Studio 2022 17.8+** или **Visual Studio Code**
- **.NET 8.0 SDK**
- **Workload для .NET MAUI**

## Установка workload для .NET MAUI

```bash
dotnet workload install maui
```

## Запуск проекта

### Windows
```bash
dotnet build -f net8.0-windows10.0.19041.0
dotnet run -f net8.0-windows10.0.19041.0
```

### macOS
```bash
dotnet build -f net8.0-maccatalyst
dotnet run -f net8.0-maccatalyst
```

### iOS (требует Mac)
```bash
dotnet build -f net8.0-ios
dotnet run -f net8.0-ios
```

### Android
```bash
dotnet build -f net8.0-android
dotnet run -f net8.0-android
```

## Структура проекта

```
LumenFocus.Maui/
├── Data/                    # Модели данных и DbContext
│   ├── Models/             # Entity Framework модели
│   └── LumenFocusDbContext.cs
├── Services/               # Бизнес-логика и сервисы
│   ├── IDataService.cs
│   ├── DataService.cs
│   ├── INotificationService.cs
│   ├── NotificationService.cs
│   ├── IAudioService.cs
│   ├── AudioService.cs
│   ├── IFocusModeService.cs
│   └── FocusModeService.cs
├── ViewModels/             # ViewModels для MVVM
│   ├── TasksViewModel.cs
│   └── TimerViewModel.cs
├── Views/                  # XAML страницы
│   ├── TasksView.xaml
│   ├── FocusView.xaml
│   ├── GardenView.xaml
│   ├── StatisticsView.xaml
│   └── SettingsView.xaml
├── Converters/             # Конвертеры для XAML
│   └── ValueConverters.cs
├── Resources/              # Ресурсы приложения
│   ├── Styles/
│   └── Images/
├── App.xaml                # Главный файл приложения
├── AppShell.xaml          # Навигация
└── MauiProgram.cs         # Конфигурация DI
```

## Основные отличия от SwiftUI версии

### UI Framework
- **SwiftUI** → **XAML** + **C#**
- **@State, @Binding** → **ObservableObject, ObservableProperty**
- **NavigationView** → **Shell** с **TabBar**

### Data Layer
- **Core Data** → **Entity Framework Core**
- **NSManagedObjectContext** → **DbContext**
- **@FetchRequest** → **ObservableCollection** с **IDataService**

### Architecture
- **Swift** → **C#**
- **MVVM** с **CommunityToolkit.Mvvm**
- **Dependency Injection** через **MauiProgram.cs**

## Планы развития

- [ ] Добавить AddTaskView
- [ ] Реализовать GardenView
- [ ] Добавить StatisticsView
- [ ] Улучшить SettingsView
- [ ] Добавить уведомления
- [ ] Реализовать аудио
- [ ] Добавить синхронизацию с облаком
- [ ] Создать виджеты

## Лицензия

MIT License
