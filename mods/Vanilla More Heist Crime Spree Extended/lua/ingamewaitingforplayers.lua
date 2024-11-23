Hooks:PreHook(IngameWaitingForPlayersState, "at_enter", "MHiCS_ingamewaitingforplayers_at_enter", function()
	if managers.crime_spree and managers.crime_spree:is_active() and managers.crime_spree:current_mission() == "ed_3" then
		tweak_data.carry["lance_bag"].visual_unit_name = "units/payday2/characters/npc_acc_loot_bag_1/npc_acc_loot_bag_1"
	end
end)