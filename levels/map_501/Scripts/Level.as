// ------------------------------------------------------------------------------------------------------------------------------------
#include "../../basicScripts/Journey_LevelBase.as"

// ------------------------------------------------------------------------------------------------------------------------------------
class Level: Journey_LevelBase
{
	// count this version-number up. This is for later version tracking, when the QA plays the map.
	string m_Version_Level = "QA hasn't played the map yet";
	
	// --- constructor --- DONT TOUCH!!!!
	Level (LevelReference@ _Reference)
	{
		super(_Reference);
	}

// -------------------------------------------------------------------------------------------------------------------	
// --- V A R I A B L E S ---------------------------------------------------------------------------------------------
	
	// Used in map intros/outros
	string m_sGoatsOwner = "Journey_GoatsOwner_501";
	string m_sMapIntroTopic = "Journey_501_GoatsOwner_MapIntro";
	string m_sMapOutroTopic = "Journey_501_GoatsOwner_MapOutro";

	string m_sMainQuest_501 = "Journey_501_Q0_StopCattleKiller";

	string m_sTroll = "Journey_CattleStealerTroll_501";
	string m_sTuskHunterCommander = "Journey_TuskHunter_Commander_501";

	uint8 m_u0_PlayerFaction = 0;
	uint8 m_u1_PlayerFaction= 1;
	uint8 m_u2_PlayerFaction = 2;
	uint8 m_uTuskHunters = 5;
	uint8 m_uTroll = 4;
	uint8 m_uGoatsFaction= 6;

	bool m_bTrollSpell_CoolDown_Finished = true;
	bool m_bGoatTauntCooldown = false;
	// Taunt duration of the Journey_501_GoatTaunt spell
	uint m_uGoatTauntDuration = 2;
	// On damaged goats shoutdown cooldown, so we won't trigger it too often
	bool m_bDamagedGoatsShoutoutReady = true;

	// How many goats must survive to complete the side quest, gets global value in initcommon
	int m_iGoatsMustSurvive;

	/*	--------------------------------------------------
	*	Not used at all now. Maybe activating random "free roam" 
	*	spawns on map launch will be a good idea
	*	--------------------------------------------------
	*/	
	array<string> Zombie_Spawns = 
	{
		"Zombie_Spawn_01",
		"Zombie_Spawn_02",
		"Zombie_Spawn_03",
		"Zombie_Spawn_04",
		"Zombie_Spawn_05",
		"Zombie_Spawn_06",
		"Zombie_Spawn_07",
		"Zombie_Spawn_08",
		"Zombie_Spawn_09",
		"Zombie_Spawn_10",
		"Zombie_Spawn_11",
		"Zombie_Spawn_12",
		"Zombie_Spawn_13",
		"Zombie_Spawn_14",
		"Zombie_Spawn_15"
	};

	array<string> Quest_Spawns = 
	{
		"MeleeBugs_Spawn_01",
		"Troll_Spawn",
		"Cattle_Spawn",
		"MeleeSpiders_Spawn_01",
		"RangeBugs_Spawn_01",
		"MeleeBugs_Spawn_02",
		"RangeBugs_Spawn_02",
		"RangeSpiders_Spawn_01",
		"MeleeSpiders_Spawn_02",
		"FlyingBugs_Spawn_01"
	};

	array<string> EarthquakeBugs_Spawns = 
	{
		"EarthquakeBugs_Spawn_01",
		"EarthquakeBugs_Spawn_02",
		"EarthquakeBugs_Spawn_04",
		"EarthquakeBugs_Spawn_06",
		"EarthquakeBugs_Spawn_08"
	};

	array<string> TrollStuff_NavBlockers = 
	{
		"RockGate_Blocker",
		"LogicItem_3_Clone_1",
		"LogicItem_3_Clone_2",
		"LogicItem_3_Clone_3",
		"LogicItem_3_Clone_4",
		"LogicItem_3_Clone_5",
		"LogicItem_3_Clone_6",
		"LogicItem_3_Clone_7",
		"LogicItem_3_Clone_9",
		"LogicItem_3_Clone_10"
	};

// -------------------------------------------------------------------------------------------------------------------
// ---  S Y S T E M   E V E N T S  -----------------------------------------------------------------------------------

	void OnCreated () override
	{
		// Call the original OnCreated
		Journey_LevelBase::OnCreated();
		print("--- M A P : Level Script: '"+m_Version_Level+"', Map: '"+ m_Reference.GetMapId() +"', Setting: '"+ m_Reference.GetWorld().GetCurrentMapSetting( m_Reference.GetMapId() )+"'");

		// Calling the final functions
		InitEvents(); // register all neutral events
		InitCommon(); // script and set everything up for starting the level
	}

