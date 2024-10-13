package states.stages;

import states.stages.objects.*;

class Fleetway extends BaseStage
{
    //Inner Moving sprites
    var wall:FlxSprite;

    //Outer Static sprites
    var floor:FlxSprite;
    var bgShit:FlxSprite;
    var beamUncharged:FlxSprite;
    var beamCharged:FlxSprite;
    var emeralds:FlxSprite;
    var chamber:FlxSprite;

    //characters go here

    //Layered Static Sprites
    var pebbles:FlxSprite;   
    var jhonPork:FlxSprite;   //its jhon pork, fight me sonic.exe team

	override function create()
	{
        //Inner Sprites
        wall = new FlxSprite(-2379.05, -1211.1).setFrames(Paths.getSparrowAtlas('Wall'));
        wall.animation.addByPrefix('gud', 'Wall instance', 25, true);
        wall.animation.addByPrefix('nogud', 'Wall Broken instance', 25, true);
        wall.animation.play('gud');
        wall.scrollFactor.set(1, 0.5);
        wall.scale.set(1.3, 1.3); 
        wall.y += 500;
        wall.x -= 500;
        add(wall);

        //Static Sprites

        floor = new FlxSprite(-2349, 1000).setFrames(Paths.getSparrowAtlas('Floor'));
        floor.animation.addByPrefix('blue', 'floor blue', 25, true);
        floor.animation.addByPrefix('yellow', 'floor yellow', 25, true);
        floor.animation.play('blue');
        floor.scrollFactor.set(1, 1);
        floor.scale.set(1, 1); 
        bgShit = new FlxSprite(-2629.05, -1344.05).setFrames(Paths.getSparrowAtlas('FleetwayBGshit'));
        bgShit.animation.addByPrefix('blue', 'BGblue', 25, true);
        bgShit.animation.addByPrefix('yellow', 'BGyellow', 25, true);
        bgShit.animation.play('blue');
        bgShit.scrollFactor.set(1, 1);
        bgShit.scale.set(1, 1);
        beamUncharged = new FlxSprite(0, -1376.95 - 200).setFrames(Paths.getSparrowAtlas('Emerald Beam'));
        beamUncharged.animation.addByPrefix('bohoo', 'Emerald Beam instance', 25, true);
        beamUncharged.animation.play('bohoo');
        beamUncharged.scrollFactor.set(1, 1);
        beamUncharged.scale.set(1, 1);
        beamUncharged.visible = true;
        beamCharged = new FlxSprite(-300, -1376.95 - 200).setFrames(Paths.getSparrowAtlas('Emerald Beam Charged'));
        beamCharged.animation.addByPrefix('omg', 'Emerald Beam Charged instance', 25, true);
        beamCharged.animation.play('omg');
        beamCharged.scrollFactor.set(1, 1);
        beamCharged.scale.set(1, 1);
        beamCharged.visible = false;
        emeralds = new FlxSprite(326.6, -191.75).setFrames(Paths.getSparrowAtlas('Emeralds'));
        emeralds.animation.addByPrefix('boo', 'TheEmeralds instance', 25, true);
        emeralds.animation.play('boo');
        emeralds.scrollFactor.set(1, 1);
        emeralds.scale.set(1, 1);

        add(floor);        
        add(bgShit);        
        add(beamUncharged);            
        add(beamCharged);
        add(emeralds);


        switch (songName)
        {
            case 'chaos':
                setStartCallback(chaosIntro);
        }
	}
    override function createPost()
    {
        //Layered Static Sprites
        chamber = new FlxSprite(-225.05, 463.9).setFrames(Paths.getSparrowAtlas('The Chamber'));
        chamber.animation.addByPrefix('woah', 'Chamber Sonic Fall', 25, false);
        chamber.scrollFactor.set(1, 1);
        chamber.scale.set(1, 1);        
        pebbles = new FlxSprite(-562.15 + 100, 1043.3).setFrames(Paths.getSparrowAtlas('pebles'));
        pebbles.animation.addByPrefix('bruh', 'pebles instance', 25, true);
        pebbles.animation.play('bruh');
        pebbles.scrollFactor.set(1, 1);
        pebbles.scale.set(1, 1);
        jhonPork = new FlxSprite(2880.15, -762.8).setFrames(Paths.getSparrowAtlas('Porker Lewis'));
        jhonPork.animation.addByPrefix('gobf', 'Porker FG', 25, true);
        jhonPork.animation.play('gobf');
        jhonPork.scrollFactor.set(1, 1);
        jhonPork.scale.set(1, 1);
        jhonPork.x -= 500;

        add(chamber);      
        add(pebbles);
        add(jhonPork);      

    }
    
	function chaosIntro()
        {
            FlxTween.tween(dad, {x: 600, y: 800}, 0.1, {ease: FlxEase.cubeOut});            
            camFollow.x += -250;
            camFollow.y += 700;            
            FlxG.camera.zoom = defaultCamZoom;
            camHUD.visible = false;
            dad.visible = false;
            boyfriend.visible = false;

            new FlxTimer().start(0.5, function(lol:FlxTimer)
                {
                    new FlxTimer().start(1, function(lol:FlxTimer)
                        {

                            FlxTween.tween(FlxG.camera, {zoom: 1.3}, 2, {ease: FlxEase.cubeOut});
                            FlxG.sound.play(Paths.sound('Fleetway/robot'));
                            FlxG.camera.flash(FlxColor.RED, 0.2);
                        });
                        new FlxTimer().start(2, function(lol:FlxTimer)
                        {
                            FlxG.sound.play(Paths.sound('Fleetway/sonic'));
                            chamber.animation.play('woah');
                            
                        });

                    new FlxTimer().start(6, function(lol:FlxTimer)
                    {
                        startCountdown();                                
                        dad.visible = true;
                        FlxG.sound.play(Paths.sound('Fleetway/beam'));
                        camFollow.y -= 500;      
                        FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.2, {ease: FlxEase.cubeOut});
                        FlxG.camera.shake(0.02, 0.2);
                        FlxG.camera.flash(FlxColor.WHITE, 0.2);
                        wall.animation.play('nogud');
                        floor.animation.play('yellow');
                        bgShit.animation.play('yellow');
                        pebbles.animation.play('yellow');
                        beamUncharged.visible = false;
                        beamCharged.visible = true;

                        new FlxTimer().start(0.7, function(lol:FlxTimer)
                            {
                                FlxTween.tween(dad, {x: 600, y: -400}, 0.8, {ease: FlxEase.cubeOut});
                            });

                        
                        new FlxTimer().start(4.9, function(lol:FlxTimer)
                            {
                                camHUD.visible = true;
                                boyfriend.visible = true;
                            });
                    });
                });
    }
}