mixin class Journey_TrollStoryAbilities
{
	/*	--------------------------------------------------
	*	Called in OnCreated in LevelBase, sets up EXP2
	*	story synergy abilities for troll avatars
	*	--------------------------------------------------
	*/
	void UnlockTrollStoryAbilities()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			Creature _Avatar = m_Reference.GetHeroParty(_uFaction).GetMembers()[0];
			Variables@ _FactionGlobalVariables = m_Reference.GetVariables(_uFaction);

			if(_Avatar.GetDescriptionName() == "JourneyHero_EXP2" && _FactionGlobalVariables.GetGlobalBool("Journey_CampaignVariables.Journey_bTrollStoryAbilitiesUnlocked") == false)
			{
				string _sAvatar = m_Reference.FindEntityName(_Avatar);
				array<string> _arrAbilityTrees = _Avatar.GetAbilityTrees(m_Reference);
				for (uint j = 0; j < _arrAbilityTrees.length(); ++j)
				{
					if(_arrAbilityTrees[j] == "EXP2_Tree_Akrog")
					{
						m_Reference.GetHeroParty(_uFaction).SetAbilityUnavailable(_Avatar, "Akrog_StoryAbilityUnlocker", false);
						SkillTrollStoryAbility("TS_Story_Akrog", _uFaction, _Avatar);
					}
					else if(_arrAbilityTrees[j] == "EXP2_Tree_Grungwar")
					{
						m_Reference.GetHeroParty(_uFaction).SetAbilityUnavailable(_Avatar, "Grungwar_StoryAbilityUnlocker", false);
						SkillTrollStoryAbility("TS_Story_Grungwar", _uFaction, _Avatar);
					}
					else if(_arrAbilityTrees[j] == "EXP2_Tree_Zazka")
					{
						m_Reference.GetHeroParty(_uFaction).SetAbilityUnavailable(_Avatar, "Zazka_StoryAbilityUnlocker", false);
						SkillTrollStoryAbility("TS_Story_Zazka", _uFaction, _Avatar);
					}
				}

				_FactionGlobalVariables.SetGlobalBool("Journey_CampaignVariables.Journey_bTrollStoryAbilitiesUnlocked", true);
			}
		}
	}

	void SkillTrollStoryAbility(string _sAbility, uint _uFaction, Creature _Avatar)
	{
		m_Reference.GetHeroParty(_uFaction).AddAbilityPoints(_Avatar.GetDescriptionName(), 1);
		m_Reference.GetHeroParty(_uFaction).UnlockHeroAbility(_Avatar, _sAbility);
		m_Reference.GetHeroParty(_uFaction).PreventAbilityReset(_Avatar, _sAbility, 0);
	}
}