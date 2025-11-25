module("zen", package.seeall)

include("shared.lua")

function ENT:OnRemove()
    if IsValid(self.pnlZTVVideo) then
        self.pnlZTVVideo:Remove()
    end
end

function ENT:LoadURL(url)
    if !IsValid(self.pnlZTVVideo) then
        self.pnlZTVVideo = vgui.Create("ZTVVideoYoutube")
        self.pnlZTVVideo:SetSize(self.TV_Width, self.TV_Height)
        self.pnlZTVVideo:SetPaintedManually(true)
    end

    self.pnlZTVVideo:OpenVideo(url)
end


function ENT:CanInteract()
    if vgui.GetKeyboardFocus() ~= nil then
        return false
    end

    if vgui.CursorVisible() then
        return false
    end

    if gui.IsGameUIVisible() then
        return false
    end

    if input.IsShiftDown() or input.IsControlDown() then
        return false
    end

    if input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) then
        return false
    end

    return true
end

function ENT:OnInteract()
    -- Override me

    if self.HoverAction == "tv.interact" then
        RunConsoleCommand("zen_tv_open_web_browser", self:EntIndex())
    elseif self.HoverAction == "tv.pause" then
        if IsValid(self.pnlZTVVideo) then
            self.pnlZTVVideo:ToggleVideo()
        end
    elseif self.HoverAction == "tv.update_volume" then
        if IsValid(self.pnlZTVVideo) then
            self.pnlZTVVideo:SetVolume(self.HoverActionVolume)
        end
    end


    self:SetNW2VarProxy("tv_url", function(ent, name, old, new)
        self:LoadURL(new)
    end)
end

surface.CreateFont("zen.plugin.tv.title", {
    font = "DejaVu Sans",
    size = 255,
    weight = 800,
    antialias = true,
})

surface.CreateFont("zen.plugin.tv.info", {
    font = "DejaVu Sans",
    size = 50,
    weight = 800,
    antialias = true,
})

function ENT:DrawTVPanel(vis, cx, cy)
    -- Code to replace



    surface.SetDrawColor( 40, 40, 40, 255 )
    surface.DrawRect( 0, 0, self.TV_Width, self.TV_Height )

    surface.SetDrawColor( 255, 255, 255, 255 )
    surface.DrawOutlinedRect( 0, 0, self.TV_Width, self.TV_Height, 5)


    if self.pnlZTVVideo and IsValid(self.pnlZTVVideo) then
        draw.SimpleText( "Loading page, please wait!", "zen.plugin.tv.info", self.TV_Width / 2, self.TV_Height / 2 + 50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        self.pnlZTVVideo:PaintManual()

        if self.pnlZTVVideo:IsPaused() then
            -- Draw mid-screen box
            surface.SetDrawColor( 0, 0, 0, 200 )
            surface.DrawRect( 0, self.TV_Height / 2 - 50, self.TV_Width, 100 )

            draw.SimpleText( "Paused", "zen.plugin.tv.info", self.TV_Width / 2, self.TV_Height / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

    else
        draw.SimpleText( "Zen TV", "zen.plugin.tv.title", self.TV_Width / 2, self.TV_Height / 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end


    self.HoverAction = ""
    -- Draw cursor
    if ( vis ) then
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawRect( cx - 5, cy - 5, 10, 10 )

        if cx > 0 and cx < self.TV_Width and cy > 0 and cy < self.TV_Height then
            self.HoverAction = "tv.interact"

            -- Draw press 'E' to interact
            draw.SimpleText( "Press 'E' to interact", "zen.plugin.tv.info", self.TV_Width / 2, self.TV_Height - 50, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )


            do -- Draw Pause Button
                local pauseX, pauseY = 20, self.TV_Height - 70
                local pauseW, pauseH = 50, 50
                -- Draw Pause Button, and Check for clicks
                surface.SetDrawColor( 200, 200, 200, 255 )
                surface.DrawRect( pauseX, pauseY, pauseW, pauseH )

                if self.pnlZTVVideo and IsValid(self.pnlZTVVideo) and self.pnlZTVVideo:IsPaused() then
                    draw.SimpleText( "▶", "zen.plugin.tv.info", pauseX + pauseW / 2, pauseY + pauseH / 2, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                else
                    draw.SimpleText( "II", "zen.plugin.tv.info", pauseX + pauseW / 2, pauseY + pauseH / 2, Color( 0, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                if cx > pauseX and cx < pauseX + pauseW and cy > pauseY and cy < pauseY + pauseH then
                    surface.SetDrawColor( 25, 125, 255, 50 )
                    surface.DrawRect( pauseX, pauseY, pauseW, pauseH )

                    self.HoverAction = "tv.pause"
                end
            end

            do -- Draw Volume Slider
                local sliderX, sliderY = 100, self.TV_Height - 60
                local sliderW, sliderH = 200, 30

                -- Background
                surface.SetDrawColor( 100, 100, 100, 255 )
                surface.DrawRect( sliderX, sliderY, sliderW, sliderH )

                -- Fill
                local volume = 0.5
                if IsValid(self.pnlZTVVideo) then
                    volume = self.pnlZTVVideo.CurrentVolume
                end
                surface.SetDrawColor( 25, 125, 255, 255 )
                surface.DrawRect( sliderX, sliderY, sliderW * volume, sliderH )

                -- Handle mouse interaction
                if cx > sliderX and cx < sliderX + sliderW and cy > sliderY and cy < sliderY + sliderH then
                    surface.SetDrawColor( 25, 125, 255, 50 )
                    surface.DrawRect( sliderX, sliderY, sliderW, sliderH )

                    self.HoverAction = "tv.update_volume"
                    self.HoverActionVolume = math.Clamp((cx - sliderX) / sliderW, 0, 1)
                end

            end

            if self:CanInteract() and input.IsKeyDown( KEY_E ) then
                if (self.LastInteractTime == nil) or (CurTime() - self.LastInteractTime >= 1) then
                    self.LastInteractTime = CurTime()

                    self:OnInteract()
                end
            end

        end



    end
end

function ENT:DrawTV()
    local origin = self:GetPos()

    origin = origin + ( self:GetUp() * self.Cam3D2D_OriginOffset.z )
    origin = origin + ( self:GetForward() * self.Cam3D2D_OriginOffset.y )
    origin = origin + ( self:GetRight() * self.Cam3D2D_OriginOffset.x )

    local angle = self:GetAngles()
    angle:RotateAroundAxis( angle:Right(), self.Cam3D2D_AngleOffset.p )
    angle:RotateAroundAxis( angle:Up(), self.Cam3D2D_AngleOffset.y )
    angle:RotateAroundAxis( angle:Forward(), self.Cam3D2D_AngleOffset.r )


    local vis, cx, cy = widget.GetCursor3D2D( origin, angle, self.Cam3D2D_Scale, true)
    cam.Start3D2D( origin, angle, self.Cam3D2D_Scale )
        self:DrawTVPanel(vis, cx, cy)
    cam.End3D2D()
end

function ENT:Draw()
    self:DrawModel()

    self:DrawTV()
end