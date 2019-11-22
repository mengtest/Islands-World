﻿-- 世界地图数据
-- require("public.class")
IDDBWorldMap = {}
--------------------------------------------
-- IDDBMapCell = class("IDDBMapCell")
-- function IDDBMapCell:ctor(d)
--     self._data = d
--     self.idx = d.idx -- 网格index
--     self.type = d.type --地块类型 1：玩家，2：npc
--     self.cidx = d.cidx--主城idx
--     self.pageIdx = d.pageIdx--所在屏的index
--     self.val1 = d.val1--值1
--     self.val2 = d.val2--值2
--     self.val3 = d.val3--值3
-- end
--------------------------------------------
local mapPageData = {}  -- key:pageIdx, value = list
local mapPageCacheTime = {} -- key:pageIdx, value = timeOut
IDDBWorldMap.ConstTimeOutSec = 60 -- 数据超时秒

---@public 取得一屏的数据
function IDDBWorldMap.getDataByPageIdx(pageIdx)
    if pageIdx == nil then
        return nil
    end
    if mapPageData[pageIdx] == nil or mapPageCacheTime[pageIdx] == nil then
        -- 没有数据，发送服务器
        CLLNet.send(NetProtoIsland.send.getMapDataByPageIdx(pageIdx))
        return
    end
    local timeOut = mapPageCacheTime[pageIdx]
    if DateEx.nowMS - timeOut > 0 then
        --说明已经超时了
        CLLNet.send(NetProtoIsland.send.getMapDataByPageIdx(pageIdx))
        return
    end

    return mapPageData[pageIdx]
end

---@public 取得一屏数据
---@param data NetProtoIsland.ST_mapPage
function IDDBWorldMap.onGetMapPageData(data)
    local pageIdx = bio2number(data.pageIdx)
    local cells = data.cells

    local cellmap = {}
    ---@type NetProtoIsland.ST_mapCell
    for i, v in ipairs(cells) do
        cellmap[bio2number(v.idx)] = v
    end
    mapPageData[pageIdx] = { list = cells, map = cellmap }
    mapPageCacheTime[pageIdx] = DateEx.nowMS + IDDBWorldMap.ConstTimeOutSec * 1000
    if MyCfg.mode == GameMode.map then
        IDWorldMap.onGetMapPageData(pageIdx, mapPageData[pageIdx])
    end
end

---@param mapCell NetProtoIsland.ST_mapCell
function IDDBWorldMap.onMapCellChg(mapCell)
    local pageIdx = bio2number(mapCell.pageIdx)
    local pageData = mapPageData[pageIdx]
    if pageData then
        local list = pageData.list
        local idx = bio2number(mapCell.idx)
        for i,v in ipairs(list) do
            if bio2number(v.idx) == idx then
                table.remove(list, i)
                break
            end
        end
        table.insert(list, mapCell)
        pageData.map[idx] = mapCell
        
        if MyCfg.mode == GameMode.map then
            if IDWorldMap then
                IDWorldMap.onMapCellChg(mapCell)
            end
        end
    end
end


function IDDBWorldMap.clean()
    mapPageData = {}  -- key:pageIdx, value = list
    mapPageCacheTime = {} -- key:pageIdx, value = timeOut
end
--------------------------------------------
return IDDBWorldMap
