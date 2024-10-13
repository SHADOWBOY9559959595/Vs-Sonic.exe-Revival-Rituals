package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import backend.Song;

class MainMenuState extends MusicBeatState
{
    public static var psychEngineVersion:String = '0.7.3'; // This is also used for Discord RPC
    public static var curSelected:Int = 0;

    var menuItems:FlxTypedGroup<FlxSprite>;

    var optionShit:Array<String> = [
        'story_mode',
        'encore',
        'freeplay',
        'options',
        'extras'
    ];

    var magenta:FlxSprite;
    var camFollow:FlxObject;
    var char:FlxSprite;

    var arrowLeft:FlxSprite;    
    var arrowRight:FlxSprite;

    // New variables for week selection
    var isMainWeek:Bool = true;
    var selectedWeekSprite:FlxSprite;

    override function create()
    {
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Choosing Their Fate", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		//NewBg

		var bg:FlxSprite;
		bg = new FlxSprite().setFrames(Paths.getSparrowAtlas('MainMenuState/bg'));
		bg.animation.addByPrefix('bg', 'bg', 25, true);
		bg.animation.play('bg');
		add(bg);
		bg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		bg.updateHitbox();
		bg.screenCenter(X);
		bg.screenCenter(Y);

		switch (FlxG.random.int(1, 10))
			{
				case 1:
					char = new FlxSprite().loadGraphic(Paths.image('MainMenuState/Arts/xeno-1'));
					char.scrollFactor.set();
					 char.flipX = true;
					add(char);
				case 2:
					char = new FlxSprite().loadGraphic(Paths.image('MainMenuState/Arts/xeno-2'));
					char.scrollFactor.set();
					 char.flipX = true;
					add(char);
				case 3:
					char = new FlxSprite().loadGraphic(Paths.image('MainMenuState/Arts/educator'));
					char.scrollFactor.set();
					 char.flipX = true;
					add(char);
				case 4:
					char = new FlxSprite().loadGraphic(Paths.image('MainMenuState/Arts/mono'));
					char.scrollFactor.set();
					 char.flipX = true;
					add(char);
				case 5:
					char = new FlxSprite().loadGraphic(Paths.image('MainMenuState/Arts/sanic'));
					char.scrollFactor.set();
					 char.flipX = true;
					add(char);
				case 6:
					char = new FlxSprite().loadGraphic(Paths.image('MainMenuState/Arts/sonichu'));
					char.scrollFactor.set();
					 char.flipX = true;
					add(char);
				case 7:
					char = new FlxSprite().loadGraphic(Paths.image('MainMenuState/Arts/x-terion'));
					char.scrollFactor.set();
					 char.flipX = true;
					add(char);
				case 8:
					char = new FlxSprite().loadGraphic(Paths.image('MainMenuState/Arts/xterion-1'));
					char.scrollFactor.set();
					 char.flipX = true;
					add(char);
				case 9:
					char = new FlxSprite().loadGraphic(Paths.image('MainMenuState/Arts/xterion-2'));
					char.scrollFactor.set();
					 char.flipX = true;
					add(char);
				case 10:
					char = new FlxSprite().loadGraphic(Paths.image('MainMenuState/Arts/man'));
					char.scrollFactor.set();
					 char.flipX = true;
					add(char);
			}	

		var bar:FlxSprite;
		bar = new FlxSprite().loadGraphic(Paths.image('MainMenuState/bar'));
		bar.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		bar.updateHitbox();
		bar.screenCenter(X);
		bar.screenCenter(Y);
		bar.scrollFactor.set();
		add(bar);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('MainMenuState/buttons/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if (optionShit.length < 6)
				scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.updateHitbox();
			menuItem.screenCenter();
		switch (i) {
			case 0: menuItem.setPosition(170, 200);
			case 1: menuItem.setPosition(140, 300);
			case 2: menuItem.setPosition(110, 400);
			case 3: menuItem.setPosition(80, 500);
			case 4: menuItem.setPosition(50, 600);
			}
		}

        // Initialize the week selection sprite
        selectedWeekSprite = new FlxSprite();
        updateWeekSprite();
        add(selectedWeekSprite);

        // Initialize the arrows
        arrowLeft = new FlxSprite().setFrames(Paths.getSparrowAtlas('MainMenuState/arrowLeft'));
        arrowLeft.animation.addByPrefix('idle', "arrowLeft Static");
        arrowLeft.animation.addByPrefix('pressed', "arrowLeft Selected");
		arrowLeft.x +=44;
        arrowLeft.animation.play('idle');        
        add(arrowLeft);

        arrowRight = new FlxSprite().setFrames(Paths.getSparrowAtlas('MainMenuState/arrowRight'));
        arrowRight.animation.addByPrefix('idle', "arrowRight Static");
        arrowRight.animation.addByPrefix('pressed', "arrowRight Selected");
		arrowRight.x +=44;
        arrowRight.animation.play('idle');            
        add(arrowRight);

        super.create();

        FlxG.camera.follow(camFollow, null, 9);
    }

