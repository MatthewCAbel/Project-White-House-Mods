local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

dofile(ModPath .. 'lua/_breakpoints.lua')
dofile(ModPath .. 'lua/_chart.lua')
dofile(ModPath .. 'lua/_difficulty_picker.lua')

DB:create_entry(
	Idstring('texture'),
	Idstring('guis/textures/mws/stances_atlas'),
	ModPath .. 'assets/stances_atlas.texture'
)

local _dlc_info_patched = false
local _henchmen_weapon = false

local mws_original_blackmarketguislotitem_init = BlackMarketGuiSlotItem.init
function BlackMarketGuiSlotItem:init(main_panel, data, x, y, w, h)
	mws_original_blackmarketguislotitem_init(self, main_panel, data, x, y, w, h)

	if self._data.equipped then
		DelayedCalls:Add('DelayedModMWS_blackmarketguislotitem_init', 0, function()
			if alive(self.rect_bg) then
				self.rect_bg:set_color(Color.black)
				self.rect_bg:set_alpha(0.4)
				self.rect_bg:set_visible(true)
			end
		end)
	end
end

local mws_original_blackmarketgui_close = BlackMarketGui.close
function BlackMarketGui:close()
	if alive(self.mws_range_charts_floating_text) then
		self.mws_range_charts_floating_text:parent():remove(self.mws_range_charts_floating_text)
	end

	mws_original_blackmarketgui_close(self)
end

function BlackMarketGuiSlotItem:mws_change_text_visibility(state)
	if not MoreWeaponStats.settings.show_dlc_info then
		return
	end

	local equipped_text = self._panel:child('equipped_text')
	if alive(equipped_text) then
		equipped_text:set_visible(state)
	end

	local custom_name_text = self._panel:child('custom_name_text')
	if alive(custom_name_text) then
		custom_name_text:set_visible(state)
	end
end

local mws_original_blackmarketgui_select = BlackMarketGuiSlotItem.select
function BlackMarketGuiSlotItem:select(...)
	if _dlc_info_patched then
		self:mws_change_text_visibility(false)
	end
	return mws_original_blackmarketgui_select(self, ...)
end

local mws_original_blackmarketgui_deselect = BlackMarketGuiSlotItem.deselect
function BlackMarketGuiSlotItem:deselect(...)
	mws_original_blackmarketgui_deselect(self, ...)
	self:mws_change_text_visibility(true)
end

local mws_original_blackmarketgui_updateborders = BlackMarketGui._update_borders
function BlackMarketGui:_update_borders()
	mws_original_blackmarketgui_updateborders(self)

	if self._tabs[self._selected]._data.identifier == self.identifiers.weapon then
		self:mws_set_bonus_availability()

		local back_button = self._panel:child('back_button')
		back_button:set_right(self._box_panel:right())
		if self._detection_panel:visible() then
			self._detection_panel:set_right(back_button:left() - 8)
			self._detection_panel:set_center_y(back_button:center_y())
			self._detection_border:hide()
		end

		if self._btn_panel then
			self._btn_panel:set_bottom(self._panel:bottom())
		end

		local wh = self._weapon_info_panel:h()

		local weapon_info_height = self._panel:bottom() - (self._button_count > 0 and self._btn_panel:h() + 8 or 0) - self._weapon_info_panel:top()
		self._weapon_info_panel:set_h(weapon_info_height)
		self._stats_panel:set_h(weapon_info_height - self._stats_panel:top())
		self._rweapon_stats_panel:set_h(weapon_info_height)
		self._info_texts_panel:set_h(weapon_info_height - 20)

		if wh ~= self._weapon_info_panel:h() then
			self._weapon_info_border:create_sides(self._weapon_info_panel, { sides = { 1, 1, 1, 1 } })
		end
	end
end

local mws_original_blackmarketgui_setinfotext = BlackMarketGui.set_info_text
function BlackMarketGui:set_info_text(id, new_string, resource_color)
	if id == 2 then
		if self.mws_breakpoints and self.mws_bp_current_damage then
			self.mws_text2 = string.gsub(new_string, '##', '')
			new_string = ('%s %.2f'):format(utf8.to_upper(managers.localization:text('bm_menu_damage')), self.mws_bp_current_damage)
			self._info_texts[2]:set_h(20)
		end
	end

	mws_original_blackmarketgui_setinfotext(self, id, new_string, resource_color)

	if self._tabs[self._selected]._data.identifier == self.identifiers.weapon then
		if id == 3 or id == 5 then
			self._info_texts[id]:set_visible(false)
		end
	end
end

function BlackMarketGui:mws_is_buying()
	local identifier = self._tabs[self._selected]._data.identifier
	if identifier == self.identifiers.weapon then
		return not not self._data.buying_weapon
	elseif identifier == self.identifiers.masks then
		return self._data.topic_id == 'bm_menu_buy_mask_title'
	else
		return false
	end
end

local mws_original_blackmarketgui_updateinfotext = BlackMarketGui.update_info_text
function BlackMarketGui:update_info_text()
	mws_original_blackmarketgui_updateinfotext(self)

	if alive(self.mws_dlc_info_text) then
		local selected_slot_panel = self._selected_slot._panel
		self.mws_dlc_info_text:set_w(selected_slot_panel:w())
		self.mws_dlc_info_text:set_x(selected_slot_panel:world_left())
		self.mws_dlc_info_text:set_font_size(tweak_data.menu.pd2_tiny_font_size - 3)

		if self._selected_slot._data.empty_slot then
			self.mws_dlc_info_text:set_bottom(selected_slot_panel:world_bottom())
		else
			self.mws_dlc_info_text:set_top(selected_slot_panel:world_top() + 6)
		end

		if self._selected_slot then
			local scroll_bar = self._tabs[self._selected]._scroll_bar_panel:child("scroll_bar")
			self.mws_dlc_info_text:set_visible(selected_slot_panel:center_y() > scroll_bar:y() and MoreWeaponStats.settings.show_dlc_info)
		end

		self.mws_dlc_info_text_bg:set_shape(self.mws_dlc_info_text:shape())
	end
