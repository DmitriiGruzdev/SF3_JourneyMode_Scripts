// -----------------------------------------------------------------------------------------------------------------------
#include "../../basicScripts/Journey_AATurret.as"
#include "../../basicScripts/Journey_EverlightWeather.as"
#include "../../basicScripts/Journey_MiniBosses.as"
#include "../../basicScripts/Journey_QuestRewards.as"
#include "../../basicScripts/Journey_QuestManager.as"
#include "../../basicScripts/Journey_Companions.as"
#include "../../basicScripts/Journey_SharedQuestItems.as"
#include "../../basicScripts/Journey_Veil.as"
#include "../../basicScripts/Journey_SpecialItems.as"
#include "../../basicScripts/Journey_IntroOutroDialogues.as"
#include "../../basicScripts/Journey_RandomLoot.as"
#include "../../basicScripts/Journey_Music.as"
#include "../../basicScripts/Journey_QuestItems.as"
#include "../../basicScripts/Journey_TrollStoryAbilities.as"
// -----------------------------------------------------------------------------------------------------------------------


class Journey_LevelBase : Journey_AATurret, Journey_EverlightWeather, Journey_MiniBosses, Journey_QuestRewards, Journey_QuestManager, Journey_Companions, Journey_SharedQuestItems, Journey_Veil, Journey_SpecialItems, Journey_IntroOutroDialogues, Journey_RandomLoot, Journey_Music, Journey_QuestItems, Journey_TrollStoryAbilities
{
	// -------------------------------------------------------------------------------------------------------------------
	string m_sVersion_Levelbase = "1.04 - 15.10.2019 - 12:03";

	/*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*								V A R I A B L E S 
	*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*/
	protected LevelReference@ m_Reference = null;
	
	dictionary m_DialogueParticipantSettings; // save state of dialogue participants when calling 'PlayerHeroControlDisable'
	dictionary m_HeroPartySettings; // save state of heroparty members when calling 'PlayerHeroControlDisable'

	array<string> m_RevivingTalismanHeroes = {}; // Store heroes that need to be revived
	uint m_iTimer_ReviveTalisman = 2; //How long does it need to revive a hero automatically
	uint m_iPlayerFaction = 0;

	// Player controlled factions in Journey mode, gets values when joined players are present
	array<uint8> m_arrPlayerControlledFactions;

	// Ids of host and joined players' avatars
	uint m_iHostAvatarId;
	uint m_i1_JoinedAvatarId;
	uint m_i2_JoinedAvatarId;

	string m_sExploration = "Journey_ExplorationNPC";

	string m_sGlobalCollectibleItem = "Journey_AntiqueCoin_Global";

	// --- constructor --- DONT TOUCH!!!!
	Journey_LevelBase (LevelReference@ _Reference)
	{
		@m_Reference = _Reference; 
	}
	

// -------------------------------------------------------------------------------------------------------------------
// ---  S Y S T E M   E V E N T S  -----------------------------------------------------------------------------------

	void OnCreated ()
	{
		print("---------------------------------------------------------------------------------------------------");
		print("--- V E R S I O N : Journey_LevelBase: '"+m_sVersion_Levelbase+"' (Level was just created)");
		print("---  M A P "+ m_Reference.GetMapId() +" was just created");

		DisableRandomLoot();
		InitJourneyQuests();
		RemoveQuestItems();
		DetermineAvatarsIds();
		UnlockTrollStoryAbilities();
		// Hero selection shouldn't be enabled on Everlight as well as MapIntro
		if(GetString_CurrentMapId() != "500")
		{
			HostHeroSelection();
		}
		// Setting up exploration NPC
		if(m_Reference.GetCreatureByName(m_sExploration).Exists())
		{
			OnTimer_SetupExplorationNPC();
		} 
		else
		{
			m_Reference.CastSpell("Journey_Summon_ExplorationNpc", kFactionNeutral, m_Reference.GetCreatureById(m_iHostAvatarId));
			m_Reference.SetTimerMS(TOnTimerEvent(@this.OnTimer_SetupExplorationNPC), 100);		
		}
		RegisterEvents_Gameplay();

		// Setting up global collectibles on a timer because all creatures need to spawn beforehand 
		m_Reference.SetTimerMS(TOnTimerEvent(@this.SetupGlobalCollectiblesDrop), 100);

		// By default travel is not allowed on Journey maps, not the case for 500 map 
		m_Reference.GetWorld().AllowTravel(false);

		UnlockDefaultGlossaryEntries();
	}


 	void OnLoaded ( const uint _uVersion )
	{

	}

	void RegisterEvents_Gameplay()
	{
		// Register events for the revive talsiman, the reskill-, attribute- and abilitypoint-potions
		RegisterSpecialItems();

		// Journey specific events 
		m_Reference.RegisterHeroPartyEvent(HeroRevivePeriodEnded, TOnHeroPartyEvent(@this.OnHostHeroRevivePeriodEnded_LoseGame), "", m_Reference.GetHostFaction());

		for(uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); i++)
		{
			m_Reference.RegisterHeroPartyEvent(QuestRewardClaimed, TOnHeroPartyByDescriptionEvent(@this.OnRewardClaimed_AllowTravel), "", m_Reference.GetPlayerFactions(true)[i]);
			m_Reference.RegisterHeroPartyEvent(CoopPlayerLeft, TOnHeroPartyByDescriptionEvent(@this.OnPlayerLeft_Journey), "", m_Reference.GetPlayerFactions(true)[i]);
			m_Reference.RegisterInventoryEvent(Added, TOnInventoryEvent(@this.OnAdded_CheckSharedQuestItem), "", m_Reference.GetPlayerFactions(true)[i]);
			m_Reference.RegisterInventoryEvent(Removed, TOnInventoryEvent(@this.OnRemoved_CheckSharedQuestItem), "", m_Reference.GetPlayerFactions(true)[i]);
		}
		RegisterMinibossTrophies();

