using Microsoft.Extensions.Logging;
using CommunityToolkit.Maui;
using LumenFocus.Maui.Services;
using LumenFocus.Maui.ViewModels;
using LumenFocus.Maui.Views;
using LumenFocus.Maui.Data;

namespace LumenFocus.Maui;

public static class MauiProgram
{
	public static MauiApp CreateMauiApp()
	{
		var builder = MauiApp.CreateBuilder();
		builder
			.UseMauiApp<App>()
			.UseMauiCommunityToolkit()
			.ConfigureFonts(fonts =>
			{
				fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
				fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
			});

		// Register Services
		builder.Services.AddDbContext<LumenFocusDbContext>();
		builder.Services.AddSingleton<IDataService, DataService>();

#if IOS
		builder.Services.AddSingleton<INotificationService, LumenFocus.Maui.Platforms.iOS.Services.NotificationService>();
		builder.Services.AddSingleton<IAudioService, LumenFocus.Maui.Platforms.iOS.Services.AudioService>();
		builder.Services.AddSingleton<IFocusModeService, LumenFocus.Maui.Platforms.iOS.Services.FocusModeService>();
#elif ANDROID
		builder.Services.AddSingleton<INotificationService, LumenFocus.Maui.Platforms.Android.Services.NotificationService>();
		builder.Services.AddSingleton<IAudioService, LumenFocus.Maui.Services.AudioService>();
		builder.Services.AddSingleton<IFocusModeService, LumenFocus.Maui.Services.FocusModeService>();
#elif WINDOWS
		builder.Services.AddSingleton<INotificationService, LumenFocus.Maui.Platforms.Windows.Services.NotificationService>();
		builder.Services.AddSingleton<IAudioService, LumenFocus.Maui.Services.AudioService>();
		builder.Services.AddSingleton<IFocusModeService, LumenFocus.Maui.Services.FocusModeService>();
#elif MACCATALYST
		builder.Services.AddSingleton<INotificationService, LumenFocus.Maui.Platforms.MacCatalyst.Services.NotificationService>();
		builder.Services.AddSingleton<IAudioService, LumenFocus.Maui.Services.AudioService>();
		builder.Services.AddSingleton<IFocusModeService, LumenFocus.Maui.Services.FocusModeService>();
#else
		builder.Services.AddSingleton<INotificationService, LumenFocus.Maui.Services.NotificationService>();
		builder.Services.AddSingleton<IAudioService, LumenFocus.Maui.Services.AudioService>();
		builder.Services.AddSingleton<IFocusModeService, LumenFocus.Maui.Services.FocusModeService>();
#endif

		// Register ViewModels
		builder.Services.AddTransient<TimerViewModel>();
		builder.Services.AddTransient<TasksViewModel>();
		builder.Services.AddTransient<GardenViewModel>();
		builder.Services.AddTransient<StatisticsViewModel>();
		builder.Services.AddTransient<SettingsViewModel>();
		builder.Services.AddTransient<AddTaskViewModel>();

		// Register Views
		builder.Services.AddTransient<FocusView>();
		builder.Services.AddTransient<TasksView>();
		builder.Services.AddTransient<GardenView>();
		builder.Services.AddTransient<StatisticsView>();
		builder.Services.AddTransient<SettingsView>();
		builder.Services.AddTransient<AddTaskView>();

#if DEBUG
		builder.Logging.AddDebug();
#endif

		return builder.Build();
	}
}