end

function BlackMarketGui:mws_realign_rcells(panel)
	for _, line in pairs(panel:children()) do
		if type(line.children) == 'function' then
			for _, cell in ipairs(line:children()) do
				if cell:width() == 45 then
					local left = cell:left()
					cell:set_left(left + 5 * (1 + (left - 100 - (left == 190 and 0 or 2)) / 45) + (left == 190 and 2 or 0))
				end
			end
		end
	end
end

function BlackMarketGui:mws_get_bottom(panel)
	local y = 0
	local lines_nr = 0

	for _, line in ipairs(panel:children()) do
		if type(line.bottom) == 'function' and line:alpha() > 0 then
			y = math.max(y, line:bottom())
			lines_nr = lines_nr + 1
		end
	end

	return y, lines_nr
end

local mws_original_blackmarketgui_setup = BlackMarketGui._setup
function BlackMarketGui:_setup(is_start_page, component_data)
	_dlc_info_patched = false
	_henchmen_weapon = false
	if component_data then
		if component_data.buying_weapon then
			_henchmen_weapon = not not (not component_data[1].on_create_func_name and component_data[1].on_create_func)
		elseif component_data.category == 'primaries' or component_data.category == 'secondaries' then
			_henchmen_weapon = not not component_data.custom_callback
		end
		if component_data.category == 'primaries'
		or component_data.category == 'secondaries'
		or component_data.topic_id == 'bm_menu_melee_weapons'
		or component_data.topic_id == 'bm_menu_buy_weapon_title'
		then
			_dlc_info_patched = true
		end
	end

	mws_original_blackmarketgui_setup(self, is_start_page, component_data)

	-- stats extension
	self.mws_stats_shown = nil
	local base_panel
	local text_columns = {}
	local identifier = self._tabs[self._selected]._data.identifier

	if self._mweapon_stats_panel and identifier == self.identifiers.melee_weapon then
		base_panel = self._mweapon_stats_panel

		self.mws_stats_shown = {
			{ name = 'mws_attack_delay' },
			{ name = 'mws_cooldown' },
			{ name = 'mws_unequip_delay' },
			{ name = 'mws_special' },
			{ name = 'mws_dot_length' }
		}

		text_columns = {
			{ size = 100, name = 'name' },
			{ size = 55, align = 'right', alpha = 0.75, blend = 'add', name = 'a1' },
			{ size = 88, align = 'right', alpha = 0.75, blend = 'add', name = 'a2' },
		}
	end

	-- move dlc info in slot item
	if _dlc_info_patched then
		local dlc_text = self._info_texts[4]
		if dlc_text then
			self.mws_dlc_info_text = self._panel:text({
				text = dlc_text:text(),
				wrap = dlc_text:wrap(),
				name = dlc_text:name(),
				word_wrap = dlc_text:word_wrap(),
				layer = 10,
				font_size = tweak_data.menu.pd2_tiny_font_size - 3,
				font = tweak_data.menu.pd2_small_font,
				color = dlc_text:color(),
				width = dlc_text:w(),
				align = 'center'
			})
			self._info_texts[4] = self.mws_dlc_info_text
			dlc_text:parent():remove(dlc_text)

			self.mws_dlc_info_text_bg = self._panel:rect({
				alpha = 0.2,
				visible = false,
				layer = 0,
				color = Color.black
			})
		end
	end

	if self._rweapon_stats_panel and identifier == self.identifiers.weapon then
		base_panel = self._rweapon_stats_panel
		for i, s in pairs(self._stats_shown) do
			local name = s.name
			if name == 'reload' or name == 'optimal_range' then
				self._rweapon_stats_panel:children()[i]:set_alpha(0)
			elseif _henchmen_weapon then
				if name == 'damage' or name == 'spread' or name == 'recoil' or name == 'concealment' or name == 'suppression' or name == 'totalammo' or name == 'fire_rate' then
					self._rweapon_stats_panel:children()[i]:set_alpha(0)
				end
			end
		end

		if _henchmen_weapon then
			self.mws_stats_shown = {
				{ name = 'mws_spread', fct = self.mws_spread_bot },
				{ name = 'mws_rof', fct = self.mws_rof_bot },
				{ name = 'mws_autorounds', fct = self.mws_autorounds_bot },
				{ name = 'mws_reload_full', fct = self.mws_reload_bot },
				{ name = 'mws_aim_delay', fct = self.mws_aim_delay_bot },
			}

			local dis = {}
			for k, v in pairs(tweak_data.character.russian.weapon) do
				if v.FALLOFF then
					for _, f in ipairs(v.FALLOFF) do
						if f.r then
							dis[f.r] = f.r
						end
					end
				end
			end
			dis = table.map_values(dis)
			table.sort(dis, function(a, b) return a < b end)
			for _, d in ipairs(dis) do
				local clbk = function(...)
					local params = {...}
					table.insert(params, d)
					self.mws_falloff_bot(unpack(params))
				end
				table.insert(self.mws_stats_shown, {
					name = 'mws_damage_hitchance',
					text_name = 'mws_damage_hitchance_' .. d,
					fct = clbk,
					macros = { DIS = d / 100 }
				} )
			end

		else
			self.mws_stats_shown = {
				{ name = 'mws_reload_partial', fct = self.mws_reload_partial },
				{ name = 'mws_reload_full', fct = self.mws_reload_full },
				{ name = 'mws_equip_delay', fct = self.mws_equip_delay },
				{ name = 'mws_ammo_pickup', fct = self.mws_ammo_pickup },
				{ name = 'mws_recoil_horiz', fct = self.mws_recoil_horiz },
				{ name = 'mws_recoil_vert', fct = self.mws_recoil_vert },
				{ name = 'mws_spread', fct = self.mws_spread_horiz },
				{ name = 'mws_spread_vert', fct = self.mws_spread_vert }, -- for donald's horizontal leveller, or not
				{ name = 'mws_falloff', fct = self.mws_falloff },
			}
		end

		text_columns = {
			{ size = 100, name = 'name' },
			{ size = 50, align = 'right', alpha = 0.75, blend = 'add', name = 'a1' },
			{ size = 50, align = 'left', alpha = 0.75, blend = 'add', name = 'b1' },
			{ size = 50, align = 'right', alpha = 0.75, blend = 'add', name = 'a2' },
			{ size = 50, align = 'left', alpha = 0.75, blend = 'add', name = 'b2' },
		}
	end

	local y_stat_line
	if self.mws_stats_shown then
		local lines_nr
		y_stat_line, lines_nr = self:mws_get_bottom(base_panel)
		local oddeven = math.mod(lines_nr, 2)

		self.mws_stats_texts = {}
		
		for i, stat in ipairs(self.mws_stats_shown) do
			if MoreWeaponStats.settings.display[stat.name:sub(5, -1)] == false then
				goto continue
			end

			local panel = base_panel:panel({
				layer = 1,
				x = 0,
				y = y_stat_line,
				w = base_panel:w(),
				h = 20
			})
			if math.mod(i, 2) == oddeven and not panel:child(tostring(i)) then
				panel:rect({
					color = Color.black:with_alpha(0.3)
				})
			end

			y_stat_line = y_stat_line + 20
			local x = 2
			local text_name = stat.text_name or stat.name
			self.mws_stats_texts[text_name] = {}
			for i, column in ipairs(text_columns) do
				local text_panel = panel:panel({
					layer = 0,
					x = x,
					w = column.size,
					h = panel:h()
				})
				self.mws_stats_texts[text_name][column.name] = text_panel:text({
					text = i == 1 and managers.localization:to_upper_text(stat.name, stat.macros) or nil,
					font_size = tweak_data.menu.pd2_small_font_size,
					font = tweak_data.menu.pd2_small_font,
					align = column.align,
					layer = 1,
					alpha = column.alpha,
					blend_mode = column.blend,
					color = column.color or tweak_data.screen_colors.text
				})
				x = x + column.size
			end
			::continue::
		end
	end

	-- add components
	if self._rweapon_stats_panel and identifier == self.identifiers.weapon and not _henchmen_weapon then
		-- stances
		self.mws_in_steelsight = false
		self.mws_ducking = false

		self.mws_stances_panel = self._stats_panel:panel({
			visible = true,
			x = 0,
			layer = 1,
			w = self._stats_panel:w(),
			h = 64
		})
		self.mws_stances_panel:set_top(y_stat_line + 10)

		local stance_text = self.mws_stances_panel:text({
			name = 'mws_stance',
			align = 'center',
			vertical = 'center',
			text = utf8.to_upper(managers.localization:text('mws_stance')),
			font_size = 12,
			font = tweak_data.menu.pd2_small_font,
			color = MoreWeaponStats.stance_color,
			x = 2,
			y = 0,
			w = 200,
			h = self.mws_stances_panel:h()
		})
		local _, _, w, _ = stance_text:text_rect()
		stance_text:set_w(w)

		self.mws_stances_bitmaps = {}
		local top = -32
		local left = stance_text:right() + 10
		local visible = true
		for y = 0, 64, 64 do
			for x = 0, 64, 64 do
				table.insert(self.mws_stances_bitmaps, self.mws_stances_panel:bitmap({
					x = left,
					y = top,
					texture = 'guis/textures/mws/stances_atlas',
					color = MoreWeaponStats.stance_color,
					blend_mode = 'add',
					layer = 1,
					texture_rect = { x, y, 64, 64 },
					w = 64,
					h = 64,
					alpha = 1,
					visible = visible,
				}))
				visible = not visible
			end
			top = top + 64
		end

		-- damage range modifier
		self.mws_range_charts = {
			SimpleChart:new(self.mws_stances_panel, 105, 0, 100, self.mws_stances_panel:h(), self.mws_stances_panel:h() / 2),
			SimpleChart:new(self.mws_stances_panel, 210, 0, 100, self.mws_stances_panel:h(), self.mws_stances_panel:h() / 2),
		}
		self.mws_range_charts_floating_text = self.mws_range_charts_floating_text or self.mws_stances_panel:root():text({
			layer = 100000000000,
			visible = false,
			align = 'right',
			vertical = 'top',
			text = '',
			font_size = tweak_data.menu.pd2_small_font_size,
			font = tweak_data.menu.pd2_small_font,
			color = tweak_data.screen_colors.risk,
			blend_mode = 'normal',
			x = 0,
			y = 0,
			w = 200,
			h = 40
		})

		-- breakpoints key
		if MoreWeaponStats.settings.use_preview_to_switch_breakpoints then
			local preview_btn = self._btns.w_preview
			preview_btn._data.pc_btn = nil
			preview_btn._pc_btn = nil
		end

		-- show/hide breakpoints buttons
		self.mws_bp_switch_panel = self._panel:panel({
			w = self._buttons:w(),
			h = 30,
		})
		self.mws_bp_switch_panel:set_bottom(self._weapon_info_panel:y() + 2)
		self.mws_bp_switch_panel:set_right(self._panel:w())

		local prio = self.si_extra_button_added and 2 or 1
		local btn_data = {
			prio = prio,
			name = 'mws_bp_show',
			pc_btn = 'menu_preview_item',
			callback = callback(self, self, 'mws_bp_show_callback')
		}
		self.mws_bp_show_btn = BlackMarketGuiButtonItem:new(self.mws_bp_switch_panel, btn_data, 10)
		self.mws_bp_show_btn._data.prio = 5 -- ugly trick for double-click
		self._btns['mws_bp_show'] = self.mws_bp_show_btn

		btn_data = {
			prio = prio,
			name = 'mws_bp_hide',
			pc_btn = 'menu_preview_item',
			callback = callback(self, self, 'mws_bp_hide_callback')
		}
		self.mws_bp_hide_btn = BlackMarketGuiButtonItem:new(self.mws_bp_switch_panel, btn_data, 10)
		self.mws_bp_hide_btn._data.prio = 5
		self._btns['mws_bp_hide'] = self.mws_bp_hide_btn

		self:show_btns(self._selected_slot)

		-- breakpoints
		self.mws_bp_panel = self._weapon_info_panel:panel({
			visible = false,
			y = 58,
			x = 10,
			layer = 1,
			w = self._weapon_info_panel:w() - 20,
			h = self._weapon_info_panel:h() - 84
		})

		-- checkable bonuses
		self.mws_bp_bonus_panel = self.mws_bp_panel:panel({
			y = 0,
			x = 0,
			layer = 1,
			w = 200,
			h = 40
		})

		local max_x = 0
		local bonus_dim = 32
		self.mws_bp_skill_bitmaps = {}
		for skill_name, bonus in pairs(self.mws_bonuses) do
			local icon_xy = tweak_data.skilltree.skills[skill_name].icon_xy
			max_x = math.max(max_x, bonus.x * bonus_dim)
			self.mws_bp_skill_bitmaps[bonus.index] = self.mws_bp_bonus_panel:bitmap({
				x = bonus.x * bonus_dim,
				y = 0,
				texture = 'guis/textures/pd2/skilltree_2/icons_atlas_2',
				name = skill_name,
				blend_mode = 'add',
				layer = 1,
				texture_rect = {
					icon_xy[1] * 80,
					icon_xy[2] * 80,
					80,
					80
				},
				w = bonus_dim,
				h = bonus_dim,
				alpha = not bonus.available and self.mws_alpha_unavailable or bonus.checked and self.mws_alpha_enabled or self.mws_alpha_disabled
			})
		end
		self.mws_bp_bonus_panel:set_w(max_x + bonus_dim)
		self.mws_bp_bonus_panel:set_center_x(self.mws_bp_panel:w() / 2)

		-- unit names
		local col_width = 38
		self.mws_bp_unit_texts = {}
		local h = self.mws_bp_panel:h() - 10
		for i, unit_name in ipairs(self.mws_unit_types) do
			local txt = self.mws_bp_panel:text({
				vertical = 'center',
				align = 'right',
				text = managers.localization:text('mws_bp_option_' .. unit_name),
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				color = tweak_data.screen_colors.text:with_alpha(0.3 + i * 0.06),
				x = i * col_width - 32,
				y = h - 60,
				w = 100,
				h = 30
			})
			txt:rotate(-45)
			self.mws_bp_unit_texts[i] = txt
		end

		-- cells
		self.mws_bp_damage = {}
		self.mws_bp_bullet = {}
		local row_max = math.floor(self.mws_bp_unit_texts[1]:top() / 20) - 2
		local nr = 0
		for i = 2, row_max do
			local y = i * 20
			local panel = self.mws_bp_panel:panel({
				layer = 1,
				x = 0,
				y = y,
				w = self.mws_bp_panel:w(),
				h = 20
			})
			if i % 2 == 0 then
				panel:rect({
					color = Color.black:with_alpha(0.3)
				})
			end

			self.mws_bp_damage[i - 1] = self.mws_bp_panel:text({
				name = 'mws_bp_damage_' .. tostring(i - 1),
				layer = 2,
				align = 'right',
				vertical = 'center',
				font_size = tweak_data.menu.pd2_small_font_size,
				font = tweak_data.menu.pd2_small_font,
				text = '?',
				x = 0,
				y = y,
				w = 60,
				h = 20,
				color = Color.white,
			})

			for j = 1, 6 do
				nr = nr + 1
				self.mws_bp_bullet[nr] = self.mws_bp_panel:text({
					name = 'mws_bp_bullet_' .. tostring(i - 1) .. '_' .. self.mws_unit_types[j],
					layer = 2,
					align = 'center',
					vertical = 'center',
					font_size = tweak_data.menu.pd2_small_font_size,
					font = tweak_data.menu.pd2_small_font,
					text = '-',
					x = 80 + (j - 1) * col_width,
					y = y,
					w = 25,
					h = 20,
					color = Color.white,
					alpha = 1
				})
			end
		end

		-- difficulty
		self.mws_difficulty_picker = DifficultyPicker:new(self.mws_bp_panel)
		self.mws_difficulty_picker:update_difficulty()

		if self.mws_breakpoints then
			self:mws_update_breakpoints()
		end
	end

	if self.mws_stats_shown then
		self:show_stats()
		self:update_info_text()
	end
