local ObjectManager = require("managers.object.object_manager")
includeFile("gcw/recruiters/factionPerkData.lua")

recruiterScreenplay = Object:new {
  minimumFactionStanding = 0,

  factionHashCode = { rebel = 370444368, imperial = 3679112276 },

  errorCodes =  {
    SUCCESS = 0, INVENTORYFULL = 1,  NOTENOUGHFACTION = 2, GENERALERROR = 3, ITEMCOST = 4, INVENTORYERROR = 5,
    TEMPLATEPATHERROR = 6, GIVEERROR = 7, DATAPADFULL = 8, DATAPADERROR = 9, TOOMANYHIRELINGS = 10,
  }
}

function recruiterScreenplay:getFactionHashCode(faction)
  if (faction == "rebel") then
    return self.factionHashCode.rebel
  elseif (faction == "imperial") then
    return self.factionHashCode.imperial
  else
    return nil
  end
end

function recruiterScreenplay:getFactionFromHashCode(hash)
  if (hash == self.factionHashCode.rebel) then
    return "rebel"
  elseif (hash == self.factionHashCode.imperial) then
    return "imperial"
  else
    return nil
  end
end

function recruiterScreenplay:getRecruiterFactionHashCode(pNpc)
  local faction = self:getRecruiterFaction(pNpc)
  if (faction == "rebel") then
    return self.factionHashCode.rebel
  elseif (faction == "imperial") then
    return self.factionHashCode.imperial
  else
    return nil
  end
end

function recruiterScreenplay:getRecruiterFaction(pNpc)
  if pNpc == nil then
    return nil
  end

  return self:getFactionFromHashCode(TangibleObject(pNpc):getFaction())
end

function recruiterScreenplay:getRecruiterEnemyFaction(pNpc)
  if (self:getRecruiterFaction(pNpc) == "rebel") then
    return self:getFactionHashCode("imperial")
  elseif (self:getRecruiterFaction(pNpc) == "imperial") then
    return self:getFactionHashCode("rebel")
  end
  return nil
end

function recruiterScreenplay:getRecruiterEnemyFactionHashCode(pNpc)
  if (self:getRecruiterFaction(pNpc) == "rebel") then
    return self.factionHashCode.imperial
  elseif (self:getRecruiterFaction(pNpc) == "imperial") then
    return self.factionHashCode.rebel
  end
  return nil
end

function recruiterScreenplay:grantBribe(pRecruiter, pPlayer, cost, factionPoints)
  if (pRecruiter == nil or pPlayer == nil) then
    return
  end

  local pGhost = CreatureObject(pPlayer):getPlayerObject()

  if (pGhost == nil) then
    return
  end

  if (CreatureObject(pPlayer):getCashCredits() >= cost) then
    CreatureObject(pPlayer):subtractCashCredits(cost)
    PlayerObject(pGhost):increaseFactionStanding(self:getRecruiterFaction(pRecruiter), factionPoints)
  end
end

function recruiterScreenplay:getFactionDataTable(faction)
  if (faction == "rebel") then
    return rebelRewardData
  elseif (faction == "imperial") then
    return imperialRewardData
  else
    return nil
  end
end

function recruiterScreenplay:getMinimumFactionStanding()
  return self.minimumFactionStanding
end

function recruiterScreenplay:isWeapon(faction, strItem)
  local factionRewardData = self:getFactionDataTable(faction)
  return factionRewardData.weaponsArmor[strItem] ~= nil and factionRewardData.weaponsArmor[strItem].type == factionRewardType.weapon
end

function recruiterScreenplay:isArmor(faction, strItem)
  local factionRewardData = self:getFactionDataTable(faction)
  return factionRewardData.weaponsArmor[strItem] ~= nil and factionRewardData.weaponsArmor[strItem].type == factionRewardType.armor
end


