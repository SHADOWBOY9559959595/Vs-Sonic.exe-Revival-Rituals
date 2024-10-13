package states;

import backend.WeekData;
import backend.Highscore;

import flixel.input.keyboard.FlxKey;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import shaders.ColorSwap;

import states.StoryMenuState;
import states.MainMenuState;


class TitleState extends MusicBeatState
{	

	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	var bg:FlxSprite;
	var sidebar1:FlxSprite;
    var sidebar2:FlxSprite;
	var sidebarScrollSpeed:Float = 70; // Adjust this speed as needed
	var logo:FlxSprite;
	var titleEnter:FlxSprite;

	var enterPressed:Bool = false;

	override public function create():Void
		{
			Paths.clearStoredMemory();

			#if LUA_ALLOWED
			Mods.pushGlobalMods();
			#end
			Mods.loadTopMod();
			
			FlxG.save.bind('funkin', CoolUtil.getSavePath());
			ClientPrefs.loadPrefs();

			FlxG.mouse.visible = false;		

			bg = new FlxSprite().loadGraphic(Paths.image('TitleState/bg'));
			bg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
			bg.updateHitbox();
			bg.scrollFactor.set();

			// Scrolling sidebars
			sidebar1 = new FlxSprite().loadGraphic(Paths.image('TitleState/bars'));
			sidebar1.updateHitbox();
			sidebar1.x = FlxG.width - sidebar1.width;
			sidebar1.y = 0;
			sidebar1.scrollFactor.set();
			
			sidebar2 = new FlxSprite().loadGraphic(Paths.image('TitleState/bars'));
			sidebar2.updateHitbox();
			sidebar2.x = FlxG.width - sidebar2.width;
			sidebar2.y = -sidebar2.height;
			sidebar2.scrollFactor.set();

			logo = new FlxSprite().loadGraphic(Paths.image('TitleState/logo'));
			logo.scale.set(0.55, 0.55);
			logo.screenCenter(X);
			logo.screenCenter(Y);
			logo.y += 20;

			titleEnter = new FlxSprite().setFrames(Paths.getSparrowAtlas('TitleState/titleEnter'));
			titleEnter.screenCenter(X);
			titleEnter.y += 50;
			titleEnter.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleEnter.animation.addByPrefix('pressed', "ENTER PRESSED", 12, false);
			titleEnter.animation.play('idle');

			FlxG.sound.play(Paths.sound('TitleLaugh'));

			new FlxTimer().start(1.55, function(tmr:FlxTimer)
                {
					FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.RED : 0xFFFF0000, 1.5);
					
					FlxG.sound.play(Paths.sound('IntroRING'));
					new FlxTimer().start(0.4, function(tmr:FlxTimer)
						{
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							
							// Initially set volume to 0
							FlxG.sound.music.volume = 0;
							
							// Tween the volume from 0 to 1 over 0.4 seconds
							FlxTween.num(0, 1, 0.4, function(volume:Float)
							{
								FlxG.sound.music.volume = volume;
							});
						
						});

					add(bg);			
					add(sidebar1);			
					add(sidebar2);			
					add(logo);
					add(titleEnter);
				});
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

			if (FlxG.keys.justPressed.ENTER && !enterPressed)
				{
					enterPressed = true;  // Set the flag to true to prevent further presses
		
					FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.RED : 0xFFFF0000, 1);
		
					titleEnter.animation.play('pressed', true);
					FlxG.sound.play(Paths.sound('menumomentclick'), 0.7);
		
					FlxTween.tween(bg, {alpha: 0}, 2.5, {ease: FlxEase.quartInOut});
					FlxTween.tween(titleEnter, {alpha: 0}, 2, {ease: FlxEase.quartInOut});
					FlxG.sound.play(Paths.sound('menulaugh'), 0.7);
		
					new FlxTimer().start(2, function(tmr:FlxTimer)
					{
						FlxTween.tween(logo, {alpha: 0}, 1.5, {ease: FlxEase.quartInOut});
					});    
		
					new FlxTimer().start(3.5, function(tmr:FlxTimer)
					{
						MusicBeatState.switchState(new MainMenuState());
					});
				}
		}
		
}