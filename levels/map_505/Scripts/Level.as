 // ------------------------------------------------------------------------------------------------------------------------------------
// includes:
#include "../../basicScripts/Journey_LevelBase.as"

	
// ------------------------------------------------------------------------------------------------------------------------------------
// classes:

class Level: Journey_LevelBase
{
	string m_Version_Level = "QA hasn't played the map yet";
	
// --------------------------------------------------------------------------------------------------------------------------------
// --- G E N E R A L  V A R I A B L E S -------------------------------------------------------------------------------------------
	
	// Used in map intros/outros
	string m_sScholar = "Journey_RoadScholar_505";
	string m_sMapIntroTopic = "Journey_505_RoadScholar_MapIntro";

	// Factions
	uint8 m_i0_PlayerFaction = 				0;
	uint8 m_i1_PlayerFaction = 				1;
	uint8 m_i2_PlayerFaction = 				2;
	uint8 m_iFaction_RuneWarrior = 			4;
	uint8 m_iRoadScholarFaction = 			5;

	// Quests
	string m_sMainQuest_505 = "Journey_505_Q0_CollectShaperArtifacts";

	string m_sQuestItem_505 = "Journey_ShaperArtifact_505";

	// Quest-related
	array<string> m_arrShaperGolems_Spawns = 
	{
		"ShaperGolem_Medium_Spawn_01",
		"ShaperGolem_Medium_Spawn_02",
		"ShaperGolem_Medium_Spawn_03",
		"ShaperGolem_Medium_Spawn_04",
		"ShaperGolem_Medium_Spawn_05"
	};

	// lootable pillars
	array<string> m_arrLootablePillars = 
	{
		"Loot_Shaper_Pillar_01",
		"Loot_Shaper_Pillar_02",
		"Loot_Shaper_Pillar_03",
		"Loot_Shaper_Pillar_04",
		"Loot_Shaper_Pillar_05"
	};

	array<string> m_arrPillarsFX = 
	{
		"Loot_Shaper_Pillar_FX_01",
		"Loot_Shaper_Pillar_FX_02",
		"Loot_Shaper_Pillar_FX_03",
		"Loot_Shaper_Pillar_FX_04",
		"Loot_Shaper_Pillar_FX_05"
	};

	// unlootable pillars
	array<string> m_arrUnlootablePillars = 
	{
		"Empty_Shaper_Pillar_01",
		"Empty_Shaper_Pillar_02",
		"Empty_Shaper_Pillar_03",
		"Empty_Shaper_Pillar_04",
		"Empty_Shaper_Pillar_05"
	};

	array<string> m_arrRuneWarriors =
	{
		"M1_TalkingRuneWarrior",
		"M1_Rune_Warrior_01",
		"M1_Rune_Warrior_02",
		"M1_Rune_Warrior_03"
	};

	array<string> m_arrRuneWarriorsSpoken = {};
	array<string> m_arrQuestPillarsSeen = {};
	
	string m_stgM1_grpRuneBarrier =			 	"M1_Barrier";
	string m_stgM1_grpEffectRuneShard_1 = 		"M1_ArchfireForge_1";
	string m_stgM1_grpEffectRuneShard_2 = 		"M1_ArchfireForge_2";

	uint m_iLootedPillars = 0;

	string m_sShaperPillarKey = "Journey_ShaperPillarKey_505";

// ---------------------------------------------------------------------------------------------------------------------------------

	// --- constructor --- dont make any changes here
	Level (LevelReference@ _Reference)
	{
		super(_Reference);
	}
	// -----------------------------------------------------------------------------------------------------------------------------
	// overriden:
	
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
	
// -----------------------------------------------------------------------------------------------------------------------------
// ---  B A S I C S   E V E N T S  -----------------------------------------------------------------------------------------------------------------

	void InitEvents()
	{
		// Rune warriors' greetings
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			for (uint j = 0; j < m_arrRuneWarriors.length(); ++j)
			{
				m_Reference.RegisterHeroPartyEvent( AnyInAggroRange, TOnHeroPartyExtendedEvent(@this.InAggroRange_RuneWarriorReaction), m_arrRuneWarriors[j], m_Reference.GetPlayerFactions(true)[i]);
			}
		}

