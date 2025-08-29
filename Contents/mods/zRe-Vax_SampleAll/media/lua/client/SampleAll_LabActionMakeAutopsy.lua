
SampleAll_LabActionMakeAutopsy = LabActionMakeAutopsy:derive("SampleAll_LabActionMakeAutopsy");
function SampleAll_LabActionMakeAutopsy:stop()
    SampleAll_DequeueCorpses(self.worldObjects)
    LabActionMakeAutopsy.stop(self);
end

function SampleAll_LabActionMakeAutopsy:forceStop()
    SampleAll_DequeueCorpses(self.worldObjects)
    LabActionMakeAutopsy.forceStop(self);
end

function SampleAll_LabActionMakeAutopsy:forceCancel()
    -- called when action is deleted action queue without being started
    SampleAll_DequeueCorpses(self.worldObjects)
    LabActionMakeAutopsy.forceCancel(self);
end

function SampleAll_LabActionMakeAutopsy:new(character, corpse, square, bottom, worldObjects)
    local o = LabActionMakeAutopsy.new(self, character, corpse, square, bottom);
    setmetatable(o, self);
    self.__index = self;
    o.worldObjects = worldObjects
    return o
end