		RegisterVeilItem();
	}

	/*	--------------------------------------------------
	*	Called both in articy quests and level scripts,
	*	saves current equipment, experience and quest
	*	progress of all present hero parties
	*	--------------------------------------------------
	*/
	void CheckpointReached()
	{
		if(m_Reference.GetSharedJournal().IsQuestActive("Journey_Global_CollectPendingRewards") == false)
		{
			m_Reference.AutoSave();	
		}
	}

	/*	--------------------------------------------------
	*	Set in OnCreated in LevelBase, registers events for
	*	enemy factions which with certain probability drop
	*	Journey_AntiqueCoin_Global on creature being killed
	*	--------------------------------------------------
	*/
	bool SetupGlobalCollectiblesDrop()
	{
		array<uint> _arrHostileFactions;
		for (uint i = 0; i < kMaxFactions; ++i)
		{
			if(m_Reference.GetFactionRelation(m_Reference.GetHostFaction(), i) == Hostile && m_Reference.FindCreaturesByFaction(i, true).length() != 0)
			{
				_arrHostileFactions.insertLast(i);
			}
		}
		for (uint i = 0; i < _arrHostileFactions.length(); ++i)
		{
			m_Reference.RegisterCreatureEventByDescription(Damaged, TOnCreatureEvent(@this.OnKilled_DropGlobalCollectible), "", _arrHostileFactions[i], "");
		}

		return true;
	}

	/*	--------------------------------------------------
	*	Determines Ids of current Journey players' avatars
	*	--------------------------------------------------
	*/

	void DetermineAvatarsIds()
	{
		// Storing player controlled factions
		m_arrPlayerControlledFactions = m_Reference.GetPlayerFactions(true);
		// Storing Id of the host avatar
		if(m_Reference.GetHeroParty(m_Reference.GetHostFaction()).GetMembers().length() > 0)
		{
			m_iHostAvatarId = m_Reference.GetHeroParty(m_Reference.GetHostFaction()).GetMembers()[0].GetId();	
		}
		// Storing Ids for joined players' avatars in case they are present
		if (m_arrPlayerControlledFactions.length() > 1)
		{
			uint _iHostFaction = m_Reference.GetHostFaction();
			uint _iHostFactionIndex = m_arrPlayerControlledFactions.find(_iHostFaction);
			m_arrPlayerControlledFactions.removeAt(_iHostFactionIndex);

			if (m_arrPlayerControlledFactions.length() == 1)
			{
				m_i1_JoinedAvatarId = m_Reference.GetHeroParty(m_arrPlayerControlledFactions[0]).GetMembers()[0].GetId();
			}
			else if (m_arrPlayerControlledFactions.length() == 2)
			{
				m_i1_JoinedAvatarId = m_Reference.GetHeroParty(m_arrPlayerControlledFactions[0]).GetMembers()[0].GetId();
				m_i2_JoinedAvatarId = m_Reference.GetHeroParty(m_arrPlayerControlledFactions[1]).GetMembers()[0].GetId();
			}
		}
	}

	
	/*	--------------------------------------------------
	*	Called on Journey rts maps, distributes starting
	*	rts sectors depending on how many and from which
	*	lobby slots players are playing
	*	--------------------------------------------------
	*/
	void InitialSectorsDistribution(dictionary _PlayersInititalSectors)
	{
		array<string> _arrkeys = _PlayersInititalSectors.getKeys();
		for (uint i = 0; i < _arrkeys.length(); ++i)
		{
			uint _uFaction;
			string _sSector = _arrkeys[i];
			_PlayersInititalSectors.get(_sSector, _uFaction);
			if(m_Reference.GetHeroParty(_uFaction).GetMembers().length() != 0)
			{
				Sector@ _Sector = m_Reference.GetSectorByName(_sSector);
				_Sector.SetOwner(_uFaction);
				_Sector.CreateCapital(_uFaction, true, false);
				m_Reference.RegisterBuildingEventByIndividual(Destroyed, TOnBuildingEvent(@this.OnDestroyed_PlayersCapital), _Sector.GetMainBuilding());
			}
		}
	}

	void testSO(string _sTest, uint _uFaction)
	{
		Creature _Avatar = m_Reference.GetHeroParty(_uFaction).GetMembers()[0];
		string _sAvatar = m_Reference.FindEntityName(_Avatar);
		JourneyDialogShoutout(_sAvatar, "GenericAvatar", _sTest, false, false, false, _uFaction);
	}

	bool OnTimer_SetupExplorationNPC()
	{
		m_Reference.GetCreatureByName(m_sExploration).SetCollisionDisabled(true);
		m_Reference.GetCreatureByName(m_sExploration).SetAttackable(false);
		m_Reference.GetCreatureByName(m_sExploration).ApplyCondition(39825, -1, kMaxFactions, 100);
		return true;
	}

	/*	--------------------------------------------------
	*	Journey variant of ExplorationShoutout, uses a random
	*	player controlled faction that has heroes in range
	*	of the shoutout
	*	--------------------------------------------------
	*/
	bool JourneyExplorationShoutout(Entity&in _Target, string _sTopicName, bool _bQueued = false, bool _bStop = false, bool _bIgnoreInDialog = false, bool _bIgnoreDead = false)
	{
		Creature _ExplorationNPC = m_Reference.GetCreatureByName(m_sExploration);
		_ExplorationNPC.Stop(m_Reference);
		_ExplorationNPC.Teleport(m_Reference, _Target);
		
		uint _uSpeakerFaction = GetExplorationShoutoutSpeakerFaction();
		if(_uSpeakerFaction == kFactionNeutral)
		{
			return false;
		}

		if (m_Reference.IsCutScenePlaying() == true)
		{
			return false;
		}

		uint _uTargetId = _Target.GetId();
		if ( _bIgnoreDead == false && _Target.GetEntityType() == Creature && m_Reference.GetCreatureById(_uTargetId).GetCurrentHP() == 0)
		{
			print("EXPLORATION SHOUTOUT >>"+ _sTopicName+"<<: Creature "+m_Reference.GetCreatureById(_uTargetId).GetDescriptionName() + " is dead");
			return false;
		}

		if (_bIgnoreInDialog || HeroPartyInDialogue(_uSpeakerFaction) == false)
		{
			if(_bStop)
			{
				m_Reference.GetHeroParty(_uSpeakerFaction).Stop();
			}
			return JourneyDialogShoutout(m_sExploration, m_sExploration, _sTopicName, false, _bQueued, _bStop, _uSpeakerFaction);
		}

		return false;
	}

	/*	--------------------------------------------------
	*	Called in JourneyExplorationShoutout, returns a
	*	random faction that has an alive hero within
	*	exploration NPC dialogue range
	*	--------------------------------------------------
	*/	
	uint GetExplorationShoutoutSpeakerFaction()
	{
		uint _uSpeakerFaction = kFactionNeutral;
		Creature _ExplorationNPC = m_Reference.GetCreatureByName(m_sExploration);
		array<uint> _arrFactions = {};
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			for (uint j = 0; j < m_Reference.GetHeroParty(_uFaction).GetMembers().length(); ++j)
			{
				Creature _Hero = m_Reference.GetHeroParty(_uFaction).GetMembers()[j];
				if(m_Reference.FindEntityName(_Hero) != "Journey_Priest_Companion" && _Hero.GetCurrentHP() > 0 
					&& m_Reference.GetEntityDistance(_Hero.GetId(), _ExplorationNPC.GetId()) <= 200 && _arrFactions.find(_uFaction) == -1)
				{
					_arrFactions.insertLast(_uFaction);
				}
			}
		}
		if(_arrFactions.length() != 0)
		{
			uint _uRandom = m_Reference.GetRandom().GetInteger(0, _arrFactions.length());
			_uSpeakerFaction = _arrFactions[_uRandom];
			print("Faction to speak in ExplorationShoutout: "+_uSpeakerFaction);
		}
		
		return _uSpeakerFaction;
	}

	/*	--------------------------------------------------
	*	The same as normal DialogShoutout, but starts the
	*	dialogue for all factions
	*	--------------------------------------------------
	*/
	bool JourneyDialogShoutout(string _sCreature, string _sContainerName, string _sTopicName, bool _bPrioritizeCurrentDialogue = false, bool _bQueued = false, bool _bStop = false, uint _uFaction = kMaxFactions, bool _bIgnoreCutscene = false)
	{
		if (_bIgnoreCutscene == false && m_Reference.IsCutScenePlaying() == true)
		{
			return false;
		}

		if (_bPrioritizeCurrentDialogue == true && m_Reference.GetCreatureByName(_sCreature).IsInDialogue() == true)
		{
			print("Tried to do another shoutout while _bPrioritizeCurrentDialogue was true");
			return false;
		}

		if(_bStop)
		{
			m_Reference.GetHeroParty(_uFaction).Stop();
		}

		if(!m_Reference.GetCreatureByName(_sCreature).Shoutout(m_Reference, _sContainerName, _sTopicName, _bQueued, _uFaction))
		{
			warn("Could not start dialogue " + _sTopicName + " in container " +  _sContainerName);
		}

		string activeTopic = "";
		string activeContainer = "";
	 	m_Reference.GetCreatureByName(_sCreature).GetActiveDialogueTopic(m_Reference, activeContainer, activeTopic);
		return m_Reference.GetCreatureByName(_sCreature).IsInDialogue() && activeTopic == _sTopicName && activeContainer == _sContainerName;
	}

	/*	--------------------------------------------------
	*	Returns a faction that is in dialogue with an NPC
	*	which name is passed. Will return kFactionNeutral
	*	if no player controlled factions will be present
	*	in the dialogue
	*	--------------------------------------------------
	*/
	uint GetFactionTalkingToNPC(string _sNPC)
	{
		uint _uFaction = kFactionNeutral;
		array <Creature>@ Participants = m_Reference.GetCreatureByName(_sNPC).GetDialogueParticipants(m_Reference);
		for(uint i = 0; i < Participants.length(); ++i)
		{
			if(m_Reference.FindEntityName(Participants[i]) != _sNPC && Participants[i].GetFaction() != kFactionNeutral)
			{
				_uFaction = Participants[i].GetFaction();
			}
		}
		return _uFaction;
	}

	/*	--------------------------------------------------
	*	A generic function to remove a specified item from
	*	a faction in dialogue with a specified NPC. Called
	*	from articy.
	*	--------------------------------------------------
	*/
	void RemoveItemInDialogue(string _sNPC, string _sItem, uint _uAmount)
	{
		uint _uFaction = GetFactionTalkingToNPC(_sNPC);
		if(_uFaction != kFactionNeutral)
		{
			m_Reference.GetHeroParty(_uFaction).RemoveItems(_sItem, _uAmount, true);
		}
	}

	/*	--------------------------------------------------
	*	Called from dialogues, enables trade for a journey
	*	hero which initiated a dialogue. Trader's name
	*	should be passed as parameter.
	*	--------------------------------------------------
	*/
	void TradeWithJourneyHero(string _sNPC)
	{
		Creature _Trader = m_Reference.GetCreatureByName(_sNPC);
		Creature _Hero = _Trader.GetDialogueInitiator(m_Reference);
		uint _uFaction = _Hero.GetFaction();
		_Hero.Trade(m_Reference, _Trader, false, _uFaction, m_Reference.GetHeroParty(_uFaction).GetControlIndex(_Hero));
	}

	/*	--------------------------------------------------
	*	Sets the 'important' value of the given dialogue.
	*	A creature with an important dialogue 
	*	has a '!' over it's head.
	*	--------------------------------------------------
	*/
	void SetDialogTopicImportant( string _sContainerName, string _sTopicName, bool _bImportant )
	{
		m_Reference.GetWorld().SetDialogueTopicImportant(_sContainerName, _sTopicName, _bImportant);
	}

	/*	--------------------------------------------------
	*	Sets the 'important' value of the given dialogue.
	* 	Depending on the status of the given quest.
	*	--------------------------------------------------
	*/
	void SetDialogTopicImportant_QuestActiveCheck( string _sContainerName, string _sTopicName, string _sQuestName, bool _bWhenQuestActive = false, bool _bImportant = false  )
	{
		if( m_Reference.GetJournal(0).IsQuestActive(_sQuestName) == _bWhenQuestActive )
		{
			m_Reference.GetWorld().SetDialogueTopicImportant(_sContainerName, _sTopicName, _bImportant);
		}
	}

	/*	--------------------------------------------------
	*	Starts the given cutscene.
	*	Stops all dialogues, revives all heroes and removes
	*	all summoned minions.
	*	--------------------------------------------------
	*/
	void PlayCutscene( string _stgCutscene )
	{
		print( "CUTSCENE STARTS: '"+_stgCutscene+"'" );
		HeroParty_Revive();
		HeroPartyStopDialogues();
		HeroParty_KillAllSummons();
		m_Reference.PlayCutScene( _stgCutscene );
	}

	/*	--------------------------------------------------
	*	Used in PlayCutscene function
	*	--------------------------------------------------
	*/
	void HeroPartyStopDialogues(uint _uFaction = 0)
	{
		array <Creature>@ Heroes = m_Reference.GetHeroParty( _uFaction ).GetMembers ();
		for ( uint i = 0; i < Heroes.length(); i++ )
		{
			Heroes[i].CancelDialogue();
		}
	}

	/*	--------------------------------------------------
	*	Removes gold from the heroparty inventory
	*	If a target creature is given the gold is added
	*	to its tradeinventory and loot drop
	*	--------------------------------------------------
	*/
	void HeroParty_RemoveGold( uint _uAmount, string _sTarget = "" )
	{
		printNote( " - Giving '"+_uAmount+"' Gold to the NPC '"+_sTarget+"'" );
		m_Reference.GetHeroParty( m_Reference.GetHostFaction() ).RemoveGold( _uAmount );
		if( _sTarget != "" )
		{
			m_Reference.GetWorld().AddItemToCreatureDrops( _sTarget, "Gold", _uAmount, 100 ); // adding the gold to item drop
			m_Reference.GetCreatureByName(_sTarget).AddTradeItem("Gold", _uAmount);
		}

	}

	/*	--------------------------------------------------
	*	In case if journey hero parties aren't wiped, returns
	*	a random hero that is alive. If all player controlled
	*	heroes are dead, returns a host avatar. Used in
	*	exploration shoutouts for which location is irrelevant.
	*	--------------------------------------------------
	*/
	Creature GetRandomJourneyHero()
	{
		if(JourneyHeroparty_Wiped())
		{
			print("All journey heroes are wiped, host avatar will be returned in GetRandomJourneyHero");
			return m_Reference.GetCreatureById(m_iHostAvatarId);
		}

		Creature[] _AliveHeroes = {};
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			for (uint j = 0; j < m_Reference.GetHeroParty(_uFaction).GetMembers().length(); ++j)
			{
				Creature _Hero = m_Reference.GetHeroParty(_uFaction).GetMembers()[j];
				if(_Hero.GetCurrentHP() > 0)
				{
					_AliveHeroes.insertLast(_Hero);
				}
			}
		}
		uint _uRandom = m_Reference.GetRandom().GetInteger(0, _AliveHeroes.length());
		Creature _RandomJourneyHero = _AliveHeroes[_uRandom];
		print("GetRandomJourneyHero returns "+m_Reference.FindEntityName(_RandomJourneyHero));
		return _RandomJourneyHero;
	}

	/*	--------------------------------------------------
	*	Used in combat music timers on Journey rpg maps
	*	--------------------------------------------------
	*/
	bool JourneyHeropartyOutOfRange(Entity& in _target, uint _uDistance)
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			Creature[] Heroes = m_Reference.GetHeroParty(_uFaction).GetMembers();
			for(uint j = 0; j < Heroes.length(); j++)
			{
				if(Heroes[j].GetCurrentHP() > 0 && m_Reference.GetEntityDistance(Heroes[j].GetId(), _target.GetId()) < _uDistance)
				{
					return false;
				}
			}
		}
		return true;
	}

	/*	--------------------------------------------------
	*	Translates race enum to a string
	*	--------------------------------------------------
	*/
	string TranslateRaceEnum( uint _iNmbr )
	{
		string _stgRace = "";
		switch( _iNmbr )
		{	
			case 0:
				_stgRace = "Human"; break;
			case 1:
				_stgRace = "Elf"; break;
			case 2:
				_stgRace = "Dwarf"; break;
			case 3:
				_stgRace = "Orc"; break;
			case 4:
				_stgRace = "DarkElf"; break;
			case 6:
				_stgRace = "Troll"; break;
		}
		return _stgRace;
	}

	/*	--------------------------------------------------
	*	Used for debug of the passed faction avatar's race
	*	--------------------------------------------------
	*/
	void CheckAvatarRace(uint _uFaction)
	{
		Creature[] _Heroes = m_Reference.GetHeroParty(_uFaction).GetMembers();
		if(_Heroes.length() != 0)
		{
			Creature _Avatar = _Heroes[0];
			uint _uRaceEnum = _Avatar.GetCreatureRace();
			print("Avatar of faction "+_uFaction+" is of this race: "+_uRaceEnum);
		}
	}

	/*	--------------------------------------------------
	*	Reveals an area for all currently player-controlled
	*	factions for certain amount of time
	*	--------------------------------------------------
	*/
	void JourneyRevealArea ( string _stgArea, uint _iSeconds )
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.AddVisiblePath( m_Reference.GetPlayerFactions(true)[i], _stgArea );
		}
		m_Reference.SetTimer( TOnTimerUserDataEvent(@this.JourneyRevealArea_timer), _iSeconds, _stgArea );
	}
	bool JourneyRevealArea_timer ( const string& in _stgKey )
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.RemoveVisiblePath( m_Reference.GetPlayerFactions(true)[i], _stgKey );
		}
		return true;
	}

	/*	--------------------------------------------------
	*	Clears up an item container: needed when a container
	*	was looted on previous map run
	*	--------------------------------------------------
	*/
	void CleanUp_LootContainer(string _sLootContainer)
	{
		LogicObject _LootContainer = m_Reference.GetLogicObjectByName(_sLootContainer);
		dictionary _Item_Amount = {};
		array<string> _arrItems = _LootContainer.GetContainerItems();
		for (uint i = 0; i < _arrItems.length(); ++i)
		{
			uint _uItemAmount = _LootContainer.GetContainerItemAmount(_arrItems[i]);
			_Item_Amount.set(_arrItems[i], _uItemAmount);
		}

		array<string> _dictKeys = _Item_Amount.getKeys();
		for (uint i = 0; i < _dictKeys.length(); ++i)
		{
			uint _uAmountRemoved;
			_Item_Amount.get(_arrItems[i], _uAmountRemoved);
			_LootContainer.RemoveContainerItem(m_Reference, _dictKeys[i], _uAmountRemoved);
			print(_uAmountRemoved+" units of "+_dictKeys[i]+" removed from "+_sLootContainer);
		}

		_LootContainer.SetToggleState(true);
	}

	/*	--------------------------------------------------
	*	Wins a map for all players, used for debug
	*	--------------------------------------------------
	*/
	void DebugWin()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			m_Reference.WinGame(m_Reference.GetPlayerFactions(true)[i]);	
		}
	}

	/*	--------------------------------------------------
	*	Kills all creatures of the passed faction, used for debug
	*	--------------------------------------------------
	*/
	void KillFaction(uint _uFaction)
	{
		CreatureGroup _Creatures = CreatureGroup(m_Reference, GetLivingCreaturesByFaction(_uFaction));
		_Creatures.Die(false);
	}

	// From EXP2_Debug
	void printNote( string _string ) 
	{
		print(" - [NOTE]: " + _string);
	}

	/*	--------------------------------------------------
	*	Add an item with a given amount to the party
	*	inventory
	*	--------------------------------------------------
	*/
	void HeroParty_AddItem( string _sName, uint _uAmount )
	{
		m_Reference.GetHeroParty(0).AddItems(_sName, _uAmount);
	}

	/*	--------------------------------------------------
	*	Remove an item with a given amount to the party
	*	inventory
	*	--------------------------------------------------
	*/
	void HeroParty_RemoveItem( string _sName, uint _uAmount )
	{
		m_Reference.GetHeroParty(0).RemoveItems(_sName, _uAmount);
	}

	/*	--------------------------------------------------
	*	Kill all summoned creatures of the given heroparty
	*	--------------------------------------------------
	*/
	void HeroParty_KillAllSummons(uint _uFaction = 0)
	{
		array <Creature>@ Heroes = m_Reference.GetHeroParty( _uFaction ).GetMembers();
		for( uint i = 0; i < Heroes.length(); i++ )
		{
			array <Creature>@ Summons = Heroes[i].GetSummonedCreatures( m_Reference );
			for( uint j= 0; j < Summons.length(); j++ )
			{
				Summons[j].Kill();
				Summons[j].Enable( false );
			}
		}
	}

	/*	--------------------------------------------------
	*	Checks if any heroparty member is in combat
	*	--------------------------------------------------
	*/
	bool HeroPartyInCombat(uint _uFaction = 0, bool _bShowNotification = false)
	{
		for (uint i = 0; i < m_Reference.GetHeroParty(_uFaction).GetMembers().length(); i++)
		{
			if( m_Reference.GetHeroParty(_uFaction).GetMembers()[i].IsInCombat())
			{
				if (_bShowNotification == true)
				{
					m_Reference.ShowNotification(0, "HeroPartyEndCombat", Entity());
				}
				return true;
			}
		}
		return false;
	}

	/*	--------------------------------------------------
	*	Checks if any heroparty member is dead
	*	--------------------------------------------------
	*/
	bool HeroPartyAlive( uint _uFaction = 0 )
	{
		for (uint i = 0; i < m_Reference.GetHeroParty(_uFaction).GetMembers().length(); i++)
		{
			if(m_Reference.GetHeroParty(_uFaction).GetMembers()[i].GetCurrentHP() <= 0)
			{
				return false;
			}
		}
		return true;
	}

	/*	--------------------------------------------------
	*	Same as original Heroparty_Wiped, but checks alive
	*	heroes for all player cotrolled factions
	*	--------------------------------------------------
	*/
	bool JourneyHeroparty_Wiped()
	{
		for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
		{
			uint _uFaction = m_Reference.GetPlayerFactions(true)[i];
			for (uint j = 0; j < m_Reference.GetHeroParty(_uFaction).GetMembers().length(); j++)
			{
				if(m_Reference.GetHeroParty(_uFaction).GetMembers()[j].GetCurrentHP() > 0)
				{
					return false;
				}
			}
		}
		return true;
	}

	bool HeroParty_InArea(string _sAreaName, uint _uFaction = 0)
	{
		Creature[] CreaturesInArea = m_Reference.FindCreaturesInArea(_sAreaName);
		Creature[] _HeroParty = m_Reference.GetHeroParty(_uFaction).GetMembers();
		uint uHeroesInArea = 0;
		for (uint i = 0; i < CreaturesInArea.length(); i++)
		{
			for (uint j = 0; j < _HeroParty.length(); j++)
			{
				if(CreaturesInArea[i] == _HeroParty[j] )
				{
					uHeroesInArea++;
				}
			}
		}
		return uHeroesInArea == _HeroParty.length();
	}

	/*	--------------------------------------------------
	*	Checks if the heroparty was inactive for a given
	*	amount of time. 
	*	(No movement, dialog, combat)
	*	--------------------------------------------------
	*/
	bool HeroPartyInactive( uint _uTime, uint _uFaction = 0 )
	{
		array <Creature> Heroes = m_Reference.GetHeroParty(_uFaction).GetMembers();
		for ( uint i = 0; i < Heroes.length() ; i++ )
		{
			if(!Heroes[i].HasBeenInactiveFor(_uTime))
				return false;
		}
		return true;
	}

	/*	--------------------------------------------------
	*	Checks if any heroparty member is in dialogue
	*	--------------------------------------------------
	*/
	bool HeroPartyInDialogue(uint _uFaction = 0, bool _bShowNotification = false)
	{
		for (uint i = 0; i < m_Reference.GetHeroParty(_uFaction).GetMembers().length(); i++)
		{
			if(m_Reference.GetHeroParty(_uFaction).GetMembers()[i].IsInDialogue())
			{
				if (_bShowNotification == true)
				{
					m_Reference.ShowNotification(0, "HeroPartyEndDialogue", Entity());
				}
				return true;
			}
		}
		return false;
	}

	/*	--------------------------------------------------
	*	Set the level of the heroparty 
	*	(Use this to test specific maps)
	*	--------------------------------------------------
	*/
	void HeroPartySetLevel(uint _uLevel, uint _uFaction = 0)
	{
		m_Reference.ExecuteConsoleCommand("setherolevel "+ _uLevel +" "+ _uFaction);
	}

