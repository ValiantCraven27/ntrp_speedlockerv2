ESX = nil

Citizen.CreateThread(function()
  while ESX == nil do
   TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
   Citizen.Wait(0)
   end   
end)

SpeedMultiplier, IsInSpeedLock, IsInSuspensionMenu = 2.238, false, false

TriggerEvent('chat:addSuggestion', '/cam', 'Turn on/off or Lock Cinematic Cam', {
    { name="on or off", help ="on | off" }
})

Citizen.CreateThread(function()
  while true do
      Citizen.Wait(0)
          local ped = GetPlayerPed(-1)
          local vehicleId = GetVehiclePedIsIn(ped, false)
          local vehicleMPH = GetEntitySpeed(vehicleId)
          local driverPed = GetPedInVehicleSeat(vehicleId,-1)
          
   if not IsPedInAnyBoat(ped) and not IsPedInAnyPlane(ped) and not IsPedInAnyHeli(ped) and not IsOnBike then 
     if IsControlJustPressed(0, Config.SpeedKey) and driverPed == ped then 
              Menu_SpeedLock()                      
              Citizen.Wait(1)            
             
   end
  end
 end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
            local ped = GetPlayerPed(-1)
            local vehicleId = GetVehiclePedIsIn(ped, false)
            local vehicleMPH = GetEntitySpeed(vehicleId)
            local driverPed = GetPedInVehicleSeat(vehicleId,-1)
         
   if IsControlJustPressed(0,Config.RideKey) and driverPed == ped and not IsPedInAnyBoat(ped) and not IsPedInAnyPlane(ped) and not IsPedInAnyHeli(ped) and not IsPedOnAnyBike(ped) then
        Citizen.Wait(150)
    if IsControlJustPressed(0, Config.RideKey) and driverPed == ped and not IsPedInAnyBoat(ped) and not IsPedInAnyPlane(ped) and not IsPedInAnyHeli(ped) and not IsPedOnAnyBike(ped) then                
         Menu_RideHeight()                 
    end
  end 
 end  
end)

Citizen.CreateThread(function() -- Driver Ped no Drive By
 while true do 
  Citizen.Wait(1)
    local ped = GetPlayerPed(-1)
    local vehicleId = GetVehiclePedIsIn(ped, false)
    local driverPed = GetPedInVehicleSeat(vehicleId, -1) 

  if driverPed == ped then
    if Config.noWeapons then
      SetCurrentPedWeapon(ped,GetHashKey("WEAPON_UNARMED"),true)
      DisableControlAction(0, 37, true) -- Weapon wheel
      DisableControlAction(0, 106, true) -- Weapon wheel
      if IsDisabledControlJustPressed(2, 37) then
		    --SetCurrentPedWeapon(ped,GetHashKey("WEAPON_UNARMED"),true) 	
      end
      if IsDisabledControlJustPressed(0, 106) then 
		    SetCurrentPedWeapon(ped,GetHashKey("WEAPON_UNARMED"),true)
      end
    end
    if VehCamOff then
      DisableControlAction(0, 80, true) -- no cin cam or lock it in cin mode
      SetFollowPedCamViewMode(1)
    end   
    if IsInSuspensionMenu then
       DisableControlAction(0, 74, true)  
       DisableControlAction(0, 82, true)  
       DisableControlAction(0, 83, true)
       DisableControlAction(0, 84, true)  
       DisableControlAction(0, 85, true)      
       
    end 
   end
  end
end)

function Menu_SpeedLock() -- Speedlock Menu
  local ped = GetPlayerPed(-1)
  local vehicleId = GetVehiclePedIsIn(ped, false)
  local vehicleMPH = GetEntitySpeed(vehicleId)

if IsInSpeedLock == true then
   PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
   
   NTRP.Notify(" 🚦 Speedometer Lock : Inactive ", "info", math.random(2000, 2000))
   SetEntityMaxSpeed(GetVehiclePedIsIn(ped, false), 299.9)              
   IsInSpeedLock = false  
else
   PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
   NTRP.Notify(" 🚦 Speedometer Lock : Estimated "..Round(GetEntitySpeed(vehicleId) * SpeedMultiplier).." MPH", "warning", math.random(2000, 2000))  
   SetEntityMaxSpeed(GetVehiclePedIsIn(ped, false), vehicleMPH )     
   IsInSpeedLock = true  
end 
Citizen.Wait(300)   
end
 
function Menu_RideHeight() -- Ride Height MENU
  IsInSuspensionMenu = true 
  local ped = GetPlayerPed(-1)
  local vehicleId = GetVehiclePedIsIn(ped, false) 
   
  ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'smenu2',
      {
        title    = Config.MenuTitle,
        align    = 'right',
        elements = {                        
                {label = 'Ride Level', type = 'slider', value = 0, min = -7, max = 7},
                {label = 'Wheel Width', type = 'slider', value = 50, min = 25, max = 100},
          },
      },
      function(data, menu)
        PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
        if data.current.label == 'Ride Level' then
          SetVehicleSuspensionHeight(vehicleId, data.current.value / -100) 
          NTRP.Notify("🚘 "..data.current.label.." "..data.current.value.."", "gray", math.random(2000, 2000))  
         end
         if data.current.label == 'Wheel Width' then
          --SetVehicleWheelSize(vehicleId,data.current.value)
          SetVehicleWheelWidth(vehicleId,data.current.value / 100)

          NTRP.Notify("🚘 "..data.current.label.." "..data.current.value.."", "gray", math.random(2000, 2000))  
         end
               
        IsInSuspensionMenu = false 
        menu.close()
      end,
      function(data, menu)
        IsInSuspensionMenu = false
        menu.close()
      end
    )
end

if Config.fuelWarning then
  Citizen.CreateThread(function() -- Driver Ped no Drive By
   while true do 
    Citizen.Wait(Config.fuelTimer)
       local ped = GetPlayerPed(-1)
       local vehicleId = GetVehiclePedIsIn(ped, false)
       local driverPed = GetPedInVehicleSeat(vehicleId, -1) 
       local IsInVehicle = IsPedInAnyVehicle(ped, false)
       local IsOnBike = IsPedOnAnyBike(ped)
  
       local fuelLevel =  GetVehicleFuelLevel(vehicleId)
       local roundFuel = Round(fuelLevel)    
   
       if fuelLevel < Config.fuelPercent and IsInVehicle and driverPed == ped and not IsOnBike then
           NTRP.Notify("Low Fuel : ⛽ "..roundFuel.." %", "warning", math.random(3000, 3000))           
           if Config.Chime then
            local volume = 0.3
            TriggerServerEvent('InteractSound_SV:PlayOnSource', 'notbad', volume)
           end 
        end
    end
   end)
  end

RegisterCommand("cam", function(source, args)     
      camState = args[1]        
  if camState == "on" then
      VehCamOff = false
   end
  if camState == "off" then
      VehCamOff = true
   end               
end)
