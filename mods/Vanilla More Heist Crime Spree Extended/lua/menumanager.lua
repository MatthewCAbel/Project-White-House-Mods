---------------------------------------------- Localization ------------------------------------------------
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_MHiCS", function(loc)
	local loc_lang = BLT.Localization._current
	if loc_lang == 'cht' or BLT.Localization._current == 'zh-cn' then
		loc_lang = "ch"
	end
	for _, filename in pairs(file.GetFiles(MHiCS._path .. "loc/")) do
		local str = filename:match('^(.*).txt$')
		if str and loc_lang == str then
			loc:load_localization_file(MHiCS._path .. "loc/" .. filename)
			break
		end
	end

	loc:load_localization_file(MHiCS._path .. "loc/en.txt", false)
end)

----------------------- Callbacks ----------------------- 
local function MHiCS_impossible_selection()
	local dialog_data = {
		title = managers.localization:text("dialog_error_title"),
		text = managers.localization:text("MHiCS_about_to_imposs_desc")
	}
	local ok_button = {
		text = managers.localization:text("dialog_ok")
	}
	dialog_data.button_list = {
		ok_button
	}
	managers.system_menu:show(dialog_data)
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_MHiCS", function(menu_manager)
	MenuCallbackHandler.MHiCS_settings_changed_callback = function(this,item)
		local name = tostring(item._parameters["name"]):gsub("MHiCS_","")
		MHiCS.settings[name] = Utils:ToggleItemToBoolean(item)
		MHiCS:Save()
	end

	MenuCallbackHandler.MHiCS_deactivate_callback = function(this,item)
		if managers.crime_spree.is_active() then
			MHiCS_impossible_selection()
		else
			local dialog_data = {
				title = managers.localization:text("dialog_warning_title"),
				text = managers.localization:text("MHiCS_about_to_deact_desc")
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
			yes_button.callback_func = MenuCallbackHandler.MHiCS_confirm_deactivate_callback
			managers.system_menu:show(dialog_data)
		end
	end

	MenuCallbackHandler.MHiCS_confirm_deactivate_callback = function(this,item)
		local menu = MenuHelper:GetMenu("MHiCS_menu")
		for _, item in pairs (menu._items) do
			if item._parameters.name == "MHiCS_deactivate" then
				item:set_enabled(false)
			end
			if item._parameters.name == "MHiCS_reactivate" then
				item:set_enabled(true)
			end
		end
		MHiCS.settings.enabled = false
		MHiCS.settings.more = false
		MHiCS:set_correct_missions()
		MenuCallbackHandler:save_progress()
		MHiCS:Save()
	end

	MenuCallbackHandler.MHiCS_reactivate_callback = function(this,item)
		if managers.crime_spree.is_active() then
			MHiCS_impossible_selection()
		else
			local dialog_data = {
				title = managers.localization:text("dialog_warning_title"),
				text = managers.localization:text("MHiCS_about_to_react_desc")
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
			managers.system_menu:show(dialog_data)
		end
	end

	MenuCallbackHandler.MHiCS_confirm_reactivate_callback = function(this,item)
		local menu = MenuHelper:GetMenu("MHiCS_menu")
		for _, item in pairs (menu._items) do
			if item._parameters.name == "MHiCS_deactivate" then
				item:set_enabled(true)
			end
			if item._parameters.name == "MHiCS_reactivate" then
				item:set_enabled(false)
			end
		end
		MHiCS.settings.enabled = true
		MHiCS.settings.more = true
		MHiCS:set_correct_missions()
		MHiCS:Save()
	end
end)

----------------------- Menu Creation ----------------------- 
Hooks:Add("MenuManagerSetupCustomMenus", "Base_SetupCustomMenus_Json_MHiCS_menu", function( menu_manager, nodes )
	MenuHelper:NewMenu( "MHiCS_menu" )
end)

Hooks:Add("MenuManagerBuildCustomMenus", "Base_BuildCustomMenus_Json_MHiCS_menu", function( menu_manager, nodes )
	local parent_menu = "blt_options"
	local menu_id = "MHiCS_menu"
	local menu_name = "MHiCS_menu_title"
	local menu_desc = "MHiCS_menu_desc"

	local data = {
		focus_changed_callback = nil,
		area_bg = nil,
	}
	nodes[menu_id] = MenuHelper:BuildMenu( menu_id, data )

	MenuHelper:AddMenuItem( nodes[parent_menu], menu_id, menu_name, menu_desc, nil )

end)

Hooks:Add("MenuManagerPopulateCustomMenus", "Base_PopulateCustomMenus_Json_MHiCS_menu", function( menu_manager, nodes )
	local menu_id = "MHiCS_menu"
	MenuHelper:AddButton({
		id = "MHiCS_deactivate",
		title = "MHiCS_deactivate_button_title",
		desc = "MHiCS_deactivate_button_desc",
		callback = "MHiCS_deactivate_callback",
		menu_id = menu_id,
		priority = 2,
		localized = true,
		disabled = not MHiCS.settings.enabled
	})
	MenuHelper:AddButton({
		id = "MHiCS_reactivate",
		title = "MHiCS_reactivate_button_title",
		desc = "MHiCS_reactivate_button_desc",
		callback = "MHiCS_reactivate_callback",
		menu_id = menu_id,
		priority = 1,
		localized = true,
		disabled = MHiCS.settings.enabled
	})

end)

local function MHiCS_remove_only_MHiCS(node)
	for i=1,#node._items do
		if node._items[i]._parameters.name == "MHiCS_only_lobbies" then
			table.remove(node._items, i)
			return
		end
	end
end

local function MHiCS_insert_only_MHiCS(node)
	for _, it in pairs(node._items) do
		if it._parameters.name == "MHiCS_only_lobbies" then
			return
		end
	end
	local data = {
		type = "CoreMenuItemToggle.ItemToggle",
		{
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			value = "on",
			x = 24,
			y = 0,
			w = 24,
			h = 24,
			s_icon = "guis/textures/menu_tickbox",
			s_x = 24,
			s_y = 24,
			s_w = 24,
			s_h = 24
		},
		{
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			value = "off",
			x = 0,
			y = 0,
			w = 24,
			h = 24,
			s_icon = "guis/textures/menu_tickbox",
			s_x = 0,
			s_y = 24,
			s_w = 24,
			s_h = 24
		}
	}
	local params = {
		name = "MHiCS_only_lobbies",
		text_id = "MHiCS_toggle_only_title",
		help_id = "MHiCS_toggle_only_desc",
		callback = "MHiCS_settings_changed_callback",
		localize = true
	}

	local item = node:create_item(data, params)
	item:set_value(MHiCS.settings.only_lobbies and "on" or "off")
	item:set_callback_handler(node.callback_handler)
	for i=1,#node._items do
		if node._items[i]._parameters.name == "toggle_friends_only" then
			table.insert(node._items, i + 1, item)
			return
		end
	end
end

local MHiCS_old_crimenetfilters_modify_node = MenuCrimeNetFiltersInitiator.modify_node

function MenuCrimeNetFiltersInitiator:modify_node(original_node, data)
	local node = MHiCS_old_crimenetfilters_modify_node(self, original_node, data)
	if (Global.game_settings.gamemode_filter == GamemodeCrimeSpree.id or MHiCS.crimespree_lobby_everywhere) and MHiCS.settings.enabled then
		MHiCS_insert_only_MHiCS(node)
	else
		MHiCS_remove_only_MHiCS(node)
	end		
	return node
end