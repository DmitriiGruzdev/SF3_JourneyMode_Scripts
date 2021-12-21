enum ESummonType
{
	MoleRider,
	Axewielder,
	DwarfSentry,
	EarthShaper,
	Berserker,
	Pyromancer,
	CombatBalloon,
	FireGolem,
	BanditHealer,
	None
}

enum EWaveType
{
	Special,
	Cheap,
	MixWave,
	Expensive,
	None
}

class Wave
{
	array<SubWave> subWaves;
	uint GetNumberOfSubWaves()
	{
		return subWaves.length();
	}

	Wave()
	{

	}

	Wave(array<SubWave> _subWaves)
	{
		subWaves = _subWaves;
	}

	void AddSubWave(EWaveType _waveType, string _spawnPosition, uint _waveBudget)
	{
		subWaves.insertLast(SubWave(_waveType, _spawnPosition, _waveBudget));
	}

	void AddSpecialSubwave(array<uint> &in _waveData, string _spawnPosition)
	{
		subWaves.insertLast(SubWave(_waveData, _spawnPosition));
	}

	SubWave GetSubWave(uint _index)
	{
		if(_index >= 0 && _index < subWaves.length())
		{
			return subWaves[_index];
		}
		else
		{
			return SubWave(None, "Wrong Index", 0);
		}
	}
}

class SubWave
{
	EWaveType Type;
	string SpawnLocation;
	uint Budget;
	array<ESummonType> SpecialWave;

	SubWave()
	{
		Type = None;
		SpawnLocation = "";
		Budget = 0;
	}

	SubWave(EWaveType _Type, string _SpawnLocation, uint _Budget)
	{
		Type = _Type;
		SpawnLocation = _SpawnLocation;
		Budget = _Budget;
	}

	SubWave(array<uint> &in _waveData, string _SpawnLocation)
	{
		SpawnLocation = _SpawnLocation;
		SpecialWave = BuildSpecialWave(_waveData);
	}
}

array<ESummonType> BuildSpecialWave(array<uint> &in _waveData)
{
	array<ESummonType> result;
	for (int i = 0; i < 9; ++i)
	{
		for(uint j = 0; j < _waveData[i]; ++j)
		{
			result.insertLast(ESummonType(i));
		}
	}
	return result;
}

class Journey_FarlornsHope_Balancing
{
	////
	//	Balancing Values
	////
	// Time in seconds between subsequent waves, should be multiple of 1800 (time before the royal army arrives)
	/*	--------------------------------------------------
	*	Time in seconds between subsequent waves, should be multiple
	*	of 1800 (time before the royal army arrives). Determines
	*	the number of waves to be summoned
	*	--------------------------------------------------
	*/
	array<uint> m_uRecurringWavesTimer = {
										180, 	// Easy
										180, 	// Normal
										180, 	// Hard
										180		// Circle-Mage
									};

	// Logic Object Names for Spawn locations
	string m_sSE_Spot = "DwarvenAttack_SE_Spot";
	string m_sE_Spot = "DwarvenAttack_E_Spot";
	string m_sNE_Spot = "DwarvenAttack_NE_Spot";
	string m_sN_Spot = "DwarvenAttack_N_Spot";
	string m_sNW_Spot = "DwarvenAttack_NW_Spot";
	string m_sW_Spot = "DwarvenAttack_W_Spot";
	string m_sSW_Spot = "DwarvenAttack_SW_Spot";

	//Unitcosts, VALUES SHOULD BE TUNED
	array<uint> m_uUnitCost = {	10, // MoleRider
								15, // Axewielder
								15, // DwarfSentry
								20, // EarthShaper
								30, // Berserker
								40, // Pyromancer
								40, // CombatBalloon
								30, // FireGolem
								15 // BanditHealer
							};

	// Waves Definition
	// Defines special waves of units per wave


