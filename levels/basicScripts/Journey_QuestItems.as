mixin class Journey_QuestItems
{
	array<string> m_arrEquippableItems =
	{
		"Journey_VeilDestroyer_503",
		"Journey_IsamosArtifact_510"
	};

	array<string> m_arrUnequippableItems =
	{
		"Journey_VeilMoonsilver_503",
		"Journey_ShaperPillarKey_505",
		"Journey_ShaperArtifact_505",
		"Journey_DwarvenRescueDevice_509",
		"Journey_IsamosArtifact_510"
	};

	/*	--------------------------------------------------
	*	Called in OnCreated on LevelBase, removes all
	*	quest items which should be only obtained by players
	*	only in specific maps and thus shouldn't remain in players'
	*	inventories when they leave the map
	*	--------------------------------------------------
	*/
	void RemoveQuestItems()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			for (uint j = 0; j < m_arrEquippableItems.length(); ++j)
			{
				string _sQuestItem = m_arrEquippableItems[j];
				for (uint k = 0; k < m_Reference.GetHeroParty(_uFaction).GetMembers().length(); ++k)
				{
					string _sEquipedItem = "";
					Creature _Hero = m_Reference.GetHeroParty(_uFaction).GetMembers()[k];
					_Hero.GetEquipment(Item, _sEquipedItem);
					if(_sEquipedItem == _sQuestItem)
					{
						_Hero.Unequip(m_Reference, Item, AddToInventory, uint16 ( - 1 ));
					}
				}
				m_Reference.GetHeroParty(_uFaction).RemoveItems(_sQuestItem, 1, false);
			}

			for (uint j = 0; j < m_arrUnequippableItems.length(); ++j)
			{
				string _sQuestItem = m_arrUnequippableItems[j];
				uint _uAmount = m_Reference.GetHeroParty(_uFaction).GetItemAmount(_sQuestItem, true);
				m_Reference.GetHeroParty(_uFaction).RemoveItems(_sQuestItem, _uAmount, false);
			}
		}
	}
}