// includes:
#include "../../basicScripts/Journey_LevelBase.as"
#include "../../basicScripts/Journey_WindwallFoothills_Balancing.as"

// ------------------------------------------------------------------------------------------------------------------------------------
class Level: Journey_LevelBase
{
	// count this version-number up. This is for later version tracking, when the QA plays the map.
	string m_Version_Level = "QA hasn't played the map yet";     

	// --------------------------------------------------------------------------------------------------------------------------------
	// --- G E N E R A L  V A R I A B L E S -------------------------------------------------------------------------------------------
	
	Journey_WindwallFoothills_BalancingData m_SummonsBalancing;

	// --- Factions -----------------------------------------------------------------------------------------------------------
	uint8 m_i0_PlayerFaction = 					0;
	uint8 m_i1_PlayerFaction = 					1;
	uint8 m_i2_PlayerFaction = 					2;
	uint8 m_iAlliedAI_Faction = 		    	3;
	uint8 m_iDarkElves = 				    	4;
	uint8 m_iSettlers = 				    	5;
	uint8 m_iDarkElves_AttackWaves = 			6;
    uint8 m_iAlliedAI_Reinforcements_Faction =  7;
	uint8 m_iDarkElvenAttack_01_Faction =   	8;
	uint8 m_iDarkElvenAttack_02_Faction =   	9;
	uint8 m_iCreeps =   	                    10;
	uint8 m_iDefault_Faction = 		        	12;

	/*	--------------------------------------------------
	*	Two factions are used for allied AI so 'Reinforcement'
	*	one is always close to the carriage, while AI actually
	*	controls its troops between expansions
	*	--------------------------------------------------
	*/
	array<uint8> m_arrAlliedAI_Factions =
	{
		m_iAlliedAI_Faction,
		m_iAlliedAI_Reinforcements_Faction
	};

	dictionary m_PlayersInititalSectors =
	{
		{"Sector_10", m_i0_PlayerFaction},
		{"Sector_11", m_i1_PlayerFaction},
		{"Sector_0", m_i2_PlayerFaction}
	};

	array<string> SectorsForSettlers_ToConquer = 
	{
		"Sector_09",
		"Sector_03",
		"Sector_04",
		"Sector_02",
		"Sector_01",
		"Sector_05",
		"Sector_07",
		"Sector_08",
		"Sector_12"
	};

	// quest spawns
	array<string> DarkElvenSpawns = 
	{
		"DarkElvenPatrol_02_Spawn",
		"DarkElvenPatrol_03_Spawn",
		"DarkElvenPatrol_04_Spawn",
		"DarkElvenPatrol_05_Spawn",
		"DarkElvenPatrol_06_Spawn",
		"DarkElvenPatrol_07_Spawn",
		"DarkElvenPatrol_08_Spawn",
		"DarkElvenPatrol_09_Spawn",
		"DarkElvenPatrol_10_Spawn",
		"DarkElvenPatrol_11_Spawn",
		"DarkElvenPatrol_12_Spawn",
		"DarkElvenPatrol_14_Spawn",
		"DarkElvenPatrol_15_Spawn",
		"DarkElvenPatrol_16_Spawn",
		"DarkElvenPatrol_17_Spawn",
		"DarkElvenPatrol_18_Spawn",
		"DarkElvenPatrol_19_Spawn",
		"DarkElvenPatrol_20_Spawn",
		"DarkElvenPatrol_21_Spawn",
		"DarkElvenPatrol_22_Spawn",
		"DarkElvenPatrol_23_Spawn",
		"DarkElvenPatrol_24_Spawn",
		"DarkElvenPatrol_25_Spawn",
		"DarkElvenPatrol_26_Spawn",
		"DarkElves_DefCapital",
		"DarkElves_HeroSpawn"
	};

	/*	--------------------------------------------------
	*	Not used at all now. Maybe activating random "free roam" 
	*	spawns on map launch will be a good idea
	*	--------------------------------------------------
	*/
	array<string> FreeRoamSpawns = 
	{
		"WildLife_Spawn_01",
		"WildLife_Spawn_02",
		"WildLife_Spawn_03",
		"WildLife_Spawn_04",
		"WildLife_Spawn_05",
		"WildLife_Spawn_06",
		"WildLife_Spawn_07",
		"WildLife_Spawn_08",
		"WildLife_Spawn_09",
		"WildLife_Spawn_10",
		"WildLife_Spawn_11",
		"WildLife_Spawn_12",
		"WildLife_Spawn_13",
		"WildLife_Spawn_14",
		"WildLife_Spawn_15",
		"WildLife_Spawn_16",
		"WildLife_Spawn_17",
		"WildLife_Spawn_18"
	};

	// Spellnames
	string m_sSummon_Spectre = 					"Journey_502_SummonSpectre";
	string m_sSummon_Spider = 				    "Journey_502_SummonSpider";
	string m_sSummon_Sleeper = 				    "Journey_502_SummonSleeper";
	string m_sSummon_Infiltrator =				"Journey_502_SummonInfiltrator";
	string m_sSummon_Scion = 					"Journey_502_SummonScion";
	string m_sSummon_TwistedOne = 				"Journey_502_SummonTwistedOne";
	string m_sSummon_LizardRider = 				"Journey_502_SummonLizardRider";
	string m_sSummon_PlagueBeetle = 			"Journey_502_SummonPlagueBeetle";
	string m_sSummon_NorsEmissary = 			"Journey_502_SummonNorsEmissary";
	string m_sSummon_FleshThrower = 			"Journey_502_SummonFleshThrower";

	// Quest timers 

	array<uint> m_uInitialExpansionTimer = {
										330,  	// Easy
										270,  	// Normal
										150,  	// Hard
										150	  	// Circle-Mage
									};

	array<uint> m_uSubsequentExpansionTimer = {
										330,  	// Easy
										270,  	// Normal
										150,  	// Hard
										150	  	// Circle-Mage
									};

	// Debug timers

	// array<uint> m_uInitialExpansionTimer = {
	// 									10,  	// Easy
	// 									10,  	// Normal
	// 									10,  	// Hard
	// 									10	  	// Circle-Mage
	// 								};

	// array<uint> m_uSubsequentExpansionTimer = {
	// 									10,  	// Easy
	// 									10,  	// Normal
	// 									10,  	// Hard
	// 									10	  	// Circle-Mage
	// 								};

	// Temporary invulnerability will be applied to newly built settlers' homes, so they won't be destroyed just on construction start
	uint m_iInvulnerabilityDuration = 2;

	uint m_iRemainingEnemiesKilled = 0;

	string Carriage_01 = "Journey_SettlersCarriage_01_502";
	string Carriage_02 = "Journey_SettlersCarriage_02_502";

	// Used in map intros/outros
	string m_sChiefSettler = "Journey_ChiefSettler_502";
	string m_sMapIntroTopic = "Journey_502_ChiefSettler_MapIntro";
	string m_sMapOutroTopic = "Journey_502_ChiefSettler_MapOutro";