function recruiterScreenplay:isUniform(faction, strItem)
  if faction == "rebel" then
    return false
  end
  local factionRewardData = self:getFactionDataTable(faction)
  return factionRewardData.uniforms[strItem] ~= nil
end

function recruiterScreenplay:isHireling(faction, strItem)
  local factionRewardData = self:getFactionDataTable(faction)
  return factionRewardData.hirelings[strItem] ~= nil
end

function recruiterScreenplay:isFurniture(faction, strItem)
  local factionRewardData = self:getFactionDataTable(faction)
  return factionRewardData.furniture[strItem] ~= nil
end

function recruiterScreenplay:isContainer(faction, strItem)
  local factionRewardData = self:getFactionDataTable(faction)
  return factionRewardData.furniture[strItem] ~= nil and factionRewardData.furniture[strItem].type == factionRewardType.container
end

function recruiterScreenplay:isTerminal(faction, strItem)
  local factionRewardData = self:getFactionDataTable(faction)
  return factionRewardData.furniture[strItem] ~= nil and factionRewardData.furniture[strItem].type == factionRewardType.terminal
end

function recruiterScreenplay:isInstallation(faction, strItem)
  local factionRewardData = self:getFactionDataTable(faction)
  return factionRewardData.installations[strItem] ~= nil and factionRewardData.installations[strItem].type == factionRewardType.installation
end

function recruiterScreenplay:getWeaponsArmorOptions(faction, gcwDiscount, smugglerDiscount)
  local optionsTable = { }
  local factionRewardData = self:getFactionDataTable(faction)
  for k,v in pairs(factionRewardData.weaponsArmorList) do
    if ( factionRewardData.weaponsArmor[v] ~= nil and factionRewardData.weaponsArmor[v].display ~= nil and factionRewardData.weaponsArmor[v].cost ~= nil ) then
      local option = {self:generateSuiString(factionRewardData.weaponsArmor[v].display, math.ceil(factionRewardData.weaponsArmor[v].cost * gcwDiscount * smugglerDiscount)), 0}
      table.insert(optionsTable, option)
    end
  end
  return optionsTable
end

function recruiterScreenplay:getFurnitureOptions(faction, gcwDiscount, smugglerDiscount)
  local optionsTable = { }
  local factionRewardData = self:getFactionDataTable(faction)
  for k,v in pairs(factionRewardData.furnitureList) do
    if ( factionRewardData.furniture[v] ~= nil and factionRewardData.furniture[v].display ~= nil and factionRewardData.furniture[v].cost ~= nil ) then
      local option = {self:generateSuiString(factionRewardData.furniture[v].display, math.ceil(factionRewardData.furniture[v].cost * gcwDiscount * smugglerDiscount)), 0}
      table.insert(optionsTable, option)
    end
  end
  return optionsTable
end

function recruiterScreenplay:getInstallationsOptions(faction, gcwDiscount, smugglerDiscount)
  local optionsTable = { }
  local factionRewardData = self:getFactionDataTable(faction)
  for k,v in pairs(factionRewardData.installationsList) do
    if ( factionRewardData.installations[v] ~= nil and factionRewardData.installations[v].display ~= nil and factionRewardData.installations[v].cost ~= nil ) then
      local option = {self:generateSuiString(factionRewardData.installations[v].display, math.ceil(factionRewardData.installations[v].cost * gcwDiscount * smugglerDiscount)), 0}
      table.insert(optionsTable, option)
    end
  end
  return optionsTable
end

function recruiterScreenplay:getHirelingsOptions(faction, gcwDiscount, smugglerDiscount)
  local optionsTable = { }
  local factionRewardData = self:getFactionDataTable(faction)
  for k,v in pairs(factionRewardData.hirelingList) do
    if ( factionRewardData.hirelings[v] ~= nil and factionRewardData.hirelings[v].display ~= nil and factionRewardData.hirelings[v].cost ~= nil ) then
      local option = {self:generateSuiString(factionRewardData.hirelings[v].display, math.ceil(factionRewardData.hirelings[v].cost * gcwDiscount * smugglerDiscount)), 0}
      table.insert(optionsTable, option)
    end
  end
  return optionsTable
