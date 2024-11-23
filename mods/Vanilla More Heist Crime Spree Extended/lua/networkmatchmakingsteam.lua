local MHiCS_otherkey
local MHiCS_originalkey
local MHiCS_combined_info

local function clear_combined_info()
	MHiCS_combined_info = {}
	MHiCS_combined_info.room_list = {}
	MHiCS_combined_info.attribute_list = {}
end

local function copy_to_combined(info, max_rooms)
	if not max_rooms then
		max_rooms = #MHiCS_combined_info.room_list + #info.room_lost + 1
	end
	for i=1,#info.room_list do
		if #MHiCS_combined_info.room_list < max_rooms then
			table.insert(MHiCS_combined_info.room_list, info.room_list[i])
			table.insert(MHiCS_combined_info.attribute_list, info.attribute_list[i])
		end
	end
end


function NetworkMatchMakingSTEAM:register_callback(event, callback)
	if event == "search_lobby" then
		event = "MHiCS_proxy_search_lobby"
	end
	self._callback_map[event] = callback
end

local MHiCS_old_search_lobby
local MHiCS_search_lobby = function (self, friends_only, no_filters)
	local MHiCS_double_dip = false
	clear_combined_info()

	if MHiCS_originalkey ~= NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY and 
					MHiCS_otherkey ~= NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY then
		MHiCS_originalkey = NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY
	end

	local function MHiCS_proxy(info)
		self._callback_map["search_lobby"] = nil
		if not MHiCS.settings.enabled then
			self:_call_callback("MHiCS_proxy_search_lobby", info)
			return
		end
		copy_to_combined(info, self._lobby_return_count)
		if MHiCS_double_dip then
			for _, attributes in ipairs(info.attribute_list) do
				attributes.one_down = "MHiCS"
			end
			MHiCS_double_dip = false
			NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = MHiCS_originalkey
			if MHiCS.settings.only_lobbies then
				self:_call_callback("MHiCS_proxy_search_lobby", MHiCS_combined_info)
			else
				self._callback_map["search_lobby"] = MHiCS_proxy
				MHiCS_old_search_lobby(self, friends_only, no_filters)
			end
		else
			self:_call_callback("MHiCS_proxy_search_lobby", MHiCS_combined_info)
		end
	end
	if not self._callback_map["MHiCS_proxy_search_lobby"] then
		return
	end
	if not self._callback_map["search_lobby"] then
		self._callback_map["search_lobby"] = MHiCS_proxy
	end
	if (Global.game_settings.gamemode_filter == GamemodeCrimeSpree.id or MHiCS.crimespree_lobby_everywhere) and MHiCS.settings.enabled then
		MHiCS_double_dip = true
		NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = MHiCS_otherkey
	else
		NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = MHiCS_originalkey
	end
	MHiCS_old_search_lobby(self, friends_only, no_filters)
end



local MHiCS_old_set_attributes
local MHiCS_set_attributes = function (self, settings)
	if MHiCS_originalkey ~= NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY and 
				MHiCS_otherkey ~= NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY then
		MHiCS_originalkey = NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY
	end
	log("START_MHICS_COPY")
	log(MHiCS_originalkey)
	log(MHiCS_otherkey)
	if managers.crime_spree:is_active() then
		if MHiCS.settings.more and MHiCS.settings.enabled then
			NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = MHiCS_otherkey
		else
			NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = MHiCS_originalkey
		end
		MHiCS:set_correct_missions()
	else
		NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = MHiCS_originalkey
	end
	log(NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY)
	MHiCS_old_set_attributes(self, settings)
	NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY = MHiCS_originalkey
	log("END_MHICS_COPY")
end

local MHiCS_old_join_server_with_check
local MHiCS_join_server_with_check = function(self, room_id, is_invite)
	if MHiCS_originalkey ~= NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY and 
				MHiCS_otherkey ~= NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY then
		MHiCS_originalkey = NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY
	end
	managers.menu:show_joining_lobby_dialog()

	local lobby = Steam:lobby(room_id)

	local function empty()
	end

	local function f()
		lobby:setup_callback(empty)

		local attributes = self:_lobby_to_numbers(lobby)

		if NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY then
			local ikey = lobby:key_value(MHiCS_originalkey)
			if ikey == "value_missing" or ikey == "value_pending" then
				ikey = lobby:key_value(MHiCS_otherkey)
				if ikey == "value_missing" or ikey == "value_pending" or (not MHiCS.settings.enabled) then
					-- really ugly but just to make sure connecting still works
					-- if there is a second mod modifying _BUILD_SEARCH_INTEREST_KEY
					managers.system_menu:close("join_server")
					MHiCS_old_join_server_with_check(self, room_id, is_invite)
					return
				end
			end
		end

		local server_ok, ok_error = self:is_server_ok(nil, room_id, {
			numbers = attributes
		}, is_invite)

		if server_ok then
			self:join_server(room_id, true)
		else
			managers.system_menu:close("join_server")

			if ok_error == 1 then
				managers.menu:show_game_started_dialog()
			elseif ok_error == 2 then
				managers.menu:show_game_permission_changed_dialog()
			elseif ok_error == 3 then
				managers.menu:show_too_low_level()
			elseif ok_error == 4 then
				managers.menu:show_does_not_own_heist()
			elseif ok_error == 5 then
				managers.menu:show_heist_is_locked_dialog()
			elseif ok_error == 6 then
				managers.menu:show_crime_spree_locked_dialog()
			end

			self:search_lobby(self:search_friends_only())
		end
	end

	lobby:setup_callback(f)
	lobby:key_value(MHiCS_originalkey)
	lobby:key_value(MHiCS_otherkey)
	if lobby:key_value("state") == "value_pending" then
		lobby:request_data()
	else
		f()
	end
end

--- Make sure we are run last
local function MHiCS_setup_network_values()
	MHiCS_old_search_lobby = NetworkMatchMakingSTEAM.search_lobby
	NetworkMatchMakingSTEAM.search_lobby = MHiCS_search_lobby
	MHiCS_originalkey = NetworkMatchMakingSTEAM._BUILD_SEARCH_INTEREST_KEY
	MHiCS_otherkey = MHiCS:generate_network_key(MHiCS_originalkey)
	MHiCS_old_set_attributes = NetworkMatchMakingSTEAM.set_attributes
	NetworkMatchMakingSTEAM.set_attributes = MHiCS_set_attributes
	MHiCS_old_join_server_with_check = NetworkMatchMakingSTEAM.join_server_with_check
	NetworkMatchMakingSTEAM.join_server_with_check = MHiCS_join_server_with_check
end

DelayedCalls:Add( "MHiCS_setup_network_values", 2, MHiCS_setup_network_values )