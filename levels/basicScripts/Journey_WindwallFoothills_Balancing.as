enum ESummonType
{
	Spectre,
	Spider,
	Sleeper,
	Infiltrator,
	Scion,
	TwistedOne,
	LizardRider,
	PlagueBeetle,
	NorsEmissary,
	FleshThrower,
	None
}

class Summon
{
	array<ESummonType> SpecialWave;

	Summon()
	{

	}

	Summon(array<uint> &in _waveData)
	{
		SpecialWave = BuildSpecialWave(_waveData);
	}
}

array<ESummonType> BuildSpecialWave(array<uint> &in _waveData)
{
	array<ESummonType> result;
	for (int i = 0; i < 10; ++i)
	{
		for(uint j = 0; j < _waveData[i]; ++j)
		{
			result.insertLast(ESummonType(i));
		}
	}
	return result;
}

class Journey_WindwallFoothills_BalancingData
{
	////
	//	Balancing Values
	////
	// Waves to be summoned in relation to current expansion stage and difficulty
	// Easy
	array<uint> EasySummon_0 = {	1 , // Spectre
									4 , // Spider
									0 , // Sleeper
									4 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> EasySummon_1 = {	1 , // Spectre
									8 , // Spider
									0 , // Sleeper
									4 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									1 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> EasySummon_2 = {	1 , // Spectre
									8 , // Spider
									2 , // Sleeper
									6 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> EasySummon_3 = {	1 , // Spectre
									0 , // Spider
									4 , // Sleeper
									4 , // Infiltrator
									1 , // Scion
									1 , // TwistedOne
									0 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> EasySummon_4 = {	1 , // Spectre
									2 , // Spider
									4 , // Sleeper
									4 , // Infiltrator
									2 , // Scion
									2 , // TwistedOne
									2 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};																													
	// Normal
	array<uint> NormalSummon_0 = {	1 , // Spectre
									4 , // Spider
									0 , // Sleeper
									4 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> NormalSummon_1 = {	1 , // Spectre
									8 , // Spider
									0 , // Sleeper
									4 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									1 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> NormalSummon_2 = {	1 , // Spectre
									8 , // Spider
									2 , // Sleeper
									6 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> NormalSummon_3 = {	1 , // Spectre
									0 , // Spider
									4 , // Sleeper
									4 , // Infiltrator
									1 , // Scion
									1 , // TwistedOne
									0 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> NormalSummon_4 = {	1 , // Spectre
									2 , // Spider
									4 , // Sleeper
									4 , // Infiltrator
									2 , // Scion
									2 , // TwistedOne
									2 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	// Hard
	array<uint> HardSummon_0 = {	1 , // Spectre
									4 , // Spider
									0 , // Sleeper
									6 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> HardSummon_1 = {	1 , // Spectre
									8 , // Spider
									0 , // Sleeper
									6 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									1 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> HardSummon_2 = {	1 , // Spectre
									8 , // Spider
									3 , // Sleeper
									8 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> HardSummon_3 = {	1 , // Spectre
									0 , // Spider
									4 , // Sleeper
									8 , // Infiltrator
									2 , // Scion
									2 , // TwistedOne
									1 , // LizardRider
									0 , // PlagueBeetle
									1 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> HardSummon_4 = {	1 , // Spectre
									2 , // Spider
									5 , // Sleeper
									8 , // Infiltrator
									3 , // Scion
									3 , // TwistedOne
									3 , // LizardRider
									0 , // PlagueBeetle
									2 , // NorsEmissary
									0 	// FleshThrower
							};
	// Insane
	array<uint> InsaneSummon_0 = {	1 , // Spectre
									4 , // Spider
									2 , // Sleeper
									6 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									0 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> InsaneSummon_1 = {	1 , // Spectre
									8 , // Spider
									2 , // Sleeper
									6 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									1 , // PlagueBeetle
									0 , // NorsEmissary
									0 	// FleshThrower
							};
	array<uint> InsaneSummon_2 = {	1 , // Spectre
									8 , // Spider
									3 , // Sleeper
									8 , // Infiltrator
									0 , // Scion
									0 , // TwistedOne
									0 , // LizardRider
									1 , // PlagueBeetle
									0 , // NorsEmissary
									1 	// FleshThrower
							};
	array<uint> InsaneSummon_3 = {	1 , // Spectre
									0 , // Spider
									4 , // Sleeper
									8 , // Infiltrator
									2 , // Scion
									2 , // TwistedOne
									1 , // LizardRider
									2 , // PlagueBeetle
									1 , // NorsEmissary
									1 	// FleshThrower
							};
	array<uint> InsaneSummon_4 = {	1 , // Spectre
									2 , // Spider
									5 , // Sleeper
									8 , // Infiltrator
									3 , // Scion
									3 , // TwistedOne
									3 , // LizardRider
									2 , // PlagueBeetle
									2 , // NorsEmissary
									1 	// FleshThrower
							};
	// Sets of summons for each difficulty
	array<Summon> Summons_Easy = {
	/*	1st expansion	*/	Summon(EasySummon_0),
	/*	2nd expansion	*/  Summon(EasySummon_1),
	/*	3rd expansion	*/  Summon(EasySummon_2),
	/*	4th expansion	*/  Summon(EasySummon_3),
	/*	5th expansion	*/  Summon(EasySummon_4)
	};
	array<Summon> Summons_Normal = {
	/*	1st expansion	*/	Summon(NormalSummon_0),
	/*	2nd expansion	*/  Summon(NormalSummon_1),
	/*	3rd expansion	*/  Summon(NormalSummon_2),
	/*	4th expansion	*/  Summon(NormalSummon_3),
	/*	5th expansion	*/  Summon(NormalSummon_4)
	};
	array<Summon> Summons_Hard = {
	/*	1st expansion	*/	Summon(HardSummon_0),
	/*	2nd expansion	*/  Summon(HardSummon_1),
	/*	3rd expansion	*/  Summon(HardSummon_2),
	/*	4th expansion	*/  Summon(HardSummon_3),
	/*	5th expansion	*/  Summon(HardSummon_4)
	};
	array<Summon> Summons_Insane = {
	/*	1st expansion	*/	Summon(InsaneSummon_0),
	/*	2nd expansion	*/  Summon(InsaneSummon_1),
	/*	3rd expansion	*/  Summon(InsaneSummon_2),
	/*	4th expansion	*/  Summon(InsaneSummon_3),
	/*	5th expansion	*/  Summon(InsaneSummon_4)
	};

	Journey_WindwallFoothills_BalancingData()
	{

	}
}