end

function recruiterScreenplay:getUniformsOptions(faction, gcwDiscount, smugglerDiscount)
  local optionsTable = { }
  local factionRewardData = self:getFactionDataTable(faction)
  for k,v in pairs(factionRewardData.uniformList) do
    if ( factionRewardData.uniforms[v] ~= nil and factionRewardData.uniforms[v].display ~= nil and factionRewardData.uniforms[v].cost ~= nil ) then
      local option = {self:generateSuiString(factionRewardData.uniforms[v].display, math.ceil(factionRewardData.uniforms[v].cost * gcwDiscount * smugglerDiscount)), 0}
      table.insert(optionsTable, option)
    end
  end
  return optionsTable
end

function recruiterScreenplay:generateSuiString(item, cost)
  return getStringId(item) .. " (Cost: " .. cost .. ")"
end

function recruiterScreenplay:getItemCost(faction, itemString)
  local factionRewardData = self:getFactionDataTable(faction)
  if self:isWeapon(faction, itemString) or self:isArmor(faction, itemString)  and factionRewardData.weaponsArmor[itemString] ~= nil and factionRewardData.weaponsArmor[itemString].cost ~= nil then
    return factionRewardData.weaponsArmor[itemString].cost
  elseif self:isUniform(faction, itemString) and factionRewardData.uniforms[itemString].cost ~= nil then
    return factionRewardData.uniforms[itemString].cost
  elseif self:isFurniture(faction, itemString) and factionRewardData.furniture[itemString].cost ~= nil then
    return factionRewardData.furniture[itemString].cost
  elseif self:isInstallation(faction, itemString) and factionRewardData.installations[itemString].cost ~= nil then
    return factionRewardData.installations[itemString].cost
  elseif self:isHireling(faction, itemString) and factionRewardData.hirelings[itemString].cost ~= nil then
    return factionRewardData.hirelings[itemString].cost
  end
  return nil
end

function recruiterScreenplay:getTemplatePath(faction, itemString)
  local factionRewardData = self:getFactionDataTable(faction)
  if self:isWeapon(faction, itemString) or self:isArmor(faction, itemString) then
    return factionRewardData.weaponsArmor[itemString].item
  elseif self:isUniform(faction, itemString) then
    return factionRewardData.uniforms[itemString].item
  elseif self:isFurniture(faction, itemString) then
    return factionRewardData.furniture[itemString].item
  elseif self:isInstallation(faction, itemString) then
    return factionRewardData.installations[itemString].item
  elseif self:isHireling(faction, itemString) then
    return factionRewardData.hirelings[itemString].item
  end
  return nil
end

function recruiterScreenplay:getDisplayName(faction, itemString)
  local factionRewardData = self:getFactionDataTable(faction)
  if self:isWeapon(faction, itemString) or self:isArmor(faction, itemString) then
    return factionRewardData.weaponsArmor[itemString].display
  elseif self:isUniform(faction, itemString) then
    return factionRewardData.uniforms[itemString].display
  elseif self:isFurniture(faction, itemString) then
    return factionRewardData.furniture[itemString].display
  elseif self:isInstallation(faction, itemString) then
    return factionRewardData.installations[itemString].display
  elseif self:isHireling(faction, itemString) then
    return factionRewardData.hirelings[itemString].display
  end
  return nil
end


function recruiterScreenplay:getGeneratedObjectTemplate(faction, itemString)
  local factionRewardData = self:getFactionDataTable(faction)
  if self:isInstallation(faction, itemString) and factionRewardData.installations[itemString].generatedObjectTemplate ~= nil then
    return factionRewardData.installations[itemString].generatedObjectTemplate
  end
  return nil