end

local mws_original_blackmarketgui_showbtns = BlackMarketGui.show_btns
function BlackMarketGui:show_btns(...)
	mws_original_blackmarketgui_showbtns(self, ...)

	local btn -- no 1-liner!
	if self.mws_breakpoints then
		btn = self.mws_bp_hide_btn
	else
		btn = self.mws_bp_show_btn
	end
	if btn then
		btn:set_text_params()
		btn:show()
		if MoreWeaponStats.settings.use_preview_to_switch_breakpoints then
			self._controllers_pc_mapping[Idstring(btn._data.pc_btn):key()] = btn
		end
	end
end

function BlackMarketGui:mws_bp_show_callback(data)
	self.mws_breakpoints = true
	self._stats_panel:hide()
	self.mws_bp_panel:show()
	self._button_highlighted = nil
	self:show_btns(self._selected_slot)
	self:mws_update_breakpoints()

	self:set_info_text(2, self._info_texts[2]:text(), tweak_data.screen_colors.text:with_alpha(0.35))
end

function BlackMarketGui:mws_bp_hide_callback(data)
	self.mws_breakpoints = false
	self._stats_panel:show()
	self.mws_bp_panel:hide()
	self._button_highlighted = nil
	self:show_btns(self._selected_slot)

	if self.mws_text2 then
		self._info_texts[2]:set_text(self.mws_text2)
	end
