package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.addons.transition.FlxTransitionableState;

import flixel.util.FlxStringUtil;
import flixel.effects.FlxFlicker;

import states.MainMenuState;

import objects.HealthIcon;
import objects.Bar;

class PauseSubStateBKUP extends MusicBeatSubstate
{
    var menuItems:FlxTypedGroup<FlxSprite>;
    var optionShit:Array<String> = ['Continue', 'Restart', 'Exit'];

    public static var curSelected:Int = 0;
    public static var songName:String = null;

    var rightThingie:FlxSprite; 
    var leftThingie:FlxSprite;    
    var bg:FlxSprite;
    var icon:HealthIcon;

    var timeBar:Bar;
    var songPercent:Float = 0;
    var songLength:Float = 0;

    override function create()
        { 
            cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];          
      
            PlayState.instance.camHUD.visible = false;

            FlxG.sound.play(Paths.sound('pause'));

            bg = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK);
            bg.scrollFactor.set(); 
            bg.alpha = 0;
            bg.screenCenter(X);
            bg.screenCenter(Y);
            add(bg);
            bg.updateHitbox();
        
            FlxTween.tween(bg, {alpha: 0.6}, 0.3, {ease: FlxEase.quartInOut});
        
            leftThingie = new FlxSprite(0, 0).loadGraphic(Paths.image('pauseStuff/pauseLeft'));
            leftThingie.scrollFactor.set();
            leftThingie.alpha = 1;
            leftThingie.antialiasing = true;
            leftThingie.setGraphicSize(Std.int(bg.width));
            leftThingie.x += -300;
            leftThingie.y += 0;
            add(leftThingie);
            leftThingie.updateHitbox();
        
            FlxTween.tween(leftThingie, {x: 0}, 0.3, {ease: FlxEase.quadOut});
        
            rightThingie = new FlxSprite(0, 0).loadGraphic(Paths.image('pauseStuff/pauseRight'));
            rightThingie.scrollFactor.set();
            rightThingie.alpha = 1;
            rightThingie.antialiasing = true;
            rightThingie.setGraphicSize(Std.int(bg.width));
            rightThingie.x += 300;
            rightThingie.y += 0;
            add(rightThingie);
            rightThingie.updateHitbox();
        
            FlxTween.tween(rightThingie, {x: 0}, 0.3, {ease: FlxEase.quadOut});

            timeBar = new Bar(-320, 210, 'timeBar', function() return songPercent, 0, 1);
            timeBar.setColors(FlxColor.RED);
            timeBar.scale.set(0.9, 0.9);
            timeBar.scrollFactor.set();
            timeBar.alpha = 1;
            add(timeBar);             

            FlxTween.tween(timeBar, {x: 120}, 0.3, {ease: FlxEase.quadOut});      

            var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);            
            var iconOffset:Int;            
            var percent = timeBar.percent;
            songLength = FlxG.sound.music.length;
			songPercent = (curTime / songLength);
            iconOffset = 50;
            percent = 100-timeBar.percent;

            icon = new HealthIcon(PlayState.instance.boyfriend.healthIcon);
            icon.scrollFactor.set();
            icon.x = timeBar.x + (timeBar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01) - iconOffset);
            icon.y += 150;
            icon.scale.set(0.9, 0.9);
            add(icon);
        
            //FlxTween.tween(icon, {x: -300}, 0.3, {ease: FlxEase.quadIn});
        
            menuItems = new FlxTypedGroup<FlxSprite>();
            for (i in 0...optionShit.length)
            {
                var menuItem:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pauseStuff/' + optionShit[i]));
                menuItem.scrollFactor.set();
                menuItem.scale.set(1, 1);
        
                new FlxTimer().start(0.4, function(tmr:FlxTimer)
                {
                    add(menuItem);
                    menuItems.add(menuItem);
                });
        
                switch (i) {
                    case 0: menuItem.setPosition(0, 0);
                    case 1: menuItem.setPosition(0, 0);
                    case 2: menuItem.setPosition(0, 0);
                }
            }
        
            // Call changeSelection(0) after all menu items have been added
            new FlxTimer().start(0.42, function(tmr:FlxTimer)
            {
                curSelected = 0;
                changeSelection(0);
            });
        
            super.create();    
        }        

    var selectedSomethin:Bool = false;

    override function update(elapsed:Float)
    {
        var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);            
        var iconOffset:Int;            
        var percent = timeBar.percent;
        songLength = FlxG.sound.music.length;
        songPercent = (curTime / songLength);
        iconOffset = 50;
        percent = 100-timeBar.percent;
        icon.x = timeBar.x + (timeBar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01) - iconOffset);
        
        // Set the initial selection to the last selected item
		//menuItems.members[curSelected];	
        
        if (!selectedSomethin)
        {
            if (controls.UI_UP_P)
                changeSelection(-1);
            
            if (controls.UI_DOWN_P)
                changeSelection(1);
            
            if (controls.ACCEPT)
                {
                    FlxG.sound.play(Paths.sound('unpause'));
        
                    selectedSomethin = true;
        
                    switch (optionShit[curSelected])
                    {
                        case 'Continue':
                            // Fade out menu items
                            for (i in 0...menuItems.members.length)
                            {
                                var item = menuItems.members[i];
                                FlxTween.tween(item, {alpha: 0}, 0.2, {ease: FlxEase.quartInOut});
                            }
                                // Play tweens for bg, leftThingie, and rightThingie
                                FlxTween.tween(bg, {alpha: 0}, 0.2, {ease: FlxEase.quartInOut});
                                FlxTween.tween(leftThingie, {x: -1000}, 0.2, {ease: FlxEase.quadOut});
                                FlxTween.tween(rightThingie, {x: 1000}, 0.2, {ease: FlxEase.quadOut});
                                FlxTween.tween(timeBar, {x: -1000}, 0.2, {ease: FlxEase.quadIn}); 
        
                                new FlxTimer().start(0.25, function(tmr:FlxTimer)
                                {
                                    // Restore the HUD when resuming the game
                                    showHUD();

                                    close();
                                });

                    case 'Restart':
                        restartSong();
                    case 'Exit':
                        #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
                        PlayState.deathCounter = 0;
                        PlayState.seenCutscene = false;

                        MusicBeatState.switchState(new MainMenuState());
                        FlxG.sound.playMusic(Paths.music('freakyMenu'));
                }
            }
        }

        super.update(elapsed);
    }

    public static function restartSong(noTrans:Bool = false)
    {
        PlayState.instance.paused = true; // For lua
        FlxG.sound.music.volume = 0;
        PlayState.instance.vocals.volume = 0;
            
        if (noTrans)
        {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
        }
        MusicBeatState.resetState();
    }

    function changeSelection(change:Int = 0):Void
        {
            curSelected += change;
        
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        
            if (curSelected < 0)
                curSelected = menuItems.members.length - 1;
            if (curSelected >= menuItems.members.length)
                curSelected = 0;
        
            for (i in 0...menuItems.members.length)
            {
                var item = menuItems.members[i];
                item.alpha = 1;
        
                if (i == curSelected) {
                    // Adjust the selected item position
                    item.y -= 12;
                    item.x -= 7;
                } else {
                    // Reset the position for non-selected items
                    // (Assuming you want to revert the position if it's no longer selected)
                    switch (i) {
                        case 0: item.setPosition(0, 0);
                        case 1: item.setPosition(0, 0);
                        case 2: item.setPosition(0, 0);
                    }
                }
            }
        }
}