// -------------------------------------------------------------------------------------------------------------------
	
	void ResetGlobalResources()
	{
		m_Reference.RemoveGlobalResources(0, Food, m_Reference.GetGlobalResource(0, Food));
		m_Reference.RemoveGlobalResources(0, Brick, m_Reference.GetGlobalResource(0, Brick));
		m_Reference.RemoveGlobalResources(0, Planks, m_Reference.GetGlobalResource(0, Planks));
		m_Reference.RemoveGlobalResources(0, ScrapMetal, m_Reference.GetGlobalResource(0, ScrapMetal));
		m_Reference.RemoveGlobalResources(0, Relic, m_Reference.GetGlobalResource(0, Relic));
	}

	/*	--------------------------------------------------
	*	Transfers all buildings and units
	*	from Faction A to Faction B.
	*	The Heroparty, summons and godstones claimed by
	*	Faction A will no be transfered.
	*	(The are transferred back)
	*	--------------------------------------------------
	*/
	void TransferRTS ( uint _iFaction_A, uint _iFaction_B )
	{
		print( "* Transferring all RTS assets from Faction '"+_iFaction_A+"' to '"+_iFaction_B+"'." );
		// Get stuff that should be transferred back again
		array <Creature>@ Heroparty_A = m_Reference.GetHeroParty( _iFaction_A ).GetMembers();
		array <Building>@ Godstones_A = m_Reference.FindBuildingsByDescription( _iFaction_A, "Exp1_Godstone" );

		// Transfer everything from faction A to faction B
		m_Reference.TransferFactionAssets( _iFaction_A, _iFaction_B );
		
		// Transfer back the godstones
		for(uint i = 0; i < Godstones_A.length(); i++)
		{
			Godstones_A[i].SetFaction( _iFaction_A );
		}
		
		// Transfer back the Hero Party and summons
		for(uint i = 0; i < Heroparty_A.length(); i++)
		{
			Heroparty_A[i].SetFaction( _iFaction_A );
			// Summons from the hero party
			array <Creature>@ Heroparty_summons = Heroparty_A[i].GetSummonedCreatures( m_Reference );
			for(uint j = 0; j < Heroparty_summons.length(); j++)
			{
				Heroparty_summons[j].SetFaction(_iFaction_A);
			}
		}
	}

	/*	--------------------------------------------------
	*	Kill all creatures of a given spawn
	*	--------------------------------------------------
	*/
	bool SpawnKill( const string& in _sName )
	{
		array<Creature>@ Creatures = m_Reference.GetCreaturesFromSpawn(_sName);
		for( uint i = 0; i < Creatures.length(); i++ )
		{
			m_Reference.SetTimerMS(TOnTimerUserDataEvent(@this.OnTimer_KillCreature), m_Reference.GetRandom().GetInteger(0, 750), Creatures[i].GetId()+"");		
		}
		return true;
	}

	/*	--------------------------------------------------
	*	Can be used as a timer to kill a creature
	*	--------------------------------------------------
	*/
	bool OnTimer_KillCreature( const string& in _sId )
	{
		m_Reference.GetCreatureById(parseInt(_sId)).Kill();
		return true;
	}

	/*	--------------------------------------------------
	*	Move command for a given spawn
	*	--------------------------------------------------
	*/
	void SpawnMoveTo( string _sSpawn, string _sPosition, bool _bQueued = false, bool _bSameSpeed = true, bool _bWalk = false )
	{
		CreatureGroup Grp = CreatureGroup(m_Reference, m_Reference.GetCreaturesFromSpawn(_sSpawn));
		Grp.Move(m_Reference.GetLogicObjectByName(_sPosition), _bQueued, _bSameSpeed, _bWalk); 	
	}

	/*	--------------------------------------------------
	*	Set all creatures in a spawn (not) selectable
	*	--------------------------------------------------
	*/
	void SpawnSetSelectable ( string _sSpawn, bool _bEnable )
	{
		array<Creature>@ Creatures = m_Reference.GetCreaturesFromSpawn( _sSpawn );
		for ( uint i = 0; i < Creatures.length(); i++ )
		{
			Creatures[i].SetSelectable(_bEnable);
		}
	}

	/*	--------------------------------------------------
	*	Get all alive creatures of a goven faction
	*	--------------------------------------------------
	*/
	array<Creature> GetLivingCreaturesByFaction(uint8 _uFaction)
	{
		array<Creature> _arrLivingCreatures = {};
		array<Creature> _arrAllCreatures = m_Reference.FindCreaturesByFaction(_uFaction, true);

		for (uint i = 0; i < _arrAllCreatures.length; i++)
		{
			if(_arrAllCreatures[i].GetCurrentHP() > 0)
			{
				_arrLivingCreatures.insertLast(_arrAllCreatures[i]);
			}
		}
		return _arrLivingCreatures;
	}

	/*	--------------------------------------------------
	*	Check if the given creature is inside the given area
	*	--------------------------------------------------
	*/
	bool IsCreatureInsideArea( Creature &in _Creature, string _sTrigger )
	{
		for ( uint i = 0; i <  m_Reference.FindCreaturesInArea(_sTrigger).length(); i++ )
		{
			if( _Creature == m_Reference.FindCreaturesInArea(_sTrigger)[i])
			{
				return true;
			}
		}
		return false;
	}


