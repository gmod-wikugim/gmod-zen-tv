module("zen", package.seeall)

AddCSLuaFile("shared.lua")
include("shared.lua")
AddCSLuaFile("cl_init.lua")


function ENT:Initialize()
    self:SetModel( self.Model )
    self:SetMaterial( self.Material )
    self:SetColor( self.Color )

    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()

    if ( IsValid( phys ) ) then
        phys:Wake()
    end
end