local orig_check_state = WeaponFlashLight._check_state
function WeaponFlashLight:_check_state(current_state)
	orig_check_state(self,current_state)
	if NoFlashGlow.settings.disable_glow then
		World:effect_manager():set_hidden(self._light_effect,true)-- take that light cone
	end
end


--may as well replace this whole function
local update_orig = WeaponFlashLight.update
function WeaponFlashLight:update(unit,t,dt)
	update_orig(self,unit,t,dt)
	if not self._is_npc and self.noflashglow_reset_num ~= NoFlashGlow.flag_reset then
	--sloppy, but it works. forces all flashlights to update their lightcone opacity and color, if player flashlight
		self:set_color(self:color())
		self.noflashglow_reset_num = NoFlashGlow.flag_reset
	end
end

function WeaponFlashLight:set_color(color)
	if self:is_haunted() then
		return
	end

	if not color then
		return
	end
	
	local a = NoFlashGlow.settings.glow_alpha or WeaponFlashLight.EFFECT_OPACITY_MAX --SORRY, WHAT DID YOU SAY, OVERKILL? I CAN'T HEAR YOU! YOU SHOULD TRY TYPING LOUDER!

	local opacity_ids = Idstring("opacity")
	local col_vec = Vector3(color.r, color.g, color.b)

	self._light:set_color(col_vec)

	if self._is_npc then
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera r"), opacity_ids, opacity_ids, color.r * WeaponFlashLight.NPC_GLOW_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera g"), opacity_ids, opacity_ids, color.g * WeaponFlashLight.NPC_GLOW_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("glow base camera b"), opacity_ids, opacity_ids, color.b * WeaponFlashLight.NPC_GLOW_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone r"), opacity_ids, opacity_ids, color.r * WeaponFlashLight.NPC_CONE_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone g"), opacity_ids, opacity_ids, color.g * WeaponFlashLight.NPC_CONE_OPACITY_MAX)
		World:effect_manager():set_simulator_var_float(self._light_effect, Idstring("lightcone b"), opacity_ids, opacity_ids, color.b * WeaponFlashLight.NPC_CONE_OPACITY_MAX)
	else
		local r_ids = Idstring("red")
		local g_ids = Idstring("green")
		local b_ids = Idstring("blue")

		World:effect_manager():set_simulator_var_float(self._light_effect, r_ids, r_ids, opacity_ids, color.r * a)
		World:effect_manager():set_simulator_var_float(self._light_effect, g_ids, g_ids, opacity_ids, color.g * a)
		World:effect_manager():set_simulator_var_float(self._light_effect, b_ids, b_ids, opacity_ids, color.b * a)
	end
end
