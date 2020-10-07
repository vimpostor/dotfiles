ardour {
	["type"] = "EditorAction",
	name = "Initialize tracks with a single mic",
	author = "Magnus Groß",
	license = "MIT",
	description = [[Assigns the same stereo channel to all selected mono tracks]]
}

function factory() return function()
	local sel = Editor:get_selection()
	local _, ports = Session:engine():get_backend_ports("", ARDOUR.DataType.audio(), ARDOUR.PortFlags.IsOutput | ARDOUR.PortFlags.IsPhysical, C.StringVector())
	local p = ""
	for port in ports[4]:iter() do
		if p == "" then
			p = port
		end
	end
	if p == "" then
		return
	end

	for r in sel.tracks:routelist():iter() do
		local input = r:input()
		if input:n_ports():n_audio() == 0 then
			return
		end
		-- disconnect all connected ports and connect the standard port
		local current_port = input:audio(0)
		current_port:disconnect_all()
		current_port:connect(p)
	end
end end
