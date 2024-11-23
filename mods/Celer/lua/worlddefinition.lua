local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

core:import('CoreWorldDefinition')

function WorldDefinition:sync_load(data)
	local state = data.WorldDefinition
	if state then
		local second_state = {}
		for _, state_n in pairs({state, second_state}) do
			for unit_id, unit_state in pairs(state_n) do
				other_unit_id = Celer.duplicate_unit_ids[unit_id] or unit_id

				local f = function(unit)
					if unit:interaction() then
						unit:interaction():load(unit_state)
					else
						if state_n ~= second_state then
							second_state[other_unit_id] = unit_state
						else
							log('[Celer] interaction state not synched, too much ambiguity on ID ' .. tostring(unit_id))
						end
					end
				end

				local unit = self:get_unit_on_load(unit_id, f)
				if alive(unit) then
					f(unit)
				end
			end
		end
	end
end
