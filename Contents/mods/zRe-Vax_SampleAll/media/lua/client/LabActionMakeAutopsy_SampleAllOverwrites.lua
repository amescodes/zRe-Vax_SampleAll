
local old_LabActionMakeAutopsy_stop = LabActionMakeAutopsy.stop
function LabActionMakeAutopsy:stop()
    SampleAll_DequeueCorpse(self.corpse)
    old_LabActionMakeAutopsy_stop(self)
end

local old_LabActionMakeAutopsy_perform = LabActionMakeAutopsy.perform
function LabActionMakeAutopsy:perform()
    old_LabActionMakeAutopsy_perform(self)
    SampleAll_DequeueCorpse(self.corpse)
end

local old_LabActionMakeAutopsy_forceStop = LabActionMakeAutopsy.forceStop
function LabActionMakeAutopsy:forceStop()
    SampleAll_DequeueCorpse(self.corpse)
    old_LabActionMakeAutopsy_forceStop(self)
end

local old_LabActionMakeAutopsy_forceCancel = LabActionMakeAutopsy.forceCancel
function LabActionMakeAutopsy:forceCancel()
    SampleAll_DequeueCorpse(self.corpse)
    old_LabActionMakeAutopsy_forceCancel(self)
end

-- not sure if needed, but wasn't set up right in the og mod
function LabActionMakeAutopsy:waitToStart()
	self.character:faceThisObject(self.corpse or self.bottom);
	return self.character:shouldBeTurning();
end

local old_LabActionMakeAutopsy_new = LabActionMakeAutopsy.new
function LabActionMakeAutopsy:new(character, corpse, square, bottom)
    SampleAll_QueueCorpse(corpse)
    return old_LabActionMakeAutopsy_new(self,character, corpse, square, bottom)
end