/* 	-------------------------------------------------------------------------------------------------------------------
*	HEROPARTY
*	-------------------------------------------------------------------------------------------------------------------
*/

	/*	--------------------------------------------------
	*	Adds the given Creature to the faction and
	*	to the hero party of the player.
	*	--------------------------------------------------
	*/	
	void HeroPartyJoin(string _sCreatureName, bool _bShowNotification, uint _uFaction = 0)
	{
		if(_bShowNotification)
		{
			m_Reference.ShowNotification(_uFaction, "HeroJoinedParty", m_Reference.GetCreatureByName(_sCreatureName)); 
		}

		HeroParty@ Heroes = m_Reference.GetHeroParty(_uFaction);
		Creature Hero = m_Reference.GetCreatureByName(_sCreatureName);
		Hero.SetFaction(_uFaction);
		Heroes.AddMember(Hero);
		Heroes.SetHeroOwned(_sCreatureName, true);
		Hero.PreventHeroDespawn(false); // prevent this hero from being despawned when the player enters the level without him in the party

		// check if the hero party is controllable or not 
		// if a new hero is added - also make him not controllable
		Hero.SetPlayerControllable(Heroes.GetMembers()[0].IsPlayerControllable());
	}

	/*	--------------------------------------------------
	*	Teleports the hero party of a specific faction to the given position
	*	--------------------------------------------------
	*/
	void HeroPartyTeleport( string _sPosition, uint _uFaction )
	{
		CreatureGroup Grp = CreatureGroup(m_Reference, m_Reference.GetHeroParty(_uFaction).GetMembers() );
		Grp.Teleport( m_Reference.GetLogicObjectByName(_sPosition), false );
	}


	/*	--------------------------------------------------
	*	Revive all heroparty members
	*	--------------------------------------------------
	*/
	void HeroParty_Revive(uint u_Faction = 0)
	{
		array<Creature>@ Heroes = m_Reference.GetHeroParty(u_Faction).GetMembers();
		for( uint i = 0; i < Heroes.length(); i++ )
		{
			if( Heroes[i].GetCurrentHP() == 0 )
			{
				Heroes[i].Revive();
			}
		}
	}

	/*	--------------------------------------------------
	*	Remove a condition from every member of the heroparty
	*	--------------------------------------------------
	*/
	void HeroPartyRemoveCondition( int _iConditionId, uint _uFaction = 0 )
	{
		array <Creature>@ Heroes = m_Reference.GetHeroParty(_uFaction).GetMembers();
		for (uint i = 0; i < Heroes.length(); i++)
		{
			Heroes[i].RemoveCondition( _iConditionId );
		}
	}



	/*	--------------------------------------------------
	*	Lock/ Unlock all item slots for a hero
	*	--------------------------------------------------
	*/
	void Hero_LockAllEquipmentSlots( string _sHero, bool _bEnable )
	{
		m_Reference.GetCreatureByName(_sHero).LockItemSlot( Head, _bEnable );
		m_Reference.GetCreatureByName(_sHero).LockItemSlot( Torso, _bEnable );
		m_Reference.GetCreatureByName(_sHero).LockItemSlot( PrimaryHand, _bEnable );
		m_Reference.GetCreatureByName(_sHero).LockItemSlot( SecondaryHand, _bEnable );
		m_Reference.GetCreatureByName(_sHero).LockItemSlot( Neck, _bEnable );
		m_Reference.GetCreatureByName(_sHero).LockItemSlot( Ring1, _bEnable );
		m_Reference.GetCreatureByName(_sHero).LockItemSlot( Ring2, _bEnable );
	}



