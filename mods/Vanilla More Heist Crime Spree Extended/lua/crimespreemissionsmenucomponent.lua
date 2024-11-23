local MHiCS_modify_node = MenuCrimeNetCrimeSpreeContractInitiator.modify_node
function MenuCrimeNetCrimeSpreeContractInitiator:modify_node(original_node, data)
	local node = MHiCS_modify_node(self, original_node, data)
	if not MHiCS.settings.enabled then
		return node
	end
	if not Global.game_settings.single_player then
		if data.job_id == "crime_spree" then
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
				name = "MHiCS_more",
				text_id = "MHiCS_toggle_lobby_title",
				help_id = "MHiCS_toggle_lobby_desc",
				callback = "MHiCS_settings_changed_callback",
				localize = true
			}
			local div_data = {
				type = "MenuItemDivider",
				size = 8,
				no_text = true,
			}
			local div_params = {
				name = "MHiCS_divider"
			}
			local div_item1 = node:create_item(div_data, div_params)
			local div_data2 = {
				type = "MenuItemDivider",
				size = 12,
				no_text = true,
			}
			local div_params2 = {
				name = "MHiCS_divider2"
			}
			local div_item2 = node:create_item(div_data2, div_params2)
			local item = node:create_item(data, params)
			item:set_value(MHiCS.settings.more and "on" or "off")
			item:set_callback_handler(node.callback_handler)
			for i=1,#node._items do
				if node._items[i]._parameters.name == "lobby_kicking_option" then
					table.insert(node._items, i, div_item1)
					table.insert(node._items, i + 1, item)
					table.insert(node._items, i + 2, div_item2)
					return node
				end
			end			
		end
	end

	return node
end

function CrimeSpreeMissionButton:_get_mission_category(mission)
	if mission.add <= 5 then
		return "short"
	elseif mission.add < 10 then
		return "medium"
	else
		return "long"
	end
end