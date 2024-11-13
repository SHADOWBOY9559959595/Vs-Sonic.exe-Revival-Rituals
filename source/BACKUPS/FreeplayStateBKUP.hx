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
import backend.SonicTransitionState;
import flixel.addons.display.FlxTiledSprite;

class FreeplayStateBKUP extends MusicBeatState
{
    var weekNames:Array<String> = ['majin', 'lordx', 'devoid', 'tailsdoll', 'noname', 'sallyalt', 'exeterior', 'fleetway', 'fatalerror', 'starved', 'xterion', 'educator', 'normalcd', 'needlem0use', 'luther', 'sunky', 'sanic', 'coldsteel', 'sonichu', 'sonic', 'uglysonic', 'lumpysonic', 'melthog', 'faker', 'chaotix', 'requital', 'hog', 'grimeware', 'curse', 'monobw', 'nmi', 'dsk', 'demogringriatos', 'blaze', 'satanos', 'apollyon', 'bratwurst', 'sl4sh', 'hellmas', 'batman', 'secrethistory', 'omw', 'gameover']; // Add any weeks you want here.
    
    // Songs for each week
    var majin:Array<String> = ['endless', 'endless-og', 'endless-us', 'endless-jp', 'endeavours'];
    var lordx:Array<String> = ['execution', 'cycles', 'hellbent', 'fate', 'judgement' , 'gatekeepers'];    
    var devoid:Array<String> = ['trickery'];
    var tailsdoll:Array<String> = ['sunshine', 'soulles'];
    var noname:Array<String> = ['forever-unnamed'];
    var sallyalt:Array<String> = ['agony'];
    var exeterior:Array<String> = ['sharpy-showdown'];
    var fleetway:Array<String> = ['chaos', 'running-wild', 'heroes-and-villains'];
    var fatalerror:Array<String> = ['fatality'];
    var starved:Array<String> = ['prey', 'fight-or-flight'];
    var xterion:Array<String> = ['substantial', 'digitalized'];    
    var educator:Array<String> = ['expulsion'];
    var normalcd:Array<String> = ['found-you'];
    var needlem0use:Array<String> = ['relax', 'round-a-bout', 'spike-trap'];
    var luther:Array<String> = ['her-world'];    
    var sunky:Array<String> = ['milk'];
    var sanic:Array<String> = ['too-fest'];
    var coldsteel:Array<String> = ['personel', 'personel-serious'];   
    var sonichu:Array<String> = ['shocker', 'extreme-zap'];
    var sonic:Array<String> = ['soured'];
    var uglysonic:Array<String> = ['ugly'];
    var lumpysonic:Array<String> = ['frenzy'];
    var melthog:Array<String> = ['melting', 'confronting'];
    var faker:Array<String> = ['faker', 'black-sun', 'godspeed'];
    var chaotix:Array<String> = ['my-horizon', 'our-horizon'];    
    var requital:Array<String> = ['foretall-desire'];
    var hog:Array<String> = ['hedge', 'manual-blast'];
    var grimeware:Array<String> = ['gorefest'];
    var curse:Array<String> = ['malediction', 'extricate-hex'];
    var monobw:Array<String> = ['color-blind'];
    var nmi:Array<String> = ['fake-baby'];
    var dsk:Array<String> = ['miasma'];
    var demogringriatos:Array<String> = ['insidious', 'haze', 'marauder'];
    var blaze:Array<String> = ['burning'];
    var satanos:Array<String> = ['perdition', 'underworld', 'purgatory'];
    var apollyon:Array<String> = ['genesis', 'proverbs', 'corinthians', 'revelations'];
    var bratwurst:Array<String> = ['gods-will'];    
    var sl4sh:Array<String> = ['b4cksl4sh'];
    var hellmas:Array<String> = ['missiletoe', 'slaybells', 'jingle-hells'];    
    var batman:Array<String> = ['gotta-go'];
    var secrethistory:Array<String> = ['mania'];
    var omw:Array<String> = ['universal-collapse'];
    var gameover:Array<String> = ['too-far'];

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
    var sidebar:FlxTiledSprite;
    var sidebarScrollSpeed:Float = 15;
    var title:FlxText;
    var songTexts:Array<FlxText> = [];
    var weekSprites:Array<FlxSprite> = [];

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

        // Scrolling sidebar
        sidebar = new FlxTiledSprite(Paths.image('sidebar'), 684, 720, true, true);
        sidebar.scrollFactor.set(0.4, 0.4);
        //sidebar.screenCenter();
        add(sidebar);

        for (i in 0...weekNames.length)
        {
            var weekSprite = new FlxSprite(startX, startY + moreY).loadGraphic(Paths.image('fpstuff/' + weekNames[i]));
            weekSprite.scrollFactor.set();
            weekSprite.screenCenter(Y);
            add(weekSprite);
            weekSprites.push(weekSprite);
            weekSprite.scale.set(0.5, 0.5);
            weekSprite.x += -90;
            moreY += weekSprite.height * 0.5 + 100;
        }

        title = new FlxText(0, 0, FlxG.width, capitalizeFirstLetter(weekNames[weekSelec]));
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

        sidebar.scrollY -= (sidebarScrollSpeed * sidebar.scrollFactor.y);

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
                SonicTransitionState.skipNextTransIn = true;
                SonicTransitionState.skipNextTransOut = true;

                FlxG.sound.play(Paths.sound('confirmMenu'));

                var white:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
                white.alpha = 0;
                add(white);

                FlxTween.tween(white, {alpha: 1}, 1, {onComplete:
                    function(twn:FlxTween) {
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
                var targetScaleX:Float = (i == weekSelec) ? 0.7 : 0.5;
                var targetScaleY:Float = (i == weekSelec) ? 0.7 : 0.5;
                var targetAlpha:Float = (i == weekSelec) ? 1 : 0.5;
                var targetY:Float = defPos + 447 * (i - weekSelec);
        
                FlxTween.tween(weekSprites[i].scale, {x: targetScaleX}, 0.5, {ease: FlxEase.expoOut});
                FlxTween.tween(weekSprites[i].scale, {y: targetScaleY}, 0.5, {ease: FlxEase.expoOut});
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
                var formattedSong = songs[i].toLowerCase().replace("-", " ");
        
                //var songText = new FlxText(sidebar1.x + 25, textY + addTextY, Std.int(sidebar1.width), formattedSong);
                var songText = new FlxText(sidebar.x + 25, textY + addTextY, Std.int(sidebar.width), formattedSong);
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
    
            
