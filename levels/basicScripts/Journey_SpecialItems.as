mixin class Journey_SpecialItems
{
	void RegisterSpecialItems()
	{
		for(uint i = 0; i < kMaxFactions; i++)
		{
			//Register events for the revive talsiman, the reskill-, attribute- and abilitypoint-potions 
			m_Reference.RegisterHeroPartyEvent(Killed, TOnHeroPartyEvent(@this.HeropartyMember_ReviveTalisman), "", i);
			m_Reference.RegisterCreatureInventoryEvent(ConsumedByDescription, TOnCreatureInventoryByDescriptionEvent(@this.OnConsumed_AttributePotion), "PotionOfAttributes", i);
			m_Reference.RegisterCreatureInventoryEvent(ConsumedByDescription, TOnCreatureInventoryByDescriptionEvent(@this.OnConsumed_AbilityPotion), "PotionOfAbilities", i);
			m_Reference.RegisterCreatureInventoryEvent(ConsumedByDescription, TOnCreatureInventoryByDescriptionEvent(@this.OnConsumed_ReskillPotion), "PotionOfReskill", i);
		}
	}

	/*	--------------------------------------------------
	*	Attribute potion 
	*	Grants one attribute point to the hero using the potion
	*	--------------------------------------------------
	*/
	bool OnConsumed_AttributePotion(const string&in _sCreatureName, const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		m_Reference.GetHeroParty(_uPlayerFaction).AddAttributePoints(_sCreatureName, 1);
		return false;
	}

	/*	--------------------------------------------------
	*	Ability potion 
	*	Grants one ability point to the hero using the potion
	*	--------------------------------------------------
	*/
	bool OnConsumed_AbilityPotion(const string&in _sCreatureName, const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		m_Reference.GetHeroParty(_uPlayerFaction).AddAbilityPoints(_sCreatureName, 1);
		return false;
	}

	/*	--------------------------------------------------
	*	Ability potion 
	*	Grants one ability point to the hero using the potion
	*	--------------------------------------------------
	*/
	bool OnConsumed_ReskillPotion(const string&in _sCreatureName, const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		m_Reference.GetHeroParty(_uPlayerFaction).ResetHeroAbilities(_sCreatureName);
		m_Reference.GetHeroParty(_uPlayerFaction).ResetHeroAttributes(_sCreatureName);
		return false;
	}

	/*	--------------------------------------------------
	*	Revive Talisman
	*	--------------------------------------------------
	*/

	/*
	* This function triggers when a Heroparty member dies
	* It checks if the fallen hero has the 'ReviveTalisman' equipped in the item slot
	* If this is the case - a timer is set, that revives the Hero after a few seconds automatically and removes one entity of the 'ReviveTalsiman' from the Item slot of the character
	* (This function needs to be registered whenever someone joins the heroparty)
	*/
	bool HeropartyMember_ReviveTalisman(Creature& in _Creature)
	{
		if (_Creature.Exists() == false)
			return false;
	
		bool bItemSlotLocked;
		string sItemSlot = "";
		_Creature.GetEquipment(Item, sItemSlot);
		if ( sItemSlot == "ReviveTalisman" ||  sItemSlot == "MP_ReviveTalisman" )
		{
			printNote(_Creature.GetDescriptionName() +  " will be revived");
			m_RevivingTalismanHeroes.insertLast(_Creature.GetDescriptionName());
			if( _Creature.IsItemSlotLocked(Item) )
			{
				_Creature.LockItemSlot(Item, false);
				bItemSlotLocked = true;
			}
			_Creature.Unequip(m_Reference, Item, Remove, uint16 (1));
			m_Reference.SetTimer(TOnTimerEvent(@this.Timer_ReviveWithTalisman), m_iTimer_ReviveTalisman);
			_Creature.GetEquipment(Item, sItemSlot);
			if( bItemSlotLocked && (sItemSlot == "ReviveTalisman" ||  sItemSlot == "MP_ReviveTalisman") )
				_Creature.LockItemSlot(Item, true);
			
			return false;
		}
		return false;
	}

	/*
	* This timer is set @HeropartyMember_ReviveTalisman
	* It revives a Heroparty member automatically after a few seconds
	*/
	bool Timer_ReviveWithTalisman()
	{
		printNote("Reviving " + m_Reference.GetCreatureByName(m_RevivingTalismanHeroes[0]).GetDescriptionName() );
		m_Reference.GetCreatureByName(m_RevivingTalismanHeroes[0]).Revive();
		m_RevivingTalismanHeroes.removeAt(0);
		return true;
	}
	
}