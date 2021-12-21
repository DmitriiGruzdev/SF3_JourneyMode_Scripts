// ------------------------------------------------------------------------------------------------------------------------------------
// ---- Map 031

// includes:
#include "../../basicScripts/WeatherBase.as"

// -----------------------------------------------------------------------------------------------------------------------

class Weather: WeatherBase
{
	// Weather Version
	string m_stgWeatherVersion = "0.2 - 29.06.2017 - 11:45";
	//string m_stgWeatherVersion = "0.1 - 28.06.2017 - 17:00";
	
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
		}
		else if ( iCurrentSetting == 1 ) // Second setting
		{
		}
		else if ( iCurrentSetting == 2 ) // third setting
		{
		}

		// ----------------------------------------------------------------------------------------------------------------
		// --- Setting up the weather sets

		// the numbers stand for
		// 1st and 2nd values: indicates how long it takes to change to this weather profile (min and max value)
		// 3rd and 4th values: the weather phase itself. Rain only takes place in this timeframe (min and max value)	

		RegisterWeatherSet( "Standard", 0, true );
		AddProfile( 	"Standard", "cloudyLight", 		30, 40,  35, 40 );
		AddProfile( 	"Standard", "cloudy", 			35, 40,  34, 60 );
		AddProfile( 	"Standard", "sunshine", 35, 40,  35, 70 );
		AddProfileAfter( "Standard", "cloudyHeavyWindy", "cloudyWindy", 35, 40,  20, 40 );

		/* --- Profiles that can be used: ---------------------------------------------------
			sunshine	sunshineFoggy	
			overcastThunder 	overcastLight	overcast	overcastHeavy
			cloudyLight		cloudyLightFoggy 	cloudyLightWindy		
			cloudy 	cloudyFoggy 	cloudyWindy 		
			cloudyHeavy 	cloudyHeavyFoggy cloudyHeavyWindy
			rainLight 	rain 	 rainHeavy
			stormLight 	storm 	stormHeavy 
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