local wezterm = require 'wezterm';
local default_font_size = 14.0;

function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return "Breeze"
	else
		return "One Light (base16)"
	end
end

function compute_font_size(window)
	local overrides = window:get_config_overrides() or {}
	overrides.font_size = math.ceil(default_font_size * 96 / window:get_dimensions().dpi)
	window:set_config_overrides(overrides)
end

wezterm.on('window-resized', function(window) compute_font_size() end)

return {
	adjust_window_size_when_changing_font_size = false,
	check_for_updates = false,
	color_scheme = scheme_for_appearance(wezterm.gui.get_appearance()),
	enable_tab_bar = false,
	exit_behavior = "Close",
	font = wezterm.font_with_fallback{"Iosevka Extended", "Twemoji"},
	font_size = default_font_size,
	force_reverse_video_cursor = true,
	keys = {
		{key="UpArrow", mods="SHIFT", action=wezterm.action.ScrollToPrompt(-1)},
		{key="DownArrow", mods="SHIFT", action=wezterm.action.ScrollToPrompt(1)},
	},
	warn_about_missing_glyphs = false,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}
