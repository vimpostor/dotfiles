-- normally, add would query for a bind, don't want that to happen
dispatch_bindtarget("/target/window/destroy");
dispatch_symbol("/global/settings/titlebar/buttons/left/add=icon_destroy");

dispatch_bindtarget("/global");
dispatch_symbol("/global/settings/statusbar/buttons/left/add=Go");

-- terminal icon with a popup that also allows access to other menus
dispatch_bindtarget("/global/open/terminal");
dispatch_symbol("/global/settings/statusbar/buttons/left/add=icon_cli");

dispatch_bindtarget("/global/tools/popup/menu=/menus/cli_icon");
dispatch_symbol("/global/settings/statusbar/buttons/left/extend/alternate_click/1");

dispatch_symbol("/global/settings/tools/presets")
