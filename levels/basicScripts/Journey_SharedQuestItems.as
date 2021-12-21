mixin class Journey_SharedQuestItems
{
	array<string> m_arrRecentlyAddedSharedItems = {};
	array<string> m_arrRecentlyRemovedSharedItems = {};

	/*	--------------------------------------------------------
	*	Triggered when any item is added in player contolled 
	*	party's inventory. If it is a SharedQuestItem, then
	*	the item will be added to all other players as well
	*	--------------------------------------------------------
	*/

	bool OnAdded_CheckSharedQuestItem(const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		if(m_Reference.CheckItemProperty(_sItemName, SharedQuestItem) && m_arrRecentlyAddedSharedItems.find(_sItemName) == -1)
		{
			// We need to keep track of recently added shared items to prevent them being added to players in a loop
			m_arrRecentlyAddedSharedItems.insertLast(_sItemName);
			m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.ResetRecentlyAdded_SharedQuestItem_Timer), 100, _sItemName);

			array<uint8> _arrPlayerFactions = m_Reference.GetPlayerFactions(true);
			for(uint i = 0; i < _arrPlayerFactions.length(); ++i)
			{
				if(_arrPlayerFactions[i] != _uPlayerFaction)
				{
					m_Reference.GetHeroParty(_arrPlayerFactions[i]).AddItems(_sItemName, _uAmount, true);
				}
			}
		}
		return false;
	}

	bool ResetRecentlyAdded_SharedQuestItem_Timer(const string& in _sItemName)
	{
		int _iIndex = m_arrRecentlyAddedSharedItems.find(_sItemName);
		if(_iIndex != -1)
		{
			m_arrRecentlyAddedSharedItems.removeAt(_iIndex);
		}
		return true;
	}

	/*	--------------------------------------------------------
	*	Triggered when any item is removed from player contolled 
	*	party's inventory. If it is a SharedQuestItem, then
	*	the item will be also removed from other players' inventories.
	*	Also treats Journey_MissingSonsDogTag_502 as a SharedQuestItem.
	*	--------------------------------------------------------
	*/

	bool OnRemoved_CheckSharedQuestItem(const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		if(m_Reference.CheckItemProperty(_sItemName, SharedQuestItem) && m_arrRecentlyRemovedSharedItems.find(_sItemName) == -1
			|| (_sItemName == "Journey_MissingSonsDogTag_502" && GetString_CurrentMapId() == "500"))
		{
			// We need to keep track of recently removed shared items to prevent them being removed from players in a loop
			m_arrRecentlyRemovedSharedItems.insertLast(_sItemName);
			m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.ResetRecentlyRemoved_SharedQuestItem_Timer), 100, _sItemName);

			array<uint8> _arrPlayerFactions = m_Reference.GetPlayerFactions(true);
			for(uint i = 0; i < _arrPlayerFactions.length(); ++i)
			{
				if(_arrPlayerFactions[i] != _uPlayerFaction)
				{
					m_Reference.GetHeroParty(_arrPlayerFactions[i]).RemoveItems(_sItemName, _uAmount, true);
				}
			}
		}
		return false;
	}

	bool ResetRecentlyRemoved_SharedQuestItem_Timer(const string& in _sItemName)
	{
		int _iIndex = m_arrRecentlyRemovedSharedItems.find(_sItemName);
		if(_iIndex != -1)
		{
			m_arrRecentlyRemovedSharedItems.removeAt(_iIndex);
		}
		return true;
	}

	/*	--------------------------------------------------
	*	Ensures that players won't have more than 1
	*	Journey_MissingSonsDogTag_502 in the inventory.
	*	Registered in 502 level script.
	*	--------------------------------------------------
	*/
	bool OnAdded_MissingSonsDogTags(const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		if(m_arrRecentlyAddedSharedItems.find(_sItemName) == -1)
		{
			// We need to keep track of recently added shared items to prevent them being added to players in a loop
			m_arrRecentlyAddedSharedItems.insertLast(_sItemName);
			m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.ResetRecentlyAdded_SharedQuestItem_Timer), 100, _sItemName);

			array<uint8> _arrPlayerFactions = m_Reference.GetPlayerFactions(true);
			for(uint i = 0; i < _arrPlayerFactions.length(); ++i)
			{
				Variables@ _FactionGlobalVariables = m_Reference.GetVariables(_arrPlayerFactions[i]);
				if(_arrPlayerFactions[i] == _uPlayerFaction && _FactionGlobalVariables.GetGlobalBool("Journey_CampaignVariables.bFoundMissingSonsDogTags") == true)
				{
					m_Reference.GetHeroParty(_uPlayerFaction).RemoveItems(_sItemName, 1, false);
				}
				else if(_FactionGlobalVariables.GetGlobalBool("Journey_CampaignVariables.bFoundMissingSonsDogTags") == false)
				{
					m_Reference.GetHeroParty(_arrPlayerFactions[i]).AddItems(_sItemName, _uAmount, true);
					_FactionGlobalVariables.SetGlobalBool("Journey_CampaignVariables.bFoundMissingSonsDogTags", true);
				}
			}
		}

		return false;
	}
}