	void OnLoaded (const uint _uVersion) override
	{
		Journey_LevelBase::OnLoaded(_uVersion);
		print("--- M A P : Level Script: '"+m_Version_Level+"', Map: '"+ m_Reference.GetMapId() +"', Setting: '"+ m_Reference.GetWorld().GetCurrentMapSetting( m_Reference.GetMapId() )+"'");
	}	

	// -------------------------------------------------------------------------------------------------------------------
	// ---  B A S I C S   E V E N T S  -----------------------------------------------------------------------------------

	// --- ALL SETTINGS --------------------------------------------------------------------------------------------------
	void InitEvents ()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.RegisterHeroPartyEvent(AnyCanSee, TOnHeroPartyEvent(@this.OnCanSee_Troll), m_sTroll, m_Reference.GetPlayerFactions(true)[i]);
			m_Reference.RegisterHeroPartyEvent(Interact, TOnHeroPartyEvent(@this.OnInteract_FreeCattle), "RockGate_Switch", m_Reference.GetPlayerFactions(true)[i]);
		}
	}

	void InitCommon ()
	{
		for (uint i = 0; i < Quest_Spawns.length(); ++i)
		{
			m_Reference.ActivateSpawn( Quest_Spawns[i], true );
		}
		
		m_Reference.GetLogicObjectByName( "RockGate_Switch" ).Enable( false );
		
		m_Reference.GetCreatureByName(m_sTroll).SetImmovable(true);
		m_Reference.GetCreatureByName(m_sTroll).SetImmortal(true);

		m_Reference.GetCreatureByName(m_sGoatsOwner).AllowAttacks(false);
		m_Reference.GetCreatureByName(m_sGoatsOwner).SetImmovable(true);
		// Preventing mobs attacking goats until they are freed
		Creature[] _Goats = m_Reference.GetCreaturesFromSpawn("Cattle_Spawn");
		for (uint i = 0; i < _Goats.length(); ++i)
		{
			_Goats[i].SetAttackable(false);
		}

		for (uint i = 0; i < TrollStuff_NavBlockers.length(); ++i)
		{	
			m_Reference.BlockNavMesh(TrollStuff_NavBlockers[i], true );
		}

		m_Reference.GetBuildingByName("Godstone_Entrance").SetFaction(m_Reference.GetHostFaction());

		m_Reference.GetLogicObjectByName("BossFightExit_BlockerFX").Enable(false);

		m_iGoatsMustSurvive = m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_501_iGoatsMustSurvive");
		// Resetting quest relevant global int
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_501_iSurvivingGoats", 0);

		SetupIntroCreatures(m_sGoatsOwner, m_sMapIntroTopic);

		// random loot
		ActivateRandomLoot(25);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T   F U N C T I O N S --------------------------------------------------------------------------------

	// Troll-related events

	bool OnCanSee_Troll (Creature &in _Creature)
	{
		_Creature.Shoutout(m_Reference, m_sTroll, "Journey_501_SO_Greeting", false, kMaxFactions);
		m_Reference.GetSharedJournal().SetTaskState("Journey_501_Q0_StopCattleKiller", "InvestigateCave", Completed);
		m_Reference.UnregisterHeroPartyEvent(AnyCanSee, TOnHeroPartyEvent(@this.OnCanSee_Troll));

		PrepareTuskHunters();

		return true;
	}

	bool OnHuntersGoToFinished_DialogueShoutout (Creature &in _Creature)
	{
		// Reenabling controls for players
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			JourneyPlayerHeroControlEnable_Light(_uFaction);
		}

		JourneyDialogShoutout(m_sTroll, m_sTroll, "Journey_501_InitialTalk_02", false, false, false, m_Reference.GetHostFaction());

		return true;
	}

	bool KillTuskHunters( Creature &in _Creature )
	{
		for (uint i = 0; i < m_Reference.GetCreaturesFromSpawn("TuskHunters_Spawn").length(); ++i)
		{
			m_Reference.GetCreaturesFromSpawn("TuskHunters_Spawn")[i].Kill();
		}

		m_Reference.GetCreatureByName(m_sTroll).Shoutout(m_Reference, m_sTroll, "Journey_501_SO_Threat", false, kMaxFactions);

		return true;
	}

	bool OnDamaged_Troll(Creature &in _Creature)
	{
		if(_Creature.GetCurrentHP() <= 1)
		{
			print("Troll is defeated");
			_Creature.SetAttackable(false);
			_Creature.Shoutout(m_Reference, m_sTroll, "Journey_501_SO_DeathCry", false, kMaxFactions);
			_Creature.PlayAnimation(m_Reference, Stunned, -1, 1500, true, false, Entity ( ), false, false, false);
			m_Reference.SetTimerMS(TOnTimerEvent(@this.TrollDies_Timer), 1500);
			return true;	
		}
		else if (m_bTrollSpell_CoolDown_Finished == true)
		{
			Cast_TrollSpell();
		} 
		return false;
	}

	bool TrollDies_Timer()
	{
		Creature _Troll = m_Reference.GetCreatureByName(m_sTroll);
		_Troll.SetImmortal(false);
		_Troll.KillAndPreserve(m_Reference);
		m_Reference.GetLogicObjectByName( "RockGate_Switch" ).Enable( true );
		m_Reference.GetSharedJournal().SetTaskState("Journey_501_Q0_StopCattleKiller", "DefeatTheTroll", Completed);

		// Handling music
 		m_Reference.SuspendAutomaticCombatMusic(uint8(-1), uint8(-1), false);	
		m_Reference.SetGlobalSoundParameter(uint8(-1), uint8(-1), "combat", 0);
		m_Reference.SetTimer(TOnTimerEvent(@this.OnTimer_ResetMusic), 25);

		return true;
	}

	bool OnTimer_ResetMusic()
	{
		PlaySetting_Reset("");
		return true;
	}

	void Cast_TrollSpell()
	{
		uint _iTrollSpellTargetId = TrollSpellTargetId();
		if (_iTrollSpellTargetId != 0)
		{
			m_Reference.GetCreatureByName(m_sTroll).ForceCast(m_Reference, "Journey_501_quake_troll", m_Reference.GetCreatureById(_iTrollSpellTargetId), false);
			m_bTrollSpell_CoolDown_Finished = false;
			m_Reference.SetTimer(TOnTimerEvent(@this.TrollSpell_Cooldown), 10);
		}
	}

	// get an id of a random hero from a random player controlled faction within Journey_CattleStealerTroll_501 agro range
	uint TrollSpellTargetId()
	{
		uint _uRandomPlayerFaction = m_Reference.GetRandom().GetInteger( 0, m_Reference.GetPlayerFactions(true).length());
		uint _stgRandomHeroId = 0;
		string _stgRandomHeroName;
		array <Creature>@ _arrCrtHeroParty = m_Reference.GetHeroParty( _uRandomPlayerFaction ).GetMembers ();

		// get ids of party members who are alive and within troll's agro range
		array<uint> _arrAliveAndInAgro = {};
		for ( uint _iTmp1 = 0 ; _iTmp1 < _arrCrtHeroParty.length() ; _iTmp1++ )
		{
			if ( _arrCrtHeroParty[_iTmp1].GetCurrentHP() > 0 && _arrCrtHeroParty[_iTmp1].IsInAggroRange(m_Reference, m_Reference.GetCreatureByName(m_sTroll)) == true) 
			{
				print("We add this hero in trolls' targets list: " + _arrCrtHeroParty[_iTmp1].GetDescriptionName());
				_arrAliveAndInAgro.insertLast(_arrCrtHeroParty[_iTmp1].GetId());
			}
		}
		if (_arrAliveAndInAgro.length() == 1)
		{
			_stgRandomHeroId = _arrAliveAndInAgro[0];
			_stgRandomHeroName = m_Reference.GetCreatureById(_stgRandomHeroId).GetDescriptionName();
			print("Troll casts spell at: " + _stgRandomHeroName);
			return _stgRandomHeroId;
		}
		else if (_arrAliveAndInAgro.length() > 1)
		{
			_stgRandomHeroId = _arrAliveAndInAgro[ m_Reference.GetRandom().GetInteger( 0, _arrAliveAndInAgro.length()) ];
			_stgRandomHeroName = m_Reference.GetCreatureById(_stgRandomHeroId).GetDescriptionName();
			print("Troll casts spell at: " + _stgRandomHeroName);
			return _stgRandomHeroId;
		}
		return _stgRandomHeroId;
	}

	bool TrollSpell_Cooldown()
	{
		m_bTrollSpell_CoolDown_Finished = true;
		
		return true;
	}

	// Goats-related events

	bool OnInteract_FreeCattle( Creature& in _Creature )
	{
		// Once goats are freed boss fight area is unlocked and new mobs spawn in
		BlockBossFightArea(false);
		for (uint i = 0; i < EarthquakeBugs_Spawns.length(); ++i)
		{
			m_Reference.ActivateSpawn( EarthquakeBugs_Spawns[i], true );
		}
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_501, "FreeCattle", Completed);

		m_Reference.GetLogicObjectByName( "RockGate" ).Enable( false );
		m_Reference.GetLogicObjectByName( "RockGate_Switch" ).Enable( false );
		m_Reference.BlockNavMesh("RockGate_Blocker", false);

		// Set cattle/player relations to allied + register event to trigger map outro shoutout
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.SetFactionRelation(_uFaction, m_uGoatsFaction, Allied);
		}

		Creature[] _Goats = m_Reference.GetCreaturesFromSpawn("Cattle_Spawn");
		m_Reference.RegisterCreatureEventByIndividuals(Killed, TOnCreatureEvent(@this.OnGoatKilled_UpdateSideQuest), _Goats, true, "");
		m_Reference.RegisterCreatureEventByIndividuals(CanSee, TOnCreatureEvent(@this.OnGoatsCanSeeOwner_UpdateQuest), _Goats, true, m_sGoatsOwner);
		m_Reference.RegisterCreatureEventByIndividuals(Damaged, TOnCreatureEvent(@this.OnDamaged_SlowDownGoats), _Goats, true, "Trigger_Godstone_Entrance");
		m_Reference.RegisterCreatureEventByIndividuals(EnteredAggroRange, TOnCreatureExtendedEvent(@this.OnEnteredEnemyAggroRange_GoatTaunt), _Goats, true, "Enemy");
		for (uint i = 0; i < _Goats.length(); ++i)
		{
			_Goats[i].FollowCreature( m_Reference, m_Reference.GetCreatureById(m_iHostAvatarId), 40, 30, true, false);
			_Goats[i].AllowAttacks(false);
			_Goats[i].SetAttackable(true);
		}

		return true;
	}

	bool OnEnteredEnemyAggroRange_GoatTaunt(Creature& in _Creature, Entity[]& in _Params)
	{
		if(m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_501, "ReturnGoats") == Completed)
		{
			return true;
		}
		else if(m_bGoatTauntCooldown == false)
		{
			_Creature.ForceCast(m_Reference, "Journey_501_GoatTaunt", _Params[0], false);
			print(m_Reference.FindEntityName(_Creature)+" taunts");
			_Creature.FollowCreature( m_Reference, m_Reference.GetCreatureById(m_iHostAvatarId), 40, 30, true, false);

			m_bGoatTauntCooldown = true;
			m_Reference.SetTimer(TOnTimerEvent(@this.GoatTauntCooldownReset_Timer), m_uGoatTauntDuration);
		}

		return false;
	}

	bool GoatTauntCooldownReset_Timer()
	{
		m_bGoatTauntCooldown = false;
		return true;
	}

	bool OnGoatsCanSeeOwner_UpdateQuest( Creature &in _Creature )
	{
		_Creature.SetImmortal(true);
		_Creature.SetAttackable(false);
		_Creature.FollowCreature( m_Reference, m_Reference.GetCreatureByName(m_sGoatsOwner), 0, 0, false, false);

		int _iEscapedGoats = m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_501_iSurvivingGoats");
		_iEscapedGoats++;
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_501_iSurvivingGoats", _iEscapedGoats);
		if( _iEscapedGoats >= m_iGoatsMustSurvive )
		{
			// m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_501, "SurvivingGoatsCounter", Completed);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_501, "ReturnGoats", Completed);
		}

		return false;
	}

	bool OnGoatKilled_UpdateSideQuest( Creature &in _Creature )
	{
		int _iSurvivingGoats = m_Reference.GetCreaturesFromSpawn("Cattle_Spawn").length();
		if( _iSurvivingGoats < m_iGoatsMustSurvive )
		{
			m_Reference.GetSharedJournal().SetQuestState( m_sMainQuest_501, Failed );
			return true;
		}
		else
		{
			return false;
		}
	}

	bool OnDamaged_SlowDownGoats( Creature &in _Creature )
	{
		// Applying impaired to goats on hit so it is impossible to simply rush through mobs
		_Creature.ApplyCondition(125, 10, kMaxFactions, 800);
		if(m_bDamagedGoatsShoutoutReady && _Creature.GetCurrentHP() <= PercentOf( _Creature.GetMaxHP(), 50))
		{
			m_bDamagedGoatsShoutoutReady = false;
			m_Reference.SetTimer(TOnTimerEvent(@this.DamagedGoatsShoutoutReady_Timer), 14);
			JourneyExplorationShoutout(_Creature, "Journey_501_SO_HitByEarthquake");
		}
		return false;
	}

	bool DamagedGoatsShoutoutReady_Timer()
	{
		m_bDamagedGoatsShoutoutReady = true;
		return true;
	}

	bool OnGoToFinished_Disable( Creature &in _Creature )
	{
		_Creature.Enable(false);
		return false;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- C U S T O M  F U N C T I O N S --------------------------------------------------------------------------------

	void PrepareTuskHunters()
	{
		m_Reference.ActivateSpawn( "TuskHunters_Spawn", true );

		for (uint i = 0; i < m_Reference.GetCreaturesFromSpawn("TuskHunters_Spawn").length(); ++i)
		{
			m_Reference.GetCreaturesFromSpawn("TuskHunters_Spawn")[i].Enable( false );
		}
	}

	void BlockBossFightArea(bool _bBlock)
	{
		m_Reference.GetLogicObjectByName("BossFightExit_BlockerFX").Enable(_bBlock);
		m_Reference.BlockNavMesh("BossFightExit_Blocker", _bBlock);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- A R T I C Y   F U N C T I O N S -------------------------------------------------------------------------------

	void TuskHunters_Arrive()
	{
		// Disabling controls for players before next dialogue is triggered
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.FocusCamera(_uFaction, m_Reference.GetLogicObjectByName( "TuskHunters_DialogueSpot" ));
			JourneyPlayerHeroControlDisable_Light(_uFaction);
		}

		for (uint i = 0; i < m_Reference.GetCreaturesFromSpawn("TuskHunters_Spawn").length(); ++i)
		{
			m_Reference.GetCreaturesFromSpawn("TuskHunters_Spawn")[i].Enable( true );
			m_Reference.GetCreaturesFromSpawn("TuskHunters_Spawn")[i].SetImmovable( true );
		}

		// Troll may face tuskhunters here with idle alerted animation

		CreatureGroup TuskHunters = CreatureGroup(m_Reference, m_Reference.GetCreaturesFromSpawn("TuskHunters_Spawn"));
		TuskHunters.Move( m_Reference.GetLogicObjectByName( "TuskHunters_DialogueSpot" ), false, true, false );
		m_Reference.RegisterCreatureEventByIndividuals(GoToFinished, TOnCreatureEvent(@this.OnHuntersGoToFinished_DialogueShoutout), TuskHunters.GetCreatures(), true, "");
		// Tusk hunters' commander shoutout
		m_Reference.GetCreatureByName(m_sTuskHunterCommander).Shoutout(m_Reference, m_sTuskHunterCommander, "Journey_501_SO_TuskHuntersArrival", false, kMaxFactions);
	}	

	void Start_TrollBossFight()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.SetFactionRelation(m_Reference.GetPlayerFactions(true)[i], m_uTroll, Hostile);
		}
		m_Reference.GetSharedJournal().SetTaskState("Journey_501_Q0_StopCattleKiller", "TalkToTheTroll", Completed);
		m_Reference.RegisterCreatureEventByIndividual(Damaged, TOnCreatureEvent(@this.OnDamaged_Troll), m_sTroll, "");

		// Troll kills tusk hunters
		m_Reference.SetFactionRelation(m_uTuskHunters, m_uTroll, Hostile);
		m_Reference.GetCreatureByName(m_sTroll).ForceCast(m_Reference, "Journey_501_quake_troll", m_Reference.GetLogicObjectByName("TuskHunters_DialogueSpot"), false);
		m_Reference.RegisterCreatureEventByIndividual( SpellCast, TOnCreatureEvent( @this.KillTuskHunters ), m_sTroll, "" );

		// Blocking exit from the boss fight area
		BlockBossFightArea(true);
		m_Reference.GetBuildingByName("Godstone_Entrance").SetFaction(kFactionNeutral);

		// Handling music
		PlaySetting_grassland_med();
	}

	// Called on complition of the main quest
	void GoatsFactionLeaves()
	{
		Creature[] _GoatsFactionCreatures = GetLivingCreaturesByFaction(m_uGoatsFaction);
		m_Reference.RegisterCreatureEventByDescription(GoToFinished, TOnCreatureEvent(@this.OnGoToFinished_Disable), "", m_uGoatsFaction, "");
		for(uint i = 0; i < _GoatsFactionCreatures.length(); ++i)
		{
			_GoatsFactionCreatures[i].GoTo(m_Reference, m_Reference.GetLogicObjectByName("CaveExit_Spot"), 1, 5, false, false);
		}
	}
}