	// Carriages' waiting spots dictionary
	dictionary m_CarriagesWaitingSpots =
	{
		{"Expansion_01", array<string> = {"Carriage_01_WaitingSpot_01", "Carriage_02_WaitingSpot_01"}},
		{"Expansion_02", array<string> = {"Carriage_01_WaitingSpot_02", "Carriage_02_WaitingSpot_02"}},
		{"Expansion_03", array<string> = {"Carriage_01_WaitingSpot_03", "Carriage_02_WaitingSpot_03"}},
		{"Expansion_04", array<string> = {"Carriage_01_WaitingSpot_04", "Carriage_02_WaitingSpot_04"}},
		{"Expansion_05", array<string> = {"Carriage_01_WaitingSpot_05", "Carriage_02_WaitingSpot_05"}}
	};
	// At what spots attack waves are summoned at which expansion
	dictionary m_SummonSpots =
	{
		{"Expansion_01", array<string> = {"Spot_DarkElvenAttack_01_01", "Spot_DarkElvenAttack_02_01"}},
		{"Expansion_02", array<string> = {"Spot_DarkElvenAttack_01_02", "Spot_DarkElvenAttack_02_02"}},
		{"Expansion_03", array<string> = {"Spot_DarkElvenAttack_01_03", "Spot_DarkElvenAttack_02_03"}},
		{"Expansion_04", array<string> = {"Spot_DarkElvenAttack_01_04", "Spot_DarkElvenAttack_02_04"}},
		{"Expansion_05", array<string> = {"Spot_DarkElvenAttack_01_05", "Spot_DarkElvenAttack_02_05"}}
	};
	string m_sCurrentExpansion;
	uint m_iCurrentExpansion = 0;

	dictionary m_Race_Expansion =
	{
		{"Human", "Exp1_H_Expansion_0"},
		{"Elf", "Exp1_E_Expansion_0"},
		{"Dwarf", "Exp1_D_Expansion_0"},
		{"Orc", "Exp1_O_Expansion_0"},
		{"DarkElf", "Exp1_DE_Expansion_0"},
		{"Troll", "EXP2_T_Expansion_0"}
	};
	array<string> m_arrExpansionByPlayerFaction(3);

	array<string> m_arrSettlersHomes =
	{
		"SettlersHome_01_Carriage_01",
		"SettlersHome_02_Carriage_01",
		"SettlersHome_03_Carriage_01",
		"SettlersHome_04_Carriage_01",
		"SettlersHome_05_Carriage_01",
		"SettlersHome_01_Carriage_02",
		"SettlersHome_02_Carriage_02",
		"SettlersHome_03_Carriage_02",
		"SettlersHome_04_Carriage_02"
	};

	// Order is important because it is used to determine what reinforcements to summon based on current difficulty
	array<string> m_arrAlliedAIReinforcementsSpells =
	{
		"Journey_502_AlliedAIReinforcements_Easy",
		"Journey_502_AlliedAIReinforcements_Normal",
		"Journey_502_AlliedAIReinforcements_Hard",
		"Journey_502_AlliedAIReinforcements_Insane"
	};

	string m_sMainQuest_502 = "Journey_502_Q0_HelpSettlersSurvive";
	string m_sSideQuest_502 = "Journey_502_SQ0_Brigands";

	// Multiplayer path scenarios
	bool m_bMP1_PathScenario = false;
	bool m_bMP2_PathScenario = false;
	bool m_bMP3_PathScenario = false;
	bool m_bMP4_PathScenario = false;

	// Singleplayer path scenarios
	bool m_bSP1_PathScenario = false;
	bool m_bSP2_PathScenario = false;
	bool m_bSP3_PathScenario = false;

	// Which sectors should be owned by which faction when a carriage conquers it
	dictionary m_SectorsToConquerByFaction = {};

	array<string> m_arrSectorsToConquer_Carriage01 =
	{
		"Sector_03",
		"Sector_01",
		"Sector_02",
		"Sector_04",
		"Sector_05"
	};

	array<string> m_arrSectorsToConquer_Carriage02 =
	{
		"Sector_09",
		"Sector_08",
		"Sector_12",
		"Sector_07"
	};

	// What carriage should Allied AI follow
	bool m_bAlliedAI_FollowCarriage01 = false;
	bool m_bAlliedAI_FollowCarriage02 = false;

	// On damaged carriage cooldown
	bool m_bOnDamaged_Carriage_01_Cooldown = false;
	bool m_bOnDamaged_Carriage_02_Cooldown = false;

	// Cooldown for showing outposts with low hp
	bool m_bCameraOnLowHPOutpostCooldown = false;

	// ---------------------------------------------------------------------------------------------------------------------------------
	// --- constructor --- dont make any changes here
	Level (LevelReference@ _Reference)
	{
		super(_Reference);
	}

	void OnCreated () override
	{
		Journey_LevelBase::OnCreated();
		print("--- M A P : Level Script: '"+m_Version_Level+"', Map: '"+ m_Reference.GetMapId() +"', Setting: '"+ m_Reference.GetWorld().GetCurrentMapSetting( m_Reference.GetMapId() )+"'");

		// global map calls
		InitEvents(); // register all neutral events
		InitCommon(); // script and set everything up for starting the level
	}

