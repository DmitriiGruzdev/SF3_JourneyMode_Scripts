// ------------------------------------------------------------------------------------------------------------------------------------

// includes:
#include "../../basicScripts/Journey_LevelBase.as"


class Level: Journey_LevelBase
{
	// count this version-number up. This is for later version tracking, when the QA plays the map.
	string m_Version_Level = "QA hasn't played the map yet"; 

	// -------------------------------------------------------------------------------------------------------------------
	// --- Member Variables ----------------------------------------------------------------------------------------------

	// Used in map intros/outros
	string m_sArlanFinrior = "Journey_ArlanFinrior_504";
	string m_sMapIntroTopic = "Journey_504_Scryer_MapIntro";

	string m_stgSect_Leafshade = 			"Sector_Leafshade";

	// Factions
	uint8 m_i0_PlayerFaction = 				0;
	uint8 m_i1_PlayerFaction = 				1;
	uint8 m_i2_PlayerFaction = 				2;
	uint8 m_iRedOrcs =		 		        3;
	uint8 m_iOrangeOrcs =		 		    4;
	uint8 m_iRedOrcs_Defence =		 		5;
	uint8 m_iOrangeOrcs_Defence =		    6;
	uint8 m_iSentientSpider =		 		7;
	uint8 m_iLeafshadeElves =		 		8;

	array<uint> OrcFactions = 
	{
		m_iRedOrcs,
		m_iOrangeOrcs,
		m_iRedOrcs_Defence,
		m_iOrangeOrcs_Defence
	};

	dictionary m_PlayersInititalSectors =
	{
		{"Sector_0", m_i0_PlayerFaction},
		{"Sector_12", m_i1_PlayerFaction},
		{"Sector_6", m_i2_PlayerFaction}
	};

	string m_Player_StartSector = 		    "Sector_0";
	string m_RedOrcs_StartSector = 		    "Sector_5";
	string m_OrangeOrcs_StartSector = 		"Sector_10";

	string m_sQuestSpider = "Journey_SentientSpider_504";
	bool m_bSentientSpider_IsFree = false;

	// Quest timers
	uint m_iTimeToNextReinforcement = 5 * 60;

	// Quests
	string m_sMainQuest_504 = "Journey_504_Q0_DefendLathweyn";
	string m_sSideQuest_504 = "Journey_504_SQ0_SaveSentientSpider";

	array<string> m_arrQuestSpawns =
	{
		"OrangeOrcs_AirDefence_01",
		"OrangeOrcs_AirDefence_02",
		"OrangeOrcs_CapitalDefence_01",
		"OrangeOrcs_GroundDefence_01",
		"OrangeOrcs_GroundDefence_02",
		"OrangeOrcs_HeroSpawn",
		"RedOrcs_AirDefence_01",
		"RedOrcs_AirDefence_02",
		"RedOrcs_CapitalDefence_01",
		"RedOrcs_GroundDefence_01",
		"RedOrcs_GroundDefence_02",
		"RedOrcs_HeroSpawn"
	};

	// Shrines from the main game
	array<string> m_arrElvenShrines =
	{
		"Shrine_Northeast",
		"Shrine_Northwest",
		"Shrine_Southeast",
		"Shrine_Southwest"
	};

	/*	--------------------------------------------------
	*	Not used at all now. Maybe activating random "free roam" 
	*	spawns on map launch will be a good idea
	*	--------------------------------------------------
	*/
	array<string> m_arrFreeRoamSpawns =
	{
		"SpidersSpawn_01",
		"SpidersSpawn_02",
		"SpidersSpawn_03",
		"SpidersSpawn_04",
		"SpidersSpawn_05",
		"SpidersSpawn_06",
		"SpidersSpawn_07",
		"SpidersSpawn_08",
		"SpidersSpawn_09",
		"SpidersSpawn_10",
		"SpidersSpawn_11",
		"SpidersSpawn_12"
	};

	// --------------------------------------------------------------------------------------------------------------------
	// --- constructor --- dont make any changes here
	Level (LevelReference@ _Reference)
	{
		super(_Reference);
	}
	// -------------------------------------------------------------------------------------------------------------------
	// overriden:

