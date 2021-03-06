ardour {
	["type"] = "EditorAction",
	name = "Create new mono track",
	author = "Magnus Groß",
	license = "MIT",
	description = [[Creates a track and connects the first Stereo channel as only input source]]
}

function factory() return function()
	-- add a new audio track
	local tracks = Session:new_audio_track(1, 2, nil, 1, "", ARDOUR.PresentationInfo.max_order, ARDOUR.TrackMode.Normal, false)
	if tracks:size() == 0 then
		return
	end
	local track = tracks:front()
	-- find out our input port
	local input = track:input()
	if input:n_ports():n_audio() == 0 then
		return
	end
	local current_port = input:audio(0)
	-- get the first channel of the default Stereo input source
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
	-- connect the Stereo channel to our mono audio track
	current_port:connect(p)
	-- disarm all armed tracks
	for route in Session:get_tracks():iter() do
		if route:rec_enable_control():get_value() == 1.0 then
			route:rec_enable_control():set_value(0, PBD.GroupControlDisposition.NoGroup)
		end
	end
	-- then arm our track
	track:rec_enable_control():set_value(1, PBD.GroupControlDisposition.NoGroup)
end end