	// Airwaves - those you have a hard time chewing
	array<uint> AirWave01 = {0, // MoleRider
							0, // Axewielder
							0, // DwarfSentry
							0, // EarthShaper
							0, // Berserker
							0, // Pyromancer
							1, // CombatBalloon
							0, // FireGolem
							0 // BanditHealer
						};
	array<uint> AirWave02 = {0, // MoleRider
							0, // Axewielder
							0, // DwarfSentry
							0, // EarthShaper
							0, // Berserker
							0, // Pyromancer
							3, // CombatBalloon
							0, // FireGolem
							0 // BanditHealer
						};	
	array<uint> AirWave02_H = {0, // MoleRider
							0, // Axewielder
							0, // DwarfSentry
							0, // EarthShaper
							0, // Berserker
							0, // Pyromancer
							6, // CombatBalloon
							0, // FireGolem
							0 // BanditHealer
						};	

	// Siege wave - threatening towers especially
	array<uint> SiegeWave01 =  {0, // MoleRider
							4, // Axewielder
							0, // DwarfSentry
							0, // EarthShaper
							1, // Berserker
							0, // Pyromancer
							0, // CombatBalloon
							2, // FireGolem
							0 // BanditHealer
						};

	array<uint> SiegeWave01_H =  {0, // MoleRider
							4, // Axewielder
							0, // DwarfSentry
							0, // EarthShaper
							2, // Berserker
							0, // Pyromancer
							0, // CombatBalloon
							2, // FireGolem
							1 // BanditHealer
						};

	array<uint> SiegeWave01_CM =  {0, // MoleRider
							4, // Axewielder
							2, // DwarfSentry
							0, // EarthShaper
							2, // Berserker
							0, // Pyromancer
							0, // CombatBalloon
							4, // FireGolem
							1 // BanditHealer
						};		


	// pre-defined milestone waves
	// easy/normal waves
	array<uint> Wave01 = {2, // MoleRider
							5, // Axewielder
							4, // DwarfSentry
							0, // EarthShaper
							0, // Berserker
							0, // Pyromancer
							0, // CombatBalloon
							0, // FireGolem
							1 // BanditHealer
						};

	array<uint> Wave05 = {4, // MoleRider
							3, // Axewielder
							3, // DwarfSentry
							1, // EarthShaper
							0, // Berserker
							0, // Pyromancer
							0, // CombatBalloon
							0, // FireGolem
							1 // BanditHealer
						};

	array<uint> Wave10 = {4, // MoleRider
							5, // Axewielder
							5, // DwarfSentry
							1, // EarthShaper
							1, // Berserker
							0, // Pyromancer
							0, // CombatBalloon
							0, // FireGolem
							1 // BanditHealer
						};	


	// hard waves
	array<uint> Wave01_H = {2, // MoleRider
							5, // Axewielder
							4, // DwarfSentry
							1, // EarthShaper
							0, // Berserker
							0, // Pyromancer
							0, // CombatBalloon
							0, // FireGolem
							1 // BanditHealer
						};

	array<uint> Wave05_H = {4, // MoleRider
							3, // Axewielder
							3, // DwarfSentry
							1, // EarthShaper
							1, // Berserker
							0, // Pyromancer
							0, // CombatBalloon
							0, // FireGolem
							1 // BanditHealer
						};

	array<uint> Wave10_H = {4, // MoleRider
							5, // Axewielder
							5, // DwarfSentry
							1, // EarthShaper
							1, // Berserker
							1, // Pyromancer
							1, // CombatBalloon
							1, // FireGolem
							1 // BanditHealer
						};	


