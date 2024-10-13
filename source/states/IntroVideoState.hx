package states;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;

import states.TitleState;

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end

class IntroVideoState extends MusicBeatState
{	

    override public function create():Void    {
            FlxG.mouse.visible = false;

            startVideo("introVideo");
        }

    public function startVideo(name:String):Void
        {
            #if VIDEOS_ALLOWED
            var introvideo:String = Paths.video(name);
            #if sys
            if(!FileSystem.exists(introvideo))
            #else
            if(!OpenFlAssets.exists(introvideo))
            #end
            {
                FlxG.log.warn('Couldnt find video file: ' + name);
                return;
            }
            var video:VideoHandler = new VideoHandler();
            #if (hxCodec >= "3.0.0")
            video.play(introvideo);
            video.onEndReached.add(function() // REMOVE THE SPACE BETWEEN on AND End!!!!!!
				{
                    MusicBeatState.switchState(new TitleState());
                }, true);
            #else
            FlxG.log.warn('Platform not supported!');
            #end
            #end
    }
}