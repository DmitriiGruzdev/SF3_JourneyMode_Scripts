// includes:
#include "../../basicScripts/Journey_LevelBase.as"

class Level: Journey_LevelBase
{

	// --------------------------------------------------------------------------------------------------------------------
	// --- Member Variables -----------------------------------------------------------------------------------------------


	// count this version-number up. This is for later version tracking, when the QA plays the map. 
	string m_Version_Level = "QA hasn't played the map yet";

	// --- Factions -----------------------------------------------------------------------------------------------------------
	uint8 m_i0_PlayerFaction = 				0;
	uint8 m_i1_PlayerFaction = 				1;
	uint8 m_i2_PlayerFaction = 				2;
	uint8 m_iBandits = 				        3;
	uint8 m_iGolems = 				        4;
	uint8 m_iCreatorsGuild = 				5;

	// Quests
	string m_sMainQuest_503 = "Journey_503_Q0_RefillTheMine";

	string m_sQuestItem_503 = "Journey_VeilMoonsilver_503";

	// Used in map intros/outros
	string m_sCreatorsGuildMage = "Journey_CreatorsGuildMage_503";
	string m_sMapIntroTopic = "Journey_503_CreatorsGuildMage_MapIntro";

	string m_sQuestArtifact = "Journey_VeilDestroyer_503";
	// Main quest related
	int iCollectedOre =                     0;

	// Quest veils
	array<string> m_arrQuestVeils = 
	{
		"Veil_A",
		"Veil_B",
		"Veil_C",
		"Veil_D",
		"Veil_E"
	};

	// Veils seen by players
	array<string> m_arrSeenVeils = {};

	/*	--------------------------------------------------
	*	Not used at all now. Maybe activating random "free roam" 
	*	spawns on map launch will be a good idea
	*	--------------------------------------------------
	*/
	array<string> m_arrFreeRoamSpawns =
	{
		"FreeRoam_GoblinsSpawn_02",
		"FreeRoam_GoblinsSpawn_03",
		"FreeRoam_GoblinsSpawn_04",
		"FreeRoam_GoblinsSpawn_01",
		"FreeRoam_GoblinsSpawn_05",
		"FreeRoam_GoblinsSpawn_06",
		"FreeRoam_GoblinsSpawn_07",
		"FreeRoam_GolemSpawn_01",
		"FreeRoam_GolemSpawn_02",
		"FreeRoam_GolemSpawn_03",
		"FreeRoam_GolemSpawn_04",
		"FreeRoam_GolemSpawn_05"
	};

	array<string> m_arrQuestSpawns =
	{
		"GolemSpawn_04",
		"MeleeBandits_Spawn_01",
		"MeleeBandits_Spawn_02",
		"MeleeBandits_Spawn_03",
		"MeleeBandits_Spawn_04",
		"MeleeBandits_Spawn_05",
		"MeleeBandits_Spawn_06",
		"MeleeBandits_Spawn_07",
		"MeleeBandits_Spawn_08",
		"MeleeBandits_Spawn_09",
		"MeleeBandits_Spawn_10",
		"RangeBandits_Spawn_01",
		"RangeBandits_Spawn_02",
		"RangeBandits_Spawn_03",
		"RangeBandits_Spawn_04",
		"RangeBandits_Spawn_05"
	};

	dictionary m_QuestMobsLoot =
	{
		{"Journey_ArchfireBeast_MeleeDisabler_Elite", 0},
		{"Journey_ArchfireBeast_Melee_Elite", 0},
		{"Journey_ArchfireBeast_RangedCorruptor_Elite", 0},
		{"Journey_ArchfireBeast_RangedSorcerer_Elite", 0},
		{"Journey_ArchfireBeast_Reviver_Elite", 0}
	};

