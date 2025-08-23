using AVFoundation;
using Foundation;
using LumenFocus.Maui.Services;

namespace LumenFocus.Maui.Platforms.MacCatalyst.Services;

public class AudioService : IAudioService
{
    private AVAudioPlayer? _audioPlayer;

    public async Task PlaySoundAsync(string soundName)
    {
        try
        {
            await MainThread.InvokeOnMainThreadAsync(() =>
            {
                PlayCustomSound(soundName);
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
                _audioPlayer?.Stop();
                _audioPlayer = null;
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
                if (_audioPlayer != null)
                {
                    _audioPlayer.Volume = Math.Max(0.0f, Math.Min(1.0f, volume));
                }
            });
        }
        catch
        {
            // Ignore errors when setting volume
        }
    }

    public async Task<bool> RequestPermissionAsync()
    {
        try
        {
            // macOS doesn't require explicit audio permission for basic sounds
            return true;
        }
        catch
        {
            return false;
        }
    }

    public async Task PlayNotificationSoundAsync()
    {
        try
        {
            await MainThread.InvokeOnMainThreadAsync(() =>
            {
                PlaySystemSound();
            });
        }
        catch
        {
            // Fallback to basic sound if platform-specific fails
        }
    }

    public async Task PlayCustomSoundAsync(string soundName)
    {
        try
        {
            await MainThread.InvokeOnMainThreadAsync(() =>
            {
                PlayCustomSound(soundName);
            });
        }
        catch
        {
            // Fallback to basic sound if platform-specific fails
        }
    }

    public async Task PlaySuccessSoundAsync()
    {
        await PlayNotificationSoundAsync();
    }

    public async Task PlayErrorSoundAsync()
    {
        await PlayNotificationSoundAsync();
    }

    private void PlaySystemSound()
    {
        try
        {
            // Play system notification sound using AVAudioSession
            var session = AVAudioSession.SharedInstance();
            session.SetCategory(AVAudioSessionCategory.Playback);
            session.SetActive(true);
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
            var soundUrl = NSBundle.MainBundle.GetUrlForResource(soundName, "wav");
            if (soundUrl != null)
            {
                _audioPlayer = AVAudioPlayer.FromUrl(soundUrl);
                _audioPlayer?.Play();
            }
        }
        catch
        {
            // Fallback to system sound
            PlaySystemSound();
        }
    }
}