end

function recruiterScreenplay:getControlledObjectTemplate(faction, itemString)
  local factionRewardData = self:getFactionDataTable(faction)
  if self:isHireling(faction, itemString) and factionRewardData.hirelings[itemString].controlledObjectTemplate ~= nil then
    return factionRewardData.hirelings[itemString].controlledObjectTemplate
  end
  return nil
end

function recruiterScreenplay:getBonusItems(faction, itemString)
  local factionRewardData = self:getFactionDataTable(faction)
  if self:isInstallation(faction, itemString) and factionRewardData.installations[itemString].bonus ~= nil then
    return factionRewardData.installations[itemString].bonus
  end
  return nil
end

function recruiterScreenplay:getBonusItemCount(faction, itemString)
  local factionRewardData = self:getFactionDataTable(faction)
  if self:isInstallation(faction, itemString) and factionRewardData.installations[itemString].bonus ~= nil then
    return #factionRewardData.installations[itemString].bonus
  end
  return 0
end

function recruiterScreenplay:sendPurchaseSui(pNpc, pPlayer, screenID)
  if (pNpc == nil or pPlayer == nil) then
    return
  end

  local faction = self:getRecruiterFaction(pNpc)
  local gcwDiscount = getGCWDiscount(pPlayer)
  local smugglerDiscount = self:getSmugglerDiscount(pPlayer)

  writeStringData(CreatureObject(pPlayer):getObjectID() .. ":faction_purchase", screenID)
  local suiManager = LuaSuiManager()
  local options = { }
  if screenID == "fp_furniture" then
    options = self:getFurnitureOptions(faction, gcwDiscount, smugglerDiscount)
  elseif screenID == "fp_weapons_armor" then
    options = self:getWeaponsArmorOptions(faction, gcwDiscount, smugglerDiscount)
  elseif screenID == "fp_installations" then
    options = self:getInstallationsOptions(faction, gcwDiscount, smugglerDiscount)
  elseif screenID == "fp_uniforms" then
    options = self:getUniformsOptions(faction, gcwDiscount, smugglerDiscount)
  elseif screenID == "fp_hirelings" then
    options = self:getHirelingsOptions(faction, gcwDiscount, smugglerDiscount)
  end

  suiManager:sendListBox(pNpc, pPlayer, "@faction_recruiter:faction_purchase", "@faction_recruiter:select_item_purchase", 2, "@cancel", "", "@ok", "recruiterScreenplay", "handleSuiPurchase", 32, options)
end

