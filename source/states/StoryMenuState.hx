package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import backend.Song;
import backend.WeekData;
import states.StoryMenuStateMain;
import states.StoryMenuStateAlt;

class StoryMenuState extends MusicBeatState
{
    public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();


    var weekNames:Array<String> = ['main-week', 'alt-week']; // Add any weeks you want here.

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
    var shit:FlxSprite;    
    var weekSprites:Array<FlxSprite> = [];

    public static var vocals:FlxSound = null;

    override public function create():Void
        {
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            
            super.create();
        
            moreY = 0;
            addTextY = 0;
            weekSelec = 0;
            songSelec = 0;
            curSub = 'weeks';
        
            // Background
            var bg:FlxSprite;
            // Create a new FlxSprite and set its frames using the Sparrow Atlas
            bg = new FlxSprite().setFrames(Paths.getSparrowAtlas('menuSTATIC'));
            // Add the animation by prefix
            bg.animation.addByPrefix('menuSTATIC', 'menuSTATIC', 15, true);
            // Play the animation
            bg.animation.play('menuSTATIC');
            bg.antialiasing = ClientPrefs.data.antialiasing;
            // Add the sprite to the state
            add(bg);
            bg.scale.set(0.7, 0.7); // Customize the scale (1.5x for both width and height), It will work, ignore visual studio, this is working ok, fuck visual sutdio
            bg.updateHitbox();
            bg.screenCenter(X);
            bg.x += 0; // Adjust the x-offset
            bg.y -= 0; // Adjust the y-offset
        
            // Create week sprites vertically
            var spriteHeight:Float = 0;
            var padding:Float = 100;
            var totalHeight:Float = 0;

            shit = new FlxSprite(0, 0).loadGraphic(Paths.image('storyModeShit'));
            shit.alpha = 1;
            shit.antialiasing = true;
            shit.setGraphicSize(Std.int(bg.width));
            shit.updateHitbox();
            shit.screenCenter(X);
            add(shit);
        
            for (i in 0...weekNames.length)
            {
                var weekSprite = new FlxSprite(startX, startY + i * (spriteHeight + padding)).loadGraphic(Paths.image('ststuff/' + weekNames[i]));
                weekSprite.scrollFactor.set();
                weekSprite.screenCenter(X); // Center horizontally
                weekSprite.alpha = 1;
                add(weekSprite);
                weekSprites.push(weekSprite);
                weekSprite.scale.set(3, 3); // Set default smaller scale
                weekSprite.y -= 50; // Adjust the y-offset
            }
        
            defPos = weekSprites[0].y;
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
                    if (FlxG.keys.justPressed.DOWN)
                    {
                        weekSelec--;
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                    }
            
                    if (FlxG.keys.justPressed.UP)
                    {
                        weekSelec++;
                        FlxG.sound.play(Paths.sound('scrollMenu'));
                    }
            
                    weekSelec = (weekSelec + weekNames.length) % weekNames.length;
            
                    if (FlxG.keys.justPressed.ENTER)
                    {
                        trace('Enter pressed, switching to PlayState');
                        playSelectedSong();  
                        FlxG.sound.play(Paths.sound('confirmMenu'));
                        
                        // Flicker the selected weekSprite
                        FlxFlicker.flicker(weekSprites[weekSelec], 1.0, 0.06, true, false, null);
                    }
                }
            
                updateWeekSprites();
            }
            

    function updateWeekSprites():Void
        {
            for (i in 0...weekSprites.length)
            {
                var targetScaleX:Float = (i == weekSelec) ? 1 : 0.8; // Larger when selected
                var targetScaleY:Float = (i == weekSelec) ? 1 : 0.8; // Same for Y scale
                var targetAlpha:Float = (i == weekSelec) ? 1.3 : 0.8;
                var targetY:Float = defPos + 900 * (i - weekSelec); // Update Y position
        
                // Directly set scale, position, and alpha without tweening
                weekSprites[i].scale.set(targetScaleX, targetScaleY);
                weekSprites[i].y = targetY;
                weekSprites[i].alpha = targetAlpha;
            }
        
            if (FlxG.keys.justPressed.DOWN || FlxG.keys.justPressed.UP)
            {
                songSelec = 0; // Reset song selection to the first song of the new week
            }
        }
        

    function playSelectedSong():Void
        {
            // Get the selected week name
            var selectedWeek:String = weekNames[weekSelec];
        
            // Switch to the appropriate state based on the selected week
            new FlxTimer().start(1, function(tmr:FlxTimer)
				{
                    switch (selectedWeek)
                    {
                        case 'main-week':
                            MusicBeatState.switchState(new StoryMenuStateMain());
                        case 'alt-week':
                            MusicBeatState.switchState(new StoryMenuStateAlt());
                        default:
                            trace('Error: Unknown week selection.');
                    }
                });
        }
        

        function weekIsLocked(name:String):Bool {
            var leWeek:WeekData = WeekData.weeksLoaded.get(name);
            return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
        }
}
