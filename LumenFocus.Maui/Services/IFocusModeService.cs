namespace LumenFocus.Maui.Services;

public interface IFocusModeService
{
    Task<bool> RequestFocusModeAccessAsync();
    Task<bool> IsFocusModeEnabledAsync();
    Task EnableFocusModeAsync();
    Task DisableFocusModeAsync();
}
