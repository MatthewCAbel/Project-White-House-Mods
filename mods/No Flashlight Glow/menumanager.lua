_G.NoFlashGlow = _G.NoFlashGlow or {}

NoFlashGlow._path = ModPath
NoFlashGlow._data_path = SavePath .. "NoFlashlightGlow.txt"
NoFlashGlow.flag_reset = 0
NoFlashGlow.settings = {
	disable_glow = true, --glow is off by default
	glow_alpha = 16 --default
}


function NoFlashGlow:Load()
	local file = io.open(self._data_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		NoFlashGlow:Save()
	end
end

function NoFlashGlow:Save()
	NoFlashGlow.flag_reset = NoFlashGlow.flag_reset + 1
	local file = io.open(self._data_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_NoFlashGlow", function( loc )
	loc:load_localization_file( NoFlashGlow._path .. "en.txt")
end)


Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_NoFlashGlow", function(menu_manager)

	MenuCallbackHandler.callback_nfg_alpha_slider = function(self,item)
		NoFlashGlow.settings.glow_alpha = item:value()
		NoFlashGlow:Save()
	end
	
	MenuCallbackHandler.callback_nfg_toggle_glow = function(self,item)
		local value = item:value() == 'on'
		NoFlashGlow.settings.disable_glow = value
		NoFlashGlow:Save()
	end
	
	MenuCallbackHandler.callback_nfg_close = function(this)
		NoFlashGlow:Save()
	end
	
	NoFlashGlow:Load()
	MenuHelper:LoadFromJsonFile(NoFlashGlow._path .. "options.txt", NoFlashGlow, NoFlashGlow.settings)
	
end)