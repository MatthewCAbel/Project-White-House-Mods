--This is for the host

local function fire_ray(player_unit, from, to)
    return player_unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("world_geometry"), "report")
end

local old_func = CopLogicAttack.aim_allow_fire
function CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data, ...)
	local player_unit = data.attention_obj and data.attention_obj.unit
    local unit = data.unit

    --The unit is the local player, then ignore the rest and let the original run
    --As for local player we have the playerdamage.lua to take care of that
    if (not alive(player_unit)) or (not alive(unit)) then
        return old_func(shoot, aim, data, my_data, ...)
    end

    local player_pos = data.attention_obj.m_head_pos or player_unit:movement():m_head_pos()
    local unit_head = unit:movement():m_head_pos()
    local unit_spine = unit:movement():m_com()

    --Since the host only tells the clients when the cop is shooting. But the actual info happens locally
    --We just intercept the shooting then
	if shoot then
		if not my_data.firing then
            local head_ray = fire_ray(player_unit, player_pos, unit_head)
            local spine_ray = fire_ray(player_unit, player_pos, unit_spine)
            if head_ray or spine_ray then --If ray from player to cop has hit a wall, then disallow fire
                data.unit:movement():set_allow_fire(false)

                my_data.firing = nil
                return
            end
		end
	end

    return old_func(shoot, aim, data, my_data, ...)
end