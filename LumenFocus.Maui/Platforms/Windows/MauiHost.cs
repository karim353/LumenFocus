using Microsoft.Maui;
using Microsoft.Maui.Hosting;
using Microsoft.UI.Xaml.Controls;

namespace LumenFocus.Maui.Platforms.Windows;

public class MauiHost : ContentControl
{
    public MauiHost()
    {
        var mauiApp = MauiProgram.CreateMauiApp();
        var mauiWindow = mauiApp.Services.GetRequiredService<IWindow>();
        var mauiContent = mauiWindow.Content;
        
        Content = mauiContent;
    }
}
