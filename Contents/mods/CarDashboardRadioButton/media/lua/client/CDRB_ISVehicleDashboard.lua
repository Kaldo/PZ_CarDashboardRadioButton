require "Vehicles/ISUI/ISVehicleDashboard"
require "RadioCom/ISRadioAction"

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
	self.toggleRadioButton.mouseovertext = getText("IGUI_VehiclePartRadio");
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
        else
            -- We are not, but draw it anyway for the driver in red            
            local seat = vehicle:getSeat(playerObj)
            if seat == 1 then
                local fuelX = (self.backgroundTex:getWidth()/2)
                local fuelY = (self.fuelGauge:getCentreY() + 30)
                self.toggleRadioButton:setX(fuelX + 40);
                self.toggleRadioButton:setY(fuelY + 15);
                self.toggleRadioButton:setVisible(true);

                -- Set beginning state
                self:updateRadioIconColor();
            end
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

    local player = getPlayer();
    local playerNum = player:getPlayerNum();
    local radioIso = ISRadioWindow.instancesIso[playerNum];

    if radioIso and radioIso:getIsVisible() then
        radioIso:close();
    else
        local part = self:getRadioPart();
        if part ~= nil then -- if nil, car doesnt have a radio installed
            ISVehicleMenu.onSignalDevice(player, part);
        end
    end
end

function ISVehicleDashboard:isRadioTurnedOn()
    local part = self:getRadioPart();
    if part == nil then
        return false;
    end
    local deviceData = part:getDeviceData();
    if deviceData and part:getInventoryItem() then
        return deviceData:getIsTurnedOn();
    end
    return false;
end

function ISVehicleDashboard:updateRadioIconColor()
    local part = self:getRadioPart();
    if part == nil and self.vehicle:isKeysInIgnition() then
        self.toggleRadioButton.backgroundColor = {r=1, g=0, b=0, a=0.8};
    elseif self:isRadioTurnedOn() then
        self.toggleRadioButton.backgroundColor = {r=0, g=1, b=0, a=0.8};
    else
        self.toggleRadioButton.backgroundColor = {r=1, g=1, b=1, a=0.6};
    end
end

local ISVehicleDashboard_onClickKeys = ISVehicleDashboard.onClickKeys;
function ISVehicleDashboard:onClickKeys()
    ISVehicleDashboard_onClickKeys(self);
    self:updateRadioIconColor();
end

local ISRadioAction_performToggleOnOff = ISRadioAction.performToggleOnOff;
function ISRadioAction:performToggleOnOff()
    ISRadioAction_performToggleOnOff(self);

    local player = getPlayer();
    local thisPlayerData = getPlayerData(player:getPlayerNum());
    local dashboard = thisPlayerData.vehicleDashboard;
    local vehicle = player:getVehicle();
    if dashboard and vehicle then
        dashboard:updateRadioIconColor();
    end
end