
-- local old_LabActionMakeAutopsy_stop = LabActionMakeAutopsy.stop
-- function LabActionMakeAutopsy:stop()
--     old_LabActionMakeAutopsy_stop(self)
-- 	if self.corpse then
--         self.corpse:getModData().queued = false
-- 		self.corpse:transmitModData()
--     end
-- end

-- local old_LabActionMakeAutopsy_perform = LabActionMakeAutopsy.perform
-- function LabActionMakeAutopsy:perform()
--     old_LabActionMakeAutopsy_perform(self)
-- 	if self.corpse then
--         self.corpse:getModData().queued = false
-- 		self.corpse:transmitModData()
--     end
-- end



require "client/LabActionMakeAutopsy"

SampleAll_LabActionMakeAutopsy = LabActionMakeAutopsy:derive("SampleAll_LabActionMakeAutopsy");
function SampleAll_LabActionMakeAutopsy:stop()
    LabActionMakeAutopsy.stop(self);
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

function SampleAll_LabActionMakeAutopsy:new(character, corpse, square, bottom, worldObjects)
	local o = LabActionMakeAutopsy.new(self, character, corpse, square, bottom);
	setmetatable(o, self);
	self.__index = self;
    o.worldObjects = worldObjects
	return o
end
