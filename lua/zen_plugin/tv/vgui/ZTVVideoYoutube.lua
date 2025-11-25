module("zen")

-- VGUI Panel for YouTube Video Playback
-- YouTube video element: html5-video-player

---@class ZTVVideoYoutube : ZTVVideo
local PANEL = {}

-- Set Volume to current video
---@param volume number 0-1
function PANEL:SetVolume(volume)
    self:RunJavascript(string.format([[
        var player = document.getElementById("movie_player") || document.getElementsByClassName("html5-video-player")[0];
        player.setVolume(%f);
    ]], volume * 100))
    self.CurrentVolume = volume
end


function PANEL:OnDocumentReady()

    self:RunJavascript(
        [[
        var player = document.getElementById("movie_player") || document.getElementsByClassName("html5-video-player")[0];

        document.body.appendChild(player);
        player.style.backgroundColor = "#000";
        player.style.height = "100vh";

        var playerSizeTimerNumRuns = 0;
        var playerSizeTimer = setInterval(function() {
            for (const elem of document.getElementsByTagName("ytd-app")) {
                elem.remove();
            }
            for (const elem of document.getElementsByClassName("watch-skeleton")) {
                elem.remove();
            }
            for (const elem of document.getElementsByClassName("skeleton")) {
                elem.remove();
            }

            player.setInternalSize("100vw", "100vh");
            document.body.style.overflow = "hidden";

            playerSizeTimerNumRuns++;

            // A whole second has elapsed, we can stop
            if (playerSizeTimerNumRuns > 100) {
                clearInterval(playerSizeTimer);
            }
        }, 10);

        // Behold! The Ad-Destroyer-Inator!
        setInterval(function() {
            const adIsShowing = document.querySelector(".ad-showing"); // video-ads ytp-ad-module

            if (adIsShowing) {
            const internalVideoPlayer = document.querySelector("video");

            if (isFinite(internalVideoPlayer.duration)) {
                internalVideoPlayer.currentTime = internalVideoPlayer.duration;
            }
            }
        }, 500);

        // Remove annoying elements
        if(document.getElementsByClassName('ytp-watermark').length)document.getElementsByClassName('ytp-watermark')[0].remove()
        if(document.getElementsByClassName('ytp-show-cards-title').length)document.getElementsByClassName('ytp-show-cards-title')[0].remove()
        if(document.getElementsByClassName('ytp-paid-content-overlay').length)document.getElementsByClassName('ytp-paid-content-overlay')[0].remove()
        if(document.getElementsByClassName('ytp-pause-overlay').length)document.getElementsByClassName('ytp-pause-overlay')[0].remove()
        if(document.getElementsByClassName('videowall-endscreen').length)document.getElementsByClassName('videowall-endscreen')[0].remove()
        if(document.getElementsByClassName('ytp-gradient-top').length)document.getElementsByClassName('ytp-gradient-top')[0].remove()
    ]])


    self:_injectTimeUpdateListener()
end

vgui.Register("ZTVVideoYoutube", PANEL, "ZTVVideo")

-- Concommand to open create DHTML with ZTVVideoYoutube with privided URL
concommand.Add("ztv_open_youtube_video", function(_, _, _, argsStr)
    if not argsStr then return end

    -- Remove quotes from argsStr
    argsStr = string.Trim(argsStr, "\"")

    local Frame = vgui.Create("DFrame")
    Frame:SetTitle("ZTV YouTube Video Player - " .. argsStr)
    Frame:SetSize(800, 600)
    Frame:Center()
    Frame:MakePopup()

    local video = vgui.Create("ZTVVideoYoutube", Frame)
    video:Dock(FILL)
    video:OpenVideo(argsStr)

    -- Button for Pause/Play
    local btnTogglePlay = vgui.Create("DButton", Frame)
    btnTogglePlay:SetText("Pause/Play")
    btnTogglePlay:Dock(BOTTOM)
    btnTogglePlay.DoClick = function()
        video:ToggleVideo()
    end

    -- Slider for Volume
    local sldVolume = vgui.Create("DNumSlider", Frame)
    sldVolume:Dock(BOTTOM)
    sldVolume:SetText("Volume")
    sldVolume:SetMin(0)
    sldVolume:SetMax(1)
    sldVolume:SetDecimals(2)
    sldVolume:SetValue(0.5)
    sldVolume.OnValueChanged = function(_, val)
        video:SetVolume(val)
    end



end)
