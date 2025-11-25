module("zen")


-- List of popular free video streaming sites
local LIST_OF_POPULAR_SITES = {
    "youtube.com",
    "google.com",
}

function tv.OpenWebBrowser(entityIndex)
    local Frame = vgui.Create("DFrame")
    Frame:SetTitle("Zen TV - Web Browser")
    Frame:SetSize(800, 600)
    Frame:Center()
    Frame:MakePopup()

    local WebBrowser = vgui.Create("DHTML", Frame)
    WebBrowser:Dock(FILL)
    WebBrowser:InvalidateParent(true)


    local Header = vgui.Create("DPanel", Frame)
    Header:SetHeight(30)
    Header:Dock(TOP)
    Header:DockMargin(0, 0, 0, 0)
    Header:InvalidateParent(true)
    Header:SetVisible(type(entityIndex) == "number" and entityIndex > 0)

    local URLBar = vgui.Create("DTextEntry", Header)
    URLBar:Dock(FILL)
    URLBar:DockMargin(5, 5, 5, 5)
    URLBar:SetText("http://")
    URLBar.OnEnter = function(self)
        local url = self:GetValue()
        WebBrowser:OpenURL(url)
    end

    local SendToTVButton = vgui.Create("DButton", Header)
    SendToTVButton:Dock(RIGHT)
    SendToTVButton:DockMargin(0, 5, 5, 5)
    SendToTVButton:SetText("Send to TV")
    SendToTVButton.DoClick = function()
        local url = URLBar:GetValue()

        nt.Send("tv.sendToTV", {"uint16", "string"}, {entityIndex or 0, url or ""})
    end

    -- Create HTML for popular sites
    local html = "<html><body style='background-color:#282828; color:#FFFFFF; font-family:Arial, sans-serif;'><h1 style='text-align:center;'>Popular Sites</h1><ul style='list-style-type:none; padding:0;'>"
    for _, site in ipairs(LIST_OF_POPULAR_SITES) do
        html = html .. "<li style='margin:10px 0; text-align:center;'><a href='http://" .. site .. "' style='color:#1E90FF; font-size:18px; text-decoration:none;'>" .. site .. "</a></li>"
    end
    html = html .. "</ul></body></html>"

    WebBrowser.OnDocumentReady = function(self, url)
        URLBar:SetValue(url)

        WebBrowser:AddFunction("ztvvideo", "urlchange", function(newURL)
            URLBar:SetValue(newURL)
        end)

        WebBrowser:RunJavascript([[
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

    WebBrowser:SetHTML(html)


    hook.Add("zen.plugin.tv.web_browser_panel.loaded", Frame, function(self, panel)
        Frame:Remove()

        tv.OpenWebBrowser()
    end)
end
concommand.Add("zen_tv_open_web_browser", function (ply, cmd, args, argStr)
    local entityIndex = nil
    if args[1] then
        entityIndex = tonumber(args[1])
    end

    tv.OpenWebBrowser(entityIndex)
end, nil, "Opens the Zen TV web browser panel.")

hook.Run("zen.plugin.tv.web_browser_panel.loaded")