	// Function that is called when the Level is created for the first time - only called once within the campaign
	void OnCreated () override
	{
		Journey_LevelBase::OnCreated();
		print("--- M A P : Level Script: '"+m_Version_Level+"', Map: '"+ m_Reference.GetMapId() +"', Setting: '"+ m_Reference.GetWorld().GetCurrentMapSetting( m_Reference.GetMapId() )+"'");

		// Calling the final functions
		InitEvents(); // register all neutral events
		InitCommon(); // script and set everything up for starting the level
	}

	// level data had been restored from savegame - ensure version compability here
	void OnLoaded (const uint _uVersion) override
	{
		Journey_LevelBase::OnLoaded(_uVersion);
		print("--- M A P : Level Script: '"+m_Version_Level+"', Map: '"+ m_Reference.GetMapId() +"', Setting: '"+ m_Reference.GetWorld().GetCurrentMapSetting( m_Reference.GetMapId() )+"'");
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---  A L L  B A S I C S  E V E N T S  -----------------------------------------------------------------------------

	void InitEvents ()
	{
		m_Reference.RegisterBuildingEventByIndividual(Destroyed, TOnBuildingEvent(@this.OnDestroyedMainBase_RedOrcsLost), m_Reference.GetSectorByName(m_RedOrcs_StartSector).GetMainBuilding());
		m_Reference.RegisterBuildingEventByIndividual(Destroyed, TOnBuildingEvent(@this.OnDestroyedMainBase_OrangeOrcsLost), m_Reference.GetSectorByName(m_OrangeOrcs_StartSector).GetMainBuilding());
		m_Reference.RegisterBuildingEventByIndividual(Destroyed, TOnBuildingEvent(@this.OnDestroyedBarricade_FreeSpider), m_Reference.GetBuildingByName("SpiderBarricade"));
	}

	void InitCommon ()
	{
		ActivateRandomLoot(100);

		// Activating quest relevant spawns
		for (uint i = 0; i < m_arrQuestSpawns.length(); ++i)
		{
			m_Reference.ActivateSpawn( m_arrQuestSpawns[i], true );
		}
		
		// Wyverns patrols
		for(uint i = 0; i < m_Reference.GetCreaturesFromSpawn("OrangeOrcs_AirDefence_01").size(); i++)
		{
			m_Reference.GetCreaturesFromSpawn("OrangeOrcs_AirDefence_01")[i].Patrol(m_Reference, "OrangeOrcs_AirDefence_PatrolPath_01", true, true, true, true, false);
		}
		for(uint i = 0; i < m_Reference.GetCreaturesFromSpawn("OrangeOrcs_AirDefence_02").size(); i++)
		{
			m_Reference.GetCreaturesFromSpawn("OrangeOrcs_AirDefence_02")[i].Patrol(m_Reference, "OrangeOrcs_AirDefence_PatrolPath_02", true, false, true, true, false);
		}
		for(uint i = 0; i < m_Reference.GetCreaturesFromSpawn("RedOrcs_AirDefence_01").size(); i++)
		{
			m_Reference.GetCreaturesFromSpawn("RedOrcs_AirDefence_01")[i].Patrol(m_Reference, "RedOrcs_AirDefence_PatrolPath_01", true, true, true, true, false);
		}
		for(uint i = 0; i < m_Reference.GetCreaturesFromSpawn("RedOrcs_AirDefence_02").size(); i++)
		{
			m_Reference.GetCreaturesFromSpawn("RedOrcs_AirDefence_02")[i].Patrol(m_Reference, "RedOrcs_AirDefence_PatrolPath_02", true, false, true, true, false);
		}

		m_Reference.GetLogicObjectByName("BarricadeExplosion_FX").Enable(false);

		// Disabling elven shrines. We can add gameplay to them if the map feels plain
		for (uint i = 0; i < m_arrElvenShrines.length(); ++i)
		{
			m_Reference.GetBuildingByName(m_arrElvenShrines[i]).Enable(false);
		}

		// Blocking Leafshade sector so players won't be able to capture it
		m_Reference.GetSectorByName("Sector_Leafshade").SetBlocked(true);

		m_Reference.GetBuildingByName("ReinforcementsSpawner").SetIndestructible(true);

		m_Reference.GetBuildingByName("Godstone_QuestGiver").SetFaction(m_Reference.GetHostFaction());

		SetupIntroCreatures(m_sArlanFinrior, m_sMapIntroTopic);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T  F U N C T I O N S ---------------------------------------------------------------------------------

	bool OnDestroyedMainBase_RedOrcsLost(Building&in _Building)
	{
		m_Reference.LoseGame(m_iRedOrcs);
		m_Reference.LoseGame(m_iRedOrcs_Defence);
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_504, "DestroyRedOrcs", Completed);
		if (m_Reference.GetSectorByName( m_OrangeOrcs_StartSector ).GetOwner() == m_iOrangeOrcs)
		{
			CheckpointReached();
			m_Reference.ActivateSpawn( "OrangeOrcs_TitanSpawn", true );
			if (m_bSentientSpider_IsFree == true && m_Reference.GetCreatureByName(m_sQuestSpider).Exists() == true)
			{
				m_Reference.GetCreatureByName(m_sQuestSpider).AttackPosition(m_Reference ,m_Reference.GetSectorByName(m_OrangeOrcs_StartSector).GetMainBuilding(), false, false);
			}

			JourneyExplorationShoutout(_Building, "Journey_504_SO_DestorySecondEnemyBase");
		}
		else if (m_Reference.GetSectorByName( m_OrangeOrcs_StartSector ).GetOwner() != m_iOrangeOrcs)
		{
			OrcsDestroyed();
			JourneyExplorationShoutout(_Building, "Journey_504_SO_ReportToQuestGiver");

			if (m_Reference.GetSharedJournal().IsTaskActive(m_sSideQuest_504, "SpiderMustSurvive") == true && m_Reference.GetSharedJournal().GetTaskState(m_sSideQuest_504, "SpiderMustSurvive") != Failed)
			{
				m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_504, "SpiderMustSurvive", Completed);
				m_Reference.GetCreatureByName(m_sQuestSpider).GoTo( m_Reference, m_Reference.GetLogicObjectByName("SentientSpider_LeaveGoTo"), 0, 0, false, false );
				m_Reference.GetCreatureByName(m_sQuestSpider).SetImmortal(true);
				m_Reference.RegisterCreatureEventByIndividuals(GoToFinished, TOnCreatureEvent(@this.OnSpiderReachedMapEdge_DisableIt), m_Reference.GetCreaturesFromSpawn("BossSpiderSpawn_01"), false, "");
			}
		}

		return true;
	}

