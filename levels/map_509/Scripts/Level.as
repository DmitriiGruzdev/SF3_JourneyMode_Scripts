// includes:
#include "../../basicScripts/Journey_LevelBase.as"

class Level: Journey_LevelBase
{

	// --------------------------------------------------------------------------------------------------------------------
	// --- Member Variables -----------------------------------------------------------------------------------------------

	// Used in map intros/outros
	string m_sChiefGuard = "Journey_WindholmeChiefGuard_509";
	string m_sMapIntroTopic = "Journey_509_WindholmeChiefGuard_MapIntro";

	// count this version-number up. This is for later version tracking, when the QA plays the map. 
	string m_Version_Level = "QA hasn't played the map yet";

	// --- Factions -----------------------------------------------------------------------------------------------------------
	uint8 m_i0_PlayerFaction = 				0;
	uint8 m_i1_PlayerFaction = 				1;
	uint8 m_i2_PlayerFaction = 				2;
	uint8 m_iHostages = 				    3;
	uint8 m_iElvenHeisters = 				4;
	uint8 m_iWindholmeGuard = 				5;
	uint8 m_iElvenHeisters_Boss = 			6;

	// Quests
	string m_sMainQuest_509 = "Journey_509_Q0_SaveHostages";

	string m_sQuestItem = "Journey_DwarvenRescueDevice_509";

	string m_sBossHeister = "Journey_BossHeister_509";

	array<string> m_arrSightBlockers =
	{
		"SightBlocker_1",
		"SightBlocker_2",
		"SightBlocker_3",
		"SightBlocker_4",
		"SightBlocker_5",
		"SightBlocker_6",
		"SightBlocker_7",
		"SightBlocker_8",
		"SightBlocker_9",
		"SightBlocker_10",
		"SightBlocker_11",
		"SightBlocker_12",
		"SightBlocker_13",
		"SightBlocker_14",
		"SightBlocker_15",
		"SightBlocker_16",
		"SightBlocker_17",
		"SightBlocker_18",
		"SightBlocker_19",
		"SightBlocker_20"
	};

	array<string> m_arrVaultDoors =
	{
		"VaultDoor_1",
		"VaultDoor_2",
		"VaultDoor_3",
		"VaultDoor_4",
		"VaultDoor_5"
	};

	dictionary m_TransitionSwitch_TransitionSpot =
	{
		{"TreasuryEntrance_Switch", "TreasuryEntrance_Spot"},
		{"ToUpperLevel_Switch_1", "UpperLevel_Spot_1"},
		{"ToLowerLevel_Switch_1", "LowerLevel_Spot_1"},
		{"ToUpperLevel_Switch_2", "UpperLevel_Spot_2"},
		{"ToLowerLevel_Switch_2", "LowerLevel_Spot_2"},
		{"ToUpperLevel_Switch_3", "UpperLevel_Spot_3"},
		{"ToLowerLevel_Switch_3", "LowerLevel_Spot_3"},
		{"ToUpperLevel_Switch_4", "UpperLevel_Spot_4"},
		{"ToLowerLevel_Switch_4", "LowerLevel_Spot_4"},
		{"ToUpperLevel_Switch_5", "UpperLevel_Spot_5"},
		{"ToLowerLevel_Switch_5", "LowerLevel_Spot_5"},
		{"ToUpperLevel_Switch_6", "UpperLevel_Spot_6"},
		{"ToLowerLevel_Switch_6", "LowerLevel_Spot_6"},
		{"ToUpperLevel_Switch_7", "UpperLevel_Spot_7"},
		{"ToLowerLevel_Switch_7", "LowerLevel_Spot_7"},
		{"ToUpperLevel_Switch_8", "UpperLevel_Spot_8"},
		{"ToLowerLevel_Switch_8", "LowerLevel_Spot_8"},
		{"ToUpperLevel_Switch_9", "UpperLevel_Spot_9"},
		{"ToLowerLevel_Switch_9", "LowerLevel_Spot_9"},
		{"ToUpperLevel_Switch_10", "UpperLevel_Spot_10"},
		{"ToLowerLevel_Switch_10", "LowerLevel_Spot_10"}
	};

	dictionary m_Vault_Hostages = {};

	array<string> m_arrVaults =
	{
		"Vault_1",
		"Vault_2",
		"Vault_3",
		"Vault_4",
		"Vault_5"
	};

	array<string> m_arrGodstones =
	{
		"BossArena1_Godstone",
		"BossArena2_Godstone",
		"BossArena3_Godstone"
	};

	array<string> m_arrTransitionSwitches = m_TransitionSwitch_TransitionSpot.getKeys();

	uint m_iMageHeistersNum = 7;

	dictionary m_BossArenasWithAoE =
	{
		{"BossArena1", false},
		{"BossArena2", false},
		{"BossArena3", false}
	};

	dictionary m_BossArenasSizes =
	{
		{"BossArena1", array<uint> = {9, 8}},
		{"BossArena2", array<uint> = {5, 8}},
		{"BossArena3", array<uint> = {10, 6}}
	};

	string[][] m_sBossArena1_TargetMarkers;
	string[][] m_sBossArena2_TargetMarkers;
	string[][] m_sBossArena3_TargetMarkers;

	dictionary m_BossArenasTargetMarkers =
	{
		{"BossArena1", m_sBossArena1_TargetMarkers},
		{"BossArena2", m_sBossArena2_TargetMarkers},
		{"BossArena3", m_sBossArena3_TargetMarkers}
	};

	// Boss fight timers
	uint m_uAoEEffectDurationMin = 20;
	uint m_uAoEEffectDurationMax = 40;
	uint m_uAoESpellCastDuartionMS = 5000;

	string m_sCurrentArenaWithBoss;

