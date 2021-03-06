﻿require("public.class")

---@class IDDBPlayer 玩家数据
IDDBPlayer = class("IDDBPlayer")
---@type IDDBPlayer
IDDBPlayer.myself = nil
---@param d NetProtoIsland.ST_player
function IDDBPlayer:ctor(d)
    self._data = d
    self.idx = d.idx --  唯一标识 int
    self.diam = d.diam -- 钻石  int
    self.name = d.name --  string
    self.status = d.status --  状态 1：正常 int int
    self.cityidx = d.cityidx --  城池id int int
    self.unionidx = d.unionidx --  联盟id int int
    self.lev = d.lev --  int
    self.attacking = d.attacking
    self.beingattacked = d.beingattacked
end
---@param player IDDBPlayer
---@return boolean
function IDDBPlayer:equal(player)
    if not player then
        return false
    end
    return bio2number(self.idx) == bio2number(player.idx)
end

function IDDBPlayer:toMap()
    return self._data
end
--------------------------------------------
return IDDBPlayer