end

local mws_original_blackmarketgui_showstats = BlackMarketGui.show_stats
function BlackMarketGui:show_stats()
	pcall(function()
		self:_show_stats()
	end)
	Faker:use_normal_classes()
end

function BlackMarketGui:_show_stats()
	if _henchmen_weapon and self:mws_is_buying() then
		self._slot_data.comparision_data = nil
	end

	mws_original_blackmarketgui_showstats(self)

	Faker:use_game_classes()

	local slot_data = self._slot_data

	-- breakpoints
	MoreWeaponStats.mws_slot_data = slot_data
	if self.mws_breakpoints then
		self._stats_panel:hide()
		self:mws_update_breakpoints()
	end

	-- melee
	if self._mweapon_stats_panel and self._mweapon_stats_panel:visible() then
		if self.mws_stats_texts then
			local melee1 = managers.blackmarket:get_melee_weapon_data(self:mws_get_wbase_from_slot(true)._name_id)
			local melee2 = not slot_data.equipped and managers.blackmarket:get_melee_weapon_data(self:mws_get_wbase_from_slot(false)._name_id)
			for _, stat in ipairs(self.mws_stats_shown) do
				local txt1, txt2
				if stat.name == 'mws_attack_delay' then
					txt1 = ('%.2fs'):format(melee1.melee_damage_delay or 0)
					txt2 = melee2 and ('%.2fs'):format(melee2.melee_damage_delay or 0)
				elseif stat.name == 'mws_cooldown' then
					txt1 = ('%.2fs'):format(melee1.repeat_expire_t)
					txt2 = melee2 and ('%.2fs'):format(melee2.repeat_expire_t)
				elseif stat.name == 'mws_unequip_delay' then
					txt1 = ('%.2fs'):format(melee1.expire_t)
					txt2 = melee2 and ('%.2fs'):format(melee2.expire_t)
				elseif stat.name == 'mws_special' then
					local function mdescr(melee)
						return melee and (
							melee.special_weapon
							or melee.tase_data and 'tase'
							or melee.fire_dot_data and 'fire'
							or melee.dot_data and (melee.dot_data.type or 'dot')
						)
					end
					txt1 = mdescr(melee1)
					txt2 = mdescr(melee2)
				elseif stat.name == 'mws_dot_length' then
					local function mdescr(melee)
						return melee and (
							melee.dot_data and melee.dot_data.custom_data and ('%.2fs'):format(melee.dot_data.custom_data.dot_length or 0)
							or melee.tase_data and melee.tase_data.tase_strength
							or melee.fire_dot_data and ('%.2fs'):format(melee.fire_dot_data.dot_length or 0)
						)
					end
					txt1 = mdescr(melee1)
					txt2 = mdescr(melee2)
				end
				self.mws_stats_texts[stat.name].a1:set_text(txt1 or '')
				self.mws_stats_texts[stat.name].a2:set_text(txt2 or '')
			end
		end
	end

	-- weapons
	if not _henchmen_weapon and self._rweapon_stats_panel and self._rweapon_stats_panel:visible() then
		self:mws_realign_rcells(self._rweapon_stats_panel)
		if self.mws_stats_texts then
			local wbase_selected = self:mws_get_wbase_from_slot(true)
			local wbase_equipped = not slot_data.equipped and self:mws_get_wbase_from_slot(false)

			for _, stat in ipairs(self.mws_stats_shown) do
				if stat.fct and self.mws_stats_texts[stat.name] then
					stat.fct(self, wbase_selected, '1', self.mws_stats_texts[stat.name])
					if wbase_equipped then
						stat.fct(self, wbase_equipped, '2', self.mws_stats_texts[stat.name])
					else
						self.mws_stats_texts[stat.name].a2:set_text('')
						self.mws_stats_texts[stat.name].b2:set_text('')
					end
				end
			end

			if self.mws_range_charts then
				local function update_bars(wbase, chart)
					if wbase and wbase.is_weak_hit and wbase._optimal_distance + wbase._optimal_range ~= 0 and wbase:weapon_tweak_data().damage_falloff then
						local fake_player_unit = wbase and Faker.make_player_unit(wbase, false, self.mws_ducking, false, self.mws_in_steelsight)
						local col_ray = { distance = 0 }
						local function get_text_height_colour(i)
							col_ray.distance = (i - 1) * 50
							local value = wbase:get_damage_falloff(1, col_ray, fake_player_unit)
							local dmg = value * wbase._damage * 10
							local txt = managers.localization:text('mws_range_chart_text', {
								DMG = ('%.1f'):format(dmg),
								DIS = ('%.1f'):format(col_ray.distance / 100)
							})
							if value == 1 then
								return txt, 1, Color(0.2, 1, 1, 1)
							else
								return txt, (value - 1) * -25, tweak_data.screen_colors[value < 1 and 'stats_negative' or 'stats_positive']
							end
						end
						chart:update(get_text_height_colour)
						chart:show()
					else
						chart:hide()
					end
				end
				update_bars(wbase_selected, self.mws_range_charts[1])
				update_bars(wbase_equipped, self.mws_range_charts[2])
			end
		end
	end

	-- henchmen
	if _henchmen_weapon and not slot_data.comparision_data and slot_data.unlocked and not slot_data.empty_slot then
		self:set_weapons_stats_columns()
		self._rweapon_stats_panel:show()
		self._stats_panel:show()
		self:hide_armor_stats()
		self:hide_melee_weapon_stats()

		local wbase_equipped, wbase_selected
		if self:mws_is_buying() then
			wbase_selected = self:mws_get_wbase_from_slot(false, nil, nil, nil, true)
		else
			wbase_equipped = self:mws_get_wbase_from_slot(false, nil, nil, self:mws_get_equipped_slot_npc(), true)
			wbase_selected = not slot_data.equipped and self:mws_get_wbase_from_slot(false, nil, nil, nil, true)
		end

		for _, title in pairs(self._stats_titles) do
			title:hide()
		end
		self:set_stats_titles({
			show = true,
			name = 'total'
		}, {
			name = 'equip',
			text_id = 'bm_menu_equipped',
			alpha = 0.75,
			x = 105,
			show = true
		})

		for _, stat in ipairs(self._stats_shown) do
			local value_equipped, value_selected = '', ''
			if stat.name == 'magazine' then
				if wbase_equipped then
					value_equipped = wbase_equipped:ammo_base():get_ammo_max_per_clip()
				end
				if wbase_selected then
					value_selected = wbase_selected:ammo_base():get_ammo_max_per_clip()
				end
			elseif stat.name == 'fire_rate' then
				if wbase_equipped then
					local td = wbase_equipped:weapon_tweak_data()
					local fire_rate = 60 / (td[td.FIRE_MODE] and td[td.FIRE_MODE].fire_rate or 1) -- see NPCRaycastWeaponBase:trigger_held()
					value_equipped = math.round(fire_rate / 10 * 10)
				end
				if wbase_selected then
					local td = wbase_selected:weapon_tweak_data()
					local fire_rate = 60 / (td.auto and td.auto.fire_rate or 1)
					value_selected = math.round(fire_rate / 10 * 10)
				end
			elseif stat.name == 'damage' then
				if wbase_equipped then
					value_equipped = wbase_equipped._damage * 10
				end
				if wbase_selected then
					value_selected = wbase_selected._damage * 10
				end
			end

			local stats_text = self._stats_texts[stat.name]
			stats_text.name:set_text(utf8.to_upper(managers.localization:text('bm_menu_' .. stat.name)))
			stats_text.equip:set_alpha(0.75)
			stats_text.equip:set_text(value_equipped)
			stats_text.equip:set_color(tweak_data.screen_colors.text)
			stats_text.total:set_text(value_selected)
			stats_text.total:set_color(tweak_data.screen_colors.text)
		end

		if self.mws_stats_texts then
			for _, stat in ipairs(self.mws_stats_shown) do
				if stat.fct then
					local text_name = stat.text_name or stat.name
					if wbase_equipped then
						stat.fct(self, wbase_equipped, '1', self.mws_stats_texts[text_name])
					end
					if wbase_selected then
						stat.fct(self, wbase_selected, '2', self.mws_stats_texts[text_name])
					else
						self.mws_stats_texts[text_name].a2:set_text('')
						self.mws_stats_texts[text_name].b2:set_text('')
					end
				end
			end
		end
	end
