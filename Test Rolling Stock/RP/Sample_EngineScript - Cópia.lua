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
Call( "BeginUpdate" )

end


function OnControlValueChange ( name, index, value )

	if Call( "*:ControlExists", name, index ) then

		Call( "*:SetControlValue", name, index, value );

	end

end


function Update ( time )
	speed = Call("*:GetControlValue", "SpeedometerKPH", 0) - 5
	speedlimit = Call("*:GetControlValue", "SpeedLimit", 0)
		if speed > speedlimit then
			Call("*:SetControlValue", "Overspeed", 0, 1)
		elseif speed < speedlimit then
			Call("*:SetControlValue", "Overspeed", 0, 0)
		end
end


function OnCustomSignalMessage ( arg )

	if arg == "newspeed" then

	glimit = Call("GetCurrentSpeedLimit") * 3.6
	gSpeedo = (math.floor(Call("GetCurrentSpeedLimit") * 3.6))
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
	Call("*:SetControlValue", "SpeedLimit", 0,  tonumber(glimit))
	
	end
end


