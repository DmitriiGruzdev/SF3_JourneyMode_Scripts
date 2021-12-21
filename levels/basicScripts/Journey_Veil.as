mixin class Journey_Veil
{
	array<uint> arr_VeilEffects;
	
	void RegisterVeilItem()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			m_Reference.RegisterCreatureInventoryEvent(Equipped, TOnCreatureInventoryEvent(@this.EXP1_OnEquipped_VeilItem), "Journey_VeilDestroyer_503", m_Reference.GetPlayerFactions(true)[i]);
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			m_Reference.RegisterCreatureInventoryEvent(Unequipped, TOnCreatureInventoryEvent(@this.EXP1_Unequipped_VeilItem), "Journey_VeilDestroyer_503", m_Reference.GetPlayerFactions(true)[i]);
		m_Reference.RegisterBuildingEventByDescription(Damaged, TOnBuildingEvent(@this.OnDamage_Veil), "Exp1_Veil", kFactionNeutral);
		CollectAllVeilEffects();
	}

	void Veil_JourneyCheck(uint _uFaction)
	{
		string _sItem = "";
		for (uint i = 0; i < m_Reference.GetHeroParty(_uFaction).GetMembers().length(); i++)
		{
			m_Reference.GetHeroParty(_uFaction).GetMembers()[i].GetEquipment(Item, _sItem);
			if( _sItem == "Journey_VeilDestroyer_503" )
			{
				print("Equipped Veil, activate " + arr_VeilEffects.length() + " veils" );
				for( uint j = 0; j < arr_VeilEffects.length(); j++ )
				{
					m_Reference.GetBuildingById(arr_VeilEffects[j]).SetCustomState(Script1, false);
					m_Reference.GetBuildingById(arr_VeilEffects[j]).SetCustomState(Script2, true);
					m_Reference.GetBuildingById(arr_VeilEffects[j]).SetAttackable(true);
				} 
				return;
			}
		}
		for( uint i = 0; i < arr_VeilEffects.length(); i++ )
		{
			m_Reference.GetBuildingById(arr_VeilEffects[i]).SetCustomState(Script1, true);
			m_Reference.GetBuildingById(arr_VeilEffects[i]).SetCustomState(Script2, false);
			m_Reference.GetBuildingById(arr_VeilEffects[i]).SetAttackable(true);
		} 		
	}

	void CollectAllVeilEffects()
	{
		//array<Building>@ _arr_VeilEffectsBuilding = m_Reference.FindBuildingsByDescription(kFactionNeutral, "Exp1_Veil");
		// Anja: I intergrated this, as a veil building could be placed inside an occupied sector, which changes it's initial faction.
		array<Building>@ _arr_VeilEffectsBuilding = GetAllVeilBuildings();

		for( uint i = 0; i < _arr_VeilEffectsBuilding.length(); i++ )
		{
			arr_VeilEffects.insertLast(_arr_VeilEffectsBuilding[i].GetId());
			_arr_VeilEffectsBuilding[i].SetSelectable(false);
			_arr_VeilEffectsBuilding[i].SetAttackable(false);
			_arr_VeilEffectsBuilding[i].SetInteractive(false);
			_arr_VeilEffectsBuilding[i].SetCustomState(Script1, true);

			print("Added veil with id " + _arr_VeilEffectsBuilding[i].GetId() );
		}
	}
	array<Building>@ GetAllVeilBuildings()
	{
		array<Building>@ _arr_VeilEffectsBuilding_ALL = {}; 
		for( uint _iTmp = 1; _iTmp < 13; _iTmp++ )
		{
			array<Building>@ _arr_VeilEffectsBuilding = m_Reference.FindBuildingsByDescription(_iTmp, "Exp1_Veil");
			for( uint _iTmp_2 = 0; _iTmp_2 < _arr_VeilEffectsBuilding.length(); _iTmp_2++ )
			{
				_arr_VeilEffectsBuilding_ALL.insertLast( _arr_VeilEffectsBuilding[_iTmp_2] );
				_arr_VeilEffectsBuilding[_iTmp_2].SetFaction( kFactionNeutral );
			}
		}
		return _arr_VeilEffectsBuilding_ALL;
	}

	void RemoveVeil(uint _uID)
	{
		for( uint i = 0; i < arr_VeilEffects.length(); i++ )
		{
			if( arr_VeilEffects[i] == _uID )
			{
				arr_VeilEffects.removeAt(i);
			}
		}
	}

	bool EXP1_OnEquipped_VeilItem(Creature&in _Creature, const string&in _sItemName, const uint _uAmount)
	{
		print("Equipped Veil, activate " + arr_VeilEffects.length() + " veils" );
		for( uint i = 0; i < arr_VeilEffects.length(); i++ )
		{
			//m_Reference.GetBuildingById(arr_VeilEffects[i]).SetCustomState(Script1, true);
			m_Reference.SetTimerMS(TOnTimerEvent(@this.OnTimer_ActivateVeilState), 1000);
			m_Reference.GetBuildingById(arr_VeilEffects[i]).SetCustomState(Script2, true);
			m_Reference.GetBuildingById(arr_VeilEffects[i]).SetAttackable(true);
		} 
		return false;
	}

	bool EXP1_Unequipped_VeilItem(Creature&in _Creature, const string&in _sItemName, const uint _uAmount)
	{
		print("Unquipped Veil, deactivate " + arr_VeilEffects.length() + " veils" );
		if(arr_VeilEffects.length() < 1)
			return false;
		for( uint i = 0; i < arr_VeilEffects.length(); i++ )
		{
			m_Reference.GetBuildingById(arr_VeilEffects[i]).SetCustomState(Script1, true);
			m_Reference.SetTimerMS(TOnTimerEvent(@this.OnTimer_DeactivateVeilState), 1000);
		//	m_Reference.GetBuildingById(arr_VeilEffects[i]).SetCustomState(Script2, true);
			m_Reference.GetBuildingById(arr_VeilEffects[i]).SetAttackable(false);
		} 
		return false;
	}

	bool OnTimer_ActivateVeilState()
	{
		for( uint i = 0; i < arr_VeilEffects.length(); i++ )
		{
			m_Reference.GetBuildingById(arr_VeilEffects[i]).SetCustomState(Script1, false);
		} 
		return true;
	}

	bool OnTimer_DeactivateVeilState()
	{
		for( uint i = 0; i < arr_VeilEffects.length(); i++ )
		{
			m_Reference.GetBuildingById(arr_VeilEffects[i]).SetCustomState(Script2, false);
		} 
		return true;
	}


	bool OnDamage_Veil(Building& in _Building)
	{
		if( _Building.HasCondition(32000) )
		{
			m_Reference.CastSpell("Exp1_Veil_Destroyed", kFactionNeutral, _Building);
			RemoveVeil(_Building.GetId());
			_Building.Destroy();
			return false;
		}

		return false;
	}
}