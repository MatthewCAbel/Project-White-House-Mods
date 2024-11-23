function CrimeSpreeManager:get_narrative_tweak_data_for_mission_level_for_music(mission_id)
	local mission = self:get_mission(mission_id)
	local narrative_id, narrative_data, day, variant, name_id = nil

	for job_id, heist in pairs(tweak_data.narrative.jobs) do
		if not heist.hidden then
			for idx, day in pairs(heist.chain or {}) do
				if type(day) == "table" and not day.level_id then
					for variant_idx, day in ipairs(day) do
						if mission.level == day and heist.name_id then
							return heist, idx, variant_idx, heist.name_id
						end
					end
				elseif mission.level == day and heist.name_id then
						return heist, idx, nil, heist.name_id
				end
			end
		end
	end

	-- wrapped job
	for job_id, wrapper in pairs(tweak_data.narrative.jobs) do
		for _, heist in pairs(wrapper.job_wrapper or {}) do
			if not tweak_data.narrative.jobs[heist].hidden then
				for idx, day in pairs(tweak_data.narrative.jobs[heist].chain or {}) do
					if type(day) == "table" and not day.level_id then
						for variant_idx, day in ipairs(day) do
							if mission.level == day and wrapper.name_id then
								return tweak_data.narrative.jobs[heist], idx, variant_idx, wrapper.name_id
							end
						end
					elseif mission.level == day and wrapper.name_id then
							return tweak_data.narrative.jobs[heist], idx, nil, wrapper.name_id
					end
				end
			end
		end
	end
end