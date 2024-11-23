Hooks:PostHook(WeaponFactoryTweakData, "init", "MG42BeltFix", function(self)

-- LMG --
-- KSP 58 --
-- Default Magazine
self.parts.wpn_fps_lmg_mg42_reciever.bullet_objects = {
  amount = 5,
  prefix = "g_bullet_"
}

end)