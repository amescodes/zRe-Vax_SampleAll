require "TimedActions/ISWalkToTimedAction"

SampleAllWalkToCorpseAction = ISWalkToTimedAction:derive("SampleAllEquipScalpelAction");
function SampleAllWalkToCorpseAction:stop()
    ISWalkToTimedAction.stop(self);
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

function SampleAllWalkToCorpseAction:new (character, location, additionalTest, additionalContext, worldObjects)
	local o = ISWalkToTimedAction.new(self, character,  location, additionalTest, additionalContext);
	setmetatable(o, self);
	self.__index = self;
    o.worldObjects = worldObjects
	return o
end