end

function BlackMarketGui:mws_get_equipped_slot_npc()
	for _, tabdata in ipairs(self._data) do
		for _, item in ipairs(tabdata) do
			if item.equipped then
				return item
			end
		end
	end
end

function BlackMarketGui:mws_get_wbase_from_slot(equipped, remove_mod, add_mod, slot_data, npc)
	slot_data = slot_data or self._slot_data
	if slot_data.name == 'sentry_gun' then
		return
	end

	local category = slot_data.category
	if tweak_data.weapon[slot_data.name] then
		local slot = equipped and managers.blackmarket:equipped_weapon_slot(category) or slot_data.slot
		local weapon = equipped and managers.blackmarket:equipped_item(category) or managers.blackmarket:get_crafted_category_slot(category, slot)
		local weapon_id = equipped and weapon.weapon_id or weapon and weapon.weapon_id or slot_data.name
		local factory_id = managers.weapon_factory:get_factory_id_by_weapon_id(weapon_id)

		local blueprint = deep_clone(managers.blackmarket:get_weapon_blueprint(category, slot) or managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id))
		if blueprint then
			if remove_mod then
				for i = 1, #blueprint do
					if blueprint[i] == remove_mod then
						table.remove(blueprint, i)
						break
					end
				end
			end
			if add_mod then
				table.insert(blueprint, add_mod)
			end
		end

		return Faker:make_weapon_base(factory_id, blueprint, weapon_id, npc)

	elseif tweak_data.blackmarket.melee_weapons[slot_data.name] then
		local weapon_id = equipped and managers.blackmarket:equipped_item(category) or slot_data.name
		return {
			_name_id = weapon_id,
		}
	end