	bool m_bFirstAoECasted = false;
	bool m_bBossIsCastingAoE = false;
	bool m_bBossIsTeleportingWithinArena = false;
	bool m_bHitByFreezeAOE_ShoutoutReady = true;

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
		// Registering events for transition between upper and lower levels
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			for (uint j = 0; j < m_arrTransitionSwitches.length(); j++)
			{
				m_Reference.RegisterHeroPartyEvent(Interact, TOnHeroPartyExtendedEvent(@this.OnInteract_SwitchTransition), m_arrTransitionSwitches[j], m_Reference.GetPlayerFactions(true)[i]);
			}
		}

		// Registering events for disabling of vault doors
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			for (uint j = 0; j < m_arrVaultDoors.length(); j++)
			{
				m_Reference.RegisterHeroPartyEvent(Interact, TOnHeroPartyExtendedEvent(@this.OnInteract_DisableDoor), m_arrVaultDoors[j], m_Reference.GetPlayerFactions(true)[i]);
			}
		}

		Creature[] _MageHeisters = m_Reference.FindCreaturesByDescription(m_iElvenHeisters, "Journey_MageHeister_509");
		m_Reference.RegisterCreatureEventByIndividuals(CanSee, TOnCreatureEvent(@this.OnCanSeeOrDamaged_ExplodeHostages), _MageHeisters, true, "Enemy");
		m_Reference.RegisterCreatureEventByIndividuals(Damaged, TOnCreatureEvent(@this.OnCanSeeOrDamaged_ExplodeHostages), _MageHeisters, true, "");

		// event for chief windholme guard to cheat death
		m_Reference.RegisterCreatureEventByIndividual(Damaged, TOnCreatureEvent(@this.OnLowHP_Heal), m_sChiefGuard, "");

		// blocking treasury entrace before players spoke to the chief guard
		m_Reference.BlockNavMesh("NavBlocker_TreasuryEntrance", true );
		m_Reference.BlockNavMesh("TreasuryGate_Blocker", true );
		// handling windholme chief guard
		m_Reference.GetCreatureByName(m_sChiefGuard).SetImmovable(true);
	}

	/*
		Is called right at the beginning of the level. Should only be used to start a dialoge, or directly stage an event and so on.
	*/
	void InitCommon ()
	{
		ActivateRandomLoot(100);

		m_Reference.GetBuildingByName("Entrance_Godstone").SetFaction(m_Reference.GetHostFaction());

		// Preventing navmesh bugs while telporting betwen higher and lower levels
		array<LogicObject>@ _NavBlockers = m_Reference.FindLogicObjectsByPrefix("TeleportNavBlocker_");
		for (uint i = 0; i < _NavBlockers.length(); ++i)
		{
			string _sNavBlocker = m_Reference.FindEntityName(_NavBlockers[i]);
			m_Reference.BlockNavMesh(_sNavBlocker, true);
		}

		// Disabling autoattacks for players' heroes for stealth gameplay
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.GetHeroParty(m_Reference.GetPlayerFactions(true)[i]).EnableAutoAttacks(false);
		}

		// event that triggers new patrols
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.RegisterHeroPartyEvent(AnyInside, TOnHeroPartyEvent(@this.OnTriggerEnter_EventPatrols), "Trigger_EventPatrols", m_Reference.GetPlayerFactions(true)[i]);
		}
		
		// disabling gate explosion FX
		m_Reference.GetLogicObjectByName("GateExplosionFX").Enable(false);

		// Handling boss arenas
		array <string> _arrkeys = m_BossArenasWithAoE.getKeys();
		for(uint i = 0; i < _arrkeys.length(); ++i)
		{
			m_Reference.EnableGroup(_arrkeys[i]+"_AoEFX", false, false);	
		}

		// Handling boss
		Creature _Boss = m_Reference.GetCreatureByName(m_sBossHeister);
		m_Reference.EnableGroup("IceWallsFX_BossArena", false, false);
		_Boss.SetImmovable(true);
		_Boss.PlayAnimation(m_Reference, KneelLoop, -1, uint(-1), true, false, Entity (m_Reference.GetLogicObjectByName("BossArena1_BossTeleportSpot")), false, false, false);

		// Handling hostages
		SetupHostages();
		// Resetting quest global var
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_509_iSavedHostages", 0);

		// Filling up arrays of logic objects names used for spells targeting in the boss fight
		FillBossFightMarkerArray();

		SetupIntroCreatures(m_sChiefGuard, m_sMapIntroTopic);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- CUSTOM FUNCTIONS AND EVENTS ----------------------------------------------------------------------------------

	void PlayersSpotted()
	{
		for (uint i = 0; i < m_arrSightBlockers.length(); ++i)
			m_Reference.GetLogicObjectByName(m_arrSightBlockers[i]).SetSightBlocking(false);
	}

	void ActivateSightBlockers()
	{
		for (uint i = 0; i < m_arrSightBlockers.length(); ++i)
			m_Reference.GetLogicObjectByName(m_arrSightBlockers[i]).SetSightBlocking(true);
	}

	void SightState()
	{
		bool _bSightBlocking = m_Reference.GetLogicObjectByName(m_arrSightBlockers[0]).IsSightBlocking();
		print("Current sight blocking state: "+_bSightBlocking);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T  F U N C T I O N S ---------------------------------------------------------------------------------- 

	// Transitions between upper and lower levels
	bool OnInteract_SwitchTransition(Creature& in _Creature, Entity[]&in _Params)
	{
		uint _uInteractedCreatureId = _Creature.GetId();
		uint _uFaction = _Creature.GetFaction();
		string _sUsedSwitch = m_Reference.FindEntityName(_Params[0]);
		string _sTransitionSpot;
		m_TransitionSwitch_TransitionSpot.get(_sUsedSwitch, _sTransitionSpot);
		Creature[] _Heroes = m_Reference.GetHeroParty(_uFaction).GetMembers();
		CreatureGroup _HeroesToTeleport = CreatureGroup(m_Reference);
		for (uint i = 0; i < _Heroes.length(); ++i)
		{
			uint _uId = _Heroes[i].GetId();
			if(m_Reference.GetEntityDistance(_uInteractedCreatureId, _uId) < 50)
			{
				_HeroesToTeleport.Add(_Heroes[i]);
			}
		}
		_HeroesToTeleport.Teleport( m_Reference.GetLogicObjectByName(_sTransitionSpot), false );
		if(_sTransitionSpot == "TreasuryEntrance_Spot")
		{
			m_Reference.FocusCamera(_uFaction, m_Reference.GetLogicObjectByName(_sTransitionSpot));
		}

		return false;
	}

	// Mage heister explodes hostages when sees players' party
	bool OnCanSeeOrDamaged_ExplodeHostages( Creature &in _Creature )
	{
		string _sMageHeisterName = m_Reference.FindEntityName(_Creature);
		/*	-----------------------------------------------------------
		*	Now all mages will say this shoutout on seeing a player. 
		*	Depending on what we do with stealth there are different
		*	ways to tackle this issue, the easiest is to Unregister the event.
		*	-----------------------------------------------------------
		*/
		JourneyDialogShoutout(_sMageHeisterName, _Creature.GetDescriptionName(), "Journey_509_SO_HeisterSpotsPlayer");
		m_Reference.SetTimerMS( TOnTimerUserDataEvent(@this.CastExplodeHostagesSpell_Timer), 300, _sMageHeisterName );
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			Creature[] Heroes = m_Reference.GetHeroParty(_uFaction).GetMembers();
			for (uint j = 0; j < Heroes.length(); ++j)
			{
				if(_Creature.CanSee(m_Reference, Heroes[j]))
				{
					_Creature.PlayAnimation(m_Reference, ChannelSpellEnter, -1, 300, false, false, Entity(Heroes[j]), false, false, false);
					m_Reference.PlaySound(uint8(-1), uint8(-1), "events/events_lc1_cave_alarm");
				}
			}
		}

		return false;
	}
	bool CastExplodeHostagesSpell_Timer(const string& in _sMageHeisterName)
	{
		m_Reference.GetCreatureByName(_sMageHeisterName).ForceCast(m_Reference, "Journey_509_ExplodeHostages", m_Reference.GetCreatureByName(_sMageHeisterName), false);
		m_Reference.RegisterCreatureEventByIndividual( SpellCast, TOnCreatureEvent( @this.OnSpellCasted_ExplodeHostages ), _sMageHeisterName, "" );
		// Showing what mage heister spotted players
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetCreatureByName(_sMageHeisterName));
		return true;
	}
	bool OnSpellCasted_ExplodeHostages( Creature &in _Creature )
	{
		uint iVaultsWithHostages;
		array<string> _arrVaultsWithHostages;
		for (uint i = 0; i < m_arrVaults.length(); ++i)
		{
			uint _iHostagesInVault;
			m_Vault_Hostages.get(m_arrVaults[i], _iHostagesInVault);
			if(_iHostagesInVault > 0)
			{
				_arrVaultsWithHostages.insertLast(m_arrVaults[i]);	
			}
		}
		iVaultsWithHostages = _arrVaultsWithHostages.length();
		print(iVaultsWithHostages+" vaults still have hostages");
		uint _uRandomIndex = m_Reference.GetRandom().GetInteger( 0, _arrVaultsWithHostages.length());
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("CameraSpot_"+_arrVaultsWithHostages[_uRandomIndex]));
		// Exploding all barrels
		for (uint i = 0; i < 5; ++i)
			m_Reference.CastSpell("BarrelExplosion_Medium", m_iElvenHeisters, m_Reference.GetLogicObjectByName("CameraSpot_Vault_"+(i+1)));
		m_Reference.GetSharedJournal().SetQuestState(m_sMainQuest_509, Failed);
		return true;
	}

	// Disabling vault doors on interaction and triggering hostages' reactions
	bool OnInteract_DisableDoor(Creature& in _Creature, Entity[]& in _Params)
	{
		if( _Params.length() != 0 )
		{
			_Params[0].SetInteractive( false );
		}

		string _sDoor = m_Reference.FindEntityName(_Params[0]);
		m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.HostageAsksForRescue_Timer), 1200, _sDoor);

		return false;
	}

	bool HostageAsksForRescue_Timer(const string& in _sDoor)
	{
		string _uVaultNum = _sDoor.substr(_sDoor.findFirst("_", 0)+1, 1);
		Creature[] _Hostages = m_Reference.FindCreaturesByPrefix("Journey_Dwarven_Hostage");
		Creature[] _HostagesToSpeak = {};
		for (uint i = 0; i < _Hostages.length(); ++i)
		{
			if(IsCreatureInsideArea(_Hostages[i], "Vault_"+_uVaultNum))
			{
				_HostagesToSpeak.insertLast(_Hostages[i]);
			}
		}

		uint _uRandom = m_Reference.GetRandom().GetInteger(0, _HostagesToSpeak.length());
		string _sSpeaker = m_Reference.FindEntityName(_HostagesToSpeak[_uRandom]);
		string _sContainerName = _HostagesToSpeak[_uRandom].GetDescriptionName();
		JourneyDialogShoutout(_sSpeaker, _sContainerName, "Journey_509_SO_HostageAsksForRescue");
		_HostagesToSpeak.removeAt(_uRandom);

		return true;
	}

	// Freeing hostages on interaction with players' parties
	bool OnInteract_Hostage(Creature& in _Creature, Entity[]&in _Params)
	{
		Creature _InteractedHostage = Creature(_Params[0]);
		string _sInteractedHostageName = m_Reference.FindEntityName(_InteractedHostage);
		// Timed action should be increased if we want an avatar to say their lines in "Journey_509_SO_HostageThanksForRescue"
		_Creature.StartTimedAction(m_Reference, HelpUp, 3000, _InteractedHostage, 1, false, false, false);
		m_Reference.RegisterCreatureEventByIndividual(TimedActionFinished, TOnCreatureExtendedEvent(@this.OnTimedActionFinished_FreeHostage), m_Reference.FindEntityName(_Creature), _sInteractedHostageName);

		// Hostage will play a shoutout with certain probability, so players will listen to less simillar lines. Maybe it'll be ok if SOs will just always play
		uint _uShoutoutChance = m_Reference.GetRandom().GetInteger(0, 99);
		uint _uShoutoutChanceThreshold = 50;
		print("_uShoutoutChance: "+_uShoutoutChance);
		if(_uShoutoutChance <= _uShoutoutChanceThreshold)
		{
			JourneyDialogShoutout(_sInteractedHostageName, _InteractedHostage.GetDescriptionName(), "Journey_509_SO_HostageThanksForRescue");
		}
		return false;
	}
	bool OnTimedActionFinished_FreeHostage(Creature& in _Creature, Entity[]&in _Params)
	{
		uint _uHostagesSaved = m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_509_iSavedHostages", 0) +1;
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_509_iSavedHostages", _uHostagesSaved);

		string _sInteractedHostageName = m_Reference.FindEntityName(_Params[0]);
		Creature _InteractedHostage = m_Reference.GetCreatureByName(_sInteractedHostageName);
		_InteractedHostage.PlayAnimation(m_Reference, Cheering, -1, uint(-1), true, false, Entity (), false, false, false);
		m_Reference.CastSpell("Journey_509_TeleportHostage", m_iHostages, _InteractedHostage);
		m_Reference.SetTimerMS( TOnTimerUserDataEvent(@this.TeleportHostage_Timer), 1500, _sInteractedHostageName );
		return true;
	}
	bool TeleportHostage_Timer(const string& in _sInteractedHostageName)
	{
		Creature _InteractedHostage = m_Reference.GetCreatureByName(_sInteractedHostageName);
		for (uint i = 0; i < m_arrVaults.length(); ++i)
		{
			if(IsCreatureInsideArea(_InteractedHostage, m_arrVaults[i]))
			{
				uint _iHostagesInVault;
				m_Vault_Hostages.get(m_arrVaults[i], _iHostagesInVault);
				_iHostagesInVault--;
				m_Vault_Hostages.set(m_arrVaults[i], _iHostagesInVault);
				print(_iHostagesInVault+" hostages remain in "+m_arrVaults[i]);
				
				if(_iHostagesInVault == 0)
				{
					m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_509, "RescueHostagesFromVault_"+(i+1), Completed);
					CheckRemainingHostages();
				}
			}
		}
		_InteractedHostage.Teleport(m_Reference, m_Reference.GetLogicObjectByName("HostagesRescueSpot"));
		_InteractedHostage.GoTo(m_Reference, m_Reference.GetLogicObjectByName("CaveExit_Spot"), 1, 1, false, false);
		m_Reference.RegisterCreatureEventByIndividual(GoToFinished, TOnCreatureEvent(@this.OnGoToFinished_DisableHostage), m_Reference.FindEntityName(_InteractedHostage), "");
		return true;
	}

	bool OnGoToFinished_DisableHostage(Creature& in _Creature)
	{
		_Creature.Enable(false);
		return true;
	}

	// Activating new patrols
	bool OnTriggerEnter_EventPatrols(Creature& in _Creature)
	{
		m_Reference.UnregisterHeroPartyEvent(AnyInside, TOnHeroPartyEvent(@this.OnTriggerEnter_EventPatrols));

		// two patrols in the area with the trigger
		m_Reference.ActivateSpawn("EventPatrol_Spawn_1", true);
		m_Reference.ActivateSpawn("EventPatrol_Spawn_2", true);
		Creature _EventPatrolHeister_1 = m_Reference.GetCreaturesFromSpawn("EventPatrol_Spawn_1")[0];
		Creature _EventPatrolHeister_2 = m_Reference.GetCreaturesFromSpawn("EventPatrol_Spawn_2")[0];
		Creature _EventPatrolHeister_3;
		if(m_Reference.GetCreaturesFromSpawn("EventPatrol_Spawn_3").length() > 0)
		{
			_EventPatrolHeister_3 = m_Reference.GetCreaturesFromSpawn("EventPatrol_Spawn_3")[0];
		}

		m_Reference.RegisterCreatureEventByIndividual(CanSee, TOnCreatureEvent(@this.OnCanSeeOrDamaged_ExplodeHostages), m_Reference.FindEntityName(_EventPatrolHeister_1), "Enemy");
		m_Reference.RegisterCreatureEventByIndividual(CanSee, TOnCreatureEvent(@this.OnCanSeeOrDamaged_ExplodeHostages), m_Reference.FindEntityName(_EventPatrolHeister_2), "Enemy");

		m_Reference.CastSpell("Journey_500_TeleportMessenger", m_iElvenHeisters, _EventPatrolHeister_1);
		m_Reference.CastSpell("Journey_500_TeleportMessenger", m_iElvenHeisters, _EventPatrolHeister_2);
		_EventPatrolHeister_1.FollowPath(m_Reference, "EventPatrolPath_1", true, false, true);
		_EventPatrolHeister_2.FollowPath(m_Reference, "EventPatrolPath_2", true, false, true);
		// for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		// 	m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("EventPatrols_Spot"));
		// mage heister leaves the switch through which players can reach vault 5
		_EventPatrolHeister_3.FollowPath(m_Reference, "EventPatrolPath_3", true, false, true);
		_EventPatrolHeister_3.EnablePOIVisitingBehavior(false);
		return true;
	}

	// Windholme chief guard cheats death
	bool OnLowHP_Heal( Creature &in _Creature )
	{
		if(_Creature.GetCurrentHP() <= PercentOf( _Creature.GetMaxHP(), 10))
		{
			_Creature.Heal(1000);
			print("Chief guard reached low hp, healing it.");
		}
		return false;
	}

	// Updating flow when boss hesiter is killed
	bool OnKilled_BossHeister( Creature &in _Creature )
	{
		m_Reference.EnableGroup("IceWallsFX_BossArena", false, true);
		for (uint i = 0; i < 10; ++i)
		{
			m_Reference.BlockNavMesh("BossArena_NavBlocker_"+(i+1), false);
		}

		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_509, "KillBossHeister", Completed);

		// Changing Everlight weather
		SetEverlightWeather();

		// Handling music
 		m_Reference.SuspendAutomaticCombatMusic(uint8(-1), uint8(-1), false);	
		m_Reference.SetGlobalSoundParameter(uint8(-1), uint8(-1), "combat", 0);
		m_Reference.SetTimer(TOnTimerEvent(@this.OnTimer_ResetMusic), 15);

		return true;
	}

	bool OnTimer_ResetMusic()
	{
		PlaySetting_Reset("");
		return true;
	}

	bool OnDamaged_BossHeister( Creature &in _Creature )
	{
		// Triggering first AoE spell
		if(_Creature.GetCurrentHP() <= PercentOf( _Creature.GetMaxHP(), 90) && m_bFirstAoECasted == false)
		{
			m_bFirstAoECasted = true;
			CastAoEOnArenas();
		}

		// Triggering random boss teleportation within current Arena
		uint temp = m_Reference.GetRandom().GetInteger(1, 20);
		if(!m_bBossIsCastingAoE && !m_bBossIsTeleportingWithinArena && temp <= 2)
		{
			m_bBossIsTeleportingWithinArena = true;
			BossTeleportWithinArena();
		}

		return false;
	}

	bool OnInteract_StartBossFight( Creature &in _Creature )
	{
		uint _uPlayersInArea = 0;
		array<uint8> _arrPlayers = m_Reference.GetPlayerFactions(true);
		for (uint i = 0; i < _arrPlayers.length(); ++i)
		{
			if(HeroParty_InArea("BossArena1", _arrPlayers[i]))
			{
				_uPlayersInArea++;
			}
		}

		if(_uPlayersInArea == _arrPlayers.length())
		{
			StartBossFight();
			m_Reference.GetLogicObjectByName("BossStasis_Switch").SetInteractive(false);
			return true;
		}
		else
		{
			for (uint i = 0; i < _arrPlayers.length(); ++i)
			{
				m_Reference.ShowNotification(_arrPlayers[i], "HeroPartyGather", m_Reference.GetCreatureByName(m_sBossHeister));
			}
		}

		return false;
	}

	void StartBossFight()
	{
		// Handling boss faction relations
		array<uint> _arrNeutralFactions;
		Creature _Boss = m_Reference.GetCreatureByName(m_sBossHeister);
		uint _uBossFaction = _Boss.GetFaction();
		for (uint i = 0; i < kMaxFactions; ++i)
		{
			if(m_Reference.GetFactionRelation(_uBossFaction, i) == Neutral && m_Reference.FindCreaturesByFaction(i, true).length() != 0
				&& i != m_iElvenHeisters)
			{
				_arrNeutralFactions.insertLast(i);
			}
		}
		for (uint i = 0; i < _arrNeutralFactions.length(); ++i)
		{
			m_Reference.SetFactionRelation(_uBossFaction, _arrNeutralFactions[i], Hostile);
		}

		JourneyDialogShoutout(m_sBossHeister, m_sBossHeister, "Journey_509_SO_BossFightStart");
		m_Reference.GetLogicObjectByName("BossStasis_FX").Enable(false);
		_Boss.SetImmovable(false);
		m_Reference.RegisterCreatureEventByIndividual(Killed, TOnCreatureEvent(@this.OnKilled_BossHeister), m_sBossHeister, "");
		m_Reference.RegisterCreatureEventByIndividual(Damaged, TOnCreatureEvent(@this.OnDamaged_BossHeister), m_sBossHeister, "");
		_Boss.PlayAnimation(m_Reference, ScreamExit, -1, 1200, false, false, Entity(), false, false, false);

		m_Reference.EnableGroup("IceWallsFX_BossArena", true, true);
		for (uint i = 0; i < 11; ++i)
		{
			m_Reference.BlockNavMesh("BossArena_NavBlocker_"+(i+1), true);
		}

		// activating all godstones just in case
		for (uint i = 0; i < m_arrGodstones.length(); ++i)
		{
			m_Reference.GetBuildingByName(m_arrGodstones[i]).SetFaction(m_Reference.GetHostFaction());
		}
		m_Reference.GetBuildingByName("Entrance_Godstone").SetFaction(kFactionNeutral);

		//Handling music
		PlaySetting_mountains_high();
	}

	bool OnEnteredArea_AoEAffectedArena( Creature &in _Creature )
	{
		// for fine-tuning journey specific condition is needed, based on Exp1_IceTrap_Low_HybDun
		string _sHero = m_Reference.FindEntityName(_Creature);
		m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.ApplyAoECondition_Timer), 100, _sHero);
		if(m_bHitByFreezeAOE_ShoutoutReady)
		{
			JourneyExplorationShoutout(_Creature, "Journey_509_SO_HitByFreezeAOE");
			m_Reference.SetTimer(TOnTimerEvent(@this.ResetHitByFreezeAOEShoutout_Timer), 10);
			m_bHitByFreezeAOE_ShoutoutReady = false;
		}
		return false;
	}
	bool ApplyAoECondition_Timer(const string& in _sHero)
	{
		m_Reference.GetCreatureByName(_sHero).ApplyCondition(51008, -1, kMaxFactions, 100);
		print("apply condition");
		return true;
	}
	bool ResetHitByFreezeAOEShoutout_Timer()
	{
		m_bHitByFreezeAOE_ShoutoutReady = true;
		return true;
	}

	bool OnLeftArea_AoEAffectedArena( Creature &in _Creature )
	{
		_Creature.RemoveCondition(51008);
		print("remove condition");
		return false;
	}

	bool OnResurrected_CheckAoEEffect( Creature &in _Creature )
	{
		array<string> _arrkeys = m_BossArenasWithAoE.getKeys();
		for(uint i = 0; i < _arrkeys.length(); ++i)
		{
			bool _bActiveAoEInArena;
			m_BossArenasWithAoE.get(_arrkeys[i], _bActiveAoEInArena);
			if(IsCreatureInsideArea(_Creature, _arrkeys[i]))
			{
				_Creature.ApplyCondition(51008, -1, kMaxFactions, 100);
			}
		}
		return false;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- A R T I C Y  F U N C T I O N S --------------------------------------------------------------------------------

	void CameraOnHostages()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("CameraSpot_Vault_1"));
		}
	}

	void CameraOnChiefGuard()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetCreatureByName(m_sChiefGuard));
		}
	}

	void ReceiveRescueDevice()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.AddVisiblePath(m_Reference.GetPlayerFactions(true)[i], "VisiblePath_Treasury");
		}
		m_Reference.GetHeroParty(m_Reference.GetHostFaction()).AddItems(m_sQuestItem, 1, true);
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_509, "TalkToChiefGuard", Completed);
		m_Reference.BlockNavMesh("NavBlocker_TreasuryEntrance", false );
	}

	void PlayersReturnRescueDevice()
	{
		m_Reference.GetHeroParty(m_Reference.GetHostFaction()).RemoveItems(m_sQuestItem, 1, true);
		// For now we'll disable treasury reveal here, but maybe there should be an event checking if the rescue device is in trinket slot
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.RemoveVisiblePath(m_Reference.GetPlayerFactions(true)[i], "VisiblePath_Treasury");
		}

	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- C U S T O M F U N C T I O N S ---------------------------------------------------------------------------------

	void SetupHostages()
	{
		// Fill the dictionaries with hostages in relation to vaults where they are held
		for (uint i = 0; i < m_arrVaults.length(); ++i)
		{
			uint _iHostagesInVault = m_Reference.FindCreaturesInArea(m_arrVaults[i]).length();
			m_Vault_Hostages.set("Vault_"+(i+1), _iHostagesInVault);

			Creature[] HostagesInVault = m_Reference.FindCreaturesInArea(m_arrVaults[i]);
			for (uint j = 0; j < HostagesInVault.length(); ++j)
			{
				HostagesInVault[j].PlayAnimation(m_Reference, IdleBound, -1, uint(-1), true, false, Entity (m_Reference.GetLogicObjectByName("VaultDoor_"+(i+1))), false, false, false);
				HostagesInVault[j].SetInteractive(true);
				HostagesInVault[j].SetImmovable(true);
				for (uint k = 0; k < m_Reference.GetPlayerFactions(true).length(); ++k)
					m_Reference.RegisterHeroPartyEvent(Interact, TOnHeroPartyExtendedEvent(@this.OnInteract_Hostage), m_Reference.FindEntityName(HostagesInVault[j]), m_Reference.GetPlayerFactions(true)[k]);
			}
		}
	}

	// Only works with linear sequence of saving hostages, should be reworked if we will allow to fight with heisters and not only sneak by
	void CheckRemainingHostages()
	{
		for (uint i = 0; i < m_arrVaults.length(); ++i)
		{
			uint _iHostagesInVault;
			m_Vault_Hostages.get(m_arrVaults[i], _iHostagesInVault);
			if(_iHostagesInVault > 0)
			{
				print("Not all hostages are saves yet.");
				break; 
			}
			if(m_arrVaults[i] == "Vault_5")
			{
				print("All hostages are saved, updating quest flow.");
				m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_509, "RescueHostagesHint", Completed);
				m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_509, "SaveAllHostages", Completed);
				m_Reference.UnregisterCreatureEvent(CanSee, TOnCreatureEvent(@this.OnCanSeeOrDamaged_ExplodeHostages));
				m_Reference.UnregisterCreatureEvent(Damaged, TOnCreatureEvent(@this.OnCanSeeOrDamaged_ExplodeHostages));
				StartTreasuryAssault();
			}
		}
	}

	void StartTreasuryAssault()
	{
		// Showing players that assault was started and reenabling autoattacks
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.GetHeroParty(m_Reference.GetPlayerFactions(true)[i]).EnableAutoAttacks(true);
			// Use map ping as well
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("GateExplosion_Spot"));
		}

		m_Reference.GetLogicObjectByName("GateExplosionFX").Enable(true);
		m_Reference.SetTimer( TOnTimerEvent( @this.DisableExplosionFX_Timer ), 3);

		m_Reference.GetLogicObjectByName("WT1_Blockade").Enable(false);
		m_Reference.BlockNavMesh("TreasuryGate_Blocker", false );
		m_Reference.SetFactionRelation(m_iWindholmeGuard, m_iElvenHeisters, Hostile);
		m_Reference.SetFactionRelation(m_iWindholmeGuard, m_iElvenHeisters_Boss, Hostile);
		m_Reference.GetWorld().EnableDialogueTopic(m_sChiefGuard, "Journey_509_WindholmeChiefGuard_DefaultDialogue", false);

		m_Reference.ActivateSpawn("DwarvenReinforcements_Spawn", true);
		CreatureGroup _Grp_WindholmeGuards = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iWindholmeGuard));
		_Grp_WindholmeGuards.AttackPosition(m_Reference.GetLogicObjectByName("Assault_Spot"), false, false);
		m_Reference.GetCreatureByName(m_sChiefGuard).SetImmovable(false);

		CreatureGroup _Grp_Heisters = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iElvenHeisters));
		_Grp_Heisters.AttackPosition(m_Reference.GetLogicObjectByName("Assault_Spot"), false, false);
		m_Reference.RegisterCreatureEventByIndividuals(Killed, TOnCreatureEvent(@this.OnKilledAllHeisters_MoveGuards), _Grp_Heisters.GetCreatures(), false, "");
		for (uint i = 0; i < _Grp_Heisters.GetCreatures().length(); ++i)
		{
			_Grp_Heisters.GetCreatures()[i].EnablePOIVisitingBehavior(false);
		}
		// Registering event to start the boss fight
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.RegisterHeroPartyEvent(Interact, TOnHeroPartyEvent(@this.OnInteract_StartBossFight), "BossStasis_Switch", _uFaction);
		}
	}

	bool OnKilledAllHeisters_MoveGuards(Creature &in _Creature)
	{
		CreatureGroup _Grp_WindholmeGuards = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(m_iWindholmeGuard));
		_Grp_WindholmeGuards.Move(m_Reference.GetLogicObjectByName("Assault_Spot"), false, false, true);
		m_Reference.GetCreatureByName(m_sChiefGuard).SetImmovable(true);
		return true;
	}

	bool DisableExplosionFX_Timer()
	{
		m_Reference.GetLogicObjectByName("GateExplosionFX").Enable(false);
		return true;
	}

	void CastAoEOnArenas()
	{
		Creature _Boss = m_Reference.GetCreatureByName(m_sBossHeister);
		_Boss.ForceCast(m_Reference, "Journey_509_BossIceAoE", _Boss, false);
		m_bBossIsCastingAoE = true;

		array<string> _arrArenasWithoutBoss;
		array<string> _arrkeys = m_BossArenasWithAoE.getKeys();
		for (uint i = 0; i < _arrkeys.length(); ++i)
		{
			if(IsCreatureInsideArea(m_Reference.GetCreatureByName(m_sBossHeister), _arrkeys[i]))
			{
				m_sCurrentArenaWithBoss = _arrkeys[i];
				m_BossArenasWithAoE.set(_arrkeys[i], true);
				print("Boss is currently here: : "+m_sCurrentArenaWithBoss);
			}
			else
			{
				_arrArenasWithoutBoss.insertLast(_arrkeys[i]);
				print("boss is not in this area: "+_arrkeys[i]);
			}
		}

		uint _uRandomIndex = m_Reference.GetRandom().GetInteger(0, _arrArenasWithoutBoss.length());
		string _sRandomArenaForAoE = _arrArenasWithoutBoss[_uRandomIndex];
		m_BossArenasWithAoE.set(_sRandomArenaForAoE, true);

		for (uint i = 0; i < _arrkeys.length(); ++i)
		{
			bool _bActiveAoEInArena;
			m_BossArenasWithAoE.get(_arrkeys[i], _bActiveAoEInArena);
			if(_bActiveAoEInArena)
			{
				if(_arrkeys[i] == "BossArena1")
				{
				    m_BossArenasTargetMarkers.get(_arrkeys[i], m_sBossArena1_TargetMarkers);
				    for (uint x = 0; x < m_sBossArena1_TargetMarkers.length(); ++x)
				    {
				    	for(uint y = 0; y < m_sBossArena1_TargetMarkers[0].length(); ++y)
				    	{
				    		if(m_Reference.GetLogicObjectByName(m_sBossArena1_TargetMarkers[x][y]).Exists())
					    	{
					        	m_Reference.ShowSpellMarker(2, 15, 6000, m_Reference.GetLogicObjectByName(m_sBossArena1_TargetMarkers[x][y]));
					    	}
				    	}
				    }
				}
				else if(_arrkeys[i] == "BossArena2")
				{
				    m_BossArenasTargetMarkers.get(_arrkeys[i], m_sBossArena2_TargetMarkers);
					for (uint x = 0; x < m_sBossArena2_TargetMarkers.length(); ++x)
					{
						for(uint y = 0; y < m_sBossArena2_TargetMarkers[0].length(); ++y)
						{
							if(m_Reference.GetLogicObjectByName(m_sBossArena2_TargetMarkers[x][y]).Exists())
					    	{
					        	m_Reference.ShowSpellMarker(2, 15, 6000, m_Reference.GetLogicObjectByName(m_sBossArena2_TargetMarkers[x][y]));
					    	}
						}
					}
				}
				else if(_arrkeys[i] == "BossArena3")
				{
				    m_BossArenasTargetMarkers.get(_arrkeys[i], m_sBossArena3_TargetMarkers);
					for (uint x = 0; x < m_sBossArena3_TargetMarkers.length(); ++x)
					{
						for(uint y = 0; y < m_sBossArena3_TargetMarkers[0].length(); ++y)
						{
							if(m_Reference.GetLogicObjectByName(m_sBossArena3_TargetMarkers[x][y]).Exists())
					    	{
					        	m_Reference.ShowSpellMarker(2, 15, 6000, m_Reference.GetLogicObjectByName(m_sBossArena3_TargetMarkers[x][y]));
					    	}
						}
					}
				}
			}
		}

		m_Reference.SetTimerMS(TOnTimerEvent(@this.BossArena_AoEEffect_Timer), m_uAoESpellCastDuartionMS);
	}

	bool BossArena_AoEEffect_Timer()
	{
		array<string> _arrkeys = m_BossArenasWithAoE.getKeys();
		for(uint i = 0; i < _arrkeys.length(); ++i)
		{
			bool _bActiveAoEInArena;
			m_BossArenasWithAoE.get(_arrkeys[i], _bActiveAoEInArena);
			if(_bActiveAoEInArena)
			{
				m_Reference.EnableGroup(_arrkeys[i]+"_AoEFX", true, true);
				for(uint j = 0; j < m_Reference.GetPlayerFactions(true).length(); ++j)
				{
					uint _uFaction = m_Reference.GetPlayerFactions(true)[j];
					m_Reference.RegisterCreatureEventByDescription(EnteredArea, TOnCreatureEvent(@this.OnEnteredArea_AoEAffectedArena), "", _uFaction, _arrkeys[i]);
					m_Reference.RegisterCreatureEventByDescription(LeftArea, TOnCreatureEvent(@this.OnLeftArea_AoEAffectedArena), "", _uFaction, _arrkeys[i]);
					m_Reference.RegisterCreatureEventByIndividuals(Resurrected, TOnCreatureEvent(@this.OnResurrected_CheckAoEEffect), m_Reference.GetHeroParty(_uFaction).GetMembers(), true, "");
				}
			}
		}

		uint _uAoEEffectRandomDuration = m_Reference.GetRandom().GetInteger(m_uAoEEffectDurationMin, m_uAoEEffectDurationMax);
		m_Reference.SetTimer(TOnTimerEvent(@this.DisableAoEEffect_Timer), _uAoEEffectRandomDuration);
		if(m_Reference.GetCreatureByName(m_sBossHeister).GetCurrentHP() > 0)
		{
			BossTeleportFromArena();	
		}

		return true;
	}

	bool DisableAoEEffect_Timer()
	{
		m_Reference.UnregisterCreatureEvent(EnteredArea, TOnCreatureEvent(@this.OnEnteredArea_AoEAffectedArena));
		m_Reference.UnregisterCreatureEvent(LeftArea, TOnCreatureEvent(@this.OnLeftArea_AoEAffectedArena));
		m_Reference.UnregisterCreatureEvent(Resurrected, TOnCreatureEvent(@this.OnResurrected_CheckAoEEffect));

		array<string> _arrkeys = m_BossArenasWithAoE.getKeys();
		for(uint i = 0; i < _arrkeys.length(); ++i)
		{
			bool _bActiveAoEInArena;
			m_BossArenasWithAoE.get(_arrkeys[i], _bActiveAoEInArena);
			if(_bActiveAoEInArena)
			{
				m_Reference.EnableGroup(_arrkeys[i]+"_AoEFX", false, true);
				m_BossArenasWithAoE.set(_arrkeys[i], false);
			}
		}

		// Debuff should be disabled with small delay because FXs don't disapear instantly
		m_Reference.SetTimerMS(TOnTimerEvent(@this.DisableDebuffCondition_Timer), 1500);
		// If boss is alive trigger AOE spell once again
		if(m_Reference.GetCreatureByName(m_sBossHeister).GetCurrentHP() > 0)
		{
			CastAoEOnArenas();	
		}			

		return true; 
	}

	bool DisableDebuffCondition_Timer()
	{
		for(uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			Creature[] _arrHeroes = m_Reference.GetHeroParty(_uFaction).GetMembers();
			for(uint j = 0; j < _arrHeroes.length(); ++j)
			{
				_arrHeroes[j].RemoveCondition(51008);
			}
		}
		return true;
	}

	void BossTeleportFromArena()
	{
		m_Reference.CastSpell("Journey_500_TeleportMessenger", m_iElvenHeisters_Boss, m_Reference.GetCreatureByName(m_sBossHeister));

		string _sTeleportTarget;
		array<string> _arrkeys = m_BossArenasWithAoE.getKeys();
		for(uint i = 0; i < _arrkeys.length(); ++i)
		{
			bool _bActiveAoEInArena;
			m_BossArenasWithAoE.get(_arrkeys[i], _bActiveAoEInArena);
			if(!_bActiveAoEInArena)
			{
				_sTeleportTarget = _arrkeys[i]+"_BossTeleportSpot";
			}
		}

		m_Reference.GetCreatureByName(m_sBossHeister).Teleport(m_Reference, m_Reference.GetLogicObjectByName(_sTeleportTarget));
		m_bBossIsCastingAoE = false;
	}

	void BossTeleportWithinArena()
	{
		Creature _Boss = m_Reference.GetCreatureByName(m_sBossHeister);
		array<string> _arrkeys = m_BossArenasTargetMarkers.getKeys();
		for(uint i = 0; i < _arrkeys.length(); ++i)
		{
			if(IsCreatureInsideArea(_Boss, _arrkeys[i]))
			{
				string _sTeleportTarget;
				bool _bFoundTarget = false;
				string[][] m_sBossFightTargetMarkers;
				m_BossArenasTargetMarkers.get(_arrkeys[i], m_sBossFightTargetMarkers);
				while(!_bFoundTarget)
				{
					uint _uRandomX = m_Reference.GetRandom().GetInteger( 0, m_sBossFightTargetMarkers.length());
					uint _uRandomY = m_Reference.GetRandom().GetInteger( 0, m_sBossFightTargetMarkers[0].length());
					LogicObject _TeleportTarget = m_Reference.GetLogicObjectByName(_arrkeys[i]+"_TrapMarker_"+_uRandomX+"_"+_uRandomY);
					if(_TeleportTarget.Exists())
					{
						_bFoundTarget = true;
						_sTeleportTarget = m_Reference.FindEntityName(_TeleportTarget);
						m_Reference.CastSpell("Journey_500_TeleportMessenger", m_iElvenHeisters_Boss, _Boss);
						m_Reference.GetCreatureByName(m_sBossHeister).PlayAnimation(m_Reference, CastShortSelf, -1, 3000, false, false, Entity ( ), false, false, false);
						m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.BossTeleportWithinArena_Timer), 500, _sTeleportTarget);
					}
				}
			}
		}
	}

	bool BossTeleportWithinArena_Timer(const string& in _sTeleportTarget)
		{
			Creature _Boss = m_Reference.GetCreatureByName(m_sBossHeister);
			_Boss.Teleport(m_Reference, m_Reference.GetLogicObjectByName(_sTeleportTarget));
			m_Reference.CastSpell("Journey_500_TeleportMessenger", m_iElvenHeisters_Boss, _Boss);
			m_bBossIsTeleportingWithinArena = false;

			return true;
		}

	// -------------------------------------------------------------------------------------------------------------------
	// --- U T I L S -----------------------------------------------------------------------------------------------------

	void FillBossFightMarkerArray()
	{
		array<string> _arrkeys = m_BossArenasSizes.getKeys();
		for(uint i = 0; i < _arrkeys.length(); ++i)
		{
			array<uint> _arrBossArenaSize;
			m_BossArenasSizes.get(_arrkeys[i], _arrBossArenaSize);
			if(_arrBossArenaSize.length() == 2)
			{
				InitArray(_arrBossArenaSize[0], _arrBossArenaSize[1], _arrkeys[i]);
				string[][] m_sBossFightTargetMarkers;
				m_BossArenasTargetMarkers.get(_arrkeys[i], m_sBossFightTargetMarkers);
				print("Array Length: " + m_sBossFightTargetMarkers.length());
				for(uint x = 0; x < m_sBossFightTargetMarkers.length(); x++)
				{
					for (uint y = 0; y < m_sBossFightTargetMarkers[0].length(); y++)
					{
						m_sBossFightTargetMarkers[x][y] = _arrkeys[i]+"_TrapMarker_" + x + "_" + y;
					}
				}
				m_BossArenasTargetMarkers.set(_arrkeys[i], m_sBossFightTargetMarkers);
			}
		}
	}

	void InitArray(uint _xSize, uint _ySize, string _sBossArena)
	{
		string[][] m_sBossFightTargetMarkers;
		m_BossArenasTargetMarkers.get(_sBossArena, m_sBossFightTargetMarkers);
		m_sBossFightTargetMarkers.resize(_xSize);
		for(uint i = 0; i < m_sBossFightTargetMarkers.length(); i++)
		{
			m_sBossFightTargetMarkers[i].resize(_ySize);
		}
		m_BossArenasTargetMarkers.set(_sBossArena, m_sBossFightTargetMarkers);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- DEBUG --------------------------------------------------------------------------------- 

	void test()
	{
		array<string> _arrkeys = m_Vault_Hostages.getKeys();
		for (uint i = 0; i < _arrkeys.length(); ++i)
		{
			uint _iHostagesInVault;
			m_Vault_Hostages.get(_arrkeys[i], _iHostagesInVault);
			print(_arrkeys[i]+" has "+_iHostagesInVault+" hostages.");
		}
	}

	void explosion(uint _num)
	{
		m_Reference.CastSpell("BarrelExplosion_Medium", m_iElvenHeisters, m_Reference.GetLogicObjectByName("CameraSpot_Vault_"+_num));
	}

	void testFight()
	{
		m_Reference.UnregisterCreatureEvent(CanSee, TOnCreatureEvent(@this.OnCanSeeOrDamaged_ExplodeHostages));
		m_Reference.UnregisterCreatureEvent(Damaged, TOnCreatureEvent(@this.OnCanSeeOrDamaged_ExplodeHostages));
		m_Reference.BlockNavMesh("NavBlocker_TreasuryEntrance", false );
		StartTreasuryAssault();
	}

	void testSingleSpell(uint _uType, uint _uRadius, uint _uDuration, string _sTarget)
	{
		m_Reference.ShowSpellMarker(_uType, _uRadius, _uDuration, m_Reference.GetLogicObjectByName(_sTarget));
	}

	void testPattern(uint _uType, uint _uDuration)
	{
		for (uint i = 0; i < 127; ++i)
		{
			m_Reference.ShowSpellMarker(_uType, 15, _uDuration, m_Reference.GetLogicObjectByName("Spell_Spot_4_Clone_"+(i+1)));	
		}
	}

	void testTeleport(string _sTeleportTarget)
	{
		m_Reference.GetCreatureByName(m_sBossHeister).Teleport(m_Reference, m_Reference.GetLogicObjectByName(_sTeleportTarget));
	}
}
