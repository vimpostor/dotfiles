local wezterm = require 'wezterm';

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Breeze"
	else
		return "PencilLight"
	end
end

wezterm.on("window-config-reloaded", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local scheme = scheme_for_appearance(window:get_appearance())
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

return {
	check_for_updates = false,
	enable_tab_bar = false,
	exit_behavior = "Close",
	font = wezterm.font("MesloLGS NF"),
	font_size = 10.0,
	keys = {
		{key="UpArrow", mods="SHIFT", action=wezterm.action.ScrollToPrompt(-1)},
		{key="DownArrow", mods="SHIFT", action=wezterm.action.ScrollToPrompt(1)},
	},
}
