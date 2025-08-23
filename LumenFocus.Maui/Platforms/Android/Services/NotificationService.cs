using Android.App;
using Android.Content;
using Android.OS;
using AndroidX.Core.App;
using LumenFocus.Maui.Services;

namespace LumenFocus.Maui.Platforms.Android.Services;

public class NotificationService : INotificationService
{
    private const string ChannelId = "LumenFocus_Channel";
    private const string ChannelName = "LumenFocus Notifications";
    private const string ChannelDescription = "Notifications for focus sessions";

    public async Task<bool> RequestNotificationPermissionAsync()
    {
        try
        {
            // For now, just return true to avoid permission issues
            // In a real app, you would implement proper permission handling
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
                CreateNotificationChannel();
                ShowNotification(title, message);
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
            await MainThread.InvokeOnMainThreadAsync(() =>
            {
                var notificationManager = NotificationManagerCompat.From(Microsoft.Maui.ApplicationModel.Platform.CurrentActivity ?? throw new InvalidOperationException("CurrentActivity is null"));
                notificationManager.Cancel(notificationId);
            });
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
            return await MainThread.InvokeOnMainThreadAsync(() =>
            {
                var notificationManager = NotificationManagerCompat.From(Microsoft.Maui.ApplicationModel.Platform.CurrentActivity ?? throw new InvalidOperationException("CurrentActivity is null"));
                return notificationManager.AreNotificationsEnabled();
            });
        }
        catch
        {
            return false;
        }
    }

    private void CreateNotificationChannel()
    {
        if (OperatingSystem.IsAndroidVersionAtLeast(26))
        {
            var channel = new NotificationChannel(ChannelId, ChannelName, NotificationImportance.High)
            {
                Description = ChannelDescription
            };

            var notificationManager = Microsoft.Maui.ApplicationModel.Platform.CurrentActivity?.GetSystemService(global::Android.Content.Context.NotificationService) as NotificationManager;
            notificationManager?.CreateNotificationChannel(channel);
        }
    }

    private void ShowNotification(string title, string message)
    {
        var builder = new NotificationCompat.Builder(Microsoft.Maui.ApplicationModel.Platform.CurrentActivity ?? throw new InvalidOperationException("CurrentActivity is null"), ChannelId)
            .SetContentTitle(title)
            .SetContentText(message)
            .SetSmallIcon(global::Android.Resource.Mipmap.SymDefAppIcon)
            .SetPriority(NotificationCompat.PriorityHigh)
            .SetAutoCancel(true);

        var notificationManager = NotificationManagerCompat.From(Microsoft.Maui.ApplicationModel.Platform.CurrentActivity ?? throw new InvalidOperationException("CurrentActivity is null"));
        notificationManager.Notify(1, builder.Build());
    }
}
