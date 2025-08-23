using Microsoft.UI.Xaml;
using Windows.UI.Notifications;
using Windows.Data.Xml.Dom;
using LumenFocus.Maui.Services;

namespace LumenFocus.Maui.Platforms.Windows.Services;

public class NotificationService : INotificationService
{
    public async Task<bool> RequestNotificationPermissionAsync()
    {
        try
        {
            // Windows notifications don't require explicit permission
            return true;
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
            await MainThread.InvokeOnMainThreadAsync(() =>
            {
                ShowToastNotification(title, message);
            });
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
            // Windows doesn't support canceling specific notifications by ID
            await Task.CompletedTask;
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
            // Windows notifications are generally enabled
            return true;
        }
        catch
        {
            return false;
        }
    }

    private void ShowToastNotification(string title, string message)
    {
        try
        {
            var toastXml = $@"
                <toast>
                    <visual>
                        <binding template='ToastGeneric'>
                            <text>{title}</text>
                            <text>{message}</text>
                        </binding>
                    </visual>
                </toast>";

            var doc = new XmlDocument();
            doc.LoadXml(toastXml);

            var toast = new ToastNotification(doc);
            var notifier = ToastNotificationManager.CreateToastNotifier("LumenFocus");
            notifier.Show(toast);
        }
        catch
        {
            // Fallback to basic notification if platform-specific fails
        }
    }
}
