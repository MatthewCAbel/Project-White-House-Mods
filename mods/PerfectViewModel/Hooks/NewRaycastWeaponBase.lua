function NewRaycastWeaponBase:real_stance_mod()
	if not self._blueprint or not self._factory_id then
		return nil
	end
	return managers.weapon_factory:get_real_stance_mod(self._factory_id, self._blueprint, self:is_second_sight_on())
end

function NewRaycastWeaponBase:stance_mod_part_id()
	if not self._blueprint or not self._factory_id then
		return nil
	end
	return managers.weapon_factory:get_stance_mod_part_id(self._factory_id, self._blueprint, self:is_second_sight_on())
end

Hooks:PostHook(NewRaycastWeaponBase, "assemble_from_blueprint", "PVMAssemle", function(self)
	local saved = PVM.Options:GetValue("Saved")[self:get_name_id()]
	local stance = self:real_stance_mod()
	local stance_mod = self:stance_mod_part_id()
	if stance then
		stance.default = {
			translation = mvector3.copy(stance.translation) or Vector3(),
			rotation = mrotation.copy(stance.rotation) or Rotation(),
		}
		if saved then
			local saved_mod = saved[stance_mod] 
			if saved_mod then
				if saved_mod.translation then
					stance.translation = mvector3.copy(saved_mod.translation)
				end
				if saved_mod.rotation then
					stance.rotation = mrotation.copy(saved_mod.rotation)
				end
			end
		end
	end
end)