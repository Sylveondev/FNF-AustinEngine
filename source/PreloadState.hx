#if sys
package;

import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets;
import flixel.ui.FlxBar;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class PreloadState extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxText;
	var bg:FlxSprite;

	public static var bitmapData:Map<String,FlxGraphic>;

	var images = [];
	var music = [];
	var charts = [];


	override function create()
	{

		FlxG.save.bind('funkin', 'ninjamuffin99');

		ClientPrefs.loadDefaultKeys();

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();

		bg = new FlxSprite();
		bg.makeGraphic(Std.int(FlxG.height),Std.int(FlxG.width),FlxColor.BLACK);
        bg.screenCenter();
        bg.updateHitbox();
		add(bg);

        var austinLogo = new FlxSprite();
		austinLogo.loadGraphic(Paths.image('austinLogo'));
		austinLogo.scale.set(0.5,0.5);
        austinLogo.screenCenter();
        austinLogo.updateHitbox();
		//add(austinLogo);

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300,0,"Preparing to Preload...");
		text.size = 16;
		text.alignment = FlxTextAlign.CENTER;
		text.alpha = 1000;
		
		text.y = FlxG.width / 2;
		text.x -= 170;
		

		#if cpp
		trace("caching images...");

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
		{
			if (!i.endsWith(".png"))
				continue;
			images.push(i);
		}

		/* trace("caching music...");
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			music.push(i);
		}
        */
		#end

		toBeDone = Lambda.count(images) /*+ Lambda.count(music)*/;

		//var bar = new FlxBar(10,FlxG.height - 50,FlxBarFillDirection.LEFT_TO_RIGHT,FlxG.width,40,null,"done",0,toBeDone);
		//bar.color = FlxColor.PURPLE;

		//add(bar);

		add(text);

		trace('starting caching..');
		
		#if cpp
		// update thread

		sys.thread.Thread.create(() -> {
			while(!loaded)
			{
				if (toBeDone != 0 && done != toBeDone)
					{
						
						text.text = "Preloading (" + done + "/" + toBeDone + ") assets";
					}
			}
		
		});

		// cache thread

		sys.thread.Thread.create(() -> {
			cache();
		});
		#end

		super.create();
	}

	var calledDone = false;

	override function update(elapsed) 
	{
		super.update(elapsed);
	}


	function cache()
	{
		trace("LOADING: " + toBeDone + " OBJECTS.");

		for (i in images)
		{
			var replaced = i.replace(".png","");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			trace('id ' + replaced + ' file - assets/shared/images/characters/' + i + ' ${data.width}');
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced,graph);
			done++;
		}

        /*
        //Remove for now
		for (i in music)
		{
			FlxG.sound.cache(Paths.inst(i));
			FlxG.sound.cache(Paths.voices(i));
			trace("cached some song");
			done++;
		}
        */


		trace("Finished caching...");

		loaded = true;

		trace(Assets.cache.hasBitmapData('GF_assets'));

		FlxG.switchState(new TitleState());
	}

}
#end