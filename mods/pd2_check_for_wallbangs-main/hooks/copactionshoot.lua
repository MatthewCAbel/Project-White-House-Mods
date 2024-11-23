local function fire_ray(player_unit, from, to)
    return player_unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("world_geometry"), "report")
end

local old_func = CopActionShoot._chk_start_melee
function CopActionShoot:_chk_start_melee(...)
	local player_unit = (self._attention and self._attention.unit) or managers.player:local_player()
	local unit = self._unit

    if (not alive(player_unit)) or (not alive(unit)) then
        return old_func(self, ...)
    end

    local player_pos = self:_get_target_pos(self._shoot_from_pos, self._attention, TimerManager:game():time()) or player_unit:movement():m_head_pos()
	--We don't need the head here
    local unit_spine = unit:movement():m_com()

	--The melee is processed on the client and then sent to peers
	--Which sadly, doesn't let us stop other players from getting meleed as a host
	--But we can at least stop the whole thing
    local spine_ray = fire_ray(player_unit, player_pos, unit_spine)
    if spine_ray then
        return
	end

    return old_func(self, ...)
end