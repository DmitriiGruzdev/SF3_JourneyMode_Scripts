// includes:
#include "../../basicScripts/Journey_LevelBase.as"
#include "../../basicScripts/Journey_FarlornsHope_Balancing.as"

class Level: Journey_LevelBase
{

	// --------------------------------------------------------------------------------------------------------------------
	// --- Member Variables -----------------------------------------------------------------------------------------------

	Journey_FarlornsHope_Balancing m_WaveBalancing;

	// Used in map intros/outros
	string m_sClaraFarlorn = "Journey_ClaraFarlorn_506";
	string m_sMapIntroTopic = "Journey_506_ClaraFarlorn_MapIntro";

	// count this version-number up. This is for later version tracking, when the QA plays the map. 
	string m_Version_Level = "QA hasn't played the map yet";

	// --- Factions -----------------------------------------------------------------------------------------------------------
	uint8 m_i0_PlayerFaction = 				0;
	uint8 m_i1_PlayerFaction = 				1;
	uint8 m_i2_PlayerFaction = 				2;
	uint8 m_iDwarvenAttacks = 				3;
	uint8 m_iDwarvenDefence = 				4;
	uint8 m_iFarlornsHopeFaction = 			5;

	// Quests
	string m_sMainQuest_506 = "Journey_506_Q0_DefendFarlornsHope";
	string m_sSideQuest_506 = "Journey_506_SQ0_CollectResourcePickups";

	// quest timer
	uint m_iTimeBeforeRoyalArmyArrives = 30 * 60;
	uint m_iNextReinforcementTimer = 6 * 60;

	// waves' timers
	uint m_iMediumDifficultyWavesTimer = 10 * 60;
	uint m_iHardDifficultyWavesTimer = 20 * 60;

	// uint m_iAttackWavesFrequency = 1.5 * 60;
	uint m_iAttacksSummoned = 0;
	uint m_uCurrentWave = 0;

	// Spellnames
	string m_sSummon_MoleRider = 					"Journey_506_SummonMoleRider";
	string m_sSummon_Axewielder = 					"Journey_506_SummonAxewielder";
	string m_sSummon_DwarfSentry = 					"Journey_506_SummonDwarfSentry";
	string m_sSummon_EarthShaper =					"Journey_506_SummonEarthShaper";
	string m_sSummon_Berserker = 					"Journey_506_SummonBerserker";
	string m_sSummon_Pyromancer = 					"Journey_506_SummonPyromancer";
	string m_sSummon_CombatBalloon = 				"Journey_506_SummonCombatBalloon";
	string m_sSummon_FireGolem = 					"Journey_506_SummonFireGolem";
	string m_sSummon_BanditHealer = 				"Journey_506_SummonBanditHealer";

	// Current difficulty of attack waves, determines tier of reinforcements for players
	string m_sAttackWavesDifficulty = "Easy";

	// Keeps track of how many remaining enemies are already killed in the final part of the quest
	uint m_iRemainingEnemiesKilled = 0;

	// dictionary that determines of what tier reinfocements will be spawned depending on current difficulty 
	dictionary m_ReinforcementsTier = 
	{
		{"Easy", "I"},
		{"Medium", "II"},
		{"Hard", "III"}
	};

	array<string> m_arrRandomizedDeposits =
	{
		"ResourceDeposits_1",
		"ResourceDeposits_2",
		"ResourceDeposits_3",
		"ResourceDeposits_4",
		"ResourceDeposits_5",
		"ResourceDeposits_6",
		"ResourceDeposits_7",
		"ResourceDeposits_8",
		"ResourceDeposits_9"
	};

	dictionary m_dictDepositsPerArea = 
	{
		{"ResourceDeposits_10", 4}
	};

	// Overall ammount of resource pickups
	uint m_uResourcePickups = 10;
	// Ammount of randomly disabled pickups on map launch
	uint m_uDisabledPickups = 6;

	uint m_uPickupsCollected = 0;

	uint m_uResourceDepositCapacity = 25;

