package states.stages;

import states.stages.objects.*;
import states.PlayState;
import backend.StageData;

class YCR extends BaseStage
{
    //Inner Moving sprites
    var sky:BGSprite;
    var backtrees:BGSprite;
    //Outer Static sprites
    var trees:BGSprite;
    var ground:BGSprite;

    //GREN HILL SHIT

    //Inner Moving sprites
    var skyGH:BGSprite;
    var mountainsGH:FlxSprite;
    var waterGH:FlxSprite;
    //Outer Static sprites
    var groundGH:BGSprite;
    var flowersGH:FlxSprite;
    var objectsGH:FlxSprite;

	override function create()
	{

        //Inner Sprites
        sky = new BGSprite('P1/sky', 0, 0, 0, 0);
        sky.scrollFactor.set(1, 0.5);
        sky.scale.set(1.3, 1.3);
        sky.screenCenter(X);
        sky.screenCenter(Y);  
        sky.y -= 50; 
        backtrees = new BGSprite('P1/backtrees', 0, 0, 0, 0);
        backtrees.scrollFactor.set(1, 0.5);
        backtrees.scale.set(1.3, 1.3);
        backtrees.screenCenter(X);
        backtrees.screenCenter(Y); 
        backtrees.y -= 50;    
     
        //Static Sprites
        trees = new BGSprite('P1/trees', 0, 0, 0, 0); 
        trees.scrollFactor.set(1, 1);
        trees.scale.set(1.3, 1.3);
        trees.screenCenter(X);
        trees.screenCenter(Y);
        ground = new BGSprite('P1/ground', 0, 0, 0, 0);
        ground.scrollFactor.set(1, 1);
        ground.scale.set(1.3, 1.3);
        ground.screenCenter(X);
        ground.screenCenter(Y);  

        add(sky);
        add(backtrees);
        add(trees);        
        add(ground);

        //GREEN HILL SHIT WOHOOOO
        //Inner Sprites
        skyGH = new BGSprite('P2/bg3', 0, 0, 0, 0);
        skyGH.scrollFactor.set(1, 0.5);
        skyGH.scale.set(6, 6);
        skyGH.screenCenter(X);
        skyGH.screenCenter(Y);  
        skyGH.y -= 200; 
        skyGH.visible = false;
        mountainsGH = new FlxSprite().setFrames(Paths.getSparrowAtlas('P2/bg2'));
        mountainsGH.animation.addByPrefix('Move', 'bg2', 25, true);
        mountainsGH.animation.play('Move');
        mountainsGH.scrollFactor.set(1, 0.5);
        mountainsGH.scale.set(6, 6);
        mountainsGH.screenCenter(X);
        mountainsGH.screenCenter(Y);  
        mountainsGH.y -= 200;  
        mountainsGH.visible = false;
        waterGH = new FlxSprite().setFrames(Paths.getSparrowAtlas('P2/bg1'));
        waterGH.animation.addByPrefix('Move', 'bg1', 25, true);
        waterGH.animation.play('Move');
        waterGH.scrollFactor.set(1, 0.5);
        waterGH.scale.set(6, 6);
        waterGH.screenCenter(X);
        waterGH.screenCenter(Y);  
        waterGH.y -= 200;  
        waterGH.visible = false;
        //Static Sprites
        groundGH = new BGSprite('P2/GHGround', 0, 0, 0, 0);
        groundGH.scrollFactor.set(1, 1);
        groundGH.scale.set(5.4, 5.4);
        groundGH.screenCenter(X);
        groundGH.screenCenter(Y);
        groundGH.visible = false;
        flowersGH = new FlxSprite().setFrames(Paths.getSparrowAtlas('P2/flowers'));
        flowersGH.animation.addByPrefix('Move', 'flowerloop', 25, true);
        flowersGH.animation.play('Move');
        flowersGH.scrollFactor.set(1, 1);
        flowersGH.scale.set(5.4, 5.4);
        flowersGH.screenCenter(X);
        flowersGH.screenCenter(Y);  
        flowersGH.visible = false;
        objectsGH = new FlxSprite().setFrames(Paths.getSparrowAtlas('P2/objects'));
        objectsGH.animation.addByPrefix('Move', 'objects', 25, true);
        objectsGH.animation.play('Move');
        objectsGH.scrollFactor.set(1, 1);
        objectsGH.scale.set(5.4, 5.4);
        objectsGH.screenCenter(X);
        objectsGH.screenCenter(Y);  
        objectsGH.visible = false;

        add(skyGH);       
        add(mountainsGH);
        add(waterGH);
        add(groundGH);       
        add(flowersGH);
        add(objectsGH);
    
	}

    override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
        {
            switch(eventName)
            {
                case "Stage Change":
                    if (value1 == "Green Hill")
                    {
                        if (value2 == "1") {

                            sky.visible = false;
                            backtrees.visible = false;
                            trees.visible = false;
                            ground.visible = false;

                            skyGH.visible = true;
                            mountainsGH.visible = true;
                            waterGH.visible = true;
                            groundGH.visible = true;
                            flowersGH.visible = true;
                            objectsGH.visible = true;
                        } else if (value2 == "2") {

                            sky.visible = true;
                            backtrees.visible = true;
                            trees.visible = true;
                            ground.visible = true;

                            skyGH.visible = false;
                            mountainsGH.visible = false;
                            waterGH.visible = false;
                            groundGH.visible = false;
                            flowersGH.visible = false;
                            objectsGH.visible = false;
                        }
                    }
            }
        }
}