	void OnLoaded (const uint _uVersion) override
	{
		Journey_LevelBase::OnLoaded(_uVersion);
		print("--- M A P : Level Script: '"+m_Version_Level+"', Map: '"+ m_Reference.GetMapId() +"', Setting: '"+ m_Reference.GetWorld().GetCurrentMapSetting( m_Reference.GetMapId() )+"'");
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---  A L L  B A S I C S  E V E N T S  -----------------------------------------------------------------------------

	void InitEvents ()
	{
		// setting LoseGame() event if any carriage is killed
		m_Reference.RegisterCreatureEventBySpawn(Killed, TOnCreatureEvent(@this.OnAnyCarriageKilled), "Carriage_01_Spawn", true, "");
		m_Reference.RegisterCreatureEventBySpawn(Killed, TOnCreatureEvent(@this.OnAnyCarriageKilled), "Carriage_02_Spawn", true, "");

		// setting LoseGame() events on Outpost destruction for all players
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.RegisterBuildingEventByDescription(Destroyed, TOnBuildingEvent(@this.OnDestroyed_SettlersHome), "Journey_SettlersHome_502", m_Reference.GetPlayerFactions(true)[i]);
			m_Reference.RegisterBuildingEventByDescription(Damaged, TOnBuildingEvent(@this.OnDamaged_SettlersHome), "Journey_SettlersHome_502", m_Reference.GetPlayerFactions(true)[i]);
			// Event for finding missing son's dog tags from Journey_Everlight_Flavor_GrievingMother_HUB dialogue
			m_Reference.RegisterInventoryEvent(Added, TOnInventoryEvent(@this.OnAdded_MissingSonsDogTags), "Journey_MissingSonsDogTag_502", m_Reference.GetPlayerFactions(true)[i]);
		}

		// registering lose condition in case one of the settlers' homes is destroyed
		m_Reference.RegisterBuildingEventByDescription(Destroyed, TOnBuildingEvent(@this.OnDestroyed_SettlersHome), "Journey_SettlersHome_502", m_iAlliedAI_Faction);
		m_Reference.RegisterBuildingEventByDescription(Damaged, TOnBuildingEvent(@this.OnDamaged_SettlersHome), "Journey_SettlersHome_502", m_iAlliedAI_Faction);

		// registering on enemy base destroyed events
		m_Reference.RegisterBuildingEventByIndividual(Destroyed, TOnBuildingEvent( @this.OnDestroyed_DarkElvenBase ), m_Reference.GetSectorByName("Sector_06").GetMainBuilding());

		// registering events for carriages when they are under attack
		m_Reference.RegisterCreatureEventByIndividual(Damaged, TOnCreatureEvent(@this.OnDamaged_Carriage_01), "Journey_SettlersCarriage_01_502", "");
		m_Reference.RegisterCreatureEventByIndividual(Damaged, TOnCreatureEvent(@this.OnDamaged_Carriage_02), "Journey_SettlersCarriage_02_502", "");

		// registering dark elven attacks to be triggered when a carriage on its way to the next sector
		for (uint i = 0; i < 5; ++i)
		{
			m_Reference.RegisterHeroPartyEvent(AnyInside, TOnHeroPartyEvent(@this.OnAnyInside_SummonAttackOnCarriage), "Trigger_DarkElvenAttack_01_0"+(i+1), m_iSettlers);
		}
		for (uint i = 0; i < 5; ++i)
		{
			m_Reference.RegisterHeroPartyEvent(AnyInside, TOnHeroPartyEvent(@this.OnAnyInside_SummonAttackOnCarriage), "Trigger_DarkElvenAttack_02_0"+(i+1), m_iSettlers);
		}
	}
	
	void InitCommon ()
	{
		ActivateRandomLoot(100);
		
		// block Mine entrances 
		m_Reference.BlockNavMesh("MineGate_01", true);
		m_Reference.BlockNavMesh("MineGate_02", true);
		m_Reference.BlockNavMesh("MineGate_03", true);
		m_Reference.BlockNavMesh("MineGate_04", true);

		// Init balancing data
		m_SummonsBalancing = Journey_WindwallFoothills_BalancingData();

		// Reset of quest relevant global vairable
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iReclaimedSettlersLand", 0);

		// Activatin dark elven spawns
		for (uint i = 0; i < DarkElvenSpawns.length(); ++i)
		{
			m_Reference.ActivateSpawn( DarkElvenSpawns[i], true );
		}

		// Sets increased baseline unit supply for players + handling missing son's dog tags
		uint _uPlayersFoundDogTags = 0;
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.SetBaseSupply(_uFaction, uint(40));

			Variables@ _FactionGlobalVariables = m_Reference.GetVariables(_uFaction);
			if(_FactionGlobalVariables.GetGlobalBool("Journey_CampaignVariables.bFoundMissingSonsDogTags") == true)
			{
				_uPlayersFoundDogTags++;
			}
		}
		if(_uPlayersFoundDogTags == m_Reference.GetPlayerFactions(true).length())
		{
			m_Reference.GetLogicObjectByName("FlavourMissingSonCorpse_Loot").Enable(false);
		}

		// blocking the sectors so only carriages will be able to conquer them, as quest requires
		for (uint i = 0; i < SectorsForSettlers_ToConquer.length(); ++i)
		{
			m_Reference.GetSectorByName(SectorsForSettlers_ToConquer[i]).SetBlocked(true);
		}

		// setting carriages' behavior
		m_Reference.GetCreatureByName("Journey_SettlersCarriage_01_502").AllowAttacks(false);
		m_Reference.GetCreatureByName("Journey_SettlersCarriage_02_502").AllowAttacks(false);

		// Preventing players dragging chief settler into battle
		m_Reference.GetCreatureByName(m_sChiefSettler).SetImmovable(true);

		// Handling settlers' homes
		for (uint i = 0; i < m_arrSettlersHomes.length(); ++i)
		{
			m_Reference.GetBuildingByName(m_arrSettlersHomes[i]).Enable(false);
		}

