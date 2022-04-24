SLASH_SHAKEIT1 = "/shakeit"
ShakeIt_updateInterval = .008

ShakeIt_ShakeIntensity = 70;
ShakeIt_ShakeOffset = 1;
ShakeIt_ShakeDuration = 1;

function ShakeIt_OnLoad(self)
    self.ShakeIt_timeSinceLastUpdate = 0;
    self.ShakeIt_remainingShakeDuration = nil;
    self.ShakeIt_defaultMinimapPoints = {};
    self.ShakeIt_unitGUID = UnitGUID("player");

    ShakeIt_Frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

function ShakeIt_OnEvent(self, event, ...)
    local currentEventInfo = {CombatLogGetCurrentEventInfo()};
    local subevent, _, sourceGUID = select(2, unpack(currentEventInfo));
    local critical

    if subevent == "SWING_DAMAGE" then
        critical = select(18, unpack(currentEventInfo));
    end
    if subevent == "SPELL_DAMAGE" then
        critical = select(21, unpack(currentEventInfo));
    end

    if critical and sourceGUID == self.ShakeIt_unitGUID then
        if self.ShakeIt_remainingShakeDuration == nil then
            ShakeIt_Frame.ShakeIt_remainingShakeDuration = ShakeIt_ShakeDuration;
        end
  	end
end

function ShakeIt_OnUpdate(self, elapsed)
    self.ShakeIt_timeSinceLastUpdate = self.ShakeIt_timeSinceLastUpdate + elapsed;

    while self.ShakeIt_timeSinceLastUpdate > ShakeIt_updateInterval do
        if self.ShakeIt_remainingShakeDuration ~= nil then
            Minimap:ClearAllPoints();
            -- shake it!
            if self.ShakeIt_remainingShakeDuration > 0 then
                self.ShakeIt_remainingShakeDuration = self.ShakeIt_remainingShakeDuration - elapsed;
                local shakeOffset = fastrandom(-100, 100)/(101 - ShakeIt_ShakeIntensity - (ShakeIt_ShakeOffset - 1));
                for _, value in pairs(self.ShakeIt_defaultMinimapPoints) do
                    securecall(function() Minimap:SetPoint(value.point, value.relativeTo, value.relativePoint, value.xOffset + shakeOffset, value.yOffset + shakeOffset) end);
                end
            -- stop and reset
            else
                self.ShakeIt_remainingShakeDuration = nil;
                for _, value in pairs(self.ShakeIt_defaultMinimapPoints) do
                    Minimap:SetPoint(value.point, value.relativeTo, value.relativePoint, value.xOffset, value.yOffset);
                end
            end
        else
            for i = 1, Minimap:GetNumPoints() do
                local point, relativeTo, relativePoint, xOffset, yOffset = Minimap:GetPoint(i);
                self.ShakeIt_defaultMinimapPoints[i] = {
                    point = point,
                    relativeTo = relativeTo,
                    relativePoint = relativePoint,
                    xOffset = xOffset,
                    yOffset = yOffset
                }
            end
        end

        self.ShakeIt_timeSinceLastUpdate = self.ShakeIt_timeSinceLastUpdate - ShakeIt_updateInterval;
    end
end

SlashCmdList.SHAKEIT = function(msg, editBox)
    ShakeIt_Frame.ShakeIt_remainingShakeDuration = ShakeIt_ShakeDuration;
end