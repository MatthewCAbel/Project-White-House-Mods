local MHiCS_old_create_job_gui
local MHiCS_create_job_gui = function(self, data, ...)
	if not MHiCS.settings.enabled then
		return MHiCS_old_create_job_gui(self, data, ...)
	end

	local narrative_data = data.job_id and tweak_data.narrative:job_data(data.job_id)
	if data.one_down == "MHiCS" then
		data.one_down = 0
		local old_professional
		if narrative_data then
			old_professional = narrative_data.professional
			narrative_data.professional = true
		else
			local gui_data = MHiCS_old_create_job_gui(self, data, ...)
			gui_data.marker_panel:bitmap({
				texture = "guis/textures/pd2/crimenet_marker_pro_outline",
				name = "marker_pro_outline",
				h = 64,
				rotation = 0,
				w = 64,
				alpha = 1,
				blend_mode = "add",
				y = 0,
				x = 0,
				layer = 0
			})
			if gui_data.glow_panel then
				for _, panel in ipairs(gui_data.glow_panel:children()) do
					if panel:name() == "glow_center" or panel:name() == "glow_stretch" then
						panel:set_color(tweak_data.screen_colors.pro_color)
					end
				end	
			end
			return gui_data
		end
		local ret_val = MHiCS_old_create_job_gui(self, data, ...)
		narrative_data.professional = old_professional	
		return ret_val
	end
	return MHiCS_old_create_job_gui(self, data, ...)
end

local MHiCS_old_update_server_job
local MHiCS_update_server_job = function(self, data, ...)
	if not MHiCS.settings.enabled then
		return MHiCS_old_update_server_job(self, data, ...)
	end

	local narrative_data = data.job_id and tweak_data.narrative:job_data(data.job_id)
	if data.one_down == "MHiCS" then
		data.one_down = 0
		local old_professional
		if narrative_data then
			old_professional = narrative_data.professional
			narrative_data.professional = true
		else
			return MHiCS_old_update_server_job(self, data, ...)
		end
		local ret_val = MHiCS_old_update_server_job(self, data, ...)
		narrative_data.professional = old_professional	
		return ret_val
	end
	return MHiCS_old_update_server_job(self, data, ...)
end

local function MHiCS_setup_crimenet_values()
	MHiCS_old_create_job_gui = CrimeNetGui._create_job_gui
	CrimeNetGui._create_job_gui = MHiCS_create_job_gui
	MHiCS_old_update_server_job = CrimeNetGui.update_server_job
	CrimeNetGui.update_server_job = MHiCS_update_server_job
end
DelayedCalls:Add( "MHiCS_setup_crimenet_values", 2, MHiCS_setup_crimenet_values )