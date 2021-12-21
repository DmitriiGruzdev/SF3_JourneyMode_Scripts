// ------------------------------------------------------------------------------------------------------------------------------------
// includes:
#include "../../basicScripts/Journey_LevelBase.as"

class Level: Journey_LevelBase
{
	// -------------------------------------------------------------------------------------------------------------------
	/* --- Member Variables ----------------------------------------------------------------------------------------------
	*/
	
	// count this version-number up. This is for later version tracking, when the QA plays the map. 
	string m_Version_Level = "QA hasn't played the map yet";    

	// --------------------------------------------------------------------------------------------------------------------
	// --- constructor --- dont make any changes here
	Level (LevelReference@ _Reference)
	{
		super(_Reference);
	}
	
	// -------------------------------------------------------------------------------------------------------------------
	// --- V A R I A B L E S ---------------------------------------------------------------------------------------------

	// --- Factions -----------------------------------------------------------------------------------------------------------
	uint8 m_i0_PlayerFaction = 				0;
	uint8 m_i1_PlayerFaction = 				1;
	uint8 m_i2_PlayerFaction = 				2;
	uint8 m_iEverlightGuard = 				4;

	// Everlight quests
	string m_sSideQuest_500_Q0 = "Journey_500_SQ0_HireCompanions";
	string m_sSideQuest_500_Q2 = "Journey_500_SQ2_SeeRondarLacaine";
	string m_sSideQuest_500_Q3 = "Journey_500_SQ3_SeeMinibossTrophiesCollector";

	string m_sGlobalCollectiblesQuest = "Journey_Global_CollectAntiqueCoins";
	string m_sGlobalCollectiblesNPC = "Journey_RondarLacaine_500";

	string m_sGlobalMinibossTrophiesNPC = "Journey_MinibossTrophiesCollector_500";
	string m_sGlobalMinibossTrophiesNPC_PetGolem = "Journey_MinibossTrophiesCollector_PetGolem_500";

	array<string> m_arrTraders =
	{
		"Journey_TraderGen_AdvancedArmor",
		"Journey_TraderGen_AdvancedWeapons",
		"Journey_TraderGen_Alchemist",
		"Journey_TraderGen_Basics",
		"Journey_TraderGen_Jewelry",
		"EL1_TraderGen_HuSmith_01",
	};

	array<string> m_arrGodstones =
	{
		"CompanionsSpot_Godstone",
		"CreatorsGuild_Godstone",
		"North_Godstone",
		"NorthWest_Godstone",
		"RefugeesCamp_Godstone",
		"SculptorsWorkshop_Godstone",
		"Slums_Godstone",
		"StartingHarbor_Godstone"
	};

	bool m_bFirstTimeVisit  = false;
	bool m_bTestSetup = false;

	// Generic shoutouts one of which is randomly chosen on map launch if there is no available quest-related shoutout
	array<string> m_arrAvatarGenericShoutouts =
	{
		"Journey_500_SO_EverlightReturn_01",
		"Journey_500_SO_EverlightReturn_02",
		"Journey_500_SO_EverlightReturn_03",
		"Journey_500_SO_EverlightReturn_04",
		"Journey_500_SO_EverlightReturn_05"
	};

	// Shoutouts that are used by generic flavour NPCs
	array<string> m_arrFishermanGenericRandomSHoutouts =
	{
		"Journey_Everlight_Fisherman_02_Idle_01",
		"Journey_Everlight_Fisherman_02_Idle_02",
		"Journey_Everlight_Fisherman_02_Idle_03"
	};

	array<string> m_arrRefugeeGenericRandomSHoutouts =
	{
		"Journey_Everlight_Starving_Refugee_01_SO_HungryRefugee_Idle_01",
		"Journey_Everlight_Starving_Refugee_01_SO_HungryRefugee_Idle_02",
		"Journey_Everlight_Starving_Refugee_01_SO_HungryRefugee_Idle_03",
		"Journey_Everlight_Starving_Refugee_01_SO_HungryRefugee_Idle_04",
		"Journey_Everlight_Starving_Refugee_01_SO_HungryRefugee_Idle_05",
		"Journey_Everlight_Starving_Refugee_01_SO_HungryRefugee_Idle_06"
	};

	array<string> m_arrGuardsGenericRandomSHoutouts =
	{
		"Journey_Everlight_Guard_02_Idle_01",
		"Journey_Everlight_Guard_02_Idle_02",
		"Journey_Everlight_Guard_02_Idle_03"
	};

	bool m_bAvatarShoutoutSet = false;

	// Stores disabled shoutouts in relation to flavour NPCs, filled in DisableGenericFlavourShoutouts
	dictionary m_GenericNPC_DisabledShoutouts = {};

