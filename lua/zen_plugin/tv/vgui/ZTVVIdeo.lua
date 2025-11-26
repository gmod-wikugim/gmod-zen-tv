module("zen")

---@class ZTVVideo : DHTML
local PANEL = {}

function PANEL:Init()
    self.VideoStartTime = 0
    self.VideoCurrentTime = 0

    self.CurrentVolume = 0.5

    self.CurrentlyPlaying = nil
end

-- Set Volume to current video
---@param volume number 0-1
function PANEL:SetVolume(volume)
    self:RunJavascript(string.format([[
        var video = document.querySelector("video");
        if (video) {
            video.volume = %f;
        }
    ]], volume))
    self.CurrentVolume = volume
end

-- Seek to time in seconds
---@param time number in seconds
function PANEL:SetPlayTime(time)
    self:RunJavascript(string.format([[
        var video = document.querySelector("video");
        if (video) {
            video.currentTime = %f;
        }
    ]], time))

    self.VideoCurrentTime = time
end

-- Stop video playback
function PANEL:StopVideo()
    self:RunJavascript([[
        var video = document.querySelector("video");
        if (video) {
            video.pause();
            video.currentTime = 0;
        }
    ]])
end

-- Pause video playback
function PANEL:PauseVideo()
    self:RunJavascript([[
        var video = document.querySelector("video");
        if (video) {
            video.pause();
        }
    ]])
end

-- Resume video playback
function PANEL:ResumeVideo()
    self:RunJavascript([[
        var video = document.querySelector("video");
        if (video) {
            video.play();
        }
    ]])
end

-- Toggle video playback
function PANEL:ToggleVideo()
    self:RunJavascript([[
        var video = document.querySelector("video");
        if (video) {
            if (video.paused) {
                video.play();
            } else {
                video.pause();
            }
        }
    ]])
end

---@param time number
function PANEL:OnTimeUpdate(time)
    -- print("ZTVVideo: Time Update: " .. tostring(time))

    self.VideoCurrentTime = time
end

function PANEL:_injectTimeUpdateListener()
    self:AddFunction("ztvvideo", "timeupdate", function(time)
        time = tonumber(time) or 0
        self.VideoCurrentTime = time
        self:OnTimeUpdate(time)
    end)

    -- RunJavascript for timeupdate event
    self:RunJavascript([[
        var video = document.querySelector("video");
        if (video) {
            video.addEventListener("timeupdate", function() {
                ztvvideo.timeupdate(video.currentTime);
            });
        }
        
        // Initial time
        if (video) {
            ztvvideo.timeupdate(video.currentTime);
        }
    ]])
end

---@param url string
function PANEL:OnURLChange(url)
    -- print("ZTVVideo: URL Change: " .. tostring(url))
end

-- Inject URL Change Listener
function PANEL:_injectURLChangeListener()
    self:AddFunction("ztvvideo", "urlchange", function(newURL)
        self.CurrentURL = newURL
        self:OnURLChange(newURL)
    end)

    self:RunJavascript([[
        var lastURL = window.location.href;
        setInterval(function() {
            var currentURL = window.location.href;
            if (currentURL !== lastURL) {
                lastURL = currentURL;
                ztvvideo.urlchange(currentURL);
            }
        }, 100);

        // Initial call
        ztvvideo.urlchange(window.location.href);
    ]])
end


function PANEL:IsPlaying() return self.CurrentlyPlaying end
function PANEL:IsPaused() return self.CurrentlyPlaying == false end

---@param status boolean
function PANEL:OnPlayStatusChange(status)
    -- print("ZTVVideo: Play Status Change: " .. tostring(status))
end

-- Inject video.play and video.pause listeners
function PANEL:_injectPlayStatusListeners()
    self:AddFunction("ztvvideo", "playstatuschange", function(status)
        status = tobool(status)

        self.CurrentlyPlaying = status
        self:OnPlayStatusChange(status)
    end)

    self:RunJavascript([[
        var video = document.querySelector("video");
        if (video) {
            video.addEventListener("play", function() {
                ztvvideo.playstatuschange(true);
            });
            video.addEventListener("pause", function() {
                ztvvideo.playstatuschange(false);
            });
        }
        
        // Initial status
        if (video) {
            ztvvideo.playstatuschange(!video.paused);
        }
    ]])
end


function PANEL:PostDocumentReady()
    -- Override in derived classes
end

function PANEL:OnDocumentReady()
    -- print("ZTVVideo: Document Ready")

    if self.VideoCurrentTime > 0 then
        self:SetPlayTime(self.VideoCurrentTime)
    end

    self:SetVolume(self.CurrentVolume)

    self:_injectTimeUpdateListener()
    self:_injectURLChangeListener()
    self:_injectPlayStatusListeners()

    self:PostDocumentReady()
end

-- OnVideoError
function PANEL:OnVideoError(err)
    print("ZTVVideo: Video Error: " .. tostring(err))
end

---@param video_url string
function PANEL:OpenVideo(video_url)
    self:OpenURL(video_url)
end

vgui.Register("ZTVVideo", PANEL, "DHTML")

-- Concommand to open create DHTML with ZTVVideo with privided URL
concommand.Add("ztv_open_video", function(_, _, _, argsStr)
    if not argsStr then return end


    -- Remove quotes from argsStr
    argsStr = argsStr:gsub('^"', ''):gsub('"$', '')

    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:Center()
    frame:SetTitle("ZTVVideo Test - " .. argsStr)
    frame:MakePopup()

    local video = vgui.Create("ZTVVideo", frame)
    video:Dock(FILL)
    video:OpenVideo(argsStr)

end)