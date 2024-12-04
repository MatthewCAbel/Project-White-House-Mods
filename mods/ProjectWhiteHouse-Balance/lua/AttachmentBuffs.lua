Hooks:PostHook( WeaponFactoryTweakData, "init", "AttachmentBuffs", function(self)

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

self.parts.wpn_fps_ass_g36_m_quick.stats.concealment = -2

self.parts.wpn_fps_ass_aug_m_quick.stats.concealment = -2

self.parts.wpn_fps_upg_ak_m_quick.stats.concealment = -2

self.parts.wpn_fps_m4_upg_m_quick.stats.concealment = -2

self.parts.wpn_fps_smg_sr2_m_quick.stats.concealment =-2

self.parts.wpn_fps_smg_mac10_m_quick.stats.concealment = -2

self.parts.wpn_fps_smg_p90_m_strap.stats.concealment = -2

self.parts.wpn_fps_ass_l85a2_m_emag.stats = {
	reload = 3
}

self.parts.wpn_fps_upg_m4_m_pmag.stats = {
	reload = 5,
	spread = -1,
}

self.parts.wpn_fps_upg_m4_m_l5.stats.recoil = +2

end )
