util.AddNetworkString("nos?")

local boostremain = 100

function ActivateBoost(ply)
    local vehicle = ply:GetVehicle()

    if IsValid(vehicle) and vehicle:IsVehicle() then

        util.PrecacheSound("ambient/gas/cannister_loop.wav")

        ply:EmitSound("ambient/gas/cannister_loop.wav", SNDLVL_NORM, 100, 0.3, CHAN_AUTO)

        local forwardDirection = vehicle:GetForward()
        local upDirection = vehicle:GetUp()

        local velocityDirection = vehicle:GetVelocity():GetNormalized()
        local isMovingForward = ply:KeyDown(IN_FORWARD) and forwardDirection:Dot(velocityDirection) > 0
        local isMovingBackward = ply:KeyDown(IN_BACK) and forwardDirection:Dot(velocityDirection) < 0

        local boostDirection = isMovingForward and forwardDirection or isMovingBackward and -forwardDirection or Vector(0, 0, 0)

        local physObj = vehicle:GetPhysicsObject()

        if IsValid(physObj) then
            local currentVelocity = physObj:GetVelocity()

            local boostForce = 15
            local constantForce = 10

            local boostVelocity = currentVelocity + boostDirection * boostForce
            local force = (boostDirection * constantForce + boostVelocity - currentVelocity) * physObj:GetMass()

            physObj:ApplyForceCenter(force)
        else
            print("Vehicle physics object is invalid")
        end
    end
end

function StopBoost(ply)
    local vehicle = ply:GetVehicle()

    if IsValid(vehicle) and vehicle:IsVehicle() then
        vehicle:SetVelocity(Vector(0, 0, 0))

        ply:StopSound("ambient/gas/cannister_loop.wav")
    end
end

hook.Add("KeyPress", "BoostKeyPress", function(ply, key)
    if key == IN_SPEED and boostremain > 10 and ply:InVehicle() then
        ActivateBoost(ply)
        timer.Remove("BoostCharge")
        timer.Create("BoostDischarge", 0.1, 0, function()
            boostremain = boostremain - 1
            if boostremain < 10 then
                timer.Remove("BoostDischarge")
                StopBoost(ply)
            end
        end)
    else
        StopBoost(ply)
    end
end)

hook.Add("KeyRelease", "BoostKeyRelease", function(ply, key)
    if key == IN_SPEED and ply:InVehicle() then
        StopBoost(ply)
        timer.Remove("BoostDischarge")
        timer.Create("BoostCharge", 0.5, 0, function()
            if boostremain < 100 then
                boostremain = boostremain + 2
            else
                return("")
            end
        end)
    end
end)

hook.Add("Think", "BoostThink", function()
    for _, ply in ipairs(player.GetAll()) do
        if ply:KeyDown(IN_SPEED) and boostremain > 10 then
            ActivateBoost(ply)
        else
            StopBoost(ply)
        end

        net.Start("nos?")
        net.WriteFloat(boostremain)
        net.Send(ply)
    end
end)