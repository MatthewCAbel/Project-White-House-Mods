IndividualMasks = IndividualMasks or {}
IndividualMasks._path = ModPath
IndividualMasks._data_path = SavePath .. "CustomPreferredMasksSaveData.txt"
IndividualMasks._data = {}
IndividualMasks._data.character_masks = {}


function IndividualMasks:Save()
	if next(self._data) == nil then
		os.remove( self._data_path )
	else
		local file = io.open( self._data_path, "w+" )
		if file then
			file:write( json.encode( self._data ) )
			file:close()
		end
	end
end

function IndividualMasks:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end


function IndividualMasks:get_mask_data(mask_id)
	return {
		mask_id = mask_id,
		equipped = true,
		blueprint = {
			color = {
				id = "nothing"
			},
			pattern = {
				id = "no_color_no_material"
			},
			material = {
				id = "plastic"
			}
		}
	}
end

function IndividualMasks:populate_masks(character, data, gui)
	gui:populate_masks_new(data)
	local character_data = self._data.character_masks[character]
	if not character_data or not Global.blackmarket_manager.crafted_items.masks[character_data.slot] then
		character_data = {
			slot = 1
		}
	end
	for k, v in ipairs(data) do
		v.equipped = character_data.slot == v.slot
		if not v.empty_slot then
			v.buttons = {"m_equip"}
		end
	end
end

function IndividualMasks:create_pages(new_node_data, params, identifier, selected_slot, rows, columns, max_pages)
	local category = new_node_data.category
	rows = rows or 3
	columns = columns or 3
	max_pages = max_pages or 8
	local items_per_page = rows * columns
	local item_data
	local selected_tab = 1
	for page = 1, max_pages do
		local index = 1
		local start_i = 1 + items_per_page * (page - 1)
		item_data = {}
		for i = start_i, items_per_page * page do
			item_data[index] = i
			index = index + 1
			if i == selected_slot then
				selected_tab = page
			end
		end
		local name_id = managers.localization:to_upper_text("bm_menu_page", {
			page = tostring(page)
		})
		table.insert(new_node_data, {
			name = category,
			category = category,
			prev_node_data = false,
			start_i = start_i,
			allow_preview = true,
			name_localized = name_id,
			on_create_func = callback(self, self, "populate_" .. category, params),
			on_create_data = item_data,
			identifier = BlackMarketGui.identifiers[identifier],
			override_slots = {columns, rows}
		})
	end
	return selected_tab
end

function IndividualMasks:refresh_mask()
	if managers.menu_scene then
		local new_mask_data = managers.blackmarket:equipped_mask()
		managers.menu_scene:set_character_mask_by_id(new_mask_data.mask_id, new_mask_data.blueprint)
	end
end

function IndividualMasks:select_mask(character, data, gui)
	print("[IndividualMasks]:select_mask", index, data, gui)
	IndividualMasks._data.character_masks[character] = {
		name = data.name,
		slot = data.slot
	}
	gui:reload()
	IndividualMasks:refresh_mask()
	IndividualMasks:Save()
end

function IndividualMasks:can_display_menu()
	local in_lobby = managers and managers.network and managers.network.session  and managers.network:session() and managers.network:session():_local_peer_in_lobby()
	if game_state_machine:current_state_name() ~= "menu_main" or in_lobby then
		local options = {
			{
				text = managers.localization:text("IndividualMasks_ok_prompt"),
				is_cancel_button = true
			}
		}
		menu_title = managers.localization:text("IndividualMasks_menu_cannot_display")
		menu_msg = managers.localization:text("IndividualMasks_menu_cannot_display_desc")
		QuickMenu:new(menu_title,menu_msg,options):show()
		return false
	end
	return true
end

function IndividualMasks:back_to_the_menu(character)
	managers.menu:close_menu("menu_main")
	DelayedCalls:Add('IndividualMasks:back_to_the_menu', 0.1, function()
		managers.menu:open_menu("menu_main")
		--managers.menu:open_node("options")
		--managers.menu:open_node("blt_options")
		--managers.menu:open_node("IndividualMasks_menu_id")
	end)
end

function IndividualMasks:set_default_to_all()
	for character, mask_data in pairs(IndividualMasks._data.character_masks) do
		IndividualMasks._data.character_masks[character].slot = 1	
	end
	IndividualMasks:refresh_mask()
	IndividualMasks:Save()
end

function IndividualMasks:_preview_mask(data)
	managers.blackmarket:view_mask(data.slot)
	managers.menu:open_node("blackmarket_preview_mask_node", {})
end

function IndividualMasks:preview_mask_callback(data)
	self:_preview_mask(data)
end

function IndividualMasks:open_mask_category_menu(character)
	local new_node_data = {category = "masks"}
	local character_data = self._data.character_masks[character]
	if not character_data then
		character_data = {
			slot = 1
		}
	end
	local old_work_name = CriminalsManager.convert_new_to_old_character_workname(character)
	local selected_tab = self:create_pages(new_node_data, character, "mask", character_data.slot, tweak_data.gui.MASK_ROWS_PER_PAGE, tweak_data.gui.MASK_COLUMNS_PER_PAGE, tweak_data.gui.MAX_MASK_PAGES)
	new_node_data.can_move_over_tabs = true
	new_node_data.selected_tab = selected_tab
	new_node_data.scroll_tab_anywhere = true
	new_node_data.hide_detection_panel = true
	new_node_data.back_callback = callback(self, self, "back_to_the_menu")
	new_node_data.custom_callback = {
		m_equip = callback(self, self, "select_mask", character),		
	}
	new_node_data.topic_id = "IndividualMasks_choose_new_default_mask"
	new_node_data.topic_params = {
		CHARACTER = managers.localization:text("menu_"..tostring(old_work_name))
	}

	managers.menu:open_node("blackmarket_node", {new_node_data})
