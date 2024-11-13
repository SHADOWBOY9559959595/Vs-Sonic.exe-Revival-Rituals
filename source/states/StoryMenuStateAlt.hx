package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import backend.Song;
import backend.WeekData;
import states.MainMenuState;

class StoryMenuStateAlt extends MusicBeatState
{
    public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

    var weekNames:Array<String> = ['coulrophobia', 'brokenheart', 'goddess', 'tribal']; // Add any weeks you want here.
    
    // Songs for each week
    var coulrophobia:Array<String> = ['coulrophobia'];
    var brokenheart:Array<String> = ['broken-heart'];
    var goddess:Array<String> = ['goddess'];
    var tribal:Array<String> = ['tribal'];

    // Other variables
    var weekSelec:Int = 0;
    var songSelec:Int = 0;
    var curSub:String = 'weeks';
    var startX:Float = 80;
    var startY:Float = 190;
    var moreY:Float = 0;
    var defPos:Float;
    var defTY:Float = 320;
    var textY:Float = 0;
    var addTextY:Float = 0;

    var bg:FlxSprite;
    var weekSprites:Array<FlxSprite> = [];

    var staticscreen:FlxSprite;
    var bf:FlxSprite;
    var yellowBOX:FlxSprite;
	var redBOX:FlxSprite;
    var greyBOX:FlxSprite;
    var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var leftArrow2:FlxSprite;
	var rightArrow2:FlxSprite;
    var lock:FlxSprite;
    

    public static var vocals:FlxSound = null;

    function capitalizeFirstLetter(text:String):String {
        if (text.length == 0) return text;
        return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();
    }

