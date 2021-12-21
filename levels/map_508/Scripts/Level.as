// includes:
#include "../../basicScripts/Journey_LevelBase.as"

class Level: Journey_LevelBase
{

	// --------------------------------------------------------------------------------------------------------------------
	// --- Member Variables -----------------------------------------------------------------------------------------------

	// Used in map intros/outros
	string m_sRebelMageGuide = "Journey_RebelMageGuide_508";
	string m_sMapIntroTopic = "Journey_508_RebelMageGuide_MapIntro";

	// count this version-number up. This is for later version tracking, when the QA plays the map. 
	string m_Version_Level = "QA hasn't played the map yet";

	// --- Factions -----------------------------------------------------------------------------------------------------------
	uint8 m_i0_PlayerFaction = 				0;
	uint8 m_i1_PlayerFaction = 				1;
	uint8 m_i2_PlayerFaction = 				2;
	
	uint8 m_iArchfireDemons = 				4;
	uint8 m_iRiftProtectors = 				5;
	uint8 m_iAndraFaction = 				6;

	// Quests
	string m_sMainQuest_508 = "Journey_508_Q0_ProtectIsamosArtefact";
	string m_sSideQuest_508 = "Journey_508_SQ0_DefendRebelMages";

	// Dictionaries that set what creatures and at which spots will be summoned, depending on currently played area
	dictionary m_SummonsTypes =
	{
		{"Rift01_Area", array<string> = {"Journey_508_ArchfireDemons_01", "Journey_508_ArchfireDemons_02", "Journey_508_SiphonedMedium"}},
		{"Rift02Rift03_Area", array<string> = {"Journey_508_ArchfireDemons_01", "Journey_508_ArchfireDemons_02", "Journey_508_SiphonedHard", "Journey_508_AlienDemon"}},
		{"Rift04Rift05_Area", array<string> = {"Journey_508_ArchfireDemons_01_Double", "Journey_508_AlienDemon_Double", "Journey_508_SiphonedHard_Double", "Journey_508_FatDemon"}},
		{"Final_Area", array<string> = {"Journey_508_ArchfireDemons_01_Double", "Journey_508_AlienDemon_Double", "Journey_508_SiphonedHard_Double", "Journey_508_FatDemon"}}
	};
	dictionary m_SummonsSpots =
	{
		{"Rift01_Area", array<string> = {"Rift01_SummonSpot_01", "Rift01_SummonSpot_02", "Rift01_SummonSpot_03", "Rift01_SummonSpot_04", "Rift01_SummonSpot_05", "Rift01_SummonSpot_06", "Rift01_SummonSpot_07", "Rift01_SummonSpot_08"}},
		{"Rift02Rift03_Area", array<string> = {"Rift02_SummonSpot_01", "Rift02_SummonSpot_02", "Rift02_SummonSpot_03", "Rift02_SummonSpot_04", "Rift02_SummonSpot_05", "Rift03_SummonSpot_01", "Rift03_SummonSpot_02", "Rift03_SummonSpot_03", "Rift03_SummonSpot_04", "Rift03_SummonSpot_05"}},
		{"Rift04Rift05_Area", array<string> = {"Rift04_SummonSpot_01", "Rift04_SummonSpot_02", "Rift04_SummonSpot_03", "Rift04_SummonSpot_04", "Rift04_SummonSpot_05", "Rift05_SummonSpot_01", "Rift05_SummonSpot_02", "Rift05_SummonSpot_03", "Rift05_SummonSpot_04", "Rift05_SummonSpot_05"}},
		{"Final_Area", array<string> = {"Final_SummonSpot_01", "Final_SummonSpot_02", "Final_SummonSpot_03", "Final_SummonSpot_04", "Final_SummonSpot_05", "Final_SummonSpot_06", "Final_SummonSpot_07", "Final_SummonSpot_08", "Final_SummonSpot_09", "Final_SummonSpot_10"}}
	};
	// Dictionary that sets relation between summoned final rift protectors and rifts where they are summoned
	dictionary m_FinalRiftProtectors =
	{
		{"Rift_06", ""},
		{"Rift_07", ""},
		{"Rift_08", ""}
	};
	// Stores ids of final rift protectors
	dictionary m_FinalRiftProtectorsIds =
	{
		{"Rift_06", 0},
		{"Rift_07", 0},
		{"Rift_08", 0}
	};
	// All rifts that players have to close to win the map
	array<string> m_arrRifts =
	{
		"Rift_01",
		"Rift_02",
		"Rift_03",
		"Rift_04",
		"Rift_05",
		"Rift_06",
		"Rift_07",
		"Rift_08"
	};
	array<string> m_arrRiftAreas = // All but the final one
	{
		"Rift01_Area",
		"Rift02Rift03_Area",
		"Rift04Rift05_Area"
	};

	array<string> m_arrRebelsSummonSpells =
	{
		"Journey_508_RebelMageFire_Summon",
		"Journey_508_RebelMageNecro_Summon",
		"Journey_508_RebelMageLight_Summon",
		"Journey_508_RebelMageNature_Summon"
	};
	array<string> m_arrRebelMages =
	{
		"Journey_RebelMageFire_508",
		"Journey_RebelMageLight_508",
		"Journey_RebelMageNature_508",
		"Journey_RebelMageNecro_508"
	};

	int m_iRebelsKilled = 0;

	uint m_uRebelsToSummon = 1;

	uint m_iAliveStaticRiftProtectors = 0;
	uint m_iSummonedFinalRiftProtectors = 0;
	uint m_iRiftsToClose = 0; // depends on the current area
	string m_sCurrentRiftWithStaticProtectors;
	string m_sCurrentRiftWithMobileProtector;
	uint m_iSummonsFrequency = 1 * 30;
	uint m_iSummonsToSpawn = 1; // may be increased in later rift areas

	string m_sCurrentlyPlayedArea;

	bool m_bRift01_ProtectorSummoned = false;
	bool m_bRift02_ProtectorSummoned = false;
	bool m_bRift03_ProtectorSummoned = false;
	bool m_bRift04_ProtectorSummoned = false;
	bool m_bRift05_ProtectorSummoned = false;
	bool m_bRift06_ProtectorSummoned = false;
	bool m_bRift07_ProtectorSummoned = false;
	bool m_bRift08_ProtectorSummoned = false;