function recruiterScreenplay:handleSuiPurchase(pCreature, pSui, eventIndex, arg0)
  local cancelPressed = (eventIndex == 1)

  if pCreature == nil then
    return
  end

  if cancelPressed then
    deleteStringData(CreatureObject(pCreature):getObjectID() .. ":faction_purchase")
    return
  end

  local playerID = SceneObject(pCreature):getObjectID()
  local purchaseCategory = readStringData(playerID .. ":faction_purchase")

  if purchaseCategory == "" then
    return
  end

  local purchaseIndex = arg0 + 1
  local faction = self:getFactionFromHashCode(CreatureObject(pCreature):getFaction())
  local dataTable = self:getFactionDataTable(faction)
  local itemListTable = self:getItemListTable(faction, purchaseCategory)
  local itemString = itemListTable[purchaseIndex]
  deleteStringData(playerID .. ":faction_purchase")

  local awardResult = nil

  if (self:isHireling(faction, itemString)) then
    awardResult = self:awardData(pCreature, faction, itemString)
  else
    awardResult = self:awardItem(pCreature, faction, itemString)
  end

  if (awardResult == self.errorCodes.SUCCESS) then
    return
  elseif (awardResult == self.errorCodes.INVENTORYFULL) then
    CreatureObject(pCreature):sendSystemMessage("@dispenser:inventory_full") -- Your inventory is full. You must make some room before you can purchase.
  elseif (awardResult == self.errorCodes.DATAPADFULL) then
    CreatureObject(pCreature):sendSystemMessage("@faction_recruiter:datapad_full") -- Your datapad is full. You must first free some space.
  elseif (awardResult == self.errorCodes.TOOMANYHIRELINGS) then
    CreatureObject(pCreature):sendSystemMessage("@faction_recruiter:too_many_hirelings") -- You already have too much under your command.
  elseif (awardResult == self.errorCodes.NOTENOUGHFACTION) then
    local messageString = LuaStringIdChatParameter("@faction_recruiter:not_enough_standing_spend")
    messageString:setDI(self.minimumFactionStanding)
    messageString:setTO(self:toTitleCase(faction))
    CreatureObject(pCreature):sendSystemMessage(messageString:_getObject()) -- You do not have enough faction standing to spend. You must maintain at least %DI to remain part of the %TO faction.
  elseif (awardResult == self.errorCodes.ITEMCOST) then
    CreatureObject(pCreature):sendSystemMessage("Error determining cost of item. Please post a bug report regarding the item you attempted to purchase.")
  elseif (awardResult == self.errorCodes.INVENTORYERROR or awardResult == self.DATAPADERROR) then
    CreatureObject(pCreature):sendSystemMessage("Error finding location to put item. Please post a report.")
  elseif (awardResult == self.errorCodes.TEMPLATEPATHERROR) then
    CreatureObject(pCreature):sendSystemMessage("Error determining data for item. Please post a bug report regarding the item you attempted to purchase..")
  end
end

function recruiterScreenplay:awardItem(pPlayer, faction, itemString)
  local pGhost = CreatureObject(pPlayer):getPlayerObject()

  if (pGhost == nil) then
    return self.errorCodes.INVENTORYERROR
  end

  local pInventory = SceneObject(pPlayer):getSlottedObject("inventory")

  if (pInventory == nil) then
    return self.errorCodes.INVENTORYERROR
  end

  local factionStanding = PlayerObject(pGhost):getFactionStanding(faction)
  local itemCost = self:getItemCost(faction, itemString)

  if itemCost == nil then
    return self.errorCodes.ITEMCOST
  end

  local bothanDiscount = 1.0

  if (CreatureObject(pPlayer):getSpecies() == 5) then
    bothanDiscount = 0.9;
  end

  itemCost = math.ceil(itemCost * getGCWDiscount(pPlayer) * self:getSmugglerDiscount(pPlayer) * bothanDiscount)

  if (factionStanding < (itemCost + self.minimumFactionStanding)) then
    return self.errorCodes.NOTENOUGHFACTION
  end

  local slotsremaining = SceneObject(pInventory):getContainerVolumeLimit() - SceneObject(pInventory):getCountableObjectsRecursive()

  local bonusItemCount = self:getBonusItemCount(faction, itemString)

  if (slotsremaining < (1 + bonusItemCount)) then
    return self.errorCodes.INVENTORYFULL
  end

  local transferResult =  self:transferItem(pPlayer, pInventory, faction, itemString)

  if (transferResult ~= self.errorCodes.SUCCESS) then
    return transferResult
  end

  PlayerObject(pGhost):decreaseFactionStanding(faction, itemCost)

  local messageString = LuaStringIdChatParameter("@faction_recruiter:item_purchase_complete") -- Your requisition of %TT is complete.
  messageString:setTT(self:getDisplayName(faction, itemString))
  CreatureObject(pPlayer):sendSystemMessage(messageString:_getObject())

  if bonusItemCount then
    local bonusItems = self:getBonusItems(faction, itemString)
    if bonusItems ~= nil then
      messageString = LuaStringIdChatParameter("@faction_perk:given_extra_bases") -- Congratulations! In addition to the base that you purchased, we have given you two additional bases. They are:
      CreatureObject(pPlayer):sendSystemMessage(messageString:_getObject())

      for k, v in pairs(bonusItems) do
        transferResult = self:transferItem(pPlayer, pInventory, faction, v)
        if(transferResult ~= self.errorCodes.SUCCESS) then
          return transferResult
        end

        messageString = LuaStringIdChatParameter("@faction_perk:bonus_base_name") -- You received a: %TO
        messageString:setTO(self:getDisplayName(faction, v))
        CreatureObject(pPlayer):sendSystemMessage(messageString:_getObject())
      end
    end
  end

  return self.errorCodes.SUCCESS
