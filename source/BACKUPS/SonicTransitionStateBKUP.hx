package backend;

import flixel.util.FlxGradient;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import shaders.BlueMaskShader;

class SonicTransitionStateBKUP extends MusicBeatSubstate {
    public static var skipNextTransIn:Bool = false;
    public static var skipNextTransOut:Bool = false;
    
    public static var finishCallback:Void->Void;
    var isTransIn:Bool = false;
    var transBlack:FlxSprite;
    var transGradient:FlxSprite;
    public static var shape:String = 'head';
    var theShape:FlxSprite; // New sprite for scaling effect

    var duration:Float;
    var transitionTime:Float = 1; // Duration for scaling transition
    var minScale:Float = 0.2; // Maximum scale for the sprite
    var maxScale:Float = 6; // Maximum scale for the sprite
    
    public function new(duration:Float, isTransIn:Bool) {
        this.duration = duration;
        this.isTransIn = isTransIn;
        super();
    }

    override function create() {
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
        var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
        var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
        
        // Create gradient sprite
        transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
        transGradient.scale.x = width;
        transGradient.updateHitbox();
        transGradient.scrollFactor.set();
        transGradient.screenCenter(X);

        // Create black sprite
        transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
        transBlack.scale.set(width, height + 400);
        transBlack.updateHitbox();
        transBlack.scrollFactor.set();
        transBlack.screenCenter(X);

        // Create the new sprite for scaling effect
        theShape = new FlxSprite().loadGraphic(Paths.image('transition/' + shape));
        theShape.screenCenter(XY);
        

        if(isTransIn) {
            transGradient.y = transBlack.y - transBlack.height;
            theShape.scale.set(minScale, minScale); // Start small for transition-in
        } else {
            transGradient.y = -transGradient.height;
            theShape.scale.set(maxScale, maxScale); // Start large for transition-out
        }

        if (skipNextTransIn || skipNextTransOut) {
            // Do nothing if skipNextTransIn or skipNextTransOut is true
        } else {
            add(theShape);
        }
        
        super.create();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
        final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);
        
        // Update gradient position
        if(duration > 0)
            transGradient.y += (height + targetPos) * elapsed / duration;
        else
            transGradient.y = (targetPos) * elapsed;

        if(isTransIn)
            transBlack.y = transGradient.y + transGradient.height;
        else
            transBlack.y = transGradient.y - transBlack.height;

        // Update sprite scale
        var progress:Float = (transGradient.y - (isTransIn ? transBlack.y - transBlack.height : -transGradient.height)) / (targetPos - (isTransIn ? transBlack.y - transBlack.height : -transGradient.height));

        if(isTransIn) {
            // Ensure theShape reaches maxScale
            theShape.scale.set(FlxMath.lerp(minScale, maxScale, progress), FlxMath.lerp(minScale, maxScale, progress));  
        } else {
            // Shrinking logic for transition-out
            theShape.scale.set(FlxMath.lerp(maxScale, minScale, progress), FlxMath.lerp(maxScale, minScale, progress));
        }

        theShape.screenCenter(XY);

        // End transition and call callback
        if(transGradient.y >= targetPos) {
            // Set the scale to maxScale explicitly when the transition ends
            if(isTransIn) {
                theShape.scale.set(maxScale, maxScale); // Ensure it reaches maxScale
            } else {
                theShape.scale.set(minScale, minScale); // Ensure it shrinks to minScale
            }

            close();
            if(finishCallback != null) finishCallback();
            finishCallback = null;
        }
    }
}
