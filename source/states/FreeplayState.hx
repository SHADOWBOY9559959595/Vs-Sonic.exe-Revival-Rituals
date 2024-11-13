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

class FreeplayState extends MusicBeatState
{
    var weekNames:Array<String> = [
        'majin', 'lordx', 'devoid', 'tails-doll', 'no-name', 'sally-alt', 'exeterior', 
        'fleetway', 'fatal-error', 'starved', 'xterion', 'educator', 'normal-cd', 'needlem0use', 
        'luther', 'sunky', 'sanic', 'coldsteel', 'sonichu', 'sonic', 'ugly-sonic', 
        'lumpy-sonic', 'melthog', 'faker', 'chaotix', 'requital', 'hog', 'grimeware', 
        'curse', 'monobw', 'no-more-innocence', 'dsk', 'demogri-and-griatos', 'blaze', 'satanos', 'apollyon', 
        'bratwurst', 'sl4sh', 'hellmas', 'batman', 'secret-history', 'omw', 'game-over'
    ];
    
    var songsByWeek:Map<String, Array<String>> = [
        'majin' => ['endless', 'endless-og', 'endless-us', 'endless-jp', 'endeavours'],
        'lordx' => ['execution', 'cycles', 'hellbent', 'fate', 'judgement', 'gatekeepers'],
        'devoid' => ['trickery'],
        'tails-doll' => ['sunshine', 'soulles'],
        'no-name' => ['forever-unnamed'],
        'sally-alt' => ['agony'],
        'exeterior' => ['sharpy-showdown'],
        'fleetway' => ['chaos', 'running-wild', 'heroes-and-villains'],
        'fatal-error' => ['fatality'],
        'starved' => ['prey', 'fight-or-flight'],
        'xterion' => ['substantial', 'digitalized'],
        'educator' => ['expulsion'],
        'normal-cd' => ['found-you'],
        'needlem0use' => ['relax', 'round-a-bout', 'spike-trap'],
        'luther' => ['her-world'],
        'sunky' => ['milk'],
        'sanic' => ['too-fest'],
        'coldsteel' => ['personel', 'personel-serious'],
        'sonichu' => ['shocker', 'extreme-zap'],
        'sonic' => ['soured'],
        'ugly-sonic' => ['ugly'],
        'lumpy-sonic' => ['frenzy'],
        'melthog' => ['melting', 'confronting'],
        'faker' => ['faker', 'black-sun', 'godspeed'],
        'chaotix' => ['my-horizon', 'our-horizon'],
        'requital' => ['foretall-desire'],
        'hog' => ['hedge', 'manual-blast'],
        'grimeware' => ['gorefest'],
        'curse' => ['malediction', 'extricate-hex'],
        'monobw' => ['color-blind'],
        'no-more-innocence' => ['fake-baby'],
        'dsk' => ['miasma'],
        'demogri-and-griatos' => ['insidious', 'haze', 'marauder'],
        'blaze' => ['burning'],
        'satanos' => ['perdition', 'underworld', 'purgatory'],
        'apollyon' => ['genesis', 'proverbs', 'corinthians', 'revelations'],
        'bratwurst' => ['gods-will'],
        'sl4sh' => ['b4cksl4sh'],
        'hellmas' => ['missiletoe', 'slaybells', 'jingle-hells'],
        'batman' => ['gotta-go'],
        'secret-history' => ['mania'],
        'omw' => ['universal-collapse'],
        'game-over' => ['too-far']
    ];
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
    
    override public function create():Void {
        super.create();
        moreY = 0;
        addTextY = 0;
        weekSelec = 0;
        songSelec = 0;
        curSub = 'weeks';

        fpbg = new FlxSprite().loadGraphic(Paths.image('backgroundlool'));
        fpbg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
        fpbg.updateHitbox();
        fpbg.scrollFactor.set();
        add(fpbg);

        blackLine = new FlxSprite(80 + 219, 0).makeGraphic(10, FlxG.height, 0xFF000000);
        blackLine.scrollFactor.set();
        add(blackLine);

        sidebar = new FlxTiledSprite(Paths.image('sidebar'), 684, 720, true, true);
        sidebar.x=FlxG.width - sidebar.width;
        sidebar.scrollFactor.set(0.4, 0.4);
        add(sidebar);

        for (i in 0...weekNames.length) {
            var weekSprite = new FlxSprite(startX, startY + moreY).loadGraphic(Paths.image('fpstuff/' + weekNames[i]));
            weekSprite.scrollFactor.set();
            weekSprite.screenCenter(Y);
            add(weekSprite);
            weekSprites.push(weekSprite);
            weekSprite.scale.set(0.5, 0.5);
            weekSprite.x += -90;
            moreY += weekSprite.height * 0.5 + 100;
        }

        title = new FlxText(0, 0, FlxG.width, capitalizeFirstLetter(weekNames[weekSelec]).replace("-", " "));
        title.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 37, FlxColor.WHITE, FlxTextAlign.CENTER);
        title.screenCenter(X);
        title.scrollFactor.set();
        add(title);

        updateSongTexts();

        defPos = weekSprites[0].y;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
    
        sidebar.scrollY -= (sidebarScrollSpeed * sidebar.scrollFactor.y) * (elapsed/(1/120));
    
