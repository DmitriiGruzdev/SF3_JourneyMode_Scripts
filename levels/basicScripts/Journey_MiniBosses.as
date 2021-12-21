mixin class Journey_MiniBosses
{
	string m_sMiniBossQuest;
	string m_sMiniBoss;

	bool m_bMusic_MiniBoss = false;
	uint m_uAggroRange_MiniBoss = 300;

	string m_sGlobalMinibossTrophiesQuest = "Journey_Global_CollectMinibossTrophies";

	/*	--------------------------------------------------
	*	Quest items that players get as quest rewards for
	*	completing miniboss side quests on respective maps.
	*	Needed to complete Journey_Global_CollectMinibossTrophies
	*	quest
	*	--------------------------------------------------
	*/
	array<string> m_arrGlobalMiniBossTrophies =
	{
		"Journey_MiniBossTrophy_502",
		"Journey_MiniBossTrophy_503",
		"Journey_MiniBossTrophy_504",
		"Journey_MiniBossTrophy_505",
		"Journey_MiniBossTrophy_506",
		"Journey_MiniBossTrophy_507",
		"Journey_MiniBossTrophy_508",
		"Journey_MiniBossTrophy_510"
	};

	array<uint> m_arrMinibossSummonsIds = {};

	/*	--------------------------------------------------
	*	Fired on map launch if it has a miniboss quest
	*	--------------------------------------------------
	*/
	void InitSideQuest_MiniBoss(string _sQuestName)
	{
		m_sMiniBossQuest = _sQuestName;

		Creature[] _MiniBosses = m_Reference.GetCreaturesFromSpawn("MiniBoss_Spawn");
		uint _uRandom = m_Reference.GetRandom().GetInteger(0, _MiniBosses.length());
		m_sMiniBoss = m_Reference.FindEntityName(_MiniBosses[_uRandom]);
		m_Reference.RegisterCreatureEventByIndividuals(Killed, TOnCreatureEvent(@this.OnKilled_MiniBoss), _MiniBosses, true, "");
		m_Reference.RegisterCreatureEventByIndividuals(Damaged, TOnCreatureEvent(@this.OnDamaged_MiniBoss), _MiniBosses, true, "");
		m_Reference.RegisterCreatureEventByIndividuals(EnteredAggroRange, TOnCreatureEvent(@this.OnEnteredAggroRange_MiniBoss), _MiniBosses, true, "Enemy");
		m_Reference.RegisterCreatureEventByIndividuals(SummonedCreatures, TOnCreatureEvent(@this.OnSummonedCreatures_MiniBoss), _MiniBosses, true, "");
		for (uint i = 0; i < _MiniBosses.length(); i++)
		{
			if(i != _uRandom)
			{
				_MiniBosses[i].Enable(false);
			}
		}

		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.RegisterCreatureEventByDescription(EnteredArea, TOnCreatureEvent(@this.OnEnteredArea_MiniBossQuestTrigger), "", _uFaction, "MiniBoss_Trigger");
		}
	}

	bool OnEnteredArea_MiniBossQuestTrigger(Creature &in _Creature)
	{
		if(m_Reference.GetSharedJournal().IsQuestActive(m_sMiniBossQuest) == false)
		{
			StartMinibossFight(_Creature);
		}

		return true;
	}

	bool OnEnteredAggroRange_MiniBoss(Creature &in _Creature)
	{
		if(m_Reference.GetSharedJournal().IsQuestActive(m_sMiniBossQuest))
		{
			return true;
		}
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			for (uint j = 0; j < GetLivingCreaturesByFaction(_uFaction).length(); ++j)
			{
				Creature _PlayersCreature = GetLivingCreaturesByFaction(_uFaction)[j];
				if(m_Reference.GetCreatureByName(m_sMiniBoss).IsInAggroRange(m_Reference, _PlayersCreature))
				{
					StartMinibossFight(_PlayersCreature);
					return true;
				}
			}
		}

		return false;
	}

	bool OnKilled_MiniBoss(Creature &in _Creature)
	{
		m_Reference.GetSharedJournal().SetTaskState(m_sMiniBossQuest, "KillMiniBoss", Completed);
		m_Reference.GetLogicObjectByName("MiniBoss_Chest").Unlock();
		m_Reference.GetLogicObjectByName("MiniBoss_ChestFX").Enable(false);
		if(_Creature.GetDescriptionName() != "Journey_MB_InsectFire")
		{
			_Creature.SetPreserveBody(true);
		}

		array<Creature> tempSummonsContainer = _Creature.GetSummonedCreatures(m_Reference);
		if(tempSummonsContainer.length() > 0)
		{
			for(uint i = 0; i < tempSummonsContainer.length(); i++)
			{
				tempSummonsContainer[i].Kill();
			}	
		}

		return true;
	}

	/*	--------------------------------------------------
	*	When a miniboss reaches certain HP value we apply
	*	sort of 'enraged' buff to it
	*	--------------------------------------------------
	*/
	bool OnDamaged_MiniBoss(Creature &in _Creature)
	{
		if(_Creature.GetCurrentHP() <= PercentOf( _Creature.GetMaxHP(), 30))
		{
			_Creature.ApplyCondition(51031, -1, kMaxFactions, 100);
			return true;
		}

		return false;
	}

	/*	--------------------------------------------------
	*	We constatnly update an array of ids of active miniboss
	*	summons in order to use it in OnKilled_DropGlobalCollectible
	*	event in LevelBase to prevent antique coins farming
	*	through these summons
	*	--------------------------------------------------
	*/
	bool OnSummonedCreatures_MiniBoss(Creature &in _Creature)
	{
		array<uint> _temp = {};
		Creature[] _MinibossSummons = m_Reference.GetCreatureByName(m_sMiniBoss).GetSummonedCreatures(m_Reference);
		for (uint i = 0; i < _MinibossSummons.length(); ++i)
		{
			_temp.insertLast(_MinibossSummons[i].GetId());
		}
		m_arrMinibossSummonsIds = _temp;
		return false;
	}

	/*	--------------------------------------------------
	*	Called either by OnEnteredAggroRange_MiniBoss or 
	*	OnEnteredArea_MiniBossQuestTrigger, starts miniboss 
	*	fight sequence
	*	--------------------------------------------------
	*/
	void StartMinibossFight(Creature _Creature)
	{
		m_Reference.GetSharedJournal().ActivateQuest(m_sMiniBossQuest, true);
		m_Reference.GetSharedJournal().ActivateTask(m_sGlobalMinibossTrophiesQuest, "Find_Journey_MiniBossTrophy_"+GetString_CurrentMapId(), true);
		JourneyExplorationShoutout(_Creature, "Journey_GenericDialogue_RandomMinibossReaction");

		Creature _MiniBoss = m_Reference.GetCreatureByName(m_sMiniBoss);
		_MiniBoss.ForceCast(m_Reference, m_sMiniBoss+"_MiniBossSpell", _MiniBoss, false);
		m_Reference.RegisterCreatureEventByIndividual(SpellFinished, TOnCreatureSpellEvent(@this.OnSpellFinished_ApplySummonsBehaviour), m_sMiniBoss, "");
		if(_MiniBoss.IsInAggroRange(m_Reference, _Creature) == false)
		{
			_MiniBoss.AttackPosition(m_Reference, _Creature, true, false);	
		}
	}
	
	/*	--------------------------------------------------
	*	Fired in RegisterEvents_Gameplay in LevelBase.
	*	Registers events for updating trophies collectibles
	*	quest once they are added in players' inventories
	*	--------------------------------------------------
	*/
	void RegisterMinibossTrophies()
	{
		for(uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			for(uint j = 0; j < m_arrGlobalMiniBossTrophies.length(); ++j)
			{
				if(m_Reference.GetJournal(_uFaction).GetTaskState(m_sGlobalMinibossTrophiesQuest, "Find_"+m_arrGlobalMiniBossTrophies[j]) == Unfinished)
				{
					m_Reference.RegisterInventoryEvent(Added, TOnInventoryEvent(@this.OnAdded_UpdateMinibossTrophiesQuest), m_arrGlobalMiniBossTrophies[j], _uFaction);
				}
			}
		}
	}

	bool OnAdded_UpdateMinibossTrophiesQuest(const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		m_Reference.GetJournal(_uPlayerFaction).SetTaskState(m_sGlobalMinibossTrophiesQuest, "Find_"+_sItemName, Completed);
		return true;
	}

	/*	--------------------------------------------------
	*	Used for debug of Journey_Global_CollectMinibossTrophies
	*	quest
	*	--------------------------------------------------
	*/
	void AddAllTrophies()
	{
		for(uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			for(uint j = 0; j < m_arrGlobalMiniBossTrophies.length(); ++j)
			{
				m_Reference.GetHeroParty(_uFaction).AddItems(m_arrGlobalMiniBossTrophies[j], 1, true);
			}
		}
	}

	void AddTrophy(uint _uMapId)
	{
		for(uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.GetHeroParty(_uFaction).AddItems("Journey_MiniBossTrophy_"+_uMapId, 1, true);
		}
	}

	/*	--------------------------------------------------
	*	With this event we can trigger certain script funcitons
	*	which we want to be played based on spell suffix
	*	once its casted
	*	--------------------------------------------------
	*/
	bool OnSpellFinished_ApplySummonsBehaviour(Creature&in _Creature, const string&in _sSpellName, Entity[]&in _Targets)
	{
		int _idivide = _sSpellName.findLast("_", - 1);
		string _sSpellSuffix = _sSpellName.substr(_idivide, - 1);
		if(_sSpellSuffix == "_SummonMobsWithChannelSpell")
		{
			m_Reference.SetTimerMS(TOnTimerEvent(@this.SummonsChannelSpell_Timer), 500);
		}
		else if(_sSpellName == "Journey_MB_DemonSummoner_MiniBossSpell")
		{
			DemonSummoner_MiniBossSpell();
		}
		return false;
	}

	bool SummonsChannelSpell_Timer()
	{
		Creature _MiniBoss = m_Reference.GetCreatureByName(m_sMiniBoss);
		array<Creature> tempSummonsContainer = _MiniBoss.GetSummonedCreatures(m_Reference);
		if(tempSummonsContainer.length() > 0)
		{
			string _sChannelSpell = m_sMiniBoss + "_Summon_ChannelSpell";
			for(uint i = 0; i < tempSummonsContainer.length(); i++)
			{
				if(tempSummonsContainer[i].GetDescriptionName() == m_sMiniBoss+"_Summon")
				{
					tempSummonsContainer[i].ForceCast(m_Reference, _sChannelSpell, _MiniBoss, false);
				}
			}	
		}

		return true;
	}

	/*	--------------------------------------------------
	*	Called once Journey_MB_DemonSummoner casts its'
	*	_MiniBossSpell'
	*	--------------------------------------------------
	*/
	void DemonSummoner_MiniBossSpell()
	{
		Creature[] tempCreaturesContainer = m_Reference.FindCreaturesInArea("MiniBoss_Trigger");
		for (uint i = 0; i < tempCreaturesContainer.length(); ++i)
		{
			if(tempCreaturesContainer[i].GetDescriptionName() == "Journey_AlienDemon_508")
			{
				m_Reference.CastSpell("Journey_MB_DemonSummoner_InitialSummon", m_Reference.GetCreatureByName(m_sMiniBoss).GetFaction(), tempCreaturesContainer[i]);
				tempCreaturesContainer[i].Kill();
				tempCreaturesContainer[i].Enable(false);
			}
		}
	}

	/*	--------------------------------------------------
	*	Called on activation of miniboss sidequests which take place on
	*	rpg maps without dynamic combat music enabled by default.
	*	--------------------------------------------------
	*/
	void StartMinibossMusic()
	{
		m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.OnTimer_HeropartyDistance_MiniBoss), 100, "" + m_uAggroRange_MiniBoss);		
	}

	bool OnTimer_HeropartyDistance_MiniBoss(const string& in _sDistance)
	{
		uint uDistance = uint(parseInt(_sDistance));
		if(m_Reference.GetCreatureByName(m_sMiniBoss).Exists() == false || m_Reference.GetCreatureByName(m_sMiniBoss).GetCurrentHP() <= 0 )
		{
			return true;
		}
		if(JourneyHeropartyOutOfRange(Entity(m_Reference.GetCreatureByName(m_sMiniBoss)), uDistance) == true &&
		m_bMusic_MiniBoss == true)
		{
			m_bMusic_MiniBoss = false;
			m_Reference.SuspendAutomaticCombatMusic(uint8(-1), uint8(-1), false);	
			m_Reference.SetGlobalSoundParameter(uint8(-1), uint8(-1), "combat", 0);
			m_Reference.SetTimer(TOnTimerEvent(@this.OnTimer_ResetMinibossMusic), 25);
		}
		else if(JourneyHeropartyOutOfRange(Entity(m_Reference.GetCreatureByName(m_sMiniBoss)), uDistance) == false &&
				m_bMusic_MiniBoss == false)
		{
			m_bMusic_MiniBoss = true;
			if(GetString_CurrentMapId() == "503")
			{
				PlaySetting_grassland_med();	
			}
			else if(GetString_CurrentMapId() == "505" || GetString_CurrentMapId() == "508")
			{
				PlaySetting_mountains_med();
			}
			else
			{
				print("No music track is set for this map miniboss!");
			}
		}

		return false;
	}

	/*	--------------------------------------------------
	*	Called on complition of miniboss sidequests which take place on
	*	rpg maps without dynamic combat music enabled by default.
	*	--------------------------------------------------
	*/
	void StopMinibossMusic()
	{
		m_Reference.SuspendAutomaticCombatMusic(uint8(-1), uint8(-1), false);	
		m_Reference.SetGlobalSoundParameter(uint8(-1), uint8(-1), "combat", 0);
		m_bMusic_MiniBoss = false;
		m_Reference.CancelTimer(TOnTimerUserDataEvent(@this.OnTimer_HeropartyDistance_MiniBoss), "" + m_uAggroRange_MiniBoss);
		m_Reference.SetTimer(TOnTimerEvent(@this.OnTimer_ResetMinibossMusic), 25);
	}

	bool OnTimer_ResetMinibossMusic()
	{
		if(m_bMusic_MiniBoss == false)
		{
			PlaySetting_Reset("");
		}
		return true;
	}

	/*	--------------------------------------------------
	*	Used for debugging of MiniBoss rage condition
	*	--------------------------------------------------
	*/
	void TestRage()
	{
		Creature _Boss = m_Reference.GetCreatureByName(m_sMiniBoss);
		_Boss.Damage(Irresistible, PercentOf( _Boss.GetMaxHP(), 70));
	}
}

