// includes:
#include "../../basicScripts/Journey_LevelBase.as"

class Level: Journey_LevelBase
{

	// --------------------------------------------------------------------------------------------------------------------
	// --- Member Variables -----------------------------------------------------------------------------------------------

	// Used in map intros/outros
	string m_sKeeperArenor = "Journey_KeeperArenor_507";
	string m_sMapIntroTopic = "Journey_507_KeeperArenor_MapIntro";

	// count this version-number up. This is for later version tracking, when the QA plays the map. 
	string m_Version_Level = "QA hasn't played the map yet";

	// --- Factions -----------------------------------------------------------------------------------------------------------
	uint8 m_i0_PlayerFaction = 				0;
	uint8 m_i1_PlayerFaction = 				1;
	uint8 m_i2_PlayerFaction = 				2;
	uint8 m_iIronFalcons = 				    3;
	uint8 m_iNecroOrcs = 				    4;
	uint8 m_iUndeadSummons = 				5;
	uint8 m_iNecroOrcs_Defence = 			6;
	uint8 m_iNecroOrcs_Boss = 				7;
	uint8 m_iIronFalconsDefence = 			8;
	uint8 m_iUndeadMobs = 				    9;
	uint8 m_iCreeps = 		                10;

	array<uint8> m_arrFogDebuffedFactions =
	{
		m_i0_PlayerFaction,
		m_i1_PlayerFaction,
		m_i2_PlayerFaction,
		m_iIronFalcons,
		m_iIronFalconsDefence
	};
	array<uint8> m_arrFogBuffedFactions =
	{
		m_iNecroOrcs,
		m_iUndeadSummons,
		m_iNecroOrcs_Defence,
		m_iNecroOrcs_Boss
	};

	dictionary m_PlayersInititalSectors =
	{
		{"Sector_1", m_i0_PlayerFaction},
		{"Sector_13", m_i1_PlayerFaction},
		{"Sector_2", m_i2_PlayerFaction}
	};

	uint m_iNecroBuffDuration = 5 * 60;
	uint m_iTimeToNextReinforcement = 5 * 60;

	array<string> m_arrUndeadTowers =
	{
		"UndeadTower_01",
		"UndeadTower_02",
		"UndeadTower_03",
		"UndeadTower_04",
		"UndeadTower_05",
		"UndeadTower_06"
	};
	dictionary m_UndeadTower_SummonSpot =
	{
		{"UndeadTower_01", "UndeadSummoningSpot_01"},
		{"UndeadTower_02", "UndeadSummoningSpot_02"},
		{"UndeadTower_03", "UndeadSummoningSpot_03"},
		{"UndeadTower_04", "UndeadSummoningSpot_04"},
		{"UndeadTower_05", "UndeadSummoningSpot_05"},
		{"UndeadTower_06", "UndeadSummoningSpot_06"}
	};

	array<string> m_arrUndeadTowersSectors =
	{
		"Sector_6",
		"Sector_7",
		"Sector_5",
		"Sector_4"
	};

