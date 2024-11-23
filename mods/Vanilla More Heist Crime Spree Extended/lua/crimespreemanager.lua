-- Failsafe in case your crimespree breaks because of levels
Hooks:PostHook(CrimeSpreeManager, "load", "MHiCS_CrimeSpreeManager_load", function(self, data, version)
	if not MHiCS.settings.enabled then
		local dialog_data = {
			title = managers.localization:text("MHiCS_mod_not_enabled_title"),
			text = managers.localization:text("MHiCS_mod_not_enabled_desc")
		}
		local yes_button = {
			text = managers.localization:text("dialog_yes")
		}
		local no_button = {
			text = managers.localization:text("dialog_no")
		}
		dialog_data.focus_button = 2
		dialog_data.button_list = {
			yes_button,
			no_button
		}
		yes_button.callback_func = MenuCallbackHandler.MHiCS_confirm_reactivate_callback
		managers.system_menu:add_init_show(dialog_data)
	end
	if not self:in_progress() then
		return
	end
	MHiCS:check_mission_list(self)
end)


Hooks:PreHook(CrimeSpreeManager, "missions", MHiCS_CrimeSpreeManager_missions, function(self)
	MHiCS:check_mission_list(self)
end)

local function MHiCS_find_fit(random_set, to_fit, idx)
	if idx > 3 then
		return MHiCS.heist_to_entry[to_fit[2]].add < MHiCS.heist_to_entry[to_fit[3]].add
	end
	for _, i in pairs(MHiCS.heists[random_set[idx]].assign) do
		if to_fit[i] == "noheist" then
			to_fit[i] = random_set[idx]
			if MHiCS_find_fit(random_set, to_fit, idx + 1) then
				return true
			end
			to_fit[i] = "noheist"
		end
	end			
	return false
end

local MHiCS_old_get_random_missions = CrimeSpreeManager.get_random_missions

function CrimeSpreeManager:get_random_missions(prev_missions)
	if not MHiCS.settings.enabled or (not MHiCS.settings.more and not Global.game_settings.single_player) then
		return MHiCS_old_get_random_missions(self, prev_missions)
	end
	local is_ok = false
	local result_set = {"noheist", "noheist", "noheist"}
	while not is_ok do
		local random_set = {
			table.random(MHiCS.heist_names),
			table.random(MHiCS.heist_names),
			table.random(MHiCS.heist_names)
		}
		is_ok = true
		for j=1,#MHiCS.settings.last_missions do
			local miss = MHiCS.settings.last_missions[j]
			for i=1,3 do
				if MHiCS.heist_to_entry[random_set[i]].id == miss then
					is_ok = false
				end
			end
		end
		if is_ok then
			is_ok = false
			if random_set[1] ~= random_set[2] and random_set[2] ~= random_set[3] and random_set[3] ~= random_set[1] then 				
				is_ok = MHiCS_find_fit(random_set, result_set, 1)
			end
		end			
	end
	return {
		MHiCS.heist_to_entry[result_set[1]],
		MHiCS.heist_to_entry[result_set[2]],
		MHiCS.heist_to_entry[result_set[3]],
		}
end

Hooks:PreHook(CrimeSpreeManager, "on_mission_completed", "MHiCS_CrimeSpreeManager_on_mission_completed", function(self, mission_id)
	if MHiCS.settings.enabled and self:is_active() and (not self:has_failed()) and self:_is_host() then
		while #MHiCS.settings.last_missions >= MHiCS.settings.last_mission_limit do
			table.remove(MHiCS.settings.last_missions, 1)
		end
		table.insert(MHiCS.settings.last_missions, mission_id)
		MHiCS:Save()
	end
end)