	bool OnDestroyedMainBase_OrangeOrcsLost(Building&in _Building)
	{
		m_Reference.LoseGame(m_iOrangeOrcs);
		m_Reference.LoseGame(m_iOrangeOrcs_Defence);
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_504, "DestroyOrangeOrcs", Completed);
		if (m_Reference.GetSectorByName( m_RedOrcs_StartSector ).GetOwner() == m_iRedOrcs)
		{
			CheckpointReached();
			m_Reference.ActivateSpawn( "RedOrcs_TitanSpawn", true );
			if (m_bSentientSpider_IsFree == true && m_Reference.GetCreatureByName(m_sQuestSpider).Exists() == true)
			{
				m_Reference.GetCreatureByName(m_sQuestSpider).AttackPosition(m_Reference ,m_Reference.GetSectorByName(m_RedOrcs_StartSector).GetMainBuilding(), false, false);
			}

			JourneyExplorationShoutout(_Building, "Journey_504_SO_DestorySecondEnemyBase");
		}
		else if (m_Reference.GetSectorByName( m_RedOrcs_StartSector ).GetOwner() != m_iRedOrcs)
		{
			OrcsDestroyed();
			JourneyExplorationShoutout(_Building, "Journey_504_SO_ReportToQuestGiver");

			if (m_Reference.GetSharedJournal().IsTaskActive(m_sSideQuest_504, "SpiderMustSurvive") == true && m_Reference.GetSharedJournal().GetTaskState(m_sSideQuest_504, "SpiderMustSurvive") != Failed)
			{
				m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_504, "SpiderMustSurvive", Completed);
				m_Reference.GetCreatureByName(m_sQuestSpider).GoTo( m_Reference, m_Reference.GetLogicObjectByName("SentientSpider_LeaveGoTo"), 0, 0, false, false );
				m_Reference.GetCreatureByName(m_sQuestSpider).SetImmortal(true);
				m_Reference.RegisterCreatureEventByIndividuals(GoToFinished, TOnCreatureEvent(@this.OnSpiderReachedMapEdge_DisableIt), m_Reference.GetCreaturesFromSpawn("BossSpiderSpawn_01"), false, "");
			}
		}

		return true;
	}

	bool OnAnyHeroInside_FreeSpiderShoutout( Creature& in _Creature )
	{
		if(m_Reference.GetSharedJournal().GetTaskState(m_sSideQuest_504, "FreeTheSpider") != Completed)
		{
			m_Reference.UnregisterHeroPartyEvent(AnyInside, TOnHeroPartyEvent(@this.OnAnyHeroInside_FreeSpiderShoutout));
			JourneyExplorationShoutout(_Creature, "Journey_504_SO_FreeSpiderSuggestion");
		}
		return true;
	}

	// Handling releasing the Sentient Spider
	bool OnDestroyedBarricade_FreeSpider(Building& in _Building)
	{
		m_Reference.GetLogicObjectByName("BarricadeExplosion_FX").Enable(true);
		m_Reference.SetTimer( TOnTimerEvent( @this.DisableExplosionFX_Timer ), 3);
		m_bSentientSpider_IsFree = true;

		//set spider/other factions relations
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.SetFactionRelation(m_Reference.GetPlayerFactions(true)[i], m_iSentientSpider, Allied);
		}

		for (uint i = 0; i < OrcFactions.length(); ++i)
		{
			m_Reference.SetFactionRelation(m_iSentientSpider, OrcFactions[i], Hostile);
		}
		
		if (m_Reference.GetSectorByName( m_OrangeOrcs_StartSector ).GetOwner() == m_iOrangeOrcs)
		{
			m_Reference.GetCreatureByName(m_sQuestSpider).AttackPosition(m_Reference, m_Reference.GetSectorByName(m_OrangeOrcs_StartSector).GetMainBuilding(), false, false);
		}
		else if (m_Reference.GetSectorByName( m_OrangeOrcs_StartSector ).GetOwner() != m_iOrangeOrcs && m_Reference.GetSectorByName( m_RedOrcs_StartSector ).GetOwner() == m_iRedOrcs)
		{
			m_Reference.GetCreatureByName(m_sQuestSpider).AttackPosition(m_Reference, m_Reference.GetSectorByName(m_RedOrcs_StartSector).GetMainBuilding(), false, false);
		}
		else if (m_Reference.GetSectorByName( m_OrangeOrcs_StartSector ).GetOwner() != m_iOrangeOrcs && m_Reference.GetSectorByName( m_RedOrcs_StartSector ).GetOwner() != m_iRedOrcs)
		{
			m_Reference.GetCreatureByName(m_sQuestSpider).GoTo( m_Reference, m_Reference.GetLogicObjectByName("SentientSpider_LeaveGoTo"), 0, 0, false, false );
			m_Reference.RegisterCreatureEventByIndividuals(GoToFinished, TOnCreatureEvent(@this.OnSpiderReachedMapEdge_DisableIt), m_Reference.GetCreaturesFromSpawn("BossSpiderSpawn_01"), false, "") ;
			m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_504, "SpiderMustSurvive", Completed);
		}

		m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_504, "FreeTheSpider", Completed);

		return true;
	}

	bool DisableExplosionFX_Timer()
	{
		m_Reference.GetLogicObjectByName("BarricadeExplosion_FX").Enable(false);
		return true;
	}


	bool SpawnReinforcements_LoopedTimer()
	{
		if ((m_Reference.GetSharedJournal().IsTaskActive(m_sMainQuest_504, "ReportBackToTheScryer") == false))
		{
			SpawnReinforcements();
			m_Reference.CreateCountdownTimer(0, m_iTimeToNextReinforcement, TOnTimerEvent(@this.SpawnReinforcements_LoopedTimer), m_Reference.GetHostFaction() , "Journey_504_TimeToNextReinforcement");
		}
	
		return true;
	}

	// Handling the spider leaving the forest
	bool OnSpiderReachedMapEdge_DisableIt( Creature &in _Creature )
	{
		m_Reference.GetCreatureByName(m_sQuestSpider).Enable( false );
		return true;
	}
	
	// -------------------------------------------------------------------------------------------------------------------
	// --- A R T I C Y  F U N C T I O N S --------------------------------------------------------------------------------

	void ActivateElvenReinforcements()
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_504, "ReinforcementsTimer", true);
		m_Reference.CreateCountdownTimer(0, m_iTimeToNextReinforcement, TOnTimerEvent(@this.SpawnReinforcements_LoopedTimer), m_Reference.GetHostFaction() , "Journey_504_TimeToNextReinforcement");
		SpawnReinforcements();
	}

	void ActivateSpiderSideQuest()
	{
		m_Reference.GetSharedJournal().ActivateQuest(m_sSideQuest_504, true);
	}

	void CompleteSpiderSideQuest()
	{
		m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_504, "GetRewardScryer", Completed);
	}

	void FailSpiderSideQuest()
	{
		m_Reference.GetSharedJournal().SetQuestState(m_sSideQuest_504, Failed);
	}

	void StartRTS()
	{
		if(m_Reference.GetPlayerFactions(true).length() > 1)
		{
			InitialSectorsDistribution(m_PlayersInititalSectors);
		}
		else
		{
			m_Reference.GetSectorByName("Sector_0").CreateCapital(m_Reference.GetHostFaction(), true, false);
		}

		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.AddVisibleSector( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetSectorByName(m_stgSect_Leafshade).GetIndex());
		}

		ActivateElvenReinforcements();
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_504, "DestroyOrangeOrcs", true);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_504, "DestroyRedOrcs", true);
	}

	void PlayerSkippedMapIntro()
	{
		ActivateSpiderSideQuest();
		StartRTS();
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- C U S T O M   F U N C T I O N S -------------------------------------------------------------------------------

	void SpawnReinforcements()
	{
		array<uint> _arrJoinedPlayers;
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			if (m_Reference.GetPlayerFactions(true)[i] != m_Reference.GetHostFaction())
			{
				_arrJoinedPlayers.insertLast(m_Reference.GetPlayerFactions(true)[i]);
			}
		}

		if (_arrJoinedPlayers.length() == 1)
		{
			m_Reference.CastSpell("Journey_504_ReinforcementsSpawn", _arrJoinedPlayers[0], m_Reference.GetLogicObjectByName("ElvenReinforcements_SpawnSpot"));
			JourneyExplorationShoutout(m_Reference.GetHeroParty(_arrJoinedPlayers[0]).GetMembers()[0], "Journey_504_SO_AvailableReinforcementsHint");
		}
		else if (_arrJoinedPlayers.length() == 2)
		{
			m_Reference.CastSpell("Journey_504_ReinforcementsSpawn_Shortened", _arrJoinedPlayers[0], m_Reference.GetLogicObjectByName("ElvenReinforcements_SpawnSpot"));
			m_Reference.CastSpell("Journey_504_ReinforcementsSpawn_Shortened", _arrJoinedPlayers[1], m_Reference.GetLogicObjectByName("ElvenReinforcements_SpawnSpot"));
			uint _uRandom = m_Reference.GetRandom().GetInteger(0, 1);
			JourneyExplorationShoutout(m_Reference.GetHeroParty(_arrJoinedPlayers[_uRandom]).GetMembers()[0], "Journey_504_SO_AvailableReinforcementsHint");
		}
		else if (_arrJoinedPlayers.length() == 0)
		{
			m_Reference.CastSpell("Journey_504_ReinforcementsSpawn", m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName("ElvenReinforcements_SpawnSpot"));
			JourneyExplorationShoutout(m_Reference.GetCreatureById(m_iHostAvatarId), "Journey_504_SO_AvailableReinforcementsHint");
		}
	}

	void OrcsDestroyed()
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_504, "ReportBackToTheScryer", true);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_504, "ReinforcementsTimer", false);

		// Changing Everlight weather
		SetEverlightWeather();
	}
}
