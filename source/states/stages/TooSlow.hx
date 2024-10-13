package states.stages;

import states.stages.objects.*;

class TooSlow extends BaseStage
{
    //Inner Moving sprites
    var bgSky:BGSprite;
    var treesMidBack:BGSprite;
    var treesMid:BGSprite;
    var treesOuterMid1:BGSprite;

    //Outer Static sprites
    var treesOuterMid2:BGSprite;
    var treesLeft:BGSprite;
    var treesRight:BGSprite;    
    var outerBush:BGSprite;
    var grass:BGSprite;
    var deadTailz1:BGSprite;

    var deadEgg:BGSprite;

    //characters go here

    //Layered Static Sprites
    var deadKnux:BGSprite;    
    var deadTailz2:BGSprite;    
    var outerBushUp:BGSprite;
    var treesFG:BGSprite;

	override function create()
	{
     
        
        //Inner Sprites
        bgSky = new BGSprite('BGSky', 0, 0, 0, 0);
        bgSky.scrollFactor.set(1, 0.5);
        bgSky.scale.set(1.3, 1.3);
        bgSky.screenCenter(X);
        bgSky.screenCenter(Y);  
        bgSky.y -= 50; 
        treesMidBack = new BGSprite('TreesMidBack', 0, 0, 0, 0);
        treesMidBack.scrollFactor.set(1, 0.5);
        treesMidBack.scale.set(1.3, 1.3);
        treesMidBack.screenCenter(X);
        treesMidBack.screenCenter(Y); 
        treesMidBack.y -= 50;
        treesMid = new BGSprite('TreesMid', 0, 0, 0, 0);    
        treesMid.scrollFactor.set(1, 0.5);
        treesMid.scale.set(1.3, 1.3);
        treesMid.screenCenter(X);
        treesMid.screenCenter(Y);
        treesMid.y -= 50;
        treesOuterMid1 = new BGSprite('TreesOuterMid1', 0, 0, 0, 0);
        treesOuterMid1.scrollFactor.set(1, 0.5);
        treesOuterMid1.scale.set(1.3, 1.3);
        treesOuterMid1.screenCenter(X);
        treesOuterMid1.screenCenter(Y);
        treesOuterMid1.y -= 50;
        add(bgSky);        
        add(treesMidBack);        
        add(treesMid);          
        add(treesOuterMid1);       
     
        //Static Sprites
        treesOuterMid2 = new BGSprite('TreesOuterMid1', 0, 0, 0, 0); 
        treesOuterMid2.scrollFactor.set(1, 1);
        treesOuterMid2.scale.set(1.3, 1.3);
        treesOuterMid2.screenCenter(X);
        treesOuterMid2.screenCenter(Y);
        treesLeft = new BGSprite('TreesLeft', 0, 0, 0, 0);
        treesLeft.scrollFactor.set(1, 1);
        treesLeft.scale.set(1.3, 1.3);
        treesLeft.screenCenter(X);
        treesLeft.screenCenter(Y);
        treesRight = new BGSprite('TreesRight', 0, 0, 0, 0);
        treesRight.scrollFactor.set(1, 1);      
        treesRight.scale.set(1.3, 1.3);
        treesRight.screenCenter(X);
        treesRight.screenCenter(Y);
        outerBush = new BGSprite('OuterBush', 0, 0, 0, 0);
        outerBush.scrollFactor.set(1, 1);
        outerBush.scale.set(1.3, 1.3);
        outerBush.screenCenter(X);
        outerBush.screenCenter(Y);
        grass = new BGSprite('Grass', 0, 0, 0, 0);
        grass.scrollFactor.set(1, 1);
        grass.scale.set(1.3, 1.3);
        grass.screenCenter(X);
        grass.screenCenter(Y);
        deadTailz1 = new BGSprite('DeadTailz1', 0, 0, 0, 0);
        deadTailz1.scrollFactor.set(1, 1);
        deadTailz1.scale.set(1.3, 1.3);
        deadTailz1.screenCenter(X);
        deadTailz1.screenCenter(Y);
     
        deadEgg = new BGSprite('DeadEgg', 0, 0, 0, 0);
        deadEgg.scrollFactor.set(1, 1);
        deadEgg.scale.set(1.3, 1.3);
        deadEgg.screenCenter(X);
        deadEgg.screenCenter(Y);   

        add(treesOuterMid2);        
        add(treesLeft);        
        add(treesRight);            
        add(outerBush);
        add(grass);
        add(deadTailz1);

        add(deadEgg);    

	}
    override function createPost()
    {
        //Layered Static Sprites
        deadKnux = new BGSprite('DeadKnux', 0, 0, 0, 0);
        deadKnux.scrollFactor.set(1, 1);
        deadKnux.scale.set(1.3, 1.3);
        deadKnux.screenCenter(X);
        deadKnux.screenCenter(Y);   
        deadTailz2 = new BGSprite('DeadTailz2', 0, 0, 0, 0);
        deadTailz2.scrollFactor.set(1, 1);
        deadTailz2.scale.set(1.3, 1.3);
        deadTailz2.screenCenter(X);
        deadTailz2.screenCenter(Y);
        outerBushUp = new BGSprite('OuterBushUp', 0, 0, 0, 0);
        outerBushUp.scrollFactor.set(1, 1);
        outerBushUp.scale.set(1.3, 1.3);
        outerBushUp.screenCenter(X);
        outerBushUp.screenCenter(Y);
        treesFG = new BGSprite('TreesFG', 0, 0, 0, 0);
        treesFG.scrollFactor.set(1, 1);
        treesFG.scale.set(1.3, 1.3);
        treesFG.screenCenter(X);
        treesFG.screenCenter(Y);

      
        add(deadTailz2);
        add(deadKnux);      
        add(outerBushUp);
        add(treesFG);

    }

}