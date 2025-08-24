-- referenced from PZ B41 luautils.walkAdj
local function sampleAll_walkAdj(playerObj, square, worldObjs)
	square = luautils.getCorrectSquareForWall(playerObj, square);
	local diffX = math.abs(square:getX() + 0.5 - playerObj:getX());
	local diffY = math.abs(square:getY() + 0.5 - playerObj:getY());
	if diffX <= 1.6 and diffY <= 1.6 then
		return true;
	end
	local adjacent = AdjacentFreeTileFinder.Find(square, playerObj);
	if adjacent ~= nil then
		ISTimedActionQueue.add(SampleAllWalkToCorpseAction:new(playerObj, adjacent, nil,nil,worldObjs));
		return true;
	else
		return  false;
	end
end

-- referenced from PZ B41 ISInventoryPaneContextMenu.equipWeapon
local function equipScalpel(weapon, primary, twoHands, playerObj, worldObjs)
	if isForceDropHeavyItem(playerObj:getPrimaryHandItem()) then
		ISTimedActionQueue.add(ISUnequipAction:new(playerObj, playerObj:getPrimaryHandItem(), 50));
	end
	ISInventoryPaneContextMenu.transferIfNeeded(playerObj, weapon)
    ISTimedActionQueue.add(SampleAllEquipScalpelAction:new(playerObj, weapon, 50, primary, twoHands,worldObjs));
end

-- from zRe Vax 2.0
local function predicateNotBroken(item)
    return not item:isBroken()
end

-- referenced from zRe Vax 2.0
local function LabRecipes_WMOnCorpseAutopsyAll(player, worldobjects)
    local inv = player:getInventory()
    local scalpel = inv:getFirstTypeEvalRecurse("Scalpel", predicateNotBroken)
    if scalpel and scalpel.isRequiresEquippedBothHands then
		equipScalpel(scalpel, true, false, player,worldobjects)
        for _, v in ipairs(worldobjects) do
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
                                local notFresh = obj:isSkeleton()
                                local notZombie = not (obj:isZombie())
                                local notOrgans = obj:getModData().Autopsy
                                local inQueue = obj:getModData().queued
                                if not (notFresh or notZombie or notOrgans or inQueue) and
                                    sampleAll_walkAdj(player, obj:getSquare(), worldobjects) then
                                    ISTimedActionQueue.add(SampleAll_LabActionMakeAutopsy:new(player, obj, square, nil, worldobjects))
                                    obj:getModData().queued = true
                                    obj:transmitModData()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- from zRe Vax 2.0
local function LabRecipes_CreateCheckTooltip(option, inventory, moduleName, itemTypes, count, noBroken)
    local n = 0
    for _, v in ipairs(itemTypes) do
        if noBroken then
            n = n + inventory:getCountTypeEvalRecurse(v, predicateNotBroken)
        else
            n = n + inventory:getItemCountRecurse(v)
        end
    end
    local s = moduleName .. "." .. itemTypes[1]
    if count == 1 then
        option.toolTip.description = option.toolTip.description ..
                                         string.format(" -  <%s> %s <RGB:1,1,1> <LINE>",
                (n < count) and "RED" or "GREEN", getItemNameFromFullType(s))
    else
        option.toolTip.description = option.toolTip.description ..
                                         string.format(" -  <%s> %s ( %d / %d ) <RGB:1,1,1> <LINE>",
                (n < count) and "RED" or "GREEN", getItemNameFromFullType(s), math.min(n, count), count)
    end
    return n >= count
end

local function zreVaxSampleAll_AddSampleAllOption(playerNum, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then
        return true
    end
    local player = getSpecificPlayer(playerNum)
    local subMenu = nil
    local subMenuName = getText("ContextMenu_LabCorpseAutopsy")
    for i = 1, context.numOptions - 1 do
        local option = context.options[i]
        if option.name == subMenuName then
            subMenu = context:getSubMenu(option.subOption)
            break
        end
    end

    if subMenu ~= nil then
        local notAvailable = true
        for i = 1, subMenu.numOptions - 1 do
            local subMenuOption = subMenu.options[i]
            local corpse = subMenuOption.param1
            -- check if in queue, make unavailable if true
            if corpse and instanceof(corpse, "IsoDeadBody") then
                if corpse:getModData().queued then
                    subMenuOption.notAvailable = true
                end
            end
            -- if any are available, sample all is also
            if not (subMenuOption.notAvailable) then
                notAvailable = false
            end
        end
        subMenu:addOptionOnTop(getText("ContextMenu_SampleAllCorpses"), player, LabRecipes_WMOnCorpseAutopsyAll, worldobjects)
        local sampleAllOpt = subMenu.options[1]
        if sampleAllOpt then
            local tooltip = ISInventoryPaneContextMenu.addToolTip()
            sampleAllOpt.toolTip = tooltip
            tooltip.description = tooltip.description .. getText("ContextMenu_LabMustHaveItems")

            local ok = true
            local inv = player:getInventory()
            ok = LabRecipes_CreateCheckTooltip(sampleAllOpt, inv, "Base", {"Scalpel"}, 1, true) and ok
            ok = LabRecipes_CreateCheckTooltip(sampleAllOpt, inv, "Base", {"Tweezers"}, 1) and ok
            sampleAllOpt.notAvailable = notAvailable or not (ok)
        end
    end
end

Events.OnFillWorldObjectContextMenu.Add(zreVaxSampleAll_AddSampleAllOption)