		// Registering events for updating a quest on seeing a shaper golem
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			for (uint j = 1; j <= 5; ++j)
			{
				m_Reference.RegisterHeroPartyEvent(AnyCanSee, TOnHeroPartyExtendedEvent(@this.OnCanSee_QuestPillar), "Loot_Shaper_Pillar_0"+j, m_Reference.GetPlayerFactions(true)[i]);
			}
		}

		// Registering events for dropping quest items
		for (uint i = 0; i < m_arrShaperGolems_Spawns.length(); ++i)
		{
			m_Reference.RegisterCreatureEventByIndividuals(Killed, TOnCreatureEvent(@this.OnShaperGolemKilled_DropQuestItem), m_Reference.GetCreaturesFromSpawn(m_arrShaperGolems_Spawns[i]), false, "");
		}

		// Registering events for handling looting of quest pilalrs
		for (uint i = 0; i < m_arrLootablePillars.length(); ++i)
		{
			for(uint j = 0; j < m_Reference.GetPlayerFactions(true).length(); ++j)
			{
				m_Reference.RegisterLogicObjectEvent(AllLooted, TOnLogicObjectEvent(@this.OnAllLooted_ShaperPillar), m_arrLootablePillars[i], m_Reference.GetPlayerFactions(true)[j]);		
			}
		}
	}

	void InitCommon()
	{
		ActivateRandomLoot(100);
		for (uint i = 0; i < m_arrRuneWarriors.length(); ++i)
		{
			m_Reference.GetCreatureByName(m_arrRuneWarriors[i]).SetImmovable( true );
		}

		m_Reference.SetFactionRelation( m_iFaction_RuneWarrior, kFactionMob, Neutral );
		m_Reference.SetFactionRelation( m_iFaction_RuneWarrior, kFactionNeutral, Neutral );

		// Nexus entrace blockage 
		m_Reference.EnableGroup( m_stgM1_grpEffectRuneShard_1, true );
		m_Reference.EnableGroup( m_stgM1_grpEffectRuneShard_2, true );
		array <Entity> _entBarrier = m_Reference.GetEntitiesInGroup( m_stgM1_grpRuneBarrier );
		for ( uint _iTmp1 = 0; _iTmp1 < _entBarrier.length(); _iTmp1++ )
		{
			_entBarrier[_iTmp1].SetInteractive( false );
		}

		m_Reference.GetBuildingByName("Godstone_Entrance").SetFaction(m_Reference.GetHostFaction());

		SetupIntroCreatures(m_sScholar, m_sMapIntroTopic);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T  F U N C T I O N S ----------------------------------------------------------------------------------

	bool InAggroRange_RuneWarriorReaction(Creature& in _Creature, Entity[]&in _Params)
	{
		string _sRuneWarrior = m_Reference.FindEntityName(_Params[0]);
		if(m_arrRuneWarriorsSpoken.find(_sRuneWarrior) == -1)
		{
			m_Reference.GetCreatureByName(_sRuneWarrior).Shoutout(m_Reference, _sRuneWarrior, "M1_SO_Greeting", false, kMaxFactions);
			m_arrRuneWarriorsSpoken.insertLast(_sRuneWarrior);
		}
		return true;
	}

	// Quest update on seeing quest pillars
	bool OnCanSee_QuestPillar(Creature &in _Creature, Entity[]&in _Params)
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_505, "KillShaperGolem", true);
		string _sQuestPillar = m_Reference.FindEntityName(_Params[0]);
		if(m_arrQuestPillarsSeen.find(_sQuestPillar) == -1)
		{
			JourneyExplorationShoutout(_Creature, "Journey_505_SO_QuestPillarReaction");
			m_arrQuestPillarsSeen.insertLast(_sQuestPillar);
		}
		return true;
	}

	// Shaper golems drop keys to pillars with quest items
	bool OnShaperGolemKilled_DropQuestItem( Creature &in _Creature )
	{
		_Creature.DropItem( m_Reference, m_sShaperPillarKey, 1 );
		if (m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_505, "KillShaperGolem") != Completed)
		{
			JourneyExplorationShoutout(_Creature, "Journey_505_SO_PillarKeyHint", false, false, false, true);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_505, "KillShaperGolem", Completed);
		}
		return false;
	}

	// Disappearing of the shaper pillar FX when it is looted and removing the key from the inventory
	bool OnAllLooted_ShaperPillar(LogicObject&in _Object, uint8 _uFaction)
	{
		string _sPillar = m_Reference.FindEntityName(_Object); 
		string _sPillarNum = _sPillar.substr(_sPillar.findLast("_", -1)+2, -1);
		m_Reference.GetHeroParty(_uFaction).RemoveItems(m_sShaperPillarKey, 1 );	
		m_Reference.GetLogicObjectByName( "Loot_Shaper_Pillar_FX_0"+_sPillarNum ).Enable( false );
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_505, "CollectArtifact_Pillar_0"+_sPillarNum, Completed);
		m_iLootedPillars ++;
		OnLootedPillar_CheckQuests();

		return false;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- A R T I C Y   F U N C T I O N S ------------------------------------------------------------------------------

	void PlayersSubmitQuestItems()
	{
		uint _uQuestItems = m_Reference.GetHeroParty(m_Reference.GetHostFaction()).GetItemAmount(m_sQuestItem_505, true);
		m_Reference.GetHeroParty(m_Reference.GetHostFaction()).RemoveItems(m_sQuestItem_505, _uQuestItems, true);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---  H E L P E R  F U N C T I O N S  ------------------------------------------------------------------------------

	void OnLootedPillar_CheckQuests()
	{
		if (m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_505, "LootShaperPillar") != Completed)
		{
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_505, "LootShaperPillar", Completed);
		}

		if (m_iLootedPillars == 5)
		{
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_505, "InspectOtherPillars", Completed);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_505, "CollectArtifacts", Completed);
			JourneyExplorationShoutout(GetRandomJourneyHero(), "Journey_505_SO_ReportToQuestGiver");
			// Changing Everlight weather
			SetEverlightWeather();
		}
		else if(m_iLootedPillars == 3)
		{
			CheckpointReached();
		}
	}
}