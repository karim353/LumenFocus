using Microsoft.Extensions.Logging;
using LumenFocus.Maui.Services;
using LumenFocus.Maui.Data;
using LumenFocus.Maui.ViewModels;

namespace LumenFocus.Maui;

public partial class App : Application
{
	public App()
	{
		InitializeComponent();
		
		// Initialize database
		InitializeDatabaseAsync();
		
		MainPage = new AppShell();
	}

	private async void InitializeDatabaseAsync()
	{
		try
		{
			using var context = new LumenFocusDbContext();
			await context.Database.EnsureCreatedAsync();
			System.Diagnostics.Debug.WriteLine("Database initialized successfully");
		}
		catch (Exception ex)
		{
			System.Diagnostics.Debug.WriteLine($"Error initializing database: {ex.Message}");
			// Continue without database for now
		}
	}
}
