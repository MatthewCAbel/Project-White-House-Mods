if not _G.MHiCS then
	local debug_short_add = 5
	local debug_med_add = 7
	local debug_long_add = 10
	_G.MHiCS = {}
	MHiCS.crimespree_lobby_everywhere = false
	MHiCS._path = ModPath
	MHiCS._data_path = SavePath .. "More_Heists_in_Crime_Spree.txt"
	MHiCS._instance = ModInstance
	MHiCS.version = MHiCS._instance:GetVersion()
	
	local BLT = rawget(_G, "BLT")
	if (BLT and BLT.Mods) then
		for _, mod in ipairs(BLT.Mods:Mods()) do
			local name = mod:GetId()
			if  name == "UNIfied CrimeNet" then
				MHiCS.crimespree_lobby_everywhere = true
			end
		end
	end

	function MHiCS:Load()
		local file = io.open(MHiCS._data_path, "r")
		if file then
			local decoded = json.decode(file:read("*all")) or {}
			if type(decoded) ~= "table" then
				return false
			end
			for k, v in pairs(decoded) do
				MHiCS.settings[k] = v
			end
			file:close()
			return MHiCS.settings.version == MHiCS.version
		end
		return false
	end

	function MHiCS:Save()
		local file = io.open(MHiCS._data_path, "w+")
		if file then
			file:write(json.encode(MHiCS.settings))
			file:close()
		end
	end

	function MHiCS:check_mission_in_list(mission_id, mission_list)
		for idx, data in pairs(mission_list) do
			if data.id == mission_id then
				return true
			end
		end
		return false
	end

	function MHiCS:check_data(avail_list, cat, mission_lists)
		if not (avail_list and avail_list[cat] and avail_list[cat].id) then
			return false
		end
		if not (mission_lists and mission_lists[cat]) then
			return false
		end

		return MHiCS:check_mission_in_list(avail_list[cat].id, mission_lists[cat])
	end

	function MHiCS:repair_heists(avail_miss)	
		local repaired = {}
		for i=1,3 do
			if MHiCS:check_data(avail_miss, i, tweak_data.crime_spree.missions) then
				table.insert(repaired, avail_miss[i])
			else
				table.insert(repaired, table.random(tweak_data.crime_spree.missions[i]))
			end
		end
		return repaired
	end

	function MHiCS:check_mission_list(crime_spree_manager)
		crime_spree_manager._global.available_missions = MHiCS:repair_heists(crime_spree_manager._global.available_missions)
	end

	function MHiCS:set_correct_missions(more_heists, isclient)
		if not isclient and not more_heists and MHiCS.settings.more then
			more_heists = true
		end
		if more_heists then
			tweak_data.crime_spree.missions = MHiCS.missions
		else
			tweak_data.crime_spree.missions = MHiCS.orig_missions
			MHiCS:check_mission_list(managers.crime_spree)
		end
		if not isclient then
			MHiCS:check_mission_list(managers.crime_spree)
		end
	end

	function MHiCS:default_values()
		if MHiCS.settings.enabled == nil then
			MHiCS.settings.enabled = true
		end
		if MHiCS.settings.only_lobbies == nil then
			MHiCS.settings.only_lobbies = false
		end
		if MHiCS.settings.more == nil then
			MHiCS.settings.more = true
		end
		if MHiCS.settings.last_mission_limit == nil then
			MHiCS.settings.last_mission_limit = 7
		end
		MHiCS.settings.version = MHiCS.version
		MHiCS.settings.last_missions = {}
	end

	-- Create a new network key
	function MHiCS:generate_network_key(MHiCS_originalkey)
		return MHiCS_originalkey .. "_MHiCS_" .. MHiCS.settings.version
	end

	MHiCS.settings = {}
	MHiCS:default_values()
	if not MHiCS:Load() then
		MHiCS:default_values()
		MHiCS:Save()
	end
	MHiCS.settings.more = MHiCS.settings.more and MHiCS.settings.enabled
	MHiCS.heists = {
		branchbank_cash = {assign = {1,2}, value = debug_short_add},
		cage = {assign = {1}, value = debug_short_add},
		kosugi = {assign = {1}, value = debug_short_add},
		dark = {assign = {1}, value = debug_short_add},
		firestarter_2 = {assign = {1,2}, value = debug_short_add},
		firestarter_3 = {assign = {3}, value = 7},
		hox_3 = {assign = {1,2}, value = 4},
		fish = {assign = {1}, value = 4},
		election_day_2 = {assign = {1,2}, value = 4},
		crojob1 = {assign = {1,2}, value = 8},
		framing_frame_1	= {assign = {3}, value = 7},
		framing_frame_2	= {assign = {3}, value = 7},
		framing_frame_3 = {assign = {1,2}, value = debug_med_add},
		arm_for = {assign = {1,2}, value = debug_med_add},
		friend = {assign = {1,2}, value = 8},
		big = {assign = {1,3}, value = 13},
		mus = {assign = {1,2,3}, value = debug_long_add},
		roberts = {assign = {1,2,3}, value = debug_long_add},
		red2 = {assign = {1,2,3}, value = debug_long_add},
		arena = {assign = {1,3}, value = 12},
		tag = {assign = {1}, value = debug_short_add},
		vit = {assign = {1,3}, value = 13},
		family = {assign = {1,2}, value = 6},
		kenaz = {assign = {1,3}, value = 13},
		jewelry_store = {assign = {1,2}, value = 4},
		ukrainian_job = {assign = {1,2}, value = debug_short_add},
		gallery = {assign = {1,2}, value = 4},
		welcome_to_the_jungle_1_d = {assign = {1,2}, value = 4},
		dah = {assign = {1,2}, value = 8},
		sah = {assign = {1,2}, value = debug_med_add},
		nightclub = {assign = {1,2}, value = debug_short_add},
		election_day_1 = {assign = {1}, value = 1},
		wwh = {assign = {2}, value = 8},
		rvd_1 = {assign = {2}, value = 8},
		rvd_2 = {assign = {2,3}, value = debug_long_add},
		brb = {assign = {2}, value = 8},
		arm_cro = {assign = {2}, value = debug_short_add},
		help = {assign = {2}, value = debug_short_add},
		arm_und = {assign = {2}, value = debug_short_add},
		arm_hcm = {assign = {2}, value = debug_short_add},
		arm_par = {assign = {2}, value = debug_short_add},
		arm_fac = {assign = {2}, value = debug_short_add},
		chew = {assign = {2}, value = 3},
		firestarter_1 = {assign = {2}, value = 4},
		nail = {assign = {2}, value = debug_short_add},
		watchdogs_1_d = {assign = {2}, value = 6},
		pines = {assign = {2}, value = debug_med_add},
		moon = {assign = {2}, value = debug_med_add},
		spa = {assign = {2}, value = 8},
		cane = {assign = {2}, value = 8},
		mia_2 = {assign = {2}, value = 8},
		mad = {assign = {2,3}, value = debug_long_add},
		mallcrasher = {assign = {2}, value = 4},
		shoutout_raid = {assign = {2}, value = 8},
		election_day_3 = {assign = {2}, value = 6},
		watchdogs_2_d = {assign = {2}, value = 6},
		pbr2 = {assign = {2,3}, value = 9},
		pal = {assign = {2,3}, value = 9},
		flat = {assign = {3}, value = 12},
		born = {assign = {2,3}, value = debug_long_add},
		hox_2 = {assign = {3}, value = 15},
		hox_1 = {assign = {2,3}, value = debug_long_add},
		welcome_to_the_jungle_2 = {assign = {3}, value = 14},
		mia_1 = {assign = {2,3}, value = debug_long_add},
		rat = {assign = {3}, value = 13},
		pbr = {assign = {2,3}, value = debug_long_add},
		glace = {assign = {3}, value = 12},
		run = {assign = {3}, value = 12},
		man = {assign = {2,3}, value = debug_long_add},
		dinner = {assign = {3}, value = 12},
		jolly = {assign = {3}, value = 12},
		chill_combat = {assign = {3}, value = 12},
		crojob2_d = {assign = {3}, value = 14},
		bph = {assign = {3}, value = 13},
		nmh = {assign = {3}, value = 13},
		des = {assign = {3}, value = 14},
		peta_1 = {assign = {3}, value = 14},
		peta_2 = {assign = {3}, value = 14},
		hvh = {assign = {2,3}, value = 5},
		alex_1 = {assign = {2,	3}, value = 12},
		alex_2 = {assign = {2,3}, value = 5},
		alex_3 = {assign = {3}, value = 7},
		haunted = {assign = {3}, value = 8},
		four_stores = {assign = {3}, value = 7},
	}
	MHiCS.heist_names = {}
	for heist, _ in pairs(MHiCS.heists) do
		table.insert(MHiCS.heist_names, heist)
	end
	MHiCS.heist_to_entry = {}
	for _, file in pairs(SystemFS:list(ModPath .. "guis/dlc/MHiCS")) do
		if not DB:has("texture", Idstring("guis/dlc/MHiCS/".. file:gsub(".texture", ""))) then
			DB:create_entry("texture", Idstring("guis/dlc/MHiCS/".. file:gsub(".texture", "")), ModPath .. "guis/dlc/MHiCS/" .. file)
		end
	end
	MHiCS.missions = {{}, {}, {}}
