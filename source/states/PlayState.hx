package states;

import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Song;
import backend.Section;
import backend.Rating;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import haxe.Json;

import cutscenes.CutsceneHandler;
import cutscenes.DialogueBoxPsych;

import states.StoryMenuState;
import states.FreeplayState;
import states.editors.ChartingState;
import states.editors.CharacterEditorState;

import substates.PauseSubState;
import substates.GameOverSubstate;

#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end

import objects.Note.EventNote;
import objects.*;
import states.stages.objects.*;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if SScript
import tea.SScript;
#end

//import shaders.Shaders;
import shaders.ColorSwap;
import backend.SonicTransitionState;

//isFixedAspectRatio shit
import lime.app.Application;
import flixel.FlxG;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.scaleModes.StageSizeScaleMode;
import flixel.FlxState;

//fatality window shit}
import openfl.Lib;
import objects.FatalPopup;

//chaos intro shit
import states.stages.Fleetway;

//Shaders shit
import shaders.VCRDistortionShader;

/**
 * This is where all the Gameplay stuff happens and is managed
 *
 * here's some useful tips if you are making a mod in source:
 *
 * If you want to add your stage to the game, copy states/stages/Template.hx,
 * and put your stage code there, then, on PlayState, search for
 * "switch (curStage)", and add your stage to that list.
 *
 * If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
 *
 * "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
 * "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
 * "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
 * "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for
**/
class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	public var isCameraOnForcedPos:Bool = false;

	public var boyfriend2Map:Map<String, Character> = new Map<String, Character>();
	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dad2Map:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	public var instancesExclude:Array<String> = [];
	#end

	#if LUA_ALLOWED
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var BF2_X:Float = 870;
	public var BF2_Y:Float = 200;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var DAD2_X:Float = 0;
	public var DAD2_Y:Float = 0;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var boyfriend2Group:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var dad2Group:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var stageUI:String = "normal";
	public static var isPixelStage(get, never):Bool;

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel" || stageUI.endsWith("-pixel");

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public var dad2:Character = null;
	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend2:Character = null;
	public var boyfriend:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	public var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health(default, set):Float = 1;
	public var combo:Int = 0;

	public var healthBar:Bar;
	public var timeBar:Bar;
	var songPercent:Float = 0;

	public var ratingsData:Array<Rating> = Rating.loadDefault();

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;

	public var guitarHeroSustains:Bool = false;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var iconP3:HealthIcon;
	public var iconP4:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = true;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var boyfriend2CameraOffset:Array<Float> = null;
	public var opponent2CameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if DISCORD_ALLOWED
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Int> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	#if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
	#end
	public var introSoundsSuffix:String = '';

	// Less laggy controls
	private var keysArray:Array<String>;
	public var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	//Fixed aspect ratio stuff
	public static var isFixedAspectRatio:Bool = false;

	//Phantom Notes shit
	var healthDrop:Float = 0;
	var dropTime:Float = 0;

	//Pause grayscale shit
	var curShader:ShaderFilter;

	//Events shit
	private var topBar:FlxSprite; //Cinematics
    private var botBar:FlxSprite; //Cinematics
	var canDodge:Bool = false; //Fleetway shit

	//SONIC HUD SHITSS!!!!
	public var minNumber:SonicNumber;
	public var sonicHUD:FlxSpriteGroup;
	public var scoreNumbers:Array<SonicNumber>=[];
	public var missNumbers:Array<SonicNumber>=[];
	public var secondNumberA:SonicNumber;
	public var secondNumberB:SonicNumber;
	public var millisecondNumberA:SonicNumber;
	public var millisecondNumberB:SonicNumber;

	public var sonicHUDSongs:Array<String> = [
		"my-horizon",
		"our-horizon",
		"prey",
		"you-cant-run", // for the pixel part in specific
		"fatality",
		"b4cksl4sh",
		"substantial",
		"digitalized"
	];

	var hudStyle:String = 'sonic2';
	public var sonicHUDStyles:Map<String, String> = [

		"fatality" => "sonic3",
		"prey" => "soniccd",
		"you-cant-run" => "sonic1", // because its green hill zone so it should be sonic1
		"our-horizon" => "chaotix",
		"my-horizon" => "chaotix",
		"substantial" => "sJam", //sJam stands for SonicJam
		"digitalized" => "sJam",
		// "songName" => "styleName",

		// styles are sonic2 and sonic3
		// defaults to sonic2 if its in sonicHUDSongs but not in here
	];

	//fatality mechanic shit + moving funne window for fatal error
	var windowX:Float = Lib.application.window.x;
	var windowY:Float = Lib.application.window.y;
	var Xamount:Float = 0;
	var Yamount:Float = 0;
	var IsWindowMoving:Bool = false;
	var IsWindowMoving2:Bool = false;

	//xterion intro stuff
	var sjamMusic:FlxSound;
	var isinxterionintro:Bool = false;
	var xtBlackbg:FlxSprite;
	var xtMissionGrp:FlxTypedGroup<FlxSprite>;
	var xtMission:FlxSprite;
	var xtText:FlxText;
	var xtStartButton:FlxSprite;

	//Sunky timebar shi
	public var sunkerTimebarFuckery:Bool = false;
	public var sunkerTimebarNumber:Int;	

	//Flying shit
	var flyTarg:Character;
	var flyState:String = '';
	var floatyX:Float = 0;
	var floatyY:Float = 0;
	var floatyTime:Float = 0;

	override public function create()
	{
		FlxG.autoPause = false;
		isFixedAspectRatio = false;

		SonicTransitionState.skipNextTransIn = true;
		
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		switch (SONG.song.toLowerCase())
		{
			case 'fatality':
				startCallback = startCountdown;
			case 'chaos':
				startCallback = chaosIntro;
			case 'milk':
				startCallback = sunkIntro;
				sunkerTimebarFuckery = true;
			case 'substantial' | 'digitalized':
				startCallback = xterionIntro;
			case 'round-a-bout':
				startCallback = needleIntro;
			default:
				startCallback = startSongTrans;
		}
		
		endCallback = endSong;

		// for lua
		instance = this;

		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed');

		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain');
		healthLoss = ClientPrefs.getGameplaySetting('healthloss');
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill');
		practiceMode = ClientPrefs.getGameplaySetting('practice');
		cpuControlled = ClientPrefs.getGameplaySetting('botplay');
		guitarHeroSustains = ClientPrefs.data.guitarHeroSustains;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;


		#if DISCORD_ALLOWED
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		storyDifficultyText = Difficulty.getString();

		if (isStoryMode)
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end


		songName = Paths.formatToSongPath(SONG.song);
		if(SONG.stage == null || SONG.stage.length < 1) {
			SONG.stage = StageData.vanillaSongStage(songName);
		}
		curStage = SONG.stage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = StageData.dummy();
		}

		defaultCamZoom = stageData.defaultZoom;

		stageUI = "normal";
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			stageUI = stageData.stageUI;
		else {
			if (stageData.isPixelStage)
				stageUI = "pixel";
		}

		if (SONG.isBf2)
			{
				BF2_X = stageData.boyfriend2[0];
				BF2_Y = stageData.boyfriend2[1];
			}

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];

		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		
		if (SONG.isDad2)
			{		
				DAD2_X = stageData.opponent2[0];
				DAD2_Y = stageData.opponent2[1];
			}

		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		if (SONG.isBf2)
			{
				boyfriend2CameraOffset = stageData.camera_boyfriend2;
				if(boyfriend2CameraOffset == null)
					boyfriend2CameraOffset = [0, 0];
			}


		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		if (SONG.isDad2)
			{		
				opponent2CameraOffset = stageData.camera_opponent2;
				if(opponent2CameraOffset == null)
					opponent2CameraOffset = [0, 0];
			}

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		boyfriend2Group = new FlxSpriteGroup(BF2_X, BF2_Y);

		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		dad2Group = new FlxSpriteGroup(DAD2_X, DAD2_Y);

		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		// use this for 4:3 aspect ratio shit lmao
		switch (SONG.song.toLowerCase())
		{
			case 'fatality' | "milk":
				isFixedAspectRatio = true;
			default:
				isFixedAspectRatio = false;
		}
		
        if (isFixedAspectRatio) {
            FlxG.fullscreen = false; // Disable fullscreen mode if fixed aspect ratio

            // Center camera fix
            camOther.x -= 50;

            Application.current.window.resizable = false; // Keep window non-resizable
            FlxG.scaleMode = new StageSizeScaleMode(); // Change to StageSizeScaleMode for fixed size
            FlxG.resizeGame(960, 720); // Set game resolution
            Application.current.window.width = 960; // Resize window width
            Application.current.window.height = 720; // Resize window height
        }

		switch (curStage)
		{
			case 'tooSlow': new states.stages.TooSlow();
			case 'ycr': new states.stages.YCR();
			case 'majinForestBlue': new states.stages.MajinForestBlue();
			case 'fleetway': new states.stages.Fleetway();
			case 'needlemouse': new states.stages.Fleetway();
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);	

		if (SONG.isDad2)
			{		
				trace("added dad 2");
				add(dad2Group);
			}
		add(dadGroup);

		if (SONG.isBf2)
			{		
				trace("added bf 2");
				add(boyfriend2Group);			
			}
		add(boyfriendGroup);

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		luaDebugGroup = new FlxTypedGroup<psychlua.DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		// STAGE SCRIPTS
		#if LUA_ALLOWED
		startLuasNamed('stages/' + curStage + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		startHScriptsNamed('stages/' + curStage + '.hx');
		#end

		if (songName == 'fatality') {
			// For "fatality", skip the countdown and load the mouse
			FlxG.mouse.visible = true;
			FlxG.mouse.unload();
			FlxG.log.add("Sexy mouse cursor " + Paths.image("fatal_mouse_cursor"));
			FlxG.mouse.load(Paths.image("fatal_mouse_cursor").bitmap, 1.5, 0);

			skipCountdown = false;			
			} 

		if (!stageData.hide_girlfriend)
		{
			if(SONG.gfVersion == null || SONG.gfVersion.length < 1) SONG.gfVersion = 'gf'; //Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterScripts(gf.curCharacter);
		}

		if (SONG.isDad2)
			{
				dad2 = new Character(0, 0, SONG.player5);
				startCharacterPos(dad2, true);
				dad2Group.add(dad2);
				startCharacterScripts(dad2.curCharacter);
			}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterScripts(dad.curCharacter);

		if (SONG.isBf2)
			{
				boyfriend2 = new Character(0, 0, SONG.player4, true);
				startCharacterPos(boyfriend2);
				boyfriend2Group.add(boyfriend2);
				startCharacterScripts(boyfriend2.curCharacter);
			}

		boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterScripts(boyfriend.curCharacter);
		GameOverSubstate.resetVariables();

		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}
		stagesFunc(function(stage:BaseStage) stage.createPost());

		comboGroup = new FlxSpriteGroup();
		add(comboGroup);
		noteGroup = new FlxTypedGroup<FlxBasic>();
		add(noteGroup);
		uiGroup = new FlxSpriteGroup();
		add(uiGroup);

		Conductor.songPosition = -5000 / Conductor.songPosition;
		var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19 + 32, 400, songName, 32);
		timeTxt.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 23, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 3.5;
		timeTxt.visible = updateTime = showTime;
		if(ClientPrefs.data.downScroll) timeTxt.y = FlxG.height - 44;
		if(ClientPrefs.data.timeBarType == 'Song Name') timeTxt.text = SONG.song;

		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 4) - 50, 'timeBar', function() return songPercent, 0, 1);

		if(!sunkerTimebarFuckery)
			timeBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));

		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		uiGroup.add(timeBar);
		uiGroup.add(timeTxt);

		if(ClientPrefs.data.downScroll)
		{
			timeBar.y += 50;
			timeTxt.y += 20;
		}
		strumLineNotes = new FlxTypedGroup<StrumNote>();
		noteGroup.add(strumLineNotes);

		if(ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 15;
			timeTxt.y += -30;
		}

		var splash:NoteSplash = new NoteSplash(100, 100);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.000001; //cant make it invisible or it won't allow precaching

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);

		noteGroup.add(grpNoteSplashes);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camPos.put();

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.snapToTarget();

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		moveCameraSection();

		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBars/default', function() return health, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		uiGroup.add(healthBar);

		scoreTxt = new FlxText(0, healthBar.y + 42, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("NiseSegaSonic.TTF"), 17, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.data.hideHud;
		updateScore(false);
		uiGroup.add(scoreTxt);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.data.hideHud;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP2);

		if(SONG.isDad2)
			{		
				iconP4 = new HealthIcon(dad2.healthIcon, false);
				iconP4.y = healthBar.y - 95;
				iconP4.visible = !ClientPrefs.data.hideHud;
				iconP4.alpha = ClientPrefs.data.healthBarAlpha;
				uiGroup.add(iconP4);
			}

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.data.hideHud;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP1);

		if(SONG.isBf2)
			{		
				iconP3 = new HealthIcon(boyfriend2.healthIcon, true);
				iconP3.y = healthBar.y - 95;
				iconP3.visible = !ClientPrefs.data.hideHud;
				iconP3.alpha = ClientPrefs.data.healthBarAlpha;
				uiGroup.add(iconP3);
			}

		botplayTxt = new FlxText(400, timeBar.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		uiGroup.add(botplayTxt);
		if(ClientPrefs.data.downScroll)
			botplayTxt.y = timeBar.y - 78;

		sonicHUD = new FlxSpriteGroup();

		if(sonicHUDStyles.exists(SONG.song.toLowerCase()))hudStyle = sonicHUDStyles.get(SONG.song.toLowerCase());
		var hudFolder = hudStyle;
		if(hudStyle == 'soniccd')hudFolder = 'sonic1';
		var scoreLabel:FlxSprite = new FlxSprite(15, 25).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/score"));
		scoreLabel.setGraphicSize(Std.int(scoreLabel.width * 3));
		scoreLabel.updateHitbox();
		scoreLabel.x = 15;
		scoreLabel.antialiasing = false;
		scoreLabel.scrollFactor.set();
		sonicHUD.add(scoreLabel);

		var timeLabel:FlxSprite = new FlxSprite(15, 70).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/time"));
		timeLabel.setGraphicSize(Std.int(timeLabel.width * 3));
		timeLabel.updateHitbox();
		timeLabel.x = 15;
		timeLabel.antialiasing = false;
		timeLabel.scrollFactor.set();
		sonicHUD.add(timeLabel);

		var missLabel:FlxSprite = new FlxSprite(15, 115).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/misses"));
		missLabel.setGraphicSize(Std.int(missLabel.width * 3));
		missLabel.updateHitbox();
		missLabel.x = 15;
		missLabel.antialiasing = false;
		missLabel.scrollFactor.set();
		sonicHUD.add(missLabel);	

		// score numbers
		if(hudFolder=='sonic3'){
			for(i in 0...7){
				var number = new SonicNumber(0, 0, 0);
				number.folder = hudFolder;
				number.setGraphicSize(Std.int(number.width*3));
				number.updateHitbox();
				number.x = scoreLabel.x + scoreLabel.width + ((9 * i) * 3);
				number.y = scoreLabel.y;
				scoreNumbers.push(number);
				sonicHUD.add(number);
			}
		}else{
			for(i in 0...7){
				var number = new SonicNumber(0, 0, 0);
				number.folder = hudFolder;
				number.setGraphicSize(Std.int(number.width*3));
				number.updateHitbox();
				number.x = scoreLabel.x + scoreLabel.width + ((9 * i) * 3);
				number.y = scoreLabel.y;
				scoreNumbers.push(number);
				sonicHUD.add(number);
			}
		}	

		// miss numbers
		for(i in 0...4){
			var number = new SonicNumber(0, 0, 0);
			number.folder = hudFolder;
			number.setGraphicSize(Std.int(number.width*3));
			number.updateHitbox();
			number.x = missLabel.x + missLabel.width + (6*3) + ((9 * i) * 3);
			number.y = missLabel.y;
			missNumbers.push(number);
			sonicHUD.add(number);
		}

		// time numbers
		minNumber = new SonicNumber(0, 0, 0);
		minNumber.folder = hudFolder; 	
		minNumber.setGraphicSize(Std.int(minNumber.width*3));
		minNumber.updateHitbox();
		minNumber.x = timeLabel.x + timeLabel.width;
		minNumber.y = timeLabel.y;
		sonicHUD.add(minNumber);

		var timeColon:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("sonicUI/" + hudFolder + "/colon"));
		timeColon.setGraphicSize(Std.int(timeColon.width * 3));
		timeColon.updateHitbox();
		timeColon.x = 170;
		timeColon.y = timeLabel.y;
		timeColon.antialiasing = false;
		timeColon.scrollFactor.set();
		sonicHUD.add(timeColon);

		secondNumberA = new SonicNumber(0, 0, 0);
		secondNumberA.folder = hudFolder;
		secondNumberA.setGraphicSize(Std.int(secondNumberA.width*3));
		secondNumberA.updateHitbox();
		secondNumberA.x = 186;
		secondNumberA.y = timeLabel.y;
		sonicHUD.add(secondNumberA);

		secondNumberB = new SonicNumber(0, 0, 0);
		secondNumberB.folder = hudFolder;
		secondNumberB.setGraphicSize(Std.int(secondNumberB.width*3));
		secondNumberB.updateHitbox();
		secondNumberB.x = 213;
		secondNumberB.y = timeLabel.y;
		sonicHUD.add(secondNumberB);

		var timeQuote:FlxSprite = new FlxSprite(0, 0);
		if(hudFolder=='chaotix'){
			timeQuote.loadGraphic(Paths.image("sonicUI/" + hudFolder + "/quote"));
			timeQuote.setGraphicSize(Std.int(timeQuote.width * 3));
			timeQuote.updateHitbox();
			timeQuote.x = secondNumberB.x + secondNumberB.width;
			timeQuote.y = timeLabel.y;
			timeQuote.antialiasing = false;
			timeQuote.scrollFactor.set();
			sonicHUD.add(timeQuote);	

			millisecondNumberA = new SonicNumber(0, 0, 0);
			millisecondNumberA.folder = hudFolder;
			millisecondNumberA.setGraphicSize(Std.int(millisecondNumberA.width*3));
			millisecondNumberA.updateHitbox();
			millisecondNumberA.x = timeQuote.x + timeQuote.width + (2*3);
			millisecondNumberA.y = timeLabel.y;
			sonicHUD.add(millisecondNumberA);	

			millisecondNumberB = new SonicNumber(0, 0, 0);
			millisecondNumberB.folder = hudFolder;
			millisecondNumberB.setGraphicSize(Std.int(millisecondNumberB.width*3));
			millisecondNumberB.updateHitbox();
			millisecondNumberB.x = millisecondNumberA.x + millisecondNumberA.width + 3;
			millisecondNumberB.y = timeLabel.y;
			sonicHUD.add(millisecondNumberB);
		}

		else if(hudFolder=='sJam'){
			timeQuote.loadGraphic(Paths.image("sonicUI/" + hudFolder + "/quote"));
			timeQuote.setGraphicSize(Std.int(timeQuote.width * 3));
			timeQuote.updateHitbox();
			timeQuote.x = secondNumberB.x + secondNumberB.width;
			timeQuote.y = timeLabel.y;
			timeQuote.antialiasing = false;
			timeQuote.scrollFactor.set();
			sonicHUD.add(timeQuote);	

			millisecondNumberA = new SonicNumber(0, 0, 0);
			millisecondNumberA.folder = hudFolder;
			millisecondNumberA.setGraphicSize(Std.int(millisecondNumberA.width*3));
			millisecondNumberA.updateHitbox();
			millisecondNumberA.x = timeQuote.x + timeQuote.width + (2*3);
			millisecondNumberA.y = timeLabel.y;
			sonicHUD.add(millisecondNumberA);	

			millisecondNumberB = new SonicNumber(0, 0, 0);
			millisecondNumberB.folder = hudFolder;
			millisecondNumberB.setGraphicSize(Std.int(millisecondNumberB.width*3));
			millisecondNumberB.updateHitbox();
			millisecondNumberB.x = millisecondNumberA.x + millisecondNumberA.width + 3;
			millisecondNumberB.y = timeLabel.y;
			sonicHUD.add(millisecondNumberB);
		}

		switch(hudFolder){
			case 'chaotix':
				minNumber.x = timeLabel.x + timeLabel.width + (4*3);
				timeColon.x = minNumber.x + minNumber.width + (2*3);
				secondNumberA.x = timeColon.x + timeColon.width + (4*3);
				secondNumberB.x = secondNumberA.x + secondNumberA.width + 3;
				timeQuote.x = secondNumberB.x + secondNumberB.width;
				millisecondNumberA.x = timeQuote.x + timeQuote.width + (2*3);
				millisecondNumberB.x = millisecondNumberA.x + millisecondNumberA.width + 3;
			case 'sJam':
				minNumber.x = timeLabel.x + timeLabel.width + (4*3);
				timeColon.x = minNumber.x + minNumber.width + (2*3);
				secondNumberA.x = timeColon.x + timeColon.width + (4*3);
				secondNumberB.x = secondNumberA.x + secondNumberA.width + 3;
				timeQuote.x = secondNumberB.x + secondNumberB.width;
				millisecondNumberA.x = timeQuote.x + timeQuote.width + (2*3);
				millisecondNumberB.x = millisecondNumberA.x + millisecondNumberA.width + 3;

			default:

		}	

		if(hudFolder == 'sJam'){
			scoreLabel.setGraphicSize(Std.int(scoreLabel.width * 1.3));
			scoreLabel.x += 60;
			timeLabel.setGraphicSize(Std.int(timeLabel.width * 1.3));
			timeLabel.x += 60;
			timeLabel.y += 17;
			missLabel.setGraphicSize(Std.int(missLabel.width * 1.3));
			missLabel.x += 60;
			missLabel.y += 35;

			for(i in 0...scoreNumbers.length){
				scoreNumbers[i].x -= 200;
				scoreNumbers[i].y += 5;
			}
			for(i in 0...missNumbers.length){
				missNumbers[i].x -= 40;
				missNumbers[i].y += 38;
			}

			minNumber.x -= 137;
			minNumber.y += 20;
			secondNumberA.x -= 137;
			secondNumberA.y += 20;
			secondNumberB.x -= 137;
			secondNumberB.y += 20;
			timeColon.x -= 137;
			timeColon.y += 20;
			timeQuote.x -= 137;
			timeQuote.y += 20;
			millisecondNumberA.x -= 137;
			millisecondNumberA.y += 20;
			millisecondNumberB.x -= 137;
			millisecondNumberB.y += 20;

			iconP1.visible = false;
			iconP2.visible = false;
			if(SONG.isBf2)
				iconP3.visible = false;
			if(SONG.isDad2)
				iconP4.visible = false;
			healthBar.visible = false;
		}

		if(!ClientPrefs.data.downScroll){
			for(member in sonicHUD.members){
				member.y = FlxG.height-member.height-member.y;
			}
		}

		if(sonicHUDSongs.contains(SONG.song.toLowerCase())){
			scoreTxt.visible=false;
			timeBar.visible=false;
			timeTxt.visible=false;
			add(sonicHUD);
		}

		updateSonicScore();
		updateSonicMisses();

		if(SONG.song.toLowerCase()=='you-cant-run'){
			scoreTxt.visible=!ClientPrefs.data.hideHud;
			timeBar.visible=!ClientPrefs.data.hideHud;
			timeTxt.visible=!ClientPrefs.data.hideHud;

			sonicHUD.visible=false;
		}

		sonicHUD.cameras = [camHUD];
		uiGroup.cameras = [camHUD];
		noteGroup.cameras = [camHUD];
		comboGroup.cameras = [camHUD];

		startingSong = true;

		#if LUA_ALLOWED
		for (notetype in noteTypes)
			startLuasNamed('custom_notetypes/' + notetype + '.lua');
		for (event in eventsPushed)
			startLuasNamed('custom_events/' + event + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');
		for (event in eventsPushed)
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end
		noteTypes = null;
		eventsPushed = null;

		if(eventNotes.length > 1)
		{
			for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		startCallback();
		RecalculateRating();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		//PRECACHING THINGS THAT GET USED FREQUENTLY TO AVOID LAGSPIKES
		if(ClientPrefs.data.hitsoundVolume > 0) Paths.sound('hitsound');
		for (i in 1...4) Paths.sound('missnote$i');
		Paths.image('alphabet');

		if (PauseSubState.songName != null)
			Paths.music(PauseSubState.songName);
		else if(Paths.formatToSongPath(ClientPrefs.data.pauseMusic) != 'none')
			Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic));

		resetRPC();

		callOnScripts('onCreatePost');

		cacheCountdown();
		cachePopUpScore();

		super.create();
		Paths.clearUnusedMemory();

		if(eventNotes.length < 1) checkEventNote();

		switch (SONG.song.toLowerCase())
		{
			case 'round-a-bout':
				var vcr:VCRDistortionShader;
				vcr = new VCRDistortionShader();
				curShader = new ShaderFilter(vcr);
				camGame.setFilters([curShader]);
				camHUD.setFilters([curShader]);
				camOther.setFilters([curShader]);
			default:
				camGame.setFilters([]);
				camHUD.setFilters([]);
				camOther.setFilters([]);
		}

		if(songName == 'round-a-bout' && dad2.curCharacter == "Sarah")
			FlxTween.tween(dad2, { alpha: 0.5 }, 3, { type: FlxTween.PINGPONG });

	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		#if FLX_PITCH
		if(generatedMusic)
		{
			vocals.pitch = value;
			opponentVocals.pitch = value;
			FlxG.sound.music.pitch = value;

			var ratio:Float = playbackRate / value; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		FlxG.animationTimeScale = value;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		setOnScripts('playbackRate', playbackRate);
		#else
		playbackRate = 1.0; // ensuring -Crow
		#end
		return playbackRate;
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor) {
		var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}
	#end

	public function reloadHealthBarColors() {
		healthBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterScripts(newBoyfriend.curCharacter);
					GameOverSubstate.resetVariables();
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterScripts(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterScripts(newGf.curCharacter);
				}
			case 3:
				if(!boyfriend2Map.exists(newCharacter)) {
					var newBoyfriend2:Character = new Character(0, 0, newCharacter, true);
					boyfriend2Map.set(newCharacter, newBoyfriend2);
					boyfriend2Group.add(newBoyfriend2);
					startCharacterPos(newBoyfriend2);
					newBoyfriend2.alpha = 0.00001;
					startCharacterScripts(newBoyfriend2.curCharacter);
				}
			case 4:
				if(!dad2Map.exists(newCharacter)) {
					var newDad2:Character = new Character(0, 0, newCharacter);
					dad2Map.set(newCharacter, newDad2);
					dad2Group.add(newDad2);
					startCharacterPos(newDad2, true);
					newDad2.alpha = 0.00001;
					startCharacterScripts(newDad2.curCharacter);
				}
	
		}
	}

	function startCharacterScripts(name:String)
	{
		// Lua
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/$name.lua';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(replacePath))
		{
			luaFile = replacePath;
			doPush = true;
		}
		else
		{
			luaFile = Paths.getSharedPath(luaFile);
			if(FileSystem.exists(luaFile))
				doPush = true;
		}
		#else
		luaFile = Paths.getSharedPath(luaFile);
		if(Assets.exists(luaFile)) doPush = true;
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile)
				{
					doPush = false;
					break;
				}
			}
			if(doPush) new FunkinLua(luaFile);
		}
		#end

		// HScript
		#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var scriptFile:String = 'characters/' + name + '.hx';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(scriptFile);
		if(FileSystem.exists(replacePath))
		{
			scriptFile = replacePath;
			doPush = true;
		}
		else
		#end
		{
			scriptFile = Paths.getSharedPath(scriptFile);
			if(FileSystem.exists(scriptFile))
				doPush = true;
		}

		if(doPush)
		{
			if(SScript.global.exists(scriptFile))
				doPush = false;

			if(doPush) initHScript(scriptFile);
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		#if LUA_ALLOWED
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		#end
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:VideoHandler = new VideoHandler();
			#if (hxCodec >= "3.0.0")
			// Recent versions
			video.play(filepath);
			video.onEndReached.add(function()
			{
				video.dispose();
				startAndEnd();
				return;
			}, true);
			#else
			// Older versions
			video.playVideo(filepath);
			video.finishCallback = function()
			{
				startAndEnd();
				return;
			}
			#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var introImagesArray:Array<String> = switch(stageUI) {
			case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
			case "normal": ["ready", "set" ,"go"];
			default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
		}
		introAssets.set(stageUI, introImagesArray);
		var introAlts:Array<String> = introAssets.get(stageUI);
		for (asset in introAlts) Paths.image(asset);

		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startSongTrans () {
		var blackbg:FlxSprite;
		var circle:FlxSprite;
		var text:FlxSprite;
	
		camHUD.alpha = 0;
	
		blackbg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackbg.scrollFactor.set(); 
		blackbg.alpha = 1;
		blackbg.screenCenter(XY);
		blackbg.cameras = [camOther];
		add(blackbg);
		blackbg.updateHitbox();
	
		circle = new FlxSprite().loadGraphic(Paths.image('introStuff/circle/Circle-' + SONG.song));
		circle.scrollFactor.set();
		circle.screenCenter(X);
		circle.cameras = [camOther];
		add(circle);
		circle.x -= 2000;
	
		text = new FlxSprite().loadGraphic(Paths.image('introStuff/text/Text-' + SONG.song));
		text.scrollFactor.set();
		text.screenCenter(X);
		text.cameras = [camOther];
		add(text);
		text.x -= -2000;
	
		FlxTween.tween(circle, {x: 0}, 0.8, {ease: FlxEase.quadOut});
		FlxTween.tween(text, {x: 0}, 0.8, {ease: FlxEase.quadOut});

		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			startCountdown();
		});

		new FlxTimer().start(2.2, function(tmr:FlxTimer) {
			FlxTween.tween(blackbg, {alpha: 0}, 0.5);
			FlxTween.tween(circle, {alpha: 0}, 0.5);
			FlxTween.tween(text, {alpha: 0}, 0.5);
			FlxTween.tween(camHUD, {alpha: 1}, 0.5);

			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
				camHUD.alpha = 1;
			});
		});
	}

	public function xterionIntro () { 
		isinxterionintro = true; 
	
		camHUD.alpha = 0; 
	
		sjamMusic = FlxG.sound.play(Paths.music('sjamMusic'), true); 
	
		xtBlackbg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK); 
		xtBlackbg.scrollFactor.set(); 
		xtBlackbg.alpha = 1; 
		xtBlackbg.screenCenter(XY); 
		xtBlackbg.cameras = [camOther]; 
		add(xtBlackbg); 
		xtBlackbg.updateHitbox(); 
	
		xtMission = new FlxSprite().loadGraphic(Paths.image('sonicUI/sJam/missionlist')); 
		xtMission.scrollFactor.set(); 
		xtMission.scale.set(1.5, 1.5); 
		xtMission.updateHitbox(); 
		xtMission.x = FlxG.width - xtMission.width - 10; 
		xtMission.y = -200; 
		xtMission.cameras = [camOther]; 
		add(xtMission); 
	
		var dummymission:FlxSprite; 
		dummymission = new FlxSprite().loadGraphic(Paths.image('sonicUI/sJam/missionlist')); 
		dummymission.scrollFactor.set(); 
		dummymission.scale.set(1.5, 1.5); 
		dummymission.updateHitbox(); 
		dummymission.x = FlxG.width - xtMission.width - 10; 
		dummymission.y = 10; 
	
		xtText = new FlxText(0, 0, 0, SONG.song, 32, true); 
		xtText.setFormat(Paths.font("NiseSegaSonic.TTF"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK); 
		xtText.scrollFactor.set(); 
		xtText.borderSize = 1.25; 
		xtText.x = xtMission.x + (xtMission.width - xtText.width) / 2 - 170; 
		xtText.y = dummymission.y + (dummymission.height - xtText.height * 2 - 200); 
		xtText.cameras = [camOther]; 
		add(xtText); 
	
		xtStartButton = new FlxSprite().loadGraphic(Paths.image('sonicUI/sJam/start')); 
		xtStartButton.scrollFactor.set(); 
		xtStartButton.scale.set(1.55, 1.55); 
		xtStartButton.updateHitbox(); 
		xtStartButton.screenCenter(XY); 
		xtStartButton.cameras = [camOther]; 
		add(xtStartButton); 
	
		FlxTween.tween(xtMission, {y: 10}, 0.8, {ease: FlxEase.quadOut}); 
		FlxTween.tween(xtText, {y: dummymission.y + (dummymission.height - xtText.height * 2 + 13)}, 0.8, {ease: FlxEase.quadOut}); 
		FlxTween.tween(xtStartButton.scale, {x: 1.7, y: 1.7}, 3, {ease: FlxEase.quadInOut, type: PINGPONG}); 
	}

	public function chaosIntro () 
		{
			var wall = Fleetway.wall;
			var floor = Fleetway.floor;
			var bgShit = Fleetway.bgShit;
			var beamUncharged = Fleetway.beamUncharged;
			var beamCharged = Fleetway.beamCharged;
			var emeralds = Fleetway.emeralds;
			var chamber = Fleetway.chamber;
			var pebbles = Fleetway.pebbles;   
			var jhonPork = Fleetway.jhonPork;

			FlxTween.tween(dad, {x: 600, y: 800}, 0.1, {ease: FlxEase.cubeOut});    
			isCameraOnForcedPos = true;			
			camFollow.x = 900;
			camFollow.y = 700;            
			FlxG.camera.zoom = defaultCamZoom;
			camHUD.visible = false;
			dad.visible = false;
			boyfriend.visible = false;

			new FlxTimer().start(0.5, function(lol:FlxTimer)
				{
					new FlxTimer().start(1, function(lol:FlxTimer)
						{
							FlxTween.tween(FlxG.camera, {zoom: 1.3}, 2, {ease: FlxEase.cubeOut});
							FlxG.sound.play(Paths.sound('Fleetway/robot'));
							FlxG.camera.flash(FlxColor.RED, 0.2);
						});
						new FlxTimer().start(2, function(lol:FlxTimer)
						{
							FlxG.sound.play(Paths.sound('Fleetway/sonic'));
							chamber.animation.play('woah');
						});

					new FlxTimer().start(6, function(lol:FlxTimer)
					{
						startCountdown();                                
						dad.visible = true;
						FlxG.sound.play(Paths.sound('Fleetway/beam'));
						camFollow.y -= 500;      
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.2, {ease: FlxEase.cubeOut});
						FlxG.camera.shake(0.02, 0.2);
						FlxG.camera.flash(FlxColor.WHITE, 0.2);
						wall.animation.play('nogud');
						floor.animation.play('yellow');
						bgShit.animation.play('yellow');
						pebbles.animation.play('yellow');
						beamUncharged.visible = false;
						beamCharged.visible = true;

						new FlxTimer().start(0.7, function(lol:FlxTimer)
							{
								FlxTween.tween(dad, {x: 600, y: -400}, 0.8, {ease: FlxEase.cubeOut});
								
								new FlxTimer().start(0.6, function(lol:FlxTimer)
									{
										isCameraOnForcedPos = false;			
									});
							});
						new FlxTimer().start(4.9, function(lol:FlxTimer)
							{
								camHUD.visible = true;
								boyfriend.visible = true;
							});
					});
				});
	}

	public function needleIntro () {
		startCountdown();

		var blackbg:FlxSprite;	
		var needleBad:FlxSprite;
		var needleGud:FlxSprite;

		needleBad = new FlxSprite().loadGraphic(Paths.image('needleM0use/needleBad')); 
		needleBad.scrollFactor.set(); 
		needleBad.updateHitbox(); 
		needleBad.screenCenter(XY); 
		needleBad.cameras = [camOther]; 
		add(needleBad); 

		blackbg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackbg.scrollFactor.set(); 
		blackbg.alpha = 1;
		blackbg.screenCenter(XY);	
		blackbg.updateHitbox();
		blackbg.cameras = [camOther];
		add(blackbg);

		needleGud = new FlxSprite().loadGraphic(Paths.image('needleM0use/needleGud')); 
		needleGud.scrollFactor.set(); 
		needleGud.updateHitbox(); 
		needleGud.screenCenter(XY); 
		needleGud.alpha = 0;
		needleGud.cameras = [camOther]; 
		add(needleGud);

		//"1963","I KNOw wHERe yoU livE","I'M TRAPPED","30 YEARS","30 LONG YEARS..","MOM","DAD","LILY","I REMEMBER EVERYTHING","THERE IS NO GOD.","YOU ARE IN MY WORLD NOW.","803 Branch Lane Kennersville, NC 27284","I CAN STILL FEEL THE PAIN"

		FlxTween.tween(needleGud, {alpha: 1}, 1, {onComplete: function(twn:FlxTween) {
			remove(blackbg);
			blackbg.destroy();			
			new FlxTimer().start(0.8, function(tmr:FlxTimer) {
				needleGud.visible = false;

			new FlxTimer().start(0.45, function(tmr:FlxTimer) {
				needleBad.visible = false;
				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.RED : 0xFFFF0000, 1.2);
			});
		});
	}});
	}

	public function sunkIntro () {
		var blackbg:FlxSprite;
		var sunk:FlxSprite;
	
		camHUD.alpha = 0;
	
		blackbg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackbg.scrollFactor.set(); 
		blackbg.alpha = 1;
		blackbg.screenCenter(XY);
		blackbg.cameras = [camOther];
		add(blackbg);
		blackbg.updateHitbox();
	
		sunk = new FlxSprite().loadGraphic(Paths.image('introStuff/Sunky'));
		sunk.scrollFactor.set();
		sunk.screenCenter(XY);
		sunk.cameras = [camOther];
		add(sunk);
		sunk.x += 200;
		sunk.y -= 2000;


		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			FlxTween.tween(sunk, {y: 0}, 0.3, {ease: FlxEase.quadOut});
			FlxG.sound.play(Paths.sound('Sunk/flatBONK'));

			new FlxTimer().start(1, function(tmr:FlxTimer) {
				FlxTween.tween(blackbg, {alpha: 0}, 0.5);
				FlxTween.tween(sunk, {alpha: 0}, 0.5);
				FlxTween.tween(camHUD, {alpha: 1}, 0.5);
				startCountdown();

				new FlxTimer().start(0.5, function(tmr:FlxTimer) {
					camHUD.alpha = 1;
				});
			});
		});
	}
	
	public function startCountdown()
	{
		if(startedCountdown) {
			callOnScripts('onStartCountdown');
			return false;
		}

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if(ret != LuaUtils.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.data.middleScroll) opponentStrums.members[i].visible = false;
			}

			if (songName == 'fatality') {
   				for (strum in opponentStrums) {
        		strum.texture = 'noteSkins/NOTE_assets-fatal';
   				}
   				for (note in unspawnNotes) {
        			//if (note.mustPress) continue;
        			note.texture = 'noteSkins/NOTE_assets-fatal';
    			}
			}

			if (isFixedAspectRatio) {
				playerStrums.forEach(function(spr:FlxSprite)
					{
						spr.x -= 65;
					});
				opponentStrums.forEach(function(spr:FlxSprite)
					{
						spr.x -= 75;
					});
			}

			if(sonicHUDSongs.contains(SONG.song.toLowerCase()) && SONG.song.toLowerCase() != 'you-cant-run'){
				healthBar.x += 150;
				iconP1.x += 150;
				iconP2.x += 150;
				if(SONG.isBf2)
					iconP2.x += 150;
				if(SONG.isDad2)
					iconP4.x += 150;
			}
		

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted', null);

			var swagCounter:Int = 0;
			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return true;
			}
			moveCameraSection();

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				characterBopper(tmr.loopsLeft);

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				var introImagesArray:Array<String> = switch(stageUI) {
					case "pixel": ['${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
					case "normal": ["ready", "set" ,"go"];
					default: ['${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
				}
				introAssets.set(stageUI, introImagesArray);

				var introAlts:Array<String> = introAssets.get(stageUI);
				var antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelStage);
				var tick:Countdown = THREE;

				switch (swagCounter)
				{
					case 0:
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						tick = THREE;
					case 1:
						countdownReady = createCountdownSprite(introAlts[0], antialias);
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						tick = TWO;
					case 2:
						countdownSet = createCountdownSprite(introAlts[1], antialias);
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						tick = ONE;
					case 3:
						countdownGo = createCountdownSprite(introAlts[2], antialias);
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						tick = GO;
					case 4:
						tick = START;
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.data.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.data.middleScroll && !note.mustPress)
							note.alpha *= 0.35;
					}
				});

				stagesFunc(function(stage:BaseStage) stage.countdownTick(tick, swagCounter));
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHScript('onCountdownTick', [tick, swagCounter]);

				swagCounter += 1;
			}, 5);
		}
		return true;
	}

	inline private function createCountdownSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (PlayState.isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		insert(members.indexOf(noteGroup), spr);
		FlxTween.tween(spr, {/*y: spr.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				remove(spr);
				spr.destroy();
			}
		});
		return spr;
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriend2Group), obj);
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dad2Group), obj);
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				invalidateNote(daNote);
			}
			--i;
		}
	}

	// fun fact: Dynamic Functions can be overriden by just doing this
	// `updateScore = function(miss:Bool = false) { ... }
	// its like if it was a variable but its just a function!
	// cool right? -Crow
	public dynamic function updateScore(miss:Bool = false)
	{
		var ret:Dynamic = callOnScripts('preUpdateScore', [miss], true);
		if (ret == LuaUtils.Function_Stop)
			return;

		var str:String = ratingName;
		if(totalPlayed != 0)
		{
			var percent:Float = CoolUtil.floorDecimal(ratingPercent * 100, 2);
			str += ' (${percent}%) - ${ratingFC}';
		}

		var tempScore:String = 'Score: ${songScore}'
		+ (!instakillOnMiss ? ' | Misses: ${songMisses}' : "")
		+ ' | Rating: ${str}';
		// "tempScore" variable is used to prevent another memory leak, just in case
		// "\n" here prevents the text from being cut off by beat zooms
		scoreTxt.text = '${tempScore}\n';

		if (!miss && !cpuControlled)
			doScoreBop();

		callOnScripts('onUpdateScore', [miss]);
	}

	public dynamic function fullComboFunction()
	{
		var sicks:Int = ratingsData[0].hits;
		var goods:Int = ratingsData[1].hits;
		var bads:Int = ratingsData[2].hits;
		var shits:Int = ratingsData[3].hits;

		ratingFC = "";
		if(songMisses == 0)
		{
			if (bads > 0 || shits > 0) ratingFC = 'FC';
			else if (goods > 0) ratingFC = 'GFC';
			else if (sicks > 0) ratingFC = 'SFC';
		}
		else {
			if (songMisses < 10) ratingFC = 'SDCB';
			else ratingFC = 'Clear';
		}
	}

	public function doScoreBop():Void {
		if(!ClientPrefs.data.scoreZoom)
			return;

		if(scoreTxtTween != null)
			scoreTxtTween.cancel();

		scoreTxt.scale.x = 1.075;
		scoreTxt.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.time = time;
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			opponentVocals.time = time;
			#if FLX_PITCH
			vocals.pitch = playbackRate;
			opponentVocals.pitch = playbackRate;
			#end
		}
		vocals.play();
		opponentVocals.play();
		Conductor.songPosition = time;
	}

	public function startNextDialogue() {
		dialogueCount++;
		callOnScripts('onNextDialogue', [dialogueCount]);
	}

	public function skipDialogue() {
		callOnScripts('onSkipDialogue', [dialogueCount]);
	}

	function startSong():Void
	{
		startingSong = false;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		opponentVocals.play();

		if(startOnTime > 0) setSongTime(startOnTime - 500);
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence (with Time Left)
		if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart');
	}

	var debugNum:Int = 0;
	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = PlayState.SONG.speed;
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		try
		{
			if (songData.needsVoices)
			{
				var playerVocals = Paths.voices(songData.song, (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile);
				vocals.loadEmbedded(playerVocals != null ? playerVocals : Paths.voices(songData.song));
				
				var oppVocals = Paths.voices(songData.song, (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile);
				if(oppVocals != null) opponentVocals.loadEmbedded(oppVocals);
			}
		}
		catch(e:Dynamic) {}

		#if FLX_PITCH
		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;
		#end
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);

		inst = new FlxSound();
		try {
			inst.loadEmbedded(Paths.inst(songData.song));
		}
		catch(e:Dynamic) {}
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		noteGroup.add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file))
		#else
		if (OpenFlAssets.exists(file))
		#end
		{
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
				for (i in 0...event[1].length)
					makeEvent(event, i);
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.dad2Note = (section.dad2Section && (songNotes[1]<4));
				swagNote.bf2Note = (section.bf2Section && (songNotes[1]<4));
				swagNote.dadsDuetNote = (section.dadsDuetSection && (songNotes[1]<4));
				swagNote.bfsDuetNote = (section.bfsDuetSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				unspawnNotes.push(swagNote);

				final susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;
				final floorSus:Int = Math.floor(susLength);

				if(floorSus > 0) {
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.dad2Note = (section.dad2Section && (songNotes[1]<4));
						sustainNote.bf2Note = (section.bf2Section && (songNotes[1]<4));
						sustainNote.dadsDuetNote = (section.dadsDuetSection && (songNotes[1]<4));
						sustainNote.bfsDuetNote = (section.bfsDuetSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						swagNote.tail.push(sustainNote);

						sustainNote.correctionOffset = swagNote.height / 2;
						if(!PlayState.isPixelStage)
						{
							if(oldNote.isSustainNote)
							{
								oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
								oldNote.scale.y /= playbackRate;
								oldNote.updateHitbox();
							}

							if(ClientPrefs.data.downScroll)
								sustainNote.correctionOffset = 0;
						}
						else if(oldNote.isSustainNote)
						{
							oldNote.scale.y /= playbackRate;
							oldNote.updateHitbox();
						}

						if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
						else if(ClientPrefs.data.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.data.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypes.contains(swagNote.noteType)) {
					noteTypes.push(swagNote.noteType);
				}
			}
		}
		for (event in songData.events) //Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	// called only once per different event (Used for precaching)
	function eventPushed(event:EventNote) {
		eventPushedUnique(event);
		if(eventsPushed.contains(event.event)) {
			return;
		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		eventsPushed.push(event.event);
	}

	// called by every event with the same name
	function eventPushedUnique(event:EventNote) {
		switch(event.event) {
			case "Change Character":
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'bf2' | 'boyfriend2' | '3':
						charType = 3;
					case 'dad2' | 'opponent2' | '4':
						charType = 4;
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						var val1:Int = Std.parseInt(event.value1);
						if(Math.isNaN(val1)) val1 = 0;
						charType = val1;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Play Sound':
				Paths.sound(event.value1); //Precache sound
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushedUnique(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true, [], [0]);
		if(returnedValue != null && returnedValue != 0 && returnedValue != LuaUtils.Function_Continue) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [subEvent.event, subEvent.value1 != null ? subEvent.value1 : '', subEvent.value2 != null ? subEvent.value2 : '', subEvent.strumTime]);
	}

	public var skipArrowStartTween:Bool = true; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		var strumLineX:Float = ClientPrefs.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X;
		var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.data.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.data.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(strumLineX, strumLineY, i, player);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
				babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if(ClientPrefs.data.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			var colorSwap:ColorSwap = new ColorSwap();
			colorSwap.hue = -1;
			colorSwap.brightness = -0.5;
			colorSwap.saturation = -1;

			if (curShader != null && health > 0)
				{
					camGame.setFilters([curShader, new ShaderFilter(colorSwap.shader)]);
					camHUD.setFilters([curShader, new ShaderFilter(colorSwap.shader)]);
					//camOther.setFilters([curShader, new ShaderFilter(colorSwap.shader)]);
				}
				else if (curShader == null && health > 0)
				{
					camGame.setFilters([new ShaderFilter(colorSwap.shader)]);
					camHUD.setFilters([new ShaderFilter(colorSwap.shader)]);
					//camOther.setFilters([new ShaderFilter(colorSwap.shader)]);
				}

			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				opponentVocals.pause();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = false);
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		super.closeSubState();
		
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (paused)
		{
			if (curShader != null)
				{
					camGame.setFilters([curShader]);
					camHUD.setFilters([curShader]);
					camOther.setFilters([curShader]);
				}
				else
				{
					camGame.setFilters([]);
					camHUD.setFilters([]);
					camOther.setFilters([]);
				}

			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = true);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = true);

			paused = false;
			callOnScripts('onResume');
			resetRPC(startTimer != null && startTimer.finished);
		}
	}

	override public function onFocus():Void
	{
		if (health > 0 && !paused) resetRPC(Conductor.songPosition > 0.0);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if DISCORD_ALLOWED
		if (health > 0 && !paused && autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		super.onFocusLost();
	}

	// Updating Discord Rich Presence.
	public var autoUpdateRPC:Bool = true; //performance setting for custom RPC things
	function resetRPC(?showTime:Bool = false)
	{
		#if DISCORD_ALLOWED
		if(!autoUpdateRPC) return;

		if (showTime)
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
		else
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.play();
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			#if FLX_PITCH vocals.pitch = playbackRate; #end
		}

		if (Conductor.songPosition <= opponentVocals.length)
		{
			opponentVocals.time = Conductor.songPosition;
			#if FLX_PITCH opponentVocals.pitch = playbackRate; #end
		}
		vocals.play();
		opponentVocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var freezeCamera:Bool = false;
	var allowDebugKeys:Bool = true;

	override public function update(elapsed:Float)
	{

		if (isFixedAspectRatio)
			FlxG.fullscreen = false;

		if(!sunkerTimebarFuckery)
			timeBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]));

		if(!inCutscene && !paused && !freezeCamera) {
			FlxG.camera.followLerp = 2.4 * cameraSpeed * playbackRate;
			if(!startingSong && !endingSong && boyfriend.getAnimationName().startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}
		else FlxG.camera.followLerp = 0;
		callOnScripts('onUpdate', [elapsed]);

		// Continuously update the score, misses, and time
		if (sonicHUDSongs.contains(SONG.song.toLowerCase())) {
		    updateSonicScore();
		    updateSonicMisses();
		    updateSonicTime(elapsed);
		}

		if (FlxG.keys.justPressed.ENTER && isinxterionintro)
			{
				isinxterionintro = false;

				FlxTween.tween(sjamMusic, {volume: 0}, 0.4, {onComplete: function(tween:FlxTween) {
					sjamMusic.stop();
				}});

				FlxTween.tween(xtBlackbg, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(xtMission, {y: -200}, 0.4, {ease: FlxEase.quadOut});
				FlxTween.tween(xtText, {y: -200}, 0.4, {ease: FlxEase.quadOut});
				FlxTween.tween(xtStartButton, {alpha: 0}, 0.4, {ease: FlxEase.quartInOut});
				FlxTween.tween(camHUD, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});

				new FlxTimer().start(0.5, function(tmr:FlxTimer) {
					startCountdown();	
				});
			}

		super.update(elapsed);

		setOnScripts('curDecStep', curDecStep);
		setOnScripts('curDecBeat', curDecBeat);

		if(botplayTxt != null && botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnScripts('onPause', null, true);
			if(ret != LuaUtils.Function_Stop) {
				openPauseMenu();
			}
		}

		if(!endingSong && !inCutscene && allowDebugKeys)
		{
			if (controls.justPressed('debug_1'))
				openChartEditor();
			else if (controls.justPressed('debug_2'))
				openCharacterEditor();
		}

		if (!isCameraOnForcedPos && !endingSong) {
			var target = SONG.notes[curSection];
			if (target != null) {
				var isMustHitSection = target.mustHitSection;
				var bf2Section = target.bf2Section;
				var dad2Section = target.dad2Section;
				var dadsDuetSection = target.dadsDuetSection;
				var bfsDuetSection = target.bfsDuetSection;
		
				var character;
				var offsetX;
				var cameraOffset;
		
				if (bf2Section) {
					character = boyfriend2;
					offsetX = -100;
					cameraOffset = boyfriend2CameraOffset;
				} else if (dad2Section) {
					character = dad2;
					offsetX = 150;
					cameraOffset = opponent2CameraOffset;
				} else if (dadsDuetSection) {
					character = dad2;
					offsetX = 150;
					cameraOffset = opponent2CameraOffset;
				} else if (bfsDuetSection) {
					character = boyfriend2;
					offsetX = 150;
					cameraOffset = boyfriend2CameraOffset;
				} else if (isMustHitSection) {
					character = boyfriend;
					offsetX = -100;
					cameraOffset = boyfriendCameraOffset;
				} else {
					character = dad;
					offsetX = 150;
					cameraOffset = opponentCameraOffset;
				}
		
				switch (character.animation.curAnim.name) {
					case "singLEFT" | "singLEFT-loop" | "singLEFT-alt":
						camFollow.setPosition(character.getMidpoint().x + offsetX - 25, character.getMidpoint().y - 100);
					case "singRIGHT" | "singRIGHT-loop" | "singRIGHT-alt":
						camFollow.setPosition(character.getMidpoint().x + offsetX + 50, character.getMidpoint().y - 100);
					case "singDOWN" | "singDOWN-loop" | "singDOWN-alt":
						camFollow.setPosition(character.getMidpoint().x + offsetX, character.getMidpoint().y - 50);
					case "singUP" | "singUP-loop" | "singUP-alt":
						camFollow.setPosition(character.getMidpoint().x + offsetX, character.getMidpoint().y - 150);
					case "idle" | "idle-alt" | "idle-loop" | "singLEFTmiss" | "singDOWNmiss" | "singUPmiss" | "singRIGHTmiss" | "danceLeft" | "danceRight":
						camFollow.setPosition(character.getMidpoint().x + offsetX, character.getMidpoint().y - 100);
					default:
						camFollow.setPosition(character.getMidpoint().x + offsetX, character.getMidpoint().y - 100);
				}
		
				camFollow.x += character.cameraPosition[0] + cameraOffset[0];
				camFollow.y += character.cameraPosition[1] + cameraOffset[1];
			}
		}	

		if (healthBar.bounds.max != null && health > healthBar.bounds.max)
			health = healthBar.bounds.max;

		updateIconsScale(elapsed);
		updateIconsPosition();

		if (startedCountdown && !paused)
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else if (!paused && updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime);
			if(ClientPrefs.data.timeBarType == 'Time Elapsed') songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if(ClientPrefs.data.timeBarType != 'Song Name')
				timeTxt.text = SONG.song;
				timeTxt.text = SONG.song.replace("-", " ");
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.data.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime * playbackRate;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;
			
				if (songName == 'fatality')
					{
						if (!dunceNote.mustPress)
						dunceNote.texture = 'noteSkins/NOTE_assets-fatal';
					}

				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, dunceNote.strumTime]);
				callOnHScript('onSpawnNote', [dunceNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled)
					keysCheck();
				else
				{
					playerDance();

					if(SONG.isBf2)
						player2Dance();

				}
				if(notes.length > 0)
				{
					if(startedCountdown)
					{
						var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
						notes.forEachAlive(function(daNote:Note)
						{
							var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
							if(!daNote.mustPress) strumGroup = opponentStrums;

							var strum:StrumNote = strumGroup.members[daNote.noteData];
							daNote.followStrumNote(strum, fakeCrochet, songSpeed / playbackRate);

							if(daNote.mustPress)
							{
								if(cpuControlled && !daNote.blockHit && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition))
									goodNoteHit(daNote);
							}
							else if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
								opponentNoteHit(daNote);

							if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

							// Kill extremely late notes and cause misses
							if (Conductor.songPosition - daNote.strumTime > noteKillOffset)
							{
								if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
									noteMiss(daNote);

								daNote.active = daNote.visible = false;
								invalidateNote(daNote);
							}
						});
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
			checkEventNote();
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnScripts('cameraX', camFollow.x);
		setOnScripts('cameraY', camFollow.y);
		setOnScripts('botPlay', cpuControlled);
		callOnScripts('onUpdatePost', [elapsed]);

		//Phantom note shit
		if(dropTime > 0)
			{
				dropTime -= elapsed;
				health -= healthDrop * (elapsed/(1/120));
			}
			
			if(dropTime<=0)
			{
				healthDrop = 0;
				dropTime = 0;
			}

		managePopups();

		//fatality window shit
		if (SONG.song.toLowerCase() == 'fatality' && IsWindowMoving)
			{
				var thisX:Float = Math.sin(Xamount * (Xamount)) * 100;
				var thisY:Float = Math.sin(Yamount * (Yamount)) * 100;
				var yVal = Std.int(windowY + thisY);
				var xVal = Std.int(windowX + thisX);
				Lib.application.window.move(xVal, yVal);
				Yamount = Yamount + 0.0015;
				Xamount = Xamount + 0.00075;
			}
	}

	// Health icon updaters
	public dynamic function updateIconsScale(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 9 * playbackRate));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		if(SONG.isBf2)
			{		
				var mult:Float = FlxMath.lerp(1, iconP3.scale.x, Math.exp(-elapsed * 9 * playbackRate));
				iconP3.scale.set(mult, mult);
				iconP3.updateHitbox();
			}

		if(SONG.isDad2)
			{		
				var mult:Float = FlxMath.lerp(1, iconP4.scale.x, Math.exp(-elapsed * 9 * playbackRate));
				iconP4.scale.set(mult, mult);
				iconP4.updateHitbox();
			}
	}

	public dynamic function updateIconsPosition()
	{
		var iconOffset:Int = 26;
		iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		if(SONG.isBf2)
			iconP3.x = healthBar.barCenter + (150 * iconP3.scale.x - 150) / 2 - iconOffset + 70;
		if(SONG.isDad2)
			iconP4.x = healthBar.barCenter - (150 * iconP4.scale.x) / 2 - iconOffset * 2 - 70;
	}

	var iconsAnimations:Bool = true;
	function set_health(value:Float):Float // You can alter how icon animations work here
	{
		if(!iconsAnimations || healthBar == null || !healthBar.enabled || healthBar.valueFunction == null)
		{
			health = value;
			return health;
		}

		// update health bar
		health = value;
		var newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0; //If health is under 20%, change player icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0; //If health is over 80%, change opponent icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		if(SONG.isBf2)
			iconP3.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0; //If health is under 20%, change player icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		if(SONG.isDad2)
			iconP4.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0; //If health is over 80%, change opponent icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		return health;
	}

	function openPauseMenu()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}
		if(!cpuControlled)
		{
			for (note in playerStrums)
				if(note.animation.curAnim != null && note.animation.curAnim.name != 'static')
				{
					note.playAnim('static');
					note.resetAnim = 0;
				}
		}
		openSubState(new PauseSubState());

		#if DISCORD_ALLOWED
		if(autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		chartingMode = true;

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Chart Editor", null, null, true);
		DiscordClient.resetClientID();
		#end

		MusicBeatState.switchState(new ChartingState());
	}

	function openCharacterEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if(ret != LuaUtils.Function_Stop) {
				FlxG.animationTimeScale = 1;
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				opponentVocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				FlxTimer.globalManager.clear();
				FlxTween.globalManager.clear();
				#if LUA_ALLOWED
				modchartTimers.clear();
				modchartTweens.clear();
				#end
				

				openSubState(new GameOverSubstate());

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if DISCORD_ALLOWED
				// Game Over doesn't get his its variable because it's only used here
				if(autoUpdateRPC) DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEvent(eventNotes[0].event, value1, value2, leStrumTime);
			eventNotes.shift();
		}
	}

	public function triggerEvent(eventName:String, value1:String, value2:String, strumTime:Float) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		if(Math.isNaN(flValue1)) flValue1 = null;
		if(Math.isNaN(flValue2)) flValue2 = null;

		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				if(flValue2 == null || flValue2 <= 0) flValue2 = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = flValue2;
				}

			case 'Set GF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				gfSpeed = Math.round(flValue1);

			case 'Add Camera Zoom':
				if(ClientPrefs.data.camZooms && FlxG.camera.zoom < 1.35) {
					if(flValue1 == null) flValue1 = 0.015;
					if(flValue2 == null) flValue2 = 0.03;

					FlxG.camera.zoom += flValue1;
					camHUD.zoom += flValue2;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					case 'bf1' | 'boyfriend2':
						char = boyfriend2;
					case 'dad2':
						char = dad2;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
							case 3: char = boyfriend2;
							case 4: char = dad2;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					isCameraOnForcedPos = false;
					if(flValue1 != null || flValue2 != null)
					{
						isCameraOnForcedPos = true;
						if(flValue1 == null) flValue1 = 0;
						if(flValue2 == null) flValue2 = 0;
						camFollow.x = flValue1;
						camFollow.y = flValue2;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					case 'bf2' | 'boyfriend2':
						char = boyfriend2;
					case 'dad2':
						char = dad2;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
							case 3: char = boyfriend2;
							case 4: char = dad2;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());	
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}


			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'dad2' | 'opponent2':
						charType = 4;
					case 'bf2' | 'boyfriend2':
						charType = 3;
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnScripts('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf-') || dad.curCharacter == 'gf';
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf-') && dad.curCharacter != 'gf') {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnScripts('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnScripts('gfName', gf.curCharacter);
						}

					case 3:
						if(boyfriend2.curCharacter != value2) {
							if(!boyfriend2Map.exists(value2)) {
								addCharacterToList(value2, charType);
							}
	
							var lastAlpha:Float = boyfriend2.alpha;
							boyfriend2.alpha = 0.00001;
							boyfriend2 = boyfriend2Map.get(value2);
							boyfriend2.alpha = lastAlpha;
							iconP3.changeIcon(boyfriend2.healthIcon);
						}	
						setOnScripts('boyfriend2Name', boyfriend2.curCharacter);
					case 4:
						if(dad2.curCharacter != value2) {
							if(!dad2Map.exists(value2)) {
								addCharacterToList(value2, charType);
							}
	
							var lastAlpha:Float = dad2.alpha;
							dad2.alpha = 0.00001;
							dad2 = dad2Map.get(value2);
							dad2.alpha = lastAlpha;
							iconP4.changeIcon(dad2.healthIcon);
						}	
				}					
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
					if(flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {ease: FlxEase.linear, onComplete:
							function (twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}

			case 'Set Property':
				try
				{
					var split:Array<String> = value1.split('.');
					if(split.length > 1) {
						LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1], value2);
					} else {
						LuaUtils.setVarInArray(this, value1, value2);
					}
				}
				catch(e:Dynamic)
				{
					var len:Int = e.message.indexOf('\n') + 1;
					if(len <= 0) len = e.message.length;
					#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
					addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, len), FlxColor.RED);
					#else
					FlxG.log.warn('ERROR ("Set Property" Event) - ' + e.message.substr(0, len));
					#end
				}

			case 'Play Sound':
				if(flValue2 == null) flValue2 = 1;
				FlxG.sound.play(Paths.sound(value1), flValue2);

			case 'Cinematic Bars':
				if (flValue2 == null) flValue2 = 0.7;
		
				camHUD.alpha = 1;
		
				// Check if the bars have already been created
				if (topBar == null || botBar == null) {
					topBar = new FlxSprite(0, -Std.parseInt(value1)).makeGraphic(1280, Std.parseInt(value1), FlxColor.BLACK);
					topBar.scrollFactor.set();
					topBar.camera = camOther;
					topBar.screenCenter(X);
		
					botBar = new FlxSprite(0, 720).makeGraphic(1280, Std.parseInt(value1), FlxColor.BLACK);
					botBar.scrollFactor.set();
					botBar.camera = camOther;
					botBar.screenCenter(X);
		
					add(topBar);
					add(botBar);
				}
		
				if (flValue1 == null || flValue1 == 0) {
					FlxTween.tween(camHUD, {alpha: 1}, flValue2, {ease: FlxEase.quartInOut});
					FlxTween.tween(topBar, {y: -topBar.height}, flValue2, {ease: FlxEase.quadOut});
					FlxTween.tween(botBar, {y: 720 + botBar.height}, flValue2, {ease: FlxEase.quadOut});
				} else if (flValue1 > 0.1) {
					FlxTween.tween(camHUD, {alpha: 0}, flValue2, {ease: FlxEase.quartInOut});
					FlxTween.tween(topBar, {y: 0}, flValue2, {ease: FlxEase.quadOut});
					FlxTween.tween(botBar, {y: 720 - botBar.height}, flValue2, {ease: FlxEase.quadOut});
				}
	
				case 'Pickel':
				if (value1 == "ye") {
					stageUI = "pixel";
			
					scoreTxt.visible = false;
					timeBar.visible = false;
					timeTxt.visible = false;
			
					removeStatics();
					generateStaticArrows(0);
					generateStaticArrows(1);
			
					for (note in notes) {
						if (note.isSustainNote) {
							note.scale.set(note.scale.x, PlayState.daPixelZoom);
							note.updateHitbox();
						} else {
							note.scale.set(PlayState.daPixelZoom);
						}
						note.loadPixelNoteAnims();
					}
			

					healthBar.x += 150;
					iconP1.x += 150;
					iconP2.x += 150;
					if(SONG.isBf2)
						iconP3.x += 150;
					if(SONG.isDad2)
						iconP4.x += 150;
					updateIconsPosition();
					iconP1.updateHitbox();
					iconP2.updateHitbox();
					if(SONG.isBf2)
						iconP3.updateHitbox();
					if(SONG.isDad2)
						iconP4.updateHitbox();
					reloadHealthBarColors();
			
					sonicHUD.visible = true;
			
				} else if (value1 == "no") {
					stageUI = "normal";
			
					scoreTxt.visible = !ClientPrefs.data.hideHud;
					timeBar.visible = !ClientPrefs.data.hideHud;
					timeTxt.visible = !ClientPrefs.data.hideHud;
			
					removeStatics();
					generateStaticArrows(0);
					generateStaticArrows(1);
			
					for (note in notes) {
						if (note.isSustainNote) {
							note.scale.set(note.scale.x, 1);
							note.updateHitbox();
						} else {
							note.scale.set(note.scale.x, 1);
						}
					}
			
					healthBar.x -= 137;
					iconP1.x -= 137;
					iconP2.x -= 137;
					if(SONG.isBf2)
						iconP3.x += 137;
					if(SONG.isDad2)
						iconP4.x += 137;
					updateIconsPosition();
					iconP1.updateHitbox();
					iconP2.updateHitbox();
					if(SONG.isBf2)
						iconP3.updateHitbox();
					if(SONG.isDad2)
						iconP4.updateHitbox();
					reloadHealthBarColors();
			
					sonicHUD.visible = false;
				}
			
			case 'Note spin':
				strumLineNotes.forEach(function(tospin:FlxSprite)
					{
						FlxTween.angle(tospin, 0, 360, 0.2, {ease: FlxEase.quintOut});
					});
			case 'sonicspook':
				trace('JUMPSCARE aaaa');
	
				var daJumpscare:FlxSprite = new FlxSprite();
				daJumpscare.frames = Paths.getSparrowAtlas('sonicJUMPSCARE');
				daJumpscare.animation.addByPrefix('jump', "sonicSPOOK", 24, false);
				daJumpscare.animation.play('jump',true);
				daJumpscare.scale.x = 1.3;
				daJumpscare.scale.y = 1.3;
				daJumpscare.updateHitbox();
				daJumpscare.screenCenter();
				daJumpscare.y += 370;
				daJumpscare.cameras = [camHUD];
	
				FlxG.sound.play(Paths.sound('datOneSound'), 1);
	
				add(daJumpscare);
	
				daJumpscare.animation.play('jump');
	
				daJumpscare.animation.finishCallback = function(pog:String)
				{
					trace('ended jump');
					daJumpscare.visible = false;
				}

			case 'Change Noteskin':

				for (note in unspawnNotes) {
					if (note.isSustainNote) {
						note.updateHitbox();
					} else {
						note.scale.set(1, 1);
					}
					note.reloadNote('noteSkins/NOTE_assets-' + value1);
				}				
							
				for (strum in strumLineNotes) {
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
						{
							strum.texture = 'noteSkins/NOTE_assets-' + value1;
							strum.reloadNote();
						});
				}

				if (flValue2 == null) {				
					for (note in unspawnNotes) {
					note.noteSplashData.texture = 'noteSplashes/noteSplashes';
				  	}
				}
				else{
					for (note in unspawnNotes) {
						note.noteSplashData.texture = 'noteSplashes/noteSplashes-' + value2;
					 	}
				}


			case 'Flash Camera red':
				if (flValue1 == null) flValue1 = 1;

				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.RED : 0xFFFF0000, flValue1);

			case 'RedVG':
				if (flValue1 == null) flValue1 = 2.5;

				var VG:FlxSprite;
				VG = new FlxSprite().loadGraphic(Paths.image('RedVG'));
				VG.alpha = 0.6;
				VG.scrollFactor.set();
				VG.camera = camOther;
				VG.screenCenter(XY);
				add(VG);

				FlxTween.tween(VG, {alpha: 0}, flValue1, {ease: FlxEase.quartInOut});

			case 'jumpscare':
				var boo:FlxSprite;
				boo = new FlxSprite().loadGraphic(Paths.image('jumpscares/' + value1));
				boo.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
				boo.scrollFactor.set();
				boo.camera = camOther;
				boo.screenCenter(XY);
				add(boo);
				
				var statix:FlxSprite;
				statix = new FlxSprite().setFrames(Paths.getSparrowAtlas('screenstatic'));
				statix.animation.addByPrefix('screenSTATIC', 'screenSTATIC', 25, true);
				statix.animation.play('screenSTATIC');
				statix.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
				statix.alpha = 0.3;
				statix.screenCenter(XY);
				statix.camera = camOther;
				add(statix);
				
				FlxG.camera.shake(0.0025, 0.50);
				FlxG.sound.play(Paths.sound('jumpscares/' + value2));

				new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						boo.destroy();
						statix.destroy();
					});
			case 'static':
				if (flValue1 == null) flValue1 = 0.3;
				if (flValue2 == null) flValue2 = 0.3;

				var statix:FlxSprite;
				statix = new FlxSprite().setFrames(Paths.getSparrowAtlas('screenstatic'));
				statix.animation.addByPrefix('screenSTATIC', 'screenSTATIC', 25, true);
				statix.animation.play('screenSTATIC');
				statix.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
				statix.alpha = flValue2;
				statix.screenCenter(XY);
				statix.camera = camOther;
				add(statix);
				
				FlxG.sound.play(Paths.sound('staticBUZZ'));

				new FlxTimer().start(flValue1, function(tmr:FlxTimer)
					{
						statix.destroy();
					});
			case 'Majin count':
				playerDance();
				switch (Std.parseFloat(value1))
				{
					case 1:
						inCutscene = true;
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
						majinSaysFuck(4);
					case 2:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
						majinSaysFuck(3);
					case 3:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 0.7, {ease: FlxEase.cubeInOut});
						majinSaysFuck(2);
					case 4:
						inCutscene = false;
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.7, {ease: FlxEase.cubeInOut});
						majinSaysFuck(1);
				}
			case 'Fleet Attack':
				canDodge = true;
			
				var dodgeShi:FlxSprite = new FlxSprite(0, 0);
				dodgeShi.frames = Paths.getSparrowAtlas('spacebar_icon');
				dodgeShi.animation.addByPrefix('pressed', 'spacebar00', 24, false);
				dodgeShi.scale.x = .5;
				dodgeShi.scale.y = .5;
				dodgeShi.screenCenter();
				dodgeShi.cameras = [camHUD];
				add(dodgeShi);
			
				var dodgeTimerActive:Bool = true;
				new FlxTimer().start(1, function(tmr:FlxTimer) {
					if (canDodge && dodgeTimerActive) {
						canDodge = false;
						GameOverSubstate.characterName = "deaths/bf-fleet-death";
						GameOverSubstate.deathSoundName = "Fleetway/laser_moment";
						if (boyfriend.animOffsets.exists('hurt')) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
						health = 0;
						doDeathCheck();
					}
				});
			
				FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
					if (FlxG.keys.justPressed.SPACE && canDodge) {
						canDodge = false;
						dodgeShi.animation.play('pressed');
			
						if (boyfriend.animOffsets.exists('dodge')) {
							boyfriend.playAnim('dodge', true);
							boyfriend.specialAnim = true;
						}
			
						new FlxTimer().start(0.5, function(tmr:FlxTimer) {
							trace("Sprite destroyed");
							remove(dodgeShi);
						});
						
						dodgeTimerActive = false;
					}
				});

			case 'Clear Popups':
				while(FatalPopup.popups.length>0)
					FatalPopup.popups[0].close();

			case 'Fatality Popup':
			var value:Int = Std.parseInt(value1);
			if (Math.isNaN(value) || value<1)
				value = 1;

			var type:Int = Std.parseInt(value2);
			if (Math.isNaN(type) || type<1)
				type = 1;
			for(idx in 0...value){
				doPopup(type);
			}

			case 'Window fucking moves':
				if (flValue1 == null) {
					IsWindowMoving = false;
					}
				else if (flValue1 < 1){
					IsWindowMoving = true;
					Xamount += flValue1;
				}

				if (flValue2 == null) {
					IsWindowMoving = false;
					}
				else if (flValue2 < 1){
					IsWindowMoving = true;
					Yamount += flValue2;
				}
			case 'Window fucking shakes':
			shakescreen();
			
			case 'Set Cam Follow':
    			if (value1 == "dad")
    			{
        			camFollow.setPosition(dad.getMidpoint().x, dad.getMidpoint().y);	
					isCameraOnForcedPos = true;			
    			}
    			else if (value1 == "bf")
    			{
        			camFollow.setPosition(boyfriend.getMidpoint().x, boyfriend.getMidpoint().y);	
					isCameraOnForcedPos = true;			
    			}
				else if (value1 == "reset")
					{
						isCameraOnForcedPos = false;		
						moveCameraSection();	
					}
    			else
    			{
    			    FlxG.log.warn('ERROR ("Set Cam Follow" Event) - Invalid character: ' + value1);
    			}
		}

		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime));
		callOnScripts('onEvent', [eventName, value1, value2, strumTime]);
	}

	function moveCameraSection(?sec:Null<Int>):Void {
		if(sec == null) sec = curSection;
		if(sec < 0) sec = 0;

		if(SONG.notes[sec] == null) return;

		if (gf != null && SONG.notes[sec].gfSection)
		{
			camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnScripts('onMoveCamera', ['gf']);
			return;
		}

		else if (boyfriend2 != null && SONG.notes[sec].bf2Section)
			{
				camFollow.setPosition(boyfriend2.getMidpoint().x, boyfriend2.getMidpoint().y);
				camFollow.x += boyfriend2.cameraPosition[0] + boyfriend2CameraOffset[0];
				camFollow.y += boyfriend2.cameraPosition[1] + boyfriend2CameraOffset[1];
				tweenCamIn();
				return;
			}

		else if (dad2 != null && SONG.notes[sec].dad2Section)
			{
				camFollow.setPosition(dad2.getMidpoint().x, dad2.getMidpoint().y);
				camFollow.x += dad2.cameraPosition[0] + opponent2CameraOffset[0];
				camFollow.y += dad2.cameraPosition[1] + opponent2CameraOffset[1];
				tweenCamIn();
				return;
			}

		var isDad:Bool = (SONG.notes[sec].mustHitSection != true);
		moveCamera(isDad);
		callOnScripts('onMoveCamera', [isDad ? 'dad' : 'boyfriend']);
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	public function tweenCamIn() {
		if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		updateTime = false;
		FlxG.sound.music.volume = 0;

		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();

		if(ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong()
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return false;
			}
		}

		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;
		


		var ret:Dynamic = callOnScripts('onEndSong', null, true);
		if(ret != LuaUtils.Function_Stop && !transitioning)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			#end
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return false;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					Mods.loadTopMod();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay')) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = Difficulty.getFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
				else
					{
						if (curSong == 'too-slow' || curSong == 'you-cant-run' || curSong == 'triple-trouble' || curSong == 'final-escape' || curSong == 'eye-to-eye') {
							trace('WENT BACK TO StoryMenuStateMain');
							Mods.loadTopMod();
							#if DISCORD_ALLOWED 
							DiscordClient.resetClientID(); 
							#end
				
							MusicBeatState.switchState(new StoryMenuStateMain());
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							changedDifficulty = false;
						} 
						else if (curSong == 'coulrophobia' || curSong == 'brokenheart' || curSong == 'goddess' || curSong == 'tribal') {
							trace('WENT BACK TO StoryMenuStateAlt');
							Mods.loadTopMod();
							#if DISCORD_ALLOWED 
							DiscordClient.resetClientID(); 
							#end
				
							MusicBeatState.switchState(new StoryMenuStateAlt());
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							changedDifficulty = false;
						} 
						else if (curSong == 'fatality') {
							try{
								Sys.command('${Sys.getCwd()}\\assets\\FatalError.exe');
							}catch(e:Dynamic){
								trace("A fatal error has ACTUALLY occured: " + e);
							}
				
							isFixedAspectRatio = false;
							FlxG.mouse.visible = false;
							FlxG.mouse.unload();							
							new FlxTimer().start(0.2, function(tmr:FlxTimer)
								{
									Sys.exit(0);
								});
						} 
						else {
							trace('WENT BACK TO MainMenuState');
							Mods.loadTopMod();
							#if DISCORD_ALLOWED 
							DiscordClient.resetClientID(); 
							#end
				
							MusicBeatState.switchState(new MainMenuState());
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							changedDifficulty = false;
					}
				}			
			transitioning = true;
		}
		return true;
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;
			invalidateNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	// Stores Ratings and Combo Sprites in a group
	public var comboGroup:FlxSpriteGroup;
	// Stores HUD Objects in a Group
	public var uiGroup:FlxSpriteGroup;
	// Stores Note Objects in a Group
	public var noteGroup:FlxTypedGroup<FlxBasic>;

	private function cachePopUpScore()
	{
		var uiPrefix:String = '';
		var uiSuffix:String = '';
		if (stageUI != "normal")
		{
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiSuffix = '-pixel';
		}

		for (rating in ratingsData)
			Paths.image(uiPrefix + rating.image + uiSuffix);
		for (i in 0...10)
			Paths.image(uiPrefix + 'num' + i + uiSuffix);
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		vocals.volume = 1;

		if (!ClientPrefs.data.comboStacking && comboGroup.members.length > 0) {
			for (spr in comboGroup) {
				spr.destroy();
				comboGroup.remove(spr);
			}
		}

		var placement:Float = FlxG.width * 0.35;
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.hits++;
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashData.disabled)
			spawnNoteSplashOnNote(note);

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var uiPrefix:String = "";
		var uiSuffix:String = '';
		var antialias:Bool = ClientPrefs.data.antialiasing;

		if (stageUI != "normal")
		{
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiSuffix = '-pixel';
			antialias = !isPixelStage;
		}

		rating.loadGraphic(Paths.image(uiPrefix + daRating.image + uiSuffix));
		rating.screenCenter();
		rating.x = placement - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.data.hideHud && showRating);
		rating.x += ClientPrefs.data.comboOffset[0];
		rating.y -= ClientPrefs.data.comboOffset[1];
		rating.antialiasing = antialias;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'combo' + uiSuffix));
		comboSpr.screenCenter();
		comboSpr.x = placement;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.data.hideHud && showCombo);
		comboSpr.x += ClientPrefs.data.comboOffset[0];
		comboSpr.y -= ClientPrefs.data.comboOffset[1];
		comboSpr.antialiasing = antialias;
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
		comboGroup.add(rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
			comboGroup.add(comboSpr);

		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'num' + Std.int(i) + uiSuffix));
			numScore.screenCenter();
			numScore.x = placement + (43 * daLoop) - 90 + ClientPrefs.data.comboOffset[2];
			numScore.y += 80 - ClientPrefs.data.comboOffset[3];

			if (!PlayState.isPixelStage) numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			else numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.data.hideHud;
			numScore.antialiasing = antialias;

			//if (combo >= 10 || combo == 0)
			if(showComboNum)
				comboGroup.add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{

		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);

		if (!controls.controllerMode)
		{
			#if debug
			//Prevents crash specifically on debug without needing to try catch shit
			@:privateAccess if (!FlxG.keys._keyListMap.exists(eventKey)) return;
			#end

			if(FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
		}
	}

	private function keyPressed(key:Int)
	{
		if(cpuControlled || paused || inCutscene || key < 0 || key >= playerStrums.length || !generatedMusic || endingSong || boyfriend.stunned) return;

		var ret:Dynamic = callOnScripts('onKeyPressPre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		// more accurate hit time for the ratings?
		var lastTime:Float = Conductor.songPosition;
		if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time;

		// obtain notes that the player can hit
		var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit;
			return n != null && canHit && !n.isSustainNote && n.noteData == key;
		});
		plrInputNotes.sort(sortHitNotes);

		var shouldMiss:Bool = !ClientPrefs.data.ghostTapping;

		if (plrInputNotes.length != 0) { // slightly faster than doing `> 0` lol
			var funnyNote:Note = plrInputNotes[0]; // front note

			if (plrInputNotes.length > 1) {
				var doubleNote:Note = plrInputNotes[1];

				if (doubleNote.noteData == funnyNote.noteData) {
					// if the note has a 0ms distance (is on top of the current note), kill it
					if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0)
						invalidateNote(doubleNote);
					else if (doubleNote.strumTime < funnyNote.strumTime)
					{
						// replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
						funnyNote = doubleNote;
					}
				}
			}
			goodNoteHit(funnyNote);
		}
		else if(shouldMiss)
		{
			callOnScripts('onGhostTap', [key]);
			noteMissPress(key);
		}

		// Needed for the  "Just the Two of Us" achievement.
		//									- Shadow Mario
		if(!keysPressed.contains(key)) keysPressed.push(key);

		//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
		Conductor.songPosition = lastTime;

		var spr:StrumNote = playerStrums.members[key];
		if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
		{
			spr.playAnim('pressed');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyPress', [key]);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);
		if(!controls.controllerMode && key > -1) keyReleased(key);
	}

	private function keyReleased(key:Int)
	{
		if(cpuControlled || !startedCountdown || paused || key < 0 || key >= playerStrums.length) return;

		var ret:Dynamic = callOnScripts('onKeyReleasePre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		var spr:StrumNote = playerStrums.members[key];
		if(spr != null)
		{
			spr.playAnim('static');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyRelease', [key]);
	}

	public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...arr.length)
			{
				var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
				for (noteKey in note)
					if(key == noteKey)
						return i;
			}
		}
		return -1;
	}

	// Hold notes
	private function keysCheck():Void
	{
		// HOLDING
		var holdArray:Array<Bool> = [];
		var pressArray:Array<Bool> = [];
		var releaseArray:Array<Bool> = [];
		for (key in keysArray)
		{
			holdArray.push(controls.pressed(key));
			if(controls.controllerMode)
			{
				pressArray.push(controls.justPressed(key));
				releaseArray.push(controls.justReleased(key));
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(controls.controllerMode && pressArray.contains(true))
			for (i in 0...pressArray.length)
				if(pressArray[i] && strumsBlocked[i] != true)
					keyPressed(i);

		if (startedCountdown && !inCutscene && !boyfriend.stunned && generatedMusic)
		{
			if (notes.length > 0) {
				for (n in notes) { // I can't do a filter here, that's kinda awesome
					var canHit:Bool = (n != null && !strumsBlocked[n.noteData] && n.canBeHit
						&& n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit);

					if (guitarHeroSustains)
						canHit = canHit && n.parent != null && n.parent.wasGoodHit;

					if (canHit && n.isSustainNote) {
						var released:Bool = !holdArray[n.noteData];

						if (!released)
							goodNoteHit(n);
					}
				}
			}

			if (!holdArray.contains(true) || endingSong)
			{
				playerDance();
					if(SONG.isBf2)
					{
						player2Dance();
					}		
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if((controls.controllerMode || strumsBlocked.contains(true)) && releaseArray.contains(true))
			for (i in 0...releaseArray.length)
				if(releaseArray[i] || strumsBlocked[i] == true)
					keyReleased(i);
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
				invalidateNote(note);
		});

		noteMissCommon(daNote.noteData, daNote);
		var result:Dynamic = callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('noteMiss', [daNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.data.ghostTapping) return; //fuck it

		noteMissCommon(direction);
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		callOnScripts('noteMissPress', [direction]);
	}

	function noteMissCommon(direction:Int, note:Note = null)
	{
		// score and data
		var subtract:Float = 0.05;
		if(note != null) subtract = note.missHealth;

		// GUITAR HERO SUSTAIN CHECK LOL!!!!
		if (note != null && guitarHeroSustains && note.parent == null) {
			if(note.tail.length > 0) {
				note.alpha = 0.35;
				for(childNote in note.tail) {
					childNote.alpha = note.alpha;
					childNote.missed = true;
					childNote.canBeHit = false;
					childNote.ignoreNote = true;
					childNote.tooLate = true;
				}
				note.missed = true;
				note.canBeHit = false;

				//subtract += 0.385; // you take more damage if playing with this gameplay changer enabled.
				// i mean its fair :p -Crow
				subtract *= note.tail.length + 1;
				// i think it would be fair if damage multiplied based on how long the sustain is -Tahir
			}

			if (note.missed)
				return;
		}
		if (note != null && guitarHeroSustains && note.parent != null && note.isSustainNote) {
			if (note.missed)
				return;

			var parentNote:Note = note.parent;
			if (parentNote.wasGoodHit && parentNote.tail.length > 0) {
				for (child in parentNote.tail) if (child != note) {
					child.missed = true;
					child.canBeHit = false;
					child.ignoreNote = true;
					child.tooLate = true;
				}
			}
		}

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			opponentVocals.volume = 0;
			doDeathCheck(true);
		}

		if(!note.noMissAnimation) {
			switch(note.noteType) {
				case 'Static Note': //Static note when missed, add static         
					var staticscreen:FlxSprite;
					staticscreen = new FlxSprite(0, 0);
					staticscreen.camera = camHUD;
					staticscreen.frames = Paths.getSparrowAtlas('statix');
					staticscreen.animation.addByPrefix('statix', "statix", 24);
					staticscreen.animation.play('statix');
					staticscreen.scale.set(4.5, 4.5);
					staticscreen.screenCenter(XY);
					staticscreen.alpha = 1;
					FlxG.sound.play(Paths.sound('hitStatic1'));
					add(staticscreen);
					new FlxTimer().start(0.2, function(tmr:FlxTimer)
						{
							staticscreen.alpha = 0;
						});
					}
			}

		var lastCombo:Int = combo;
		combo = 0;

		health -= subtract * healthLoss;
		if(!practiceMode) songScore -= 10;
		if(!endingSong) songMisses++;
		totalPlayed++;
		RecalculateRating(true);

		// play character anims
		var char:Character = boyfriend;
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;
		if((note != null && note.dad2Note) || (SONG.notes[curSection] != null && SONG.notes[curSection].dad2Section)) char = dad2;
		if((note != null && note.bf2Note) || (SONG.notes[curSection] != null && SONG.notes[curSection].bf2Section)) char = boyfriend2;

		char.recalculateDanceIdle();

		if(char != null && (note == null || !note.noMissAnimation) && char.hasMissAnimations)
		{
			var suffix:String = '';
			if(note != null) suffix = note.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + suffix;
			char.playAnim(animToPlay, true);

			if(char != gf && lastCombo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}

			if((note != null && note.dadsDuetNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].dadsDuetSection))
				{
					dad.playAnim(animToPlay, true);
					dad2.playAnim(animToPlay, true);
				}

			if((note != null && note.bfsDuetNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].bfsDuetSection))
				{
					boyfriend.playAnim(animToPlay, true);
					boyfriend2.playAnim(animToPlay, true);
				}
		}
		vocals.volume = 0;
	}

	function opponentNoteHit(note:Note):Void
	{
		var result:Dynamic = callOnLuas('opponentNoteHitPre', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHitPre', [note]);

		if (songName != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection && !SONG.notes[curSection].dad2Section && !SONG.notes[curSection].bf2Section && !SONG.notes[curSection].dadsDuetSection && !SONG.notes[curSection].bfsDuetSection)
					altAnim = '-alt';
			

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + altAnim;
			if(note.gfNote) char = gf;
			if(note.dad2Note) char = dad2;
			if(note.bf2Note) char = boyfriend2;
			if(note.dadsDuetNote)
				{
					dad.playAnim(animToPlay, true);
					dad2.playAnim(animToPlay, true);
				}
	
			if(note.bfsDuetNote)
			{
				boyfriend.playAnim(animToPlay, true);
				boyfriend2.playAnim(animToPlay, true);
			}
			
			char.recalculateDanceIdle();

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
				char.recalculateDanceIdle();
			}
		}

		if(opponentVocals.length <= 0) vocals.volume = 1;
		strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		note.hitByOpponent = true;
		
		var result:Dynamic = callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHit', [note]);

		if (!note.isSustainNote) invalidateNote(note);
	}

	public function goodNoteHit(note:Note):Void
	{
		if(note.wasGoodHit) return;
		if(cpuControlled && note.ignoreNote) return;

		var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;

		var result:Dynamic = callOnLuas('goodNoteHitPre', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHitPre', [note]);

		note.wasGoodHit = true;

		if (ClientPrefs.data.hitsoundVolume > 0 && !note.hitsoundDisabled)
			FlxG.sound.play(Paths.sound(note.hitsound), ClientPrefs.data.hitsoundVolume);

		if(note.hitCausesMiss) {
			if(!note.noMissAnimation) {
				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animOffsets.exists('hurt')) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}

					case 'Phantom Note': //Phantom note
					if(boyfriend.animOffsets.exists('hurt')) {
						boyfriend.playAnim('hurt', true);
						boyfriend.specialAnim = true;
	
						healthDrop += 0.00025;
						dropTime = 10;
					}
				}
			}

			noteMiss(note);
			if(!note.noteSplashData.disabled && !note.isSustainNote) spawnNoteSplashOnNote(note);
			if(!note.isSustainNote) invalidateNote(note);
			return;
		}

		if(!note.noAnimation) {
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];

			var char:Character = boyfriend;
			var animCheck:String = 'hey';
			if(note.gfNote)
			{
				char = gf;
				animCheck = 'cheer';
				char.recalculateDanceIdle();
			}

			if(note.dad2Note)
			{
				char = dad2;
				animCheck = 'hey';
				char.recalculateDanceIdle();
			}

			if(note.bf2Note)
			{
				char = boyfriend2;
				animCheck = 'hey';
				char.recalculateDanceIdle();
			}

			if(note.dadsDuetNote)
				{
					dad.playAnim(animToPlay, true);
					dad2.playAnim(animToPlay, true);
				}
	
			if(note.bfsDuetNote)
			{
				boyfriend.playAnim(animToPlay, true);
				boyfriend2.playAnim(animToPlay, true);
			}

			if(char != null)
			{
				char.playAnim(animToPlay + note.animSuffix, true);
				char.holdTimer = 0;

				if(note.noteType == 'Hey!') {
					if(char.animOffsets.exists(animCheck)) {
						char.playAnim(animCheck, true);
						char.specialAnim = true;
						char.heyTimer = 0.6;
					}
				}
			}
		}

		if(!cpuControlled)
		{
			var spr = playerStrums.members[note.noteData];
			if(spr != null) spr.playAnim('confirm', true);
		}
		else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		vocals.volume = 1;

		if (!note.isSustainNote)
		{
			combo++;
			if(combo > 9999) combo = 9999;
			popUpScore(note);
		}
		var gainHealth:Bool = true; // prevent health gain, *if* sustains are treated as a singular note
		if (guitarHeroSustains && note.isSustainNote) gainHealth = false;
		if (gainHealth) health += note.hitHealth * healthGain;

		var result:Dynamic = callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHit', [note]);

		if(!note.isSustainNote) invalidateNote(note);
	}

	public function invalidateNote(note:Note):Void {
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null)
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, note);
		grpNoteSplashes.add(splash);
	}

	override function destroy() {
		#if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				script.call('onDestroy');
				script.destroy();
			}

		while (hscriptArray.length > 0)
			hscriptArray.pop();
		#end

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		FlxG.animationTimeScale = 1;
		#if FLX_PITCH FlxG.sound.music.pitch = 1; #end
		backend.NoteTypesConfig.clearNoteTypesData();
		instance = null;
		super.destroy();
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		if (SONG.needsVoices && FlxG.sound.music.time >= -ClientPrefs.data.noteOffset)
		{
			var timeSub:Float = Conductor.songPosition - Conductor.offset;
			var syncTime:Float = 20 * playbackRate;
			if (Math.abs(FlxG.sound.music.time - timeSub) > syncTime ||
			(vocals.length > 0 && Math.abs(vocals.time - timeSub) > syncTime) ||
			(opponentVocals.length > 0 && Math.abs(opponentVocals.time - timeSub) > syncTime))
			{
				resyncVocals();
			}
		}

		super.stepHit();

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		if(SONG.isBf2)
			iconP3.scale.set(1.2, 1.2);
		if(SONG.isDad2)
			iconP4.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if(SONG.isBf2)
			iconP3.updateHitbox();
		if(SONG.isDad2)
			iconP4.updateHitbox();

		characterBopper(curBeat);

		super.beatHit();

		if (curBeat % 4 == 0 && sunkerTimebarFuckery)
			{
				var prevInt:Int = sunkerTimebarNumber;
	
				sunkerTimebarNumber = FlxG.random.int(1, 9, [sunkerTimebarNumber]);
	
				switch(sunkerTimebarNumber){
					case 1:
						timeBar.setColors(0xFFFF0000);
					case 2:
						timeBar.setColors(0xFF1BFF00);
					case 3:
						timeBar.setColors(0xFF00C9FF);
					case 4:
						timeBar.setColors(0xFFFC00FF);
					case 5:
						timeBar.setColors(0xFFFFD100);
					case 6:
						timeBar.setColors(0xFF0011FF);
					case 7:
						timeBar.setColors(0xFFC9C9C9);
					case 8:
						timeBar.setColors(0xFF00FFE3);
					case 9:
						timeBar.setColors(0xFF6300FF);
				}
			}

		lastBeatHit = curBeat;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

	public function characterBopper(beat:Int):Void
	{
		if (gf != null && beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.getAnimationName().startsWith('sing') && !gf.stunned)
			gf.dance();
		if (boyfriend != null && beat % boyfriend.danceEveryNumBeats == 0 && !boyfriend.getAnimationName().startsWith('sing') && !boyfriend.stunned)
			boyfriend.dance();
		if (dad != null && beat % dad.danceEveryNumBeats == 0 && !dad.getAnimationName().startsWith('sing') && !dad.stunned)
			dad.dance();
		if (SONG.isBf2)
			{		
				if (boyfriend2 != null && beat % boyfriend2.danceEveryNumBeats == 0 && !boyfriend2.getAnimationName().startsWith('sing') && !boyfriend2.stunned)			
					boyfriend2.dance();
			}
		if (SONG.isDad2)
			{		
				if (dad2 != null && beat % dad2.danceEveryNumBeats == 0 && !dad2.getAnimationName().startsWith('sing') && !dad2.stunned)
					dad2.dance();
			}
	}

	public function playerDance():Void
	{
		var anim:String = boyfriend.getAnimationName();
		if(boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.sound.music.pitch #end) * boyfriend.singDuration && anim.startsWith('sing') && !anim.endsWith('miss'))
			boyfriend.dance();
	}

	public function player2Dance():Void
		{
			if (SONG.isBf2)
				{	
					var anim:String = boyfriend2.getAnimationName();
					if(boyfriend2.holdTimer > Conductor.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.sound.music.pitch #end) * boyfriend2.singDuration && anim.startsWith('sing') && !anim.endsWith('miss'))
						boyfriend2.dance();
				}
		}

	override function sectionHit()
	{
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.data.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = SONG.notes[curSection].bpm;
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}
			setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnScripts('altAnim', SONG.notes[curSection].altAnim);
			setOnScripts('gfSection', SONG.notes[curSection].gfSection);
			setOnScripts('bf2Section', SONG.notes[curSection].bf2Section);
			setOnScripts('dad2Section', SONG.notes[curSection].dad2Section);
			setOnScripts('dadsDuetSection', SONG.notes[curSection].dadsDuetSection);
			setOnScripts('bfsDuetSection', SONG.notes[curSection].bfsDuetSection);
		}
		super.sectionHit();

		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getSharedPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getSharedPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad))
		{
			if (SScript.global.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		try
		{
			var newScript:HScript = new HScript(null, file);
			if(newScript.parsingException != null)
			{
				addTextToDebug('ERROR ON LOADING: ${newScript.parsingException.message}', FlxColor.RED);
				newScript.destroy();
				return;
			}

			hscriptArray.push(newScript);
			if(newScript.exists('onCreate'))
			{
				var callValue = newScript.call('onCreate');
				if(!callValue.succeeded)
				{
					for (e in callValue.exceptions)
					{
						if (e != null)
						{
							var len:Int = e.message.indexOf('\n') + 1;
							if(len <= 0) len = e.message.length;
								addTextToDebug('ERROR ($file: onCreate) - ${e.message.substr(0, len)}', FlxColor.RED);
						}
					}

					newScript.destroy();
					hscriptArray.remove(newScript);
					trace('failed to initialize tea interp!!! ($file)');
				}
				else trace('initialized tea interp successfully: $file');
			}

		}
		catch(e)
		{
			var len:Int = e.message.indexOf('\n') + 1;
			if(len <= 0) len = e.message.length;
			addTextToDebug('ERROR - ' + e.message.substr(0, len), FlxColor.RED);
			var newScript:HScript = cast (SScript.global.get(file), HScript);
			if(newScript != null)
			{
				newScript.destroy();
				hscriptArray.remove(newScript);
			}
		}
	}
	#end

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;
		for(i in 0...len) {
			var script:HScript = hscriptArray[i];
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var myValue:Dynamic = null;
			try {
				var callValue = script.call(funcToCall, args);
				if(!callValue.succeeded)
				{
					var e = callValue.exceptions[0];
					if(e != null)
					{
						var len:Int = e.message.indexOf('\n') + 1;
						if(len <= 0) len = e.message.length;
						addTextToDebug('ERROR (${callValue.calledFunction}) - ' + e.message.substr(0, len), FlxColor.RED);
					}
				}
				else
				{
					myValue = callValue.returnValue;
					if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
					{
						returnVal = myValue;
						break;
					}

					if(myValue != null && !excludeValues.contains(myValue))
						returnVal = myValue;
				}
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			if(!instancesExclude.contains(variable))
				instancesExclude.push(variable);
			script.set(variable, arg);
		}
		#end
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = opponentStrums.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
		if(ret != LuaUtils.Function_Stop)
		{
			ratingName = '?';
			if(totalPlayed != 0) //Prevent divide by 0
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				if(ratingPercent < 1)
					for (i in 0...ratingStuff.length-1)
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
			}
			fullComboFunction();
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce
		setOnScripts('rating', ratingPercent);
		setOnScripts('ratingName', ratingName);
		setOnScripts('ratingFC', ratingFC);
	}

	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.data.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/'))
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else frag = null;

			if(FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else vert = null;

			if(found)
			{
				runtimeShaders.set(name, [frag, vert]);
				//trace('Found shader $name!');
				return true;
			}
		}
			#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
			addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
			#else
			FlxG.log.warn('Missing shader $name .frag AND .vert files!');
			#end
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}
	#end
	
    public function switchToState(state:MusicBeatState):Void {
        // DO CLEAN-UP HERE!!
        if (curSong == 'fatality') {
			FlxG.mouse.visible = true;
			FlxG.mouse.unload();
			FlxG.log.add("Sexy mouse cursor " + Paths.image("fatal_mouse_cursor"));
			FlxG.mouse.load(Paths.image("fatal_mouse_cursor").bitmap, 1.5, 0);
        }

        if (isFixedAspectRatio) {
            Application.current.window.resizable = false; // Make window non-resizable
            FlxG.scaleMode = new RatioScaleMode(false); // False for no letterboxing
            FlxG.resizeGame(1280, 720); // Set game size
            Application.current.window.width = 1280; // Resize window width
            Application.current.window.height = 720; // Resize window height

        }

        FlxG.switchState(state); // Switch state using FlxG.switchState
    }

	function updateSonicScore(){
		var seperatedScore:Array<String> = Std.string(songScore).split("");
		if(seperatedScore.length<scoreNumbers.length){
			for(idx in seperatedScore.length...scoreNumbers.length){
				if(hudStyle == 'chaotix' || hudStyle == 'sonic3' || hudStyle == 'soniccd' || hudStyle == 'sJam'){
					seperatedScore.unshift('');
				}else{
					seperatedScore.unshift('0');
				}
			}
		}
		if(seperatedScore.length>scoreNumbers.length)
			seperatedScore.resize(scoreNumbers.length);

		for(idx in 0...seperatedScore.length){
			if(seperatedScore[idx]!='' || idx==scoreNumbers.length-1){
				var val = Std.parseInt(seperatedScore[idx]);
				if(Math.isNaN(val))val=0;
				scoreNumbers[idx].number = val;
				scoreNumbers[idx].visible=true;
			}else
				scoreNumbers[idx].visible=false;

		}
	}
	
	function updateSonicMisses(){
		var seperatedScore:Array<String> = Std.string(songMisses).split("");
		if(seperatedScore.length<missNumbers.length){
			for(idx in seperatedScore.length...missNumbers.length){
				if(hudStyle == 'chaotix' || hudStyle == 'sonic3' || hudStyle == 'soniccd' || hudStyle == 'sJam'){
					seperatedScore.unshift('');
				}else{
					seperatedScore.unshift('0');
				}
			}
		}
		if(seperatedScore.length>missNumbers.length)
			seperatedScore.resize(missNumbers.length);

		for(idx in 0...seperatedScore.length){
			if(seperatedScore[idx]!='' || idx==missNumbers.length-1){
				var val = Std.parseInt(seperatedScore[idx]);
				if(Math.isNaN(val))val=0;
				missNumbers[idx].number = val;
				missNumbers[idx].visible=true;
			}else
				missNumbers[idx].visible=false;

		}
	}

	public function updateSonicTime(elapsed:Float):Void
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			songPercent = (curTime / songLength);
		
			// Convert songPercent to milliseconds (songPercent should be multiplied by songLength to get proper time)
			var totalSeconds:Int = Std.int(Math.floor((curTime / 1000)));  // Casting to Int
			var minutes:Int = Std.int(Math.floor(totalSeconds / 60));      // Casting to Int
			var seconds:Int = totalSeconds % 60;
		
			minNumber.number = minutes;
		
			secondNumberA.number = Std.int(Math.floor(seconds / 10));      // Casting to Int
			secondNumberB.number = seconds % 10;
		
			// If Chaotix or sJam HUD is being used, update milliseconds as well
			if(hudStyle == 'chaotix' || hudStyle == 'sJam') {
				var totalMilliseconds:Int = Std.int(curTime % 1000);  // Cast to Int for proper milliseconds
				var milliseconds:Int = Std.int(Math.floor(totalMilliseconds / 10));  // Divide to get two digits and cast to Int
				millisecondNumberA.number = Std.int(Math.floor(milliseconds / 10));
				millisecondNumberB.number = milliseconds % 10;
			}
		}	
	function removeStatics()
		{
			playerStrums.forEach(function(todel:StrumNote)
			{
				playerStrums.remove(todel);
				todel.destroy();
			});
			opponentStrums.forEach(function(todel:StrumNote)
			{
				opponentStrums.remove(todel);
				todel.destroy();
			});
			strumLineNotes.forEach(function(todel:StrumNote)
			{
				strumLineNotes.remove(todel);
				todel.destroy();
			});
		}	
	function majinSaysFuck(numb:Int):Void
		{
			switch(numb)
			{
				case 4:
					FlxTween.tween(camHUD, {alpha: 0}, 0.5, {ease: FlxEase.quartInOut});

					var three:FlxSprite = new FlxSprite().loadGraphic(Paths.image('majinthree'));
					three.scrollFactor.set();
					three.updateHitbox();
					three.screenCenter();
					three.y -= 100;
					three.alpha = 0.5;
					three.cameras = [camOther];
					add(three);
					FlxTween.tween(three, {y: three.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							three.destroy();
						}
					});
				case 3:
					var two:FlxSprite = new FlxSprite().loadGraphic(Paths.image('majintwo'));
					two.scrollFactor.set();
					two.screenCenter();
					two.y -= 100;
					two.alpha = 0.5;
					two.cameras = [camOther];
					add(two);
					FlxTween.tween(two, {y: two.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							two.destroy();
						}
					});
				case 2:
					var one:FlxSprite = new FlxSprite().loadGraphic(Paths.image('majinone'));
					one.scrollFactor.set();
					one.screenCenter();
					one.y -= 100;
					one.alpha = 0.5;
					one.cameras = [camOther];
					add(one);
					FlxTween.tween(one, {y: one.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeOut,
						onComplete: function(twn:FlxTween)
						{
							one.destroy();
						}
					});
				case 1:
					var gofun:FlxSprite = new FlxSprite().loadGraphic(Paths.image('majingo'));
					gofun.scrollFactor.set();
					gofun.updateHitbox();
					gofun.screenCenter();
					gofun.y -= 100;
					gofun.alpha = 0.5;
					add(gofun);
					FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.quartInOut});

					FlxTween.tween(gofun, {y: gofun.y + 100, alpha: 0, "scale.x": 1.05, "scale.y": 1.05}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							gofun.destroy();
						}
					});
			}
		}

	function doPopup(type:Int)
		{
			var popup = new FatalPopup(0, 0, type);
			var popuppos:Array<Int> = [getRandomInt(0, Std.int(FlxG.width - popup.width)), getRandomInt(0, Std.int(FlxG.height - popup.height))];
			popup.x = popuppos[0];
			popup.y = popuppos[1];
			popup.cameras = [camOther];
			add(popup);
		}
	
	function managePopups(){
		if(FlxG.mouse.justPressed){
			trace("click :)");
			for(idx in 0...FatalPopup.popups.length){
				var realIdx = (FatalPopup.popups.length - 1) - idx;
				var popup = FatalPopup.popups[realIdx];
				var hitShit:Bool=false;
				for(camera in popup.cameras){
					@:privateAccess
					var hitOK = popup.clickDetector.overlapsPoint(FlxG.mouse.getWorldPosition(camera, popup.clickDetector._point), true, camera);
					if (hitOK){
						popup.close();
						hitShit=true;
						break;
					}
				}
				if(hitShit)break;
			}
		}
	}

	function getRandomInt(min:Int, max:Int):Int {
		return Math.floor(Math.random() * (max - min)) + min;
	}

	function windowGoBack()
		{
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				var xLerp:Float = FlxMath.lerp(windowX, Lib.application.window.x, 0.95);
				var yLerp:Float = FlxMath.lerp(windowY, Lib.application.window.y, 0.95);
				Lib.application.window.move(Std.int(xLerp), Std.int(yLerp));
			}, 20);
		}
	function shakescreen()
		{
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				Lib.application.window.move(Lib.application.window.x + FlxG.random.int(-10, 10), Lib.application.window.y + FlxG.random.int(-8, 8));
			}, 50);
		}
}