end

function BlackMarketGui:mws_reload_x_ammo(wbase, x)
	-- PlayerStandard:_start_action_reload()
	wbase:set_ammo_remaining_in_clip(x and (wbase:get_ammo_max_per_clip() - x) or 0)

	local fake_player_unit = Faker.make_player_unit(wbase)
	local fake_player_state = fake_player_unit._movement._current_state
	fake_player_state:_start_action_reload_enter(0)

	local i, v, next_v = 0, 0, table.sum(fake_player_state._state_data)
	while next_v > v do
		v = next_v
		fake_player_state:_update_reload_timers(v, 0, {})
		next_v = table.sum(fake_player_state._state_data)

		i = i + 1
		if i > 100 then
			v = -1
			break
		end
	end

	return v
end

function BlackMarketGui:mws_reload_full(wbase, index, txts)
	-- PlayerStandard:_start_action_reload()
	local v = self:mws_reload_x_ammo(wbase)
	txts['a' .. index]:set_text(('%.2f%s'):format(v, managers.localization:text('menu_seconds_suffix_short')))
end

function BlackMarketGui:mws_reload_partial(wbase, index, txts)
	-- PlayerStandard:_start_action_reload()
	if wbase:get_ammo_max_per_clip() == 1 then
		txts['a' .. index]:set_text('')
		txts['b' .. index]:set_text('')
		return
	end

	local v1 = self:mws_reload_x_ammo(wbase, 1)

	local speed_multiplier = wbase:reload_speed_multiplier()
	local v2 = (wbase:weapon_tweak_data().timers.reload_not_empty or wbase:reload_shell_expire_t() or 2.2) / speed_multiplier

	if v1 == 0 then -- see saw
		v1 = v2
	end

	local s = managers.localization:text('menu_seconds_suffix_short')
	txts['a' .. index]:set_text(('%.2f%s'):format(v1, s))
	txts['b' .. index]:set_text((v1 == v2 and '' or ' | %.2f%s'):format(v2, s))