end

function recruiterScreenplay:toTitleCase(str)
  local buf = {}
  for word in string.gmatch(str, "%S+") do
    local first, rest = string.sub(word, 1, 1), string.sub(word, 2)
    table.insert(buf, string.upper(first) .. string.lower(rest))
  end
  return table.concat(buf, " ")
end

function recruiterScreenplay:awardData(pPlayer, faction, itemString)
  local pGhost = CreatureObject(pPlayer):getPlayerObject()

  if (pGhost == nil) then
    return self.errorCodes.DATAPADERROR
  end

  local pDatapad = SceneObject(pPlayer):getSlottedObject("datapad")

  if pDatapad == nil then
    return self.errorCodes.DATAPADERROR
  end

  local factionStanding = PlayerObject(pGhost):getFactionStanding(faction)
  local itemCost = self:getItemCost(faction, itemString)

  if itemCost == nil then
    return self.errorCodes.ITEMCOST
  end

  itemCost = math.ceil(itemCost *  getGCWDiscount(pPlayer) * self:getSmugglerDiscount(pPlayer))

  if factionStanding < (itemCost + self.minimumFactionStanding) then
    return self.errorCodes.NOTENOUGHFACTION
  end

  local slotsRemaining = SceneObject(pDatapad):getContainerVolumeLimit() - SceneObject(pDatapad):getCountableObjectsRecursive()
  local bonusItemCount = self:getBonusItemCount(faction, itemString)

  if (slotsRemaining < (1 + bonusItemCount)) then
    return self.errorCodes.DATAPADFULL
  end

  local transferResult = self:transferData(pPlayer, pDatapad, faction, itemString)

  if(transferResult ~= self.errorCodes.SUCCESS) then
    return transferResult
  end

  PlayerObject(pGhost):decreaseFactionStanding(faction, itemCost)

  local messageString = LuaStringIdChatParameter("@faction_recruiter:hireling_purchase_complete") -- The %TT is now under your command.
  messageString:setTT(self:getDisplayName(faction, itemString))
  CreatureObject(pPlayer):sendSystemMessage(messageString:_getObject())

  if bonusItemCount then
    local bonusItems = self:getBonusItems(faction, itemString)
    if bonusItems ~= nil then
      for k, v in pairs(bonusItems) do
        transferResult = self:transferData(pPlayer, pDatapad, faction, v)
        if (transferResult ~= self.errorCodes.SUCCESS) then
          return transferResult
        end
      end
    end
  end

  return self.errorCodes.SUCCESS
end

function recruiterScreenplay:transferData(pPlayer, pDatapad, faction, itemString)
  local pItem
  local templatePath = self:getTemplatePath(faction, itemString)

  if templatePath == nil then
    return self.errorCodes.TEMPLATEPATHERROR
  end

  local genPath = self:getControlledObjectTemplate(faction, itemString)

  if genPath == nil then
    return self.errorCodes.TEMPLATEPATHERROR
  end

  if (self:isHireling(faction, itemString)) then
    if (checkTooManyHirelings(pDatapad)) then
      return self.errorCodes.TOOMANYHIRELINGS
    end

    pItem = giveControlDevice(pDatapad, templatePath, genPath, -1, true)
  else
    pItem = giveControlDevice(pDatapad, templatePath, genPath, -1, false)
  end

  if pItem ~= nil then
    SceneObject(pItem):sendTo(pPlayer)
  else
    return self.errorCodes.GIVEERROR
  end

  return self.errorCodes.SUCCESS
