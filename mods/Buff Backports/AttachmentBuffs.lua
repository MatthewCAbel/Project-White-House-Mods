Hooks:PostHook( WeaponFactoryTweakData, "init", "AttachmentBuffs", function(self)  --replace "ThisFileEditsAttachmentStats" with the name of this file


self.parts.wpn_fps_smg_mp5_m_straight.stats = {
	damage = 15,
	recoil = -5,
	concealment = -2,
}

self.parts.wpn_fps_smg_mp5_fg_mp5sd.stats = {
	damage = 0,
	spread = 1,
	recoil = 1,
	concealment = 1,
	suppression = 12,
}

self.parts.wpn_fps_ass_g3_b_short.override_weapon = {
AMMO_PICKUP = {4.5, 8.1}
}

self.parts.wpn_fps_ass_g3_b_sniper.override_weapon = {
AMMO_PICKUP = {0.5, 1.75}
}

self.parts.wpn_fps_smg_thompson_barrel_long.stats = {
	damage = 10,
	spread = 2,
	concealment = -3,
}
end )
