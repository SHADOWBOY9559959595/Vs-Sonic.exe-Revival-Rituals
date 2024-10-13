package backend;

class CharSongList
{
    public static var data:Map<String,Array<String>> = [
      'majin' => ['endless', 'endless-og', 'endless-us', 'endless-jp', 'endeavours'],
      'lordx' => ['execution', 'cycles', 'hellbent', 'fate', 'judgement', 'gatekeepers'],
      'devoid' => ['trickery'],
      'tailsdoll' => ['sunshine', 'soulles'],
      'noname' => ['forever-unnamed'],
      'sallyalt' => ['agony'],
      'exeterior' => ['sharpy-showdown'],
      'fleetway' => ['chaos', 'running-wild', 'heroes-and-villains'],
      'fatalerror' => ['fatality'],
      'starved' => ['prey', 'fight-or-flight'],
      'xterion' => ['substantial', 'digitalized'],
      'educator' => ['expulsion'],
      'normalcd' => ['found-you'],
      'needlem0use' => ['relax', 'round-a-bout', 'spike-trap'],
      'luther' => ['her-world'],
      'sunky' => ['milk'],
      'sanic' => ['too-fest'],
      'coldsteel' => ['personel', 'personel-serious'],
      'sonichu' => ['shocker', 'extreme-zap'],
      'sonic' => ['soured'],
      'uglysonic' => ['ugly'],
      'lumpysonic' => ['frenzy'],
      'melthog' => ['melting', 'confronting'],
      'faker' => ['faker', 'black-sun', 'godspeed'],
      'chaotix' => ['my-horizon', 'our-horizon'],
      'requital' => ['foretall-desire'],
      'hog' => ['hedge', 'manual-blast'],
      'grimeware' => ['gorefest'],
      'curse' => ['malediction', 'extricate-hex'],
      'monobw' => ['color-blind'],
      'nmi' => ['fake-baby'],
      'dsk' => ['miasma'],
      'demogringriatos' => ['insidious', 'haze', 'marauder'],
      'blaze' => ['burning'],
      'satanos' => ['perdition', 'underworld', 'purgatory'],
      'apollyon' => ['genesis', 'proverbs', 'corinthians', 'revelations'],
      'bratwurst' => ['gods-will'],
      'sl4sh' => ['b4cksl4sh'],
      'hellmas' => ['missiletoe', 'slaybells', 'jingle-hells'],
      'batman' => ['gotta-go'],
      'secrethistory' => ['mania'],
      'omw' => ['universal-collapse'],
      'gameover' => ['too-far']
    ];

    public static var characters:Array<String> = ['majin', 'lordx', 'devoid', 'tailsdoll', 'noname', 'sallyalt', 'exeterior', 'fleetway', 'fatalerror', 'starved', 'xterion', 'educator', 'normalcd', 'needlem0use', 'luther', 'sunky', 'sanic', 'coldsteel', 'sonichu', 'sonic', 'uglysonic', 'lumpysonic', 'melthog', 'faker', 'chaotix', 'requital', 'hog', 'grimeware', 'curse', 'monobw', 'nmi', 'dsk', 'demogringriatos', 'blaze', 'satanos', 'apollyon', 'bratwurst', 'sl4sh', 'hellmas', 'batman', 'secrethistory', 'omw', 'gameover'];

    // TODO: maybe a character display names map? for the top left in FreeplayState

    public static var songToChar:Map<String,String>=[];

    public static function init(){ // can PROBABLY use a macro for this? but i have no clue how they work so lmao
      // trust me I tried
      // if shubs or smth wants to give it a shot then go ahead
      // - neb
      songToChar.clear();
      for(character in data.keys()){
        var songs = data.get(character);
        for(song in songs)songToChar.set(song,character);
      }
    }

    public static function getSongsByChar(char:String)
    {
      if(data.exists(char))return data.get(char);
      return [];
    }

    public static function isLastSong(song:String)
    {
        /*for (i in songs)
        {
            if (i[i.length - 1] == song) return true;
        }
        return false;*/
      if(!songToChar.exists(song))return true;
      var songList = getSongsByChar(songToChar.get(song));
      return songList[songList.length-1]==song;
    }
}
