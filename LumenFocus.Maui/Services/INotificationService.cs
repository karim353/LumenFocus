namespace LumenFocus.Maui.Services;

public interface INotificationService
{
    Task<bool> RequestNotificationPermissionAsync();
    Task ShowNotificationAsync(string title, string message, string? soundName = null);
    Task CancelNotificationAsync(int notificationId);
    Task<bool> AreNotificationsEnabledAsync();
}