end

function recruiterScreenplay:transferItem(pPlayer, pInventory, faction, itemString)
  local templatePath = self:getTemplatePath(faction, itemString)

  if templatePath == nil then
    return self.errorCodes.TEMPLATEPATHERROR
  end

  local pItem = giveItem(pInventory, templatePath, -1)

  if (pItem == nil) then
    return self.errorCodes.GIVEERROR
  end

  if (self:isInstallation(faction, itemString)) then
    SceneObject(pItem):setObjectName("deed", itemString, true)
    local deed = LuaDeed(pItem)
    local genPath = self:getGeneratedObjectTemplate(faction, itemString)

    if genPath == nil then
      return self.errorCodes.TEMPLATEPATHERROR
    end

    deed:setGeneratedObjectTemplate(genPath)

    if (faction == "imperial") then
      TangibleObject(pItem):setFaction(FACTIONIMPERIAL)
    elseif (faction == "rebel") then
      TangibleObject(pItem):setFaction(FACTIONREBEL)
    end
  end

  return self.errorCodes.SUCCESS
end


function recruiterScreenplay:getItemListTable(faction, screenID)
  local dataTable = self:getFactionDataTable(faction)
  if screenID == "fp_furniture" then
    return dataTable.furnitureList
  elseif screenID == "fp_weapons_armor" then
    return dataTable.weaponsArmorList
  elseif screenID == "fp_installations" then
    return dataTable.installationsList
  elseif screenID == "fp_uniforms" then
    return dataTable.uniformList
  elseif screenID == "fp_hirelings" then
    return dataTable.hirelingList
  end
end

function recruiterScreenplay:getSmugglerDiscount(pPlayer)
  if CreatureObject(pPlayer):hasSkill("combat_smuggler_master") then
    return .75
  elseif CreatureObject(pPlayer):hasSkill("combat_smuggler_underworld_01") then
    return .90
  end
  return 1.0
end

function recruiterScreenplay:handleGoOnLeave(pPlayer)
  deleteData(CreatureObject(pPlayer):getObjectID() .. ":changingFactionStatus")
  CreatureObject(pPlayer):setFactionStatus(0)
end

function recruiterScreenplay:handleGoCovert(pPlayer)
  deleteData(CreatureObject(pPlayer):getObjectID() .. ":changingFactionStatus")
  CreatureObject(pPlayer):setFactionStatus(1)
end

function recruiterScreenplay:handleGoOvert(pPlayer)
  deleteData(CreatureObject(pPlayer):getObjectID() .. ":changingFactionStatus")
  CreatureObject(pPlayer):setFactionStatus(2)
end

function recruiterScreenplay:handleResign(pPlayer)
  local pGhost = CreatureObject(pPlayer):getPlayerObject()

  if (pGhost == nil) then
    return
  end

  deleteData(CreatureObject(pPlayer):getObjectID() .. ":changingFactionStatus")
  local oldFaction = CreatureObject(pPlayer):getFaction()
  local oldFactionName = self:getFactionFromHashCode(oldFaction)
  CreatureObject(pPlayer):setFactionRank(0)
  CreatureObject(pPlayer):setFaction(0)
  CreatureObject(pPlayer):setFactionStatus(0)
  PlayerObject(pGhost):decreaseFactionStanding(oldFactionName, 0)
end

function recruiterScreenplay:handleRebelTp(pPlayer) 
    local player = LuaSceneObject(pPlayer)
    player:switchZone("jakku", -5708.5, 48.2, 5506.0, 0)  --("jakku", 2.0, -20.8, 22.1, 610000100) 
    createEvent(1000, "recruiterScreenplay", "handleGoOvert", pPlayer, "")
