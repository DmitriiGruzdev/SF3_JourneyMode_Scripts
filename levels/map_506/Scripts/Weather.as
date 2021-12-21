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
			SetRoughnessMultiplicator( 1.25f );
			SetCloudStrenghtMultiplicator( 0.90f );

			RegisterWeatherSet( "FH1", 0, true );
			AddProfile( 		"FH1", "cloudyLight", 		30, 40,  45, 60 );
			AddProfile( 		"FH1", "sunshine", 	35, 40,  45, 60 );
			//AddProfile( 		"FH1", "sunshineFoggy", 		40, 50,  46, 60 );
			//AddProfile( 		"FH1", "rainLight", 		40, 50,  30, 40 );
			AddProfile( 		"FH1", "cloudy", 	30, 40,  45, 90 );
		}
		
		if ( iCurrentSetting == 1 ) 
		{
			SetRoughnessTimer( 30 ); 
			SetRoughnessMultiplicator( 1.25f );
			SetCloudStrenghtMultiplicator( 0.90f );

			RegisterWeatherSet( "FH2", 1, true );
			AddProfile( 		"FH2", "cloudyLight", 		30, 40,  45, 60 );
			AddProfile( 		"FH2", "cloudyLight", 	30, 40,  40, 30 );
			AddProfile( 		"FH2", "cloudy", 		40, 50,  35, 40 );
			//AddProfile( 		"FH2", "rainLight", 		40, 50,  20, 30 );
			AddProfile( 		"FH2", "sunshine", 	30, 40,  70, 90 );
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