/* 	-------------------------------------------------------------------------------------------------------------------
*	NAVMESH
*	-------------------------------------------------------------------------------------------------------------------
*/

	/*	--------------------------------------------------
	*	Block navmesh for all blockers in a given group
	*	--------------------------------------------------
	*/
	void BlockNavMeshGroup( string _sGrpName, bool _block )
	{
		array<Entity> Blocker = m_Reference.GetEntitiesInGroup(_sGrpName);
		for(uint i = 0; i < Blocker.length(); i++)
		{
			m_Reference.BlockNavMesh(m_Reference.FindEntityName(Blocker[i]), _block);
		}
	}


/* 	-------------------------------------------------------------------------------------------------------------------
*	Inspections
*	-------------------------------------------------------------------------------------------------------------------
*	Setup all inspections per map
*	Key is the object name, value is the inspection-ID.
*/
	dictionary m_Inspections =
	{
		{'399:0', dictionary = {{"testInspection", 100}}}
		//SetupMapInspections
	};

	void SetupMapInspections()
	{
		dictionary Inspections; 
		m_Inspections.get(GetString_CurrentMapIdAndSetting(), Inspections);
		array<string> Keys = Inspections.getKeys();
		
		for(uint i = 0; i < Keys.length(); i++)
		{
			print("Setup inspection " + Keys[i] + " with id " +  uint(Inspections[Keys[i]]) );
			m_Reference.GetLogicObjectByName(Keys[i]).SetInspectionText( uint(Inspections[Keys[i]]) );
		//	m_Reference.GetWorld().SetMapAccessible(GetInt_MapIdFromString(Keys[i]), bool(m_AccessibleMaps[Keys[i]]), GetInt_MapSettingFromString(Keys[i]));
		}
	}

/* 	-------------------------------------------------------------------------------------------------------------------
*	FACTIONS
*	-------------------------------------------------------------------------------------------------------------------
*/
	/*	--------------------------------------------------
	*	Set the faction for all creatures in the given spawn
	*	--------------------------------------------------
	*/
	void SetFaction_Spawn( string _sSpawnName, uint _uFaction )
	{
		for (uint i = 0; i < m_Reference.GetCreaturesFromSpawn(_sSpawnName).length(); i++)
		{
			m_Reference.GetCreaturesFromSpawn(_sSpawnName)[i].SetFaction(_uFaction);
		}
		
	}

	/*	--------------------------------------------------
	*	Set the faction for all creatures in multiple spawns
	*	provided as an array
	*	--------------------------------------------------
	*/
	void SetFaction_MultipleSpawns( array <string> _arrSpawns, uint _uFaction )
	{
		for( uint i = 0; i < _arrSpawns.length() ; i++ )
		{
			SetFaction_Spawn(_arrSpawns[i], _uFaction);
		}
	}

/* 	-------------------------------------------------------------------------------------------------------------------
*	BLUEPRINTS
*	-------------------------------------------------------------------------------------------------------------------
*/

	void UnlockBlueprints ( array <string> _arrBlueprints )
	{
		for ( uint i = 0; i < _arrBlueprints.length();i++)
		{
			if(  _arrBlueprints[i] != '' )
				m_Reference.GetWorld().UnlockBlueprint( _arrBlueprints[i], false );
		}
	}

/* 	-------------------------------------------------------------------------------------------------------------------
*	AUTOSAVE
*	-------------------------------------------------------------------------------------------------------------------
*/

	/*	--------------------------------------------------
	*	AutoSave function that can be used as a timer
	*	--------------------------------------------------
	*/
	bool AutosaveTimed()
	{
		m_Reference.AutoSave();
		return true;
	}

	/*	--------------------------------------------------
	*	AutoSave function that can be used as a looping timer
	*	--------------------------------------------------
	*/
	bool AutosaveTimed_Loop()
	{
		m_Reference.AutoSave();
		return false;
	}

	/*	--------------------------------------------------
	*	Starts a looping timer to autosave every X seconds
	*	--------------------------------------------------
	*/
	void StartAutosaveLoop( uint _uSeconds = 600 )
	{
		m_Reference.SetTimer(TOnTimerEvent(@this.AutosaveTimed_Loop), _uSeconds);
	}

	/*	--------------------------------------------------
	*	Stops the looping AutoSave timer
	*	--------------------------------------------------
	*/
	void StopAutosaveLoop()
	{
		m_Reference.CancelTimer(TOnTimerEvent(@this.AutosaveTimed_Loop));
	}

	/*	--------------------------------------------------
	*	Turns all Godstones of a specific faction neutral -
	*	if they are in sectors not owned by the faction
	*	--------------------------------------------------
	*/
	void DisableAllGodstonesForFaction( const uint8 _uFaction )
	{
		array<Building> Godstones = {};
		for(uint i = 0; i < m_Reference.FindBuildingsByDescription(_uFaction, "Exp1_Godstone").length(); i++)
		{
			Godstones.insertLast(m_Reference.FindBuildingsByDescription(_uFaction, "Exp1_Godstone")[i]);
		}
		
		for(uint i = 0; i < Godstones.length(); i++) 
		{
			if( Godstones[i].GetSectorIndex() == uint16(-1) || m_Reference.GetSectorByIndex( Godstones[i].GetSectorIndex() ).GetOwner() != _uFaction )
			{
				Godstones[i].SetFaction(kFactionNeutral);
			}
		}
	}

