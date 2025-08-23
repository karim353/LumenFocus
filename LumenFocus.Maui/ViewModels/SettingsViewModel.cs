using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using LumenFocus.Maui.Services;
using SystemTask = System.Threading.Tasks.Task;

namespace LumenFocus.Maui.ViewModels;

public partial class SettingsViewModel : ObservableObject
{
    private readonly IDataService _dataService;
    private readonly INotificationService _notificationService;
    private readonly IFocusModeService _focusModeService;
    
    [ObservableProperty]
    private bool _notificationsEnabled = true;
    
    [ObservableProperty]
    private bool _soundEnabled = true;
    
    [ObservableProperty]
    private bool _vibrationEnabled = true;
    
    [ObservableProperty]
    private double _soundVolume = 0.7;
    
    [ObservableProperty]
    private bool _focusModeEnabled = false;
    
    [ObservableProperty]
    private bool _autoStartSessions = false;
    
    [ObservableProperty]
    private bool _showBreakReminders = true;
    
    [ObservableProperty]
    private bool _darkModeEnabled = false;
    
    [ObservableProperty]
    private string _selectedLanguage = "English";
    
    [ObservableProperty]
    private bool _isLoading = false;
    
    public List<string> AvailableLanguages { get; } = new()
    {
        "English", "Russian", "Spanish", "French", "German", "Chinese", "Japanese"
    };
    
    public SettingsViewModel() : this(new DataService(new Data.LumenFocusDbContext()), new NotificationService(), new FocusModeService())
    {
    }
    
    public SettingsViewModel(IDataService dataService, INotificationService notificationService, IFocusModeService focusModeService)
    {
        _dataService = dataService;
        _notificationService = notificationService;
        _focusModeService = focusModeService;
        _ = LoadSettingsAsync();
    }
    
    private async SystemTask LoadSettingsAsync()
    {
        try
        {
            IsLoading = true;
            
            // Load settings from preferences or database
            // For now, we'll use default values
            NotificationsEnabled = Preferences.Default.Get("NotificationsEnabled", true);
            SoundEnabled = Preferences.Default.Get("SoundEnabled", true);
            VibrationEnabled = Preferences.Default.Get("VibrationEnabled", true);
            SoundVolume = Preferences.Default.Get("SoundVolume", 0.7);
            FocusModeEnabled = Preferences.Default.Get("FocusModeEnabled", false);
            AutoStartSessions = Preferences.Default.Get("AutoStartSessions", false);
            ShowBreakReminders = Preferences.Default.Get("ShowBreakReminders", true);
            DarkModeEnabled = Preferences.Default.Get("DarkModeEnabled", false);
            SelectedLanguage = Preferences.Default.Get("SelectedLanguage", "English");
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error loading settings: {ex.Message}");
        }
        finally
        {
            IsLoading = false;
        }
    }
    
    partial void OnNotificationsEnabledChanged(bool value)
    {
        SaveSetting("NotificationsEnabled", value);
        if (value)
        {
            _ = RequestNotificationPermissionAsync();
        }
    }
    
    partial void OnSoundEnabledChanged(bool value)
    {
        SaveSetting("SoundEnabled", value);
    }
    
    partial void OnVibrationEnabledChanged(bool value)
    {
        SaveSetting("VibrationEnabled", value);
    }
    
    partial void OnSoundVolumeChanged(double value)
    {
        SaveSetting("SoundVolume", value);
    }
    
    partial void OnFocusModeEnabledChanged(bool value)
    {
        SaveSetting("FocusModeEnabled", value);
        if (value)
        {
            _ = EnableFocusModeAsync();
        }
        else
        {
            _ = DisableFocusModeAsync();
        }
    }
    
    partial void OnAutoStartSessionsChanged(bool value)
    {
        SaveSetting("AutoStartSessions", value);
    }
    
    partial void OnShowBreakRemindersChanged(bool value)
    {
        SaveSetting("ShowBreakReminders", value);
    }
    
    partial void OnDarkModeEnabledChanged(bool value)
    {
        SaveSetting("DarkModeEnabled", value);
        _ = ApplyTheme(value);
    }
    
    partial void OnSelectedLanguageChanged(string value)
    {
        SaveSetting("SelectedLanguage", value);
        _ = ApplyLanguage(value);
    }
    
    private void SaveSetting<T>(string key, T value)
    {
        try
        {
            Preferences.Default.Set(key, value);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error saving setting {key}: {ex.Message}");
        }
    }
    
    private async SystemTask RequestNotificationPermissionAsync()
    {
        try
        {
            await _notificationService.RequestNotificationPermissionAsync();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error requesting notification permission: {ex.Message}");
        }
    }
    
    private async SystemTask EnableFocusModeAsync()
    {
        try
        {
            await _focusModeService.EnableFocusModeAsync();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error enabling focus mode: {ex.Message}");
        }
    }
    
    private async SystemTask DisableFocusModeAsync()
    {
        try
        {
            await _focusModeService.DisableFocusModeAsync();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error disabling focus mode: {ex.Message}");
        }
    }
    
    private async Task ApplyTheme(bool isDarkMode)
    {
        try
        {
            // Apply theme changes
            // This would typically involve updating the app's theme
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error applying theme: {ex.Message}");
        }
    }
    
    private async Task ApplyLanguage(string language)
    {
        try
        {
            // Apply language changes
            // This would typically involve updating the app's culture
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error applying language: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask ResetToDefaultsAsync()
    {
        try
        {
            // Reset all settings to default values
            NotificationsEnabled = true;
            SoundEnabled = true;
            VibrationEnabled = true;
            SoundVolume = 0.7;
            FocusModeEnabled = false;
            AutoStartSessions = false;
            ShowBreakReminders = true;
            DarkModeEnabled = false;
            SelectedLanguage = "English";
            
            // Clear preferences
            Preferences.Default.Clear();
            
            // Save default values
            await LoadSettingsAsync();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error resetting settings: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask ExportSettingsAsync()
    {
        try
        {
            // Export settings to file
            // This would typically involve creating a JSON file with current settings
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error exporting settings: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask ImportSettingsAsync()
    {
        try
        {
            // Import settings from file
            // This would typically involve reading a JSON file and applying settings
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error importing settings: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask ClearDataAsync()
    {
        try
        {
            // Clear all app data
            // This would typically involve clearing the database and preferences
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error clearing data: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask AboutAsync()
    {
        try
        {
            // Show about dialog
            // This would typically involve navigating to an about page
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error showing about: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask HelpAsync()
    {
        try
        {
            // Show help dialog
            // This would typically involve navigating to a help page
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error showing help: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask FeedbackAsync()
    {
        try
        {
            // Show feedback dialog
            // This would typically involve opening a feedback form
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error showing feedback: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask PrivacyPolicyAsync()
    {
        try
        {
            // Show privacy policy
            // This would typically involve opening a web page
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error showing privacy policy: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask TermsOfServiceAsync()
    {
        try
        {
            // Show terms of service
            // This would typically involve opening a web page
            await Task.CompletedTask;
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error showing terms of service: {ex.Message}");
        }
    }
}

