// includes:
#include "../../basicScripts/Journey_LevelBase.as"

class Level: Journey_LevelBase
{

	// --------------------------------------------------------------------------------------------------------------------
	// --- Member Variables -----------------------------------------------------------------------------------------------

	// Used in map intros/outros
	string m_sRohenTahir = "Journey_RohenTahir_510";
	string m_sMapIntroTopic = "Journey_510_RohenTahir_MapIntro";

	// count this version-number up. This is for later version tracking, when the QA plays the map. 
	string m_Version_Level = "QA hasn't played the map yet";

	// --- Factions -----------------------------------------------------------------------------------------------------------
	uint8 m_i0_PlayerFaction = 				0;
	uint8 m_i1_PlayerFaction = 				1;
	uint8 m_i2_PlayerFaction = 				2;
	uint8 m_iHybernianOffsprings = 		    3;
	uint8 m_iDragonFaction = 		        4;
	uint8 m_iDragonFighters = 		        5;
	uint8 m_iElvenMercenaries = 		    6;
	uint8 m_iElvenMercenaries_Defence = 	7;
	uint8 m_iHybernianOffsprings_Defence = 	8;
	uint8 m_iRohen_Faction = 	            9;

	dictionary m_PlayersInititalSectors =
	{
		{"Sector_19", m_i0_PlayerFaction},
		{"Sector_18", m_i1_PlayerFaction},
		{"Sector_20", m_i2_PlayerFaction}
	};

	// Quests
	string m_sMainQuest_510 = "Journey_510_Q0_TameDragonForIsamo";

	string m_sIsamosArifact = "Journey_IsamosArtifact_510";

	string m_sDragon = "Journey_IsamosDragon_510";
	string m_sTamedDragon = "Journey_IsamosDragon_510_1";
	
	string m_sDragonFighter = "Journey_DragonFighter_510";

	/*	--------------------------------------------------
	*	Not used at all now. Maybe activating random "free roam" 
	*	spawns on map launch will be a good idea
	*	--------------------------------------------------
	*/
	array<string> m_arrFreeRoamSpawns =
	{
		"FreeRoam_Spawn_1",
		"FreeRoam_Spawn_2",
		"FreeRoam_Spawn_3",
		"FreeRoam_Spawn_4",
		"FreeRoam_Spawn_5",
		"FreeRoam_Spawn_6",
		"FreeRoam_Spawn_7",
		"FreeRoam_Spawn_8",
		"FreeRoam_Spawn_9",
		"FreeRoam_Spawn_10",
		"FreeRoam_Spawn_11",
		"FreeRoam_Spawn_12",
		"FreeRoam_Spawn_13",
		"FreeRoam_Spawn_14",
		"FreeRoam_Spawn_15",
		"FreeRoam_Spawn_16",
		"FreeRoam_Spawn_17",
		"FreeRoam_Spawn_18",
		"FreeRoam_Spawn_19",
		"FreeRoam_Spawn_20",
		"FreeRoam_Spawn_21",
		"FreeRoam_Spawn_22",
		"FreeRoam_Spawn_23"
	};

	array<string> m_arrQuestSpawns =
	{
		"Bridge_DefenceSpawn",
		"ElvenMercenaries_HeroSpawn",
		"HybernianOffsprings_HeroSpawn_1",
		"HybernianOffsprings_HeroSpawn_2",
		"Sector3_DefenceSpawn",
		"Sector6_DefenceSpawn",
		"Sector7_DefenceSpawn",
		"Sector14_DefenceSpawn",
		"Sector17_DefenceSpawn",
		"Sector_7_10_PatrolSpawn",
		"Sector_9_23_PatrolSpawn",
		"Sector_11_4_PatrolSpawn",
		"Sector_12_5_PatrolSpawn",
		"Sector_15_16_PatrolSpawn",
		"Sectors_0_2_PatrolSpawn",
		"Sectors_22_13_PatrolSpawn"
	};

