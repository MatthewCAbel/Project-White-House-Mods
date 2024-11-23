function WeaponFactoryManager:part_data_no_clone(part_id, factory_id, override)
	return tweak_data.weapon.factory.parts[part_id] or {}
end

function WeaponFactoryManager:get_real_stance_mod(factory_id, blueprint, using_second_sight)
	local assembled_blueprint =  self:get_assembled_blueprint(factory_id, blueprint)
	local forbidden = self:_get_forbidden_parts(factory_id, assembled_blueprint)
	local override = self:_get_override_parts(factory_id, assembled_blueprint)
	local part
	for _, part_id in ipairs(assembled_blueprint) do
		if not forbidden[part_id] then
			local part = self:part_data_no_clone(part_id, factory_id, override)
			if part.stance_mod and (part.type ~= "sight" and part.type ~= "gadget" or using_second_sight and part.type == "gadget" or not using_second_sight and part.type == "sight") and part.stance_mod[factory_id] then
				return part.stance_mod[factory_id]
			end
		end
	end
end

function WeaponFactoryManager:get_stance_mod_part_id(factory_id, blueprint, using_second_sight)
	local assembled_blueprint = self:get_assembled_blueprint(factory_id, blueprint)
	local forbidden = self:_get_forbidden_parts(factory_id, assembled_blueprint)
	local override = self:_get_override_parts(factory_id, assembled_blueprint)
	for _, part_id in ipairs(assembled_blueprint) do
		if not forbidden[part_id] then
			part = self:_part_data(part_id, factory_id, override)
			if part.stance_mod and (part.type ~= "sight" and part.type ~= "gadget" or using_second_sight and part.type == "gadget" or not using_second_sight and part.type == "sight") and part.stance_mod[factory_id] then
				return part_id 
			end
		end
	end
	return nil
end