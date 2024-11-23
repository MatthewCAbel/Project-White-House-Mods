function PVM:Init()
    self.default_stances = {}
	self.black_list = {mask_off = true, civilian = true, clean = true}

    if Global.level_data and Global.level_data.level_id then
        self.refresh_key = self.Options:GetValue("RefreshKey")

        MenuUI:new({
            offset = 6,
            toggle_key = self.Options:GetValue("ToggleKey"),
            toggle_clbk = callback(self, self, "ShowMenu"),
            create_items = callback(self, self, "CreateItems"),
            use_default_close_key = true,
            key_press = function(o, k)
                if k == Idstring(self.refresh_key) then
                    self:Refresh()
                end
            end
        })
	end
end

function PVM:SaveTweak(tweak)
    tweak = tweak or tweak_data.player

	local saved = self.Options:GetValue("Saved")
	local apply_on_all = self.Options:GetValue("ApplyOnAll")
	for name, stance in pairs(tweak.stances) do
		for mode_name, mode in pairs(stance) do
			if mode.shoulders then
				if self.default_stances[name] then
					local default_stance = self.default_stances[name][mode_name]
					mode.shoulders.translation = mvector3.copy(default_stance.translation)
					mode.shoulders.rotation = mrotation.copy(default_stance.rotation)
					local saved_weapon = apply_on_all and saved.__All or saved[name]
					if saved_weapon and saved_weapon[mode_name] and saved_weapon[mode_name].shoulders then
						local shoulders = saved_weapon[mode_name].shoulders
						if shoulders.translation then
							mode.shoulders.translation = mvector3.copy(shoulders.translation)
						end
						if shoulders.rotation then
							mode.shoulders.rotation = mrotation.copy(shoulders.rotation)
						end
					end
				else
					self:AddDefaultStance(name, stance)
					self:log("Something is wrong, the following stance: %s does not have default stance data.", tostring(name))
				end
			end
		end
	end
end


function PVM:AddDefaultStance(name, stance)
	self.default_stances[name] = {}
	for mode_name, mode in pairs(stance) do
		if mode.shoulders then
			self.default_stances[name][mode_name] = {
				translation = mvector3.copy(mode.shoulders.translation or Vector3()),
				rotation = mrotation.copy(mode.shoulders.rotation or Rotation())
			}
		end
	end
end

function PVM:CreateItems(menu)
    self._menu = menu
    local accent = Color(0, 0.5, 1)
    self._holder = self._menu:DivGroup({
        name = "None",
        w = 300,
        auto_height = false,
        size = 20,
        background_visible = true,
        border_bottom = true,
        border_center_as_title = true,
        border_position_below_title = true,
        private = {text_align = "center"},
        border_lock_height = true,
        accent_color = accent,
        border_width = 200,
        background_color = Color(0.5, 0.25, 0.25, 0.25),
    })
end

function PVM:ResetStanceModPart(name)
    local state = managers.player:player_unit():movement():current_state()
    local weapon = alive(state._equipped_unit) and state._equipped_unit:base()
    local factory_id = weapon._factory_id
    local weapon_id = weapon and weapon:get_name_id() or "default"
    local stance = weapon:real_stance_mod()
    if stance.default then
        local saved = self.Options:GetValue("Saved")
        if saved[weapon_id] then
            saved[weapon_id][weapon:stance_mod_part_id()] = nil
        end
        stance.translation = mvector3.copy(stance.default.translation)
		stance.rotation = mrotation.copy(stance.default.rotation)
		local panel = self._holder:GetItem(name)
		if panel then
			local pos_p = panel:GetItem("Vector3")
			local rot_p = panel:GetItem("Rotation")
			if pos_p and rot_p then
				for _, axis in pairs({"x","y","z"}) do
					pos_p:GetItem(axis):SetValue(weapon:stance_mod().translation[axis])
				end
				for _, axis in pairs({"yaw","pitch","roll"}) do
					local rot = weapon:stance_mod().rotation
					rot_p:GetItem(axis):SetValue(rot[axis](rot))
				end
			end
		end
        self.Options:Save()
        self:RefreshState()
    end
end