end

function BlackMarketGui.mws_get_weapon_usage_tweak(wbase)
	local wtd = wbase:weapon_tweak_data()
	return wtd and tweak_data.character.russian.weapon[wtd.usage], wtd
end

function BlackMarketGui:mws_reload_bot(wbase, index, txts)
	local weapon_usage_tweak = self.mws_get_weapon_usage_tweak(wbase)
	if not weapon_usage_tweak then
		txts['a' .. index]:set_text('?')
		txts['b' .. index]:set_text('')
		return
	end

	txts['a' .. index]:set_text(('%.2f'):format(weapon_usage_tweak.RELOAD_SPEED))
end

function BlackMarketGui:mws_aim_delay_bot(wbase, index, txts)
	local weapon_usage_tweak = self.mws_get_weapon_usage_tweak(wbase)
	if not weapon_usage_tweak then
		txts['a' .. index]:set_text('?')
		txts['b' .. index]:set_text('')
		return
	end

	local s = managers.localization:text('menu_seconds_suffix_short')
	txts['a' .. index]:set_text(('%.2f%s'):format(weapon_usage_tweak.aim_delay[1], s))
	txts['b' .. index]:set_text((' | %.2f%s'):format(weapon_usage_tweak.aim_delay[2], s))
end

local pickup_range_l, pickup_range_h

local mws_original_math_lerp = math.lerp
function math.mws_lerp(a, b, t)
	pickup_range_l = a
	pickup_range_h = b
	return mws_original_math_lerp(a, b, t)
end

function BlackMarketGui:mws_ammo_pickup(wbase, index, txts)
	pickup_range_l = -1
	pickup_range_h = -1

	wbase:set_ammo_total(0)
	math.lerp = math.mws_lerp
	wbase:add_ammo(1)
	math.lerp = mws_original_math_lerp

	if pickup_range_l <= 0 and pickup_range_h <= 0 then
		txts['a' .. index]:set_text('')
		txts['b' .. index]:set_text('')
	else
		txts['a' .. index]:set_text(('%.2f'):format(pickup_range_l))
		txts['b' .. index]:set_text((' | %.2f'):format(pickup_range_h))
	end
end

function BlackMarketGui:mws_falloff(wbase, index, txts)
	if wbase.is_weak_hit and wbase._optimal_distance + wbase._optimal_range ~= 0 and wbase:weapon_tweak_data().damage_falloff then
		txts['a' .. index]:set_text(('%.1f'):format(wbase._near_multiplier))
		txts['b' .. index]:set_text((' | %.1f'):format(wbase._far_multiplier))
	elseif wbase._damage_near then
		local inc_range_mul = self.mws_in_steelsight and managers.player:upgrade_value('shotgun', 'steelsight_range_inc', 1) or 1
		local near = inc_range_mul * wbase._damage_near / 100
		local far = inc_range_mul * wbase._damage_far / 100
		txts['a' .. index]:set_text(('%.1fm'):format(near))
		txts['b' .. index]:set_text((' | %.1fm'):format(near + far))
	else
		txts['a' .. index]:set_text('')
		txts['b' .. index]:set_text('')
	end
end

