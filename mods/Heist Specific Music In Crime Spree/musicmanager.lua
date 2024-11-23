local _cs_specific_jukebox_heist_specific = MusicManager.jukebox_heist_specific

function MusicManager:jukebox_heist_specific()
	if managers.job:interupt_stage() then
		return self:track_attachment("escape") or "all"
	end

	if managers.crime_spree:is_active() then
		local narrative_data, day, variant, name_id = managers.crime_spree:get_narrative_tweak_data_for_mission_level_for_music(managers.crime_spree:current_mission())

		if narrative_data then
			local track_data = name_id .. ((#narrative_data.chain or 1) > 1 and tostring(day) or "")
			return self:track_attachment(track_data) or "all"
		end
	end

	return _cs_specific_jukebox_heist_specific(self)
end