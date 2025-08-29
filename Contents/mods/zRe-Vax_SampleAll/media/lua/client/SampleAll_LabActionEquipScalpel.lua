require "TimedActions/ISEquipWeaponAction"

SampleAllEquipScalpelAction = ISEquipWeaponAction:derive("SampleAllEquipScalpelAction");
function SampleAllEquipScalpelAction:stop()
    SampleAll_DequeueCorpses(self.worldObjects)
    ISEquipWeaponAction.stop(self);
end

function SampleAllEquipScalpelAction:forceCancel()
	-- called when action is deleted action queue without being started
    SampleAll_DequeueCorpses(self.worldObjects)
    ISEquipWeaponAction.forceCancel(self);
end

function SampleAllEquipScalpelAction:new (character, item, time, primary, twoHands, worldObjects)
	local o = ISEquipWeaponAction.new(self, character, item, time, primary, twoHands);
	setmetatable(o, self);
	self.__index = self;
    o.worldObjects = worldObjects
	return o
end
