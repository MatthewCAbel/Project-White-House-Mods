local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local modpath = ModPath

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_RefreshRateChecker', function(loc)
	local language_filename

	for _, filename in pairs(file.GetFiles(modpath .. 'loc/')) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			language_filename = filename
			break
		end
	end

	if language_filename then
		loc:load_localization_file(modpath .. 'loc/' .. language_filename)
	end
	loc:load_localization_file(modpath .. 'loc/english.txt', false)
end)

local selected_resolution = RenderSettings.resolution

function MenuCallbackHandler:select_resolution(item)
	selected_resolution = item:parameters().resolution
	managers.menu:active_menu().logic:refresh_node()
end

function MenuCallbackHandler:is_selected_resolution(item)
	local res = item:parameters().resolution
	return res and res.x == selected_resolution.x and res.y == selected_resolution.y
end

function MenuCallbackHandler:is_current_resolution(item)
	local res = item:parameters().resolution
	if res == RenderSettings.resolution then
		return true
	end
	if item:name() == ('%d x %d'):format(RenderSettings.resolution.x, RenderSettings.resolution.y) then
		return true
	end
	return false
end

function MenuResolutionCreator:modify_node(node)
	local new_node = deep_clone(node)

	local modes = RenderSettings.modes
	table.sort(modes)
	for _, res in ipairs(modes) do
		local res_string = ('%d x %d'):format(res.x, res.y)
		if not new_node:item(res_string) then
			local params = {
				callback = 'select_resolution',
				localize = false,
				icon = 'guis/textures/scrollarrow',
				icon_rotation = 90,
				icon_visible_callback = 'is_current_resolution',
				name = res_string,
				text_id = res_string,
				resolution = res
			}

			local new_item = new_node:create_item(nil, params)
			new_node:add_item(new_item)
		end

		local params = {
			callback = 'change_resolution',
			localize = false,
			icon = 'guis/textures/scrollarrow',
			icon_rotation = 90,
			icon_visible_callback = 'is_current_resolution',
			visible_callback = 'is_selected_resolution',
			name = ('%d x %d (%d Hz)'):format(res.x, res.y, res.z),
			text_id = res.z .. ' Hz',
			resolution = res
		}

		local new_item = new_node:create_item(nil, params)
		new_node:add_item(new_item)
	end

	managers.menu:add_back_button(new_node)

	return new_node
end

if Global.load_start_menu ~= false then
	local best_rate = selected_resolution.z
	for _, res in ipairs(RenderSettings.modes) do
		if res.x == selected_resolution.x and res.y == selected_resolution.y then
			if res.z > best_rate then
				best_rate = res.z
			end
		end
	end

	if best_rate > selected_resolution.z then
		DelayedCalls:Add('DelayedRRC_notification', 0, function()
			BLT.Notifications:add_notification({
				title = managers.localization:text('rrc_notif_title'),
				text = managers.localization:text('rrc_notif_msg', { rate1 = best_rate, rate2 = selected_resolution.z }),
				priority = 2000
			})
		end)
	end
end

local rrc_original_bltnotificationsgui_mousepressed = BLTNotificationsGui.mouse_pressed
function BLTNotificationsGui:mouse_pressed(button, x, y)
	if not self._enabled or button ~= Idstring('0') then
		return
	end

	if alive(self._content_panel) and self._content_panel:inside(x, y) then
		local current = self._notifications[self._current]
		local params = current and current.parameters
		if params and params.title == managers.localization:text('rrc_notif_title') then
			managers.menu:open_node('resolution')
			managers.menu_component:post_event('menu_enter')
			BLT.Notifications:remove_notification(current.id)
			return true
		end
	end

	return rrc_original_bltnotificationsgui_mousepressed(self, button, x, y)
end
