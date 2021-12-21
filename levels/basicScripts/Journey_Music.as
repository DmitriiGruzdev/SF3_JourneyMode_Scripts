
enum MusicIntensity
{
	normal = 	0,
	low = 		100,
	med = 		500,
	high = 		1000
}

mixin class Journey_Music
{
	string m_sVersion_Music = "1.0 - 10.07.2019 - 11:15";

	// --- SETTING AND COMBAT MUSIC 
	bool m_b_BossMusicPlaying = false;

	void PlayTrack ( string _sTrack ) 
	{
		m_Reference.SetGlobalSoundTrack(uint8(-1), uint8(-1), TrackMusic, _sTrack );
	}

	void PlaySetting( string _sSetting )
	{
		m_Reference.SetGlobalSoundTrack( uint8(-1), uint8(-1), TrackMusic, ("music/setting/"+_sSetting) );
	}

	void PlaySetting_Combat( string _stgSetting, MusicIntensity _eIntensity )
	{
		m_Reference.SetGlobalSoundTrack( uint8(-1), uint8(-1), TrackMusic, ("music/setting/"+_stgSetting) );
		m_Reference.SetGlobalSoundParameter( uint8(-1), uint8(-1), "intro", 1 );
		m_Reference.SetGlobalSoundParameter( uint8(-1), uint8(-1), "opener", 0 );
		
		// m_Reference.SetGlobalSoundParameter( uint8(-1), uint8(-1), "battle", 10 );

		// handling the intensity
		// ToDo: Setting the intensity hard to a predefined value
		m_Reference.SuspendAutomaticCombatMusic( uint8(-1), uint8(-1), true );
		m_Reference.SetGlobalSoundParameter( uint8(-1), uint8(-1), "combat", 1 );
		m_Reference.SetGlobalSoundParameter( uint8(-1), uint8(-1), "intensity", _eIntensity );
	}

	// should be called to reset the music back to normal
	void PlaySetting_Reset ( string _sOriginalSetting = "" )
	{
		m_Reference.SetGlobalSoundTrack( uint8(-1), uint8(-1), TrackMusic, (_sOriginalSetting));
		m_Reference.SetGlobalSoundParameter( uint8(-1), uint8(-1), "intro", 1 );
		m_Reference.SetGlobalSoundParameter( uint8(-1), uint8(-1), "opener", 0 ); 
		
		// ToDo later: "free" the intensity again for a normal calculation
		m_Reference.SuspendAutomaticCombatMusic( uint8(-1), uint8(-1), false );
		//m_Reference.SetGlobalSoundParameter( uint8(-1), uint8(-1), "intensity", 0 );
	}

	void PlayTrack_Intensity( MusicIntensity _eIntensity )
	{
		// handling the intensity
		m_Reference.SuspendAutomaticCombatMusic( uint8(-1), uint8(-1), true );
		m_Reference.SetGlobalSoundParameter( uint8(-1), uint8(-1), "combat", 1 );
		m_Reference.SetGlobalSoundParameter( uint8(-1), uint8(-1), "intensity", _eIntensity );
	}

	void PlayTrack_BossBattle( bool _suspendAutomaticCombat = false )
	{
		if( m_b_BossMusicPlaying )
		{
			return;
		}

		if( _suspendAutomaticCombat )
		{
			m_Reference.SuspendAutomaticCombatMusic(uint8(-1), uint8(-1), true);	
		}

		printNote("Boss Battle Track should play");
		m_Reference.SetGlobalSoundParameter(uint8(-1), uint8(-1), "bossfight", 1);
		m_Reference.SetGlobalSoundParameter(uint8(-1), uint8(-1), "combat", 1);
		m_Reference.SetGlobalSoundParameter(uint8(-1), uint8(-1), "intro", 1);
		m_Reference.SetGlobalSoundParameter(uint8(-1), uint8(-1), "intensity", 1000);
		m_b_BossMusicPlaying = true;
	}

	void PlayTrack_BackFromBossBattle()
	{
		if( !m_b_BossMusicPlaying )
		{
			return;
		}
		
		printNote("Boss Battle Track should stop");
		m_Reference.SetGlobalSoundParameter(uint8(-1), uint8(-1), "bossfight", 0);
		m_Reference.SetGlobalSoundParameter(uint8(-1), uint8(-1), "intro", 0);
		m_Reference.SuspendAutomaticCombatMusic(uint8(-1), uint8(-1), false);
		m_b_BossMusicPlaying = false;
	}

	void PlayTrack_Silence ()
	{
		PlayTrack("music/silence");
	}

	void PlayTrack_Intensity_low () 
	{		
		PlayTrack_Intensity( low );	
	}

	void PlayTrack_Intensity_med () 
	{		
		PlayTrack_Intensity( med );	
	}

	void PlayTrack_Intensity_high () 
	{		
		PlayTrack_Intensity( high ); 
	}

	void PlaySetting_ashlands ( ) 
	{			
		PlaySetting_Reset( "ashlands" );		
	}
	
	void PlaySetting_ashlands_low ( ) 
	{
		PlaySetting_Combat( "ashlands", low );
	}
	
	void PlaySetting_ashlands_med ( ) 
	{
		PlaySetting_Combat( "ashlands", med );
	}
	
	void PlaySetting_ashlands_high ( ) 
	{
		PlaySetting_Combat( "ashlands", high );
	}

	void PlaySetting_desert ( ) 
	{
			PlaySetting_Reset( "desert" );		
		}
	
	void PlaySetting_desert_low ( ) 
	{
		PlaySetting_Combat( "desert", low );
	}
	
	void PlaySetting_desert_med ( ) 
	{
		PlaySetting_Combat( "desert", med );
	}
	
	void PlaySetting_desert_high ( ) 
	{
		PlaySetting_Combat( "desert", high );
	}

	void PlaySetting_grassland ( )
	{
		PlaySetting_Reset( "grassland" );			
	}

	void PlaySetting_grassland_low ( )
	{
		PlaySetting_Combat( "grassland", low );		
	}

	void PlaySetting_grassland_med ( )
	{
		PlaySetting_Combat( "grassland", med );		
	}

	void PlaySetting_grassland_high ( )
	{
		PlaySetting_Combat( "grassland", high );	
	}

	void PlaySetting_grasslandNight ( )
	{
			PlaySetting_Reset( "grassland_night" );			
	}

	void PlaySetting_grasslandNight_low ( )
	{
		PlaySetting_Combat( "grassland_night", low );		
	}

	void PlaySetting_grasslandNight_med ( )
	{
		PlaySetting_Combat( "grassland_night", med );		
	}

	void PlaySetting_grasslandNight_high ( )
	{
		PlaySetting_Combat( "grassland_night", high );	
	}

	void PlaySetting_jungle ( )
	{
		PlaySetting_Reset( "jungle" );				
	}

	void PlaySetting_jungle_low ( )
	{
		PlaySetting_Combat( "jungle", low );		
	}

	void PlaySetting_jungle_med ( )
	{
		PlaySetting_Combat( "jungle", med );		
	}

	void PlaySetting_jungle_high ( )
	{
		PlaySetting_Combat( "jungle", high );		
	}

	void PlaySetting_mountains ( ) 
	{
		PlaySetting_Reset( "mountains" );			
	}

	void PlaySetting_mountains_low ( ) 
	{
		PlaySetting_Combat( "mountains", low );		
	}

	void PlaySetting_mountains_med ( ) 
	{
		PlaySetting_Combat( "mountains", med );		
	}

	void PlaySetting_mountains_high ( ) 
	{
		PlaySetting_Combat( "mountains", high );	
	}

	void PlaySetting_swamp ( ) 
	{
		PlaySetting_Reset( "swamp" );				
	}

	void PlaySetting_swamp_low ( ) 
	{
		PlaySetting_Combat( "swamp", low );			
	}

	void PlaySetting_swamp_med ( ) 
	{
		PlaySetting_Combat( "swamp", med );			
	}

	void PlaySetting_swamp_high ( ) 
	{
		PlaySetting_Combat( "swamp", high );		
	}

	void PlaySetting_dungeon ( ) 
	{
		PlaySetting_Reset( "dungeon" );				
	}

}