local function containsId(list,id)
    if not id then
        return false
    end
    for _, it in ipairs(list) do
        if it == id then
            return true
        end
    end

    return false
end

-- referenced from zRe Vax 2.0
local function predicateNotBroken(item)
	return not item:isBroken();
end

-- referenced from zRe Vax 2.0
local function LabRecipes_WMOnCorpseAutopsyAll(player, worldobjects)

	local inv = player:getInventory();
	local scalpel = inv:getFirstTypeEvalRecurse("Scalpel", predicateNotBroken);
	if scalpel and scalpel.isRequiresEquippedBothHands then
		ISInventoryPaneContextMenu.equipWeapon(scalpel, true, false, player:getPlayerNum());
		local corpseQueue = {}
		for _, v in ipairs(worldobjects) do
			local sq = v:getSquare();
			if sq then
				for y = sq:getY()-1, sq:getY()+1 do
					for x = sq:getX()-1, sq:getX()+1 do
						local square = getCell():getGridSquare(x, y, sq:getZ());
						if not(square) then
							break;
						end
						for i = 0, square:getStaticMovingObjects():size()-1 do
							local obj = square:getStaticMovingObjects():get(i);
							if instanceof(obj, "IsoDeadBody") then									
								local notFresh = obj:isSkeleton();
								local notZombie = not(obj:isZombie());
								local notOrgans = obj:getModData().Autopsy;
								local inQueue = containsId(corpseQueue,obj)
								if not(notFresh or notZombie or notOrgans or inQueue) and luautils.walkAdj(player, obj:getSquare(), true) then
									ISTimedActionQueue.add(LabActionMakeAutopsy:new(player, obj, square, nil))
									table.insert(corpseQueue,obj)
								end
							end
						end
					end
				end
			end
		end
	end
end

-- referenced from zRe Vax 2.0
local function LabRecipes_CreateCheckTooltip(option, inventory, moduleName, itemTypes, count, noBroken) 
	local n = 0;
	for _, v in ipairs(itemTypes) do
		if noBroken then
			n = n+inventory:getCountTypeEvalRecurse(v,predicateNotBroken);
		else
			n = n+inventory:getItemCountRecurse(v);
		end
	end
	local s = moduleName.."."..itemTypes[1];
	if count == 1 then
		option.toolTip.description = option.toolTip.description..string.format(" -  <%s> %s <RGB:1,1,1> <LINE>", (n<count) and "RED" or "GREEN", getItemNameFromFullType(s));
	else
		option.toolTip.description = option.toolTip.description..string.format(" -  <%s> %s ( %d / %d ) <RGB:1,1,1> <LINE>", (n<count) and "RED" or "GREEN", getItemNameFromFullType(s), math.min(n,count), count);
	end
	return n >= count;
end

local function zreVaxSampleAll_AddSampleAllOption(playerNum, context, worldobjects, test)
	if test and ISWorldObjectContextMenu.Test then
		return true;
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
			if not(subMenuOption.notAvailable) then
				notAvailable = false
				break
			end
		end
		subMenu:addOptionOnTop("Sample All",player,LabRecipes_WMOnCorpseAutopsyAll,worldobjects)
		local sampleAllOpt = subMenu.options[1]
		if sampleAllOpt then
			local tooltip = ISInventoryPaneContextMenu.addToolTip();
			sampleAllOpt.toolTip = tooltip;
			tooltip.description = tooltip.description..getText("ContextMenu_LabMustHaveItems");

			local ok = true;
			local inv = player:getInventory()
			ok = LabRecipes_CreateCheckTooltip(sampleAllOpt, inv, "Base", {"Scalpel"}, 1, true) and ok;
			ok = LabRecipes_CreateCheckTooltip(sampleAllOpt, inv, "Base", {"Tweezers"}, 1) and ok;
			sampleAllOpt.notAvailable = notAvailable or not(ok);
		end
	end
end

Events.OnFillWorldObjectContextMenu.Add(zreVaxSampleAll_AddSampleAllOption);