// -------------------------------------------------------------------------------------------------------------------

	/*	--------------------------------------------------
	*	Get the map id from a dictionary string 
	*	with the format "mapID:Setting"
	*	e.g. "301:0" returns 301 
	*	--------------------------------------------------
	*/
	int GetInt_MapIdFromString( string _sID )
	{
		string sMapId = "";

		if( _sID.findFirst(":", 0) != -1 )
		{
			sMapId = _sID.substr(0, _sID.findFirst(":", 0));
			return parseInt(sMapId);
		}
		return -1;
	}

	/*	--------------------------------------------------
	*	Get the map-setting from a dictionary string 
	*	with the format "mapID:Setting"
	*	e.g. "301:0" returns 0 
	*	--------------------------------------------------
	*/
	int GetInt_MapSettingFromString( string _sID )
	{
		string sMapSetting = "";

		if( _sID.findFirst(":", 0) != -1 )
		{
			sMapSetting = _sID.substr(_sID.findFirst(":", 0)+1, -1);
			return parseInt(sMapSetting);
		}
		return -1;
	}

	/*	--------------------------------------------------
	*	Transforms the map id fom integer to string
	*	--------------------------------------------------
	*/
	string GetString_CurrentMapId()
	{
		return m_Reference.GetMapId() + "";
	}

	/*	--------------------------------------------------
	*	Transforms the map id fom integer to string
	*	and appends the current map-setting
	*	--------------------------------------------------
	*/
	string GetString_CurrentMapIdAndSetting()
	{
		return m_Reference.GetMapId()+":"+m_Reference.GetWorld().GetCurrentMapSetting(m_Reference.GetMapId());
	}





	/*	--------------------------------------------------
	*	All Heroes become
	*		- not controllable
	*		- immovable
	*		- immortal
	*		- not attackable / can not attack anymore
	*	--------------------------------------------------
	*/
	void PlayerHeroControlDisable()
	{
		printNote( "PlayerHeroControlDisable" );
		if( !m_Reference.GetHeroParty(m_Reference.GetHostFaction()).GetMembers()[0].IsPlayerControllable() )
		{
			printNote( "*********** Call: PlayerHeroControlDisable, Party already locked." );
			return;
		}

		// *** CASE IF DIALOGUE IS CURRENTLY HAPPENING 
		if( m_Reference.GetHeroParty(m_Reference.GetHostFaction()).GetMembers()[0].IsInDialogue() )
		{
			// get all participants of the dialogue
			array <Creature>@ Participants = m_Reference.GetHeroParty(m_Reference.GetHostFaction()).GetMembers()[0].GetDialogueParticipants(m_Reference);
			for(uint i = 0; i < Participants.length(); i++)
			{
				// only handle those that exist, are alive and NOT part of the hero party (heropartymembers are handled later, they might not be registered as participants)
				if( Participants[i].Exists() && Participants[i].GetCurrentHP() > 0 && m_Reference.GetHeroParty(m_Reference.GetHostFaction()).IsMember(Participants[i]) == false )
				{
					dictionary Settings =
					{ 
						{'attackable', Participants[i].CanBeAttacked()}, 
						{'allow_attacks', Participants[i].AreAttacksAllowed()}, 
						{'immortal', Participants[i].IsImmortal()}, 
						{'immovable', Participants[i].IsImmovable()}, 
						{'player_cotrollable', Participants[i].IsPlayerControllable()} 
					};
					m_DialogueParticipantSettings.set( m_Reference.FindEntityName(Participants[i]), Settings );
					Participants[i].SetAttackable( false );
					Participants[i].AllowAttacks( false );
					Participants[i].SetImmortal( true );
					Participants[i].SetImmovable( true );
					Participants[i].SetPlayerControllable( false );
				}
			}
		}

		// Handling the hero party
		array <Creature>@ Heroes = m_Reference.GetHeroParty(m_Reference.GetHostFaction()).GetMembers ();
		for (uint i = 0; i < Heroes.length(); i++)
		{
			// when alive
			if(Heroes[i].GetCurrentHP() != 0)
			{
				dictionary Settings = 
				{
					{'attackable', Heroes[i].CanBeAttacked()}, 
					{'allow_attacks', Heroes[i].AreAttacksAllowed()}, 
					{'immortal', Heroes[i].IsImmortal()}, 
					{'immovable', Heroes[i].IsImmovable()}, 
					{'player_cotrollable', Heroes[i].IsPlayerControllable()} 
				};
				m_HeroPartySettings.set(Heroes[i].GetDescriptionName(), Settings);

				Heroes[i].SetAttackable(false);
				Heroes[i].AllowAttacks(false);
				Heroes[i].SetImmortal(true);
				Heroes[i].SetImmovable(true);
				Heroes[i].SetPlayerControllable(false);
			}
			// when currently dead
			else 
			{
				m_Reference.RegisterCreatureEventByIndividual( Resurrected, TOnCreatureEvent(@this.PlayerHeroControlDisable_revived), Heroes[i].GetDescriptionName(), "" );
			}
		}

		// Register an Event, when the map is left, and the hero party is still locked, that they are set back to normal
		m_Reference.RegisterHeroPartyEvent( LeavingMap, TOnHeroPartyEvent(@this.PlayerHeroControlDisable_LeavingMap), "", m_Reference.GetHostFaction() );
	}

	/*	--------------------------------------------------
	*	When a hero was dead during the disable call,
	*	apply the disabled-controls state on resurecction
	*	--------------------------------------------------
	*/
	bool PlayerHeroControlDisable_revived(Creature& in _Creature)
	{
		printNote( "Hero '"+_Creature.GetDescriptionName()+"' was revived, while the hero party was locked" );

		dictionary Settings = 
		{
			{'attackable', 			_Creature.CanBeAttacked()}, 
			{'allow_attacks', 		_Creature.AreAttacksAllowed()}, 
			{'immortal', 			_Creature.IsImmortal()}, 
			{'immovable', 			_Creature.IsImmovable()}, 
			{'player_cotrollable', 	_Creature.IsPlayerControllable()} 
		};
		m_HeroPartySettings.set( _Creature.GetDescriptionName(), Settings );

		_Creature.SetAttackable( false );
		_Creature.AllowAttacks( false );
		_Creature.SetImmortal( true );
		_Creature.SetImmovable( true );
		_Creature.SetPlayerControllable(false);

		return true;
	}


	/*	--------------------------------------------------
	*	Enable heroparty control when leaving the map
	*	--------------------------------------------------
	*/
	bool PlayerHeroControlDisable_LeavingMap(Creature& in _Creature)
	{
		PlayerHeroControlEnable();
		return true;
	}


	/*	--------------------------------------------------
	*	Enable heroparty controls
	*	Get all creatures who've been locked by the 
	*	disable call and reset their changed values
	*	--------------------------------------------------
	*/
	void PlayerHeroControlEnable()
	{
		printNote( "*********** Call; PlayerHeroControlEnable" );
		
		// get participants, if the player is currently in a dialogue
		if( m_DialogueParticipantSettings.getKeys().length() != 0)
		{
			array <string> Keys = m_DialogueParticipantSettings.getKeys();
			for (uint i = 0; i < Keys.length(); i++)
			{
				// only check if they currently exist and are alive - hero party check isn't needed anymore here
				if( m_Reference.GetCreatureByName( Keys[i] ).Exists() && m_Reference.GetCreatureByName( Keys[i] ).GetCurrentHP() > 0 ) 
				{
					dictionary Settings;
					m_DialogueParticipantSettings.get( Keys[i], Settings );
					
					bool _bAttackable = true;
					bool _bAllow_attacks = true;
					bool _bImmortal = false;
					bool _bImmovable = false;
					bool _bPlayer_cotrollable = false;
					Settings.get( 'attackable', _bAttackable );
					Settings.get( 'allow_attacks', _bAllow_attacks );
					Settings.get( 'immortal', _bImmortal );
					Settings.get( 'immovable', _bImmovable );
					Settings.get( 'player_cotrollable', _bPlayer_cotrollable );
					m_Reference.GetCreatureByName(Keys[i]).SetAttackable(_bAttackable);
					m_Reference.GetCreatureByName(Keys[i]).AllowAttacks(_bAllow_attacks);
					m_Reference.GetCreatureByName(Keys[i]).SetImmortal(_bImmortal);
					m_Reference.GetCreatureByName(Keys[i]).SetImmovable(_bImmovable);
					m_Reference.GetCreatureByName(Keys[i]).SetPlayerControllable(_bPlayer_cotrollable);
				}
				m_DialogueParticipantSettings.delete(Keys[i]);
			}
		}

		// going to unregister these; they should only be called, when the hero party is still locked
		m_Reference.UnregisterCreatureEvent(Resurrected, TOnCreatureEvent(@this.PlayerHeroControlDisable_revived));
		m_Reference.UnregisterHeroPartyEvent(LeavingMap, TOnHeroPartyEvent(@this.PlayerHeroControlDisable_LeavingMap));

		// Handling the hero party
		array <Creature>@ Heroes = m_Reference.GetHeroParty(m_Reference.GetHostFaction()).GetMembers ();
		for(uint i = 0; i < Heroes.length(); i++)
		{
			// when alive; set everything back to before
			if(Heroes[i].GetCurrentHP() > 0)
			{
				dictionary _dictTmp;
				bool _bAttackable = true;
				bool _bAllow_attacks = true;
				bool _bImmortal = false;
				bool _bImmovable = false;
				bool _bPlayer_cotrollable = true;

				if(m_HeroPartySettings.exists(Heroes[i].GetDescriptionName()) == false)
				{
					printNote( "*** WARNING *** "+Heroes[i].GetDescriptionName()+" wasn't properly disabled before - going with the standard configuration" );
				}
				else 
				{
					// get the former configuration
					m_HeroPartySettings.get(Heroes[i].GetDescriptionName(), _dictTmp);
					
					_dictTmp.get('attackable', _bAttackable);
					_dictTmp.get('allow_attacks', _bAllow_attacks);
					_dictTmp.get('immortal', _bImmortal);
					_dictTmp.get('immovable', _bImmovable);
					_dictTmp.get('player_cotrollable', _bPlayer_cotrollable);

					// and now delete it
					m_DialogueParticipantSettings.delete(Heroes[i].GetDescriptionName());
				}
				Heroes[i].SetAttackable(_bAttackable);
				Heroes[i].AllowAttacks(_bAllow_attacks);
				Heroes[i].SetImmortal(_bImmortal);
				Heroes[i].SetImmovable(_bImmovable);
				Heroes[i].SetPlayerControllable(_bPlayer_cotrollable);
			}
			// when party member is dead
			else
			{
				m_Reference.RegisterCreatureEventByIndividual(Resurrected, TOnCreatureEvent(@this.PlayerHeroControlEnable_revived), Heroes[i].GetDescriptionName(), "" );	
			}
		}
	}

	/*	--------------------------------------------------
	*	Enable heroparty controls when resurrected after enable call
	*	--------------------------------------------------
	*/
	bool PlayerHeroControlEnable_revived(Creature& in _Creature)
	{
		dictionary Settings;
		bool _bAttackable = true;
		bool _bAllow_attacks = true;
		bool _bImmortal = false;
		bool _bImmovable = false;
		bool _bPlayer_cotrollable = true;

		if( m_HeroPartySettings.exists( _Creature.GetDescriptionName() ) == false )
		{
			printNote( "*** WARNING *** "+_Creature.GetDescriptionName()+" wasn't disabled before - so we're not going to touch his states" );
			return true;
		}
		else 
		{
			// get the former configuration
			m_HeroPartySettings.get( _Creature.GetDescriptionName(), Settings );
			
			Settings.get( 'attackable', _bAttackable );
			Settings.get( 'allow_attacks', _bAllow_attacks );
			Settings.get( 'immortal', _bImmortal );
			Settings.get( 'immovable', _bImmovable );
			Settings.get( 'player_cotrollable', _bPlayer_cotrollable );

			// and now delete it
			m_DialogueParticipantSettings.delete( _Creature.GetDescriptionName() );
		}
		_Creature.SetAttackable( _bAttackable );
		_Creature.AllowAttacks( _bAllow_attacks );
		_Creature.SetImmortal( _bImmortal );
		_Creature.SetImmovable( _bImmovable );
		_Creature.SetPlayerControllable( _bPlayer_cotrollable );
		
		return true;
	}


	/*	--------------------------------------------------
	*	Only disable the control of the heroparty - does not
	*	set immortal etc. Receives faction uint8 in Journey mode
	*	--------------------------------------------------
	*/
	bool JourneyPlayerHeroControlDisable_Light(uint8 _uFaction)
	{
		array <Creature>@ Heroes = m_Reference.GetHeroParty(_uFaction).GetMembers ();
		for (uint i = 0; i < Heroes.length(); i++)
			Heroes[i].SetPlayerControllable( false );
		return true;
	}

	/*	--------------------------------------------------
	*	Only enable the control of the heroparty.
	*	Receives faction uint8 in Journey mode
	*	--------------------------------------------------
	*/
	bool JourneyPlayerHeroControlEnable_Light(uint8 _uFaction)
	{
		array <Creature>@ Heroes = m_Reference.GetHeroParty(_uFaction).GetMembers ();
		for (uint i = 0; i < Heroes.length(); i++)
			Heroes[i].SetPlayerControllable( true );
		return true;
	}

	/*	--------------------------------------------------
	*	Get the closest hero party member to given entity
	*	--------------------------------------------------
	*/

	Creature GetClosestHero(Entity _Entity)
	{
		uint _uEntityId = _Entity.GetId();
		int _uShortestDistance = 0;
		int _uCurrentHeroDistance = 0;
		Creature _ClosestHero;
		array<Creature> _arrHeroes = m_Reference.GetHeroParty(0).GetMembers();
		for (uint i = 0; i < _arrHeroes.length(); i++)
		{
			_uCurrentHeroDistance = m_Reference.GetEntityDistance(_uEntityId, _arrHeroes[i].GetId());
			if (_arrHeroes[i].GetCurrentHP() > 0 && (i == 0 || _uCurrentHeroDistance < _uShortestDistance))
			{
				_uShortestDistance = _uCurrentHeroDistance;
				_ClosestHero = _arrHeroes[i];
			}
		}
		
		string _sEntityName = m_Reference.FindEntityName(_Entity);
		if (_sEntityName != "")
		{
			print(_ClosestHero.GetDescriptionName()+" is closest to entity with the name "+m_Reference.FindEntityName(_Entity));
		}
		else
		{
			print(_ClosestHero.GetDescriptionName()+" is closest to entity with ID "+_Entity.GetId());
		}
		
		return _ClosestHero;
	}

	/*	--------------------------------------------------
	*	Get hero party member short name
	*	--------------------------------------------------
	*/

	string GetHeroShortName(string _sCreature)
	{
		string _sShortName = _sCreature.substr(_sCreature.findLast("_", -1)+1, -1);
		if (_sShortName != "")
		{
			return _sShortName;
		}
		return "huh?";
	}

	/**
	*-----------------------------------------------------------------------
	* TRADER GETTERS
	*-----------------------------------------------------------------------
	*/

	/*	--------------------------------------------------
	*	Get all creatures flagged as traders in the level
	*	--------------------------------------------------
	*/
	array <Creature> GetTraders()
	{
		array <Creature> Traders;
		// iterate through all factions
		for ( uint i = 0; i < kMaxFactions ; i++ )
		{
			array<Creature> Creatures = m_Reference.FindCreaturesByFaction( i, false );
			for ( uint j = 0; j < Creatures.length() ; j++ )
			{
				if(Creatures[j].IsTrader())
				{
					Traders.insertLast(Creatures[j] );
				}
			}
		}
		return Traders;
	}

	void Trade(string _sTrader, string _sHero = m_sAvatar )
	{
		m_Reference.GetCreatureByName(_sHero).Trade(m_Reference, m_Reference.GetCreatureByName(_sTrader), false, kMaxFactions, uint8(-1));
	}

	void Craft(string _sCrafter, string _sHero = m_sAvatar )
	{
		m_Reference.GetCreatureByName(_sHero).Craft(m_Reference, m_Reference.GetCreatureByName(_sCrafter), false, kMaxFactions, uint8(-1));
	}


	/*	--------------------------------------------------
	*	Get all creaturenames of creatures flagged as 
	*	traders in the level
	*	--------------------------------------------------
	*/
	array <string> GetTraderDescriptions()
	{
		array <string> Traders;
		
		// iterate through all factions
		for ( uint i = 0; i < kMaxFactions ; i++ )
		{
			array <Creature> Creatures = m_Reference.FindCreaturesByFaction( i, false );
			for ( uint j = 0; j < Creatures.length(); j++ )
			{
				if ( Creatures[j].IsTrader() && Traders.find(Creatures[j].GetDescriptionName()) == -1 )
				{
					Traders.insertLast( Creatures[j].GetDescriptionName() );
				}
			}
		}
		return Traders;
	}


	/*	--------------------------------------------------
	*	Returns the damagetype enum connected to the string
	*	--------------------------------------------------
	*/
	EDamageType DamageType_StringToEnum( string _sType )
	{
		EDamageType Type = Irresistible;

		if( _sType == 'Pierce' )
		{
			Type = Pierce;
		}
		else if( _sType == 'Slash' )
		{
			Type = Slash;
		}
		else if( _sType == 'Blunt' )
		{
			Type = Blunt;
		}
		else if( _sType == 'Thrust' )
		{
			Type = Thrust;
		}
		else if( _sType == 'Crush' )
		{
			Type = Crush;
		}
		else if( _sType == 'Siege' )
		{
			Type = Siege;
		}
		else if( _sType == 'Fire' )
		{
			Type = Fire;
		}
		else if( _sType == 'Ice' )
		{
			Type = Ice;
		}
		else if( _sType == 'Air' )
		{
			Type = Air;
		}
		else if( _sType == 'White' )
		{
			Type = White;
		}
		else if( _sType == 'Black' )
		{
			Type = Black;
		}
		else if( _sType == 'Arcane' )
		{
			Type = Arcane;
		}
		else 
			Type = Irresistible;
		
		return Type;
	}

	/*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*								P O I    B E H A V I O R
	*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*/

	void EnablePOIVisitingBehavior_Spawn(string _sSpawn, bool _bEnable)
	{
		array<Creature> _arrCreatures = m_Reference.GetCreaturesFromSpawn(_sSpawn);
		for (uint i = 0; i < _arrCreatures.length(); i++)
		{
			_arrCreatures[i].EnablePOIVisitingBehavior(_bEnable);
		}
	}

	void SetPOICategories_Spawn(string _sSpawn, string[] _sCategoryNames)
	{
		array<Creature> _arrCreatures = m_Reference.GetCreaturesFromSpawn(_sSpawn);
		for (uint i = 0; i < _arrCreatures.length(); i++)
		{
			_arrCreatures[i].SetPOICategories(m_Reference, _sCategoryNames);
		}
	}

	/*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*								E X P L O R A T I O N  N P C  S E T U P
	*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*/

	void DisableAllExplorationNPCs()
	{
		array<Creature> _arrExplorationNPCs= m_Reference.FindCreaturesByDescription(kFactionNeutral, "EXP2_ExplorationNPC");
		for (uint i = 0; i < _arrExplorationNPCs.length(); i++)
		{
			_arrExplorationNPCs[i].Enable(false);
		}
	}

	/*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*								S P A W N   F U N C T I O N S  
	*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*/
	void EnableCreatures_Spawn(string _sSpawnName, bool _bEnable)
	{
		array<Creature> Creatures = m_Reference.GetCreaturesFromSpawn(_sSpawnName);
		for(uint i = 0; i < Creatures.length; i++)
		{
			Creatures[i].Enable(_bEnable);
		}
	}

	/*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*								G E N E R A L   E V E N T   F U N C T I O N S 
	*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*/

	bool OnTimer_DisableCreature(const string& in _sName)
	{
		m_Reference.GetCreatureByName(_sName).Enable(false);
		return true;
	}

	/*	--------------------------------------------------
	*	Attribute potion 
	*	Grants one attribute point to the hero using the potion
	*	--------------------------------------------------
	*/
	bool OnConsumed_AttributePotion(const string&in _sCreatureName, const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		m_Reference.GetHeroParty(_uPlayerFaction).AddAttributePoints(_sCreatureName, 1);
		return false;
	}

	/*	--------------------------------------------------
	*	Ability potion 
	*	Grants one ability point to the hero using the potion
	*	--------------------------------------------------
	*/
	bool OnConsumed_AbilityPotion(const string&in _sCreatureName, const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		m_Reference.GetHeroParty(_uPlayerFaction).AddAbilityPoints(_sCreatureName, 1);
		return false;
	}

	/*	--------------------------------------------------
	*	Ability potion 
	*	Grants one ability point to the hero using the potion
	*	--------------------------------------------------
	*/
	bool OnConsumed_ReskillPotion(const string&in _sCreatureName, const uint8 _uPlayerFaction, const string&in _sItemName, const uint _uAmount)
	{
		m_Reference.GetHeroParty(_uPlayerFaction).ResetHeroAbilities(_sCreatureName);
		m_Reference.GetHeroParty(_uPlayerFaction).ResetHeroAttributes(_sCreatureName);
		return false;
	}


	/*	--------------------------------------------------
	*	Revive Talisman
	*	--------------------------------------------------
	*/

	/*
	* This function triggers when a Heroparty member dies
	* It checks if the fallen hero has the 'ReviveTalisman' equipped in the item slot
	* If this is the case - a timer is set, that revives the Hero after a few seconds automatically and removes one entity of the 'ReviveTalsiman' from the Item slot of the character
	* (This function needs to be registered whenever someone joins the heroparty)
	*/
	bool HeropartyMember_ReviveTalisman(Creature& in _Creature)
	{
		if (_Creature.Exists() == false)
			return false;
	
		bool bItemSlotLocked;
		string sItemSlot = "";
		_Creature.GetEquipment(Item, sItemSlot);
		if ( sItemSlot == "ReviveTalisman" ||  sItemSlot == "MP_ReviveTalisman" )
		{
			printNote(_Creature.GetDescriptionName() +  " will be revived");
			m_RevivingTalismanHeroes.insertLast(_Creature.GetDescriptionName());
			if( _Creature.IsItemSlotLocked(Item) )
			{
				_Creature.LockItemSlot(Item, false);
				bItemSlotLocked = true;
			}
			_Creature.Unequip(m_Reference, Item, Remove, uint16 (1));
			m_Reference.SetTimer(TOnTimerEvent(@this.Timer_ReviveWithTalisman), m_iTimer_ReviveTalisman);
			_Creature.GetEquipment(Item, sItemSlot);
			if( bItemSlotLocked && (sItemSlot == "ReviveTalisman" ||  sItemSlot == "MP_ReviveTalisman") )
				_Creature.LockItemSlot(Item, true);
			
			return false;
		}
		return false;
	}

	/*
	* This timer is set @HeropartyMember_ReviveTalisman
	* It revives a Heroparty member automatically after a few seconds
	*/
	bool Timer_ReviveWithTalisman()
	{
		printNote("Reviving " + m_Reference.GetCreatureByName(m_RevivingTalismanHeroes[0]).GetDescriptionName() );
		m_Reference.GetCreatureByName(m_RevivingTalismanHeroes[0]).Revive();
		m_RevivingTalismanHeroes.removeAt(0);
		return true;
	}

	/*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*								J O U R N E Y   E V E N T   F U N C T I O N S 
	*	----------------------------------------------------------------------------------------------------
	*	----------------------------------------------------------------------------------------------------
	*/

	/*	--------------------------------------------------------
	*	Triggered when any Journey player disconnects. If it was
	*	a joined player, pending quest rewards are updated; if it
	*	was a host all players lose, forcing them to leave the level  
	*	--------------------------------------------------------
	*/

	bool OnPlayerLeft_Journey(const uint8 _uFaction, string&in _sDescriptionName)
	{
		if(_uFaction == m_Reference.GetHostFaction() && m_Reference.GetWorld().IsTravelAllowed() == false)
		{
			// losing the game for all players when the host left, allows us not to worry about this case for further gameplay
			for(uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); i++)
			{
				m_Reference.LoseGame(m_Reference.GetPlayerFactions(true)[i]);
			}
		}
		else
		{
			if(!m_dictPendingQuestRewards.isEmpty())
			{
				array<string> _arrKeys = m_dictPendingQuestRewards.getKeys();
				for (uint i = 0; i < _arrKeys.length(); ++i)
				{
					UpdatePendingQuestReward(_arrKeys[i]);
				}
			}
		}
		return false;
	}

	bool OnKilled_DropGlobalCollectible(Creature &in _Creature)
	{
		if(_Creature.GetCurrentHP() > 0 || _Creature.GetCreatureType() == Worker 
			|| m_arrMinibossSummonsIds.find(_Creature.GetId()) != -1)
		{
			return false;
		}

		uint _uDropChance = m_Reference.GetRandom().GetInteger(0, 99);
		uint _uDropThreshold = 1;
		if(_uDropChance <= _uDropThreshold)
		{
			_Creature.DropItem(m_Reference, m_sGlobalCollectibleItem, 1);
		}
		return false;
	}

	bool OnDestroyed_PlayersCapital(Building& in _Building)
	{
		uint _uFaction = _Building.GetFaction();
		if(_uFaction == m_Reference.GetHostFaction())
		{
			for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			{
				m_Reference.LoseGame(m_Reference.GetPlayerFactions(true)[i]);		
			}
		}
		else
		{
			m_Reference.LoseGame(_uFaction);
		}
		return true;
	}

	bool OnHostHeroRevivePeriodEnded_LoseGame(Creature &in _Creature)
	{
		uint _uFaction = _Creature.GetFaction();
		uint _uCharges = m_Reference.GetHeroParty(_uFaction).GetCurrentRevivalCharges();
		if(_uCharges == 0)
		{
			for (uint i = 0; i < m_Reference.GetPlayerFactions(true).length(); ++i)
			{
				m_Reference.LoseGame(m_Reference.GetPlayerFactions(true)[i]);
			}
		}
		return false;
	}

	// -------------------------------------------------------------------------------------------------------------------
	// ---- G L O S S A R Y   E N T R I E S ------------------------------------------------------------------------------

	void UnlockDefaultGlossaryEntries()
	{
		m_Reference.GetWorld().UnlockAllGlossaryTargetParagraphs("Exp1_Status Effects");
		m_Reference.GetWorld().UnlockAllGlossaryTargetParagraphs("Exp1_Resistance System");
		m_Reference.GetWorld().UnlockAllGlossaryTargetParagraphs("Exp1_Flags");
		m_Reference.GetWorld().UnlockAllGlossaryTargetParagraphs("Exp1_Abilities");
		m_Reference.GetWorld().UnlockAllGlossaryTargetParagraphs("Exp1_Terminology");
	}

}