end

local function MHiCS_add_mission_to(self, tweak_data, mission_stage, mission_id, mission_icon)
	local heist = MHiCS.heists[mission_stage]
	local mission = {
		stage_id = mission_stage,
		id = mission_id,
		icon = mission_icon,
		add = heist.value,
		level = tweak_data.narrative.stages[mission_stage]
	}
	MHiCS.heist_to_entry[mission_stage] = mission
	for _, i in pairs(heist.assign) do
		table.insert(self.missions[i], mission)
	end
end

Hooks:PostHook(CrimeSpreeTweakData,"init_missions", "MHiCS_CrimeSpreeTweakData_init_missions", function(self, tweak_data)
	MHiCS.orig_missions = self.missions
	MHiCS_add_mission_to(MHiCS, tweak_data, "branchbank_cash", "bb_cash", "csm_branchbank")
	MHiCS_add_mission_to(MHiCS, tweak_data, "branchbank_cash", "bb_cash", "csm_branchbank")
	MHiCS_add_mission_to(MHiCS, tweak_data, "cage", "cage", "csm_carshop")
	MHiCS_add_mission_to(MHiCS, tweak_data, "kosugi", "kosugi", "csm_shadow_raid")
	MHiCS_add_mission_to(MHiCS, tweak_data, "dark", "dark", "csm_murky")
	MHiCS_add_mission_to(MHiCS, tweak_data, "firestarter_2", "fs_2", "csm_fs_2")
	MHiCS_add_mission_to(MHiCS, tweak_data, "hox_3", "hox_3", "csm_hoxvenge")
	MHiCS_add_mission_to(MHiCS, tweak_data, "fish", "fish", "csm_yacht")
	MHiCS_add_mission_to(MHiCS, tweak_data, "election_day_2", "ed_2", "csm_election_2")
	MHiCS_add_mission_to(MHiCS, tweak_data, "crojob1", "crojob1", "csm_docks")
	MHiCS_add_mission_to(MHiCS, tweak_data, "framing_frame_3", "framing_frame_3", "csm_framing_3")
	MHiCS_add_mission_to(MHiCS, tweak_data, "arm_for", "arm_for", "csm_train_forest") 	
	MHiCS_add_mission_to(MHiCS, tweak_data, "friend", "friend", "csm_friend")
	MHiCS_add_mission_to(MHiCS, tweak_data, "big", "big", "csm_big")
	MHiCS_add_mission_to(MHiCS, tweak_data, "mus", "mus", "csm_diamond")
	MHiCS_add_mission_to(MHiCS, tweak_data, "roberts", "roberts", "csm_go")
	MHiCS_add_mission_to(MHiCS, tweak_data, "red2", "red2", "csm_fwb")
	MHiCS_add_mission_to(MHiCS, tweak_data, "arena", "arena", "csm_alesso")
	MHiCS_add_mission_to(MHiCS, tweak_data, "tag", "tag", "csm_tag")
	MHiCS_add_mission_to(MHiCS, tweak_data, "vit", "vit", "csm_vit")
	MHiCS_add_mission_to(MHiCS, tweak_data, "family", "family", "csm_family")
	MHiCS_add_mission_to(MHiCS, tweak_data, "kenaz", "kenaz", "csm_kenaz")
	MHiCS_add_mission_to(MHiCS, tweak_data, "jewelry_store", "jewelry", "csm_jewelry")
	MHiCS_add_mission_to(MHiCS, tweak_data, "ukrainian_job", "ukrainian", "csm_jewelry")
	MHiCS_add_mission_to(MHiCS, tweak_data, "gallery", "gallery", "csm_gallery")
	MHiCS_add_mission_to(MHiCS, tweak_data, "welcome_to_the_jungle_1_d", "big_oil1", "csm_bigoil_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "dah", "dah", "csm_dah")
	MHiCS_add_mission_to(MHiCS, tweak_data, "sah", "sah", "csm_sah")
	MHiCS_add_mission_to(MHiCS, tweak_data, "nightclub", "nightclub", "csm_nightclub")
	MHiCS_add_mission_to(MHiCS, tweak_data, "election_day_1", "ed_1", "csm_election_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "wwh", "wwh", "csm_wwh")
	MHiCS_add_mission_to(MHiCS, tweak_data, "rvd_1", "rvd1", "csm_rvd_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "rvd_2", "rvd2", "csm_rvd_2")
	MHiCS_add_mission_to(MHiCS, tweak_data, "brb", "brb", "csm_brb")
	MHiCS_add_mission_to(MHiCS, tweak_data, "arm_cro", "arm_cro", "csm_crossroads")
	MHiCS_add_mission_to(MHiCS, tweak_data, "help", "help", "csm_prison")
	MHiCS_add_mission_to(MHiCS, tweak_data, "arm_und", "arm_und", "csm_overpass")
	MHiCS_add_mission_to(MHiCS, tweak_data, "arm_hcm", "arm_hcm", "csm_downtown")
	MHiCS_add_mission_to(MHiCS, tweak_data, "arm_par", "arm_par", "csm_park")
	MHiCS_add_mission_to(MHiCS, tweak_data, "arm_fac", "arm_fac", "csm_harbor")
	MHiCS_add_mission_to(MHiCS, tweak_data, "chew", "biker_2", "csm_biker_2")
	MHiCS_add_mission_to(MHiCS, tweak_data, "firestarter_1", "fs_1", "csm_fs_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "nail", "nail", "csm_labrats")
	MHiCS_add_mission_to(MHiCS, tweak_data, "watchdogs_1_d", "watchdogs_1_d", "csm_watchdogs_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "pines", "pines", "csm_white_xmas")
	MHiCS_add_mission_to(MHiCS, tweak_data, "moon", "moon", "csm_stealing_xmas")
	MHiCS_add_mission_to(MHiCS, tweak_data, "spa", "spa", "csm_brooklyn")
	MHiCS_add_mission_to(MHiCS, tweak_data, "cane", "cane", "csm_santas_workshop")
	MHiCS_add_mission_to(MHiCS, tweak_data, "mia_2", "mia_2", "csm_miami_2")
	MHiCS_add_mission_to(MHiCS, tweak_data, "mad", "mad", "csm_mad")
	MHiCS_add_mission_to(MHiCS, tweak_data, "mallcrasher", "mallcrasher", "csm_mall")
	MHiCS_add_mission_to(MHiCS, tweak_data, "shoutout_raid", "meltdown", "csm_meltdown")
	MHiCS_add_mission_to(MHiCS, tweak_data, "election_day_3", "ed_3", "csm_ed_3")
	MHiCS_add_mission_to(MHiCS, tweak_data, "watchdogs_2_d", "watchdogs_2_d", "csm_watchdogs_2")
	MHiCS_add_mission_to(MHiCS, tweak_data, "pbr2", "pbr2", "csm_sky")
	MHiCS_add_mission_to(MHiCS, tweak_data, "pal", "pal", "csm_counterfeit")
	MHiCS_add_mission_to(MHiCS, tweak_data, "flat", "flat", "csm_panic_room")
	MHiCS_add_mission_to(MHiCS, tweak_data, "born", "born", "csm_biker_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "hox_2", "hoxton_2", "csm_hoxout_2")
	MHiCS_add_mission_to(MHiCS, tweak_data, "hox_1", "hoxton_1", "csm_hoxout_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "welcome_to_the_jungle_2", "bo_2", "csm_bigoil_2")
	MHiCS_add_mission_to(MHiCS, tweak_data, "mia_1", "mia_1", "csm_miami_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "rat", "cook_off", "csm_rats_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "pbr", "pbr", "csm_mountain")
	MHiCS_add_mission_to(MHiCS, tweak_data, "glace", "glace", "csm_glace")
	MHiCS_add_mission_to(MHiCS, tweak_data, "run", "run", "csm_run")
	MHiCS_add_mission_to(MHiCS, tweak_data, "man", "man", "csm_undercover")
	MHiCS_add_mission_to(MHiCS, tweak_data, "dinner", "dinner", "csm_slaughterhouse")
	MHiCS_add_mission_to(MHiCS, tweak_data, "jolly", "jolly", "csm_aftershock")
	MHiCS_add_mission_to(MHiCS, tweak_data, "chill_combat", "chill_combat", "csm_saferaid")
	MHiCS_add_mission_to(MHiCS, tweak_data, "crojob2_d", "bomb_for", "csm_bomb_forest")
	MHiCS_add_mission_to(MHiCS, tweak_data, "bph", "bph", "csm_bph")
	MHiCS_add_mission_to(MHiCS, tweak_data, "nmh", "nmh", "csm_nmh")
	MHiCS_add_mission_to(MHiCS, tweak_data, "des", "des", "csm_des")
	MHiCS_add_mission_to(MHiCS, tweak_data, "peta_1", "goats_1", "csm_goats_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "peta_2", "goats_2", "csm_goats_2")
	MHiCS_add_mission_to(MHiCS, tweak_data, "hvh", "hvh", "csm_hvh")
	MHiCS_add_mission_to(MHiCS, tweak_data, "alex_1", "alex_1", "csm_rats1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "alex_2", "alex_2", "csm_rats2")
	MHiCS_add_mission_to(MHiCS, tweak_data, "alex_3", "alex_3", "csm_rats3")
	MHiCS_add_mission_to(MHiCS, tweak_data, "haunted", "haunted", "csm_haunted")
	MHiCS_add_mission_to(MHiCS, tweak_data, "four_stores", "four_stores", "csm_four_stores")
	MHiCS_add_mission_to(MHiCS, tweak_data, "firestarter_1", "fs_1", "csm_fs_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "firestarter_3", "fs_3", "csm_fs_3")
	MHiCS_add_mission_to(MHiCS, tweak_data, "framing_frame_1", "framing_frame_1", "csm_framing_frame_1")
	MHiCS_add_mission_to(MHiCS, tweak_data, "framing_frame_2", "framing_frame_2", "csm_framing_frame_2")
	if MHiCS.settings.enabled then
		self.missions =  MHiCS.missions
	end
end )
