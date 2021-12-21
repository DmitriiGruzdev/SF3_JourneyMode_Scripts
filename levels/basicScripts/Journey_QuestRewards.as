mixin class Journey_QuestRewards
{
	uint8 m_uPendingQuestRewards = 0;

	dictionary m_dictPendingQuestRewards = {};

	array<string> m_arrGlobalCollectiblesQuestRewards =
	{
		"Journey_Global_Invis_Reward_AntiqueCoins_01",
		"Journey_Global_Invis_Reward_AntiqueCoins_02",
		"Journey_Global_Invis_Reward_AntiqueCoins_03"
	};

	array<string> m_arrPendingGlobalCollectiblesRewards = {};

	/*	--------------------------------------------------
	*	Handles joureny quest rewards: makes sure that
	*	all players receive respective quest rewards
	*	before leaving the map. Called in articy quest object
	*	--------------------------------------------------
	*/
	void OnQuestCompleted_AddPendingQuestReward(string _sQuestName)
	{
		uint8 _uPlayersWithPendingRewards = 0;
		m_uPendingQuestRewards++;

		for(uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); i++)
		{
			uint8 _uFaction = m_Reference.GetPlayerFactions(true)[i];
			if(m_Reference.HasLostGame(_uFaction) == false)
			{
				Creature _Avatar = m_Reference.GetHeroParty(_uFaction).GetMembers()[0];
				if(m_uPendingQuestRewards == 1)
				{
					m_Reference.ShowQuestRewardWindow(_uFaction, m_Reference.GetHeroParty(_uFaction).GetControlIndex(_Avatar), _sQuestName);
				}

				_uPlayersWithPendingRewards++;
			}
		}

		m_dictPendingQuestRewards.set(_sQuestName, _uPlayersWithPendingRewards);
		array<string> _arrKeys = m_dictPendingQuestRewards.getKeys();
		for (uint i = 0; i < _arrKeys.length(); ++i)
		{
			uint8 _uRemainingPlayers;
			m_dictPendingQuestRewards.get(_arrKeys[i], _uRemainingPlayers);
			print(_uRemainingPlayers+" players need to get reward for "+_arrKeys[i]+" quest in order to win the map.");
		}

		m_Reference.GetSharedJournal().ActivateQuest("Journey_Global_CollectPendingRewards", true);

		OnGlobalCollectiblesQuestCompleted_BlockTravel(_sQuestName);
	}

	/*	--------------------------------------------------
	*	If global collectibles quest was submitted (Can only happen
	*	in Everlight), map travel will be blocked
	*	--------------------------------------------------
	*/
	void OnGlobalCollectiblesQuestCompleted_BlockTravel(string _sQuestName)
	{
		if(m_arrGlobalCollectiblesQuestRewards.find(_sQuestName) != -1)
		{
			m_Reference.GetWorld().AllowTravel(false);
			m_arrPendingGlobalCollectiblesRewards.insertLast(_sQuestName);
		}
	}

	/*	--------------------------------------------------
	*	Tracks and updates number of players who need to
	*	collect their quest rewards. If all pending quest rewards
	*	are collected by all active players, win condition is triggered.
	*	Called when RewardClaimed event is triggered 
	*	--------------------------------------------------
	*/
	void UpdatePendingQuestReward(string _sQuestName)
	{
		uint8 _uPlayersWithPendingRewards;
		m_dictPendingQuestRewards.get(_sQuestName, _uPlayersWithPendingRewards);
		_uPlayersWithPendingRewards--;
		m_dictPendingQuestRewards.set(_sQuestName, _uPlayersWithPendingRewards);
		
		if(_uPlayersWithPendingRewards == 0)
		{
			m_dictPendingQuestRewards.delete(_sQuestName);
			m_uPendingQuestRewards--;
		}

		if(m_dictPendingQuestRewards.isEmpty())
		{
			for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			{
				m_Reference.GetSharedJournal().SetTaskState("Journey_Global_CollectPendingRewards", "CollectPendingRewards", Completed);
				
				m_Reference.GetWorld().AllowTravel(true);
				m_Reference.GetWorld().SetWorldMapId(0);
				m_Reference.GetWorld().SetMapAccessible(0, true);

				ResetGlobalCollectiblesQuest();
			}
		}
		else
		{
			array<string> _arrKeys = m_dictPendingQuestRewards.getKeys();
			for (uint i = 0; i < _arrKeys.length(); ++i)
			{
				uint8 _uRemainingPlayers;
				m_dictPendingQuestRewards.get(_arrKeys[i], _uRemainingPlayers);
				print("Number of players who still have pending reward for quest "+_arrKeys[i]+": "+_uRemainingPlayers);
			}
		}
	}

	/*	--------------------------------------------------
	*	If there are any pending global collectibles quest
	*	on allowing map travel again, they will be reset
	*	so players will be able to complete them again straight off
	*	--------------------------------------------------
	*/
	void ResetGlobalCollectiblesQuest()
	{
		if(m_arrPendingGlobalCollectiblesRewards.length() != 0)
		{
			for(uint i = 0; i < m_arrPendingGlobalCollectiblesRewards.length(); ++i)
			{
				ResetQuest(m_arrPendingGlobalCollectiblesRewards[i]);
				m_arrPendingGlobalCollectiblesRewards.removeAt(i);
			}
		}
	}

	/*	--------------------------------------------------
	*	Registered in LevelBase with other specific Journey
	*	gameplay events
	*	--------------------------------------------------
	*/
	bool OnRewardClaimed_AllowTravel(const uint8 _uFaction, string&in _sDescriptionName)
	{
		if(m_dictPendingQuestRewards.exists(_sDescriptionName) == true)
		{
			UpdatePendingQuestReward(_sDescriptionName);
		}

		return false;
	}
}