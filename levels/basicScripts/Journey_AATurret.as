// ------------------------------------------------------------------------------------------------------------------------------------
class AirDefenseTurret
{
	string m_sBuildingName;
	string m_sSpellName;
	uint m_uBuildingId;
	array<uint> m_ProductionQueue;
	bool m_bProductionRunning;

	AirDefenseTurret()
	{
		m_sBuildingName = "";
		m_uBuildingId = 0;
		m_ProductionQueue = array<uint>();
		m_bProductionRunning = false;
	}

	AirDefenseTurret(const AirDefenseTurret &in _other)
    {
		m_sBuildingName = _other.m_sBuildingName;
		m_uBuildingId = _other.m_uBuildingId;
		m_ProductionQueue = _other.m_ProductionQueue;
		m_bProductionRunning = _other.m_bProductionRunning;
    }

	AirDefenseTurret(LevelReference@ _LevelRef, const string _sName, const string _sSpellName, TOnBuildingEvent@ _Event)
	{
		m_sBuildingName = _sName;
		m_sSpellName = _sSpellName;
		Building Turret = _LevelRef.GetBuildingByName(m_sBuildingName);
		m_uBuildingId = Turret.GetId();
		_LevelRef.RegisterBuildingEventByIndividual(ProductionFinished, _Event, Turret);
	}


	void fireAt(LevelReference@ _LevelRef, uint _uEntityId)
	{
		if (m_bProductionRunning)
		{
			m_ProductionQueue.push_back(_uEntityId);
		}
		else
		{
			m_bProductionRunning = true;
			addProduction(_LevelRef, _uEntityId);
		}
	}

	void onProductionFinished(LevelReference@ _LevelRef)
	{
		if (m_ProductionQueue.empty())
		{
			m_bProductionRunning = false;
		}
		else
		{
			addProduction(_LevelRef, m_ProductionQueue[m_ProductionQueue.length() - 1]);
			m_ProductionQueue.pop_back();
		}
	}

	void addProduction(LevelReference@ _LevelRef, uint _uEntityId)
	{
		Creature creature = _LevelRef.GetCreatureById(_uEntityId);
		Building FlakTower = _LevelRef.GetBuildingByName(m_sBuildingName);
 		if (creature.Exists() && FlakTower.Exists())
 		{
			FlakTower.AddProductionAssignment(Spell, m_sSpellName, creature);
		}
 	}
}

// ------------------------------------------------------------------------------------------------------------------------------------
mixin class Journey_AATurret
{
	array<AirDefenseTurret> m_AATurrets;


	bool OnAATowerProductionFinished(Building&in _Building)
	{
		for (uint i = 0; i < m_AATurrets.length(); ++i)
		{
			if (m_AATurrets[i].m_uBuildingId == _Building.GetId())
			{
				m_AATurrets[i].onProductionFinished(m_Reference);
			}
		}

		return false;
	}

	void AddAATurrets(uint _uNumberToAdd, const string _sSpellName, const string _sTurretNamePrefix)
	{
		for (uint i = 0; i < _uNumberToAdd; ++i)
		{
			uint uTowerNumber = m_AATurrets.length() + 1;
			string sTowerName = _sTurretNamePrefix + uTowerNumber;
			m_AATurrets.push_back(AirDefenseTurret(m_Reference, sTowerName, _sSpellName, @TOnBuildingEvent(@this.OnAATowerProductionFinished)));
		}
	}

	void AATurretFireAt(const uint _uTowerNumber, const uint _uTargetId)
	{
		m_AATurrets[_uTowerNumber - 1].fireAt(m_Reference, _uTargetId);
	}
}
