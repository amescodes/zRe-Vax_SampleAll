require "TimedActions/ISEquipWeaponAction"

SampleAllEquipScalpelAction = ISEquipWeaponAction:derive("SampleAllEquipScalpelAction");
function SampleAllEquipScalpelAction:stop()
    ISEquipWeaponAction.stop(self);
    if self.worldObjects then
        for _, v in ipairs(self.worldObjects) do
            local sq = v:getSquare()
            if sq then
                for y = sq:getY() - 1, sq:getY() + 1 do
                    for x = sq:getX() - 1, sq:getX() + 1 do
                        local square = getCell():getGridSquare(x, y, sq:getZ())
                        if not (square) then
                            break
                        end
                        for i = 0, square:getStaticMovingObjects():size() - 1 do
                            local obj = square:getStaticMovingObjects():get(i)
                            if instanceof(obj, "IsoDeadBody") then
                                obj:getModData().queued = false
                                obj:transmitModData()
                            end
                        end
                    end
                end
            end
        end
    end
end

function SampleAllEquipScalpelAction:new (character, item, time, primary, twoHands, worldObjects)
	local o = ISEquipWeaponAction.new(self, character, item, time, primary, twoHands);
	setmetatable(o, self);
	self.__index = self;
    o.worldObjects = worldObjects
	return o
end
