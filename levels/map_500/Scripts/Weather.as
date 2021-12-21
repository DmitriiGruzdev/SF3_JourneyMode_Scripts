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
			// SetCloudStrenghtMultiplicator( 1.0f );

			// RegisterWeatherSet("Burial", 0, false);
			// AddProfile("Burial", "EXP2_rain", 5, 10, 5, 10);
			// m_Reference.SetEffectIntensity( Rain, 0.125f );
			// EnableWeatherSet("Burial");

			SetCloudStrenghtMultiplicator( 1.20f );

			RegisterWeatherSet( "Standard", 0, true );
			AddProfile( 		"Standard", "cloudyLight", 		20, 30,  10, 15 );
			// AddProfile( 		"Rain", "rain", 		20, 30,  10, 15 );
			// AddProfile( 		"Rain", "rain", 	20, 40,  10, 15 );
			// AddProfile( 		"Rain", "rain", 	20, 40,  25, 35 );
			// AddProfile( 		"Cloudy", "cloudyHeavy", 	10, 20,  5, 10 );
		}
		else if ( iCurrentSetting == 1 ) // Second setting
		{
			//SetRoughnessTimer( 30 ); 
			//SetRoughnessMultiplicator( 1.50f );
			/*SetCloudStrenghtMultiplicator( 0.90f );

			RegisterWeatherSet( "CloudyAndRainy", 1, true );
			AddProfile( 		"CloudyAndRainy", "cloudyLight", 		15, 20,  15, 20 );
			AddProfile( 		"CloudyAndRainy", "cloudyLightWindy", 	15, 20,  15, 20 );
			AddProfile( 		"CloudyAndRainy", "cloudyWindy", 		10, 20,  15, 20 );
			AddProfile( 		"CloudyAndRainy", "cloudyHeavyWindy", 	10, 20,  15, 20 );*/
		}
		else if ( iCurrentSetting == 2 ) // third setting
		{
			//SetRoughnessTimer( 30 ); 
			//SetRoughnessMultiplicator( 1.50f );
			//SetCloudStrenghtMultiplicator( 0.95f );
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