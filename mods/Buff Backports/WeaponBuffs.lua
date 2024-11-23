Hooks:PostHook( WeaponTweakData, "init", "WeaponBuffs", function(self)

self.vhs.AMMO_MAX = 180
self.vhs.stats.damage = 78

self.ak5.stats.damage = 66

self.famas.stats.damage = 51

self.asval.stats.damage = 50

self.amcar.stats.damage = 45

self.s552.stats.damage = 52

self.g36.stats.damage = 54

self.new_m4.stats.damage = 62

self.ak74.stats.damage = 63

self.aug.stats.damage = 65

self.komodo.stats.damage = 62

self.new_m14.AMMO_PICKUP = {1.26, 2.8}

self.m16.AMMO_PICKUP = {2.7, 4.95}

self.galil.stats.damage = 67
self.galil.stats.reload = 15

self.g3.AMMO_PICKUP = {3, 4.495}

self.l85a2.stats.damage = 65

self.sub2000.AMMO_PICKUP = {1.19, 2.64}

self.tecci.stats.damage = 70
self.tecci.stats.concealment = 14
self.tecci.stats.reload = 13

self.contraband.AMMO_PICKUP = {1.08, 2.4}

self.ching.AMMO_PICKUP = {1.38, 2.88}

self.mp9.stats.damage = 50

self.olympic.stats.damage = 65

self.shepheard.stats.damage = 58
self.shepheard.stats.spread = 17
self.shepheard.AMMO_PICKUP = {6, 11}

self.shepheard.stats.recoil = 18

self.mp7.stats.damage = 70

self.uzi.stats.damage = 90

self.sterling.stats.damage = 99
self.sterling.AMMO_PICKUP = {2.81, 5.28}
self.sterling.stats.spread = 14
self.sterling.CLIP_AMMO_MAX = 24
self.sterling.AMMO_MAX = 96

self.cobray.stats.reload = 11

self.coal.stats.recoil = 16
self.coal.stats.reload = 14

self.x_cobray.AMMO_PICKUP = {2.24, 7.84}
self.x_cobray.stats.reload = 13

self.x_scorpion.AMMO_PICKUP = {2.9, 9.8}
self.x_scorpion.stats.reload = 16

self.x_mp9.stats.damage = 50
self.x_mp9.stats.reload = 16

self.x_olympic.AMMO_PICKUP = {2.25, 7.88}

self.x_shepheard.stats.damage = 58
self.x_shepheard.stats.spread = 17

self.x_polymer.AMMO_PICKUP = {2.4, 8.4}
self.x_polymer.stats.reload = 13

self.x_coal.stats.reload = 13
self.x_coal.stats.recoil = 16
self.x_coal.AMMO_PICKUP = {1.8, 6.32}

self.x_sterling.stats.damage = 99
self.x_sterling.AMMO_PICKUP = {2.4, 8.4}
self.x_sterling.stats.spread = 14
self.x_sterling.stats.recoil = 20
self.x_sterling.CLIP_AMMO_MAX = 48
self.x_sterling.AMMO_MAX = 168

self.x_uzi.stats.damage = 90
self.x_uzi.AMMO_PICKUP = {2.16, 7.56}

self.x_mp7.stats.damage = 70

self.x_sr2.stats.reload = 13

self.x_erma.AMMO_PICKUP = {2.1, 3.85}
self.x_erma.stats.reload = 11

self.wa2000.CLIP_AMMO_MAX = 15
self.wa2000.AMMO_MAX = 60
self.wa2000.AMMO_PICKUP = {3, 4.5}
self.wa2000.stats.reload = 16

self.par.AMMO_PICKUP = {10, 12}
	self.par.kick = {
		standing = {
			-0.2,
			0.8,
			-1,
			1.7
		}
	}
	self.par.kick.crouching = self.par.kick.standing
	self.par.kick.steelsight = self.par.kick.standing

self.rpk.stats.concealment = 5
self.rpk.AMMO_PICKUP = {7.50, 10.50}
	self.rpk.kick = {
		standing = {
			-0.2,
			0.8,
			-1,
			1.4
		}
	}
	self.rpk.kick.crouching = self.rpk.kick.standing
	self.rpk.kick.steelsight = self.rpk.kick.standing

self.m249.AMMO_PICKUP = {10, 12}
	self.m249.kick = {
		standing = {
			-0.2,
			0.8,
			-1,
			1.4
		}
	}
	self.m249.kick.crouching = self.m249.kick.standing
	self.m249.kick.steelsight = self.m249.kick.standing

self.hk21.AMMO_PICKUP = {7.5, 10.5}
	self.hk21.kick = {
		standing = {
			0.4,
			0.8,
			-0.6,
			0.6
		}
	}
	self.hk21.kick.crouching = self.hk21.kick.standing
	self.hk21.kick.steelsight = self.hk21.kick.standing

self.mg42.AMMO_PICKUP = {10, 12}
	self.mg42.kick = {
		standing = {
			-0.2,
			0.8,
			-1,
			1.4
		}
	}
	self.mg42.kick.crouching = self.mg42.kick.standing
	self.mg42.kick.steelsight = self.mg42.kick.standing

self.ecp.stats.concealment = 28

end )