	// Scrapper sets
		dictionary m_MasterScrapper_ItemSets = {
												// All
												{"All", array<string> = {
																			"EXP2_Set_MasterScrapper_Q0",
																			"Journey_Set_MasterScrapper_Potions",
																			"EXP2_Set_MasterScrapper_Armors_Q1",
																			"EXP2_Set_MasterScrapper_Helmets_Q1",
																			"EXP2_Set_MasterScrapper_Shields_Q1",
																			"EXP2_Set_MasterScrapper_Weapons_Q1",
																			"EXP2_Set_MasterScrapper_Armors_Q2",
																			"EXP2_Set_MasterScrapper_Helmets_Q2",
																			"EXP2_Set_MasterScrapper_Shields_Q2",
																			"EXP2_Set_MasterScrapper_Weapons_Q2",
																			"EXP2_Set_MasterScrapper_Jewelery_Q2",
																			"EXP2_Set_MasterScrapper_Armors_Q3",
																			"EXP2_Set_MasterScrapper_Helmets_Q3",
																			"EXP2_Set_MasterScrapper_Shields_Q3",
																			"EXP2_Set_MasterScrapper_Weapons_Q3",
																			"EXP2_Set_MasterScrapper_Necklaces_Q3",
																			"EXP2_Set_MasterScrapper_Trinkets_Q3",
																			"EXP2_Set_MasterScrapper_Rings_Q3",
																			"EXP2_Set_MasterScrapper_Armors_Q4",
																			"EXP2_Set_MasterScrapper_Helmets_Q4",
																			"EXP2_Set_MasterScrapper_Shields_Q4",
																			"EXP2_Set_MasterScrapper_Weapons_Q4",
																			"EXP2_Set_MasterScrapper_Necklaces_Q4",
																			"EXP2_Set_MasterScrapper_Trinkets_Q4",
																			"EXP2_Set_MasterScrapper_Rings_Q4"										
																		}
												}
								};

	// Flavour SOs in relation to triggers which should cause them
		dictionary m_FlavourDialoguesTriggers_RandomSOs = {
												{"FlavourSculptor_Trigger", array<string> = {	
																			"Journey_Everlight_Artist_Idle_01",
																			"Journey_Everlight_Artist_Idle_02",
																			"Journey_Everlight_Artist_Idle_03"
																		} 
												},
												{"FlavourRefugeeFather_Trigger", array<string> = {}
												},
												{"FlavourGuard_Trigger", array<string> = {	
																			"Journey_Everlight_Guard_01_Idle_01",
																			"Journey_Everlight_Guard_01_Idle_02",
																			"Journey_Everlight_Guard_01_Idle_03"
																		} 
												},
												{"FlavourFisherman_Trigger", array<string> = {	
																			"Journey_Everlight_Fisherman_01_Idle_01",
																			"Journey_Everlight_Fisherman_01_Idle_02",
																			"Journey_Everlight_Fisherman_01_Idle_03"
																		} 
												},
												{"FlavourGrievingMother_Trigger", array<string> = {	
																			"Journey_Everlight_Flavor_GrievingMother_SO_LookingForSon_01",
																			"Journey_Everlight_Flavor_GrievingMother_SO_LookingForSon_02",
																			"Journey_Everlight_Flavor_GrievingMother_SO_LookingForSon_03"
																		} 
												},
												{"FlavourTrader_Trigger", array<string> = {	
																			"Journey_Everlight_Merchant_01_Market_Hawking_01",
																			"Journey_Everlight_Merchant_01_Market_Hawking_02",
																			"Journey_Everlight_Merchant_01_Market_Hawking_03"
																		} 
												},
												{"FlavourMudTrader_Trigger", array<string> = {}
												},
												{"FlavourRefugee_Trigger", array<string> = {	
																			"Journey_Everlight_Starving_Refugee_03_SO_HungryRefugee_Idle_01",
																			"Journey_Everlight_Starving_Refugee_03_SO_HungryRefugee_Idle_02",
																			"Journey_Everlight_Starving_Refugee_03_SO_HungryRefugee_Idle_03"
																		} 
												},
												{"FlavourFishermanGeneric_Trigger_1", m_arrFishermanGenericRandomSHoutouts	
												},
												{"FlavourFishermanGeneric_Trigger_2", m_arrFishermanGenericRandomSHoutouts	
												},
												{"FlavourFishermanGeneric_Trigger_3", m_arrFishermanGenericRandomSHoutouts	
												},
												{"FlavourFishermanGeneric_Trigger_4", m_arrFishermanGenericRandomSHoutouts	
												},
												{"FlavourFishermanGeneric_Trigger_5", m_arrFishermanGenericRandomSHoutouts	
												},
												{"FlavourRefugeeGeneric_Trigger_1", m_arrRefugeeGenericRandomSHoutouts	
												},
												{"FlavourRefugeeGeneric_Trigger_2", m_arrRefugeeGenericRandomSHoutouts	
												},
												{"FlavourRefugeeGeneric_Trigger_3", m_arrRefugeeGenericRandomSHoutouts	
												},
												{"FlavourRefugeeGeneric_Trigger_4", m_arrRefugeeGenericRandomSHoutouts	
												},
												{"FlavourRefugeeGeneric_Trigger_5", m_arrRefugeeGenericRandomSHoutouts	
												},
												{"FlavourGuardGeneric_Trigger_1", m_arrGuardsGenericRandomSHoutouts	
												},
												{"FlavourGuardGeneric_Trigger_2", m_arrGuardsGenericRandomSHoutouts	
												},
												{"FlavourGuardGeneric_Trigger_3", m_arrGuardsGenericRandomSHoutouts	
												},
												{"FlavourGuardGeneric_Trigger_4", m_arrGuardsGenericRandomSHoutouts	
												},
												{"FlavourGuardGeneric_Trigger_5", m_arrGuardsGenericRandomSHoutouts	
												}

								};
	// Flavour NPCs conversations in relation to triggers which can cause them
		dictionary m_FlavourDialoguesTriggers_NPCsConversations = {
												{"FlavourSculptor_Trigger", "Journey_Everlight_Artist_Patron_Conversation"},
												{"FlavourRefugeeFather_Trigger", "Journey_Everlight_Refugee_Father_SO_ConversationWithSon"},
												{"FlavourGuard_Trigger", "Journey_Everlight_Guard_01_Chat_With_Guard_02"},
												{"FlavourFisherman_Trigger", "Journey_Everlight_Fishermen_Conversation"},
												{"FlavourMudTrader_Trigger", "Journey_Everlight_MudMerchant_SO_Argument"}
								};														

