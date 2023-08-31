armor_clone_trooper_neutral_s01_bracer_r = {
	minimumLevel = 0,
	maximumLevel = -1,
	customObjectName = "Clone Trooper Armor Right Bracer (neutral)",
	directObjectTemplate = "object/tangible/wearables/armor/clone_trooper/armor_clone_trooper_neutral_s01_bracer_r.iff",
	craftingValues = {
		{"armor_rating",1,1,0},
     {"armor_effectiveness",25,40,10},
    {"armor_integrity",30000, 55000,0},
    {"armor_health_encumbrance",0,0,0},
    {"armor_action_encumbrance",0,0,0},
    {"armor_mind_encumbrance",0,0,0},
	},
	skillMods = {

	},
	

	junkDealerTypeNeeded = JUNKARMOUR,
	junkMinValue = 55,
	junkMaxValue = 110
}

addLootItemTemplate("armor_clone_trooper_neutral_s01_bracer_r", armor_clone_trooper_neutral_s01_bracer_r)
