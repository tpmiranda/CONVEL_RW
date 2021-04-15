------------------------------------------------------------
-- OnControlValueChange
------------------------------------------------------------
-- Called when a cab control is modified
------------------------------------------------------------
-- Parameters:
--	name	= Name of the control
--	index	= Index of the control
--	value	= Modified control value
------------------------------------------------------------

function Initialise ()
gUnits = 0
gTens = 0
gHundreds = 0
goUnits = 0
goTens = 0
goHundreds = 0
tdistance = 0
speedwait = 0
warnloop = 0
cnvcomprimento = 0
cnvspeed = 0
cnvacel = 0
fdistance = 0
signalloop = 0
sdistance = 0
Call("*:SetControlValue", "SpeedLimit", 0, 30)
Call( "BeginUpdate" )
end

function OnControlValueChange ( name, index, value )
	if Call( "*:ControlExists", name, index ) then
		Call( "*:SetControlValue", name, index, value );
	end
end

function Update ( time )
type, speed, distance = Call("GetNextSpeedLimit", 0, 0)
dtype, dstate, ddistance, daspect = Call("GetNextRestrictiveSignal", 0, 0)
linelimit = Call("GetCurrentSpeedLimit")
tdistance = (Call ( "*:GetSpeed" )/30) + tdistance
cnvcomprimento = 100 * Call("*:GetControlValue", "RotorComprimento", 0)
cnvlimit = Call("*:GetControlValue", "SpeedLimit", 0)
cnvspeed = (Call("*:GetControlValue", "RotorVelocidade1", 0) * 100) + (Call("*:GetControlValue", "RotorVelocidade2", 0) * 10)
cnvacel = Call("*:GetControlValue", "RotorAcel1", 0) + (Call("*:GetControlValue", "RotorAcel2", 0) * 0.1) + (Call("*:GetControlValue", "RotorAcel3", 0) * 0.01)
fdistance = (Call ( "*:GetSpeed" )^2 - (speed)^2) / (2 * cnvacel)
sdistance = (Call ( "*:GetSpeed" )^2 - 156.25) / (2 * cnvacel)
Call("*:SetControlValue", "Accelerometer123", 0, tonumber(distance) - tonumber(ddistance))
	
	if Call("*:GetControlValue", "DisjuntorP", 0) == 0 then
		Call("*:SetControlValue", "Startup", 0, -1)
	else
		Call("*:SetControlValue", "Startup", 0, 1)
	end

	if Call("*:GetControlValue", "Bateria", 0) == 0 then
		Call("*:LockControl", "PantographControl", 0, 1)
	else
		Call("*:LockControl", "PantographControl", 0, 0)
	end

	if Call("*:GetControlValue", "PantographControl", 0) == 1 then
		Call("*:LockControl", "Bateria", 0, 1)
	else
		Call("*:LockControl", "Bateria", 0, 0)
	end

	if Call("*:GetControlValue", "Regulator", 0) ~= 0 then
		Call("*:LockControl", "Reverser", 0, 1)
	else
		Call("*:LockControl", "Reverser", 0, 0)
	end

	gSpeedo = (math.floor(Call("*:GetControlValue", "SpeedLimit", 0)))
	gSpeedo = tostring(gSpeedo)

		if string.len(gSpeedo) == 1 then
			gSpeedo = ("00" .. gSpeedo)
		elseif string.len(gSpeedo) == 2 then
			gSpeedo = ("0" .. gSpeedo)
		end
	_, _, gHundreds, gTens, gUnits = string.find(gSpeedo, "(%d)(%d)(%d)")

	Call("*:SetControlValue", "SpeedoUnits", 0,  tonumber(gUnits))
	Call("*:SetControlValue", "SpeedoTens", 0,  tonumber(gTens))
	Call("*:SetControlValue", "SpeedoHundreds", 0,  tonumber(gHundreds))

	gnSpeedo = (math.floor(Call("*:GetControlValue", "NextSpeedLimit", 0)))
	gnSpeedo = tostring(gnSpeedo)

		if string.len(gnSpeedo) == 1 then
			gnSpeedo = ("00" .. gnSpeedo)
		elseif string.len(gnSpeedo) == 2 then
			gnSpeedo = ("0" .. gnSpeedo)
		end
	_, _, goHundreds, goTens, goUnits = string.find(gnSpeedo, "(%d)(%d)(%d)")

	Call("*:SetControlValue", "OSpeedoUnits", 0,  tonumber(goUnits))
	Call("*:SetControlValue", "OSpeedoTens", 0,  tonumber(goTens))
	Call("*:SetControlValue", "OSpeedoHundreds", 0,  tonumber(goHundreds))

	if (Call("*:GetControlValue", "SpeedometerKPH", 0) - 5) > Call("*:GetControlValue", "SpeedLimit", 0) or (Call("*:GetControlValue", "SpeedometerKPH", 0) - 5) > cnvspeed then
		Call("*:SetControlValue", "Overspeed", 0, 1)
	else
		Call("*:SetControlValue", "Overspeed", 0, 0)
	end

	if (Call("*:GetControlValue", "SpeedometerKPH", 0) - 10) > Call("*:GetControlValue", "SpeedLimit", 0) or (Call("*:GetControlValue", "SpeedometerKPH", 0) - 10) > cnvspeed then
		Call("*:SetControlValue", "TrainBrakeControl", 0, 0.9)
		Call("*:LockControl", "TrainBrakeControl", 0, 1)
	end

	if Call("*:GetControlValue", "RealeseConvel", 0) == 1 and Call("*:GetControlValue", "SpeedometerKPH", 0) < Call("*:GetControlValue", "SpeedLimit", 0) then
		Call("*:SetControlValue", "TrainBrakeControl", 0, 0)
		Call("*:LockControl", "TrainBrakeControl", 0, 0)
	end

	if Call("*:GetControlValue", "RealeseConvel", 0) == 1 and Call("*:GetControlValue", "ConvelEmergencyBrake", 0) == 1 and Call("*:GetControlValue", "SpeedometerKPH", 0) < 1 then
		Call("*:LockControl", "TrainBrakeControl", 0, 0)
		Call("*:SetControlValue", "ConvelEmergencyBrake", 0, 0)
		Call("*:SetControlValue", "TrainBrakeControl", 0, 0)
		Call("*:SetControlValue", "SpeedLimit", 0, 30)
		Call("*:SetControlValue", "NextSpeedLimit", 0, 0)
	end

	if (speedwait == 1) and (tdistance > cnvcomprimento) then
		Call("*:SetControlValue", "SpeedLimit", 0, tonumber(linelimit) *3.6)
		Call("*:SetControlValue", "AWSClearCount", 0, Call("*:GetControlValue", "AWSClearCount", 0) + 1 )
		speedwait = 0
	end

	if warnloop == 1 then
		if fdistance > distance then
			Call("*:SetControlValue", "TrainBrakeControl", 0, 0.9)
			Call("*:LockControl", "TrainBrakeControl", 0, 1)
			Call("*:SetControlValue", "Overspeed", 0, 1)
		elseif 1.6 * fdistance > distance then
			Call("*:SetControlValue", "Overspeed", 0, 1)
		elseif 2.3 * fdistance > distance then
			Call("*:SetControlValue", "Overspeed", 0, 0)
		end
	end
	
	if signalloop == 1 then
		if sdistance > ddistance then
			Call("*:SetControlValue", "TrainBrakeControl", 0, 0.9)
			Call("*:LockControl", "TrainBrakeControl", 0, 1)
			Call("*:SetControlValue", "Overspeed", 0, 1)
		elseif 1.6 * sdistance > ddistance then
			Call("*:SetControlValue", "Overspeed", 0, 1)
		elseif 2.3 * sdistance > ddistance then
			Call("*:SetControlValue", "Overspeed", 0, 0)
		end
	end
	