	array<string> m_arrHyberianTowers_Areas =
	{
		"Area_HyberianTower_1",
		"Area_HyberianTower_2",
		"Area_HyberianTower_3",
		"Area_HyberianTower_4",
		"Area_HyberianTower_5",
		"Area_HyberianTower_6",
		"Area_HyberianTower_7",
		"Area_HyberianTower_8",
		"Area_HyberianTower_9",
		"Area_HyberianTower_10",
		"Area_HyberianTower_11",
		"Area_HyberianTower_12",
		"Area_HyberianTower_13",
		"Area_HyberianTower_14",
		"Area_HyberianTower_15",
		"Area_HyberianTower_16",
		"Area_HyberianTower_17"
	};

	dictionary m_Sectors_Altars =
	{
		{"Sector_7", "SealBreakerAltar_SW"},
		{"Sector_17", "SealBreakerAltar_N"},
		{"Sector_6", "SealBreakerAltar_SE"}
	};

	array<string> m_arrEnemyBaseSectors =
	{
		"Sector_14", // Hybernians
		"Sector_6" // Elven mercenaries
	};

	array<string> m_arrDragonBossSpells =
	{
		"Dragon_Argamar_ContinousStream",
		"Dragon_Argamar_Spit",
		"Dragon_Argamar_Shatter"
	};

	uint m_iTimeToNextReinforcement = 5 * 60;
	string m_sReinforcementsTier = "_I";

	uint m_iChargedSealBreakers = 0;