	// now for circle mage
	array<uint> Wave01_CM = {2, // MoleRider
							5, // Axewielder
							4, // DwarfSentry
							1, // EarthShaper
							1, // Berserker
							1, // Pyromancer
							0, // CombatBalloon
							0, // FireGolem
							1 // BanditHealer
						};
	array<uint> Wave05_CM = {4, // MoleRider
							7, // Axewielder
							5, // DwarfSentry
							1, // EarthShaper
							1, // Berserker
							1, // Pyromancer
							1, // CombatBalloon
							1, // FireGolem
							1 // BanditHealer
						};
	array<uint> Wave10_CM = {4, // MoleRider
							10, // Axewielder
							10, // DwarfSentry
							2, // EarthShaper
							1, // Berserker
							1, // Pyromancer
							1, // CombatBalloon
							1, // FireGolem
							2 // BanditHealer
						};

	// Last wave that is summoned right after royal army arrives
	array<uint> FinalWave = {0, // MoleRider
							15, // Axewielder
							15, // DwarfSentry
							4, // EarthShaper
							2, // Berserker
							2, // Pyromancer
							2, // CombatBalloon
							2, // FireGolem
							6 // BanditHealer
						};


						// setup inspired by red meadows tweaking
	array<Wave> Waves_Easy = {
		// easy and normal are identical
												// wave unit intro: Wave01 + air
	/*	Wave01	*/	Wave(array<SubWave> = {SubWave(Wave01, m_sE_Spot), 					SubWave(Wave01, m_sN_Spot),					SubWave(AirWave01, m_sNW_Spot)}),
											// catch lazy defenses
	/*	Wave02	*/	Wave(array<SubWave> = {SubWave(MixWave, m_sN_Spot, 150), 		 	SubWave(MixWave, m_sW_Spot, 150),			SubWave(MixWave, m_sE_Spot, 150)}),
											// pure air --> always challenging
	/*	Wave03	*/	Wave(array<SubWave> = {SubWave(AirWave02, m_sNE_Spot), 				SubWave(AirWave02, m_sNE_Spot),				SubWave(AirWave02, m_sSE_Spot)}),
											// rest wave
	/*	Wave04	*/	Wave(array<SubWave> = {SubWave(MixWave, m_sN_Spot, 50), 		 	SubWave(MixWave, m_sW_Spot, 50),			SubWave(MixWave, m_sE_Spot, 50)}),
											// show new units: expensive type
	/*	Wave05	*/	Wave(array<SubWave> = {SubWave(Wave05, m_sE_Spot),					SubWave(Wave05, m_sW_Spot),					SubWave(SiegeWave01, m_sN_Spot)}),
											// catch weak defenses off guard again
	/*	Wave06	*/	Wave(array<SubWave> = {SubWave(Expensive, m_sN_Spot, 150), 			SubWave(Expensive, m_sW_Spot, 150),			SubWave(Expensive, m_sE_Spot, 150)}),
											// Siege + Air, solid defenses will have no problem, weak prep might already lose
	/*	Wave07	*/	Wave(array<SubWave> = {SubWave(SiegeWave01, m_sW_Spot), 			SubWave(SiegeWave01, m_sE_Spot), 			SubWave(AirWave02, m_sNE_Spot), 			SubWave(AirWave02, m_sSE_Spot)}),
											// prepare finale, test defenses once again
	/*	Wave09	*/	Wave(array<SubWave> = {SubWave(Expensive, m_sW_Spot, 50), 			SubWave(Expensive, m_sE_Spot, 50), 			SubWave(Expensive, m_sN_Spot, 50)}),
	/*	Wave10	*/	Wave(array<SubWave> = {SubWave(Wave10, m_sW_Spot),					SubWave(SiegeWave01, m_sE_Spot),			SubWave(SiegeWave01, m_sN_Spot)}),
											// hardcore players will end this map by now
	};
	array<Wave> Waves_Normal = {
		// easy and normal are identical
												// wave unit intro: Wave01 + air
	/*	Wave01	*/	Wave(array<SubWave> = {SubWave(Wave01, m_sE_Spot), 					SubWave(Wave01, m_sN_Spot),					SubWave(AirWave01, m_sNW_Spot)}),
											// catch lazy defenses
	/*	Wave02	*/	Wave(array<SubWave> = {SubWave(MixWave, m_sN_Spot, 150), 		 	SubWave(MixWave, m_sW_Spot, 150),			SubWave(MixWave, m_sE_Spot, 150)}),
											// pure air --> always challenging
	/*	Wave03	*/	Wave(array<SubWave> = {SubWave(AirWave02, m_sNE_Spot), 				SubWave(AirWave02, m_sNE_Spot),				SubWave(AirWave02, m_sSE_Spot)}),
											// rest wave
	/*	Wave04	*/	Wave(array<SubWave> = {SubWave(MixWave, m_sN_Spot, 50), 		 	SubWave(MixWave, m_sW_Spot, 50),			SubWave(MixWave, m_sE_Spot, 50)}),
											// show new units: expensive type
	/*	Wave05	*/	Wave(array<SubWave> = {SubWave(Wave05, m_sE_Spot),					SubWave(Wave05, m_sW_Spot),					SubWave(SiegeWave01, m_sN_Spot)}),
											// catch weak defenses off guard again
	/*	Wave06	*/	Wave(array<SubWave> = {SubWave(Expensive, m_sN_Spot, 150), 			SubWave(Expensive, m_sW_Spot, 150),			SubWave(Expensive, m_sE_Spot, 150)}),
											// Siege + Air, solid defenses will have no problem, weak prep might already lose
	/*	Wave07	*/	Wave(array<SubWave> = {SubWave(SiegeWave01, m_sW_Spot), 			SubWave(SiegeWave01, m_sE_Spot), 			SubWave(AirWave02, m_sNE_Spot), 			SubWave(AirWave02, m_sSE_Spot)}),
											// prepare finale, test defenses once again
	/*	Wave09	*/	Wave(array<SubWave> = {SubWave(Expensive, m_sW_Spot, 50), 			SubWave(Expensive, m_sE_Spot, 50), 			SubWave(Expensive, m_sN_Spot, 50)}),
	/*	Wave10	*/	Wave(array<SubWave> = {SubWave(Wave10, m_sW_Spot),					SubWave(SiegeWave01, m_sE_Spot),			SubWave(SiegeWave01, m_sN_Spot)}),
											// hardcore players will end this map by now
	};
	array<Wave> Waves_Hard = {
		// this is the same as CM, but tuned down
												// wave unit intro: Wave01 + air
	/*	Wave01	*/	Wave(array<SubWave> = {SubWave(Wave01_H, m_sE_Spot), 					SubWave(Wave01_CM, m_sN_Spot),				SubWave(AirWave01, m_sNW_Spot)}),
											// catch lazy defenses
	/*	Wave02	*/	Wave(array<SubWave> = {SubWave(MixWave, m_sN_Spot, 200), 			 	SubWave(MixWave, m_sW_Spot, 200),			SubWave(MixWave, m_sE_Spot, 200)}),
											// pure air --> always challenging
	/*	Wave03	*/	Wave(array<SubWave> = {SubWave(AirWave02, m_sNE_Spot), 					SubWave(AirWave02, m_sNE_Spot),				SubWave(AirWave02, m_sSE_Spot)}),
											// rest wave
	/*	Wave04	*/	Wave(array<SubWave> = {SubWave(MixWave, m_sN_Spot, 100), 			 	SubWave(MixWave, m_sW_Spot, 100),			SubWave(MixWave, m_sE_Spot, 100)}),
											// show new units: expensive type
	/*	Wave05	*/	Wave(array<SubWave> = {SubWave(Wave05_H, m_sE_Spot),					SubWave(Wave05_H, m_sW_Spot),				SubWave(SiegeWave01_H, m_sN_Spot)}),
											// catch weak defenses off guard again
	/*	Wave06	*/	Wave(array<SubWave> = {SubWave(Expensive, m_sN_Spot, 200), 				SubWave(Expensive, m_sW_Spot, 200),			SubWave(Expensive, m_sE_Spot, 200)}),
											// Siege + Air, solid defenses will have no problem, weak prep might already lose
	/*	Wave07	*/	Wave(array<SubWave> = {SubWave(SiegeWave01_H, m_sW_Spot), 				SubWave(SiegeWave01_H, m_sE_Spot), 			SubWave(AirWave02, m_sNE_Spot), 			SubWave(AirWave02, m_sSE_Spot)}),
											// prepare finale, test defenses once again
	/*	Wave09	*/	Wave(array<SubWave> = {SubWave(Expensive, m_sW_Spot, 100), 				SubWave(Expensive, m_sE_Spot, 100), 		SubWave(Expensive, m_sN_Spot, 100)}),
	/*	Wave10	*/	Wave(array<SubWave> = {SubWave(Wave10_H, m_sW_Spot),					SubWave(SiegeWave01_H, m_sE_Spot),			SubWave(SiegeWave01_H, m_sN_Spot)}),
											// hardcore players will end this map by now
	};
	array<Wave> Waves_Insane = {
		// This is the base wave, CM, hardest
		// all other difficulties derive from this logic & are tuned down

												// wave unit intro: Wave01 + air
	/*	Wave01	*/	Wave(array<SubWave> = {SubWave(Wave01_CM, m_sE_Spot), 					SubWave(Wave01_CM, m_sN_Spot),				SubWave(AirWave01, m_sNW_Spot)}),
											// catch lazy defenses
	/*	Wave02	*/	Wave(array<SubWave> = {SubWave(MixWave, m_sN_Spot, 250), 			 	SubWave(MixWave, m_sW_Spot, 250),			SubWave(MixWave, m_sE_Spot, 250)}),
											// pure air --> always challenging
	/*	Wave03	*/	Wave(array<SubWave> = {SubWave(AirWave02_H, m_sNE_Spot), 				SubWave(AirWave02_H, m_sNE_Spot),			SubWave(AirWave02_H, m_sSE_Spot)}),
											// rest wave
	/*	Wave04	*/	Wave(array<SubWave> = {SubWave(MixWave, m_sN_Spot, 150), 			 	SubWave(MixWave, m_sW_Spot, 150),			SubWave(MixWave, m_sE_Spot, 150)}),
											// show new units: expensive type
	/*	Wave05	*/	Wave(array<SubWave> = {SubWave(Wave05_CM, m_sE_Spot),					SubWave(Wave05_CM, m_sW_Spot),				SubWave(SiegeWave01_CM, m_sN_Spot)}),
											// catch weak defenses off guard again
	/*	Wave06	*/	Wave(array<SubWave> = {SubWave(Expensive, m_sN_Spot, 250), 				SubWave(Expensive, m_sW_Spot, 250),			SubWave(Expensive, m_sE_Spot, 250)}),
											// Siege + Air, solid defenses will have no problem, weak prep might already lose
	/*	Wave07	*/	Wave(array<SubWave> = {SubWave(SiegeWave01_CM, m_sW_Spot), 				SubWave(SiegeWave01_CM, m_sE_Spot), 		SubWave(AirWave02, m_sNE_Spot), 			SubWave(AirWave02, m_sSE_Spot)}),
											// prepare finale, test defenses once again
	/*	Wave09	*/	Wave(array<SubWave> = {SubWave(Expensive, m_sW_Spot, 150), 				SubWave(Expensive, m_sE_Spot, 150), 		SubWave(Expensive, m_sN_Spot, 150)}),
	/*	Wave10	*/	Wave(array<SubWave> = {SubWave(Wave10_CM, m_sW_Spot),					SubWave(SiegeWave01_CM, m_sE_Spot),			SubWave(SiegeWave01_CM, m_sN_Spot)}),
											// hardcore players will end this map by now
		};

	array<array<Wave>> WavesByDifficulty =
	{
		Waves_Easy,
		Waves_Normal,
		Waves_Hard,
		Waves_Insane
	};
	
	Journey_FarlornsHope_Balancing()
	{

	}
}