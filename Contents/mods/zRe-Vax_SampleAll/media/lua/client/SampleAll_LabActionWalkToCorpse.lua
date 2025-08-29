require "TimedActions/ISWalkToTimedAction"

SampleAllWalkToCorpseAction = ISWalkToTimedAction:derive("SampleAllEquipScalpelAction");
function SampleAllWalkToCorpseAction:stop()
    SampleAll_DequeueCorpses(self.worldObjects)
    ISWalkToTimedAction.stop(self);
end

function SampleAllWalkToCorpseAction:forceStop()
    SampleAll_DequeueCorpses(self.worldObjects)
    ISWalkToTimedAction.forceStop(self);
end

function SampleAllWalkToCorpseAction:forceCancel()
	-- called when action is deleted action queue without being started
    SampleAll_DequeueCorpses(self.worldObjects)
    ISWalkToTimedAction.forceCancel(self);
end

function SampleAllWalkToCorpseAction:new (character, location, additionalTest, additionalContext, worldObjects)
	local o = ISWalkToTimedAction.new(self, character,  location, additionalTest, additionalContext);
	setmetatable(o, self);
	self.__index = self;
    o.worldObjects = worldObjects
	return o
end
