mixin class Journey_RandomLoot
{
	array<string> m_arrRandomLootTypes =
	{
		"RandomLoot_Weapons_", // ordinary weapons
		"RandomLoot_Equipment_", // ordinary equipment (armor, trinkets, rings)
		"RandomLoot_Treasure_", // uncommon weapons and equipment
		"RandomLoot_SpecialTreasure_" // cool weapons and equipment
	};

	/*	--------------------------------------------------
	*	Called in OnCreated in LevelBase
	*	--------------------------------------------------
	*/
	void DisableRandomLoot(string _sPrefix = "RandomLoot")
	{
		array<LogicObject>@ RandomLoot = m_Reference.FindLogicObjectsByPrefix(_sPrefix);
		for(uint i = 0; i < RandomLoot.length(); i++)
		{
			RandomLoot[i].Enable(false);
		}
	}

	/*	--------------------------------------------------
	*	Called in InitCommon of level scripts
	*	--------------------------------------------------
	*/
	void ActivateRandomLoot(uint _uEnablePercentage, string _sPrefix = "RandomLootSpot")
	{
		array<LogicObject>@ RandomLootSpots = m_Reference.FindLogicObjectsByPrefix(_sPrefix);
		uint uTotalAmount = RandomLootSpots.length();
		uint uAmountToEnable = PercentOf(uTotalAmount, _uEnablePercentage);
		uint uAlreadyEnabled = 0;

		while(uAlreadyEnabled < uAmountToEnable)
		{
			uint _uRandom = m_Reference.GetRandom().GetInteger(0, RandomLootSpots.length());
			SetupRandomLootType(m_Reference.FindEntityName(RandomLootSpots[_uRandom]));
			RandomLootSpots.removeAt(_uRandom);
			uAlreadyEnabled++;
		}
	}

	/*	--------------------------------------------------
	*	Activates one randomly chosen loot container in
	*	the passed spot
	*	--------------------------------------------------
	*/
	void SetupRandomLootType(string _sSpot)
	{
		array<string> _arrLinkedLoot = m_Reference.GetLinkedObjects(_sSpot, false);
		uint _uRandom = m_Reference.GetRandom().GetInteger(0, _arrLinkedLoot.length());
		string _sLootContainer = _arrLinkedLoot[_uRandom];

		m_Reference.GetLogicObjectByName(_sLootContainer).Enable(true);
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			m_Reference.RegisterHeroPartyEvent(Loot, TOnHeroPartyEvent(@this.OnLoot_RandomLoot), _sLootContainer, _uFaction);
		}
		print(_sSpot+" will have "+_sLootContainer);
	}

	/*	--------------------------------------------------
	*	Does an exploration shoutout every time any journey
	*	hero opnes a random loot container
	*	--------------------------------------------------
	*/
	bool OnLoot_RandomLoot(Creature& in _Creature)
	{
		JourneyExplorationShoutout(_Creature, "Journey_GenericDialogue_RandomLootReaction");
		return false;
	}
}