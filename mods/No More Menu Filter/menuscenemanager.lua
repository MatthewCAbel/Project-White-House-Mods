Hooks:PostHook( MenuSceneManager, "_set_up_environments", "NoMoreMenuFilterEnvironmentFix", function( self )
	if self._environments and self._environments.standard and self._environments.standard.color_grading then
		self._environments.standard.color_grading = "color_off"
	end
end)