local function updateBodiesQueued(worldobjects, queueBool)
    if worldobjects then
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
                                if queueBool then
                                    SampleAll_QueueCorpse(obj)
                                else
                                    SampleAll_DequeueCorpse(obj)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function SampleAll_QueueCorpses(worldobjects)
    updateBodiesQueued(worldobjects,true)
end

function SampleAll_DequeueCorpses(worldobjects)
    updateBodiesQueued(worldobjects,false)
end

function SampleAll_DequeueCorpse(corpse)
    if corpse then
        corpse:getModData().queued = false
        corpse:transmitModData()
    end

end
function SampleAll_QueueCorpse(corpse)
    if corpse then
        corpse:getModData().queued = true
        corpse:transmitModData()
    end
end