	/*	--------------------------------------------------
	*	Not used at all now. Maybe activating random "free roam" 
	*	spawns on map launch will be a good idea
	*	--------------------------------------------------
	*/
	array<string> m_arrFreeRoamSpawns =
	{
		"Undead_Encounter_00",
		"Undead_Encounter_01",
		"Undead_Encounter_02",
		"Undead_Encounter_03",
		"Undead_Encounter_04",
		"Undead_Encounter_05a",
		"Undead_Encounter_05b",
		"Undead_Encounter_06",
		"Undead_Encounter_07",
		"Undead_Encounter_08",
		"Undead_Encounter_09",
		"Undead_Encounter_10",
		"Undead_SectorEncounter_01a",
		"Undead_SectorEncounter_01b",
		"Undead_SectorEncounter_01c",
		"Undead_SectorEncounter_02",
		"Undead_SectorEncounter_03a",
		"Undead_SectorEncounter_03b",
		"Undead_SectorEncounter_03c",
		"Undead_SectorEncounter_03d",
		"Undead_SectorEncounter_04",
		"Undead_SectorEncounter_05",
		"Undead_SectorEncounter_06a",
		"Undead_SectorEncounter_06b"
	};
	array<string> m_arrQuestSpawns = 
	{
		"UndeadSummonArea_Spawn_06",
		"UndeadSummonArea_Spawn_05",
		"UndeadSummonArea_Spawn_04",
		"UndeadSummonArea_Spawn_03",
		"UndeadSummonArea_Spawn_02",
		"UndeadSummonArea_Spawn_01",
		"UndeadSpawn_15",
		//"UndeadSpawn_14",
		//"UndeadSpawn_13",
		"UndeadSpawn_12",
		"UndeadSpawn_11",
		"UndeadSpawn_10",
		"UndeadSpawn_09",
		"UndeadSpawn_08",
		"UndeadSpawn_07",
		"UndeadSpawn_06",
		"UndeadSpawn_05",
		"UndeadSpawn_04",
		"UndeadSpawn_03",
		"UndeadSpawn_02",
		"UndeadSpawn_01",
		"Sector_12_DefenceArmy_Spawn",
		"Sector_11_DefenceArmy_Spawn",
		"Sector_10_DefenceArmy_Spawn",
		"NecroOrcsPatrol_Spawn_14",
		"NecroOrcsPatrol_Spawn_13",
		"NecroOrcsPatrol_Spawn_12",
		"NecroOrcsPatrol_Spawn_11",
		"NecroOrcsPatrol_Spawn_10",
		"NecroOrcsPatrol_Spawn_09",
		"NecroOrcsPatrol_Spawn_08",
		"NecroOrcsPatrol_Spawn_07",
		"NecroOrcsPatrol_Spawn_06",
		"NecroOrcsPatrol_Spawn_05",
		"NecroOrcsPatrol_Spawn_04",
		"NecroOrcsPatrol_Spawn_03",
		"NecroOrcsPatrol_Spawn_02",
		"NecroOrcsPatrol_Spawn_01",
		"EnemyBase_UndeadSpawn"
	};

	dictionary m_SummonsTypes =
	{
		{"Easy", array<string> = {"Journey_507_UndeadSummonWave_Easy_01", "Journey_507_UndeadSummonWave_Easy_02", "Journey_507_UndeadSummonWave_Easy_03", "Journey_507_UndeadSummonWave_Easy_04"}},
		{"Medium", array<string> = {"Journey_507_UndeadSummonWave_Medium_01", "Journey_507_UndeadSummonWave_Medium_02", "Journey_507_UndeadSummonWave_Medium_03"}},
		{"Hard", array<string> = {"Journey_507_UndeadSummonWave_Hard_01", "Journey_507_UndeadSummonWave_Hard_02", "Journey_507_UndeadSummonWave_Hard_03"}},
		{"Final", array<string> = {"Journey_507_UndeadSummonWave_Final_01", "Journey_507_UndeadSummonWave_Final_02", "Journey_507_UndeadSummonWave_Final_03"}}
	};
	// Initial undead waves configuration
	string m_sCurrentSummonsType = "Easy";
	uint m_iWavesToSummon = 1;
	uint m_iWavesFrequency = 2 * 60;

	uint8 m_iUndeadTowersDestroyed = 0;

	string m_sOrcNecromantBoss = "Journey_OrcNecromantBoss_507";
	bool m_bOrcNecromantBossTransformed = false;

	// Quests
	string m_sMainQuest_507 = "Journey_507_Q0_HelpIronFalcons";

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
		// registering lose events for players on desttroyed falcons' base
		m_Reference.RegisterBuildingEventByIndividual(Destroyed, TOnBuildingEvent( @this.OnDestroyed_MainBase ), m_Reference.GetSectorByName("Sector_0").GetMainBuilding());