function PVM:Reset(mode)
    if mode then
        local state = managers.player:player_unit():movement():current_state()
        local tweak = tweak_data.player
        local weapon = alive(state._equipped_unit) and state._equipped_unit:base()
		local weapon_id = weapon and weapon:get_name_id() or "default"
		local stance_base_id = tweak.stances[weapon_id] and weapon_id or "default"
		local stance = tweak.stances[stance_base_id][mode].shoulders
		local default_stance = self.default_stances[stance_base_id][mode]

        local saved = self.Options:GetValue("Saved")
        local save_weapon_id = self.Options:GetValue("ApplyOnAll") and "__All" or stance_base_id
        if saved[save_weapon_id] and saved[save_weapon_id][mode] then
            saved[save_weapon_id][mode] = nil
		end

        stance.translation = mvector3.copy(default_stance.translation)
		stance.rotation = mrotation.copy(default_stance.rotation)

		local panel = self._holder:GetItem(mode)
		if panel then
			local pos_p = panel:GetItem("Vector3")
			local rot_p = panel:GetItem("Rotation")
 			if pos_p and rot_p then
				for _, axis in pairs({"x","y","z"}) do
					pos_p:GetItem(axis):SetValue(stance.translation[axis])
				end
				for _, axis in pairs({"yaw","pitch","roll"}) do
					local rot = stance.rotation
					rot_p:GetItem(axis):SetValue(rot[axis](rot))
				end
			end
		end
        self.Options:Save()
        self:RefreshState()
    end
end

function PVM:Refresh()
    self:ShowMenu(true)
end

function PVM:ShowMenu(menu, opened)
	self._holder:ClearItems()
	if opened and managers.player:player_unit() then
		game_state_machine:current_state():set_controller_enabled(false)
		local stances = tweak_data.player.stances

        local state = managers.player:player_unit():movement():current_state()
        local weapon = alive(state._equipped_unit) and state._equipped_unit:base()
		local weapon_id = weapon and weapon:get_name_id()
		local stance_base_id = stances[weapon_id] and weapon_id or "default"
        local stances = stances[stance_base_id]
        local factory_id = weapon._factory_id
        local wep_tweak = tweak_data.weapon.factory[factory_id]
        self._holder:SetText(string.pretty(stance_base_id, true))
        self._holder:Button({
            name = "Reset",
            on_callback = function()
                for name, stance in pairs(stances) do
                    if not self.black_list[name] and stance.shoulders then
                        self:Reset(name)
                    end
                    if weapon:stance_mod_part_id() then
                        self:ResetStanceModPart(weapon:stance_mod_part_id())
                    end
                    if self._last_toggled == name then
                        self:Toggle(name)
                    end
                end
            end
        })
        self._holder:KeyBind({name = "ToggleKey", value = self.Options:GetValue("ToggleKey"), text = "Toggle key", on_callback = callback(self, self, "Set")})
        self._holder:KeyBind({name = "RefreshKey", value = self.Options:GetValue("RefreshKey"), text = "Refresh key", on_callback = callback(self, self, "Set")})
        self._holder:Toggle({name = "ApplyOnAll", value = self.Options:GetValue("ApplyOnAll"), text = "Apply on all", on_callback = callback(self, self, "Set")})
		for name, stance in pairs(stances) do
			if tonumber(name) == nil and stance.shoulders then
				self:StanceEdit(name, stance.shoulders.rotation)
                self:StanceEdit(name, stance.shoulders.translation)
			end
        end
        if weapon:stance_mod_part_id() then
            local name = weapon:stance_mod_part_id()
            self:StanceEdit(name, weapon:stance_mod().translation or Vector3(), "StanceModPartClbk", callback(self, self, "ResetStanceModPart"), true)
            self:StanceEdit(name, weapon:stance_mod().rotation or Rotation(), "StanceModPartClbk", callback(self, self, "ResetStanceModPart"), true)
        end
    else
		game_state_machine:current_state():set_controller_enabled(true)
        self._menu:disable()
    end
end

function PVM:Set(item)
    local name, value = item.name, item:Value()
    self.Options:SetValue(name, value)
    if name == "ToggleKey" then
        self._menu.toggle_key = value
    end
    if name == "RefreshKey" then
        self.refresh_key = value
    end
    if name == "ApplyOnAll" then
        self:RefreshState()
        self:Refresh()
        self:RefreshState()
    end
end

