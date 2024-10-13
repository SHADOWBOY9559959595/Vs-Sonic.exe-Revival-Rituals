package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import backend.Song;
import states.MainMenuState;

class FreeplayStateBKUP extends MusicBeatState
{
    var weekNames:Array<String> = ['majin', 'lordx', 'tailsdoll', 'fleetway', 'fatalerror', 'starved', 'xterion', 'needlemouse', 'luther', 'faker', 'devoid', 'chaotix', 'hog', 'curse', 'genysis', 'satanos', 'sl4sh', 'hellmas', 'batman', 'requital', 'secrethistory', 'educator', 'omw', 'gameover', 'sunky', 'sanic', 'sonichu', 'coldsteel']; // Add any weeks you want here.
    
    // Songs for each week
    var majin:Array<String> = ['endless', 'endless-og', 'endless-us', 'endless-jp', 'endeavours'];
    var lordx:Array<String> = ['cycles', 'execution', 'hellbent', 'fate', 'gotta-go-glove'];
    var tailsdoll:Array<String> = ['sunshine', 'soulles'];
    var fleetway:Array<String> = ['chaos'];
    var fatalerror:Array<String> = ['fatality'];
    var starved:Array<String> = ['prey', 'fight-or-flight'];
    var xterion:Array<String> = ['substantial', 'digitalized'];
    var needlemouse:Array<String> = ['round-a-bout', 'relax'];
    var luther:Array<String> = ['her-world', 'lukas-world'];
    var faker:Array<String> = ['faker', 'black-sun', 'godspeed'];
    var devoid:Array<String> = ['hollow'];
    var chaotix:Array<String> = ['my-horizon', 'my-horizon-wechidna', 'my-horizon-armydillo', 'my-horizon-obsolete'];
    var hog:Array<String> = ['hedge', 'manual-blast'];
    var curse:Array<String> = ['malediction'];
    var genysis:Array<String> = ['burning'];
    var satanos:Array<String> = ['perdition'];
    var sl4sh:Array<String> = ['b4cksl4sh'];
    var hellmas:Array<String> = ['slaybells'];
    var batman:Array<String> = ['gotta-go-batman'];
    var requital:Array<String> = ['foretall-desire'];
    var secrethistory:Array<String> = ['mania'];
    var educator:Array<String> = ['playful'];
    var omw:Array<String> = ['universal-collapse'];
    var gameover:Array<String> = ['too-far'];
    var sunky:Array<String> = ['milk'];
    var sanic:Array<String> = ['too-fest'];
    var coldsteel:Array<String> = ['personel'];   
    var sonichu:Array<String> = ['shocker'];

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
    var canPlay:Bool = false;

    var fpbg:FlxSprite;
    var blackLine:FlxSprite;
    var sidebar1:FlxSprite;
    var sidebar2:FlxSprite;
    var title:FlxText;
    var songTexts:Array<FlxText> = [];
    var weekSprites:Array<FlxSprite> = [];
    var sidebarScrollSpeed:Float = 70; // Adjust this speed as needed

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

        // Initialize shader
        //var scrollShader = new ScrollShader();

        // Background
        fpbg = new FlxSprite().loadGraphic(Paths.image('backgroundlool'));
        fpbg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
        fpbg.updateHitbox();
        fpbg.scrollFactor.set();
        add(fpbg);

        // Black line
        blackLine = new FlxSprite(80 + 219, 0).makeGraphic(10, FlxG.height, 0xFF000000);
        blackLine.scrollFactor.set();
        add(blackLine);

        // Scrolling sidebars
        sidebar1 = new FlxSprite().loadGraphic(Paths.image('sidebar'));
        sidebar1.setGraphicSize(Std.int(sidebar1.width), Std.int(sidebar1.height)); // Maintain original resolution
        sidebar1.updateHitbox();
        sidebar1.x = FlxG.width - sidebar1.width;
        sidebar1.y = 0;
        sidebar1.scrollFactor.set();
        add(sidebar1);

        sidebar2 = new FlxSprite().loadGraphic(Paths.image('sidebar'));
        sidebar2.setGraphicSize(Std.int(sidebar2.width), Std.int(sidebar2.height)); // Maintain original resolution
        sidebar2.updateHitbox();
        sidebar2.x = FlxG.width - sidebar2.width;
        sidebar2.y = -sidebar2.height;
        sidebar2.scrollFactor.set();
        add(sidebar2);

        // Create week sprites
        for (i in 0...weekNames.length)
        {
            var weekSprite = new FlxSprite(startX, startY + moreY).loadGraphic(Paths.image('fpstuff/' + weekNames[i]));
            weekSprite.scrollFactor.set();
            weekSprite.screenCenter(Y); // Center vertically
            add(weekSprite);
            weekSprites.push(weekSprite);
            weekSprite.scale.set(0.5, 0.5); // Set default smaller scale
            weekSprite.x += -90; // Adjust the x-offset
            moreY += weekSprite.height * 0.5 + 100; // Adjust spacing based on scale
        }

