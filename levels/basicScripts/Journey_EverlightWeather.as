enum EWeatherType
{
	DefaultCloudy,
	Sunshine,
	CloudyFoggy,
	HeavyCloudyFoggy,
	OvercastThunder,
	RainLight,
	RainHeavy,
	StormHeavy,
	None
}

mixin class Journey_EverlightWeather
{
	// Configuration of how Everlight weather changes after finishing a certain map
	dictionary m_MapId_WeatherChange =
	{
		{"501", RainLight}, 
		{"502", Sunshine},
		{"503", CloudyFoggy},
		{"504", HeavyCloudyFoggy},
		{"505", OvercastThunder},
		{"506", Sunshine},
		{"507", DefaultCloudy},
		{"508", RainHeavy},
		{"509", StormHeavy},
		{"510", DefaultCloudy}
	};

	string TranslateWeatherEnum( uint _iNmbr )
	{
		string _stgWeatherType = "";
		switch( _iNmbr )
		{	
			case 0:
				_stgWeatherType = "DefaultCloudy"; break;
			case 1:
				_stgWeatherType = "Sunshine"; break;
			case 2:
				_stgWeatherType = "CloudyFoggy"; break;
			case 3:
				_stgWeatherType = "HeavyCloudyFoggy"; break;
			case 4:
				_stgWeatherType = "OvercastThunder"; break;
			case 5:
				_stgWeatherType = "RainLight"; break;
			case 6:
				_stgWeatherType = "RainHeavy"; break;
			case 7:
				_stgWeatherType = "StormHeavy"; break;
		}
		return _stgWeatherType;
	}

	void SetEverlightWeather()
	{
		int _iWeatherSetting;
		m_MapId_WeatherChange.get(GetString_CurrentMapId(), _iWeatherSetting);
		
		string _sWeatherSetting = TranslateWeatherEnum(_iWeatherSetting);
		m_Reference.GetWorld().SetGlobalInt("Journey_CampaignVariables.Journey_500_iEverlightWeatherSetting", _iWeatherSetting);
		print("Everlight weather is set to "+_sWeatherSetting);
	}

	void EnableEverlightWeather()
	{
		int _iWeatherSetting = m_Reference.GetWorld().GetGlobalInt("Journey_CampaignVariables.Journey_500_iEverlightWeatherSetting");
		string _sWeatherSetting = TranslateWeatherEnum(_iWeatherSetting);
		switch(_iWeatherSetting)
		{
			case DefaultCloudy:
				Weather_cloudyLight();
				break;
			case Sunshine:
				Weather_sunshine();
				break;
			case CloudyFoggy:
				Weather_cloudyFoggy();
				break;
			case HeavyCloudyFoggy:
				Weather_cloudyHeavyFoggy();
				break;
			case OvercastThunder:
				Weather_overcastThunder();
				break;
			case RainLight:
				Weather_overcastRainLight();
				break;
			case RainHeavy:
				Weather_rainHeavy();
				break;
			case StormHeavy:
				Weather_stormHeavy();
				break;
		}
		print("Everlight weather should be set to "+_sWeatherSetting);
	}

	// -------------------------------------------------------------------------------------------------------------------
	// --- W E A T H E R  F U N C T I O N S -----------------------------------------------------------------------------

	void Weather_sunshine() { 			m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'sunshine' ) "); } // used in weather settings, Sunshine
	void Weather_sunshineFoggy() { 		m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'sunshineFoggy' ) "); }

	void Weather_overcastLight() { 		m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'overcastLight' ) "); }
	void Weather_overcast() { 			m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'overcast' ) "); }
	void Weather_overcastHeavy() { 		m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'overcastHeavy' ) "); }
	void Weather_overcastThunder() { 	m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'overcastThunder' ) "); } // used in weather settings, OvercastThunder
	
	void Weather_overcastRainLight() { 	m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'overcastRainLight' ) "); } // used in weather settings, RainLight
	void Weather_overcastStormyLight() {m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'overcastStormyLight' ) "); }
	
	void Weather_cloudyLight() { 		m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'cloudyLight' ) "); } // used in weather settings, DefaultCloudy
	void Weather_cloudyLightFoggy() { 	m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'cloudyLightFoggy' ) "); } 
	void Weather_cloudyLightWindy() { 	m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'cloudyLightWindy' ) "); }
	
	void Weather_cloudy() {				m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'cloudy' ) "); }
	void Weather_cloudyFoggy() { 		m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'cloudyFoggy' ) "); } // used in weather settings, CloudyFoggy
	void Weather_cloudyWindy() { 		m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'cloudyWindy' ) "); }
	
	void Weather_cloudyHeavy() { 		m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'cloudyHeavy' ) "); }
	void Weather_cloudyHeavyFoggy() { 	m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'cloudyHeavyFoggy' ) "); } // used in weather settings, HeavyCloudyFoggy
	void Weather_cloudyHeavyWindy() { 	m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'cloudyHeavyWindy' ) "); }

	void Weather_rainLight() { 			m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'rainLight' ) "); }
	void Weather_rain() { 				m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'rain' ) "); }
	void Weather_rainHeavy() { 			m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'rainHeavy' ) "); } // used in weather settings, RainHeavy
	
	void Weather_stormLight() { 		m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'stormLight' ) "); }
	void Weather_storm() { 				m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'storm' ) "); }
	void Weather_stormHeavy() { 		m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'stormHeavy' ) "); } // used in weather settings, StormHeavy

	void Weather_interior() { 			m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'interior' ) "); }
	void Weather_interiorFoggyLight() { m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'interiorFoggyLight' ) "); }
	void Weather_interiorFoggy() { 		m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'interiorFoggy' ) "); }
	void Weather_interiorFoggyHeavy() { m_Reference.CallWeatherScript( "Script.SetWeatherProfile ( 'interiorFoggyHeavy' ) "); }
}

