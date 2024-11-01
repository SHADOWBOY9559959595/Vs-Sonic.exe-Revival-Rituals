package backend;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var mustHitSection:Bool;
	var gfSection:Bool;
	var dad2Section:Bool;
	var bf2Section:Bool;
	var dadsDuetSection:Bool;
	var bfsDuetSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];

	public var sectionBeats:Float = 4;
	public var gfSection:Bool = false;
	public var dad2Section:Bool = false;
	public var bf2Section:Bool = false;
	public var dadsDuetSection:Bool = false;
	public var bfsDuetSection:Bool = false;
	public var mustHitSection:Bool = true;

	public function new(sectionBeats:Float = 4)
	{
		this.sectionBeats = sectionBeats;
		trace('test created section: ' + sectionBeats);
	}
}
