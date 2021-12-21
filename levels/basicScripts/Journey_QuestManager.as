mixin class Journey_QuestManager
{
	dictionary m_JourneyMainQuests =
	{
		{"501", array<string> = {"Journey_501_Q0_StopCattleKiller"}}, 
		{"502", array<string> = {"Journey_502_Q0_HelpSettlersSurvive"}},
		{"503", array<string> = {"Journey_503_Q0_RefillTheMine"}},
		{"504", array<string> = {"Journey_504_Q0_DefendLathweyn"}},
		{"505", array<string> = {"Journey_505_Q0_CollectShaperArtifacts"}},
		{"506", array<string> = {"Journey_506_Q0_DefendFarlornsHope"}},
		{"507", array<string> = {"Journey_507_Q0_HelpIronFalcons"}},
		{"508", array<string> = {"Journey_508_Q0_ProtectIsamosArtefact"}},
		{"509", array<string> = {"Journey_509_Q0_SaveHostages"}},
		{"510", array<string> = {"Journey_510_Q0_TameDragonForIsamo"}}
	};

	dictionary m_JourneySideQuests =
	{
		{"502", array<string> = {"Journey_502_SQ0_Brigands"}},
		{"504", array<string> = {"Journey_504_SQ0_SaveSentientSpider"}},
		{"506", array<string> = {"Journey_506_SQ0_CollectResourcePickups"}},
		{"508", array<string> = {"Journey_508_SQ0_DefendRebelMages"}}
	};

	dictionary m_JourneyBossQuests =
	{
		{"502", array<string> = {"Journey_502_SQ_MiniBoss"}},
		{"503", array<string> = {"Journey_503_SQ_MiniBoss"}},
		{"504", array<string> = {"Journey_504_SQ_MiniBoss"}},
		{"505", array<string> = {"Journey_505_SQ_MiniBoss"}},
		{"506", array<string> = {"Journey_506_SQ_MiniBoss"}},
		{"507", array<string> = {"Journey_507_SQ_MiniBoss"}},
		{"508", array<string> = {"Journey_508_SQ_MiniBoss"}},
		{"510", array<string> = {"Journey_510_SQ_MiniBoss"}}
	};

	array<dictionary> m_arrJourneyQuestsDicts =
	{
		m_JourneyMainQuests,
		m_JourneySideQuests,
		m_JourneyBossQuests
	};

	/*	--------------------------------------------------
	*	Fired in OnCreated in LevelBase
	*	--------------------------------------------------
	*/
	void InitJourneyQuests()
	{
		for(uint i = 0; i < m_arrJourneyQuestsDicts.length(); ++i)
		{
			ResetJourneyQuests(m_arrJourneyQuestsDicts[i]);
		}

		array<string> _arrMainQuests;
		if(m_JourneyMainQuests.get(GetString_CurrentMapId(), _arrMainQuests))
		{
			for(uint i = 0; i < _arrMainQuests.length(); ++i)
			{
				ActivateQuest(_arrMainQuests[i]);
			}
		}	

		array<string> _arrBossQuests;
		if(m_JourneyBossQuests.get(GetString_CurrentMapId(), _arrBossQuests))
		{
			for(uint i = 0; i < _arrBossQuests.length(); ++i)
			{
				InitSideQuest_MiniBoss(_arrBossQuests[i]);
			}	
		}
	}

	/*	--------------------------------------------------
	*	Resets journey quests on map launch which should be activated
	*	during map runtime 
	*	--------------------------------------------------
	*/
	void ResetQuest(string _sQuestName)
	{
		m_Reference.GetSharedJournal().ResetQuest(_sQuestName);
	}

	/*	--------------------------------------------------
	*	Activates journey quests that should be activated
	*	on map launch
	*	--------------------------------------------------
	*/
	void ActivateQuest(string _sQuestName)
	{
		m_Reference.GetSharedJournal().ActivateQuest(_sQuestName, true);
	}

	/*	--------------------------------------------------
	*	Resets all Journey quests
	*	--------------------------------------------------
	*/
	void ResetJourneyQuests(dictionary _JourneyQuests)
	{
		array<string> _arrkeys = _JourneyQuests.getKeys();
		for(uint i = 0; i < _arrkeys.length(); ++i)
		{
			array<string> _arrQuests;
			_JourneyQuests.get(_arrkeys[i], _arrQuests);
			for(uint j = 0; j < _arrQuests.length(); ++j)
			{
				ResetQuest(_arrQuests[j]);
			}
		}
	}
}