end



function IndividualMasks:get_custom_default_mask_data_by_character(character)
	local character_mask_data = IndividualMasks._data.character_masks[character]
	if not character_mask_data then
		return nil
	end	
	if not Global.blackmarket_manager.crafted_items.masks then
		managers.blackmarket:aquire_default_masks()
	end
	if not Global.blackmarket_manager.crafted_items.masks[character_mask_data.slot] then
		return nil
	end
	for slot, data in pairs(Global.blackmarket_manager.crafted_items.masks) do
		if data.mask_id ~= "character_locked" then
			if character_mask_data.slot and character_mask_data.slot == slot then
				return data, slot
			end
		end
	end
	return nil
end

function IndividualMasks:get_custom_default_mask_data()
	local session = managers.network and managers.network.session and managers.network:session()
	local peer = session and session:local_peer() or nil
	local character = managers.blackmarket:get_real_character(nil,peer and peer:id())
	local custom_default_mask_data, slot = IndividualMasks:get_custom_default_mask_data_by_character(character)			
	if custom_default_mask_data then 					
		return custom_default_mask_data, slot
	end
	return nil
end



function IndividualMasks:CreateMenu()
	local menu_title = managers.localization:text("IndividualMasks_menu_name")
	local menu_msg = managers.localization:text("IndividualMasks_menu_desc")
	local options = {}
	for num,character in pairs(tweak_data.criminals.characters) do
		local char_name = CriminalsManager.convert_old_to_new_character_workname(character.name) or character.name
		options[#options+1] = {
			text = managers.localization:text("menu_" .. character.name),
			callback = callback(self,self, "open_mask_category_menu", char_name)
		}
	end
	options[#options+1] = {
		text = managers.localization:text("IndividualMasks_quit_prompt"),
		is_cancel_button = true
	}
	
	if not IndividualMasks:can_display_menu() then
		return
	end

	QuickMenu:new(menu_title,menu_msg,options):show()
end

function IndividualMasks:PromptMenuDefault()
	local menu_title = managers.localization:text("IndividualMasks_prompt_default_title")
	local menu_msg = managers.localization:text("IndividualMasks_prompt_default_desc")
	local options = {
		{
			text = managers.localization:text("IndividualMasks_default_select_yes"),
			callback = callback(self, self, "set_default_to_all")
		},
		{
			text = managers.localization:text("IndividualMasks_default_select_no"),
			is_cancel_button = true
		}	
	}
	
	if not IndividualMasks:can_display_menu() then
		return
	end

	QuickMenu:new(menu_title,menu_msg,options):show()
end

local _BlackMarketManager_equip_mask = BlackMarketManager.equip_mask
function BlackMarketManager:equip_mask(slot)
	local result = _BlackMarketManager_equip_mask(self, slot)
	if result then
		local new_mask_data = Global.blackmarket_manager.crafted_items.masks[slot]
		if managers.menu_scene and new_mask_data.mask_id == "character_locked" then
			IndividualMasks:refresh_mask()
		end
	end
	return result
end



local _BlackMarketManager_equipped_mask = BlackMarketManager.equipped_mask
function BlackMarketManager:equipped_mask()
	local mask_data = _BlackMarketManager_equipped_mask(self)
	if mask_data and mask_data.mask_id == "character_locked" then
		local custom_default_mask_data = IndividualMasks:get_custom_default_mask_data()	
		if custom_default_mask_data then 					
			return custom_default_mask_data
		end
	end
	return mask_data
end

local _BlackMarketManager_view_mask = BlackMarketManager.view_mask
function BlackMarketManager:view_mask(slot)
	if self._global.crafted_items.masks and self._global.crafted_items.masks[slot] then
		if Global.blackmarket_manager.crafted_items.masks then
			local mask_data = Global.blackmarket_manager.crafted_items.masks[slot]
			if mask_data and mask_data.mask_id == "character_locked" then
				local _, custom_default_mask_slot = IndividualMasks:get_custom_default_mask_data()
				if custom_default_mask_slot then 					
					slot = custom_default_mask_slot
				end
			end
		end
	end
	_BlackMarketManager_view_mask(self, slot)
end

Hooks:Add("MenuManagerOnOpenMenu", "MenuManagerOnOpenMenu_IndividualMasks", function( menu_manager, menu, position )

	if menu == "menu_main" then
		DelayedCalls:Add('IndividualMasks:back_to_the_menu', 0.2, function()
			IndividualMasks:refresh_mask()
		end)
	end

end)

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_IndividualMasks", function( loc )
	loc:load_localization_file( IndividualMasks._path .. "loc/en.txt")
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_IndividualMasks", function(menu_manager)
	MenuCallbackHandler.clbk_IndividualMasks_open_open_mask_category_menu_custom = function(self,item)
		IndividualMasks:CreateMenu()
	end
	MenuCallbackHandler.clbk_IndividualMasks_set_all_to_default = function(self,item)
		IndividualMasks:PromptMenuDefault()
	end
	MenuCallbackHandler.callback_IndividualMasks_close = function(self,item)
		IndividualMasks:Save()
	end
	IndividualMasks:Load()
	MenuHelper:LoadFromJsonFile(IndividualMasks._path .. "menu/options.txt", IndividualMasks, IndividualMasks._data)
end)