		// registering win condition for players
		m_Reference.RegisterBuildingEventByIndividual(Destroyed, TOnBuildingEvent( @this.OnDestroyed_NecroOrcsBase ), m_Reference.GetSectorByName("Sector_12").GetMainBuilding());

		// registering destruction of iron falcons barracks that would prevent more reinforcements for players
		m_Reference.RegisterBuildingEventByIndividual(Destroyed, TOnBuildingEvent( @this.OnDestroyed_IronFalconsBarracks ), "IronFalconsBarracks");

		// registering events for debuffing with necrofog
		for (uint i = 0; i < m_arrFogDebuffedFactions.length(); ++i)
		{
			m_Reference.RegisterCreatureEventByDescription( EnteredArea, TOnCreatureEvent( @this.OnTriggerEnter_NecroFogDebuff ), "", m_arrFogDebuffedFactions[i], "NecroFog_Area" );
		}
		for (uint i = 0; i < m_arrFogDebuffedFactions.length(); ++i)
		{
			m_Reference.RegisterCreatureEventByDescription( LeftArea, TOnCreatureEvent( @this.OnTriggerLeave_NecroFog ), "", m_arrFogDebuffedFactions[i], "NecroFog_Area" );
		}
		// registering events for buffing with necrofog 
		for (uint i = 0; i < m_arrFogBuffedFactions.length(); ++i)
		{
			m_Reference.RegisterCreatureEventByDescription( EnteredArea, TOnCreatureEvent( @this.OnTriggerEnter_NecroFogBuff ), "", m_arrFogBuffedFactions[i], "NecroFog_Area" );
		}

		// registering event to start a boss fight on enemy base
		m_Reference.RegisterCreatureEventByIndividual(EnteredAggroRange, TOnCreatureEvent(@this.OnEnteredAggroRange_OrcNecromantBoss), m_sOrcNecromantBoss, "Enemy");
		// registering event to trigger boss transformation once it has certain HP
		m_Reference.RegisterCreatureEventByIndividual(Damaged, TOnCreatureEvent(@this.OnDamaged_OrcNecromantBoss), m_sOrcNecromantBoss, "");
		// registering event on boss necromant death
		m_Reference.RegisterCreatureEventByIndividual(Killed, TOnCreatureEvent(@this.OnKilled_OrcNecromantBoss), m_sOrcNecromantBoss, "");

