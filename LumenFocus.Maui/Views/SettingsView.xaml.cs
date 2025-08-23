using LumenFocus.Maui.ViewModels;

namespace LumenFocus.Maui.Views;

public partial class SettingsView : ContentPage
{
	public SettingsView()
	{
		InitializeComponent();
		BindingContext = ViewModelFactory.CreateSettingsViewModel();
	}
}
