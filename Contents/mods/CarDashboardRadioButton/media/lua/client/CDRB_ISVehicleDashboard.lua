require "Vehicles/ISUI/ISVehicleDashboard"

local radioIcon = getTexture("Icon_Radio_Speaker");

local ISVehicleDashboard_createChildren = ISVehicleDashboard.createChildren;
function ISVehicleDashboard:createChildren()
    ISVehicleDashboard_createChildren(self);

    local w = radioIcon:getWidthOrig();
    local h = radioIcon:getHeightOrig();

    self.toggleRadioButton = ISImage:new(0, 0, w, h, radioIcon);
    self.toggleRadioButton.scaledWidth = w/2;
    self.toggleRadioButton.scaledHeight = h/2;
    self.toggleRadioButton:initialise();
    self.toggleRadioButton.backgroundColor = {r=1, g=1, b=1, a=0.8};
    self.toggleRadioButton:instantiate();
    self.toggleRadioButton.onclick = ISVehicleDashboard.onToggleRadioClicked;
    self.toggleRadioButton.target = self;
	self.toggleRadioButton.mouseovertext = "Vehicle Radio";
	self:addChild(self.toggleRadioButton);
end

local ISVehicleDashboard_setVehicle = ISVehicleDashboard.setVehicle;
function ISVehicleDashboard:setVehicle(vehicle)
    ISVehicleDashboard_setVehicle(self, vehicle);

    if not vehicle then
		return
	end

    if vehicle then
        -- Check if we are the driver in a car with a radio
        local part = self:getRadioPart();
        if part then
            -- We are
            local fuelX = (self.backgroundTex:getWidth()/2)
            local fuelY = (self.fuelGauge:getCentreY() + 30)
            self.toggleRadioButton:setX(fuelX + 40);
            self.toggleRadioButton:setY(fuelY + 15);
            self.toggleRadioButton:setVisible(true);

            -- Set beginning state
            self:updateRadioIconColor();
            return;
        end
    end
end

function ISVehicleDashboard:getRadioPart()
    local vehicle = self.vehicle;
    local seat = vehicle:getSeat(playerObj)
    if seat <= 1 then -- only front seats can access the radio
        for partIndex=1, vehicle:getPartCount() do
            local part = vehicle:getPartByIndex(partIndex-1)
            if part:getDeviceData() and part:getInventoryItem() then
                return part;
            end
        end
    end
    return nil;
end

-- local isOn = false;
function ISVehicleDashboard:onToggleRadioClicked(button, x, y)
	if getGameSpeed() == 0 then return; end
	if getGameSpeed() > 1 then setGameSpeed(1); end

    -- local playerObj = getSpecificPlayer(0);
    local player = getPlayer();
    local playerNum = player:getPlayerNum();
    local radioIso = ISRadioWindow.instancesIso[playerNum];

    if radioIso and radioIso:getIsVisible() then --  radioIso and radioIso.modules[1].enabled 
        radioIso:close();
    else
        local part = self:getRadioPart();
        ISVehicleMenu.onSignalDevice(player, part);
    end


    -- if isOn then
    --     isOn = false;
    --     self.toggleRadioButton.backgroundColor = {r=1, g=1, b=1, a=0.6};
    --     -- if ISRadioWindow.instances[playerNum] then
    --     --     ISRadioWindow.instances[playerNum]:close();
    --     -- end
    --     if ISRadioWindow.instancesIso[playerNum] then
    --         ISRadioWindow.instancesIso[playerNum]:close();
    --     end
    -- else
    --     isOn = true;
    --     self.toggleRadioButton.backgroundColor = {r=0, g=1, b=0, a=0.8};
    --     ISVehicleMenu.onSignalDevice(player, part);
    -- end
    -- return false
end

function ISVehicleDashboard:isRadioTurnedOn()
    -- local player = getPlayer();
    -- local playerNum = player:getPlayerNum();
    -- local radioIso = ISRadioWindow.instancesIso[playerNum];
    -- local deviceData = radioIso.deviceData;
    -- return deviceData:getIsTurnedOn();
    local part = self:getRadioPart();
    local deviceData = part:getDeviceData();
    if deviceData and part:getInventoryItem() then
        return deviceData:getIsTurnedOn();
    end
    return false;
end

function ISVehicleDashboard:updateRadioIconColor()
    if self:isRadioTurnedOn() then
        self.toggleRadioButton.backgroundColor = {r=0, g=1, b=0, a=0.8};
    else
        self.toggleRadioButton.backgroundColor = {r=1, g=1, b=1, a=0.6};
    end
end

local ISRadioAction_performToggleOnOff = ISRadioAction.performToggleOnOff;
function ISRadioAction:performToggleOnOff()
    ISRadioAction_performToggleOnOff(self);
    -- if self:isValidToggleOnOff() then
    --     self.deviceData:setIsTurnedOn( not self.deviceData:getIsTurnedOn() );
    -- end
    local player = getPlayer();
    local vehicle = player:getVehicle();
    if vehicle then
        vehicle:updateRadioIconColor();
    end
end