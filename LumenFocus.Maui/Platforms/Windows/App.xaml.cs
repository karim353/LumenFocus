using Microsoft.Maui;

namespace LumenFocus.Maui.Platforms.Windows;

public partial class App : Microsoft.UI.Xaml.Application
{
	protected override void OnLaunched(Microsoft.UI.Xaml.LaunchActivatedEventArgs args)
	{
		var mauiApp = MauiProgram.CreateMauiApp();
		var window = new MainWindow();
		window.Activate();
	}
}