	override public function create():Void
		{
			super.create();
		
			moreY = 0;
			addTextY = 0;
			weekSelec = 0;
			songSelec = 0;
			curSub = 'weeks';
		
            var bg:FlxSprite;
            // Create a new FlxSprite and set its frames using the Sparrow Atlas
            bg = new FlxSprite().setFrames(Paths.getSparrowAtlas('SMMStatic'));
            // Add the animation by prefix
            bg.animation.addByPrefix('SMMStatic', 'SMMStatic', 25, true);
            // Play the animation
            bg.animation.play('SMMStatic');
            bg.antialiasing = ClientPrefs.data.antialiasing;
            // Add the sprite to the state
            add(bg);
            bg.scale.set(1, 1); // Customize the scale (1.5x for both width and height), It will work, ignore visual studio, this is working ok, fuck visual sutdio
            bg.updateHitbox();
            bg.screenCenter(X);
            bg.x += 0; // Adjust the x-offset
            bg.y -= 0; // Adjust the y-offset

            greyBOX = new FlxSprite(0, 0).loadGraphic(Paths.image('greybox'));
            bg.alpha = 1;
            greyBOX.antialiasing = true;
            greyBOX.setGraphicSize(Std.int(bg.width));
            greyBOX.updateHitbox();
            add(greyBOX);		
            
			// Create week sprites horizontally
			var spriteWidth:Float = 0;
			var padding:Float = 100;
			var totalWidth:Float = 0;

			for (i in 0...weekNames.length)
			{
				var weekSprite = new FlxSprite(startX + i * (spriteWidth + padding), startY).loadGraphic(Paths.image('smstuff/' + weekNames[i]));
				weekSprite.scrollFactor.set();
				weekSprite.screenCenter(X);
				add(weekSprite);
				weekSprites.push(weekSprite);
				weekSprite.scale.set(0.27, 0.27); // Set default smaller scale
				weekSprite.y -= 370; // Adjust the y-offset
                weekSprite.x -= 10; // Adjust the y-offset
			}
	
		
			defPos = weekSprites[0].x;

            staticscreen = new FlxSprite(450, 0);
            staticscreen.frames = Paths.getSparrowAtlas('screenstatic');
            staticscreen.animation.addByPrefix('screenstaticANIM', "screenSTATIC", 24);
            staticscreen.animation.play('screenstaticANIM');
            staticscreen.y += 79;
            staticscreen.alpha = 0.3;
            staticscreen.antialiasing = true;
            staticscreen.setGraphicSize(Std.int(staticscreen.width * 0.275));
            staticscreen.updateHitbox();
            add(staticscreen);
    
            yellowBOX = new FlxSprite(0, 0).loadGraphic(Paths.image('yellowbox'));
            yellowBOX.alpha = 1;
            yellowBOX.antialiasing = true;
            yellowBOX.setGraphicSize(Std.int(bg.width));
            yellowBOX.updateHitbox();
            add(yellowBOX);

            bf = new FlxSprite(0, 0);
            bf.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
            bf.animation.addByPrefix('IDLE', "IDLE", 24);
            bf.animation.play('IDLE');
            bf.y += 320;
            bf.alpha = 1;
            bf.antialiasing = true;
            bf.setGraphicSize(200);
            bf.screenCenter(X);
            bf.x += 115;            
            bf.updateHitbox();
            add(bf);
    
            redBOX = new FlxSprite(0, 0).loadGraphic(Paths.image('redbox'));
            redBOX.alpha = 1;
            redBOX.antialiasing = true;
            redBOX.setGraphicSize(Std.int(bg.width));
            redBOX.updateHitbox();
            add(redBOX);
    
            sprDifficulty = new FlxSprite(0, 0).loadGraphic(Paths.image('menudifficulties/hard'));
            sprDifficulty.alpha = 1;
            sprDifficulty.antialiasing = true;
            sprDifficulty.setGraphicSize(270);
            sprDifficulty.updateHitbox();
            sprDifficulty.screenCenter(X);
            sprDifficulty.y += (580);
            sprDifficulty.x += (90);
            add(sprDifficulty);
    
            lock = new FlxSprite(sprDifficulty.x, 580 + 20);
            lock.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets');
            lock.setGraphicSize(Std.int(lock.width * 1));
            lock.animation.addByPrefix('idle', "lock");
            lock.animation.addByPrefix('press', "lock");
            lock.animation.play('idle');
            add(lock);

            leftArrow = new FlxSprite(sprDifficulty.x - 200, 580 + 20);
            leftArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets_alt');
            leftArrow.setGraphicSize(Std.int(leftArrow.width * 0.8));
            leftArrow.animation.addByPrefix('idle', "arrow left");
            leftArrow.animation.addByPrefix('press', "arrow push left");
            leftArrow.animation.play('idle');
            add(leftArrow);
    
            rightArrow = new FlxSprite(sprDifficulty.x + 150, 580 + 20);
            rightArrow.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets_alt');
            rightArrow.setGraphicSize(Std.int(rightArrow.width * 0.8));
            rightArrow.animation.addByPrefix('idle', "arrow right");
            rightArrow.animation.addByPrefix('press', "arrow push right");
            rightArrow.animation.play('idle');
            add(rightArrow);
    
            leftArrow2 = new FlxSprite(325, 136 + 5);
            leftArrow2.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets_alt');
            leftArrow2.setGraphicSize(Std.int(leftArrow2.width * 0.8));
            leftArrow2.animation.addByPrefix('idle', "arrow left");
            leftArrow2.animation.addByPrefix('press', "arrow push left");
            leftArrow2.animation.play('idle');
            add(leftArrow2);
    
            rightArrow2 = new FlxSprite(820, 136 + 5);
            rightArrow2.frames = Paths.getSparrowAtlas('campaign_menu_UI_assets_alt');
            rightArrow2.setGraphicSize(Std.int(rightArrow2.width * 0.8));
            rightArrow2.animation.addByPrefix('idle', "arrow right");
            rightArrow2.animation.addByPrefix('press', "arrow push right");
            rightArrow2.animation.play('idle');
            add(rightArrow2);
    
            sprDifficulty.offset.x = 70;
            sprDifficulty.y = leftArrow.y + 10;
		}
		

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (curSub == 'weeks')
        {
            if (FlxG.keys.justPressed.ESCAPE)
            {
                MusicBeatState.switchState(new MainMenuState());
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }
            if (FlxG.keys.justPressed.LEFT)
            {
                weekSelec--;
                FlxG.sound.play(Paths.sound('scrollMenu'));

                leftArrow2.animation.play('press');

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
                    leftArrow2.animation.play('idle');
				});
            }

            if (FlxG.keys.justPressed.RIGHT)
            {
                weekSelec++;
                FlxG.sound.play(Paths.sound('scrollMenu'));

                rightArrow2.animation.play('press');

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
                    rightArrow2.animation.play('idle');
				});

    
            }
            
            if (FlxG.keys.justPressed.DOWN)
                {
                    FlxG.sound.play(Paths.sound('deniedMOMENT'));
                }

            weekSelec = (weekSelec + weekNames.length) % weekNames.length;

            if (FlxG.keys.justPressed.ENTER)
            {
                FlxG.sound.play(Paths.sound('confirmMenu'));
                FlxFlicker.flicker(redBOX, 1.0, 0.06, true, false, null);

                new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                trace('Enter pressed, switching to PlayState');
                playSelectedSong();
                });
            }
        }

        updateWeekSprites();
    }

    function updateWeekSprites():Void
        {
            for (i in 0...weekSprites.length)
            {
                var weekSprite = weekSprites[i];
                if (i == weekSelec)
                {
                    weekSprite.x = defPos; // Set the selected sprite to the default position
                    weekSprite.alpha = 1;  // Make the selected sprite fully visible
                }
                else
                {
                    weekSprite.alpha = 0;  // Hide the other sprites
                }
            }
        
    
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
			{
				songSelec = 0; // Reset song selection to the first song of the new week
                FlxTween.cancelTweensOf(staticscreen);
                staticscreen.alpha = 1;
                FlxTween.tween(staticscreen, {alpha: 0.3}, 1);
			}
        }

        function playSelectedSong():Void
            {
                var songs:Array<String> = Reflect.field(this, weekNames[weekSelec]);
                trace('Selected song: ' + songs[songSelec]);
            
                if (songs.length > 0)
                {
                    PlayState.SONG = Song.loadFromJson(songs[songSelec].toLowerCase(), songs[songSelec].toLowerCase());
                    PlayState.isStoryMode = false;
                    trace('Switching to PlayState with song: ' + PlayState.SONG.song);
            
                    LoadingState.loadAndSwitchState(new PlayState());
                }
                else
                {
                    trace('Error: No songs available for the selected week.');
                }
            }
            

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}
}
