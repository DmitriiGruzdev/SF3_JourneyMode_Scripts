mixin class Journey_IntroOutroDialogues
{
	string m_sIntroSpeaker;
	string m_sIntroTopic;

	string m_sOutroSpeaker;
	string m_sOutroTopic;

	/*	--------------------------------------------------
	*	Called in InitCommon of level scripts.
	*	--------------------------------------------------
	*/
	void SetupIntroCreatures(string _sCreatureName, string _sTopicName, array<string> _arrOtherParticipants = array<string> = {})
	{
		m_sIntroSpeaker = _sCreatureName;
		m_sIntroTopic = _sTopicName;

		SetupIntroOutroStatus(m_sIntroSpeaker);
		if(_arrOtherParticipants.length() >= 1)
		{
			Creature _IntroSpeaker = m_Reference.GetCreatureByName(m_sIntroSpeaker);
			for(uint i = 0; i < _arrOtherParticipants.length(); ++i)
			{
				SetupIntroOutroStatus(_arrOtherParticipants[i]);
				if(_IntroSpeaker.Exists())
				{
					m_Reference.GetCreatureByName(_arrOtherParticipants[i]).Teleport(m_Reference, _IntroSpeaker);
				}
			}
		}

		m_Reference.SetTimerMS(TOnTimerEvent(@this.MapIntroDialogueShoutout_Timer), 700);
	}

	bool MapIntroDialogueShoutout_Timer()
	{
		if(m_Reference.GetWorld().GetGlobalBool("Journey_CampaignVariables.Journey_bHostHeroSelectionOpen") == true)
		{
			m_Reference.RegisterHeroPartyEvent(HeroSelectionClosed, TOnHeroPartyEvent(@this.OnHeroSelectionClosed_MapIntroDialogueShoutout), "", m_Reference.GetHostFaction());
		}
		else
		{
			JourneyDialogShoutout(m_sIntroSpeaker, m_sIntroSpeaker, m_sIntroTopic);
		}
		return true;
	}

	bool OnHeroSelectionClosed_MapIntroDialogueShoutout(Creature &in _Creature)
	{
		m_Reference.SetTimerMS(TOnTimerEvent(@this.MapIntroDialogueShoutout_Timer), 700);

		return true;
	}

	/*	--------------------------------------------------
	*	Called in level scripts in case outro NPCs
	*	are different from intro NPCs
	*	--------------------------------------------------
	*/	
	void SetupOutroCreatures(string _sCreatureName, string _sTopicName, array<string> _arrOtherParticipants = array<string> = {})
	{
		m_sOutroSpeaker = _sCreatureName;
		m_sOutroTopic = _sTopicName;

		SetupIntroOutroStatus(m_sOutroSpeaker);
		if(_arrOtherParticipants.length() >= 1)
		{
			Creature _OutroSpeaker = m_Reference.GetCreatureByName(m_sOutroSpeaker);
			for(uint i = 0; i < _arrOtherParticipants.length(); ++i)
			{
				SetupIntroOutroStatus(_arrOtherParticipants[i]);
				if(_OutroSpeaker.Exists())
				{
					m_Reference.GetCreatureByName(_arrOtherParticipants[i]).Teleport(m_Reference, _OutroSpeaker);
				}
			}
		}

		m_Reference.SetTimerMS(TOnTimerEvent(@this.MapOutroDialogueShoutout_Timer), 100);
	}

	bool MapOutroDialogueShoutout_Timer()
	{
		JourneyDialogShoutout(m_sOutroSpeaker, m_sOutroSpeaker, m_sOutroTopic);
		return true;
	}

	/*	--------------------------------------------------
	*	General status setup for intro/outro NPCs
	*	--------------------------------------------------
	*/
	void SetupIntroOutroStatus(string _sCreatureName)
	{
		Creature _Creature = m_Reference.GetCreatureByName(_sCreatureName);
		if(_Creature.Exists())
		{
			_Creature.SetHelpUpAllowed(true);
			_Creature.SetAutoRevive(true);
		}
		else
		{
			print("Tried to setup status for intro/outro NPC that doesn't exist.");
		}
	}
}

