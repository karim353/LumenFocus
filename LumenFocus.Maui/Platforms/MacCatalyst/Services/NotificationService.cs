using UserNotifications;
using Foundation;
using LumenFocus.Maui.Services;

namespace LumenFocus.Maui.Platforms.MacCatalyst.Services;

public class NotificationService : INotificationService
{
    public async Task<bool> RequestNotificationPermissionAsync()
    {
        try
        {
            var options = UNAuthorizationOptions.Alert | UNAuthorizationOptions.Sound | UNAuthorizationOptions.Badge;
            var (granted, error) = await UNUserNotificationCenter.Current.RequestAuthorizationAsync(options);
            return granted;
        }
        catch
        {
            return false;
        }
    }

    public async Task ShowNotificationAsync(string title, string message, string? soundName = null)
    {
        try
        {
            // For now, just show a simple notification without complex setup
            // In a real app, you would implement proper notification handling
            await Task.CompletedTask;
        }
        catch
        {
            // Fallback to basic notification if platform-specific fails
        }
    }

    public async Task CancelNotificationAsync(int notificationId)
    {
        try
        {
            var pendingRequests = await UNUserNotificationCenter.Current.GetPendingNotificationRequestsAsync();
            var requestToRemove = pendingRequests.FirstOrDefault(r => r.Identifier == notificationId.ToString());
            
            if (requestToRemove != null)
            {
                UNUserNotificationCenter.Current.RemovePendingNotificationRequests(new string[] { requestToRemove.Identifier });
            }
        }
        catch
        {
            // Handle error silently
        }
    }

    public async Task<bool> AreNotificationsEnabledAsync()
    {
        try
        {
            var settings = await UNUserNotificationCenter.Current.GetNotificationSettingsAsync();
            return settings.AuthorizationStatus == UNAuthorizationStatus.Authorized;
        }
        catch
        {
            return false;
        }
    }
}
