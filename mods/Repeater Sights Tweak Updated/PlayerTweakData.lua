function PlayerTweakData:_init_winchester1874()
	self.stances.winchester1874 = deep_clone(self.stances.default)
	local pivot_shoulder_translation = Vector3(10.6097, 49.1694, -8.4901)
	local pivot_shoulder_rotation = Rotation(0.00124311, -0.086311, 0.630106)
	local pivot_head_translation = Vector3(12, 49, -4.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.winchester1874.standard.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.winchester1874.standard.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.winchester1874.standard.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.winchester1874.standard.vel_overshot.yaw_neg = 15
	self.stances.winchester1874.standard.vel_overshot.yaw_pos = -15
	self.stances.winchester1874.standard.vel_overshot.pitch_neg = -15
	self.stances.winchester1874.standard.vel_overshot.pitch_pos = 15
	local pivot_head_translation = Vector3(0, 42, -0.30)
	local pivot_head_rotation = Rotation(0, 0.3, 0)
	self.stances.winchester1874.steelsight.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.winchester1874.steelsight.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.winchester1874.steelsight.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -50, 0)
	self.stances.winchester1874.steelsight.vel_overshot.yaw_neg = 0
	self.stances.winchester1874.steelsight.vel_overshot.yaw_pos = -0
	self.stances.winchester1874.steelsight.vel_overshot.pitch_neg = -0
	self.stances.winchester1874.steelsight.vel_overshot.pitch_pos = 0
	local pivot_head_translation = Vector3(11, 48, -5.5)
	local pivot_head_rotation = Rotation(0, 0, 0)
	self.stances.winchester1874.crouched.shoulders.translation = pivot_head_translation - pivot_shoulder_translation:rotate_with(pivot_shoulder_rotation:inverse()):rotate_with(pivot_head_rotation)
	self.stances.winchester1874.crouched.shoulders.rotation = pivot_head_rotation * pivot_shoulder_rotation:inverse()
	self.stances.winchester1874.crouched.vel_overshot.pivot = pivot_shoulder_translation + Vector3(0, -30, 0)
end