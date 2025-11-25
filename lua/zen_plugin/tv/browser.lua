module("zen")

tv = _GET("tv") ---@class zen.tv

zen.IncludeCL{
    "vgui/ZTVVideo.lua",
    "vgui/ZTVVideoYoutube.lua",

    "menu/cl_web_browser.lua",
}

zen.IncludeSV({
    "src/sv_tv_station.lua",
})