	// Function that is called when the Level is created for the first time - only called once within the campaign
	void OnCreated () override
	{
		Journey_LevelBase::OnCreated();
		print("--- M A P : Level Script: '"+m_Version_Level+"', Map: '"+ m_Reference.GetMapId() +"', Setting: '"+ m_Reference.GetWorld().GetCurrentMapSetting( m_Reference.GetMapId() )+"'");
				
		// Calling the final functions
		InitEvents(); 
		InitCommon(); 
	}

	// level data had been restored from savegame - ensure version compability here
	void OnLoaded (const uint _uVersion) override
	{
		Journey_LevelBase::OnLoaded(_uVersion);
		print("--- M A P : Level Script: '"+m_Version_Level+"', Map: '"+ m_Reference.GetMapId() +"', Setting: '"+ m_Reference.GetWorld().GetCurrentMapSetting( m_Reference.GetMapId() )+"'");
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- CUSTOM FUNCTIONS AND EVENTS ----------------------------------------------------------------------------------
	/*
		All events are registered in this function.
		There soudn't be any variable declarations or initialitations
	*/
	void InitEvents( )
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.RegisterBuildingEventByDescription(OwnerChanged, TOnBuildingEvent(@this.OnOwnerChanged_GodstoneCaptured), "Exp1_Godstone", _uFaction);
		}
	}

	/*
		Is called right at the beginning of the level. Should only be used to start a dialoge, or directly stage an event and so on.
	*/
	void InitCommon ()
	{
		// Setting Everlight map as HUB
		m_Reference.GetWorld().AllowFullPartyManagement( 500, 0, true);

		// Allowing travelling by default because it is a HUB
		m_Reference.GetWorld().AllowTravel(true);
		m_Reference.GetWorld().SetWorldMapId(0);
		m_Reference.GetWorld().SetMapAccessible(0, true);

		// Setting up HUB
		HUB_SetUp();

		// Handling NPCs that are spawned on level start
		m_Reference.GetCreatureByName(m_sGlobalCollectiblesNPC).SetImmovable(true);
		m_Reference.GetCreatureByName(m_sGlobalMinibossTrophiesNPC).SetImmovable(true);
		m_Reference.GetCreatureByName(m_sGlobalMinibossTrophiesNPC_PetGolem).SetImmovable(true);
		Creature[] _Ferrymen = m_Reference.FindCreaturesByPrefix("EL1_Ferryman");
		for(uint i = 0; i < _Ferrymen.length(); ++i)
		{
			_Ferrymen[i].SetImmovable(true);
			for (uint j = 0; j < m_Reference.GetPlayerFactions(true).length(); ++j)
			{
				uint _uFaction = m_Reference.GetPlayerFactions(true)[j];
				m_Reference.BeginNotification(_uFaction, "DialogueAvailable", _Ferrymen[i]);
			}
		}
		m_Reference.GetCreatureByName("Journey_EverlightScrapper").SetImmovable(true);
		SetFlavourNPCsImmovable();
		SetTradersImmovable();

		// Setup flavour dialogues between NPCs 
		SetupFlavourNPCsConversations();

		// Scrapper
		Setup_MasterScrapper_ItemSets();

		// Summoning companions to the host faction
		SummonCompanionsHUB();

		// Revealing all of the map to players
		array <uint8> arr_PlayerFactions = m_Reference.GetPlayerFactions(true);	
		for(uint i  = 0; i < arr_PlayerFactions.length(); i++)
		{
			m_Reference.AddVisiblePathPartial(arr_PlayerFactions[i], "EL_RevealPath");
			m_Reference.AddVisiblePath(arr_PlayerFactions[i],"EL_Audio_EverlightGeneral");
		}
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T  F U N C T I O N S ----------------------------------------------------------------------------------

	/*	--------------------------------------------------
	*	Event registered for neutral faction, prevents
	*	Everlightians from getting stuck in the alley with
	*	miniboss trophies quest giver
	*	--------------------------------------------------
	*/
	bool OnCreatureEnteredArea_DisableCollision(Creature& in _Creature, Entity[]&in _Params)
	{
		_Creature.SetCollisionDisabled(true);
		string _sCitizenName = m_Reference.FindEntityName(_Creature);
		m_Reference.SetTimer(TOnTimerUserDataEvent(@this.ReenableCollision_Timer), 15, _sCitizenName);
		return false;
	}

	bool ReenableCollision_Timer(const string& in _sCitizenName)
	{
		Creature Citizen = m_Reference.GetCreatureByName(_sCitizenName);
		if(Citizen.Exists())
		{
			Citizen.SetCollisionDisabled(false);
			print("reenabled collision");
		}
		return true;
	}

	/*	--------------------------------------------------
	*	Saves activated godstones as global bools so on
	*	consequent visits to Everlight they will be 
	*	activated on map launch
	*	--------------------------------------------------
	*/
	bool OnOwnerChanged_GodstoneCaptured(Building&in _Building)
	{
		string _sGodstone = m_Reference.FindEntityName(_Building);
		uint _uFaction = _Building.GetFaction();
		Variables@ _FactionGlobalVariables = m_Reference.GetVariables(_uFaction);
		_FactionGlobalVariables.SetGlobalBool("Journey_EverlightGodstones."+_sGodstone, true);
		if(_uFaction != m_Reference.GetHostFaction())
		{
			Variables@ _HostGlobalVariables = m_Reference.GetVariables(m_Reference.GetHostFaction());
			_HostGlobalVariables.SetGlobalBool("Journey_EverlightGodstones."+_sGodstone, true);
		}

		return false;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- F L A V O U R  D I A L O U G E S ---------------------------------------------------------------------------------- 

	/*	--------------------------------------------------
	*	Fired when any player controlled hero enters a
	*	falvour dialogue trigger box. With certain probability
	*	will trigger a random available shoutout for this
	*	specific trigger and linked NPC 
	*	--------------------------------------------------
	*/
	bool OnAnyHeroInside_TriggerRandomSO(Creature& in _Creature, Entity[]&in _Params)
	{
		uint _uTriggerChance = m_Reference.GetRandom().GetInteger(0, 99);
		uint _uTriggerChanceThreshold = 32;
		uint _uPlayersAmount = m_Reference.GetPlayerFactions(true).length();
		if(_uPlayersAmount > 1)
		{
			_uTriggerChanceThreshold = _uTriggerChanceThreshold/_uPlayersAmount;
		}
		print("_uTriggerChance: "+_uTriggerChance+" and _uTriggerChanceThreshold is "+_uTriggerChanceThreshold);
		if(_uTriggerChance <= _uTriggerChanceThreshold)
		{
			string _sTrigger = m_Reference.FindEntityName(_Params[0]);
			RandomShoutout(_sTrigger);
		}

		return false;
	}
	

	// -------------------------------------------------------------------------------------------------------------------
	// --- A R T I C Y  F U N C T I O N S --------------------------------------------------------------------------------

	void SetCheerfulTraderGlobalVar()
	{
		uint _uFaction = GetFactionTalkingToNPC("Journey_Everlight_Merchant_01");
		if(_uFaction != kFactionNeutral)
		{
			Variables@ _FactionGlobalVariables = m_Reference.GetVariables(_uFaction);
			_FactionGlobalVariables.SetGlobalBool("Journey_CampaignVariables.Journey_500_bSkipCheerfulTraderIntro", true);
		}
	}

	void ActivateAntiqueCoinsQuest()
	{
		m_Reference.GetSharedJournal().ActivateQuest(m_sSideQuest_500_Q2, false);
		m_Reference.GetSharedJournal().ActivateQuest(m_sGlobalCollectiblesQuest, true);
	}

	void ActivateMinibossTrophiesQuest()
	{
		m_Reference.GetSharedJournal().ActivateQuest(m_sSideQuest_500_Q3, false);
		m_Reference.GetSharedJournal().ActivateQuest(m_sGlobalMinibossTrophiesQuest, true);
	}

	void CompleteMinibossTrophiesQuest()
	{
		uint _uFaction = GetFactionTalkingToNPC(m_sGlobalMinibossTrophiesNPC);
		if(_uFaction != kFactionNeutral)
		{
			m_Reference.GetJournal(_uFaction).SetTaskState(m_sGlobalMinibossTrophiesQuest, "ReceiveReward", Completed);
		}
	}

	void TurnInAntiqueCoins(uint _uAmount)
	{
		uint _uFaction = GetFactionTalkingToNPC(m_sGlobalCollectiblesNPC);
		if(_uFaction != kFactionNeutral)
		{
			m_Reference.GetHeroParty(_uFaction).RemoveItems(m_sGlobalCollectibleItem, _uAmount, true);
		}
	}

	void TurnInMinibossTrophy()
	{
		uint _uFaction = GetFactionTalkingToNPC(m_sGlobalMinibossTrophiesNPC);
		if(_uFaction != kFactionNeutral)
		{
			int _iTrophiesSubmitted = 0;
			Variables@ _FactionGlobalVariables = m_Reference.GetVariables(_uFaction);

			// Reseting the global bool that is used to trigger NPC's new trophy reaction
			_FactionGlobalVariables.SetGlobalBool("Journey_MinibossTrophies.Journey_500_bNewTrophySubmitted", false);

			for(uint j = 0; j < m_arrGlobalMiniBossTrophies.length(); ++j)
			{
				if(m_Reference.GetHeroParty(_uFaction).HasItems(m_arrGlobalMiniBossTrophies[j], 1, true) 
					&& _FactionGlobalVariables.GetGlobalBool("Journey_MinibossTrophies."+m_arrGlobalMiniBossTrophies[j]+"_bSubmitted") == false)
				{
					m_Reference.GetHeroParty(_uFaction).RemoveItems(m_arrGlobalMiniBossTrophies[j], 1, true);
					_FactionGlobalVariables.SetGlobalBool("Journey_MinibossTrophies.Journey_500_bNewTrophySubmitted", true);
					_FactionGlobalVariables.SetGlobalBool("Journey_MinibossTrophies."+m_arrGlobalMiniBossTrophies[j]+"_bSubmitted", true);
					m_Reference.GetJournal(_uFaction).ActivateTask(m_sGlobalMinibossTrophiesQuest, "Submit_"+m_arrGlobalMiniBossTrophies[j], true);
					m_Reference.GetJournal(_uFaction).SetTaskState(m_sGlobalMinibossTrophiesQuest, "Submit_"+m_arrGlobalMiniBossTrophies[j], Completed);
					_iTrophiesSubmitted++;
				}
			}

			int _iTrophiesCollected = _FactionGlobalVariables.GetGlobalInt("Journey_MinibossTrophies.Journey_Global_iMinibossTrophiesCollected");
			_FactionGlobalVariables.SetGlobalInt("Journey_MinibossTrophies.Journey_Global_iMinibossTrophiesCollected", _iTrophiesCollected+_iTrophiesSubmitted);
		}
	}

	/*	----------------------------------------------------------------------------------
	*	Fired on start of every topic from m_FlavourDialoguesTriggers_NPCsConversations,
	*	removes it from an array of possible random shoutouts that flavour NPCs can make	
	*	----------------------------------------------------------------------------------
	*/
	void RemoveFlavourConversation(string _sTopic)
	{
		array<string> _arrkeys = m_FlavourDialoguesTriggers_RandomSOs.getKeys();
		for (uint i = 0; i < _arrkeys.length(); ++i)
		{
			string _sTrigger = _arrkeys[i];
			array<string> _arrShoutouts;
			m_FlavourDialoguesTriggers_RandomSOs.get(_sTrigger, _arrShoutouts);
			int _iIndex = _arrShoutouts.find(_sTopic);
			if(_iIndex != -1)
			{
				_arrShoutouts.removeAt(_iIndex);
				m_FlavourDialoguesTriggers_RandomSOs.set(_sTrigger, _arrShoutouts);
				DisableGenericFlavourShoutouts(_sTrigger);
				return;
			}
		}
	}

	/*	--------------------------------------------------
	*	Gives a coin to a refugee, caleed from
	*	Journey_Everlight_Starving_Refugee_03_SO_HungryRefugee_Conversation
	*	--------------------------------------------------
	*/
	void GiveCoin(string _sNPC)
	{
		uint _uFaction = GetFactionTalkingToNPC(_sNPC);
		m_Reference.GetHeroParty(_uFaction).RemoveGold(1);
	}

	/*	--------------------------------------------------
	*	Fired on finished flavour conversation between NPCs,
	*	enableS POI behaviour for a participant from the 
	*	passed spawn
	*	--------------------------------------------------
	*/
	void EnableFlavourPOI(string _sSpawn)
	{
		Creature[] _Creatures = m_Reference.GetCreaturesFromSpawn(_sSpawn);
		if(_Creatures.length() != 0)
		{
			_Creatures[0].EnablePOIVisitingBehavior(true);

			string _sContainerName = _Creatures[0].GetDescriptionName();
			EnableGenericFlavourShoutouts(_sContainerName);
		}
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- DIALOGUES-RELATED -------------------------------------------------------------------------------------------

	void DialoguesSetUp()
	{
		/*	--------------------------------------------------
		*	HUB dialogues should be set here. For now only Generic
		*	Avatar shoutouts are triggered, but later avatar SOs
		*	will account for last map finished
		*	--------------------------------------------------
		*/

	//	Companions
		if(m_Reference.GetSharedJournal().GetQuestState(m_sSideQuest_500_Q0) == Completed)
		{
			EnableUnlockableCompanionsDialogues();
		}

		// If no last map finisehd avatar shoutout was set above, then randomly chosen generic SO will play
		EnableAvatarShoutout("Generic");
	}

	void EnableAvatarShoutout(string _sShoutoutTopic)
	{
		if(m_bAvatarShoutoutSet)
		{
			return;
		}
		else if(!m_bAvatarShoutoutSet && _sShoutoutTopic != "Generic")
		{
			m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.AvatarShoutout_Timer), 100, _sShoutoutTopic);
			print("Avatar should shoutout this last map finished topic on map launch: "+_sShoutoutTopic);
			m_bAvatarShoutoutSet = true;
		}
		else if(!m_bAvatarShoutoutSet && _sShoutoutTopic == "Generic")
		{
			uint _uRandom = m_Reference.GetRandom().GetInteger(0, m_arrAvatarGenericShoutouts.length());
			m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.AvatarShoutout_Timer), 100, m_arrAvatarGenericShoutouts[_uRandom]);
			m_bAvatarShoutoutSet = true;
			print("Avatar should shoutout this random generic topic on map launch: "+_sShoutoutTopic);
		}

	}

	bool AvatarShoutout_Timer(const string& in _sShoutoutTopic)
	{
		m_Reference.GetCreatureById(m_iHostAvatarId).Shoutout(m_Reference, "GenericAvatar", _sShoutoutTopic, false, kMaxFactions);
		return true;
	}

	// Also called in articy on complition of Journey_500_SQ0_HireCompanions quest
	void EnableUnlockableCompanionsDialogues()
	{
		for ( uint i = 0; i < m_arrUnlockableJourneyCompanions.length(); i++ )
		{
			m_Reference.GetWorld().EnableDialogueTopic(m_arrUnlockableJourneyCompanions[i], m_arrUnlockableJourneyCompanions[i] + "Talk", true);
		}
	}

	/*	--------------------------------------------------
	*	With certain probabilty adds a flavour conversation
	*	between NPCs as possible random flavour shoutout.
	*	In this case we also spawn required 2nd participant
	*	for it.
	*	--------------------------------------------------
	*/
	void SetupFlavourNPCsConversations()
	{
		array<string> _arrkeys = m_FlavourDialoguesTriggers_NPCsConversations.getKeys();
		for (uint i = 0; i < _arrkeys.length(); ++i)
		{
			uint _uConversationChance = m_Reference.GetRandom().GetInteger(0, 99);
			uint _uConversationChanceThreshold = 19;
			print("_uConversationChance: "+_uConversationChance);
			if(_uConversationChance <= _uConversationChanceThreshold)
			{
				string _sTrigger = _arrkeys[i];
				string _sTopic;
				m_FlavourDialoguesTriggers_NPCsConversations.get(_sTrigger, _sTopic);

				array<string> _arrShoutouts;
				m_FlavourDialoguesTriggers_RandomSOs.get(_sTrigger, _arrShoutouts);
				_arrShoutouts.insertLast(_sTopic);
				m_FlavourDialoguesTriggers_RandomSOs.set(_sTrigger, _arrShoutouts);

				// Should we account for possible index out of bounds exception here?
				array<string> _arrLinkedSpawns = m_Reference.GetLinkedObjects(_sTrigger, false);
				if(_arrLinkedSpawns.length() >= 1)
				{
					string _sSecondParticipantSpawn = _arrLinkedSpawns[1];
					m_Reference.ActivateSpawn(_sSecondParticipantSpawn, true);
					Creature[] _Participants = m_Reference.GetCreaturesFromSpawn(_sSecondParticipantSpawn);
					if(_Participants.length() != 0)
					{
						_Participants[0].SetImmovable(true);
					}
				}
				else
				{
					print("FLAVOUR DIALOGUES WARNING: "+_sTrigger+" should have more than 1 linked spawn.");
				}
			}
		}
	}

	// Called in OnAnyHeroInside_TriggerRandomSO and passes trigger name from the event
	void RandomShoutout(string _sTrigger)
	{
		array<string> _arrShoutouts;
		m_FlavourDialoguesTriggers_RandomSOs.get(_sTrigger, _arrShoutouts);
		if(_arrShoutouts.length() == 4)
		{
			array<string> _arrLinkedSpawns = m_Reference.GetLinkedObjects(_sTrigger, false);
			string _sSpeaker = m_Reference.FindEntityName(m_Reference.GetCreaturesFromSpawn(_arrLinkedSpawns[0])[0]);
			JourneyDialogShoutout(_sSpeaker, _sSpeaker, _arrShoutouts[3], true);
		}
		else if(_arrShoutouts.length() != 0)
		{
			uint _uRandom = m_Reference.GetRandom().GetInteger(0, _arrShoutouts.length());
			// For debug, should be removed
			for (uint i = 0; i < _arrShoutouts.length(); ++i)
			{
				print("Topics debug: "+_arrShoutouts[i]);
			}

			array<string> _arrLinkedSpawns = m_Reference.GetLinkedObjects(_sTrigger, false);
			Creature _Speaker = m_Reference.GetCreaturesFromSpawn(_arrLinkedSpawns[0])[0];
			string _sSpeaker = m_Reference.FindEntityName(_Speaker);
			string _sContainerName = _Speaker.GetDescriptionName();
			JourneyDialogShoutout(_sSpeaker, _sContainerName, _arrShoutouts[_uRandom], true);
		}

		// Once flavour dialogue is played we call a sciptcall that removes it from possible shoutouts + possibly activates POI behaviour of the 2nd participant
	}

	/*	--------------------------------------------------
	*	On start of falvour NPC's conversation if second
	*	participant has any shoutouts enabled by default,
	*	they will be disabled here so players won't be
	*	able to interupt the conversation
	*	--------------------------------------------------
	*/
	void DisableGenericFlavourShoutouts(string _sTrigger)
	{
		array<string> _arrLinkedSpawns = m_Reference.GetLinkedObjects(_sTrigger, false);
		if(_arrLinkedSpawns.length() >= 1)
		{
			string _sSecondParticipantSpawn = _arrLinkedSpawns[1];
			Creature[] _Participants = m_Reference.GetCreaturesFromSpawn(_sSecondParticipantSpawn);
			if(_Participants.length() != 0)
			{
				string _sContainerName = _Participants[0].GetDescriptionName();
				array<string> _arrTopics = m_Reference.GetWorld().GetEnabledTopics(_sContainerName);
				if(_arrTopics.length() != 0)
				{
					m_GenericNPC_DisabledShoutouts.set(_sContainerName, _arrTopics);
					for (uint i = 0; i < _arrTopics.length(); ++i)
					{
						m_Reference.GetWorld().EnableDialogueTopic(_sContainerName, _arrTopics[i], false);
					}
				}
			}
		}
	}

	/*	--------------------------------------------------
	*	When flavour conversation between NPCs is finished
	*	and 2nd participant POI beahviour is enabled, we
	*	reenable all flavour shoutouts for it 
	*	--------------------------------------------------
	*/
	void EnableGenericFlavourShoutouts(string _sContainerName)
	{
		array<string> _arrTopics;
		m_GenericNPC_DisabledShoutouts.get(_sContainerName, _arrTopics);
		if(_arrTopics.length() != 0)
		{
			for (uint i = 0; i < _arrTopics.length(); ++i)
			{
				m_Reference.GetWorld().EnableDialogueTopic(_sContainerName, _arrTopics[i], true);
			}
		}
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- HANDLING GODSTONES ----------------------------------------------------------------------------------

	void GodstonesSetUp()
	{
		Variables@ _HostGlobalVariables = m_Reference.GetVariables(m_Reference.GetHostFaction());
		for (uint i = 0; i < m_arrGodstones.length(); ++i)
		{
			if(_HostGlobalVariables.GetGlobalBool("Journey_EverlightGodstones."+m_arrGodstones[i]) == true)
			{
				m_Reference.GetBuildingByName(m_arrGodstones[i]).SetFaction(m_Reference.GetHostFaction());
			}
		}
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- HUB SETUP ----------------------------------------------------------------------------------------------------

	void HUB_SetUp()
	{
		// Checking if testing setup is enabled
		m_bTestSetup = m_Reference.GetWorld().GetGlobalBool("Journey_CampaignVariables.Journey_bTestSetup");

		// Activating initial HUB quests
		for(uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			Variables@ _FactionGlobalVariables = m_Reference.GetVariables(_uFaction);
			if(_FactionGlobalVariables.GetGlobalBool("Journey_CampaignVariables.Journey_500_bReceivedInitialQuests") == false)
			{
				m_Reference.GetJournal(_uFaction).ActivateQuest(m_sSideQuest_500_Q0, true);
				// Activating a quest to see Lacaine, on complition of which global collectibles quest will start
				m_Reference.GetJournal(_uFaction).ActivateQuest(m_sSideQuest_500_Q2, true);		
				// Activating a quest to see miniboss trophies collector, on complition of which global collectibles quest will start
				m_Reference.GetJournal(_uFaction).ActivateQuest(m_sSideQuest_500_Q3, true);
				_FactionGlobalVariables.SetGlobalBool("Journey_CampaignVariables.Journey_500_bReceivedInitialQuests", true);
			}
		}

		// Setting up correct dialogues depending on host's quest progress
		DialoguesSetUp();

		// Activating unlocked godstones to players
		GodstonesSetUp();

		// Configuring weather in accordance with currently active setting
		EnableEverlightWeather();
	}

	// Fired on InitCommon
	void SetFlavourNPCsImmovable()
	{
		array<string> _arrkeys = m_FlavourDialoguesTriggers_RandomSOs.getKeys();
		for (uint i = 0; i < _arrkeys.length(); ++i)
		{
			array<string> _arrLinkedSpawns = m_Reference.GetLinkedObjects(_arrkeys[i], false);
			for (uint j = 0; j < _arrLinkedSpawns.length(); ++j)
			{
				Creature[] _FlavourNPCs = m_Reference.GetCreaturesFromSpawn(_arrLinkedSpawns[j]);
				for (uint k = 0; k < _FlavourNPCs.length(); ++k)
				{
					_FlavourNPCs[k].SetImmovable(true);
				}
			}
		}
	}

	void SetTradersImmovable()
	{
		for (uint i = 0; i < m_arrTraders.length(); ++i)
		{
			m_Reference.GetCreatureByName(m_arrTraders[i]).SetImmovable(true);
		}
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- DEBUG ----------------------------------------------------------------------------------------------------

	void EnableCompanionsControl()
	{
		for ( uint i = 0; i < m_arrJourneyCompanions.length(); i++ )
		{
			m_Reference.GetCreatureByName(m_arrJourneyCompanions[i]).SetImmovable( false );
			m_Reference.GetCreatureByName(m_arrJourneyCompanions[i]).SetPlayerControllable( true );
		}
	}

	// Fired on activation of Journey_500_SQ0_HireCompanions quest
	void GiveStartCurrency()
	{
		for(uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			Variables@ _FactionGlobalVariables = m_Reference.GetVariables(_uFaction);
			if(_FactionGlobalVariables.GetGlobalBool("Journey_CampaignVariables.Journey_500_bReceivedStartCurrency") == false)
			{
				_FactionGlobalVariables.SetGlobalBool("Journey_CampaignVariables.Journey_500_bReceivedStartCurrency", true);
				m_Reference.GetHeroParty(_uFaction).AddGold(10000);
				m_Reference.GetHeroParty(_uFaction).AddItems("EXP2_Salvage_Plates", 20, true);
				m_Reference.GetHeroParty(_uFaction).AddItems("EXP2_Salvage_Blades", 20, true);
				m_Reference.GetHeroParty(_uFaction).AddItems("EXP2_Salvage_MagicEssence", 20, true);
			}
		}
	}

	void AddExp(uint _uExp)
	{
		m_Reference.GetHeroParty(m_Reference.GetHostFaction()).AddExperience(_uExp);
	}

	void TestSetup(bool _Enabled)
	{
		m_Reference.GetWorld().SetGlobalBool("Journey_CampaignVariables.Journey_bTestSetup", _Enabled);
		print("Testing setup is currently enabled: " + _Enabled);
	}

	void JourneyCompanionOwn(string _CompanionName)
	{
		m_Reference.GetWorld().SetGlobalBool("Journey_CampaignVariables.Journey_"+_CompanionName+"_Companion_bUnlocked", true);
		m_Reference.GetHeroParty(m_Reference.GetHostFaction()).SetHeroOwned("Journey_"+_CompanionName+"_Companion", true, true);
	}

	void AddGlobalCollectible(uint _uAmount)
	{
		for(uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.GetHeroParty(m_Reference.GetPlayerFactions(true)[i]).AddItems(m_sGlobalCollectibleItem, _uAmount, true);
		}
	}

	// -------------------------------------------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------------------------------------


	// ferrymen

	/*	-----------------------------------------------------------------------------------
	*	Need to grab the current location of the party to remove the option to sail to one's
	*	own current location. Because the dialogue has 'Requires all hero parites' check, we
	*	only compare distances with the host avatar
	*	-----------------------------------------------------------------------------------
	*/
	void GetCurrentLocationForFerry()
	{
		array<string> _sLocations =
		{
			"Spot_Docks",
			"Spot_CreatorsGuild",
			"Spot_SouthernBeach",
			"Spot_Farms"
		};

		uint _uClosest = 0;

		for (uint i = 0; i < _sLocations.length(); i++)
		{
			if (m_Reference.GetEntityDistance(m_iHostAvatarId, m_Reference.GetLogicObjectByName(_sLocations[i]).GetId()) <
				m_Reference.GetEntityDistance(m_iHostAvatarId, m_Reference.GetLogicObjectByName(_sLocations[_uClosest]).GetId()))
			{
				_uClosest = i;
			}
		}

		print(_sLocations[_uClosest]);

		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_500_iCurrentFerryLocation", _uClosest);
	}

	// possible ferry destinations in Journey hub
	// EL_Ferry_Docks
	// EL_Ferry_CreatorsGuild
	void TakeFerryTo(string _sDestination)
	{
		uint _uFaction;
		Creature[] _Ferrymen = m_Reference.FindCreaturesByPrefix("EL1_Ferryman");
		for(uint i = 0; i < _Ferrymen.length(); ++i)
		{
			if(_Ferrymen[i].IsInDialogue())
			{
				_uFaction = _Ferrymen[i].GetDialogueInitiator(m_Reference).GetFaction();
			}
		}

		m_Reference.GetHeroParty(_uFaction).RemoveGold(25);
		m_Reference.FadeToBlackAndBack(uint8(-1), uint8(-1), 1500, 500);
		m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.TakeFerryTo_Timer), 1500, _sDestination);
		m_Reference.PlaySound(uint8(-1), uint8(-1), "ui/interact_use_ship", m_Reference.GetCreatureById(m_iHostAvatarId));
	}

	bool TakeFerryTo_Timer(const string& in _sDestination)
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			Creature _Avatar = m_Reference.GetHeroParty(_uFaction).GetMembers()[0];
			_Avatar.Teleport(m_Reference, m_Reference.GetLogicObjectByName(_sDestination));
			m_Reference.FocusCamera(_uFaction, _Avatar);
		}
		return true;
	}

	// scrapper
	void Setup_MasterScrapper_ItemSets()
	{ 
		array<string> ItemSets;
		m_MasterScrapper_ItemSets.get("All", ItemSets);
		array<string> keys = m_MasterScrapper_ItemSets.getKeys();
		if(ItemSets is null || ItemSets.length() == 0)
		{
			print("NO MASTER SCRAPPER SETUP");
			return;
		}

		Creature MasterScrapper = m_Reference.GetCreatureByName("Journey_EverlightScrapper");
		if(MasterScrapper.Exists() == false || MasterScrapper.IsEnabled() == false)
		{
			print("Master Scrapper should be existing but isn't");
			return;
		}

		for(uint i = 0; i < ItemSets.length(); i++)
		{
			MasterScrapper.AddCraftingRecipes(m_Reference, ItemSets[i]);
		}

	}
}