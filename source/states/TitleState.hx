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
	var logo:FlxSprite;	
	var spikes:FlxSprite;
	var spikes2:FlxSprite;
	var titleEnter:FlxSprite;
	var vignette:FlxSprite;

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

			bg = new FlxSprite().setFrames(Paths.getSparrowAtlas('TitleState/static'));
			bg.screenCenter(XY);
			bg.animation.addByPrefix('idle', "anim", 10);
			bg.animation.play('idle');

			logo = new FlxSprite().loadGraphic(Paths.image('TitleState/logo'));
			logo.screenCenter(XY);
			logo.scale.set(0.5, 0.5);
			logo.y -= 20;
			logo.x = -650;

			titleEnter = new FlxSprite().setFrames(Paths.getSparrowAtlas('TitleState/titleEnter'));
			titleEnter.scale.set(0.7, 0.7);
			titleEnter.screenCenter(XY);
			titleEnter.x = 300;
			titleEnter.y -= 150;
			titleEnter.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleEnter.animation.addByPrefix('pressed', "ENTER PRESSED", 12, false);
			titleEnter.animation.play('idle');

			vignette = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
			vignette.alpha = 0.4;
			vignette.screenCenter(XY);

			FlxG.sound.play(Paths.sound('TitleLaugh'));

			new FlxTimer().start(1.55, function(tmr:FlxTimer)
                {
					FlxG.camera.flash(FlxColor.RED, 1.5);
					
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
					add(logo);
					add(spikes);	
					add(spikes2);	
					add(titleEnter);
					add(vignette);
				});
		}
	override public function update(elapsed:Float):Void
		{
			super.update(elapsed);

			if (FlxG.keys.justPressed.ENTER && !enterPressed)
				{
					enterPressed = true;  // Set the flag to true to prevent further presses
		
					FlxG.camera.flash(FlxColor.RED, 1);
		
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