end

function OnCustomSignalMessage ( arg )

	if arg == "newspeed" then
		if (cnvlimit / 3.6) > speed then	
			Call("*:SetControlValue", "SpeedLimit", 0,  tonumber(speed) * 3.6)
			Call("*:SetControlValue", "AWSClearCount", 0, Call("*:GetControlValue", "AWSClearCount", 0) + 1 )
			Call("*:SetControlValue", "NextSpeedLimit", 0, 0)
			warnwait = 0
		elseif (cnvlimit / 3.6) < speed then
			tdistance = 0
			speedwait = 1
		end

	elseif arg == "nextspeed" then		
		Call("*:SetControlValue", "NextSpeedLimit", 0,  tonumber(speed) * 3.6)
		warnloop = 1

	elseif arg == "ZNstart" then
		Call("*:SetControlValue", "DisjuntorP", 0, 0)
	
	elseif arg == "signal" then
		if ddistance < 20 and daspect == 0 then
			signalloop = 0
		elseif ddistance < 20 and daspect == 2 then
			Call("*:SetControlValue", "NextSpeedLimit", 0, 45)
			signalloop = 0
		elseif ddistance < 20 and daspect == 1 then
			Call("*:SetControlValue", "SpeedLimit", 0, 45)
			Call("*:SetControlValue", "NextSpeedLimit", 0, 0)
			signalloop = 1
		elseif ddistance < 20 and daspect == 3 then
			if Call("*:GetControlValue", "OverrideConvel", 0) == 0 then
				Call("*:SetControlValue", "SpeedLimit", 0, 0)
				Call("*:SetControlValue", "EmergencyBrake", 0, 1)
				Call("*:SetControlValue", "ConvelEmergencyBrake", 0, 1)
				Call("*:LockControl", "TrainBrakeControl", 0, 1)
			elseif Call("*:GetControlValue", "OverrideConvel", 0) == 1 then
				Call("*:SetControlValue", "SpeedLimit", 0, 30)
			end
		end		
	end
end