		// setting undead faction as owner of all undead towers and registering events on their destruction
		for (uint i = 0; i < m_arrUndeadTowers.length(); ++i)
		{
			m_Reference.GetBuildingByName(m_arrUndeadTowers[i]).SetFaction(m_iUndeadSummons);
			m_Reference.RegisterBuildingEventByIndividual(Destroyed, TOnBuildingEvent(@this.OnDestroyedUndeadTower), m_arrUndeadTowers[i]);
		}
	}

	/*
		Is called right at the beginning of the level. Should only be used to start a dialoge, or directly stage an event and so on.
	*/
	void InitCommon ()
	{
		ActivateRandomLoot(100);
		// Activating initial godstone
		m_Reference.GetBuildingByName("Entity_Godstone_Sector_0").SetFaction(m_Reference.GetHostFaction());

		// Resetting global ints
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_507_Q0_iUndeadTowersDestroyed", m_iUndeadTowersDestroyed);

		// increasing population cap for falcons' because they will only have 1 sector for the whole map 
		m_Reference.SetBaseSupply(m_iIronFalcons, uint(80));

		// Blocking exits from the fortress before talking to keeper arenor
		m_Reference.BlockNavMesh("NorthernExit_Blocker", true);
		m_Reference.BlockNavMesh("SouthernExit_Blocker", true);

		// blocking all sectors that have undead towers so players won't be able to conquer them before destroying the towers
		for (uint i = 0; i < m_arrUndeadTowersSectors.length(); ++i)
		{
			m_Reference.GetSectorByName(m_arrUndeadTowersSectors[i]).SetBlocked(true);
		}

		// disabling enemy base necro auro that should be enabled when a boss fight with orc necromant begins
		m_Reference.EnableGroup("EnemyBaseNecroAura", false, true);

		// Setting up map boss
		m_Reference.GetCreatureByName(m_sOrcNecromantBoss).SetImmortal(true);

		// Activating quest relevant spawns
		for (uint i = 0; i < m_arrQuestSpawns.length(); ++i)
		{
			m_Reference.ActivateSpawn( m_arrQuestSpawns[i], true );
		}

		SetupIntroCreatures(m_sKeeperArenor, m_sMapIntroTopic);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T  F U N C T I O N S ----------------------------------------------------------------------------------

	// lose conditions
	bool OnDestroyed_MainBase(Building& in _Building)
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)	
			m_Reference.LoseGame(m_Reference.GetPlayerFactions(true)[i]);
		
		m_Reference.GetSharedJournal().SetQuestState(m_sMainQuest_507, Failed);
		return true;
	}

	// win condition
	bool OnDestroyed_NecroOrcsBase(Building& in _Building)
	{
		JourneyExplorationShoutout(_Building, "Journey_507_SO_ReportToQuestGiver");
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_507, "DestroyEnemyBase", Completed);
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_507, "ReinforcementsTimer", Completed);
		m_Reference.LoseGame(m_iNecroOrcs);
		m_Reference.LoseGame(m_iNecroOrcs_Defence);

		// Changing Everlight weather
		SetEverlightWeather();

		return true;
	}

	// fail reinforcements task on destroyed falcons' barracks
	bool OnDestroyed_IronFalconsBarracks(Building& in _Building)
	{
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_507, "ReinforcementsTimer", Failed);
		return true;
	}

	// Necrofog related events
	bool OnTriggerEnter_NecroFogDebuff( Creature &in _Creature )
	{
		_Creature.ApplyCondition( 51001, -1, kMaxFactions, 100 );
		return false;
	}
	bool OnTriggerLeave_NecroFog( Creature &in _Creature )
	{
		_Creature.RemoveCondition( 51001 );
		return false;
	}

	bool OnTriggerEnter_NecroFogBuff( Creature &in _Creature )
	{
		_Creature.ApplyCondition( 51002, m_iNecroBuffDuration, kMaxFactions, 100 );
		return false;
	}

	// Boss fight related events
	bool OnEnteredAggroRange_OrcNecromantBoss( Creature &in _Creature )
	{
		JourneyDialogShoutout(m_sOrcNecromantBoss, m_sOrcNecromantBoss, "Journey_507_SO_BossFightStart");
		m_Reference.GetCreatureByName(m_sOrcNecromantBoss).PlayAnimation(m_Reference, CastShortSelf, -1, 3000, false, false, Entity ( ), false, false, false);
		m_Reference.GetSectorByName("Sector_12").GetMainBuilding().ApplyCondition(1, -1, kMaxFactions, 100);
		m_Reference.EnableGroup("EnemyBaseNecroAura", true, true);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_507, "KillOrcNecromant", true);
		CreatureGroup _Grp_EnemyBaseUndead = CreatureGroup(m_Reference, m_Reference.GetCreaturesFromSpawn("EnemyBase_UndeadSpawn"));
		_Grp_EnemyBaseUndead.AttackPosition(_Creature, false, false);
		return true;
	}
	bool OnDamaged_OrcNecromantBoss( Creature &in _Creature )
	{
		if( _Creature.GetCurrentHP() <= PercentOf( _Creature.GetMaxHP(), 25) && m_bOrcNecromantBossTransformed != true)
		{
			JourneyDialogShoutout(m_sOrcNecromantBoss, m_sOrcNecromantBoss, "Journey_507_SO_BossTransformation");
			m_Reference.GetCreatureByName(m_sOrcNecromantBoss).ForceCast(m_Reference, "Journey_507_BossDemon_TransformBase", m_Reference.GetCreatureByName(m_sOrcNecromantBoss), false);
			m_Reference.RegisterCreatureEventByIndividual( SpellCast, TOnCreatureEvent( @this.OnTransformFinished_OrcNecromantBoss ), m_sOrcNecromantBoss, "" );
			print("OrcNecromantBoss started transformation");
			return true;
		}
		return false;
	}
	bool OnTransformFinished_OrcNecromantBoss( Creature &in _Creature )
	{
		print("OrcNecromantBoss has transformed");
		m_bOrcNecromantBossTransformed = true;
		m_Reference.GetCreatureByName(m_sOrcNecromantBoss).SetImmortal(false);
		m_Reference.CastSpell("Journey_507_OrcNecromantBossHeal", m_iNecroOrcs_Boss, m_Reference.GetCreatureByName(m_sOrcNecromantBoss));
		return true;
	}
	bool OnKilled_OrcNecromantBoss( Creature &in _Creature )
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_507, "ProtectiveAuraHint", false);
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_507, "KillOrcNecromant", Completed);
		m_Reference.CastSpell("Journey_507_OrcNecromantBossDeath", m_iNecroOrcs_Boss, m_Reference.GetCreatureByName(m_sOrcNecromantBoss));
		m_Reference.GetSectorByName("Sector_12").GetMainBuilding().RemoveCondition(1);
		m_Reference.EnableGroup("EnemyBaseNecroAura", false, true);
		return true;
	}

	// Undead waves related events
	bool OnDestroyedUndeadTower(Building& in _Building)
	{
		// Explosion FX
		m_Reference.CastSpell("EXP2_Tower_Explosion_C110_01a_320", m_Reference.GetHostFaction(), _Building);
		// Keeping tack of global quest int
		m_iUndeadTowersDestroyed++;
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_507_Q0_iUndeadTowersDestroyed", m_iUndeadTowersDestroyed);
		// Removing mountaint pass godstone hint
		if(m_Reference.FindEntityName(_Building) == "UndeadTower_06")
		{
			m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_507, "UndeadTower_06_Hint", false);
		}
		// Configuring undead waves according to num of towers still standing
		switch(m_iUndeadTowersDestroyed)
		{
			case 1: // 5 towers still standing
				m_iWavesToSummon = 2;
				break;
			case 2: // 4 towers still standing
				m_iWavesToSummon = 3;
				break;
			case 3: // 3 towers still standing
				m_sCurrentSummonsType = "Medium";
				break;
			case 4: // 2 towers still standing
				m_iWavesToSummon = 2;
				m_sCurrentSummonsType = "Hard";
				break;
			case 5: // 1 towers still standing
				m_iWavesToSummon = 1;
				m_sCurrentSummonsType = "Final";
		}
		print("Current waves configuration: "+m_sCurrentSummonsType+", "+m_iWavesToSummon);
		// Handling destroyed tower
		string _DestroyedTowerName = m_Reference.FindEntityName(_Building);
		uint _udivide = _DestroyedTowerName.findFirst("_", 0);
		uint _DestroyedTowerNum = parseInt(_DestroyedTowerName.substr(_udivide+2, -1));
		print("Destroyed tower number: "+ _DestroyedTowerNum);
		m_Reference.EnableGroup("NecroFireCircleFX_0"+_DestroyedTowerNum, false, true);
		// Unblocking a sector if destroyed tower used to occupy one
		switch(_DestroyedTowerNum)
		{
			case 1: 
				m_Reference.GetSectorByName("Sector_6").SetBlocked(false);
				break;
			case 2: 
				m_Reference.GetSectorByName("Sector_5").SetBlocked(false);
				break;
			case 3: 
				m_Reference.GetSectorByName("Sector_4").SetBlocked(false);
				break;
			case 4: 
				m_Reference.GetSectorByName("Sector_7").SetBlocked(false);
		}
		// Update active summon spots dictionary
		m_UndeadTower_SummonSpot.delete(_DestroyedTowerName);
		array<string> _arrkeys = m_UndeadTower_SummonSpot.getKeys();
		for (uint i = 0; i < _arrkeys.length(); ++i)
		{
			string _SummoningSpot;
			m_UndeadTower_SummonSpot.get(_arrkeys[i], _SummoningSpot);
			print("Active summoning spots: "+_SummoningSpot);
		}
		// Handling quest flow when all towers are destroyed
		if (m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_507_Q0_iUndeadTowersDestroyed") == m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_507_Q0_iUndeadTowersToDestroy"))
		{
			JourneyExplorationShoutout(_Building, "Journey_507_SO_FogVanishedHint");
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_507, "NecroFogHint", Completed);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_507, "DestroyUndeadTowers", Completed);
			// disabling necrofog and its effects
			m_Reference.EnableGroup("507_Grp_NecroFog", false, true);
			m_Reference.UnregisterCreatureEvent(EnteredArea, TOnCreatureEvent( @this.OnTriggerEnter_NecroFogDebuff ));
			m_Reference.UnregisterCreatureEvent(EnteredArea, TOnCreatureEvent( @this.OnTriggerEnter_NecroFogBuff ));
			m_Reference.UnregisterCreatureEvent(LeftArea, TOnCreatureEvent( @this.OnTriggerLeave_NecroFog ));
			// allowing falcons to attack the enemy base
			m_Reference.SetAIFlag(m_iIronFalcons, CanAttack, true);
			return true;
		}
		return false;
	}

	bool SummonUndeadWaves_Timer()
	{
		// Undead should be summoned only if there are necromantic towers still standing
		if(m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_507_Q0_iUndeadTowersDestroyed") != m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_507_Q0_iUndeadTowersToDestroy"))
		{
			array<string> _arrkeysTowerSpot = m_UndeadTower_SummonSpot.getKeys();
			array<string> _arrSummonsSpots;
			array<string> _arrSummonsTypes;
			for (uint i = 0; i < _arrkeysTowerSpot.length(); ++i)
			{
				string _SummoningSpot;
				m_UndeadTower_SummonSpot.get(_arrkeysTowerSpot[i], _SummoningSpot);
				_arrSummonsSpots.insertLast(_SummoningSpot);
			}
			uint _Spots = _arrSummonsSpots.length();
			print("Number of active summoning spots: "+_Spots);
			m_SummonsTypes.get(m_sCurrentSummonsType, _arrSummonsTypes);
			for (uint i = 0; i < m_iWavesToSummon; ++i)
			{
				uint _uRandomSummonIndex = m_Reference.GetRandom().GetInteger( 0, _arrSummonsTypes.length());
				uint _uRandomSpotIndex = m_Reference.GetRandom().GetInteger( 0, _arrSummonsSpots.length());
				print("This wave will be summoned: "+_arrSummonsTypes[_uRandomSummonIndex] + " at this spot: "+_arrSummonsSpots[_uRandomSpotIndex]);
				m_Reference.CastSpell("Journey_507_UndeadSummoning", m_iUndeadSummons, m_Reference.GetLogicObjectByName(_arrSummonsSpots[_uRandomSpotIndex]));
				m_Reference.CastSpell(_arrSummonsTypes[_uRandomSummonIndex], m_iUndeadSummons, m_Reference.GetLogicObjectByName(_arrSummonsSpots[_uRandomSpotIndex]));
				// removing a used spot so waves will spawn at different towers
				_arrSummonsSpots.removeAt(_uRandomSpotIndex);
			}
			m_Reference.SetTimerMS( TOnTimerEvent( @this.UndeadAttack_Timer ), 100 );
			// resetting waves timer
			m_Reference.SetTimer( TOnTimerEvent( @this.SummonUndeadWaves_Timer), m_iWavesFrequency );
		}
		return true;
	}
	bool UndeadAttack_Timer()
	{
		// Summon undead attack falcon's base
		CreatureGroup _Grp_UndeadSummons = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iUndeadSummons));
		_Grp_UndeadSummons.AttackPosition(m_Reference.GetSectorByName("Sector_0").GetMainBuilding(), false, false);
		return true;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- A R T I C Y  F U N C T I O N S -------------------------------------------------------------------------------- 

	void StartRTS()
	{
		ActivateReinforcements();
		m_Reference.ActivateAI(m_iIronFalcons);
		// summoning first undead wave
		m_Reference.SetTimer( TOnTimerEvent( @this.SummonUndeadWaves_Timer), 10 );

		InitialSectorsDistribution(m_PlayersInititalSectors);

		// unblocking exits from the fortress
		m_Reference.BlockNavMesh("NorthernExit_Blocker", false);
		m_Reference.BlockNavMesh("SouthernExit_Blocker", false);

		// handling quest flow
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_507, "DestroyEnemyBase", true);
	}

	void CameraOnNecroFog()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("CameraOnNecroFog_Spot"));
		}
		
		JourneyRevealArea("NecroFog_Area", 10);
	}
	void CameraOnUndeadTower()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("UndeadSummoningSpot_02"));
		}
		
		JourneyRevealArea("UndeadSummonArea_02", 10);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_507, "DestroyUndeadTowers", true);
	}
	void CameraOnMountainPathGodstone()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("MountainPathGodstone_Spot"));
		}
		m_Reference.GetBuildingByName("Entity_Godstone_MountainPath").SetFaction(m_Reference.GetHostFaction());
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_507, "UndeadTower_06_Hint", true);
	}

	void ActivateReinforcements()
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_507, "ReinforcementsTimer", true);
		m_Reference.CreateCountdownTimer(0, m_iTimeToNextReinforcement, TOnTimerEvent(@this.SpawnReinforcements_LoopedTimer), m_Reference.GetHostFaction() , "Journey_507_TimeToNextReinforcement");
		SpawnReinforcements();
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("IronFalconsReinforcements_Spot"));
		}
	}

	void PlayerSkippedMapIntro()
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_507, "DestroyUndeadTowers", true);
		m_Reference.GetBuildingByName("Entity_Godstone_MountainPath").SetFaction(m_Reference.GetHostFaction());
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_507, "UndeadTower_06_Hint", true);
		StartRTS();
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- C U S T O M F U N C T I O N S ---------------------------------------------------------------------------------

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
			m_Reference.CastSpell("Journey_507_ReinforcementsSpawn", _arrJoinedPlayers[0], m_Reference.GetLogicObjectByName("IronFalconsReinforcements_Spot"));
		}
		else if (_arrJoinedPlayers.length() == 2)
		{
			m_Reference.CastSpell("Journey_507_ReinforcementsSpawn_Shortened", _arrJoinedPlayers[0], m_Reference.GetLogicObjectByName("IronFalconsReinforcements_Spot"));
			m_Reference.CastSpell("Journey_507_ReinforcementsSpawn_Shortened", _arrJoinedPlayers[1], m_Reference.GetLogicObjectByName("IronFalconsReinforcements_Spot"));
		}
		else if (_arrJoinedPlayers.length() == 0)
		{
			m_Reference.CastSpell("Journey_507_ReinforcementsSpawn", m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName("IronFalconsReinforcements_Spot"));
		}
	}

	bool SpawnReinforcements_LoopedTimer()
	{
		if(m_Reference.GetBuildingByName("IronFalconsBarracks").Exists() && m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_507, "DestroyEnemyBase") != Completed)
		{
			SpawnReinforcements();
			m_Reference.CreateCountdownTimer(0, m_iTimeToNextReinforcement, TOnTimerEvent(@this.SpawnReinforcements_LoopedTimer), m_Reference.GetHostFaction() , "Journey_507_TimeToNextReinforcement");
		}
		return true;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- D E B U G ----------------------------------------------------------------------------------------------------
	void testTransform()
	{
		m_Reference.GetCreatureByName(m_sOrcNecromantBoss).ForceCast(m_Reference, "Journey_507_BossDemon_TransformBase", m_Reference.GetCreatureByName(m_sOrcNecromantBoss), false);
		print("testTransform");
	}
	void testSummon()
	{
		array<string> _arrkeysTowerSpot = m_UndeadTower_SummonSpot.getKeys();
		array<string> _arrSummonsSpots;
		array<string> _arrSummonsTypes;
		for (uint i = 0; i < _arrkeysTowerSpot.length(); ++i)
		{
			string _SummoningSpot;
			m_UndeadTower_SummonSpot.get(_arrkeysTowerSpot[i], _SummoningSpot);
			_arrSummonsSpots.insertLast(_SummoningSpot);
		}
		uint _Spots = _arrSummonsSpots.length();
		print("Number of active summoning spots: "+_Spots);
		m_SummonsTypes.get(m_sCurrentSummonsType, _arrSummonsTypes);
		for (uint i = 0; i < m_iWavesToSummon; ++i)
		{
			uint _uRandomSummonIndex = m_Reference.GetRandom().GetInteger( 0, _arrSummonsTypes.length());
			uint _uRandomSpotIndex = m_Reference.GetRandom().GetInteger( 0, _arrSummonsSpots.length());
			print("This wave will be summoned: "+_arrSummonsTypes[_uRandomSummonIndex] + " at this spot: "+_arrSummonsSpots[_uRandomSpotIndex]);
			m_Reference.CastSpell("Journey_507_UndeadSummoning", m_iUndeadSummons, m_Reference.GetLogicObjectByName(_arrSummonsSpots[_uRandomSpotIndex]));
			m_Reference.CastSpell(_arrSummonsTypes[_uRandomSummonIndex], m_iUndeadSummons, m_Reference.GetLogicObjectByName(_arrSummonsSpots[_uRandomSpotIndex]));
			// removing a used spot so waves will spawn at different towers
			_arrSummonsSpots.removeAt(_uRandomSpotIndex);
		}
	}
	void test(uint _num)
	{
		m_Reference.CastSpell("Journey_507_UndeadSummoning", m_iUndeadSummons, m_Reference.GetLogicObjectByName("UndeadSummoningSpot_0"+_num));
		m_Reference.CastSpell("Journey_507_OrcTest", m_iUndeadSummons, m_Reference.GetLogicObjectByName("UndeadSummoningSpot_0"+_num));
	}
	void killUndead()
	{
		CreatureGroup _Grp_UndeadSummons = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iUndeadSummons));
		_Grp_UndeadSummons.Die(false);
	}
	void testingSetup()
	{
		m_Reference.GetSectorByName("Sector_0").GetMainBuilding().SetIndestructible(true);
		m_Reference.GetSectorByName("Sector_1").GetMainBuilding().SetIndestructible(true);
	}
	void testBoss()
	{
		m_Reference.GetCreatureByName(m_sOrcNecromantBoss).PlayAnimation(m_Reference, CastShortSelf, -1, 3000, false, false, Entity ( ), false, false, false);
		m_Reference.GetSectorByName("Sector_12").GetMainBuilding().ApplyCondition(1, -1, kMaxFactions, 100);
		m_Reference.EnableGroup("EnemyBaseNecroAura", true, true);
	}
	void testSpell()
	{
		m_Reference.CastSpell("Journey_507_OrcNecromantBossDeath", m_iNecroOrcs_Boss, m_Reference.GetCreatureByName(m_sOrcNecromantBoss));
	}
}
