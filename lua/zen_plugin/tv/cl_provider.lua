module('zen')

tv.providers = tv.providers or {}

---@class zen.tv.provider
---@field regEx string
---@field documentReady fun(self:zen.tv.provider, videoPanel:ZTVVideo, url:string)


-- Register provider
---@generic T : zen.tv.provider
---@param providerTbl zen.tv.provider.`T`: zen.tv.provider
function tv.RegisterProvider(id, providerTbl)
    assert(providerTbl.regEx, "Provider must have a regEx")
    assert(
        type(providerTbl.documentReady) == "function",
        "Provider must have a documentReady function"
    )

    tv.providers[providerTbl.id] = providerTbl
end

local string_match = string.match

-- Get provider by URL
---@param url string
---@return zen.tv.provider?
function tv.GetProviderByURL(url)
    for _, provider in pairs(tv.providers) do
        if string_match(url, provider.regEx) then
            return provider
        end
    end
end