using Android.Media;
using LumenFocus.Maui.Services;

namespace LumenFocus.Maui.Platforms.Android.Services;

public class AudioService : IAudioService
{
    private MediaPlayer? _mediaPlayer;

    public async Task PlaySoundAsync(string soundName)
    {
        try
        {
            await MainThread.InvokeOnMainThreadAsync(() =>
            {
                if (string.IsNullOrEmpty(soundName) || soundName == "default")
                {
                    PlaySystemSound();
                }
                else
                {
                    PlayCustomSound(soundName);
                }
            });
        }
        catch
        {
            // Fallback to basic sound if platform-specific fails
        }
    }

    public async Task StopSoundAsync()
    {
        try
        {
            await MainThread.InvokeOnMainThreadAsync(() =>
            {
                _mediaPlayer?.Stop();
                _mediaPlayer?.Release();
                _mediaPlayer = null;
            });
        }
        catch
        {
            // Ignore errors when stopping
        }
    }

    public async Task SetVolumeAsync(float volume)
    {
        try
        {
            await MainThread.InvokeOnMainThreadAsync(() =>
            {
                if (_mediaPlayer != null)
                {
                    _mediaPlayer.SetVolume(volume, volume);
                }
            });
        }
        catch
        {
            // Ignore errors when setting volume
        }
    }

    private void PlaySystemSound()
    {
        try
        {
            // Play system notification sound
            var notification = RingtoneManager.GetDefaultUri(RingtoneType.Notification);
            var ringtone = RingtoneManager.GetRingtone(Microsoft.Maui.ApplicationModel.Platform.CurrentActivity ?? throw new InvalidOperationException("CurrentActivity is null"), notification);
            ringtone?.Play();
        }
        catch
        {
            // Fallback to basic sound
        }
    }

    private void PlayCustomSound(string soundName)
    {
        try
        {
            // Play custom sound if available
            // For now, fallback to system sound
            PlaySystemSound();
        }
        catch
        {
            // Fallback to system sound
            PlaySystemSound();
        }
    }
}

