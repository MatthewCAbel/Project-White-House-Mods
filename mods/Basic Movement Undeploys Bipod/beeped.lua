--such script
--very lines
--much sophisticated
--wow
function PlayerBipod:_update_movement(t, dt)
	local current_state = managers.player:get_current_state()
	if self._move_dir then
		self:_unmount_bipod()
	end
end