function BlackMarketGui.mws_CopActionShoot_get_shoot_falloff(target_dis, falloff)
	for i_range, range_data in ipairs(falloff) do
		if target_dis < range_data.r then
			return range_data, i_range
		end
	end
	return falloff[#falloff], #falloff
end

function BlackMarketGui:mws_falloff_bot(wbase, index, txts, dis)
	local weapon_usage_tweak = self.mws_get_weapon_usage_tweak(wbase)
	if not weapon_usage_tweak then
		txts['a' .. index]:set_text('?')
		txts['b' .. index]:set_text('')
		return
	end

	local falloff, i_range = self.mws_CopActionShoot_get_shoot_falloff(dis - 0.01, weapon_usage_tweak.FALLOFF)

	txts['a' .. index]:set_text(('%.2f'):format(falloff.dmg_mul * wbase._damage * 10))
	txts['b' .. index]:set_text((' | %i%%'):format(100 * falloff.acc[2]))
end

local function mws_get_spread(wbase, st_moving, st_ducking, st_deploy, st_steelsight)
	local fake_player_unit = Faker.make_player_unit(wbase, st_moving, st_ducking, st_deploy, st_steelsight)
	return wbase:_get_spread(fake_player_unit)
end

function BlackMarketGui:mws_spread_horiz(wbase, index, txts)
	if wbase:is_category('saw') then
		txts['a' .. index]:set_text('')
		txts['b' .. index]:set_text('')
	else
		local spread_x, spread_y = mws_get_spread(wbase, false, self.mws_ducking, false, self.mws_in_steelsight)
		txts['a' .. index]:set_text(("%.2f'"):format(spread_x))
		local spread_x, spread_y = mws_get_spread(wbase, true, self.mws_ducking, false, self.mws_in_steelsight)
		txts['b' .. index]:set_text((" | %.2f'"):format(spread_x))
	end
end

function BlackMarketGui:mws_spread_vert(wbase, index, txts)
	if wbase:is_category('saw') then
		txts['a' .. index]:set_text('')
		txts['b' .. index]:set_text('')
	else
		local spread_x, spread_y = mws_get_spread(wbase, false, self.mws_ducking, false, self.mws_in_steelsight)
		txts['a' .. index]:set_text(("%.2f'"):format(spread_y))
		local spread_x, spread_y = mws_get_spread(wbase, true, self.mws_ducking, false, self.mws_in_steelsight)
		txts['b' .. index]:set_text((" | %.2f'"):format(spread_y))
	end
end

function BlackMarketGui:mws_spread_bot(wbase, index, txts)
	if wbase:is_category('saw') then
		txts['a' .. index]:set_text('')
		txts['b' .. index]:set_text('')
	else
		local weapon_usage_tweak = self.mws_get_weapon_usage_tweak(wbase)
		if not weapon_usage_tweak then
			txts['a' .. index]:set_text('?')
			txts['b' .. index]:set_text('')
		else
			txts['a' .. index]:set_text(('%.0f'):format(weapon_usage_tweak.spread))
			txts['b' .. index]:set_text('')
		end
	end
end

function BlackMarketGui:mws_autorounds_bot(wbase, index, txts)
	local weapon_usage_tweak, weap_tweak = self.mws_get_weapon_usage_tweak(wbase)
	if not weapon_usage_tweak then
		txts['a' .. index]:set_text('?')
		txts['b' .. index]:set_text('')
		return
	end

	local automatic_weap = weap_tweak.auto and weapon_usage_tweak.autofire_rounds and true
	if automatic_weap then
		txts['a' .. index]:set_text(('%i'):format(weapon_usage_tweak.autofire_rounds[1]))
		txts['b' .. index]:set_text((' | %i'):format(weapon_usage_tweak.autofire_rounds[2]))
	else
		txts['a' .. index]:set_text('-')
		txts['b' .. index]:set_text('')
	end
end

function BlackMarketGui:mws_rof_bot(wbase, index, txts)
	local weapon_usage_tweak, weap_tweak = self.mws_get_weapon_usage_tweak(wbase)
	if not weapon_usage_tweak then
		txts['a' .. index]:set_text('?')
		txts['b' .. index]:set_text('')
		return
	end

	local rof = -1
	local automatic_weap = weap_tweak.auto and weapon_usage_tweak.autofire_rounds and true
	if automatic_weap then
		-- see NewNPCRaycastWeaponBase:trigger_held()
		local fire_rate = weap_tweak.auto and weap_tweak.auto.fire_rate or 0.1
		rof = 60 / fire_rate
	else
		-- see end of CopActionShoot:update()
		local falloff, i_range = self.mws_CopActionShoot_get_shoot_falloff(1500, weapon_usage_tweak.FALLOFF)
		rof = 60 / falloff.recoil[2]
	end
	txts['a' .. index]:set_text(('%.0f'):format(rof))
	txts['b' .. index]:set_text('')
end

local function mws_get_recoil(wbase, st_ducking, st_steelsight)
	-- comes from function PlayerStandard:_check_action_primary_attack()
	local recoil_multiplier = (wbase:recoil() + wbase:recoil_addend()) * wbase:recoil_multiplier()
	local up, down, left, right = unpack(wbase:weapon_tweak_data().kick[st_steelsight and 'steelsight' or st_ducking and 'crouching' or 'standing'])
	return {
		up = up * recoil_multiplier,
		down = down * recoil_multiplier,
		left = left * recoil_multiplier,
		right = right * recoil_multiplier
	}
end

function BlackMarketGui:mws_recoil_horiz(wbase, index, txts)
	local recoil = mws_get_recoil(wbase, self.mws_ducking, self.mws_in_steelsight)
	txts['a' .. index]:set_text(("%.2f'"):format(recoil.left))
	txts['b' .. index]:set_text((" | %.2f'"):format(recoil.right))
end

function BlackMarketGui:mws_recoil_vert(wbase, index, txts)
	local recoil = mws_get_recoil(wbase, self.mws_ducking, self.mws_in_steelsight)
	txts['a' .. index]:set_text(("%.2f'"):format(recoil.up))
	txts['b' .. index]:set_text((" | %.2f'"):format(recoil.down))
end

function BlackMarketGui:mws_equip_delay(wbase, index, txts)
	local fake_player_unit = Faker.make_player_unit(wbase)
	local fake_player_state = fake_player_unit._movement._current_state

	fake_player_state:_start_action_equip_weapon(0)
	local equip = fake_player_state._equip_weapon_expire_t or 0

	fake_player_state:_start_action_unequip_weapon(0, {})
	local unequip = fake_player_state._unequip_weapon_expire_t or 0

	txts['a' .. index]:set_text(('%.2fs'):format(equip))
	txts['b' .. index]:set_text((' | %.2fs'):format(unequip))
end
