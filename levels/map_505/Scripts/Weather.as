// ------------------------------------------------------------------------------------------------------------------------------------
// ---- Map XXX - Example Weather Script

// includes:
#include "../../basicScripts/WeatherBase.as"

// -----------------------------------------------------------------------------------------------------------------------

class Weather: WeatherBase
{
	// Weather Version
	string m_stgWeatherVersion = "0.1 - 29.06.2017 - 11:45";
	
	// constructor:
	Weather (WeatherReference@ _Reference)
	{
		super(_Reference);
	}
	
	// --------------------------------------------------------------------------------------------------------------------
	// basic interface:

	// level is being created for the first time - only called once for a campaign
	void OnCreated () override
	{
		printWeather("--- W E A T H E R :  WeatherBase: "+m_WeatherBaseVersion+", Weather Script: " + m_stgWeatherVersion+".");

		// calling the original OnCreated() from the WeatherBase.as
		WeatherBase::OnCreated();
		
		// ----------------------------------------------------------------------------------------------------------------
		// --- Configuring stuff - with regards of the different settings
		
		if ( iCurrentSetting == 0 ) // First setting
		{
			//SetRoughnessTimer( 30 ); 
			//SetRoughnessMultiplicator( 1.50f );
			SetCloudStrenghtMultiplicator( 1.20f );

			RegisterWeatherSet( "CloudyHeavyWindy", 0, true );
			AddProfile( 		"CloudyHeavyWindy", "overcastLight", 		20, 30,  10, 15 );
			//AddProfile( 		"Rain", "cloudyHeavyFoggy", 	15, 20,  45, 70 );
		}
		else if ( iCurrentSetting == 1 ) // Second setting
		{
			SetRoughnessTimer( 30 ); 
			//SetRoughnessMultiplicator( 1.50f );
			SetCloudStrenghtMultiplicator( 0.90f );

			RegisterWeatherSet( "CloudyAndRainy2", 1, true );
			AddProfile( 		"CloudyAndRainy2", "sunshine", 		10, 20,  100, 150 );
			AddProfile( 		"CloudyAndRainy2", "sunshineFoggy", 	15, 20,  90, 120 );

		}
		else if ( iCurrentSetting == 2 ) // third setting
		{
			SetRoughnessTimer( 30 ); 
			//SetRoughnessMultiplicator( 1.50f );
			SetCloudStrenghtMultiplicator( 0.90f );

			RegisterWeatherSet( "CloudyAndRainy3", 2, true );
			AddProfile( 		"CloudyAndRainy3", "sunshine", 		10, 20,  100, 150 );
			AddProfile( 		"CloudyAndRainy3", "sunshineFoggy", 	15, 20,  90, 120 );
	
		}

		/* --- Profiles that can be used: ---------------------------------------------------
			sunshine		sunshineFoggy	
			overcastThunder overcastLight		overcast			overcastHeavy
			cloudyLight		cloudyLightFoggy 	cloudyLightWindy		
			cloudy 			cloudyFoggy 		cloudyWindy 		
			cloudyHeavy 	cloudyHeavyFoggy 	cloudyHeavyWindy
			rainLight 		rain 	 			rainHeavy
			stormLight 		storm 				stormHeavy 
			interior 		interiorFoggyLight	interiorFoggy 		interiorFoggyHeavy
		*/
		// ----------------------------------------------------------------------------------
		
		// Starting and calculating everything for the weather
		StartWeather();

		// ----------------------------------------------------------------------------------
	}
	
	void OnLoaded (const uint _uVersion) override
	{
		// calling the original OnCreated() from the WeatherBase.as
		WeatherBase::OnLoaded(_uVersion);

		// Starting and calculating everything for the weather
		StartWeather();

	}

	// -------------------------------------------------------------------------------------------------------------------
	// specific Weather Set calls


	// -------------------------------------------------------------------------------------------------------------------
}