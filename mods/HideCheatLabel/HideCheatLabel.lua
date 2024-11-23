    local hide_cheater_label = true
     
    if string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
    	
    	local HUDManager_mark_cheater_original = HUDManager.mark_cheater
    	function HUDManager:mark_cheater(peer_id, ...)
    		if not hide_cheater_label then
    			HUDManager_mark_cheater_original(self, peer_id, ...)
    		end
    	end
    	
    elseif string.lower(RequiredScript) == "lib/network/base/networkpeer" then
    	
    	local NetworkPeer_mark_cheater_original = NetworkPeer.mark_cheater
    	function NetworkPeer:mark_cheater(reason, auto_kick, ...)
    		if not hide_cheater_label then
    			NetworkPeer_mark_cheater_original(self, reason, auto_kick, ...)
    		end
    	end
    	
    end