function PVM:StanceEdit(name, pos, clbk, reset_clbk, is_part)
    local panel = self._menu:GetMenu(name)
    if not self.black_list[name] then
		if not panel then
			local toggleable = name == "crouched" or name == "standard" or name == "steelsight"
			panel = self._holder:DivGroup({name = name, color = self._holder.accent_color, size = 18, align_method = "grid", inherit_values = {text_align = "center"}})
			local i = toggleable and 3 or 2
			local w = panel:ItemsWidth() / i - panel:OffsetX()
            if toggleable then
                panel:Button({
					text = "Toggle",
					w = w,
                    on_callback = ClassClbk(self, "Toggle", name)
                })
            end
            panel:Button({
                text = "Reset",
				w = w,
                on_callback = function()
                    if reset_clbk then
                        reset_clbk(name)
                    else
                        self:Reset(name)
                    end
                    if self._last_toggled == name then
                        self:Toggle(name)
                    end
                end
			})
			panel:Button({
				text = "Copy XML",
				w = w,
				on_callback = function()
					local pos = panel:GetItem("Vector3")
					local rot = panel:GetItem("Rotation")
					if pos and rot then
						local posrot = {
							translation = Vector3(pos:GetItem("x"):Value(), pos:GetItem("y"):Value(), pos:GetItem("z"):Value()),
							rotation = Rotation(rot:GetItem("yaw"):Value(), rot:GetItem("pitch"):Value(), rot:GetItem("roll"):Value()),
						}
						local t = is_part and posrot or {[name] = {shoulders = posrot}}
						Application:set_clipboard(tostring(ScriptSerializer:to_custom_xml(t)))
					end
				end
			})
        end
        local rot = pos.type_name == "Rotation"
        local control_panel = panel:DivGroup({
			name = pos.type_name,
			text_align = "left",
            text = rot and "Rotate" or "Translate",
            index = not rot and 4,
            align_method = "grid",
        })
        for _, axis in pairs(rot and {"yaw", "pitch", "roll"} or {"x","y","z"}) do
            local value = rot and mrotation[axis](pos) or pos[axis]
            control_panel:NumberBox({
                name = axis,
                value = value,
                is_rotation = rot,
                text = axis,
                stance = name,
                offset = 0,
                w = control_panel.w / 3,
                control_slice = 0.6,
                floats = 3,
                on_callback = callback(self, self, clbk or "MainClbk"),
            })
        end
    end
end

function PVM:Toggle(name)
    local state = managers.player:player_unit():movement():current_state()
    self._last_toggled = name
    if name == "crouched" then
        state:_start_action_ducking()
    end
    if name == "standard" then
        state:_end_action_steelsight()
        state:_end_action_ducking()
    end
    if name == "steelsight" then
        state:_start_action_steelsight()
    end
end

function PVM:MainClbk(item)
    local state = managers.player:player_unit():movement():current_state()
	local stances = tweak_data.player.stances
	local weapon_id = alive(state._equipped_unit) and state._equipped_unit:base():get_name_id() or "default"
	local stance_base_id = stances[weapon_id] and weapon_id or "default"

    local save_weapon_id = self.Options:GetValue("ApplyOnAll") and "__All" or stance_base_id
    if item.stance then
        local saved = self.Options:GetValue("Saved")
        saved[save_weapon_id] = saved[save_weapon_id] or {}
        saved[save_weapon_id][item.stance] = saved[save_weapon_id][item.stance] or {
            shoulders = {}
		}

		local stance = stances[stance_base_id][item.stance].shoulders
		local stance_value = item:Value()

        if item.is_rotation then
            mrotation["set_" .. item.text](stance.rotation, stance_value)
            saved[save_weapon_id][item.stance].shoulders.rotation = mrotation.copy(stance.rotation)
        else
            mvector3["set_" .. item.text](stance.translation, stance_value)
            saved[save_weapon_id][item.stance].shoulders.translation = mvector3.copy(stance.translation)
        end
        self.Options:Save()
        self:RefreshState()
    end
end

function PVM:RefreshState()
    self:SaveTweak()
    local state = managers.player:player_unit():movement():current_state()
    state:_stance_entered()
    if state._state_data.current_state == "bipod" then
        state:exit(nil, "standard")
        managers.player:set_player_state(state._state_data.current_state)
    end
end

function PVM:StanceModPartClbk(item)
    local state = managers.player:player_unit():movement():current_state()
    local weapon = alive(state._equipped_unit) and state._equipped_unit:base()
    local weapon_id = weapon and weapon:get_name_id() or "default"
    local stance = weapon:real_stance_mod()
    if item.stance then
        local saved = self.Options:GetValue("Saved")
        saved[weapon_id] = saved[weapon_id] or {}
        saved[weapon_id][weapon:stance_mod_part_id()] = saved[weapon_id][weapon:stance_mod_part_id()] or {}
        stance.rotation = stance.rotation or Rotation()
        stance.translation = stance.translation or Vector3()
        if item.is_rotation then
            mrotation["set_" .. item.text](stance.rotation, item.value)
            saved[weapon_id][weapon:stance_mod_part_id()].rotation = mrotation.copy(stance.rotation)
        else
            mvector3["set_" .. item.text](stance.translation, item.value)
            saved[weapon_id][weapon:stance_mod_part_id()].translation = mvector3.copy(stance.translation)
        end
        self.Options:Save()
        self:RefreshState()
    end
end