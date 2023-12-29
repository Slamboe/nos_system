local nosback 
local nostext

surface.CreateFont("noshud", {
    font = "Arial",
    extended = false,
    size = 25,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

hook.Add("Initialize", "playerinit", function()
    nosback = vgui.Create("DPanel")
    nosback:SetPos(900, 1000)
    nosback:SetSize(150, 50)
    function nosback:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(25, 26, 29, 255))
    end
    
    nostext = vgui.Create("DLabel", nosback)
    nostext:SetWide(200)
    nostext:SetText("NOS: ")
    nostext:SetContentAlignment(5)
    nostext:Center()
    nostext:SetFont("noshud")
    nostext:SetTextColor(Color(255, 255, 255))
end)

net.Receive("nos?", function(len, ply)
    nostext:SetText("NOS: " .. net.ReadFloat() .. "%")
end)

hook.Add("Think", "isquandaledingleinveh?", function()
    local ply = LocalPlayer()
    
    if ply:InVehicle() then
        nosback:SetVisible(true)
    else
        nosback:SetVisible(false)
    end
end)
