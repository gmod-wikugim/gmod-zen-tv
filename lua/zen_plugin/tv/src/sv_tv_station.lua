module("zen")



nt.Receive("tv.sendToTV", {"uint16", "string"}, function(ply, entID, url)
    local ent = Entity(entID)

    print("Received tv.sendToTV for entity:", entID, "with URL:", url)

    if not IsValid(ent) or ent:GetClass() ~= "entity_zen_tv" then return end

    ent:SetNW2String("tv_url", url)
end)