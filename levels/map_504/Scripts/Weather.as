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
			SetRoughnessTimer( 30 ); 
			SetRoughnessMultiplicator( 1.15f );
			SetCloudStrenghtMultiplicator( 1.00f );

			RegisterWeatherSet( "Leafshade1", 0, true );
			AddProfile( 		"Leafshade1", "sunshine", 		30, 40,  40, 120 );
			AddProfile( 		"Leafshade1", "sunshine", 			35, 40,  15, 40 );
			AddProfile( 		"Leafshade1", "sunshine", 		30, 40,  40, 120 );
			AddProfile( 		"Leafshade1", "cloudyLight", 			40, 50,  45, 50 );
			AddProfile( 		"Leafshade1", "sunshine", 		30, 40,  40, 50 );
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