        if (curSub == 'weeks') {
            for (text in songTexts) {
                text.color = 0xFF000000;
                text.borderColor = 0xFFFFFFFF;
            }
    
            if (FlxG.keys.justPressed.ESCAPE) {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new MainMenuState());
            }
    
            if (FlxG.keys.justPressed.UP) {
                weekSelec--;
                FlxG.sound.play(Paths.sound('scrollMenu'));
                updateSongTexts();
            }
    
            if (FlxG.keys.justPressed.DOWN) {
                weekSelec++;
                FlxG.sound.play(Paths.sound('scrollMenu'));
                updateSongTexts();
            }
    
            weekSelec = (weekSelec + weekNames.length) % weekNames.length;
    
            if (FlxG.keys.justPressed.ENTER) {
                curSub = 'songs';
                songSelec = 0;
                new FlxTimer().start(0.1, function(tmr:FlxTimer) {
                    canPlay = true;
                });
            }
        } else if (curSub == 'songs') {
            if (FlxG.keys.justPressed.ESCAPE) {
                curSub = 'weeks';
                FlxG.sound.play(Paths.sound('cancelMenu'));
            }
    
            if (FlxG.keys.justPressed.UP) {
                songSelec--;
                FlxG.sound.play(Paths.sound('scrollMenu'));
                updateSongHighlight();
            }
    
            if (FlxG.keys.justPressed.DOWN) {
                songSelec++;
                FlxG.sound.play(Paths.sound('scrollMenu'));
                updateSongHighlight();
            }
    
            songSelec = (songSelec + songTexts.length) % songTexts.length;
    
            if (FlxG.keys.justPressed.ENTER && canPlay) {
                SonicTransitionState.skipNextTransIn = true;
                SonicTransitionState.skipNextTransOut = true;
                FlxG.sound.play(Paths.sound('confirmMenu'));
                
                var white:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
                white.alpha = 0;
                add(white);
    
                FlxTween.tween(white, {alpha: 1}, 1, {onComplete:
                    function(twn:FlxTween) {
                        var songs:Array<String> = songsByWeek[weekNames[weekSelec]];
                        PlayState.SONG = Song.loadFromJson(songs[songSelec].toLowerCase() + '-hard', songs[songSelec].toLowerCase());
                        PlayState.isStoryMode = false;
                        LoadingState.loadAndSwitchState(new PlayState());
                    }
                });
            }
            updateSongHighlight();
        }
        updateWeekSprites();
    }
    
    

    function updateWeekSprites():Void {
        for (i in 0...weekSprites.length) {
            var targetScaleX:Float = (i == weekSelec) ? 0.7 : 0.5;
            var targetScaleY:Float = (i == weekSelec) ? 0.7 : 0.5;
            var targetAlpha:Float = (i == weekSelec) ? 1 : 0.5;
            var targetY:Float = defPos + 447 * (i - weekSelec);

            FlxTween.tween(weekSprites[i].scale, {x: targetScaleX}, 0.5, {ease: FlxEase.expoOut});
            FlxTween.tween(weekSprites[i].scale, {y: targetScaleY}, 0.5, {ease: FlxEase.expoOut});
            FlxTween.tween(weekSprites[i], {y: targetY, alpha: targetAlpha}, 0.5, {ease: FlxEase.expoOut});
        }

        title.text = capitalizeFirstLetter(weekNames[weekSelec]).replace("-", " ");
    }

    function updateSongTexts():Void {
        for (text in songTexts) {
            remove(text);
        }
        songTexts = [];
    
        var songs:Array<String> = songsByWeek[weekNames[weekSelec]];
        textY = defTY - 30 * (songs.length - 1);
        addTextY = 0;
    
        for (i in 0...songs.length) {
            var formattedSong = songs[i].toLowerCase().replace("-", " ");
    
            var songText = new FlxText(sidebar.x + 25, textY + addTextY, Std.int(sidebar.width), formattedSong);
            songText.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 30, 0xFF000000, CENTER, OUTLINE, 0xFFFFFFFF);
            songText.borderSize = 2;
            songText.scrollFactor.set();
    
            add(songText);
            songTexts.push(songText);
            addTextY += 60;
        }
    }

    function startSong():Void {
        var songs:Array<String> = songsByWeek[weekNames[weekSelec]];
        var selectedSong:String = songs[songSelec].toLowerCase();

        SonicTransitionState.skipNextTransIn = true;
        SonicTransitionState.skipNextTransOut = true;

        FlxG.sound.play(Paths.sound('confirmMenu'));

        var white:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        white.alpha = 0;
        add(white);

        FlxTween.tween(white, {alpha: 1}, 1, {onComplete:
            function(twn:FlxTween) {
                PlayState.SONG = Song.loadFromJson(selectedSong, selectedSong);
                PlayState.isStoryMode = false;
                LoadingState.loadAndSwitchState(new PlayState());
            }
        });
    }

    function updateSongHighlight():Void {
        for (i in 0...songTexts.length) {
            if (i == songSelec) {
                songTexts[i].color = 0xFFFFFFFF;
                songTexts[i].borderColor = 0xFF000000;
            } else {
                songTexts[i].color = 0xFF000000;
                songTexts[i].borderColor = 0xFFFFFFFF;
            }
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
