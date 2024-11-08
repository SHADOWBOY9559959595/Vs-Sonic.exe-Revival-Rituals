package states.stages;

import states.stages.objects.*;
import shaders.ColorSwap;

class NeedleMouse extends BaseStage
{
    //Shader for circel
    var swagShader:ColorSwap = null;

    //Inner Moving sprites
    var needleSky:BGSprite;
    var needleMoutains:BGSprite;

    //Outer Static sprites
    var needleRuins:BGSprite;
    var needleBuildings:BGSprite;
    var conkCreet:BGSprite;    
    //Bad needle
    var circle:FlxSprite;

    //characters go here

    //Layered Static Sprites
    var needleFg:BGSprite;    

	override function create()
	{
        //Inner Moving Sprites
        needleSky = new BGSprite('sky', -725, -200, 0.7, 0.9);
        needleSky.scrollFactor.set(1, 0.5);
        needleMoutains = new BGSprite('mountains', -700, -175, 0.8, 0.9);
        needleMoutains.setGraphicSize(Std.int(needleMoutains.width * 1.1));
        needleMoutains.scrollFactor.set(1, 0.5);
        add(needleSky);
        add(needleMoutains);

        //Outer Static sprites
        needleRuins = new BGSprite('ruins', -775, -310, 1, 0.9);
        needleRuins.setGraphicSize(Std.int(needleRuins.width * 1.4));
        needleRuins.scrollFactor.set(1, 1);
        needleBuildings = new BGSprite('buildings', -1000, -100, 1, 0.9);
        needleBuildings.scrollFactor.set(1, 1);
        conkCreet = new BGSprite('CONK_CREET', -775, -310, 1, 0.9);
        conkCreet.setGraphicSize(Std.int(conkCreet.width * 1.4));
        conkCreet.scrollFactor.set(1, 1);

        swagShader = new ColorSwap();
        swagShader.hue = 0.75;
        swagShader.brightness = 0;
        swagShader.saturation = 0.5;

        circle = new BGSprite('basecirc', -190, 1000);
        circle.setGraphicSize(Std.int(circle.width * 1.4));
        circle.scrollFactor.set(1, 1); 
        circle.shader = swagShader.shader;
        circle.visible = false;

        add(needleRuins);
        add(needleBuildings);
        add(conkCreet);
        add(circle);
	}
    override function createPost()
    {
        //Layered Static Sprites
        needleFg = new BGSprite('fg', -690, -80, 1, 0.9);
        needleFg.setGraphicSize(Std.int(needleFg.width * 1.1));
        needleFg.scrollFactor.set(1, 1);      
        add(needleFg);

    }

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
        {
            switch(eventName)
            {
                case "Stage Change":
                    if (value1 == "NeedleMouse")
                    {
                        if (value2 == "1") {
                            needleSky.visible = false;
                            needleMoutains.visible = false;
                            needleRuins.visible = false;
                            needleBuildings.visible = false;
                            conkCreet.visible = false;
                            needleFg.visible = false;
                            circle.visible = true;
                        } else if (value2 == "2") {
                            needleSky.visible = true;
                            needleMoutains.visible = true;
                            needleRuins.visible = true;
                            needleBuildings.visible = true;
                            conkCreet.visible = true;
                            needleFg.visible = true;
                            circle.visible = false;
                        }
                    }
            }
        }

}