	bool m_b1_FinalRiftProtectorSummoned = false;
	bool m_b2_FinalRiftProtectorSummoned = false;
	bool m_b3_FinalRiftProtectorSummoned = false;

	bool m_bActiveRiftGameplay = false;

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
		// registering events for summoning rift protectors
		// rifts with static rift protectors
		m_Reference.RegisterBuildingEventByIndividual(Damaged, TOnBuildingEvent(@this.OnDamaged_Rift01), "Rift_01");
		m_Reference.RegisterBuildingEventByIndividual(Damaged, TOnBuildingEvent(@this.OnDamaged_Rift02), "Rift_02");
		m_Reference.RegisterBuildingEventByIndividual(Damaged, TOnBuildingEvent(@this.OnDamaged_Rift05), "Rift_05");
		// rifts with mobile rift protectors
		m_Reference.RegisterBuildingEventByIndividual(Damaged, TOnBuildingEvent(@this.OnDamaged_Rift03), "Rift_03");
		m_Reference.RegisterBuildingEventByIndividual(Damaged, TOnBuildingEvent(@this.OnDamaged_Rift04), "Rift_04");
		// final rifts
		m_Reference.RegisterBuildingEventByIndividual(Damaged, TOnBuildingEvent(@this.OnDamaged_Rift06), "Rift_06");
		m_Reference.RegisterBuildingEventByIndividual(Damaged, TOnBuildingEvent(@this.OnDamaged_Rift07), "Rift_07");
		m_Reference.RegisterBuildingEventByIndividual(Damaged, TOnBuildingEvent(@this.OnDamaged_Rift08), "Rift_08");
		// registering events for winning current area and progressing further in the dungeon
		for (uint i = 0; i < m_arrRifts.length(); ++i)
		{
			m_Reference.RegisterBuildingEventByIndividual(Destroyed, TOnBuildingEvent(@this.OnDestroyedRift), m_arrRifts[i]);
		}
		// registering events for summoning demons according to rift areas which players enter
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.RegisterCreatureEventByDescription(EnteredArea, TOnCreatureEvent(@this.OnTriggerEnter_Rift01_Area), "", _uFaction, "Rift01_Area");
			m_Reference.RegisterCreatureEventByDescription(EnteredArea, TOnCreatureEvent(@this.OnTriggerEnter_Rift02Rift03_Area), "", _uFaction, "Rift02Rift03_Area");
			m_Reference.RegisterCreatureEventByDescription(EnteredArea, TOnCreatureEvent(@this.OnTriggerEnter_Rift04Rift05_Area), "", _uFaction, "Rift04Rift05_Area");
			m_Reference.RegisterCreatureEventByDescription(EnteredArea, TOnCreatureEvent(@this.OnTriggerEnter_Final_Area), "", _uFaction, "Final_Area");
			m_Reference.RegisterCreatureEventByDescription(EnteredArea, TOnCreatureEvent(@this.OnEnteredArea_MiniBossCreepsAttack), "", _uFaction, "MiniBoss_Trigger");
			// event for flavour attack of demons' swarm to set the mood in the beggining of the map
			m_Reference.RegisterHeroPartyEvent(AnyInside, TOnHeroPartyEvent(@this.OnTriggerEnter_FirstDemonsAttack_Trigger), "FirstDemonsAttack_Trigger", _uFaction);
			// event for updating SQ when a rebel mage is killed
			m_Reference.RegisterCreatureEventByDescription(Damaged, TOnCreatureEvent(@this.OnDamaged_CheckRebelMages), "", _uFaction, "" );
			// events for opening secret doors
			m_Reference.RegisterHeroPartyEvent(Interact, TOnHeroPartyEvent(@this.OnInteract_OpenSecretDoor_1), "SecretDoor_1_Lvler", _uFaction);
			m_Reference.RegisterHeroPartyEvent(Interact, TOnHeroPartyEvent(@this.OnInteract_OpenSecretDoor_2), "SecretDoor_2_Lvler", _uFaction);
		}
		// registering event for disabling Andra's barrier
		m_Reference.RegisterCreatureEventByIndividual(Killed, TOnCreatureEvent(@this.OnKilled_AndraInBarrier), "Journey_AndraInBarrier_508", "");
	}

	/*
		Is called right at the beginning of the level. Should only be used to start a dialoge, or directly stage an event and so on.
	*/
	void InitCommon ()
	{
		ActivateRandomLoot(50);
		// initial godstone
		m_Reference.GetBuildingByName("Initial_Godstone").SetFaction(m_Reference.GetHostFaction());
		// setting all rifts as hostile buildings
		for (uint i = 0; i < m_arrRifts.length(); ++i)
		{
			m_Reference.GetBuildingByName(m_arrRifts[i]).SetFaction(m_iArchfireDemons);
		}
		// blocking exits from all rift areas
		for (uint i = 0; i < m_arrRiftAreas.length(); ++i)
		{
			m_Reference.BlockNavMesh("PhysBlocker_"+ m_arrRiftAreas[i], true);
		}
		// disabling force field fx for rifts
		for (uint i = 0; i < m_arrRifts.length(); ++i)
		{
			m_Reference.GetLogicObjectByName(m_arrRifts[i] + "_InvulnerabilityFX").Enable(false);
		}
		// handling Andra
		m_Reference.GetCreatureByName("Journey_AndraInBarrier_508").PlayAnimation(m_Reference, FloatingLoop, -1, uint(-1), true, false, Entity ( ), false, false);
		m_Reference.GetCreatureByName("Journey_AndraInBarrier_508").SetHelpUpAllowed(false);
		// handling secret doors
		m_Reference.GetLogicObjectByName("SecretDoor_1").SetInteractive(false);
		m_Reference.GetLogicObjectByName("SecretDoor_2").SetInteractive(false);

		m_Reference.SetTimerMS(TOnTimerEvent(@this.SetQuestInts_Timer), 100);

		SetupIntroCreatures(m_sRebelMageGuide, m_sMapIntroTopic);
	}

	bool SetQuestInts_Timer()
	{
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_508_SQ0_iRebelsKilled", 0);
		return true;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T  F U N C T I O N S ----------------------------------------------------------------------------------
	bool OnTriggerEnter_FirstDemonsAttack_Trigger(Creature& in _Creature)
	{
		m_Reference.UnregisterHeroPartyEvent(AnyInside, TOnHeroPartyEvent(@this.OnTriggerEnter_FirstDemonsAttack_Trigger));
		CreatureGroup _Grp_Spawn1 = CreatureGroup(m_Reference, m_Reference.GetCreaturesFromSpawn("Spawn_QuestCreeps_1"));
		CreatureGroup _Grp_Spawn2 = CreatureGroup(m_Reference, m_Reference.GetCreaturesFromSpawn("Spawn_QuestCreeps_2"));
		_Grp_Spawn1.AttackPosition(_Creature, false, false);
		_Grp_Spawn2.AttackPosition(_Creature, false, false);
		return true;
	}
	
	bool OnTriggerEnter_Rift01_Area(Creature& in _Creature)
	{
		m_Reference.UnregisterCreatureEvent(EnteredArea, TOnCreatureEvent(@this.OnTriggerEnter_Rift01_Area));

		m_sCurrentlyPlayedArea = "Rift01_Area";
		m_bActiveRiftGameplay = true;
		m_iRiftsToClose = 1;
		m_Reference.SetTimer(TOnTimerEvent( @this.LoopedSummons_Timer ), 10 );
		m_Reference.GetBuildingByName("Rift01_Area_Godstone").SetFaction(m_Reference.GetHostFaction());
		m_Reference.SetTimerMS(TOnTimerEvent(@this.RevealRiftArea_Timer), 800);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_508, "WinRift01Area", true);

		// rebel mages vs demons
		m_Reference.ActivateSpawn("Rift01_Area_DemonsSpawn", true);
		SummonRebelMages();

		// activating rebels SQ
		m_Reference.GetSharedJournal().ActivateQuest(m_sSideQuest_508, true);

		return true;
	}
	bool OnTriggerEnter_Rift02Rift03_Area(Creature& in _Creature)
	{
		m_Reference.UnregisterCreatureEvent(EnteredArea, TOnCreatureEvent(@this.OnTriggerEnter_Rift02Rift03_Area));

		m_sCurrentlyPlayedArea = "Rift02Rift03_Area";
		m_bActiveRiftGameplay = true;
		m_iRiftsToClose = 2;
		m_Reference.SetTimer(TOnTimerEvent( @this.LoopedSummons_Timer ), 10 );
		m_Reference.GetBuildingByName("Rift02Rift03_Area_Godstone").SetFaction(m_Reference.GetHostFaction());
		m_Reference.SetTimerMS(TOnTimerEvent(@this.RevealRiftArea_Timer), 800);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_508, "WinRift02Rift03Area", true);

		// rebel mages vs demons
		m_Reference.ActivateSpawn("Rift02Rift03_Area_DemonsSpawn_1", true);
		m_Reference.ActivateSpawn("Rift02Rift03_Area_DemonsSpawn_2", true);
		m_uRebelsToSummon = 2;
		SummonRebelMages();

		return true;
	}
	bool OnTriggerEnter_Rift04Rift05_Area(Creature& in _Creature)
	{
		m_Reference.UnregisterCreatureEvent(EnteredArea, TOnCreatureEvent(@this.OnTriggerEnter_Rift04Rift05_Area));

		m_sCurrentlyPlayedArea = "Rift04Rift05_Area";
		m_bActiveRiftGameplay = true;
		m_iRiftsToClose = 2;
		m_Reference.SetTimer(TOnTimerEvent( @this.LoopedSummons_Timer ), 10 );
		m_Reference.GetBuildingByName("Rift04Rift05_Area_Godstone").SetFaction(m_Reference.GetHostFaction());
		m_Reference.SetTimerMS(TOnTimerEvent(@this.RevealRiftArea_Timer), 800);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_508, "WinRift04Rift05Area", true);

		// rebel mages vs demons
		m_Reference.ActivateSpawn("Rift04Rift05_Area_DemonsSpawn_1", true);
		m_Reference.ActivateSpawn("Rift04Rift05_Area_DemonsSpawn_2", true);
		SummonRebelMages();

		return true;
	}
	bool OnTriggerEnter_Final_Area(Creature& in _Creature)
	{
		m_Reference.UnregisterCreatureEvent(EnteredArea, TOnCreatureEvent(@this.OnTriggerEnter_Final_Area));

		m_sCurrentlyPlayedArea = "Final_Area";
		m_bActiveRiftGameplay = true;
		m_iRiftsToClose = 3;
		m_Reference.SetTimer(TOnTimerEvent( @this.LoopedSummons_Timer ), 10 );
		m_Reference.GetBuildingByName("Final_Area_Godstone").SetFaction(m_Reference.GetHostFaction());
		m_Reference.SetTimerMS(TOnTimerEvent(@this.RevealRiftArea_Timer), 800);
		// Maybe CameraOnAndra_Timer should be tuned so exploration shoutout won't feel out of place
		m_Reference.SetTimer(TOnTimerEvent( @this.CameraOnAndra_Timer ), 2 );
		JourneyExplorationShoutout(_Creature, "Journey_505_SO_AndraReaction");

		// rebel mages vs demons
		m_Reference.ActivateSpawn("Final_Area_DemonsSpawn_1", true);
		m_Reference.ActivateSpawn("Final_Area_DemonsSpawn_2", true);
		m_Reference.ActivateSpawn("Final_Area_DemonsSpawn_3", true);
		m_uRebelsToSummon = 3;
		SummonRebelMages();

		return true;
	}
	
	// Events for rifts with static rift protectors
	bool OnDamaged_Rift01(Building& in _Building)
	{
		if( _Building.GetCurrentHP() <= PercentOf( _Building.GetMaxHP(), 50) && m_bRift01_ProtectorSummoned != true)
		{
			m_bRift01_ProtectorSummoned = true;
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift01_SummonSpot_02"));
			m_Reference.CastSpell("Journey_508_RiftProtectorStatic", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift01_SummonSpot_02"));
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift01_SummonSpot_04"));
			m_Reference.CastSpell("Journey_508_RiftProtectorStatic", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift01_SummonSpot_04"));
			m_iAliveStaticRiftProtectors = 2;
			m_sCurrentRiftWithStaticProtectors = "Rift_01";
			m_Reference.SetTimerMS( TOnTimerEvent( @this.StaticChannelSpell_Timer ), 100 );
			return true;
		}
		return false;
	}
	bool OnDamaged_Rift02(Building& in _Building)
	{
		if( _Building.GetCurrentHP() <= PercentOf( _Building.GetMaxHP(), 50) && m_bRift02_ProtectorSummoned != true)
		{
			m_bRift02_ProtectorSummoned = true;
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift02_SummonSpot_01"));
			m_Reference.CastSpell("Journey_508_RiftProtectorStatic", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift02_SummonSpot_01"));
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift02_SummonSpot_02"));
			m_Reference.CastSpell("Journey_508_RiftProtectorStatic", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift02_SummonSpot_02"));
			m_iAliveStaticRiftProtectors = 2;
			m_sCurrentRiftWithStaticProtectors = "Rift_02";
			m_Reference.SetTimerMS( TOnTimerEvent( @this.StaticChannelSpell_Timer ), 100 );
			return true;
		}
		return false;
	}
	bool OnDamaged_Rift05(Building& in _Building)
	{
		if( _Building.GetCurrentHP() <= PercentOf( _Building.GetMaxHP(), 50) && m_bRift05_ProtectorSummoned != true)
		{
			m_bRift05_ProtectorSummoned = true;
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift05_SummonSpot_01"));
			m_Reference.CastSpell("Journey_508_RiftProtectorStatic", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift05_SummonSpot_01"));
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift05_SummonSpot_02"));
			m_Reference.CastSpell("Journey_508_RiftProtectorStatic", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift05_SummonSpot_02"));
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift05_SummonSpot_02"));
			m_Reference.CastSpell("Journey_508_RiftProtectorStatic", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift05_SummonSpot_03"));
			m_iAliveStaticRiftProtectors = 3;
			m_sCurrentRiftWithStaticProtectors = "Rift_05";
			m_Reference.SetTimerMS( TOnTimerEvent( @this.StaticChannelSpell_Timer ), 100 );
			return true;
		}
		return false;
	}

	bool StaticChannelSpell_Timer()
	{
		for (uint i = 0; i < m_iAliveStaticRiftProtectors; ++i)
		{
			if(i == 0)
			{
				m_Reference.GetCreatureByName("Journey_RiftProtectorStatic_508").ForceCast(m_Reference, "Journey_508_RiftChannel", m_Reference.GetCreatureByName("Invis_Creature_" + m_sCurrentRiftWithStaticProtectors), false);
				m_Reference.RegisterCreatureEventByIndividual(Killed, TOnCreatureEvent(@this.OnStaticRiftProtectorKilled), "Journey_RiftProtectorStatic_508", "");
			}
			else
			{
				m_Reference.GetCreatureByName("Journey_RiftProtectorStatic_508_"+i).ForceCast(m_Reference, "Journey_508_RiftChannel", m_Reference.GetCreatureByName("Invis_Creature_" + m_sCurrentRiftWithStaticProtectors), false);
				m_Reference.RegisterCreatureEventByIndividual(Killed, TOnCreatureEvent(@this.OnStaticRiftProtectorKilled), "Journey_RiftProtectorStatic_508_"+i, "");
			}
		}

		Building _Rift = m_Reference.GetBuildingByName(m_sCurrentRiftWithStaticProtectors);
		_Rift.ApplyCondition(1, -1, kMaxFactions, 100);//46002
		// We can trogger this shoutout with certain probability, if it will feel that it is triggered too often
		JourneyExplorationShoutout(_Rift, "Journey_508_SO_KillRiftProtector");
		m_Reference.GetLogicObjectByName(m_sCurrentRiftWithStaticProtectors + "_InvulnerabilityFX").Enable(true);

		return true;
	}
	bool OnStaticRiftProtectorKilled(Creature& in _Creature)
	{
		m_iAliveStaticRiftProtectors--;
		print("Static rift protector is killed, remaining static rift protectors in the current area: " + m_iAliveStaticRiftProtectors);
		if(m_iAliveStaticRiftProtectors == 0)
		{
			print("All static rift protectors are killed in the current area, " + m_sCurrentRiftWithStaticProtectors + " is no longer shielded");
			m_Reference.GetBuildingByName(m_sCurrentRiftWithStaticProtectors).RemoveCondition(1);
			m_Reference.GetLogicObjectByName(m_sCurrentRiftWithStaticProtectors + "_InvulnerabilityFX").Enable(false);
		}
		return false;
	}

	// Events for rifts with mobile rift protectors
	bool OnDamaged_Rift03(Building& in _Building)
	{
		if( _Building.GetCurrentHP() <= PercentOf( _Building.GetMaxHP(), 50) && m_bRift03_ProtectorSummoned != true)
		{
			m_bRift03_ProtectorSummoned = true;
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift03_SummonSpot_01"));
			m_Reference.CastSpell("Journey_508_RiftProtectorMobile", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift03_SummonSpot_01"));
			m_sCurrentRiftWithMobileProtector = "Rift_03";
			m_Reference.SetTimerMS( TOnTimerEvent( @this.MobileChannelSpell_Timer ), 100 );
			return true;
		}
		return false;
	}
	bool OnDamaged_Rift04(Building& in _Building)
	{
		if( _Building.GetCurrentHP() <= PercentOf( _Building.GetMaxHP(), 50) && m_bRift04_ProtectorSummoned != true)
		{
			m_bRift04_ProtectorSummoned = true;
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift04_SummonSpot_01"));
			m_Reference.CastSpell("Journey_508_RiftProtectorMobile", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Rift04_SummonSpot_01"));
			m_sCurrentRiftWithMobileProtector = "Rift_04";
			m_Reference.SetTimerMS( TOnTimerEvent( @this.MobileChannelSpell_Timer ), 100 );
			return true;
		}
		return false;
	}

	bool MobileChannelSpell_Timer()
	{
		m_Reference.GetCreatureByName("Invis_Creature_" + m_sCurrentRiftWithMobileProtector).ForceCast(m_Reference, "Journey_508_RiftChannel", m_Reference.GetCreatureByName("Journey_RiftProtectorMobile_508"), false);
		m_Reference.RegisterCreatureEventByIndividual(Killed, TOnCreatureEvent(@this.OnMobileRiftProtectorKilled), "Journey_RiftProtectorMobile_508", "");

		Building _Rift = m_Reference.GetBuildingByName(m_sCurrentRiftWithMobileProtector);
		_Rift.ApplyCondition(1, -1, kMaxFactions, 100);//46002
		// We can trogger this shoutout with certain probability, if it will feel that it is triggered too often
		JourneyExplorationShoutout(_Rift, "Journey_508_SO_KillRiftProtector");
		m_Reference.GetLogicObjectByName(m_sCurrentRiftWithMobileProtector + "_InvulnerabilityFX").Enable(true);
		return true;
	}
	bool OnMobileRiftProtectorKilled(Creature& in _Creature)
	{
		print("Mobile rift protector is killed, " + m_sCurrentRiftWithMobileProtector + " is no longer shielded");
		m_Reference.GetBuildingByName(m_sCurrentRiftWithMobileProtector).RemoveCondition(1);
		m_Reference.GetLogicObjectByName(m_sCurrentRiftWithMobileProtector + "_InvulnerabilityFX").Enable(false);
		return false;
	}

	// Events for final rifts
	bool OnDamaged_Rift06(Building& in _Building)
	{
		if( _Building.GetCurrentHP() <= PercentOf( _Building.GetMaxHP(), 50) && m_bRift06_ProtectorSummoned != true)
		{
			string _DamagedRift = "Rift_06";
			m_bRift06_ProtectorSummoned = true;
			m_iSummonedFinalRiftProtectors++;
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Final_SummonSpot_02"));
			m_Reference.CastSpell("Journey_508_RiftProtectorMobile", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Final_SummonSpot_02"));
			DamagedFinalRift(_DamagedRift);
			return true;
		}
		return false;
	}
	bool OnDamaged_Rift07(Building& in _Building)
	{
		if( _Building.GetCurrentHP() <= PercentOf( _Building.GetMaxHP(), 50) && m_bRift07_ProtectorSummoned != true)
		{
			string _DamagedRift = "Rift_07";
			m_bRift06_ProtectorSummoned = true;
			m_iSummonedFinalRiftProtectors++;
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Final_SummonSpot_05"));
			m_Reference.CastSpell("Journey_508_RiftProtectorMobile", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Final_SummonSpot_05"));
			DamagedFinalRift(_DamagedRift);
			return true;
		}
		return false;
	}
	bool OnDamaged_Rift08(Building& in _Building)
	{
		if( _Building.GetCurrentHP() <= PercentOf( _Building.GetMaxHP(), 50) && m_bRift08_ProtectorSummoned != true)
		{
			string _DamagedRift = "Rift_08";
			m_bRift08_ProtectorSummoned = true;
			m_iSummonedFinalRiftProtectors++;
			m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Final_SummonSpot_08"));
			m_Reference.CastSpell("Journey_508_RiftProtectorMobile", m_iRiftProtectors, m_Reference.GetLogicObjectByName("Final_SummonSpot_08"));
			DamagedFinalRift(_DamagedRift);
			return true;
		}
		return false;
	}

	bool FinalChannelSpell_Timer()
	{
		array<string> _arrkeys = m_FinalRiftProtectors.getKeys();
		for (uint i = 0; i < _arrkeys.length(); ++i)
		{
			string _sRiftToProtect = _arrkeys[i];
			string _sRiftProtectorName;
			m_FinalRiftProtectors.get(_arrkeys[i], _sRiftProtectorName);
			if(_sRiftProtectorName == "Journey_RiftProtectorMobile_508" && m_b1_FinalRiftProtectorSummoned != true)
			{
				print("This final rift "+_sRiftToProtect+" will be protected now with this creature "+_sRiftProtectorName);
				m_b1_FinalRiftProtectorSummoned = true;
				FinalChannelSpell(_sRiftToProtect, _sRiftProtectorName);
			}
			else if(_sRiftProtectorName == "Journey_RiftProtectorMobile_508_1" && m_b2_FinalRiftProtectorSummoned != true)
			{
				print("This final rift "+_sRiftToProtect+" will be protected now with this creature "+_sRiftProtectorName);
				m_b2_FinalRiftProtectorSummoned = true;
				FinalChannelSpell(_sRiftToProtect, _sRiftProtectorName);
			}
			else if(_sRiftProtectorName == "Journey_RiftProtectorMobile_508_2" && m_b3_FinalRiftProtectorSummoned != true)
			{
				print("This final rift "+_sRiftToProtect+" will be protected now with this creature "+_sRiftProtectorName);
				m_b3_FinalRiftProtectorSummoned = true;
				FinalChannelSpell(_sRiftToProtect, _sRiftProtectorName);
			}
		}
		return true;
	}
	bool OnFinalRiftProtectorKilled(Creature& in _Creature)
	{
		array<string> _arrkeys = m_FinalRiftProtectorsIds.getKeys();
		for (uint i = 0; i < _arrkeys.length(); ++i)
		{
			uint _uRiftProtectorId;
			m_FinalRiftProtectorsIds.get(_arrkeys[i], _uRiftProtectorId);
			print("_CreatureId: " + _Creature.GetId());
			print("We comapre it with " + _uRiftProtectorId);
			if(_Creature.GetId() == _uRiftProtectorId)
			{
				print("Mobile rift protector is killed, " + _arrkeys[i] + " is no longer shielded");
				m_Reference.GetBuildingByName(_arrkeys[i]).RemoveCondition(1);
				m_Reference.GetLogicObjectByName(_arrkeys[i] + "_InvulnerabilityFX").Enable(false);
			}
		}
		return true;
	}

	bool OnDestroyedRift(Building& in _Building)
	{
		m_iRiftsToClose--;
		if(m_iRiftsToClose == 0)
		{
			CreatureGroup _Grp_RiftSummons = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iArchfireDemons));
			_Grp_RiftSummons.Die(false);
			m_bActiveRiftGameplay = false;
			if(m_sCurrentlyPlayedArea != "Final_Area")
			{
				m_Reference.BlockNavMesh("PhysBlocker_" + m_sCurrentlyPlayedArea, false);
				m_Reference.GetLogicObjectByName("MagicWall_" + m_sCurrentlyPlayedArea).Enable(false);
				print("All rifts in the current area are closed, players can progress further through the dungeon");
			}
			else
			{
				m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_508, "AndraMustSurvive", Completed);

				if(m_iRebelsKilled < m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_508_SQ0_iKilledRebelsLimit"))
				{
					m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_508, "DeadRebelsLimit_Hint", Completed);
					m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_508, "DeadRebelsLimit", Completed);
				}

				// Changing Everlight weather
				SetEverlightWeather();
			}
		}
		else
		{
			print("Rifts remaining to close in the current area: " + m_iRiftsToClose);
		}
		return false;
	}

	// Andra related events
	bool CameraOnAndra_Timer()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("Andra_Spot"));
		}
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_508, "GetToAndra", Completed);
		return true;
	}
	bool OnKilled_AndraInBarrier(Creature& in _Creature)
	{
		m_Reference.GetLogicObjectByName("AndrasBarrier_FX").Enable(false);
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.LoseGame(m_Reference.GetPlayerFactions(true)[i]);
		}
		return true;
	}

	// SQ related events
	bool OnDamaged_CheckRebelMages(Creature& in _Creature)
	{
		for (uint i = 0; i < m_arrRebelMages.length(); ++i)
		{
			if(_Creature.GetDescriptionName() == m_arrRebelMages[i] && _Creature.GetCurrentHP() <= 0)
			{
				m_iRebelsKilled++;
				m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_508_SQ0_iRebelsKilled", m_iRebelsKilled);

				if(m_iRebelsKilled >= m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_508_SQ0_iKilledRebelsLimit"))
				{
					m_Reference.GetSharedJournal().SetQuestState(m_sSideQuest_508, Failed);
				}
			}
		}
		return false;
	}

	bool OnEnteredArea_MiniBossCreepsAttack(Creature& in _Creature)
	{
		m_Reference.UnregisterCreatureEvent(EnteredArea, TOnCreatureEvent(@this.OnEnteredArea_MiniBossCreepsAttack));
		Creature[] tempCreaturesContainer = m_Reference.FindCreaturesInArea("MiniBoss_Trigger");
		for (uint i = 0; i < tempCreaturesContainer.length(); ++i)
		{
			if(tempCreaturesContainer[i].GetDescriptionName() == "Journey_AlienDemon_508")
			{
				tempCreaturesContainer[i].AttackPosition(m_Reference, _Creature, false, false);
			}
		}
		return true;
	}

	// Secret doors
	bool OnInteract_OpenSecretDoor_1(Creature &in _Creature)
	{
		m_Reference.UnregisterHeroPartyEvent(Interact, TOnHeroPartyEvent(@this.OnInteract_OpenSecretDoor_1));
		m_Reference.GetLogicObjectByName("SecretDoor_1").SetToggleState(true);
		m_Reference.GetLogicObjectByName("SecretDoor_1_Lvler").SetInteractive(false);
		return true;
	}

	bool OnInteract_OpenSecretDoor_2(Creature &in _Creature)
	{
		m_Reference.UnregisterHeroPartyEvent(Interact, TOnHeroPartyEvent(@this.OnInteract_OpenSecretDoor_2));
		m_Reference.GetLogicObjectByName("SecretDoor_2").SetToggleState(true);
		m_Reference.GetLogicObjectByName("SecretDoor_2_Lvler").SetInteractive(false);
		return true;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- A R T I C Y  F U N C T I O N S --------------------------------------------------------------------------------

	void FadeInAndBack()
	{
		m_Reference.FadeToBlackAndBack(uint8(-1), uint8(-1), 500, 1000);
	}

	// Called in map outro
	void CompleteProtectRebelsSideQuest()
	{
		m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_508, "ReportBackToRebelMageGuide", Completed);
	}

	// Called on complition of SpeakToRebelMageGuide task
	void TeleportAwayRebelMageGuide()
	{
		Creature _RebelMageGuide = m_Reference.GetCreatureByName(m_sRebelMageGuide);
		_RebelMageGuide.PlayAnimation(m_Reference, CastInstantSelf, -1, 700, false, false, Entity ( ), false, false, false);
		m_Reference.SetTimerMS(TOnTimerEvent( @this.TeleportAwayRebelMageGuide_Timer ), 600);
		m_Reference.CastSpell("Journey_500_TeleportMessenger", m_iAndraFaction, _RebelMageGuide);
	}

	bool TeleportAwayRebelMageGuide_Timer()
	{
		m_Reference.GetCreatureByName(m_sRebelMageGuide).Enable(false);
		return true;
	}

	// Called on activation of ReportBackToRebelMageGuide task
	void TeleportBackRebelMageGuide()
	{
		Creature _RebelMageGuide = m_Reference.GetCreatureByName(m_sRebelMageGuide);
		m_Reference.CastSpell("Journey_500_TeleportMessenger", m_iAndraFaction, m_Reference.GetLogicObjectByName("Andra_Spot"));
		_RebelMageGuide.Teleport(m_Reference, m_Reference.GetLogicObjectByName("Andra_Spot"));
		_RebelMageGuide.Enable(true);
		_RebelMageGuide.PlayAnimation(m_Reference, Idle, -1, 3000, false, false, Entity (m_Reference.GetCreatureByName("Journey_AndraInBarrier_508")), false, false, false);
		JourneyDialogShoutout(m_sRebelMageGuide, m_sRebelMageGuide, "Journey_508_SO_TeleportsToAndra");
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- C U S T O M  F U N C T I O N S ---------------------------------------------------------------------------------

	bool LoopedSummons_Timer()
	{
		if (m_bActiveRiftGameplay)
		{
			array<string> _arrSummonsTypes;
			array<string> _arrSummonsSpots;
			m_SummonsTypes.get(m_sCurrentlyPlayedArea, _arrSummonsTypes);
			m_SummonsSpots.get(m_sCurrentlyPlayedArea, _arrSummonsSpots);
			for (uint i = 0; i < m_iSummonsToSpawn; ++i)
			{
				uint _uRandomSummonIndex = m_Reference.GetRandom().GetInteger( 0, _arrSummonsTypes.length());
				uint _uRandomSpotIndex = m_Reference.GetRandom().GetInteger( 0, _arrSummonsSpots.length());
				print("This wave will be summoned: "+_arrSummonsTypes[_uRandomSummonIndex] + " at this spot: "+_arrSummonsSpots[_uRandomSpotIndex]);
				m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iArchfireDemons, m_Reference.GetLogicObjectByName(_arrSummonsSpots[_uRandomSpotIndex]));
				m_Reference.CastSpell(_arrSummonsTypes[_uRandomSummonIndex], m_iArchfireDemons, m_Reference.GetLogicObjectByName(_arrSummonsSpots[_uRandomSpotIndex]));
			}
			m_Reference.SetTimerMS( TOnTimerEvent( @this.DemonsAttack_Timer ), 100 );
			m_Reference.SetTimer( TOnTimerEvent( @this.LoopedSummons_Timer ), m_iSummonsFrequency );
		}
		else
		{
			print("There are no open rifts in the current area, thus demons won't be summoned");	
		}
		return true;
	}
	bool DemonsAttack_Timer()
	{
		CreatureGroup _Grp_RiftSummons = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iArchfireDemons));
		if(m_sCurrentlyPlayedArea != "Final_Area")
		{
			uint _iRiftSummonsTargetId = RiftSummonsTargetId();
			if(_iRiftSummonsTargetId != 0)
			{
				_Grp_RiftSummons.AttackPosition(m_Reference.GetCreatureById(_iRiftSummonsTargetId), false, false);
			}
			else
			{
				_Grp_RiftSummons.AttackPosition(m_Reference.GetBuildingByName("Rift_01"), false, false);
				print("No alive heroes were found in the currently played rift area, thus summons will attack position of the rift.");
			}
		}
		else
		{
			_Grp_RiftSummons.AttackPosition(m_Reference.GetCreatureByName("Journey_AndraInBarrier_508"), false, false);
			print("Because final area is played rift summons are attacking Andra's position now");
		}
		return true;
	}
	/*	--------------------------------------------------
	*	Gets an id of a random hero from a random player controlled
	*	faction inside currently played rift area. Will
	*	return 0 if there are no alive heroes in the area
	*	--------------------------------------------------
	*/
	uint RiftSummonsTargetId()
	{
		uint _stgRandomHeroId = 0;
		array<uint> _arrFactionsInArea = {};
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			if(HeroParty_InArea(m_sCurrentlyPlayedArea, _uFaction))
			{
				_arrFactionsInArea.insertLast(_uFaction);
			}
		}
		if(_arrFactionsInArea.length() > 0)
		{
			uint _uRandomFactionInArea = _arrFactionsInArea[m_Reference.GetRandom().GetInteger( 0, _arrFactionsInArea.length())];
			string _stgRandomHeroName;
			array <Creature>@ _arrCrtHeroParty = m_Reference.GetHeroParty( _uRandomFactionInArea ).GetMembers ();
			// get ids of party members who are alive and inside currently played rift area
			array<uint> _arrAliveAndInArea = {};
			for ( uint _iTmp1 = 0 ; _iTmp1 < _arrCrtHeroParty.length() ; _iTmp1++ )
			{
				if ( _arrCrtHeroParty[_iTmp1].GetCurrentHP() > 0 && IsCreatureInsideArea( _arrCrtHeroParty[_iTmp1], m_sCurrentlyPlayedArea))
				{
					print("We add this hero in summons' targets list: " + _arrCrtHeroParty[_iTmp1].GetDescriptionName());
					_arrAliveAndInArea.insertLast(_arrCrtHeroParty[_iTmp1].GetId());
				}
			}
			if (_arrAliveAndInArea.length() == 1)
			{
				_stgRandomHeroId = _arrAliveAndInArea[0];
				_stgRandomHeroName = m_Reference.GetCreatureById(_stgRandomHeroId).GetDescriptionName();
				print("Rift summons will attack position of this hero: " + _stgRandomHeroName);
				return _stgRandomHeroId;
			}
			else if (_arrAliveAndInArea.length() > 1)
			{
				_stgRandomHeroId = _arrAliveAndInArea[ m_Reference.GetRandom().GetInteger( 0, _arrAliveAndInArea.length()) ];
				_stgRandomHeroName = m_Reference.GetCreatureById(_stgRandomHeroId).GetDescriptionName();
				print("Rift summons will attack position of this hero: " + _stgRandomHeroName);
				return _stgRandomHeroId;
			}
		}
		return _stgRandomHeroId;
	}

	void DamagedFinalRift(string _DamagedRift)
	{
		if (m_iSummonedFinalRiftProtectors == 1)
		{
			m_FinalRiftProtectors.set(_DamagedRift, "Journey_RiftProtectorMobile_508");
		}
		else if(m_iSummonedFinalRiftProtectors == 2)
		{
			m_FinalRiftProtectors.set(_DamagedRift, "Journey_RiftProtectorMobile_508_1");
		}
		else if(m_iSummonedFinalRiftProtectors == 3)
		{
			m_FinalRiftProtectors.set(_DamagedRift, "Journey_RiftProtectorMobile_508_2");
		}
		m_Reference.SetTimerMS( TOnTimerEvent( @this.FinalChannelSpell_Timer ), 100 );
	}
	void FinalChannelSpell(string _sRiftToProtect, string _sRiftProtectorName)
	{
		Creature _RiftProtector = m_Reference.GetCreatureByName(_sRiftProtectorName);
		m_FinalRiftProtectorsIds.set(_sRiftToProtect, _RiftProtector.GetId());
		m_Reference.GetCreatureByName("Invis_Creature_" + _sRiftToProtect).ForceCast(m_Reference, "Journey_508_RiftChannel", _RiftProtector, false);
		m_Reference.RegisterCreatureEventByIndividual(Killed, TOnCreatureEvent(@this.OnFinalRiftProtectorKilled), _sRiftProtectorName, "");
		m_Reference.GetBuildingByName(_sRiftToProtect).ApplyCondition(1, -1, kMaxFactions, 100);//46002
		m_Reference.GetLogicObjectByName(_sRiftToProtect + "_InvulnerabilityFX").Enable(true);
		_RiftProtector.SetPreserveBody(true);
		// We can trogger this shoutout with certain probability, if it will feel that it is triggered too often
		JourneyExplorationShoutout(_RiftProtector, "Journey_508_SO_KillRiftProtector");
	}

	void SummonRebelMages()
	{
		uint _uPlayers = m_Reference.GetPlayerFactions(true).length();
		switch(_uPlayers)
		{
			case 1:
				for (uint i = 0; i < m_uRebelsToSummon; ++i)
				{
					for (uint j = 0; j < 3; ++j)
					{
						uint _uRandomIndex = m_Reference.GetRandom().GetInteger(0, m_arrRebelsSummonSpells.length());
						string _sRebelSummonSpell = m_arrRebelsSummonSpells[_uRandomIndex];
						m_Reference.CastSpell(_sRebelSummonSpell, m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName(m_sCurrentlyPlayedArea+"_RebelMages_Spot_"+(j+1)));
					}
				}
				break;
			case 2:
				for (uint i = 0; i < m_uRebelsToSummon; ++i)
				{
					for (uint j = 0; j < m_Reference.GetPlayerFactions(true).length(); ++j)
					{
						uint _uRandomIndex = m_Reference.GetRandom().GetInteger(0, m_arrRebelsSummonSpells.length());
						string _sRebelSummonSpell = m_arrRebelsSummonSpells[_uRandomIndex];
						if(m_Reference.GetPlayerFactions(true)[j] == m_Reference.GetHostFaction())
						{
							m_Reference.CastSpell(_sRebelSummonSpell, m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName(m_sCurrentlyPlayedArea+"_RebelMages_Spot_1"));
						}
						else
						{
							m_Reference.CastSpell(_sRebelSummonSpell, m_Reference.GetPlayerFactions(true)[j], m_Reference.GetLogicObjectByName(m_sCurrentlyPlayedArea+"_RebelMages_Spot_2"));
							m_Reference.CastSpell(_sRebelSummonSpell, m_Reference.GetPlayerFactions(true)[j], m_Reference.GetLogicObjectByName(m_sCurrentlyPlayedArea+"_RebelMages_Spot_3"));
						}
					}
				}
				break;
			case 3:
				for (uint i = 0; i < m_uRebelsToSummon; ++i)
				{
					for (uint j = 0; j < m_Reference.GetPlayerFactions(true).length(); ++j)
					{
						uint _uRandomIndex = m_Reference.GetRandom().GetInteger(0, m_arrRebelsSummonSpells.length());
						string _sRebelSummonSpell = m_arrRebelsSummonSpells[_uRandomIndex];
						uint _uPlayerFaction = m_Reference.GetPlayerFactions(true)[j];
						m_Reference.CastSpell(_sRebelSummonSpell, _uPlayerFaction, m_Reference.GetLogicObjectByName(m_sCurrentlyPlayedArea+"_RebelMages_Spot_"+(_uPlayerFaction+1)));
					}
				}
				break;
		}
	}

	bool RevealRiftArea_Timer()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.AddVisiblePath(m_Reference.GetPlayerFactions(true)[i], m_sCurrentlyPlayedArea);
		}

		RebelsShoutouts();

		return true;
	}

	void RebelsShoutouts()
	{
		Creature[] _RebelsToSpeak = {};
		Creature[] _Rebels = m_Reference.FindCreaturesByPrefix("Journey_RebelMage");
		array<LogicObject>@ _Spots = m_Reference.FindLogicObjectsByPrefix(m_sCurrentlyPlayedArea+"_RebelMages_Spot_");
		for (uint i = 0; i < _Rebels.length(); ++i)
		{
			for (uint j = 0; j < _Spots.length(); ++j)
			{
				if(m_Reference.GetEntityDistance(_Rebels[i].GetId(), _Spots[j].GetId()) <= 20)
				{
					_RebelsToSpeak.insertLast(_Rebels[i]);
				}
			}
		}

		// We can tune percentage of shoutouts in relation to number of rebels in the area to our liking
		uint _uShoutouts = PercentOf(_RebelsToSpeak.length(), 30);
		array<string> _UsedShoutouts = {};
		for (uint i = 0; i < _uShoutouts; ++i)
		{
			uint _uRandom = m_Reference.GetRandom().GetInteger(0, _RebelsToSpeak.length());
			string _sSpeaker = m_Reference.FindEntityName(_RebelsToSpeak[_uRandom]);
			string _sContainerName = _RebelsToSpeak[_uRandom].GetDescriptionName();
			if(_UsedShoutouts.find(_sContainerName) == -1)
			{
				JourneyDialogShoutout(_sSpeaker, _sContainerName, "Journey_508_SO_RebelsFightDemons");
			}
			_UsedShoutouts.insertLast(_sContainerName);
			_RebelsToSpeak.removeAt(_uRandom);
		}
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- DEBUG ----------------------------------------------------------------------------------
	void testRiftArea(string m_sCurrentlyPlayedArea)
	{
		if (m_bActiveRiftGameplay)
		{
			array<string> _arrSummonsTypes;
			array<string> _arrSummonsSpots;
			m_SummonsTypes.get(m_sCurrentlyPlayedArea, _arrSummonsTypes);
			m_SummonsSpots.get(m_sCurrentlyPlayedArea, _arrSummonsSpots);
			for (uint i = 0; i < m_iSummonsToSpawn; ++i)
			{
				uint _uRandomSummonIndex = m_Reference.GetRandom().GetInteger( 0, _arrSummonsTypes.length());
				uint _uRandomSpotIndex = m_Reference.GetRandom().GetInteger( 0, _arrSummonsSpots.length());
				print("This wave will be summoned: "+_arrSummonsTypes[_uRandomSummonIndex] + " at this spot: "+_arrSummonsSpots[_uRandomSpotIndex]);
				m_Reference.CastSpell("Exp1_Veil_Destroyed", m_iArchfireDemons, m_Reference.GetLogicObjectByName(_arrSummonsSpots[_uRandomSpotIndex]));
				m_Reference.CastSpell(_arrSummonsTypes[_uRandomSummonIndex], m_iArchfireDemons, m_Reference.GetLogicObjectByName(_arrSummonsSpots[_uRandomSpotIndex]));
			}
			m_Reference.SetTimerMS( TOnTimerEvent( @this.DemonsAttack_Timer ), 100 );
			m_Reference.SetTimer( TOnTimerEvent( @this.LoopedSummons_Timer ), m_iSummonsFrequency );
		}
		else
		{
			print("There are no open rifts in the current area, thus demons won't be summoned");	
		}
	}
}
