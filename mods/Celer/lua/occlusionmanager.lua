local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

function _OcclusionManager:remove_occlusion(unit)
	local u_key = unit:key()
	if self._skip_occlusion[u_key] then
		self._skip_occlusion[u_key] = self._skip_occlusion[u_key] + 1
	else
		self._skip_occlusion[u_key] = 1

		if alive(unit) then
			local objects = unit:get_objects_by_type(self._model_ids)
			for _, obj in ipairs(objects) do
				obj:set_skip_occlusion(true)
			end
		end
	end
end