	Level (LevelReference@ _Reference)
	{
		super(_Reference);
	}

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
		// Call the original OnLoaded
		Journey_LevelBase::OnLoaded(_uVersion);
		print("--- M A P : Level Script: '"+m_Version_Level+"', Map: '"+ m_Reference.GetMapId() +"', Setting: '"+ m_Reference.GetWorld().GetCurrentMapSetting( m_Reference.GetMapId() )+"'");
	}

	/*
		All events are registered in this function.
		There soudn't be any variable declarations or initialitations
	*/
	void InitEvents ()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.RegisterCreatureInventoryEvent(Equipped, TOnCreatureInventoryEvent(@this.OnEquipmentChange_UpdateQuest), "", m_Reference.GetPlayerFactions(true)[i]);
			m_Reference.RegisterHeroPartyEvent(AnyInside, TOnHeroPartyEvent(@this.GolemFightsBandits), "GolemBandits_FightArea", m_Reference.GetPlayerFactions(true)[i]);
			m_Reference.RegisterLogicObjectEvent(AllLooted, TOnLogicObjectEvent(@this.OnAllLooted_QuestMob), "", m_Reference.GetPlayerFactions(true)[i]);
		}

		for (uint i = 0; i < m_arrQuestVeils.length(); ++i)
		{
			m_Reference.RegisterBuildingEventByIndividual(Damaged, TOnBuildingEvent(@this.OnDamage_QuestVeil), m_arrQuestVeils[i]);
			for (uint j = 0; j < m_Reference.GetPlayerFactions(true).length(); ++j)
			{
				uint _uFaction = m_Reference.GetPlayerFactions(true)[j];
				m_Reference.RegisterHeroPartyEvent(AnyCanSee, TOnHeroPartyExtendedEvent(@this.OnAnyCanSee_VeilShoutout), m_arrQuestVeils[i], _uFaction);
			}
		}

		// Event for updating quest flow on it being added in host's inventory
		m_Reference.RegisterInventoryEvent(Added, TOnInventoryEvent(@this.OnAdded_MoonsilverOre_HostPlayer), m_sQuestItem_503, m_Reference.GetHostFaction());
	}

	/*
		Is called right at the beginning of the level. Should only be used to start a dialoge, or directly stage an event and so on.
	*/
	void InitCommon ()
	{
		ActivateRandomLoot(100);
		// Reseting collected moonsilver ore
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_503_Q0_RefillTheMine_iCollectedOre", 0);

		// Activating quest relevant spawns
		for (uint i = 0; i < m_arrQuestSpawns.length(); ++i)
		{
			m_Reference.ActivateSpawn( m_arrQuestSpawns[i], true );
		}

		m_Reference.BlockNavMesh("CaveExit_Blocker", true);

		SetupIntroCreatures(m_sCreatorsGuildMage, m_sMapIntroTopic);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T  F U N C T I O N S ----------------------------------------------------------------------------------

	bool OnEquipmentChange_UpdateQuest(Creature&in _Creature, const string&in _sItemName, const uint _uAmount)
	{
		if(_sItemName == m_sQuestArtifact)
		{
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_503, "EquipArtifact", Completed);
			m_Reference.UnregisterInventoryEvent(Equipped, TOnCreatureInventoryEvent(@this.OnEquipmentChange_UpdateQuest));
			return true;
		}
		return false;
	} 

	bool GolemFightsBandits( Creature &in _Creature )
	{
		m_Reference.SetFactionRelation(m_iBandits, m_iGolems, Hostile);
		Creature[] _Golems = m_Reference.GetCreaturesFromSpawn( "GolemSpawn_04" );
		if(_Golems.length() > 0)
		{
			m_Reference.GetCreaturesFromSpawn( "GolemSpawn_04" )[0].GoTo( m_Reference, m_Reference.GetLogicObjectByName("Golem_Attack_Spot"), 0, 0, false, false );
		}
		return false;
	}

	bool OnAnyCanSee_VeilShoutout(Creature &in _Creature, Entity[]&in _Params)
	{
		string _sVeil = m_Reference.FindEntityName(_Params[0]);
		if(m_arrSeenVeils.find(_sVeil) == -1)
		{
			m_arrSeenVeils.insertLast(_sVeil);
			JourneyExplorationShoutout(_Creature, "Journey_503_SO_VeilReaction");
		}
		return true;
	}

	bool OnDamage_QuestVeil(Building& in _Building)
	{
		string sQuestVeil = m_Reference.FindEntityName(_Building);
		m_Reference.ActivateSpawn( sQuestVeil+"_Spawn", true );

		Creature _QuestMob = m_Reference.GetCreaturesFromSpawn(sQuestVeil+"_Spawn")[0];
		string _sQuestMob = m_Reference.FindEntityName(_QuestMob);
		m_Reference.RegisterCreatureEventByIndividual(Killed, TOnCreatureEvent(@this.OnCreatureKilled_SpawnDropsItem), _sQuestMob, "");
		m_Reference.RegisterCreatureEventByIndividual(LootDropped, TOnCreatureExtendedEvent(@this.OnLootDropped_QuestMob), _sQuestMob, "");
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_503, _sQuestMob+"_LootQuestMarker", true);
		_QuestMob.SetPreserveBody(true);

		if (m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_503, "KillTheDemon") != Completed)
		{
			m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_503, "KillTheDemon", true);
		}

		return false;
	}

	bool OnCreatureKilled_SpawnDropsItem( Creature &in _Creature )
	{
		_Creature.DropItem( m_Reference, m_sQuestItem_503, 1 );
		JourneyExplorationShoutout(_Creature, "Journey_503_SO_LootDemon", false, false, false, true);
		if (m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_503, "KillTheDemon") != Completed)
		{
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_503, "KillTheDemon", Completed);
		}
		return false;
	}

	bool OnLootDropped_QuestMob(Creature& in _Creature, Entity[]&in _Params)
	{
		string _sCreatureName = _Creature.GetDescriptionName();
		m_QuestMobsLoot.set(_sCreatureName, _Params[0].GetId());
		return true;
	}

	bool OnAllLooted_QuestMob(LogicObject&in _Object, uint8 _uFaction)
	{
		if(m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_503, "CollectMoonsilverOre") == Completed)
		{
			return true;
		}

		uint _uId = _Object.GetId();
		array<string> _arrQuestMobs = m_QuestMobsLoot.getKeys();
		for (uint i = 0; i < _arrQuestMobs.length(); i++)
		{
			uint _uSavedId = 0;
			m_QuestMobsLoot.get(_arrQuestMobs[i], _uSavedId);
			if (_uId == _uSavedId)
			{
				m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_503, _arrQuestMobs[i]+"_LootQuestMarker", false);
			}
		}
		return false;
	}
	
	bool OnAdded_MoonsilverOre_HostPlayer(const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		iCollectedOre = m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_503_Q0_RefillTheMine_iCollectedOre", 0) +1;
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_503_Q0_RefillTheMine_iCollectedOre", iCollectedOre);

		if (m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_503_Q0_RefillTheMine_iCollectedOre", 0) >= m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_503_Q0_RefillTheMine_iOreToCollect", 0))
		{
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_503, "CollectMoonsilverOre", Completed);
			
			JourneyExplorationShoutout(GetRandomJourneyHero(), "Journey_503_SO_ReportToQuestGiver");

			// Changing Everlight weather
			SetEverlightWeather();
			return true;
		}
		else if(m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_503_Q0_RefillTheMine_iCollectedOre", 0) == 3)
		{
			CheckpointReached();
		}

		return false;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- A R T I C Y  F U N C T I O N S --------------------------------------------------------------------------------

	void PlayersReceiveQuestArtifact()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.GetHeroParty(m_Reference.GetPlayerFactions(true)[i]).AddItems(m_sQuestArtifact, 1, true);	
		}
	}

	void PlayersSubmitQuestItems()
	{
		m_Reference.GetHeroParty(m_Reference.GetHostFaction()).RemoveItems(m_sQuestItem_503, iCollectedOre, true);

		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			for (uint j = 0; j < m_Reference.GetHeroParty(_uFaction).GetMembers().length(); ++j)
			{
				string _sEquipedItem = "";
				Creature _Hero = m_Reference.GetHeroParty(_uFaction).GetMembers()[j];
				_Hero.GetEquipment(Item, _sEquipedItem);
				if(_sEquipedItem == m_sQuestArtifact)
				{
					_Hero.Unequip(m_Reference, Item, AddToInventory, uint16 ( - 1 ));
				}
			}
			m_Reference.GetHeroParty(_uFaction).RemoveItems(m_sQuestArtifact, 1, true);
		}
	}
}