	// quest bools
	bool m_bRoyalArmyArrived = false;
	bool m_bFirstReinforcementsChoiceIsMade = false;

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
			if(m_Reference.GetPlayerFactions(true)[i] == m_Reference.GetHostFaction())
			{
				m_Reference.RegisterHeroPartyEvent(ResourcesCollected, TOnHeroPartyExtendedEvent(@this.OnResourcesCollected_HostPlayer), "", m_Reference.GetPlayerFactions(true)[i]);
			}
			else
			{
				m_Reference.RegisterHeroPartyEvent(ResourcesCollected, TOnHeroPartyExtendedEvent(@this.OnResourcesCollected_JoinedPlayer), "", m_Reference.GetPlayerFactions(true)[i]);
			}
		}

		// registering lose condition in case farlorn's hope tavern is destroyed
		m_Reference.RegisterBuildingEventByDescription(Destroyed, TOnBuildingEvent(@this.OnDestroyed_ProtoTavern), "Journey_ProtoTavern_506", m_Reference.GetHostFaction());
	}

	/*
		Is called right at the beginning of the level. Should only be used to start a dialoge, or directly stage an event and so on.
	*/
	void InitCommon ()
	{
		ActivateRandomLoot(75);
		
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.AddVisiblePath(m_Reference.GetPlayerFactions(true)[i], "DefenceAreaReveal");
		}
		// Initial godstone
		m_Reference.GetBuildingByName("Godstone_Sector_01").SetFaction(m_Reference.GetHostFaction());

		// Checking if waves are set correctly for current difficulty in Journey_FarlornsHope_Balancing
		CheckWavesForCurrentDifficulty();

		m_Reference.GetLogicObjectByName("Mulandir_Door").SetInteractive(false);

		// Handling resource pickups in accordance with host's race. Should be in the resource setup function
		SetupResourcePickups();

		SetupIntroCreatures(m_sClaraFarlorn, m_sMapIntroTopic);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- CUSTOM FUNCTIONS AND EVENTS ----------------------------------------------------------------------------------
	void SetupResourcePickups()
	{
		HostRaceCheck();

		for (uint i = 0; i < m_uDisabledPickups; ++i)
		{
			uint _uRandomIndex = m_Reference.GetRandom().GetInteger(0, m_arrRandomizedDeposits.length());
			m_Reference.EnableGroup(m_arrRandomizedDeposits[_uRandomIndex], false, true);
			m_arrRandomizedDeposits.removeAt(_uRandomIndex);
		}

		for (uint i = 0; i < m_arrRandomizedDeposits.length(); ++i)
		{
			string _sResourcePickup = m_arrRandomizedDeposits[i];
			string _sResourcePickupNum = _sResourcePickup.substr(_sResourcePickup.findLast("_", -1)+1, -1);
			m_Reference.GetSharedJournal().ActivateTask(m_sSideQuest_506, "CollectPickup_"+_sResourcePickupNum, true);
			m_Reference.ActivateSpawn("ResourceDeposit_Spawn_"+_sResourcePickupNum, true);
			m_dictDepositsPerArea.set(_sResourcePickup, 4);
		}

		m_Reference.SetTimerMS(TOnTimerEvent(@this.SetQuestInts_Timer), 100);
	}

	void HostRaceCheck()
	{
		string _sPlayedRace = TranslateRaceEnum(m_Reference.GetFactionRace(m_Reference.GetHostFaction()));
		if(_sPlayedRace == "Dwarf")
		{
			for (uint i = 0; i < m_uResourcePickups; ++i)
			{
				m_Reference.GetResourceDepositByName("WoodDeposit_"+(i+1)).Enable(false);
				m_Reference.GetResourceDepositByName("ScrapDeposit_"+(i+1)).Enable(false);
			}
		}
		else if(_sPlayedRace == "Troll")
		{
			for (uint i = 0; i < m_uResourcePickups; ++i)
			{
				m_Reference.GetResourceDepositByName("CharcoalDeposit_"+(i+1)).Enable(false);
				m_Reference.GetResourceDepositByName("IronDeposit_"+(i+1)).Enable(false);
			}
		}
		else
		{
			for (uint i = 0; i < m_uResourcePickups; ++i)
			{
				m_Reference.GetResourceDepositByName("ScrapDeposit_"+(i+1)).Enable(false);
				m_Reference.GetResourceDepositByName("CharcoalDeposit_"+(i+1)).Enable(false);
			}
		}

		/*
		*	Joined players races are changed so they can pick up all resources.
		*	For some reason joined players still can't pick up resources if they
		*	chose different race (from host) in the lobby
		*/

		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			if(m_Reference.GetPlayerFactions(true)[i] != m_Reference.GetHostFaction())
			{
				m_Reference.SetFactionRace(m_Reference.GetPlayerFactions(true)[i], m_Reference.GetFactionRace(m_Reference.GetHostFaction()));
			}
		}
	}

	bool SetQuestInts_Timer()
	{
		uint _uPickupsToCollect = m_arrRandomizedDeposits.length() + 1;
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_506_SQ0_uResourcePickupsToCollect", _uPickupsToCollect);

		// Resetting global quest ints
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_506_SQ0_uResourcePickupsCollected", 0);
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_506_Q0_iEnemiesKilled", 0);
		return true;
	}

	void UpdateQuestOnResourcePickup(string _sResourcePickup)
	{
		string _sResourcePickupNum = _sResourcePickup.substr(_sResourcePickup.findLast("_", -1)+1, -1);
		uint _uRemainingPickups;
		m_dictDepositsPerArea.get("ResourceDeposits_"+_sResourcePickupNum, _uRemainingPickups);
		_uRemainingPickups--;
		m_dictDepositsPerArea.set("ResourceDeposits_"+_sResourcePickupNum, _uRemainingPickups);

		if(_uRemainingPickups == 0)
		{
			m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_506, "CollectPickup_"+_sResourcePickupNum, Completed);
			m_uPickupsCollected++;
			m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_506_SQ0_uResourcePickupsCollected", m_uPickupsCollected);

			m_dictDepositsPerArea.delete("ResourceDeposits_"+_sResourcePickupNum);
			if(m_dictDepositsPerArea.isEmpty())
			{
				m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_506, "CollectResourcePcikups", Completed);
			}
		}
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- D E B U G ----------------------------------------------------------------------------------
	void testDwarvenSpawn()
	{
		m_Reference.CastSpell("Journey_506_DwarvenAirForce", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_North_Spot"));
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_West_Spot"));
		m_Reference.CastSpell("Journey_506_DwarvenStrongAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_East_Spot"));
	}
	void ImmortalTavern()
	{
		m_Reference.GetBuildingByName("Journey_ProtoTavern_506").SetIndestructible(true);
	}
	void test_SE()
	{
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_SE_Spot"));
		m_Reference.SetTimerMS( TOnTimerEvent( @this.DwarvenAttack_Timer ), 100 );
	}
	void test_E()
	{
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_E_Spot"));
		m_Reference.SetTimerMS( TOnTimerEvent( @this.DwarvenAttack_Timer ), 100 );
	}
	void test_NE()
	{
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_NE_Spot"));
		m_Reference.SetTimerMS( TOnTimerEvent( @this.DwarvenAttack_Timer ), 100 );
	}
	void test_N()
	{
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_N_Spot"));
		m_Reference.SetTimerMS( TOnTimerEvent( @this.DwarvenAttack_Timer ), 100 );
	}
	void test_NW()
	{
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_NW_Spot"));
		m_Reference.SetTimerMS( TOnTimerEvent( @this.DwarvenAttack_Timer ), 100 );
	}
	void test_W()
	{
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_W_Spot"));
		m_Reference.SetTimerMS( TOnTimerEvent( @this.DwarvenAttack_Timer ), 100 );
	}
	void test_SW()
	{
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_SW_Spot"));
		m_Reference.SetTimerMS( TOnTimerEvent( @this.DwarvenAttack_Timer ), 100 );
	}
	void test_All()
	{
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_SE_Spot"));
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_E_Spot"));
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_NE_Spot"));
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_N_Spot"));
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_NW_Spot"));
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_W_Spot"));
		m_Reference.CastSpell("Journey_506_DwarvenWeakAttack", m_iDwarvenAttacks, m_Reference.GetLogicObjectByName("DwarvenAttack_SW_Spot"));
		m_Reference.SetTimerMS( TOnTimerEvent( @this.DwarvenAttack_Timer ), 100 );
	}
	void KillAttackers()
	{
		CreatureGroup _Grp_DwarvenAttackers = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iDwarvenAttacks));
		_Grp_DwarvenAttackers.Die(false);
	}
	void testSummon()
	{
		m_Reference.CastSpell("Journey_506_AirReinforcements_I", m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName("AirReinforcements_SpawnSpot"));
		m_Reference.CastSpell("Journey_506_GroundReinforcements_I", m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName("GroundReinforcements_SpawnSpot"));
	}
	void allDwarves()
	{
		m_Reference.CastSpell("Journey_506_AllDwarves", m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName("DwarvenAttack_SE_Spot"));
	}
	void setWavesDifficulty(string m_sDifficulty)
	{
		m_sAttackWavesDifficulty = m_sDifficulty;
	}
	void testRoyalArmy()
	{
		m_Reference.ActivateSpawn( "RoyalArmy_Spawn", true );
		CreatureGroup _Grp_RoyalArmy = CreatureGroup(m_Reference, m_Reference.GetCreaturesFromSpawn("RoyalArmy_Spawn"));
		_Grp_RoyalArmy.Move(m_Reference.GetBuildingByName("Journey_ProtoTavern_506"), false, true, false);
		m_Reference.SetTimer( TOnTimerEvent( @this.FinalQuestPart_Timer ), 3 );
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T  F U N C T I O N S ----------------------------------------------------------------------------------
	bool OnDestroyed_ProtoTavern(Building& in _Building)
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.LoseGame(m_Reference.GetPlayerFactions(true)[i]);
		}	
		
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_506, "HoldTheGroundFor30Mins", Failed);
		return true;
	}

	bool OnResourcesCollected_HostPlayer(Creature&in _Creature, Entity[]&in _Params)
	{
		string _sResourcePickup = m_Reference.FindEntityName(_Params[0]);
		UpdateQuestOnResourcePickup(_sResourcePickup);
		return false;
	}

	bool OnResourcesCollected_JoinedPlayer(Creature&in _Creature, Entity[]&in _Params)
	{
		string _sResourcePickup = m_Reference.FindEntityName(_Params[0]);
		UpdateQuestOnResourcePickup(_sResourcePickup);

		string _sDepositType = _sResourcePickup.substr(0,_sResourcePickup.findLast("_", -1));

		if(_sDepositType == "FoodDeposit")
		{
			m_Reference.AddGlobalResources(m_Reference.GetHostFaction(), Food, m_uResourceDepositCapacity);
		}
		else if(_sDepositType == "WoodDeposit")
		{
			m_Reference.AddGlobalResources(m_Reference.GetHostFaction(), Wood, m_uResourceDepositCapacity);
		}
		else if(_sDepositType == "StoneDeposit")
		{
			m_Reference.AddGlobalResources(m_Reference.GetHostFaction(), Brick, m_uResourceDepositCapacity);
		}
		else if(_sDepositType == "IronDeposit")
		{
			m_Reference.AddGlobalResources(m_Reference.GetHostFaction(), IronBar, m_uResourceDepositCapacity);
		}
		else if(_sDepositType == "CharcoalDeposit")
		{
			m_Reference.AddGlobalResources(m_Reference.GetHostFaction(), Charcoal, m_uResourceDepositCapacity);
		}
		else if(_sDepositType == "ScrapDeposit")
		{
			m_Reference.AddGlobalResources(m_Reference.GetHostFaction(), ScrapMetal, m_uResourceDepositCapacity);
		}

		return false;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- A R T I C Y  F U N C T I O N S --------------------------------------------------------------------------------

	void PlayerChoice_GroundReinforcements()
	{
		string _sReinforcementTier;
		m_ReinforcementsTier.get(m_sAttackWavesDifficulty, _sReinforcementTier);
		SummonGroundReinforcements(_sReinforcementTier);

		if (m_bFirstReinforcementsChoiceIsMade != true)
		{
			m_bFirstReinforcementsChoiceIsMade = true;
			for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			{
				m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("GroundReinforcements_SpawnSpot"));
			}
		}

		// handling reinforcements timers and tasks
		m_Reference.CreateCountdownTimer(0, m_iNextReinforcementTimer, TOnTimerEvent(@this.ReinforcementIsAvailable_Timer), m_Reference.GetHostFaction() , "Journey_506_TimeToNextReinforcement");
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_506, "ReinforcementsTimer", true);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_506, "AskForReinforcements", false);
		m_Reference.GetWorld().SetGlobalBool("Journey_CampaignVariables.Journey_506_Q0_bReinforcementsAvailable", false);
	}
	void PlayerChoice_AirReinforcements()
	{
		string _sReinforcementTier;
		m_ReinforcementsTier.get(m_sAttackWavesDifficulty, _sReinforcementTier);
		SummonAirReinforcements(_sReinforcementTier);
		
		if (m_bFirstReinforcementsChoiceIsMade != true)
		{
			m_bFirstReinforcementsChoiceIsMade = true;
			for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			{
				m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("AirReinforcements_SpawnSpot"));
			}
		}

		// handling reinforcements timers and tasks
		m_Reference.CreateCountdownTimer(0, m_iNextReinforcementTimer, TOnTimerEvent(@this.ReinforcementIsAvailable_Timer), m_Reference.GetHostFaction() , "Journey_506_TimeToNextReinforcement");
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_506, "ReinforcementsTimer", true);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_506, "AskForReinforcements", false);
		m_Reference.GetWorld().SetGlobalBool("Journey_CampaignVariables.Journey_506_Q0_bReinforcementsAvailable", false);
	}

	bool ReinforcementIsAvailable_Timer()
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_506, "ReinforcementsTimer", false);
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_506, "AskForReinforcements", true);
		m_Reference.GetWorld().SetGlobalBool("Journey_CampaignVariables.Journey_506_Q0_bReinforcementsAvailable", true);

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
			JourneyExplorationShoutout(m_Reference.GetHeroParty(_arrJoinedPlayers[0]).GetMembers()[0], "Journey_506_SO_AvailableReinforcementsHint");
		}
		else if (_arrJoinedPlayers.length() == 2)
		{
			uint _uRandom = m_Reference.GetRandom().GetInteger(0, 1);
			JourneyExplorationShoutout(m_Reference.GetHeroParty(_arrJoinedPlayers[_uRandom]).GetMembers()[0], "Journey_506_SO_AvailableReinforcementsHint");
		}
		else if (_arrJoinedPlayers.length() == 0)
		{
			JourneyExplorationShoutout(m_Reference.GetCreatureById(m_iHostAvatarId), "Journey_506_SO_AvailableReinforcementsHint");
		}
		return true;
	}

	void ReturnCamera()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetCreatureByName(m_sClaraFarlorn));
		}
	}

	void ActivateResourcePickupsSQ()
	{
		m_Reference.GetSharedJournal().ActivateQuest(m_sSideQuest_506, true);
	}

	void StartRTS()
	{
		m_Reference.GetSectorByName("Sector_01").SetOwner(m_Reference.GetHostFaction());
		m_Reference.GetSectorByName("Sector_03").CreateCapital(m_Reference.GetHostFaction(), true, true);
		m_Reference.SetBaseSupply(m_Reference.GetHostFaction(), uint(60));

		// setting quest timer
		m_Reference.CreateCountdownTimer(0, m_iTimeBeforeRoyalArmyArrives, TOnTimerEvent(@this.RoyalArmyArrives), m_Reference.GetHostFaction() , "Journey_506_RoyalArmyArrives");
		// Timer to trigger a chekpoint
		m_Reference.SetTimer(TOnTimerEvent(@this.Checkpoint_Timer), m_iTimeBeforeRoyalArmyArrives/2);

		// setting difficulty increase timer, used for increasing reinforcements tier
		m_Reference.SetTimer( TOnTimerEvent( @this.SetMediumDifficultyWaves_Timer ), m_iMediumDifficultyWavesTimer );
		m_Reference.SetTimer( TOnTimerEvent( @this.SetHardDifficultyWaves_Timer ), m_iHardDifficultyWavesTimer );

		// setting timed wave attacks
		// giving some extra preperation time
		m_Reference.SetTimer( TOnTimerEvent( @this.SummonAttackWaves_Timer ), m_WaveBalancing.m_uRecurringWavesTimer[uint(m_Reference.GetDifficulty())] + 180 );
	}

	void PlayerSkippedMapIntro()
	{
		ActivateResourcePickupsSQ();
		StartRTS();
	}

	void CompleteResourcePickupsSideQuest()
	{
		m_Reference.GetSharedJournal().SetTaskState(m_sSideQuest_506, "ReportBackToClaraFarlorn", Completed);
	}

	void FailResourcePickupsSideQuest()
	{
		m_Reference.GetSharedJournal().SetQuestState(m_sSideQuest_506, Failed);
	}

	// -------------------------------------------------------------------------------------------------------------------

	bool Checkpoint_Timer()
	{
		CheckpointReached();
		return true;
	}

	bool SummonAttackWaves_Timer()
	{
		array<uint8> _arrPlayerFactions = m_Reference.GetPlayerFactions(true);
		for(uint i = 0; i < _arrPlayerFactions.length(); ++i)
		{
			m_Reference.BeginNotification(_arrPlayerFactions[i], "BanditsApproaching", m_Reference.GetCreatureByName(m_sClaraFarlorn));
		}
		m_iAttacksSummoned++;
		SendWaves(m_uCurrentWave);
		if (m_bRoyalArmyArrived != true)
		{
			m_Reference.SetTimer( TOnTimerEvent( @this.SummonAttackWaves_Timer ), m_WaveBalancing.m_uRecurringWavesTimer[uint(m_Reference.GetDifficulty())] );
		}
		else
		{
			print("Royal army arrived, no more attacks will be summoned. In total " + m_iAttacksSummoned + " attacks were summoned.");
		}
		return true;
	}

	bool DwarvenAttack_Timer()
	{
		CreatureGroup _Grp_DwarvenAttackers = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iDwarvenAttacks));
		_Grp_DwarvenAttackers.AttackPosition(m_Reference.GetBuildingByName("Journey_ProtoTavern_506"), false, false);
		return true;
	}

	// Used for increasing players' reinforcements tier
	bool SetMediumDifficultyWaves_Timer()
	{
		m_sAttackWavesDifficulty = "Medium";
		return true;
	}
	bool SetHardDifficultyWaves_Timer()
	{
		m_sAttackWavesDifficulty = "Hard";
		return true;
	}

	bool RoyalArmyArrives()
	{
		m_bRoyalArmyArrived = true;
		m_Reference.CastSpell("Journey_506_RoyalArmyReinforcements_Summon", m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName("RoyalArmySummon_Spot"));
		m_Reference.SetTimerMS(TOnTimerEvent(@this.MoveRoyalArmy_Timer), 300);

		// Summoning last attack wave and updating quest on a timer
		SendWaves(Wave(array<SubWave> = {SubWave(m_WaveBalancing.FinalWave, m_WaveBalancing.m_sN_Spot)}));
		m_Reference.SetTimer( TOnTimerEvent( @this.FinalQuestPart_Timer ), 3 );
		return true;
	}

	bool MoveRoyalArmy_Timer()
	{
		CreatureGroup _Grp_RoyalArmy = CreatureGroup(m_Reference, m_Reference.FindCreaturesInArea("RoyalArmySummon_Area"));
		_Grp_RoyalArmy.Move(m_Reference.GetBuildingByName("Journey_ProtoTavern_506"), false, true, false);
		return true;
	}

	bool FinalQuestPart_Timer()
	{
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_506, "HoldTheGroundFor30Mins", Completed);
		uint _iEnemiesLeft = GetLivingCreaturesByFaction(m_iDwarvenAttacks).length();
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_506_Q0_iEnemiesToKill", _iEnemiesLeft);
		m_Reference.RegisterCreatureEventByIndividuals(Killed, TOnCreatureEvent(@this.OnRemainingEnemyKilled_CheckQuest), GetLivingCreaturesByFaction(m_iDwarvenAttacks), true, "");
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("RoyalArmyArrival_Spot"));
		}

		JourneyExplorationShoutout(GetRandomJourneyHero(), "Journey_506_SO_RoyalArmyArrived");
		return true;
	}

	bool OnRemainingEnemyKilled_CheckQuest(Creature &in _Creature)
	{
		m_iRemainingEnemiesKilled =  m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_506_Q0_iEnemiesKilled", 0)+ 1;
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_506_Q0_iEnemiesKilled", m_iRemainingEnemiesKilled);
		if(m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_506_Q0_iEnemiesKilled", 0) >= m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_506_Q0_iEnemiesToKill", 0))
		{
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_506, "EnemiesLeftToKill", Completed);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_506, "KillRemainingEnemies", Completed);
			m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_506, "ReinforcementsTimer", false);
			m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_506, "AskForReinforcements", false);
			m_Reference.CancelTimer(TOnTimerEvent(@this.ReinforcementIsAvailable_Timer));

			JourneyExplorationShoutout(_Creature, "Journey_506_SO_ReportToQuestGiver", false, false, false, true);

			// Changing Everlight weather
			SetEverlightWeather();

			return true;
		}
		return false;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- C U S T O M  F U N C T I O N S ---------------------------------------------------------------------------------

	void SummonGroundReinforcements(string _sReinforcementTier)
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
			m_Reference.CastSpell("Journey_506_GroundReinforcements_" + _sReinforcementTier, _arrJoinedPlayers[0], m_Reference.GetLogicObjectByName("GroundReinforcements_SpawnSpot"));
		}
		else if (_arrJoinedPlayers.length() == 2)
		{
			m_Reference.CastSpell("Journey_506_ShortenedGroundReinforcements_" + _sReinforcementTier, _arrJoinedPlayers[0], m_Reference.GetLogicObjectByName("GroundReinforcements_SpawnSpot"));
			m_Reference.CastSpell("Journey_506_ShortenedGroundReinforcements_" + _sReinforcementTier, _arrJoinedPlayers[1], m_Reference.GetLogicObjectByName("GroundReinforcements_SpawnSpot"));
		}
		else if (_arrJoinedPlayers.length() == 0)
			m_Reference.CastSpell("Journey_506_GroundReinforcements_" + _sReinforcementTier, m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName("GroundReinforcements_SpawnSpot"));
	}

	void SummonAirReinforcements(string _sReinforcementTier)
	{
		array<uint> _arrJoinedPlayers;
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			if (m_Reference.GetPlayerFactions(true)[i] != m_Reference.GetHostFaction())
				_arrJoinedPlayers.insertLast(m_Reference.GetPlayerFactions(true)[i]);

		if (_arrJoinedPlayers.length() == 1)
		{
			m_Reference.CastSpell("Journey_506_AirReinforcements_" + _sReinforcementTier, _arrJoinedPlayers[0], m_Reference.GetLogicObjectByName("AirReinforcements_SpawnSpot"));
		}
		else if (_arrJoinedPlayers.length() == 2)
		{
			m_Reference.CastSpell("Journey_506_ShortenedAirReinforcements_" + _sReinforcementTier, _arrJoinedPlayers[0], m_Reference.GetLogicObjectByName("AirReinforcements_SpawnSpot"));
			m_Reference.CastSpell("Journey_506_ShortenedAirReinforcements_" + _sReinforcementTier, _arrJoinedPlayers[1], m_Reference.GetLogicObjectByName("AirReinforcements_SpawnSpot"));
		}
		else if (_arrJoinedPlayers.length() == 0)
			m_Reference.CastSpell("Journey_506_AirReinforcements_" + _sReinforcementTier, m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName("AirReinforcements_SpawnSpot"));
	}

	void CheckWavesForCurrentDifficulty()
	{
		uint _uBalancedWavesNum = m_WaveBalancing.WavesByDifficulty[uint(m_Reference.GetDifficulty())].length();
		uint _uWavesByTimer = m_iTimeBeforeRoyalArmyArrives/m_WaveBalancing.m_uRecurringWavesTimer[uint(m_Reference.GetDifficulty())];
		if(_uWavesByTimer == _uBalancedWavesNum)
		{
			print("Waves are set correctly in the balancing script. On current difficulty players have to survive "+_uBalancedWavesNum+" waves.");
		}
		else
		{
			print("WAVES AREN'T SET CORRECTLY. By timer players should survive "+_uWavesByTimer+" waves, but there are "+_uBalancedWavesNum+" waves balanced for this difficulty in the balancing script.");
		}
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- W A V E   S P A W N   S T U F F -------------------------------------------------------------------------------
	
	void SendWaves(uint _currentWave)
	{
		uint _uWaveNum = m_uCurrentWave+1;
		print("Sending Wave: " + _uWaveNum);
		Wave tempWave;
		if(_currentWave >= 0 && _currentWave < m_WaveBalancing.WavesByDifficulty[uint(m_Reference.GetDifficulty())].length())
		{
			tempWave =	m_WaveBalancing.WavesByDifficulty[uint(m_Reference.GetDifficulty())][m_uCurrentWave];
		}
		else if(_currentWave >= 0)
		{
			/*	---------------------------------------------------------------
			*	Even if we pass an index that exceeds a length of waves array, 
			*	we should still spawn a wave because it may be a result of 
			*	players changing difficulty
			*	---------------------------------------------------------------
			*/
			uint _uWaveIndex = m_uCurrentWave % m_WaveBalancing.WavesByDifficulty[uint(m_Reference.GetDifficulty())].length();
			tempWave =	m_WaveBalancing.WavesByDifficulty[uint(m_Reference.GetDifficulty())][_uWaveIndex];
			print("Tried to spawn a wave of invalid index! A wave with index "+_uWaveIndex+" will be summoned instead.");
		}
		else
		{
			print("Negative wave Index!");
		}

		uint numOfSubWave = tempWave.GetNumberOfSubWaves();
		for (uint i = 0; i < numOfSubWave; ++i)
		{
			SubWave tempSubWave = tempWave.GetSubWave(i);
			SendSingleWave(tempSubWave);
		}
		m_Reference.SetTimerMS(TOnTimerEvent(@this.DwarvenAttack_Timer), 100);
		++m_uCurrentWave;
	}
	void SendWaves(Wave _waveData)
	{
		uint numOfSubWave = _waveData.GetNumberOfSubWaves();
		for (uint i = 0; i < numOfSubWave; ++i)
		{
			SubWave tempSubWave = _waveData.GetSubWave(i);
			SendSingleWave(tempSubWave);
		}
		m_Reference.SetTimerMS(TOnTimerEvent(@this.DwarvenAttack_Timer), 100);
	}

	void SendSingleWave(SubWave _subWave)
	{
		array<ESummonType> tempWave;
		string tempSpawnSpot = GetSpawnSpot(_subWave.SpawnLocation);

		if(_subWave.Type == Special)
		{
			tempWave = _subWave.SpecialWave;
		} else
		{
			tempWave = CreateWave(_subWave.Budget, _subWave.Type);
		}

		for (uint i = 0; i < tempWave.length(); ++i)
		{
			SpawnUnit(tempWave[i], tempSpawnSpot);
		}
		print("Spawning Wave at " + tempSpawnSpot);
		print("Budget is: " + _subWave.Budget);
		print("WaveType is: " + _subWave.Type);
	}

	string GetSpawnSpot(string&in _Location)
	{
		if(_Location == "") 
		{
			int tempSelector = m_Reference.GetRandom().GetInteger(0, 6);
			switch(tempSelector)
			{
				case 0:
					return m_WaveBalancing.m_sSE_Spot;
				case 1:
					return m_WaveBalancing.m_sE_Spot;
				case 2:
					return m_WaveBalancing.m_sNE_Spot;
				case 3:
					return m_WaveBalancing.m_sN_Spot;
				case 4:
					return m_WaveBalancing.m_sNW_Spot;
				case 5:
					return m_WaveBalancing.m_sW_Spot;
				default:
					return m_WaveBalancing.m_sSW_Spot;
			}
		}
		return _Location;
	}

	void SpawnUnit(ESummonType _spawnType, string _locationName)
	{
		string tempSpellName = "";
		switch(_spawnType)
		{
			case MoleRider:
				tempSpellName = m_sSummon_MoleRider;
				break;
			case Axewielder:
				tempSpellName = m_sSummon_Axewielder;
				break;
			case DwarfSentry:
				tempSpellName = m_sSummon_DwarfSentry;
				break;
			case EarthShaper:
				tempSpellName = m_sSummon_EarthShaper;
				break;
			case Berserker:
				tempSpellName = m_sSummon_Berserker;
				break;
			case Pyromancer:
				tempSpellName = m_sSummon_Pyromancer;
				break;
			case CombatBalloon:
				tempSpellName = m_sSummon_CombatBalloon;
				break;
			case FireGolem:
				tempSpellName = m_sSummon_FireGolem;
				break;
			case BanditHealer:
				tempSpellName = m_sSummon_BanditHealer;
				break;
		}
		m_Reference.CastSpell(tempSpellName, m_iDwarvenAttacks, m_Reference.GetLogicObjectByName(_locationName));
	}

	array<ESummonType> CreateWave(uint _waveTotalCost, EWaveType _waveType = None)
	{
		array<ESummonType> results;

		uint CheapBudget = 0;
		uint NormalBudget = 0;
		uint ExpensiveBudget = 0;

		switch(_waveType)
		{
			case Cheap:
				CheapBudget = _waveTotalCost;
				break;
			case MixWave:
				NormalBudget = uint(float(_waveTotalCost) / 2.0f);
				CheapBudget = _waveTotalCost - NormalBudget;
				break;
			case Expensive:
				ExpensiveBudget = uint(float(_waveTotalCost) / 3.0f);
				NormalBudget = _waveTotalCost - 2 * ExpensiveBudget;
				CheapBudget = _waveTotalCost - NormalBudget;
				break;
			default:
				break;
		}

		uint currentCost = 0;
		// Add Cheap Units
		while(currentCost < CheapBudget)
		{
			ESummonType tempUnitType = None;
			currentCost = currentCost + GetCheapUnit(tempUnitType);
			results.insertLast(tempUnitType);
		}

		currentCost = 0;
		// Add Normal Units (we can restrict number of certain units to spawn here)
		while(currentCost < NormalBudget)
		{
			ESummonType tempUnitType = None;
			currentCost = currentCost + GetNormalUnit(tempUnitType);
			results.insertLast(tempUnitType);
		}

		currentCost = 0;
		// Add Expensive Units
		while(currentCost < ExpensiveBudget)
		{
			ESummonType tempUnitType = None;
			currentCost = currentCost + GetExpensiveUnit(tempUnitType);
			results.insertLast(tempUnitType);
		}
		return results;
	}

	uint GetCheapUnit(ESummonType &out _unitType)
	{
		int temp = m_Reference.GetRandom().GetInteger(0, 99);
		if(temp  < 10)
		{
			// MoleRider
			_unitType = MoleRider;
			return m_WaveBalancing.m_uUnitCost[MoleRider];
		} else if(temp < 50)
		{
			// Axewielder
			_unitType = Axewielder;
			return m_WaveBalancing.m_uUnitCost[Axewielder];
		} else 
		{
			// DwarfSentry
			_unitType = DwarfSentry;
			return m_WaveBalancing.m_uUnitCost[DwarfSentry];
		}
	}

	uint GetNormalUnit(ESummonType &out _unitType)
	{
		int temp = m_Reference.GetRandom().GetInteger(0, 99);
		
		// slightly favor against earthshaper, towards bandithealer
		if(temp < 20)
		{
			// EarthShaper
			_unitType = EarthShaper;
			return m_WaveBalancing.m_uUnitCost[EarthShaper];
		} else if(temp < 50)
		{
			// Berserker
			_unitType = Berserker;
			return m_WaveBalancing.m_uUnitCost[Berserker];
		} else if(temp < 70)
		{
			// Pyromancer
			_unitType = Pyromancer;
			return m_WaveBalancing.m_uUnitCost[Pyromancer];
		}
		 else 
		{
			// BanditHealer
			_unitType = BanditHealer;
			return m_WaveBalancing.m_uUnitCost[BanditHealer];
		}
	}

	uint GetExpensiveUnit(ESummonType &out _unitType)
	{
		int temp = m_Reference.GetRandom().GetInteger(0, 99);

		// slightly favor towards combatballoon
		if(temp < 60)
		{
			// CombatBalloon
			_unitType = CombatBalloon;
			return m_WaveBalancing.m_uUnitCost[CombatBalloon];
		}
		{
			// FireGolem
			_unitType = FireGolem;
			return m_WaveBalancing.m_uUnitCost[FireGolem];
		}
	}
}