	var selectedSomethin:Bool = false;

    override function update(elapsed:Float)
    {
        // Update menu item selection
        menuItems.members[curSelected].animation.play('selected');    

        if (!selectedSomethin)
        {
            if (controls.UI_UP_P)
                changeItem(-1);

            if (controls.UI_DOWN_P)
                changeItem(1);

            // Handle left and right arrow key presses for week selection
            if (controls.UI_LEFT_P && curSelected == 0) // Only for 'story_mode'
            {
                isMainWeek = true;
                updateWeekSprite();
                arrowLeft.animation.play('pressed');
				FlxG.sound.play(Paths.sound('cancelMenu'));
                new FlxTimer().start(0.2, function(tmr:FlxTimer)
                {
                    arrowLeft.animation.play('idle');
                });
            }

            if (controls.UI_RIGHT_P && curSelected == 0) // Only for 'story_mode'
            {
                isMainWeek = false;
                updateWeekSprite();
                arrowRight.animation.play('pressed');
				FlxG.sound.play(Paths.sound('cancelMenu'));
                new FlxTimer().start(0.2, function(tmr:FlxTimer)
                {
                    arrowRight.animation.play('idle');
                });
            }

            if (controls.ACCEPT)
            {
                FlxG.sound.play(Paths.sound('confirmMenu'));
                selectedSomethin = true;

                if (optionShit[curSelected] == 'story_mode')
                {
					FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
						{
                    		if (isMainWeek)
                        		MusicBeatState.switchState(new StoryMenuStateMain());
                    		else
                        		MusicBeatState.switchState(new StoryMenuStateAlt());
							
						});
                }
                else
                {
					selectedSomethin = true;

					FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						switch (optionShit[curSelected])
						{
							case 'encore':
								MusicBeatState.switchState(new EncoreState());
							case 'freeplay':
								MusicBeatState.switchState(new FreeplayState());
							case 'options':
								MusicBeatState.switchState(new OptionsState());
								OptionsState.onPlayState = false;
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									PlayState.stageUI = 'normal';
								}
							case 'extras':
								MusicBeatState.switchState(new FreeplayState());
						}
					});
                }
            }
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
        }

        super.update(elapsed);
    }

    // Function to update the week sprite based on the current selection
    function updateWeekSprite()
    {
        if (isMainWeek)
            selectedWeekSprite.loadGraphic(Paths.image('MainMenuState/MainWeek'));
        else
            selectedWeekSprite.loadGraphic(Paths.image('MainMenuState/AltWeek'));

		selectedWeekSprite.scale.set(0.25, 0.25);
        selectedWeekSprite.screenCenter(X);
		selectedWeekSprite.screenCenter(Y);
		selectedWeekSprite.x -=300;
		selectedWeekSprite.y -=260;        
    }

    function changeItem(huh:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        menuItems.members[curSelected].animation.play('idle');
        menuItems.members[curSelected].updateHitbox();

        curSelected += huh;

        if (curSelected >= menuItems.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = menuItems.length - 1;

        menuItems.members[curSelected].animation.play('selected');
        menuItems.members[curSelected].centerOffsets();
    }
}
