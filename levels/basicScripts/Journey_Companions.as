mixin class Journey_Companions
{
	array<string> m_arrJourneyCompanions =
	{
		"Journey_BattleMagus_Companion",                  // Battlemage
		"Journey_CursedKnight_Companion",			      // Sanguine Knight
		"Journey_Elementalist_Companion",				  // Elementalist
		"Journey_Harvester_Companion",                    // Inquisitor
		"Journey_Priest_Companion",                       // Priest
		"Journey_Shapechanger_Companion",                 // Shapeshifter
		"Journey_TheDarkestDude_Companion",               // Coercer
		"Journey_Paladin_Companion",                      // Keeper
		"Journey_Ranger_Companion"					      // Ranger
	};

	array<string> m_arrUnlockableJourneyCompanions =
	{
		"Journey_CursedKnight_Companion",			      // Sanguine Knight
		"Journey_Elementalist_Companion",				  // Elementalist
		"Journey_Harvester_Companion",                    // Inquisitor
		"Journey_Priest_Companion",                       // Priest
		"Journey_Shapechanger_Companion",                 // Shapeshifter
		"Journey_TheDarkestDude_Companion",               // Coercer
		"Journey_Ranger_Companion"					      // Ranger
	};

	// Attributes
	dictionary m_CompanionsInitialAttributes =
	{
		{"Journey_BattleMagus_Companion", array<uint8> = {	
															1, // Strength
															0, // Dexterity	
															2, // Intelligence
															3, // Constitution
															2, // Willpower
														}
		},
		{"Journey_CursedKnight_Companion", array<uint8> = {	
															4, // Strength
															1, // Dexterity	
															0, // Intelligence
															4, // Constitution
															1, // Willpower
														}
		},
		{"Journey_Elementalist_Companion", array<uint8> = {	
															0, // Strength
															0, // Dexterity	
															3, // Intelligence
															2, // Constitution
															3, // Willpower
														}
		},
		{"Journey_Harvester_Companion", array<uint8> = {	
															2, // Strength
															2, // Dexterity	
															0, // Intelligence
															6, // Constitution
															0, // Willpower
														}
		},
		{"Journey_Priest_Companion", array<uint8> = {	
															0, // Strength
															0, // Dexterity	
															4, // Intelligence
															3, // Constitution
															3, // Willpower
														}
		},
		{"Journey_Shapechanger_Companion", array<uint8> = {	
															0, // Strength
															5, // Dexterity	
															0, // Intelligence
															2, // Constitution
															3, // Willpower
														}
		},
		{"Journey_TheDarkestDude_Companion", array<uint8> = {	
															0, // Strength
															0, // Dexterity	
															5, // Intelligence
															3, // Constitution
															2, // Willpower
														}
		},
		{"Journey_Paladin_Companion", array<uint8> = {	
															1, // Strength
															2, // Dexterity	
															0, // Intelligence
															4, // Constitution
															1, // Willpower
														}
		},
		{"Journey_Ranger_Companion", array<uint8> = {	
															4, // Strength
															1, // Dexterity	
															0, // Intelligence
															4, // Constitution
															0, // Willpower
														}
		}
	};

	bool m_bCompanionRemovedDueToJoinedPlayer = false;
	bool m_bTwoCompanionsRemovedDueToJoinedPlayers = false;

	/*	--------------------------------------------------
	*	Summons all companions on their respective HUB spots.
	*	Summon is used instead of normal spawns to ensure that
	*	Companions are always of host faction, preventing confusion.
	*	Fired in Everlight's InitCommon.
	*	--------------------------------------------------
	*/

	void SummonCompanionsHUB()
	{
		for ( uint i = 0; i < m_arrJourneyCompanions.length(); i++ )
		{
			m_Reference.CastSpell(m_arrJourneyCompanions[i] + "Summon", m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName(m_arrJourneyCompanions[i] + "Spawn"));
		}
		m_Reference.SetTimerMS( TOnTimerEvent( @this.SetupCompanionsHUB_Timer ), 100 );
		// Minimap marker
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.BeginNotification(_uFaction, "Journey_Companion_Minimap", m_Reference.GetLogicObjectByName("Journey_Companions_MinimapMarkerSpot"));
		}
	}

	/*	--------------------------------------------------
	*	Sets up companions after they are summoned on HUB
	*	map. 
	*	--------------------------------------------------
	*/

	bool SetupCompanionsHUB_Timer()
	{
		// Initial allocation of attribute points
		Variables@ _HostGlobalVariables = m_Reference.GetVariables(m_Reference.GetHostFaction());
		if(_HostGlobalVariables.GetGlobalBool("Journey_CampaignVariables.Journey_bCompanionsInitialSetup") == false)
		{
			Companions_AttributesSetup();
			_HostGlobalVariables.SetGlobalBool("Journey_CampaignVariables.Journey_bCompanionsInitialSetup", true);
			print("Configuring companions intial setup");
		}

		for ( uint i = 0; i < m_arrJourneyCompanions.length(); i++ )
		{
			// By default all companions are owned (because we summon them with a spell) thus we have to disown them first
			m_Reference.GetHeroParty(m_Reference.GetHostFaction()).SetHeroOwned(m_arrJourneyCompanions[i], true, false);
			if(_HostGlobalVariables.GetGlobalBool("Journey_CampaignVariables."+m_arrJourneyCompanions[i]+"_bUnlocked"))
			{
				m_Reference.GetHeroParty(m_Reference.GetHostFaction()).SetHeroOwned(m_arrJourneyCompanions[i], true, true);
			}
			// Companions' control is disabled so they behave as static NPCs
			m_Reference.GetCreatureByName(m_arrJourneyCompanions[i]).SetImmovable( true );
			m_Reference.GetCreatureByName(m_arrJourneyCompanions[i]).SetPlayerControllable( false );
			// Enabling respective companion-icons
			for (uint j = 0; j < m_Reference.GetPlayerFactions(true).length(); ++j)
			{
				uint _uFaction = m_Reference.GetPlayerFactions(true)[j];
				m_Reference.BeginNotification(_uFaction, m_arrJourneyCompanions[i], m_Reference.GetCreatureByName(m_arrJourneyCompanions[i]));
			}
			// Making companions face one direction
			m_Reference.GetCreatureByName(m_arrJourneyCompanions[i]).PlayAnimation(m_Reference, Idle, -1, 3000, false, false, Entity (m_Reference.GetLogicObjectByName("Journey_Companions_MinimapMarkerSpot")), false, false, false);
		}

		return true;
	}

	/*	--------------------------------------------------
	*	Configurates companions' initial attributes. Fired
	*	once on first Everlight launch with fresh Journey avatar
	*	--------------------------------------------------
	*/
	void Companions_AttributesSetup()
	{
		array<string> _arrkeys = m_CompanionsInitialAttributes.getKeys();
		for(uint i = 0; i < _arrkeys.length(); ++i)
		{
			array<uint8> _arrAttributes;
			m_CompanionsInitialAttributes.get(_arrkeys[i], _arrAttributes);

			m_Reference.GetHeroParty(m_Reference.GetHostFaction()).ModifyHeroAttribute(m_Reference.GetCreatureByName(_arrkeys[i]), Strength, _arrAttributes[Strength]);
			m_Reference.GetHeroParty(m_Reference.GetHostFaction()).ModifyHeroAttribute(m_Reference.GetCreatureByName(_arrkeys[i]), Dexterity, _arrAttributes[Dexterity]);
			m_Reference.GetHeroParty(m_Reference.GetHostFaction()).ModifyHeroAttribute(m_Reference.GetCreatureByName(_arrkeys[i]), Intelligence, _arrAttributes[Intelligence]);
			m_Reference.GetHeroParty(m_Reference.GetHostFaction()).ModifyHeroAttribute(m_Reference.GetCreatureByName(_arrkeys[i]), Constitution, _arrAttributes[Constitution]);
			m_Reference.GetHeroParty(m_Reference.GetHostFaction()).ModifyHeroAttribute(m_Reference.GetCreatureByName(_arrkeys[i]), Willpower, _arrAttributes[Willpower]);
		}
	}

	/*	--------------------------------------------------
	*	Allows to use the companion throughout the mode.
	*	Called in companions' dialogues in Everlight  
	*	--------------------------------------------------
	*/	
	void UnlockJourneyCompanion(string _sCompanionName)
	{
		Variables@ _HostGlobalVariables = m_Reference.GetVariables(m_Reference.GetHostFaction());
		uint _uCompanionPrice = _HostGlobalVariables.GetGlobalInt("Journey_CompanionCosts."+_sCompanionName);
		m_Reference.GetHeroParty(m_Reference.GetHostFaction()).RemoveGold(_uCompanionPrice);
		_HostGlobalVariables.SetGlobalBool("Journey_CampaignVariables."+_sCompanionName+"_bUnlocked", true);
		m_Reference.GetHeroParty(m_Reference.GetHostFaction()).SetHeroOwned(_sCompanionName, true, true);

		Check_Journey_500_SQ1_HireCompanionsForGold_Quest(_sCompanionName);
	}

	void Check_Journey_500_SQ1_HireCompanionsForGold_Quest(string _sCompanionName)
	{
		if (_sCompanionName != "Journey_BattleMagus_Companion" || _sCompanionName != "Journey_Paladin_Companion")
		{
			if (m_Reference.GetSharedJournal().GetTaskState("Journey_500_SQ1_HireCompanionsForGold", "HireAnyCompanionForGold") != Completed)
			{
				m_Reference.GetSharedJournal().SetTaskState("Journey_500_SQ1_HireCompanionsForGold", "HireAnyCompanionForGold", Completed);
			}
		}
	}

	/*	--------------------------------------------------
	*	Opens hero selection window for a host, fired in
	*	LevelBase in OnCreated (Not fired in Everlight)
	*	--------------------------------------------------
	*/
	void HostHeroSelection()
	{
		bool _bHostHeroSelectionOpen = false;
		uint8 _uJoinedPlayers = m_Reference.GetPlayerFactions(true).length() - 1;
		uint8 _uHostFaction = m_Reference.GetHostFaction();
		Creature _HostAvatar = m_Reference.GetCreatureById(m_iHostAvatarId);
		uint _uUnlockedCompanions = 0;

		for ( uint i = 0; i < m_arrJourneyCompanions.length(); i++ )
		{
			if(m_Reference.GetWorld().GetGlobalBool("Journey_CampaignVariables."+m_arrJourneyCompanions[i]+"_bUnlocked"))
			{
				m_Reference.GetHeroParty(_uHostFaction).SetHeroOwned(m_arrJourneyCompanions[i], true, true);
				_uUnlockedCompanions++;
			}
		}

		switch(_uJoinedPlayers)
		{	
			case 0:
				_bHostHeroSelectionOpen = m_Reference.ShowHeroSelection(_uHostFaction, m_Reference.GetHeroParty(_uHostFaction).GetControlIndex(_HostAvatar));
				break;
			case 1:
				_bHostHeroSelectionOpen = m_Reference.ShowHeroSelection(_uHostFaction, m_Reference.GetHeroParty(_uHostFaction).GetControlIndex(_HostAvatar), 3);
				if(_uUnlockedCompanions > 2)
				{
					m_Reference.BeginNotification(_uHostFaction, "CompanionRemovedDueToJoinedPlayer", m_Reference.GetCreatureById(m_iHostAvatarId));
					m_bCompanionRemovedDueToJoinedPlayer = true;
				}
				break;
			case 2:
				_bHostHeroSelectionOpen = m_Reference.ShowHeroSelection(_uHostFaction, m_Reference.GetHeroParty(_uHostFaction).GetControlIndex(_HostAvatar), 2);
				if(_uUnlockedCompanions > 1)
				{
					m_Reference.BeginNotification(_uHostFaction, "TwoCompanionsRemovedDueToJoinedPlayers", m_Reference.GetCreatureById(m_iHostAvatarId));
					m_bTwoCompanionsRemovedDueToJoinedPlayers = true;
				}
				break;
		}

		if(_bHostHeroSelectionOpen)
		{
			m_Reference.RegisterHeroPartyEvent(HeroSelectionClosed, TOnHeroPartyEvent(@this.OnHeroSelectionClosed_ReenableControl), "", _uHostFaction);
			m_Reference.GetWorld().SetGlobalBool("Journey_CampaignVariables.Journey_bHostHeroSelectionOpen", _bHostHeroSelectionOpen);
			// Disabling control for joined players so they won't rush forward while host is selecting companions
			DisableJoinedPlayersControl();
		}
	}

	/*	--------------------------------------------------
	*	Disables control like in exp2 for joined players 
	*	while the host is making a companion selection on
	*	level start, fired in ShowHeroSelection_Timer
	*	--------------------------------------------------
	*/

	void DisableJoinedPlayersControl()
	{
		array<uint8> _arrPlayerFactions = m_Reference.GetPlayerFactions(true);
		for(uint i = 0; i < _arrPlayerFactions.length(); ++i)
		{
			if(_arrPlayerFactions[i] != m_Reference.GetHostFaction())
			{
				JourneyPlayerHeroControlDisable_Light(_arrPlayerFactions[i]);
				m_Reference.BeginNotification(_arrPlayerFactions[i], "JourneyWaitingForHostHeroSelection", m_Reference.GetCreatureById(m_iHostAvatarId));
			}
		}
	}

	/*	--------------------------------------------------
	*	Event set in ShowHeroSelection_Timer
	*	--------------------------------------------------
	*/

	bool OnHeroSelectionClosed_ReenableControl(Creature &in _Creature)
	{
		m_Reference.GetWorld().SetGlobalBool("Journey_CampaignVariables.Journey_bHostHeroSelectionOpen", false);
		m_Reference.CastSpell("Journey_500_TeleportMessenger", m_Reference.GetHostFaction(), m_Reference.GetLogicObjectByName("PlayerSpawn_WorldMap"));
		
		// Enabling control for joined players
		array<uint8> _arrPlayerFactions = m_Reference.GetPlayerFactions(true);
		for(uint i = 0; i < _arrPlayerFactions.length(); ++i)
		{
			if(_arrPlayerFactions[i] != m_Reference.GetHostFaction())
			{
				JourneyPlayerHeroControlEnable_Light(_arrPlayerFactions[i]);
				m_Reference.EndNotification(_arrPlayerFactions[i], "JourneyWaitingForHostHeroSelection", m_Reference.GetCreatureById(m_iHostAvatarId));
			}
		}

		// Disabling notification for host
		uint _uHostFaction = m_Reference.GetHostFaction();
		if(m_bCompanionRemovedDueToJoinedPlayer)
		{
			m_Reference.EndNotification(_uHostFaction, "CompanionRemovedDueToJoinedPlayer", m_Reference.GetCreatureById(m_iHostAvatarId));
		}
		else if(m_bTwoCompanionsRemovedDueToJoinedPlayers)
		{
			m_Reference.EndNotification(_uHostFaction, "TwoCompanionsRemovedDueToJoinedPlayers", m_Reference.GetCreatureById(m_iHostAvatarId));
		}

		return true;
	}
}