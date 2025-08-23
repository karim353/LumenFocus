namespace LumenFocus.Maui.Services;

public interface IAudioService
{
    Task PlaySoundAsync(string soundName);
    Task StopSoundAsync();
    Task SetVolumeAsync(float volume);
}
