package;

import hscript.*;
import sys.io.File;
import sys.FileSystem;
import lime.utils.Assets;

using StringTools;

typedef ImportShit = {
	var library:String;
	var like:String;
}

enum HScriptCallType
{
	CALLBACK;
	FUNCTION;
}

class HScriptHandler
{
	public static var parser:Parser = new Parser();
	public var interp:Interp;

	public var variables(get, never):Map<String, Dynamic>;

	public function get_variables()
	{
		return interp.variables;
	}

	public function new(file:String)
	{
		interp = new Interp();
		if (FileSystem.exists(Paths.getPreloadPath('not_source/' + file + '.hx')) #if MODS_ALLOWED || FileSystem.exists(Paths.modFolders('not_source/' + file + '.hx')) #end)
		{
			execute(Paths.getTextFromFile('not_source/' + file + '.hx'));
			trace('HScript loaded succesfully: ' + file);
		}
		addCallbacks();
	}

	private function execute(codeToRun:String):Dynamic
	{
		@:privateAccess
		parser.line = 1;
		parser.allowTypes = true;
		return interp.execute(parser.parseString(codeToRun));
	}

	public function call(type:HScriptCallType, name:String, value:Dynamic = 0)
	{
		switch(type)
		{
			case CALLBACK:
				interp.variables.set(name, value);

			case FUNCTION:
				if (!variables.exists(name)) {
					return;
				}
				var method = variables.get(name);
				switch(value.length)
				{
					case 0:
						method();
					case 1:
						method(value[0]);
					case 2:
						method(value[0], value[1]);
					case 3:
						method(value[0], value[1], value[2]);
					case 4:
						method(value[0], value[1], value[2], value[3]);
					case 5:
						method(value[0], value[1], value[2], value[3], value[4]);
				}
		}
	}

	private function addCallbacks()
	{
		var calls:Array<Array<String>> = [ // it's beautiful
			['Achievements'],
			['AchievementsMenuState'],
			['Alphabet'],
			['AttachedSprite'],
			['AttachedText'],
			['BackgroundDancer'],
			['BackgroundGirls'],
			['BGSprite'],
			['BlendModeEffect'],
			['Boyfriend'],
			['ButtonRemapSubstate'],
			['Character'],
			['ChartParser'],
			['CheckboxThingie'],
			['ClientPrefs'],
			['ColorSwap'],
			['Conductor'],
			['Controls'],
			['CoolUtil'],
			['CreditsState'],
			['CustomFadeTransition'],
			['CutsceneHandler'],
			['DialogueBox'],
			['DialogueBoxPsych'],
			['Discord'],
			['EternalFunctions'],
			['FlashingState'],
			['FlxUIDropDownMenuCustom'],
			['FreeplayState'],
			['FunkinLua'],
			['HScriptHandler'],
			['InputFormatter'],
			['LatencyState'],
			['LoadingState'],
			['Main'],
			['MainMenuState'],
			['MenuCharacter'],
			['MenuItem'],
			['ModsMenuState'],
			['MusicBeatAddstate']
			['MusicBeatState'],
			['MusicBeatSubstate'],
			['Note'],
			['NoteSplash'],
			['OutdatedState'],
			['OverlayShader'],
			['Paths'],
			['PauseSubState'],
			['PhillyGlow'],
			['PlayerSettings'],
			['PlayState'],
			['Prompt'],
			['ResetScoreSubState'],
			['Section'],
			['Snd'],
			['SndTV'],
			['Song'],
			['StageData'],
			['StoryMenuState'],
			['StrumNote'],
			['TankmenBG'],
			['TitleState'],
			['TypedAlphabet'],
			['WeekData'],
			['WhiggleEffect']
		];
		
		call(CALLBACK, 'StringTools', StringTools);
		call(CALLBACK, 'Std', Std);
		call(CALLBACK, 'Reflect', Reflect);
		call(CALLBACK, 'Type', Type);

		for (type in calls)
			call(CALLBACK, type[0], Type.resolveClass(type[0]));

		/*
		call(CALLBACK, 'import', function(lib:ImportShit)
		{
			var libShit:Array<String> = lib.library.split('.');
			var libName:String = libShit[libShit.length - 1];

			if (lib.like != null)
				libName = lib.like;

			try
				call(CALLBACK, libName, Type.resolveClass(lib.library));
		});
		*/

		call(CALLBACK, 'import', function(lib:String)
		{
			var libShit:Array<String> = lib.split(' as ');
			var libPack:Array<String> = libShit[0].split('.');
			var libName:String = libPack[libPack.length - 1];
			
			if (libShit.length == 2)
				libName = libShit[1];

			try
				call(CALLBACK, libName, Type.resolveClass(libShit[0]));
		});
	}
}