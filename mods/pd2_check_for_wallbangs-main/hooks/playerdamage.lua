--This is for the local player

--Should probs merge the scripts to stop redefining code
local function fire_ray(player_unit, from, to)
    return player_unit:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("world_geometry"), "report")
end

local function validate(self, old_func, attack_data, ...)
    --Why check if we can't even take damage?
    if not self:_chk_can_take_dmg() then
        return
    end

    local attacker_unit = attack_data.attacker_unit --Get the cop, that's shooting
    local player_unit = self._unit or managers.player:local_player() --Get the player

    --Check if both are valid
    if (not alive(player_unit)) or (not alive(attacker_unit)) then
        return old_func(self, attack_data, ...) --Stop the function and let the original run
    end

    local player_pos = player_unit:movement():m_head_pos() --Cops shoot the players head
    local attacker_unit_head = attacker_unit:movement():m_head_pos() --Cops shoot FROM their head
    local attacker_unit_spine = attacker_unit:movement():m_com() --Check for cops clipping heads through walls, by checking if body is behind a wall

    --Since drawing the ray from the cop to the player doesn't register the wall and counts as a hit
    --While drawing a ray from the player registers the wall and can't shoot through it
    --Simply draw a ray from the player to the cop to check if there actually IS a wall
    --With the slot mask of world geometry to hit ONLY world stuff, such as walls
    local head_ray = fire_ray(player_unit, player_pos, attacker_unit_head)
    local spine_ray = fire_ray(player_unit, player_pos, attacker_unit_spine)
    if head_ray or spine_ray then --If wall was hit, then stop the function and don't let the original run to cancel the damage
        return
    end

    return old_func(self, attack_data, ...) --Run the original
end

do
    local old_func = PlayerDamage.damage_bullet
    function PlayerDamage:damage_bullet(attack_data, ...)
        validate(self, old_func, attack_data, ...)
    end
end

do
    --Just incase
    local old_func = PlayerDamage.damage_melee
    function PlayerDamage:damage_melee(attack_data, ...)
        validate(self, old_func, attack_data, ...)
    end
end