        // Add title text with the first letter capitalized
        title = new FlxText(0, 0, FlxG.width, capitalizeFirstLetter(weekNames[weekSelec])); // Ensure to set the initial x, y, and width for FlxText
        title.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 37, FlxColor.WHITE, FlxTextAlign.CENTER);
        title.screenCenter(X);
        title.scrollFactor.set();
        add(title);


        updateSongTexts();

        defPos = weekSprites[0].y;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // Update sidebar positions for scrolling
        sidebar1.y += sidebarScrollSpeed * elapsed;
        sidebar2.y += sidebarScrollSpeed * elapsed;

        // Reposition sidebars when they move completely off-screen
        if (sidebar1.y >= FlxG.height)
        {
            sidebar1.y = sidebar2.y - sidebar1.height;
        }

        if (sidebar2.y >= FlxG.height)
        {
            sidebar2.y = sidebar1.y - sidebar2.height;
        }

        //sidebar.shader.uTime.value = [elapsed];

        if (curSub == 'weeks')
        {
            if (FlxG.keys.justPressed.ESCAPE)
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new MainMenuState());
            }

            if (FlxG.keys.justPressed.UP)
            {
                weekSelec--;
                FlxG.sound.play(Paths.sound('scrollMenu'));
            }

            if (FlxG.keys.justPressed.DOWN)
            {
                weekSelec++;
                FlxG.sound.play(Paths.sound('scrollMenu'));
            }

            weekSelec = (weekSelec + weekNames.length) % weekNames.length;

            if (FlxG.keys.justPressed.ENTER)
            {
                curSub = 'songs';
                songSelec = 0;
                new FlxTimer().start(0.1, function(tmr:FlxTimer)
                {
                    canPlay = true;
                });
            }
        }
        else if (curSub == 'songs')
        {
            if (FlxG.keys.justPressed.ESCAPE)
            {
                curSub = 'weeks';
                for (text in songTexts)
                    text.color = 0xFF000000;

                FlxG.sound.play(Paths.sound('cancelMenu'));
            }

            if (FlxG.keys.justPressed.UP)
            {
                songSelec--;
                FlxG.sound.play(Paths.sound('scrollMenu'));
            }

            if (FlxG.keys.justPressed.DOWN)
            {
                songSelec++;
                FlxG.sound.play(Paths.sound('scrollMenu'));
            }

            songSelec = (songSelec + songTexts.length) % songTexts.length;

            for (i in 0...songTexts.length)
            {
                songTexts[i].color = (i == songSelec) ? 0xFFFFFFFF : 0xFF000000;
                songTexts[i].borderStyle = (i == songSelec) ? NONE : OUTLINE;
            }

            if (FlxG.keys.justPressed.ENTER && canPlay)
            {
                FlxG.sound.play(Paths.sound('confirmMenu'));

                var white:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
                white.alpha = 0;
                add(white);

                FlxTween.tween(white, {alpha: 1}, 1, {onComplete:
                    function(twn:FlxTween) {
                        FlxTransitionableState.skipNextTransIn = true;
                        FlxTransitionableState.skipNextTransOut = true;
                        var songs:Array<String> = Reflect.field(this, weekNames[weekSelec]);
                        PlayState.SONG = Song.loadFromJson(songs[songSelec].toLowerCase() + '-hard', songs[songSelec].toLowerCase());
                        PlayState.isStoryMode = false;
                        LoadingState.loadAndSwitchState(new PlayState());
						}
					});
            }
        }

        updateWeekSprites();
    }

    function updateWeekSprites():Void
        {
            for (i in 0...weekSprites.length)
            {
                var targetScaleX:Float = (i == weekSelec) ? 0.7 : 0.5; // Larger when selected
                var targetScaleY:Float = (i == weekSelec) ? 0.7 : 0.5; // Same for Y scale
                var targetAlpha:Float = (i == weekSelec) ? 1 : 0.5;
                var targetY:Float = defPos + 447 * (i - weekSelec);
        
                // Animate scale X
                FlxTween.tween(weekSprites[i].scale, {x: targetScaleX}, 0.5, {ease: FlxEase.expoOut});
                // Animate scale Y
                FlxTween.tween(weekSprites[i].scale, {y: targetScaleY}, 0.5, {ease: FlxEase.expoOut});
                // Animate Y position and alpha
                FlxTween.tween(weekSprites[i], {y: targetY, alpha: targetAlpha}, 0.5, {ease: FlxEase.expoOut});
            }
        
            title.text = capitalizeFirstLetter(weekNames[weekSelec]);
        
            if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN)
                updateSongTexts();
        }
        
    function updateSongTexts():Void
        {
            for (text in songTexts)
                remove(text);
            songTexts = [];
        
            var songs:Array<String> = Reflect.field(this, weekNames[weekSelec]);
            textY = defTY - 30 * (songs.length - 1);
            addTextY = 0;
        
            for (i in 0...songs.length)
            {
                // Replace '-' with a space
                var formattedSong = songs[i].toLowerCase().replace("-", " ");
        
                var songText = new FlxText(sidebar1.x + 25, textY + addTextY, Std.int(sidebar1.width), formattedSong);
                songText.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 30, 0xFF000000, CENTER, OUTLINE, 0xFFFFFFFF);
                songText.borderSize = 2;
                songText.scrollFactor.set();
                add(songText);
                songTexts.push(songText);
                addTextY += 60;
            }
        }

        public static function destroyFreeplayVocals() {
            if(vocals != null) {
                vocals.stop();
                vocals.destroy();
            }
            vocals = null;
        }
    }
    
            