	bool m_bDragonTamed = false;
	bool m_bDragonCanBeTamed = false;

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
		// Events for updating flow depending on what seal-breakers are charged
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.RegisterBuildingEventByDescription(Charged, TOnBuildingEvent(@this.OnBuildingCharged_SealBreakerAltar), "Journey_SealBreakerAltar_510", _uFaction);
			m_Reference.RegisterBuildingEventByDescription(ProductionFinished, TOnBuildingEvent(@this.OnSpellCasted_SealBreakerAltar), "Journey_SealBreakerAltar_510", _uFaction);
		}

		// Failing the quest if the dragon is killed
		m_Reference.RegisterCreatureEventByIndividual(Killed, TOnCreatureEvent(@this.OnKilled_IsamosDragon), m_sDragon, "");

		// Event for taming the dragon
		m_Reference.RegisterCreatureEventByIndividual(Damaged, TOnCreatureEvent(@this.OnDamaged_IsamosDragon), m_sDragon, "");

		// Events that handle dragon fighters debuffing the dragon
		Creature[] _DragonFighters = m_Reference.FindCreaturesByDescription(m_iDragonFighters, m_sDragonFighter);
		m_Reference.RegisterCreatureEventByIndividuals(CanSee, TOnCreatureEvent(@this.OnCanSee_TamedDragon), _DragonFighters, true, m_sTamedDragon);

		// Events for handling altars on conquering and losing sectors with them
		for (uint i = 0; i < m_Sectors_Altars.getKeys().length(); ++i)
		{
			string _sAltarSector = m_Sectors_Altars.getKeys()[i];
			m_Reference.RegisterSectorEvent(OwnerChanged, TOnSectorEvent(@this.OnOwnerChanged_AltarSector), _sAltarSector);
		}

		// Lose conditions for enemies on destroyed main base
		for (uint i = 0; i < m_arrEnemyBaseSectors.length(); ++i)
		{
			m_Reference.RegisterSectorEvent(OwnerChanged, TOnSectorEvent(@this.BaseSectorLost), m_arrEnemyBaseSectors[i] );
		}

		// Events for disabling Rohen's theme music once any player controlled heroes get into combat
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.RegisterHeroPartyEvent(HeroAttacking, TOnCreatureEvent(@this.OnHeroAttacking_DisableRohensTheme), "", _uFaction);
		}
	}

	/*
		Is called right at the beginning of the level. Should only be used to start a dialoge, or directly stage an event and so on.
	*/
	void InitCommon ()
	{
		ActivateRandomLoot(100);
		
		// Events for activating FX on using altars' spells should be registered

		//Activating quest relevant spawns
		for (uint i = 0; i < m_arrQuestSpawns.length(); ++i)
		{
			m_Reference.ActivateSpawn( m_arrQuestSpawns[i], true );
		}

		// Init hyberian towers
		AddAATurrets(17, "Journey_510_HyberianTowerSpell", "HyberianTower_");

		// Handling altars
		for (uint i = 0; i < m_Sectors_Altars.getKeys().length(); ++i)
		{
			string _key = m_Sectors_Altars.getKeys()[i];
			string _sSealBreakerAltar;
			m_Sectors_Altars.get(_key, _sSealBreakerAltar);
			Building _QuestAltar = m_Reference.GetBuildingByName(_sSealBreakerAltar);
			_QuestAltar.SetCustomState(Script1, true);
			_QuestAltar.ProhibitProduction(Spell, "Journey_510_ChargedDragonHeal", true);
			_QuestAltar.SetFaction(kFactionNeutral);
			_QuestAltar.SetIndestructible(true);
		}

		// Sealing the dragon
		m_Reference.BlockNavMesh("NavBlocker_DragonSeal_W", true ); 
		m_Reference.BlockNavMesh("NavBlocker_DragonSeal_E", true );

		SetupIntroCreatures(m_sRohenTahir, m_sMapIntroTopic);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- E V E N T  F U N C T I O N S ----------------------------------------------------------------------------------

	bool OnHeroAttacking_DisableRohensTheme(Creature&in _Creature)
	{
		m_Reference.UnregisterHeroPartyEvent(HeroAttacking, TOnCreatureEvent(@this.OnHeroAttacking_DisableRohensTheme));
		m_Reference.SetGlobalSoundParameter(kMaxFactions, uint8(-1), "loop", 0);
		PlaySetting_Reset("");

		return true;
	}

	// Factions lose conditions
	bool BaseSectorLost(Sector@ _Sector, const uint8 _iPreviousOwner, const uint8 _iNewOwner)
	{
		if ( _iPreviousOwner == m_iElvenMercenaries && _iNewOwner == kFactionNeutral )
		{
			m_Reference.LoseGame(m_iElvenMercenaries);
			m_Reference.LoseGame(m_iElvenMercenaries_Defence);
		}
		else if ( _iPreviousOwner == m_iHybernianOffsprings && _iNewOwner == kFactionNeutral )
		{
			m_Reference.LoseGame(m_iHybernianOffsprings);
			m_Reference.LoseGame(m_iHybernianOffsprings_Defence);
			m_Reference.LoseGame(m_iDragonFighters);
			Building[] _HybernianTowers = m_Reference.FindBuildingsByDescription(m_iHybernianOffsprings, "Journey_HyberianTower_510");
			for (uint i = 0; i < _HybernianTowers.length(); ++i)
			{
				_HybernianTowers[i].Destroy();
			}
			m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_510, "DestroyEnemyBase", true);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_510, "DestroyEnemyBase", Completed);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_510, "ReinforcementsTimer", Completed);
			RohenFinalTalkSetup();
		}
		return false;
	}

	bool OnKilled_IsamosDragon(Creature&in _Creature)
	{
		m_Reference.GetSharedJournal().SetQuestState(m_sMainQuest_510, Failed);
		return true;
	}

	bool OnKilled_TamedDragon(Creature&in _Creature)
	{
		m_Reference.GetSharedJournal().SetQuestState(m_sMainQuest_510, Failed);
		return true;
	}

	// We need this targets per tower limit for performance reasons
	array<uint> m_uTargetsPerTower(17);
	// Hybernian towers related events
	bool OnEnteredArea_HyberianTower(Creature&in _Creature, uint _uTowerNumber)
	{
		if(m_Reference.GetBuildingByName("HyberianTower_"+_uTowerNumber).Exists() == false)
		{
			return true;
		}
		if(m_uTargetsPerTower[_uTowerNumber-1] <= 5)
		{
			m_uTargetsPerTower[_uTowerNumber-1]++;
			AATurretFireAt(_uTowerNumber, _Creature.GetId());
			string _sAttackedCreatureId = _Creature.GetId();
			string _sTowerId = _uTowerNumber-1;
			m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.TurretFire_Timer), 2000, _sAttackedCreatureId);
			m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.TargetsCleanUp_Timer), 2000, _sTowerId);
		}
		return false;
	}

	bool TurretFire_Timer(const string& in _sAttackedCreatureId)
	{
		uint _uId = uint(parseInt(_sAttackedCreatureId));
		Creature _AttackedCreature = m_Reference.GetCreatureById(_uId);
		if(_AttackedCreature.Exists() && _AttackedCreature.GetCurrentHP() > 0)
		{
			for(uint i = 0; i < m_arrHyberianTowers_Areas.length(); ++i)
			{
				if(m_Reference.GetBuildingByName("HyberianTower_"+(i+1)).Exists() && IsCreatureInsideArea(_AttackedCreature, m_arrHyberianTowers_Areas[i]))
				{
					AATurretFireAt(i+1, _AttackedCreature.GetId());
					m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.TurretFire_Timer), 2000, _sAttackedCreatureId);
				}
			}
		}
		return true;
	}

	bool TargetsCleanUp_Timer(const string& in _sTowerId)
	{
		uint _uTowerId = uint(parseInt(_sTowerId));
		m_uTargetsPerTower[_uTowerId]--;
		return true;
	}

	// Sectors events
	bool OnOwnerChanged_AltarSector( Sector@ _Sector, const uint8 _uPreviousOwnerFaction, const uint8 _uNewOwnerFaction )
	{
		// Getting factions present at the level start 
		array<uint8> _arrPlayers = m_Reference.GetPlayerFactions(false);
		string _sSector = _Sector.GetName();
		string _sSealBreakerAltar;
		m_Sectors_Altars.get(_sSector, _sSealBreakerAltar);
		if(_arrPlayers.find(_uPreviousOwnerFaction) != -1)
		{
			print("Player faction "+_uPreviousOwnerFaction+" lost "+_sSealBreakerAltar+" by losing "+_sSector);
			m_Reference.GetBuildingByName(_sSealBreakerAltar).SetFaction(kFactionNeutral);
		}
		else if(_arrPlayers.find(_uNewOwnerFaction) != -1)
		{
			print("Now faction "+_uNewOwnerFaction+" can charge "+_sSealBreakerAltar+" because it conquered "+_sSector);
			m_Reference.GetBuildingByName(_sSealBreakerAltar).SetFaction(_uNewOwnerFaction);
		}
		return false;
	}

	// Seal-breakers related events
	bool OnBuildingCharged_SealBreakerAltar(Building&in _Building)
	{
		string _sChargedSealBreaker = m_Reference.FindEntityName(_Building);
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_510, "Charge_"+_sChargedSealBreaker, Completed);
		m_iChargedSealBreakers++;
		_Building.SetCustomState(Script2, true);
		print(_sChargedSealBreaker+" was charged now. Currently "+m_iChargedSealBreakers+" seal breakers are charged");
		if(m_iChargedSealBreakers == 3)
		{
			m_Reference.EnableGroup("DragonSealsFX_W", false, true);
			m_Reference.EnableGroup("DragonSealsFX_E", false, true);
			m_Reference.BlockNavMesh("NavBlocker_DragonSeal_W", false ); 
			m_Reference.BlockNavMesh("NavBlocker_DragonSeal_E", false );
			m_Reference.UnregisterBuildingEvent(Charged, TOnBuildingEvent(@this.OnBuildingCharged_SealBreakerAltar));
			return true;
		}
		else
			return false;
	}

	bool OnSpellCasted_SealBreakerAltar(Building&in _Building)
	{
		Creature _TamedDragon = m_Reference.GetCreatureByName(m_sTamedDragon);
		if(_TamedDragon.Exists() && _TamedDragon.HasCondition(51006))
		{
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_510, "HealHint", Completed);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_510, "HealHint_SealBreakerAltar_N", Completed);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_510, "HealHint_SealBreakerAltar_SW", Completed);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_510, "HealHint_SealBreakerAltar_SE", Completed);
			m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_510, "HealTheDragon", Completed);
			m_Reference.UnregisterBuildingEvent(ProductionFinished, TOnBuildingEvent(@this.OnSpellCasted_SealBreakerAltar));
			return true;
		}
		return false;
	}

	// Dragon boss fight	
	bool OnDamaged_IsamosDragon(Creature&in _Creature)
	{
		// Shoutout hint that the artifact can be used on the dragon
		if(_Creature.GetCurrentHP() <= PercentOf( _Creature.GetMaxHP(), 25) && !m_bDragonCanBeTamed)
		{
			m_bDragonCanBeTamed = true;
			JourneyExplorationShoutout(m_Reference.GetCreatureByName(m_sDragon), "Journey_510_SO_ArtifactUseHint");
			m_Reference.SetTimer(TOnTimerEvent(@this.UseArtifactShoutout_Timer), 10);
		}
		// Taming dragon
		if (_Creature.GetCurrentHP() <= PercentOf( _Creature.GetMaxHP(), 25) && _Creature.HasCondition(51005) && !m_bDragonTamed)
		{
			m_bDragonTamed = true;
			_Creature.ForceCast(m_Reference, "Journey_508_RiftChannel", m_Reference.GetCreatureById(m_iHostAvatarId), false);
			m_Reference.SetTimerMS(TOnTimerEvent(@this.FadeToColor_Timer), 1000);
		}
		return false;
	}

	bool UseArtifactShoutout_Timer()
	{
		JourneyExplorationShoutout(m_Reference.GetCreatureByName(m_sDragon), "Journey_510_SO_ArtifactUseHint");
		return false;
	}

	bool FadeToColor_Timer()
	{
		m_Reference.FadeToColor(uint8(-1), 0, 255, 255, 255, 400);
		m_Reference.SetTimerMS(TOnTimerEvent(@this.HandleDragons_Timer), 500);
		m_Reference.SetTimerMS(TOnTimerEvent(@this.AnimTamedDragon_Timer), 700);
		m_Reference.SetTimerMS(TOnTimerEvent(@this.FadeFromColor_Timer), 1500);
		m_Reference.CancelTimer(TOnTimerEvent(@this.UseArtifactShoutout_Timer));

		return true;
	}

	bool HandleDragons_Timer()
	{
		m_Reference.CastSpell("Journey_510_DragonSummon", m_Reference.GetHostFaction(), m_Reference.GetCreatureByName(m_sDragon));
		m_Reference.UnregisterCreatureEvent(Killed, TOnCreatureEvent(@this.OnKilled_IsamosDragon));
		m_Reference.UnregisterCreatureEvent(Damaged, TOnCreatureEvent(@this.OnDamaged_IsamosDragon));
		m_Reference.GetCreatureByName(m_sDragon).Kill();
		m_Reference.GetCreatureByName(m_sDragon).Enable(false);	
		return true;
	}

	bool AnimTamedDragon_Timer()
	{
		// This animation is needed that newly summoned dragon looks in the same direction as thre previous one
		m_Reference.GetCreatureByName(m_sTamedDragon).PlayAnimation(m_Reference, IdleAlerted, -1, 3000, false, false, Entity(m_Reference.GetCreatureById(m_iHostAvatarId)), false, false, false);
		return true;
	}

	bool FadeFromColor_Timer()
	{
		Creature _TamedDragon = m_Reference.GetCreatureByName(m_sTamedDragon);
		m_Reference.RegisterCreatureEventByIndividual(Killed, TOnCreatureEvent(@this.OnKilled_TamedDragon), m_sTamedDragon, "");
		_TamedDragon.Damage(Irresistible, PercentOf( _TamedDragon.GetMaxHP(), 75));
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_510, "TameTheDragon_Hint", Completed);
		m_Reference.GetSharedJournal().SetTaskState(m_sMainQuest_510, "TameTheDragon", Completed);

		// Handling tamed dragon spellcasting ability
		for (uint i = 0; i < m_arrDragonBossSpells.length(); ++i)
		{
			_TamedDragon.RemoveSpell(m_Reference, m_arrDragonBossSpells[i]);
		}
		_TamedDragon.AddSpell(m_Reference, "Journey_510_TamedDragonBreath", false);
		m_Reference.RegisterCreatureEventByIndividual(SpellImpact, TOnCreatureSpellEvent(@this.OnSpellImpact_DragonBreath), m_sTamedDragon, "");
		m_Reference.FadeFromColor(uint8(-1), 0, 255, 255, 255, 400);

		// Now altars can heal the dragon
		for (uint i = 0; i < m_Sectors_Altars.getKeys().length(); ++i)
		{
			string _key = m_Sectors_Altars.getKeys()[i];
			string _sSealBreakerAltar;
			m_Sectors_Altars.get(_key, _sSealBreakerAltar);
			m_Reference.GetBuildingByName(_sSealBreakerAltar).ClearProhibitions();
			m_Reference.SetTimerMS(TOnTimerEvent(@this.HealDragonHintShoutout_Timer), 2500);
		}

		// Activating aggresive behavior for hybernian faction
		m_Reference.SetAIFlag(m_iHybernianOffsprings, CanAttack, true);
		m_Reference.SetAIFlag(m_iHybernianOffsprings, CanScout, true);
		m_Reference.SetAIFlag(m_iHybernianOffsprings, CanExpand, true);
		return true;
	}

	bool HealDragonHintShoutout_Timer()
	{
		JourneyExplorationShoutout(m_Reference.GetCreatureByName(m_sTamedDragon), "Journey_510_SO_HealDragonHint");
		return true;
	}

	// Destroying Hybernian towers on contact with dragon spell
	bool OnSpellImpact_DragonBreath(Creature&in _Creature, const string&in _sSpellName, Entity[]&in _Targets)
	{
		print("how many targets were hit by dragon breath spell: "+_Targets.length());

		for (uint i = 0; i < _Targets.length(); i++)
		{
			if (_Targets[i].GetEntityType() == Building)
			{
				string _sBuildingDescription = Building(_Targets[i]).GetDescriptionName();
				print(_sBuildingDescription);

				if (_sBuildingDescription == "Journey_HyberianTower_510")
				{	
					print("building destroyed by dragon breath spell: "+Building(_Targets[i]).GetDescriptionName());
					Building(_Targets[i]).Destroy();
				}
			}
		}
		return false;
	}

	// Dragon fighters debuff dragon
	bool OnCanSee_TamedDragon(Creature&in _Creature)
	{
		Creature _Dragon = m_Reference.GetCreatureByName(m_sTamedDragon);
		_Creature.ForceCast(m_Reference, "Journey_510_TamedDragonDebuff_Channel", _Dragon, false);
		_Creature.SetImmovable(true);
		JourneyExplorationShoutout(_Dragon, "Journey_510_SO_DragonsMovementStiffled");
		// Dragon fighters should also channel debuffs after being interupted
		return false;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- A R T I C Y  F U N C T I O N S --------------------------------------------------------------------------------

	void RevealDragonArea()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("DragonSummon_Spot"));
		
		JourneyRevealArea("DragonReveal_Area", 10);
	}

	void RevealSealBreakersAltars()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("SealBreakerAltar_CameraSpot"));
		
		for (uint i = 0; i < m_Sectors_Altars.getKeys().length(); ++i)
		{
			string _key = m_Sectors_Altars.getKeys()[i];
			string _sSealBreakerAltar;
			m_Sectors_Altars.get(_key, _sSealBreakerAltar);
			JourneyRevealArea("RevealArea_"+_sSealBreakerAltar, 10);
		}
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_510, "ChargeSealBreakers", true);
	}

	void GiveIsamosArtifact()
	{
		// Returning the camera back to the heroparty
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("RohensReinforcements_Spot"));
		}

		m_Reference.GetHeroParty(m_Reference.GetHostFaction()).AddItems(m_sIsamosArifact, 1 );
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_510, "TameTheDragon", true);
	}

	void RevealHybernianTowers()
	{
		for (uint i = 0; i < 10; ++i)
		{
			JourneyRevealArea(m_arrHyberianTowers_Areas[i], 10);
		}
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("HybernianTowers_CameraSpot"));
		}
		// Should we explicitly show here how towers operate? Like some wildlife trying to cross the bridge and being annihilated
	}

	void SpawnFirstReinforcemnts()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FocusCamera( m_Reference.GetPlayerFactions(true)[i], m_Reference.GetLogicObjectByName("RohensReinforcements_Spot"));
		}

		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_510, "ReinforcementsTimer", true);
		m_Reference.CreateCountdownTimer(0, m_iTimeToNextReinforcement, TOnTimerEvent(@this.SpawnReinforcements_LoopedTimer), m_Reference.GetHostFaction() , "Journey_510_TimeToNextReinforcement");
		SpawnReinforcements();
	}

	void RohenTakesBackArtifact()
	{
		uint8 _uHostFaction = m_Reference.GetHostFaction();
		for (uint i = 0; i < m_Reference.GetHeroParty(_uHostFaction).GetMembers().length(); ++i)
		{
			string _sEquipedItem = "";
			Creature _Hero = m_Reference.GetHeroParty(_uHostFaction).GetMembers()[i];
			_Hero.GetEquipment(Item, _sEquipedItem);
			if(_sEquipedItem == m_sIsamosArifact)
			{
				_Hero.Unequip(m_Reference, Item, AddToInventory, uint16 (- 1));
			}
		}
		m_Reference.GetHeroParty(_uHostFaction).RemoveItems(m_sIsamosArifact, 1 );
		m_Reference.GetCreatureByName(m_sTamedDragon).SetImmortal(true);
		m_Reference.GetCreatureByName(m_sTamedDragon).SetPlayerControllable(false);
		m_Reference.GetCreatureByName(m_sTamedDragon).GoTo(m_Reference, m_Reference.GetLogicObjectByName("DragonControlledByRohen_Spot"), 5, 10, false, false);

		// Changing Everlight weather
		SetEverlightWeather();
	}

	void PlayerSkippedMapIntro()
	{
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_510, "ChargeSealBreakers", true);
		m_Reference.GetHeroParty(m_Reference.GetHostFaction()).AddItems(m_sIsamosArifact, 1 );
		m_Reference.GetSharedJournal().ActivateTask(m_sMainQuest_510, "TameTheDragon", true);
		StartRTS();
	}

	void StartRTS()
	{
		InitialSectorsDistribution(m_PlayersInititalSectors);
		SpawnFirstReinforcemnts();
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- C U S T O M F U N C T I O N S ---------------------------------------------------------------------------------

	void SpawnReinforcements()
	{
		array<uint> _arrJoinedPlayers;
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			if (m_Reference.GetPlayerFactions(true)[i] != m_Reference.GetHostFaction())
				_arrJoinedPlayers.insertLast(m_Reference.GetPlayerFactions(true)[i]);

		// Increasing reinforcements tier depending on the quest flow
		if (m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_510, "TameTheDragon") == Completed)
		{
			m_sReinforcementsTier = "_II";
		}

		if (_arrJoinedPlayers.length() == 1)
			m_Reference.CastSpell("Journey_510_ReinforcementsSpawn"+m_sReinforcementsTier, _arrJoinedPlayers[0], m_Reference.GetLogicObjectByName("RohensReinforcements_Spot"));
		else if (_arrJoinedPlayers.length() == 2)
		{
			m_Reference.CastSpell("Journey_510_ReinforcementsSpawn_Shortened"+m_sReinforcementsTier, _arrJoinedPlayers[0], m_Reference.GetLogicObjectByName("RohensReinforcements_Spot"));
			m_Reference.CastSpell("Journey_510_ReinforcementsSpawn_Shortened"+m_sReinforcementsTier, _arrJoinedPlayers[1], m_Reference.GetLogicObjectByName("RohensReinforcements_Spot"));
		}
		else if (_arrJoinedPlayers.length() == 0)
			m_Reference.CastSpell("Journey_510_ReinforcementsSpawn"+m_sReinforcementsTier, m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName("RohensReinforcements_Spot"));
	}
	bool SpawnReinforcements_LoopedTimer()
	{
		if(m_Reference.GetSharedJournal().GetTaskState(m_sMainQuest_510, "DestroyEnemyBase") != Completed)
		{
			SpawnReinforcements();
			m_Reference.CreateCountdownTimer(0, m_iTimeToNextReinforcement, TOnTimerEvent(@this.SpawnReinforcements_LoopedTimer), m_Reference.GetHostFaction() , "Journey_510_TimeToNextReinforcement");
		}
		return true;
	}

	void RohenFinalTalkSetup()
	{
		m_Reference.GetCreatureByName(m_sRohenTahir).PlayAnimation(m_Reference, CastInstantSelf, -1, 700, false, false, Entity ( ), false, false, false);
		m_Reference.SetTimerMS(TOnTimerEvent( @this.RohenTeleportFX_Timer ), 600);
		m_Reference.SetTimerMS(TOnTimerEvent( @this.RohenTeleport_Timer ), 800);
		m_Reference.CastSpell("Journey_500_TeleportMessenger", m_iRohen_Faction, m_Reference.GetCreatureByName(m_sRohenTahir));
	}
	bool RohenTeleportFX_Timer()
	{
		m_Reference.CastSpell("Journey_500_TeleportMessenger", m_iRohen_Faction, m_Reference.GetLogicObjectByName("RohenTeleportation_Spot"));		
		return true;
	}
	bool RohenTeleport_Timer()
	{
		m_Reference.GetCreatureByName(m_sRohenTahir).Teleport(m_Reference, m_Reference.GetLogicObjectByName("RohenTeleportation_Spot"));		
		JourneyDialogShoutout(m_sRohenTahir, m_sRohenTahir, "Journey_510_SO_TeleportsToDestroyedEnemyBase");
		return true;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- D E B U G ---------------------------------------------------------------------------------

	void hostDragon()
	{
		m_Reference.GetCreatureByName(m_sDragon).Stop(m_Reference);
		m_Reference.GetCreatureByName(m_sDragon).SetSelectable(true);
		m_Reference.GetCreatureByName(m_sDragon).SetImmortal(true);
		//m_Reference.GetCreatureByName(m_sDragon).SetFaction(m_Reference.GetHostFaction());
		m_Reference.GetCreatureByName(m_sDragon).SetPlayerControllable(true);
	}
	void testCharge(string _sSealName)
	{
		m_Reference.GetBuildingByName(_sSealName).SetCustomState(Script2, true);
	}
	void testOwner(string _sSealName)
	{
		m_Reference.GetBuildingByName(_sSealName).SetFaction(m_Reference.GetHostFaction());
	}
	void testLock(string _sSealName)
	{
		m_Reference.GetBuildingByName(_sSealName).ProhibitProduction(Spell, "Journey_510_ChargedDragonHeal", true);
	}
	void testFade()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.FadeToColorAndBack(m_Reference.GetPlayerFactions(true)[i], 0, 255, 255, 255, 500, 0);
		}
	}
	void hurtDragon()
	{
		Creature _Dragon = m_Reference.GetCreatureByName(m_sDragon);
		_Dragon.Damage(Irresistible, PercentOf(_Dragon.GetMaxHP(), 75));
	}
	void healDragon()
	{
		m_Reference.GetCreatureByName(m_sTamedDragon).Heal(50000);
	}
}
