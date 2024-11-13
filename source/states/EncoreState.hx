package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import backend.Song;
import states.MainMenuState;
import backend.SonicTransitionState;

class EncoreState extends MusicBeatState
{
    var weekNames:Array<String> = ['tooslow', 'youcantrun', 'tripletrouble', 'endless', 'cycles', 'sunshine', 'chaos', 'fatality', 'roundabout', 'herworld', 'faker']; // Add any weeks you want here.
    
    // Songs for each week
    var tooslow:Array<String> = ['too-slow-encore'];
    var youcantrun:Array<String> = ['you-cant-run-encore'];
    var tripletrouble:Array<String> = ['triple-trouble-encore'];
    var endless:Array<String> = ['endless-encore'];
    var cycles:Array<String> = ['cycles-encore'];
    var sunshine:Array<String> = ['sunshine-encore'];
    var chaos:Array<String> = ['chaos-encore'];
    var fatality:Array<String> = ['fatality-encore'];
    var roundabout:Array<String> = ['round-a-bout-encore'];
    var herworld:Array<String> = ['her-world-encore'];
    var faker:Array<String> = ['faker-encore'];

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

    var fpbg:FlxSprite;
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
		
            fpbg = new FlxSprite().loadGraphic(Paths.image('backgroundlool'));
			fpbg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
			fpbg.updateHitbox();
			fpbg.scrollFactor.set();
			add(fpbg);
		
            var spriteWidth:Float = 0;
			var padding:Float = 100;
			var totalWidth:Float = 0;
		
			for (i in 0...weekNames.length)
			{
				var weekSprite = new FlxSprite(startX + i * (spriteWidth + padding), startY).loadGraphic(Paths.image('ecstuff/' + weekNames[i]));
				weekSprite.scrollFactor.set();
				weekSprite.screenCenter(X);
				add(weekSprite);
				weekSprites.push(weekSprite);
				weekSprite.scale.set(3, 3);
				weekSprite.y -= 50;
			}
		
			updateSongTexts();
		
			defPos = weekSprites[0].x;
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
            }

            if (FlxG.keys.justPressed.RIGHT)
            {
                weekSelec++;
                FlxG.sound.play(Paths.sound('scrollMenu'));
            }

            weekSelec = (weekSelec + weekNames.length) % weekNames.length;

            if (FlxG.keys.justPressed.ENTER)
            {
                SonicTransitionState.skipNextTransIn = true;
                SonicTransitionState.skipNextTransOut = true;

                FlxG.sound.play(Paths.sound('confirmMenu'));

                var white:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
                white.alpha = 0;
                add(white);

                FlxTween.tween(white, {alpha: 1}, 1, {onComplete:
                    function(twn:FlxTween) {
                        playSelectedSong();                       
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
				var targetScaleX:Float = (i == weekSelec) ? 1.1 : 0.9;
				var targetScaleY:Float = (i == weekSelec) ? 1.1 : 0.9;
				var targetAlpha:Float = (i == weekSelec) ? 1.4 : 0.9;
				var targetX:Float = defPos + 700 * (i - weekSelec);
		
				FlxTween.tween(weekSprites[i].scale, {x: targetScaleX}, 0.9, {ease: FlxEase.expoOut});
				FlxTween.tween(weekSprites[i].scale, {y: targetScaleY}, 0.9, {ease: FlxEase.expoOut});
				FlxTween.tween(weekSprites[i], {x: targetX, alpha: targetAlpha}, 0.9, {ease: FlxEase.expoOut});
			}
		
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
			{
				updateSongTexts();
				songSelec = 0;
			}
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

            var songText = new FlxText( 25, textY + addTextY, formattedSong);
            songText.setFormat(Paths.font("sonic-cd-menu-font.ttf"), 37, FlxColor.WHITE, FlxTextAlign.CENTER);
            songText.scrollFactor.set();
            add(songText);
            songTexts.push(songText);
            addTextY += 60;
			songText.screenCenter(X);
			songText.y += 300;
        }
    }

    function playSelectedSong():Void
    {
        var songs:Array<String> = Reflect.field(this, weekNames[weekSelec]);
        trace('Selected song: ' + songs[songSelec]);

        if (songs.length > 0)
        {
            PlayState.SONG = Song.loadFromJson(songs[songSelec].toLowerCase(), songs[songSelec].toLowerCase());
            trace('Switching to PlayState with song: ' + PlayState.SONG.song);

            LoadingState.loadAndSwitchState(new PlayState());
        }
        else
        {
            trace('Error: No songs available for the selected week.');
        }
    }
}
