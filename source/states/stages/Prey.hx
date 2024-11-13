package states.stages;

import states.stages.objects.*;
import flixel.addons.display.FlxTiledSprite;
import flixel.tweens.FlxTween;

class Prey extends BaseStage
{
    //Inner Moving sprites
	var stardustBgPixel:FlxTiledSprite;

    //Outer Static sprites

    //characters go here

    //Layered Static Sprites
	var stardustFloorPixel:FlxTiledSprite;

    //speed shit
	var starvedSpeed:Float = 15;

	override function create()
	{ 
        //Inner Sprites
        stardustBgPixel = new FlxTiledSprite(Paths.image('stardustBg'), 4608, 2832, true, true);
        stardustBgPixel.scrollFactor.set(0.4, 0.4);
        stardustBgPixel.screenCenter();
        add(stardustBgPixel);
     
        //Static Sprites 

	}
    override function createPost()
    {
        //Layered Static Sprites
        stardustFloorPixel = new FlxTiledSprite(Paths.image('stardustFloor'), 4608, 2832, true, true);
        stardustFloorPixel.screenCenter();
        add(stardustFloorPixel);
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
                        FlxTween.tween(this, { starvedSpeed: value2 }, 2);
                    }
            }
        }

}