core:module("CoreElementArea")
core:import("CoreShapeManager")
core:import("CoreMissionScriptElement")
core:import("CoreTable")

ElementAreaTrigger = ElementAreaTrigger or class(CoreMissionScriptElement.MissionScriptElement)

ElementAreaReportTrigger = ElementAreaReportTrigger or class(ElementAreaTrigger)

function ElementAreaReportTrigger:_client_check_state(unit)
    local rule_ok = self:_check_instigator_rules(unit)
    local inside = self:_is_inside(unit:position())

    if table.contains(self._inside, unit) then
        if not inside or not rule_ok then
            table.delete(self._inside, unit)

            if
                Global.game_settings.level_id == "nail" and
                    (self._editor_name == "trigger_area_report_001" or self._editor_name == "trigger_area_report_002" or
                        self._editor_name == "trigger_area_report_003")
             then
                unit:character_damage():set_mission_damage_blockers("damage_fall_disabled", true)
            end

            managers.network:session():send_to_host("to_server_area_event", 2, self._id, unit)
        end
    elseif inside and rule_ok then
        table.insert(self._inside, unit)

        if
            Global.game_settings.level_id == "nail" and
                (self._editor_name == "trigger_area_report_001" or self._editor_name == "trigger_area_report_002" or
                    self._editor_name == "trigger_area_report_003")
         then
            unit:character_damage():set_mission_damage_blockers("damage_fall_disabled", true)
        end

        managers.network:session():send_to_host("to_server_area_event", 1, self._id, unit)
    end

    if inside then
        if rule_ok then
            if self:_has_on_executed_alternative("while_inside") then
                managers.network:session():send_to_host("to_server_area_event", 3, self._id, unit)
            end
        elseif self:_has_on_executed_alternative("rule_failed") then
            managers.network:session():send_to_host("to_server_area_event", 4, self._id, unit)
        end
    end
end
