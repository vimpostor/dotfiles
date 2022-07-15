local wezterm = require 'wezterm';

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Breeze"
	else
		return "PaperColorLight (Gogh)"
	end
end

return {
	check_for_updates = false,
	color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
	enable_tab_bar = false,
	exit_behavior = "Close",
	font = wezterm.font("MesloLGS NF"),
	font_size = 10.0,
	keys = {
		{key="UpArrow", mods="SHIFT", action=wezterm.action.ScrollToPrompt(-1)},
		{key="DownArrow", mods="SHIFT", action=wezterm.action.ScrollToPrompt(1)},
	},
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}
