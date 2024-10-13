package states.stages;

import states.stages.objects.*;

class MajinForestBlue extends BaseStage
{
    //Inner Moving sprites
    var sonicFUNsky:BGSprite;
    var majinBoopersBack:FlxSprite;
    var bush2:BGSprite;
    //Outer Static sprites
    var bush1:BGSprite;
    var majinBoopersFront:FlxSprite;
    var floorBG:BGSprite;

    //characters go here

    //Layered Static Sprites
    var majinFG1:FlxSprite;
    var majinFG2:FlxSprite;
    var overlay:BGSprite;


	override function create()
	{
        //Inner Sprites
        sonicFUNsky = new BGSprite('sonicFUNsky', 0, 0, 0, 0);
        sonicFUNsky.scrollFactor.set(1, 0.5);
        sonicFUNsky.scale.set(1.3, 1.3);
        sonicFUNsky.screenCenter(X);
        sonicFUNsky.screenCenter(Y);  
        sonicFUNsky.y -= 50; 
        majinBoopersBack = new FlxSprite().setFrames(Paths.getSparrowAtlas('majinBoopersBack'));
        majinBoopersBack.animation.addByPrefix('Bop', 'MajinBop2 instance', 25, true);
        majinBoopersBack.animation.play('Bop');
        majinBoopersBack.scrollFactor.set(1, 0.5);
        majinBoopersBack.scale.set(1, 1);
        majinBoopersBack.screenCenter(X);
        majinBoopersBack.screenCenter(Y);  
        majinBoopersBack.y -= 200;         
        bush2 = new BGSprite('bush2', 0, 0, 0, 0);
        bush2.scrollFactor.set(1, 0.5);
        bush2.scale.set(1.3, 1.3);
        bush2.screenCenter(X);
        bush2.screenCenter(Y);          
        bush2.y += 300; 

        add(sonicFUNsky);
        add(majinBoopersBack);        
        add(bush2);
        //Static Sprites
        majinBoopersFront = new FlxSprite().setFrames(Paths.getSparrowAtlas('majinBoopersFront'));
        majinBoopersFront.animation.addByPrefix('Bop', 'MajinBop1 instance', 25, true);
        majinBoopersFront.animation.play('Bop');
        majinBoopersFront.scrollFactor.set(1, 0.5);
        majinBoopersFront.scale.set(1, 1);
        majinBoopersFront.screenCenter(X);
        majinBoopersFront.screenCenter(Y);  
        majinBoopersFront.y -= 200; 
        bush1 = new BGSprite('bush1', 0, 0, 0, 0); 
        bush1.scrollFactor.set(1, 1);
        bush1.scale.set(1.3, 1.3);
        bush1.screenCenter(X);
        bush1.screenCenter(Y);        
        floorBG = new BGSprite('floorBG', 0, 0, 0, 0); 
        floorBG.scrollFactor.set(1, 1);
        floorBG.scale.set(1.3, 1.3);
        floorBG.screenCenter(X);
        floorBG.screenCenter(Y);
        add(majinBoopersFront);        
        add(bush1);
        add(floorBG);
	}
    override function createPost()
    {
        //Layered Static Sprites
        majinFG1 = new FlxSprite().setFrames(Paths.getSparrowAtlas('majinFG1'));
        majinFG1.animation.addByPrefix('Bop', 'majin front bopper1', 25, true);
        majinFG1.animation.play('Bop');
        majinFG1.scrollFactor.set(1, 0.5);
        majinFG1.scale.set(1, 1); 
        majinFG1.y += 480;   
        majinFG1.screenCenter(X); 
        majinFG1.x += 600;
        majinFG2 = new FlxSprite().setFrames(Paths.getSparrowAtlas('majinFG2'));
        majinFG2.animation.addByPrefix('Bop', 'majin front bopper2', 25, true);
        majinFG2.animation.play('Bop');
        majinFG2.scrollFactor.set(1, 0.5);
        majinFG2.scale.set(1, 1);
        majinFG2.y += 480;     
        majinFG2.screenCenter(X);
        majinFG2.x += -845;
        //majin boopers FG2 go here (PLACEHOLDER)
        overlay = new BGSprite('overlay', 0, 0, 0, 0); 
        overlay.scrollFactor.set(1, 1);
        overlay.scale.set(1.5, 1.5);
        overlay.alpha = 0.6;
        overlay.screenCenter(X);
        overlay.screenCenter(Y);
        overlay.y -= 100;
        add(majinFG1);
        add(majinFG2);
        add(overlay);
    }

}