		SetupIntroCreatures(m_sChiefSettler, m_sMapIntroTopic);
	}

	// Handling Allied AI placement in case host is playing solo
	void AlliedAI_Placement()
	{
		if (m_Reference.GetPlayerFactions(true).length() == 1)
		{
			if (m_Reference.GetSectorByName( "Sector_11" ).GetOwner() == 1 || m_Reference.GetSectorByName( "Sector_0" ).GetOwner() == 2)
			{
				m_Reference.GetSectorByName( "Sector_10" ).SetOwner(m_iAlliedAI_Faction);
				m_Reference.GetSectorByName( "Sector_10" ).CreateCapital(m_iAlliedAI_Faction, true, false);
				m_Reference.ActivateSpawn("AlliedAI_Sector_10_Spawn", true );
			}
			else
			{
				m_Reference.GetSectorByName( "Sector_11" ).SetOwner(m_iAlliedAI_Faction);
				m_Reference.GetSectorByName( "Sector_11" ).CreateCapital(m_iAlliedAI_Faction, true, false);
				m_Reference.ActivateSpawn("AlliedAI_Sector_11_Spawn", true );
			}
		}
	}

	// Handling allocation of sectors on carriages following their expansion paths
	void Enable_PathScenario()
	{
		if (m_Reference.GetPlayerFactions(true).length() == 1)
		{
			if (m_Reference.GetSectorByName( "Sector_10" ).GetOwner() == 0)
			{
				m_bAlliedAI_FollowCarriage02 = true;
				AssignSectorsToFaction(Carriage_01, 0);
				AssignSectorsToFaction(Carriage_02, m_iAlliedAI_Faction);
			}
			else if (m_Reference.GetSectorByName( "Sector_11" ).GetOwner() == 1)
			{
				m_bAlliedAI_FollowCarriage01 = true;
				AssignSectorsToFaction(Carriage_01, m_iAlliedAI_Faction);
				AssignSectorsToFaction(Carriage_02, 1);
			}
			else if (m_Reference.GetSectorByName( "Sector_0" ).GetOwner() == 2)
			{
				m_bAlliedAI_FollowCarriage01 = true;
				AssignSectorsToFaction(Carriage_01, m_iAlliedAI_Faction);
				AssignSectorsToFaction(Carriage_02, 2);
			}
		}
		else if (m_Reference.GetPlayerFactions(true).length() >= 1)
		{
			if (m_Reference.GetSectorByName( "Sector_0" ).GetOwner() == m_iDefault_Faction)
			{
				AssignSectorsToFaction(Carriage_01, 0);
				AssignSectorsToFaction(Carriage_02, 1);
			}
			else if (m_Reference.GetSectorByName( "Sector_11" ).GetOwner() == m_iDefault_Faction)
			{
				AssignSectorsToFaction(Carriage_01, 0);
				AssignSectorsToFaction(Carriage_02, 2);
			}
			else if (m_Reference.GetSectorByName( "Sector_10" ).GetOwner() == m_iDefault_Faction)
			{
				AssignSectorsToFaction(Carriage_01, 1);
				AssignSectorsToFaction(Carriage_02, 2);
			}
			else
			{
				AssignSectorsToFaction(Carriage_01, 0);
				AssignSectorsToFaction(Carriage_02, 1);
				m_SectorsToConquerByFaction.set("Sector_02", 1);
				m_SectorsToConquerByFaction.set("Sector_08", 2);
				m_SectorsToConquerByFaction.set("Sector_12", 2);
			}
		}
	}

	// Checking what race players play so carriages will build correct outposts
	void PlayedRaceCheck()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			string _sPlayedRace = TranslateRaceEnum(m_Reference.GetFactionRace(m_Reference.GetPlayerFactions(true)[i]));
			string _sCorrectExpansion;
			uint _iFactionIndex = m_Reference.GetPlayerFactions(true)[i];
			m_Race_Expansion.get(_sPlayedRace, _sCorrectExpansion);
			switch(_iFactionIndex)
			{	
				case 0:
					m_arrExpansionByPlayerFaction[0] = _sCorrectExpansion; break;
				case 1:
					m_arrExpansionByPlayerFaction[1] = _sCorrectExpansion; break;
				case 2:
					m_arrExpansionByPlayerFaction[2] = _sCorrectExpansion; break;
			}
			print("Player with faction "+_iFactionIndex+" will get these expansions from carriages: "+_sCorrectExpansion);
		}
	}

	void SetInitialQuestTimer()
	{
		m_Reference.CreateCountdownTimer(0, m_uInitialExpansionTimer[uint(m_Reference.GetDifficulty())], TOnTimerEvent(@this.CarriagesStartNewExpansion), m_Reference.GetHostFaction() , "InitialExpansion_Timer");
		m_Reference.SetTimer(TOnTimerEvent(@this.OnTimer_CarriageMovingOutSoonNotification), m_uInitialExpansionTimer[uint(m_Reference.GetDifficulty())] - 30);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "InitialExpansionTimerHint", true);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "Invis_ExpansionQuestMarker_01", true);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T  F U N C T I O N S ----------------------------------------------------------------------------------

	/*	--------------------------------------------------
	*	Lose condtions
	*	--------------------------------------------------
	*/
	bool OnAnyCarriageKilled( Creature &in _Creature )
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.LoseGame(m_Reference.GetPlayerFactions(true)[i]);
		}
		
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_502, "CarriagesSurviveRequirement", Failed);
		return true;
	}

	bool OnDestroyed_SettlersHome(Building& in _Building)
	{	
		uint _iSectorIndex = _Building.GetSectorIndex();
		string _SectorName = m_Reference.GetSectorByIndex(_iSectorIndex).GetName();
		print("Settler's Outpost was destroyed in "+_SectorName);
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)	
			m_Reference.LoseGame(m_Reference.GetPlayerFactions(true)[i]);
		
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_502, "ProtectSettlersOutposts", Failed);
		return true;
	}

	/*	--------------------------------------------------
	*	Win conditions
	*	--------------------------------------------------
	*/
	bool OnDestroyed_DarkElvenBase( Building &in _Building )
	{
		m_Reference.LoseGame(m_iDarkElves);
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_502, "DestroyDarkelvenBase", Completed);
		if (m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_502, "ConquerSectors") == Completed)
		{
			WinConditionReached();
			return true;
		}

		return true;
	}

	// An event that is registered in case dark elven base is destroyed before settlers' finished expansions
	bool OnRemainingEnemyKilled_CheckQuest(Creature &in _Creature)
	{
		m_iRemainingEnemiesKilled =  m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iEnemiesKilled", 0)+ 1;
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iEnemiesKilled", m_iRemainingEnemiesKilled);
		if(m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iEnemiesKilled", 0) >= m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iEnemiesToKill", 0))
		{
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_502, "KillRemainingAttackers", Completed);
			WinConditionReached();
			return true;
		}
		return false;
	}

	void WinConditionReached()
	{
		m_Reference.LoseGame(m_iDarkElves);
		m_Reference.LoseGame(m_iDarkElves_AttackWaves);
		m_Reference.LoseGame(m_iDarkElvenAttack_01_Faction);
		m_Reference.LoseGame(m_iDarkElvenAttack_02_Faction);
		
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_502, "CarriagesHealHint", Completed);
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_502, "CarriagesSurviveRequirement", Completed);
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_502, "ProtectSettlersOutposts", Completed);

		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "ReportBackToChiefSettler", true);
		JourneyExplorationShoutout(GetRandomJourneyHero(), "Journey_502_SO_ReportToQuestGiver");

		// Changing Everlight weather
		SetEverlightWeather();
	}
	
	/*	--------------------------------------------------
	*	Settlers expanions events and timers
	*	--------------------------------------------------
	*/
	bool CarriagesStartNewExpansion()
	{
		if(m_iCurrentExpansion == 0)
		 {
		 	m_Reference.ActivateAI( m_iDarkElves );
		 }
		m_iCurrentExpansion++;
		m_sCurrentExpansion = "Expansion_0"+(m_iCurrentExpansion);
		print("Carriages start new expansion and current expansion value is: "+m_iCurrentExpansion);

		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "SubsequentExpansionTimerHint", false);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "EscortCarriages_Paths_0"+(m_iCurrentExpansion), true);

		m_Reference.GetCreaturesFromSpawn("Carriage_01_Spawn")[0].FollowPath(m_Reference, "Carriage_01_Path_0"+(m_iCurrentExpansion), true, false, true);
		m_Reference.GetCreaturesFromSpawn("Carriage_02_Spawn")[0].FollowPath(m_Reference, "Carriage_02_Path_0"+(m_iCurrentExpansion), true, false, true);
		m_Reference.RegisterCreatureEventByIndividual(FollowPathFinished, TOnCreatureEvent(@this.OnPathFinishedCarriage_01), Carriage_01, "Carriage_01_Path_0"+(m_iCurrentExpansion));
		m_Reference.RegisterCreatureEventByIndividual(FollowPathFinished, TOnCreatureEvent(@this.OnPathFinishedCarriage_02), Carriage_02, "Carriage_02_Path_0"+(m_iCurrentExpansion));
		SetCarriagesMovable();
		AlliedAI_FollowCarriage();
		JourneyExplorationShoutout(GetRandomJourneyHero(), "Journey_502_SO_CartsMoving");

		return true;
	}

	bool BuildSettlerHome(const string& in _sCarriage)
	{
		string _sCarriageNum = _sCarriage.substr(_sCarriage.findFirst("0", 0)+1, 1);
		ConquerSector(_sCarriage);
		SpawnAttackOnSettlerHome(_sCarriageNum);

		Building _SettlerHome = m_Reference.GetBuildingByName("SettlersHome_0"+m_iCurrentExpansion+"_Carriage_0"+_sCarriageNum);
		_SettlerHome.Enable(true);
		m_Reference.RegisterBuildingEventByIndividual(Completed, TOnBuildingEvent(@this.OnCompleted_SettlersHome), _SettlerHome);
		_SettlerHome.ApplyCondition(1, m_iInvulnerabilityDuration, kMaxFactions, 100); 

		if(m_iCurrentExpansion == 5)
		{
			SpawnAttackOnSettlerHome("2");
			if(m_bAlliedAI_FollowCarriage01 == true || m_bAlliedAI_FollowCarriage02 == true)
			{
				for(uint i = 0; i < m_arrAlliedAI_Factions.length(); ++i)
				{
					CreatureGroup AlliedAI_Troops = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_arrAlliedAI_Factions[i]));
					AlliedAI_Troops.AttackPosition(m_Reference.GetLogicObjectByName("Spot_EpicBattle"), false, false);
				}
			}
		}

		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_502, "EscortCarriages_Paths_0"+m_iCurrentExpansion, Completed);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "Invis_SettlersHomesQuestMarker_0"+m_iCurrentExpansion, true);

		return true;
	}

	bool OnCompleted_SettlersHome( Building& in _Building )
	{
		int _iNewSettlersHomesBuilt = m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iSettlersHomesBuilt");
		_iNewSettlersHomesBuilt++;
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iSettlersHomesBuilt", _iNewSettlersHomesBuilt);

		if(m_Reference.GetBuildingByName("SettlersHome_0"+(m_iCurrentExpansion)+"_Carriage_01").GetStage() == Completed && 
			m_Reference.GetBuildingByName("SettlersHome_0"+(m_iCurrentExpansion)+"_Carriage_02").GetStage() == Completed)
		{
			SettlersReclaimedLand();
			JourneyExplorationShoutout(_Building, "Journey_502_SO_NewOutpostCompleted");
			m_Reference.CreateCountdownTimer(0, m_uSubsequentExpansionTimer[uint(m_Reference.GetDifficulty())], TOnTimerEvent(@this.CarriagesStartNewExpansion), m_Reference.GetHostFaction(), "SubsequentExpansion_Timer");
			m_Reference.SetTimer(TOnTimerEvent(@this.OnTimer_CarriageMovingOutSoonNotification), m_uSubsequentExpansionTimer[uint(m_Reference.GetDifficulty())] - 30);
			m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "BuildSettlersHomes_NormalExpansion", false);
			m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "SubsequentExpansionTimerHint", true);
			m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "Invis_ExpansionQuestMarker_0"+(m_iCurrentExpansion+1), true);
		}
		else if(m_iCurrentExpansion == 5)
		{
			SettlersReclaimedLand();
			m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "BuildSettlersHomes_FinalExpansion", false);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_502, "ConquerSectors", Completed);
			if(m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_502, "DestroyDarkelvenBase") != Completed)
			{
				JourneyExplorationShoutout(_Building, "Journey_502_SO_DestroyEnemyBase");
			}
			return true;
		}

		return false;
	}

	/*	--------------------------------------------------
	*	When settler's home has low HP we focus players'
	*	camera on it, warning them about it
	*	--------------------------------------------------
	*/
	bool OnDamaged_SettlersHome(Building& in _Building)
	{
		uint _iOutpostOwner = _Building.GetFaction();
		if (_iOutpostOwner == m_iAlliedAI_Faction && _Building.GetCurrentHP() <= PercentOf( _Building.GetMaxHP(), 35) && m_bCameraOnLowHPOutpostCooldown != true
			&& _Building.GetStage() == Completed)
		{
			m_Reference.FocusCamera(m_Reference.GetHostFaction(), _Building);
			m_bCameraOnLowHPOutpostCooldown = true;
			m_Reference.SetTimer(TOnTimerEvent(@this.CameraOnLowHPOutpost_CooldownReset), 10);
		}
		else if (_Building.GetCurrentHP() <= PercentOf( _Building.GetMaxHP(), 35) && m_bCameraOnLowHPOutpostCooldown != true && _Building.GetStage() == Completed)
		{
			m_Reference.FocusCamera(_iOutpostOwner, _Building);
			m_bCameraOnLowHPOutpostCooldown = true;
			m_Reference.SetTimer(TOnTimerEvent(@this.CameraOnLowHPOutpost_CooldownReset), 10);
		}
		return false;
	}
	// Cooldown is used so the FocusCamera won't be triggered too often
	bool CameraOnLowHPOutpost_CooldownReset()
	{
		m_bCameraOnLowHPOutpostCooldown = false;
		return true;
	}

	/*	--------------------------------------------------
	*	Carriages events
	*	--------------------------------------------------
	*/
	bool OnPathFinishedCarriage_01( Creature& in _Creature )
	{
		m_Reference.SetTimer( TOnTimerEvent( @this.Carriage_01_ToWaitingSpot_Timer), 2 );
		m_Reference.SetTimer(TOnTimerUserDataEvent(@this.BuildSettlerHome), 2, m_Reference.FindEntityName(_Creature));

		return true;
	}

	bool OnPathFinishedCarriage_02( Creature& in _Creature )
	{
		m_Reference.SetTimer( TOnTimerEvent( @this.Carriage_02_ToWaitingSpot_Timer), 2 );
		if(m_iCurrentExpansion != 5)
		{
			m_Reference.SetTimer(TOnTimerUserDataEvent(@this.BuildSettlerHome), 2, m_Reference.FindEntityName(_Creature));
		}
		else if(m_bAlliedAI_FollowCarriage02)
		{
			SummonAlliedAIReinforcements(Carriage_02);
		}

		return true;
	}

	bool OnDamaged_Carriage_01(Creature &in _Creature)
	{
		if (m_bAlliedAI_FollowCarriage01 == true && m_bOnDamaged_Carriage_01_Cooldown == false)
		{
			AlliedAI_DefendCarriageOnTheGo(Carriage_01);
			m_bOnDamaged_Carriage_01_Cooldown = true;
			m_Reference.SetTimer( TOnTimerEvent( @this.OnDamaged_Carriage_01_CooldownReset ), 7 );
		}
		for (uint i = 0; i < GetLivingCreaturesByFaction(m_iDarkElvenAttack_01_Faction).length(); ++i)
		{
			Creature _SummonedAttacker = GetLivingCreaturesByFaction(m_iDarkElvenAttack_01_Faction)[i];
			if(!_SummonedAttacker.IsInCombat())
			{
				_SummonedAttacker.AttackPosition(m_Reference, m_Reference.GetCreatureByName(Carriage_01), false, false);
			}
		}
		//m_Reference.GetCreatureByName("Journey_SettlersCarriage_01_502").PlayAnimation(m_Reference, IdleAlerted, -1, uint(-1), false, false, Entity ( ), false, false);
		return false;
	}

	bool OnDamaged_Carriage_02(Creature &in _Creature)
	{
		if (m_bAlliedAI_FollowCarriage02 == true && m_bOnDamaged_Carriage_02_Cooldown == false)
		{
			AlliedAI_DefendCarriageOnTheGo(Carriage_02);
			m_bOnDamaged_Carriage_02_Cooldown = true;
			m_Reference.SetTimer( TOnTimerEvent( @this.OnDamaged_Carriage_02_CooldownReset ), 7 );
		}
		for (uint i = 0; i < GetLivingCreaturesByFaction(m_iDarkElvenAttack_02_Faction).length(); ++i)
		{
			Creature _SummonedAttacker = GetLivingCreaturesByFaction(m_iDarkElvenAttack_02_Faction)[i];
			if(!_SummonedAttacker.IsInCombat())
			{
				_SummonedAttacker.AttackPosition(m_Reference, m_Reference.GetCreatureByName(Carriage_02), false, false);
			}
		}
		//m_Reference.GetCreatureByName("Journey_SettlersCarriage_02_502").PlayAnimation(m_Reference, IdleAlerted, -1, uint(-1), false, false, Entity ( ), false, false);
		return false;
	}
	// We use cooldown timers for carriages' OnDamaged events so relevant allied AI commands won't be issued too often
	bool OnDamaged_Carriage_01_CooldownReset()
	{
		m_bOnDamaged_Carriage_01_Cooldown = false;
		return true;
	}

	bool OnDamaged_Carriage_02_CooldownReset()
	{
		m_bOnDamaged_Carriage_02_Cooldown = false;
		return true;
	}

	bool OnAnyInside_SummonAttackOnCarriage(Creature&in _Creature)
	{
		array <string> _SummonSpots;
		m_SummonSpots.get(m_sCurrentExpansion, _SummonSpots);
		if(_Creature.GetDescriptionName() == Carriage_01)
		{
			JourneyExplorationShoutout(_Creature, "Journey_502_SO_NewEnemyWaveSpawns");
			SummonAttack(m_iDarkElvenAttack_01_Faction, _SummonSpots[0]);
			m_Reference.SetTimerMS( TOnTimerEvent( @this.DarkElvenAttack_01 ), 100 );
		}
		else if(_Creature.GetDescriptionName() == Carriage_02)
		{
			JourneyExplorationShoutout(_Creature, "Journey_502_SO_NewEnemyWaveSpawns");
			SummonAttack(m_iDarkElvenAttack_02_Faction, _SummonSpots[1]);
			m_Reference.SetTimerMS( TOnTimerEvent( @this.DarkElvenAttack_02 ), 100 );
		}
		return false;
	}

	bool DarkElvenAttack_01()
	{
		CreatureGroup DarkElvenAttack_01 = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iDarkElvenAttack_01_Faction));
		DarkElvenAttack_01.AttackPosition(m_Reference.GetCreatureByName(Carriage_01), false);
		return true;
	}

	bool DarkElvenAttack_02()
	{
		CreatureGroup DarkElvenAttack_02 = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iDarkElvenAttack_02_Faction));
		DarkElvenAttack_02.AttackPosition(m_Reference.GetCreatureByName(Carriage_02), false);
		return true;
	}

	/*	--------------------------------------------------
	*	Timer to trigger notifications when carriages 
	*	are about to move out
	*	--------------------------------------------------
	*/

	bool OnTimer_CarriageMovingOutSoonNotification()
	{
		array<uint8> _arrPlayerFactions = m_Reference.GetPlayerFactions(true);
		for(uint i = 0; i < _arrPlayerFactions.length(); ++i)
		{
			m_Reference.BeginNotification(_arrPlayerFactions[i], "CarriagesMovingOutSoon", m_Reference.GetCreatureByName(Carriage_01));
		}
		return true;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- A R T I C Y  F U N C T I O N S --------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------------------------------------

	// Called in Journey_502_ChiefSettler_MapIntro dialogue
	void StartGameplay()
	{
		// Quest setup
		InitialSectorsDistribution(m_PlayersInititalSectors);
		AlliedAI_Placement();
		Enable_PathScenario();
		PlayedRaceCheck();
		SetInitialQuestTimer();

		// Side quest
		m_Reference.GetSharedJournal().ActivateQuest(m_sSideQuest_502, true);

		// reveal the settlers base for players
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.AddVisiblePath(m_Reference.GetPlayerFactions(true)[i], "Reveal_InitialSectors");
		}
	}

	// Called on activation of EscortCarriages_Paths_01 task
	void CarriagesMovedOut()
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "InitialExpansionTimerHint", false);
		m_Reference.GetCreatureByName(Carriage_01).EnablePOIVisitingBehavior(false);
		m_Reference.GetCreatureByName(Carriage_02).EnablePOIVisitingBehavior(false);
	}

	// Called on complition of EscortCarriages_Paths_01 task
	void FinishedFirstExpansion()
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "ProtectSettlersOutposts", true);
	}

	// Called on complition of ConquerSectors task
	void CarriagesConqueredSectors()
	{
		if (m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_502, "DestroyDarkelvenBase") == Completed)
		{
			uint _iEnemiesLeft = m_Reference.GetCreaturesFromSpawn("Carriage_01_EnemyWaveSpawn_05").length() + m_Reference.GetCreaturesFromSpawn("Carriage_02_EnemyWaveSpawn_05").length();
			m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iEnemiesToKill", _iEnemiesLeft);
			m_Reference.RegisterCreatureEventByIndividuals(Killed, TOnCreatureEvent(@this.OnRemainingEnemyKilled_CheckQuest), GetLivingCreaturesByFaction(m_iDarkElves_AttackWaves), true, "");
			m_Reference.GetSharedJournal().ActivateTask( m_sMainQuest_502, "KillRemainingAttackers", true );
		}

		m_Reference.SetAIFlag(m_iAlliedAI_Faction, CanControlHeroes, true);
		m_Reference.SetAIFlag(m_iAlliedAI_Faction, CanAttack, true);
	}

	// Called on activation of BuildSettlersHomes_FinalExpansion and BuildSettlersHomes_NormalExpansion tasks
	void ResetBuiltSettlersHomesCount()
	{
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iSettlersHomesBuilt", 0);
	}

	// Called on activation of Invis_SettlersHomesQuestMarker_0+(m_iCurrentExpansion) task
	void DisableExpansionQuestMarker()
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "Invis_ExpansionQuestMarker_0"+(m_iCurrentExpansion), false);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- C U S T O M  F U N C T I O N S --------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------------------------------------
	/*	--------------------------------------------------
	*	Expansions relevant functions
	*	--------------------------------------------------
	*/
	void AssignSectorsToFaction(string _sCarriage, uint _uFaction)
	{
		if(_sCarriage == Carriage_01)
		{
			for(uint i = 0; i < m_arrSectorsToConquer_Carriage01.length(); ++i)
			{
				m_SectorsToConquerByFaction.set(m_arrSectorsToConquer_Carriage01[i], _uFaction);
			}
		}
		else if(_sCarriage == Carriage_02)
		{
			for(uint i = 0; i < m_arrSectorsToConquer_Carriage02.length(); ++i)
			{
				m_SectorsToConquerByFaction.set(m_arrSectorsToConquer_Carriage02[i], _uFaction);
			}
		}
	}

	void SpawnAttackOnSettlerHome(string _sCarriageNum)
	{
		string _sSpawn = "Carriage_0"+_sCarriageNum+"_EnemyWaveSpawn_0"+m_iCurrentExpansion;
		m_Reference.ActivateSpawn(_sSpawn, true );
		CreatureGroup _EnemyWave = CreatureGroup(m_Reference, m_Reference.GetCreaturesFromSpawn(_sSpawn));
		_EnemyWave.AttackPosition(m_Reference.GetCreatureByName("Journey_SettlersCarriage_0"+_sCarriageNum+"_502"), false, false);
	}

	void ConquerSector(string _sCarriage)
	{
		Sector@ _Sector = m_Reference.GetCreatureByName(_sCarriage).GetCurrentSector(m_Reference);
		string _sSector = _Sector.GetName();
		_Sector.SetBlocked(false);

		uint _uFaction;
		m_SectorsToConquerByFaction.get(_sSector, _uFaction);
		_Sector.SetOwner(_uFaction);
		if(_uFaction != m_iAlliedAI_Faction)
		{
			_Sector.CreateMainBuilding(_uFaction, m_arrExpansionByPlayerFaction[_uFaction], true, true);
		}
		else if(_uFaction == m_iAlliedAI_Faction)
		{
			_Sector.CreateMainBuilding (m_iAlliedAI_Faction, "Exp1_H_Expansion_0", true, true);
			AlliedAI_DefendCarriage();
			Building _Godstone = m_Reference.GetBuildingByName("Entity_Godstone_"+_sSector);
			if(_Godstone.Exists())
			{
				_Godstone.SetFaction(m_Reference.GetHostFaction());
			}
		}
	}

	void SettlersReclaimedLand()
	{
		CheckpointReached();
		
		int _iReclaimedSettlersLand = m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iReclaimedSettlersLand");
		_iReclaimedSettlersLand++;
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_502_Q0_iReclaimedSettlersLand", _iReclaimedSettlersLand);

		HealCarriages();
		m_Reference.SetAIFlag(m_iAlliedAI_Faction, CanControlUnits, true);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_502, "Invis_SettlersHomesQuestMarker_0"+m_iCurrentExpansion, false);
	}

	/*	--------------------------------------------------
	*	Called every time carriages move out as part of new
	*	expansion
	*	--------------------------------------------------
	*/
	void AlliedAI_FollowCarriage()
	{
		m_Reference.SetAIFlag(m_iAlliedAI_Faction, CanControlUnits, false);
		for(uint i = 0; i < m_arrAlliedAI_Factions.length(); ++i)
		{
			CreatureGroup AlliedAI_Troops = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_arrAlliedAI_Factions[i]));
			AlliedAI_Troops.Stop();
		}

		if (m_Reference.GetSectorByName( "Sector_11" ).GetOwner() == m_iAlliedAI_Faction)
		{
			m_Reference.SetTimer(TOnTimerUserDataEvent(@this.FollowCarriage_Timer), 6, Carriage_02);
		}
		else if (m_Reference.GetSectorByName( "Sector_10" ).GetOwner() == m_iAlliedAI_Faction)
		{
			m_Reference.SetTimer(TOnTimerUserDataEvent(@this.FollowCarriage_Timer), 6, Carriage_01);
		}

		print("Called AlliedAI_FollowCarriage");
	}
	// Timer is used so allied AI units won't 'stumble' on the carriage
	bool FollowCarriage_Timer(const string& in _sCarriage)
	{
		for(uint i = 0; i < m_arrAlliedAI_Factions.length(); ++i)
		{
			CreatureGroup AlliedAI_Troops = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_arrAlliedAI_Factions[i]));
			AlliedAI_Troops.FollowCreature( m_Reference.GetCreatureByName(_sCarriage), 1000, 0, true, true);
		}

		return true;
	}

	/*	--------------------------------------------------
	*	Called when carriages start building a new home.
	*	New allied reinforcements will be summoned, while
	*	allied factions will be forced to move in the area,
	*	so all aliied troops will participate in defence 
	*	--------------------------------------------------
	*/
	void AlliedAI_DefendCarriage()
	{
		if (m_Reference.GetSectorByName( "Sector_11" ).GetOwner() == m_iAlliedAI_Faction)
		{
			CreatureGroup AlliedAI_Troops = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iAlliedAI_Faction));
			AlliedAI_Troops.Move( m_Reference.GetCreatureByName(Carriage_02), false, true, false);

			SummonAlliedAIReinforcements(Carriage_02);
		}
		else if (m_Reference.GetSectorByName( "Sector_10" ).GetOwner() == m_iAlliedAI_Faction)
		{
			CreatureGroup AlliedAI_Troops = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iAlliedAI_Faction));
			AlliedAI_Troops.Move( m_Reference.GetCreatureByName(Carriage_01), false, true, false);

			SummonAlliedAIReinforcements(Carriage_01);
		}

		print("Called AlliedAI_DefendCarriage");
	}

	/*	--------------------------------------------------
	*	Called when a carriage is damaged, thanks to it 
	*	we make sure that allied ai responds to a carriage
	*	being damaged
	*	--------------------------------------------------
	*/
	void AlliedAI_DefendCarriageOnTheGo(string _sCarriage)
	{
		for(uint i = 0; i < m_arrAlliedAI_Factions.length(); ++i)
		{
			CreatureGroup AlliedAI_Troops = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_arrAlliedAI_Factions[i]));
			AlliedAI_Troops.AttackPosition(m_Reference.GetCreatureByName(_sCarriage), false, false);
			AlliedAI_Troops.FollowCreature( m_Reference.GetCreatureByName(_sCarriage), 1000, 0, true, true);
		}
	}

	/*	--------------------------------------------------
	*	Carriages relevant functions
	*	--------------------------------------------------
	*/
	void HealCarriages()
	{
		m_Reference.CastSpell("Journey_502_CarriageHeal", m_iSettlers, m_Reference.GetCreatureByName(Carriage_01));
		m_Reference.CastSpell("Journey_502_CarriageHeal", m_iSettlers, m_Reference.GetCreatureByName(Carriage_02));
	}

	// Sends carriages to waiting spots during outposts defence and expansion preparation. Prevents glitchy Aliied AI behaviour
	void CarriageToWaitingSpot(string _CarriageName)
	{
		array<string> _WaitingSpots;
		m_CarriagesWaitingSpots.get(m_sCurrentExpansion, _WaitingSpots);
		if (_CarriageName == Carriage_01)
		{
			m_Reference.GetCreatureByName(_CarriageName).GoTo(m_Reference, m_Reference.GetLogicObjectByName(_WaitingSpots[0]), 0, 0, false, false);
		}
		else if (_CarriageName == Carriage_02)
		{
			m_Reference.GetCreatureByName(_CarriageName).GoTo(m_Reference, m_Reference.GetLogicObjectByName(_WaitingSpots[1]), 0, 0, false, false);
		}
		m_Reference.GetCreatureByName(_CarriageName).SetImmovable(true);
	}

	bool Carriage_01_ToWaitingSpot_Timer()
	{
		CarriageToWaitingSpot(Carriage_01);
		return true;
	}

	bool Carriage_02_ToWaitingSpot_Timer()
	{
		CarriageToWaitingSpot(Carriage_02);
		return true;
	}

	void SetCarriagesMovable()
	{
		m_Reference.GetCreatureByName(Carriage_01).SetImmovable(false);
		m_Reference.GetCreatureByName(Carriage_02).SetImmovable(false);
	}

	/*	--------------------------------------------------
	*	Summon functions
	*	--------------------------------------------------
	*/
	void SummonAlliedAIReinforcements(string sCarriageName)
	{
		EDifficulty m_eGameDifficulty = m_Reference.GetDifficulty();
		string _sReinforcementSpell = m_arrAlliedAIReinforcementsSpells[0];
		switch(m_eGameDifficulty)
		{
			case Normal:
				_sReinforcementSpell =	m_arrAlliedAIReinforcementsSpells[1];
				break;
			case Hard:
				_sReinforcementSpell =	m_arrAlliedAIReinforcementsSpells[2];				
				break;
			case Insane:
				_sReinforcementSpell =	m_arrAlliedAIReinforcementsSpells[3];				
				break;
			default:
				break;
		}

		m_Reference.CastSpell(_sReinforcementSpell, m_iAlliedAI_Reinforcements_Faction, m_Reference.GetCreatureByName(sCarriageName));
		CreatureGroup AlliedAI_ReinforcementTroops = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iAlliedAI_Reinforcements_Faction));
		AlliedAI_ReinforcementTroops.Move( m_Reference.GetCreatureByName(sCarriageName), false, true, false);
	}

	// Functions for summoning enemy attack waves while carriages are on the move in relation to selected difficulty
	void SummonAttack(uint8 m_iAttackFaction, string _sSummonSpot)
	{
		int _iExpansionIndex = m_iCurrentExpansion-1;
		EDifficulty m_eGameDifficulty = m_Reference.GetDifficulty();
		Summon tempSummon =	m_SummonsBalancing.Summons_Easy[_iExpansionIndex];
		switch(m_eGameDifficulty)
		{
			case Normal:
				tempSummon =	m_SummonsBalancing.Summons_Normal[_iExpansionIndex];
				break;
			case Hard:
				tempSummon =	m_SummonsBalancing.Summons_Hard[_iExpansionIndex];				
				break;
			case Insane:
				tempSummon =	m_SummonsBalancing.Summons_Insane[_iExpansionIndex];				
				break;
			default:
				break;
		}

		array<ESummonType> tempAttackGrp;
		tempAttackGrp = tempSummon.SpecialWave;

		m_Reference.ClearArea(_sSummonSpot);
		m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iDarkElves_AttackWaves, m_Reference.GetLogicObjectByName(_sSummonSpot));

		for (uint i = 0; i < tempAttackGrp.length(); ++i)
		{
			SpawnUnit(tempAttackGrp[i], m_iAttackFaction, _sSummonSpot);
		}
	}

	void SpawnUnit(ESummonType _spawnType, uint8 m_iAttackFaction ,string _sSummonSpot)
	{
		string tempSpellName = "";
		switch(_spawnType)
		{
			case Spectre:
				tempSpellName = m_sSummon_Spectre;
				break;
			case Spider:
				tempSpellName = m_sSummon_Spider;
				break;
			case Sleeper:
				tempSpellName = m_sSummon_Sleeper;
				break;
			case Infiltrator:
				tempSpellName = m_sSummon_Infiltrator;
				break;
			case Scion:
				tempSpellName = m_sSummon_Scion;
				break;
			case TwistedOne:
				tempSpellName = m_sSummon_TwistedOne;
				break;
			case LizardRider:
				tempSpellName = m_sSummon_LizardRider;
				break;
			case PlagueBeetle:
				tempSpellName = m_sSummon_PlagueBeetle;
				break;
			case NorsEmissary:
				tempSpellName = m_sSummon_NorsEmissary;
				break;
			case FleshThrower:
				tempSpellName = m_sSummon_FleshThrower;
				break;
		}

		m_Reference.CastSpell(tempSpellName, m_iAttackFaction, m_Reference.GetLogicObjectByName(_sSummonSpot));
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- D E B U G --------------------------------------------------------------------------------
	// -------------------------------------------------------------------------------------------------------------------
	void ImmortalCarriages()
	{
		m_Reference.GetCreaturesFromSpawn("Carriage_01_Spawn")[0].SetImmortal(true);
		m_Reference.GetCreaturesFromSpawn("Carriage_02_Spawn")[0].SetImmortal(true);
	}

	void KillAttackers()
	{
		CreatureGroup DarkElvenAttackers = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iDarkElves_AttackWaves));
		CreatureGroup DarkElvenAttackers_01 = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iDarkElvenAttack_01_Faction));
		CreatureGroup DarkElvenAttackers_02 = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iDarkElvenAttack_02_Faction));
		DarkElvenAttackers.Die(false);
		DarkElvenAttackers_01.Die(false);
		DarkElvenAttackers_02.Die(false);
	}

	void UnlockSectors()
	{
		for (uint i = 0; i < SectorsForSettlers_ToConquer.length(); ++i)
		{
			m_Reference.GetSectorByName(SectorsForSettlers_ToConquer[i]).SetBlocked(false);
		}
	}

	void CreateMainBuilding_Expansion0()
	{
		m_Reference.GetSectorByName("Sector_03").SetBlocked(false);
		m_Reference.GetSectorByName("Sector_03").CreateMainBuilding (m_Reference.GetHostFaction(), "Exp1_H_Expansion_0" , false, true);
	}

	void CreateMainBuilding_Expansion2()
	{
		m_Reference.GetSectorByName("Sector_09").SetBlocked(false);
		m_Reference.GetSectorByName("Sector_09").CreateMainBuilding (m_Reference.GetHostFaction(), "Exp1_H_Expansion_II" , false, true);
	}

	void CreateMainBuilding_Instant()
	{
		m_Reference.GetSectorByName("Sector_01").SetBlocked(false);
		m_Reference.GetSectorByName("Sector_01").CreateMainBuilding (m_Reference.GetHostFaction(), "Exp1_H_Expansion_0" , true, true);
	}

	void AutoConstruct()
	{
		m_Reference.GetBuildingByName("SettlersHome_01_Carriage_01").AutoConstruct();
	}

	void testRepair(string _sName)
	{
		Sector@ _Sector = m_Reference.GetSectorByName(_sName);
		Building _Outpost = _Sector.GetMainBuilding();
		_Outpost.Repair(_Outpost.GetMaxHP());
	}
}