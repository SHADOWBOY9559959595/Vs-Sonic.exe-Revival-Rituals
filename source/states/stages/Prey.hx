package states.stages;

import states.stages.objects.*;
import flixel.addons.display.FlxTiledSprite;
import flixel.tweens.FlxTween;

class Prey extends BaseStage
{
    //Inner Moving sprites
	public static var stardustBgPixel:FlxTiledSprite;

    //Outer Static sprites
    var stardustFurnace:FlxSprite;

    //characters go here

    //Layered Static Sprites
	public static var stardustFloorPixel:FlxTiledSprite;

    //speed shit
	var starvedSpeed:Float = 25;

    var dadX:Float;

	override function create()
	{ 
        dadX = PlayState.instance.DAD_X;

        //Inner Sprites
        stardustBgPixel = new FlxTiledSprite(Paths.image('stardustBg'), 4608, 2832, true, true);
        stardustBgPixel.scale.x = 5;
		stardustBgPixel.scale.y = 5;
        stardustBgPixel.scrollFactor.set(0.4, 0.4);
        stardustBgPixel.screenCenter();
        stardustBgPixel.visible = false;
        add(stardustBgPixel);
     
        //Static Sprites 

	}
    override function createPost()
    {
        //Layered Static Sprites
        stardustFloorPixel = new FlxTiledSprite(Paths.image('stardustFloor'), 4608, 2832, true, true);
        stardustFloorPixel.scale.x = 5;
        stardustFloorPixel.scale.y = 5;
        stardustFloorPixel.screenCenter();
        stardustFloorPixel.visible = false;
        add(stardustFloorPixel);

        //Outer Static Sprites
        stardustFurnace = new FlxSprite(-500, 1450);
        stardustFurnace.frames = Paths.getSparrowAtlas('Furnace_sheet');
        stardustFurnace.animation.addByPrefix('idle', 'Furnace idle', 24, true);
        stardustFurnace.animation.play('idle');
        stardustFurnace.scale.x = 6;
        stardustFurnace.scale.y = 6;
        stardustFurnace.visible = false;
        stardustFurnace.antialiasing = false;
        add(stardustFurnace);

    }
    override public function update(elapsed:Float)
    {
        stardustBgPixel.scrollX -= (starvedSpeed * stardustBgPixel.scrollFactor.x) * (elapsed/(1/120));
        stardustFloorPixel.scrollX -= starvedSpeed * (elapsed/(1/120));
    }
    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
        {
            switch(eventName)
            {
                case "Stage Change":
                    if (value1 == "Prey")
                    {
                        var values:Array<String> = value2.split(",");
                        if (values.length == 2)
                        {
                            var eventId:Int = Std.parseInt(values[0].trim());
                            var eventValue:Float = Std.parseFloat(values[1].trim());
                    

                            switch(eventId)
                            {
                                case 0:
                                    FlxTween.tween(this, { starvedSpeed: eventValue}, 3);
                                case 1:
                                    FlxG.camera.flash(FlxColor.WHITE, 2);
                                    dad.visible = true;
                                    stardustBgPixel.visible = true;
                                    stardustFloorPixel.visible = true;
                                case 2:        
                                    trace ('furnace will tween into ' + dadX);
                                    FlxTween.tween(dad, {x: dadX}, 1);
                                    FlxTween.tween(camHUD, {alpha: 1}, 1.2);
                                case 3:
                                    FlxTween.tween(dad, {x: -1500}, 5, {onComplete: function(tween:FlxTween) {
                                        dad.visible = false;
                                    }});                                
                                    FlxTween.angle(dad, 0, -180, 5, {ease: FlxEase.cubeInOut});
                                case 4:
                                    dad.x = -1500;
                                    dad.y = -50;
                                    FlxTween.tween(dad, {x: 800}, 2.5,{ease: FlxEase.cubeInOut});
                                case 5:
                                    if (eventValue == 0) FlxTween.tween(camHUD, {alpha: 0}, 1);
                                    else if (eventValue == 1) FlxTween.tween(camHUD, {alpha: 1}, 1);
                                case 6: 
                                    trace ('Furnace is flying');
                                    stardustFurnace.visible = true;
                                    FlxTween.tween(stardustFurnace, {x: 3000}, 7);
                            }
                        }
                    }
            }
        }
}