end

function recruiterScreenplay:handleImpTp(pPlayer)  
    local player = LuaSceneObject(pPlayer)
    player:switchZone("jakku", -5991.7, 35.7, 6136.2, 0)  --("jakku", 1.5, -20.8, 27.5, 610000111)  
    createEvent(1000, "recruiterScreenplay", "handleGoOvert", pPlayer, "")
end

function recruiterScreenplay:handleImpTp2(pPlayer) 
    local player = LuaSceneObject(pPlayer)
    player:switchZone("dungeon2", -0.0, 173.8, 53.7, 480000038)  --("jakku", 1.5, -20.8, 27.5, 610000111)   
end

function recruiterScreenplay:handleRebelTp2(pPlayer) 
    local player = LuaSceneObject(pPlayer)
    player:switchZone("dungeon2", -41.2, 0, -0.2, 480000159)  --("jakku", 2.0, -20.8, 22.1, 610000100) 
end

function recruiterScreenplay:handleElysiumTp(pPlayer)
    local player = LuaSceneObject(pPlayer)
    player:switchZone("elysium", 2606, 0, 2343, 0)  --("jakku", 1.5, -20.8, 27.5, 610000111)  
    createEvent(1000, "recruiterScreenplay", "handleGoOnLeave", pPlayer, "")
end

function recruiterScreenplay:handleYavinTp(pPlayer)
  
    local player = LuaSceneObject(pPlayer)
    player:switchZone("yavin4", -5575, 87, 4903, 0)  --("jakku", 1.5, -20.8, 27.5, 610000111)  
    createEvent(1000, "recruiterScreenplay", "handleGoOnLeave", pPlayer, "")
end

function recruiterScreenplay:handleYavinTpDark(pPlayer)  
    local player = LuaSceneObject(pPlayer)
    player:switchZone("yavin4", 5121, 81, 301, 0)  --("jakku", 1.5, -20.8, 27.5, 610000111)  
    createEvent(1000, "recruiterScreenplay", "handleGoOnLeave", pPlayer, "")
end

function recruiterScreenplay:handleLothalTp(pPlayer)
    local player = LuaSceneObject(pPlayer)
    player:switchZone("lothal", 96, 39, 4183, 0)  --("jakku", 1.5, -20.8, 27.5, 610000111) 
    createEvent(1000, "recruiterScreenplay", "handleGoOnLeave", pPlayer, "")
end

function recruiterScreenplay:handleDantooineTp(pPlayer) 
    local player = LuaSceneObject(pPlayer)
    player:switchZone("dantooine", 4248, 8, 5181, 0)  --("jakku", 1.5, -20.8, 27.5, 610000111)  
    createEvent(1000, "recruiterScreenplay", "handleGoOnLeave", pPlayer, "")
end

function recruiterScreenplay:handleChandrilaTp(pPlayer) 
    local player = LuaSceneObject(pPlayer)
    player:switchZone("chandrila", 4363, 97, -4299, 0)  --("jakku", 1.5, -20.8, 27.5, 610000111) 
    createEvent(1000, "recruiterScreenplay", "handleGoOnLeave", pPlayer, "")
end

function recruiterScreenplay:handleAuriliaTp(pPlayer) 
    local player = LuaSceneObject(pPlayer)
    player:switchZone("dathomir", 5301, 78, -4151, 0)  --("jakku", 1.5, -20.8, 27.5, 610000111) 
  createEvent(1000, "recruiterScreenplay", "handleGoOnLeave", pPlayer, "")
end

function recruiterScreenplay:handleKaasTp(pPlayer) 
    local player = LuaSceneObject(pPlayer)
    player:switchZone("kaas", -1123, 129, -4776, 0)  --("jakku", 1.5, -20.8, 27.5, 610000111) 
    createEvent(1000, "recruiterScreenplay", "handleGoOnLeave", pPlayer, "")
end