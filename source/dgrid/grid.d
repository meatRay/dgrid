/++Authors: Syphist, meatRay+/
module dgrid.grid;

import dgrid.thing;
import dgrid.actor;
import meat.window;

import std.container;
import std.algorithm;
import std.range;

debug import std.stdio;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.datetime: Duration, dur;

/++
+ Store Things, Iterate actor actions and render them.
+/
class Grid
{
public:
	/++How often to update the grid.+/
	Duration ticktime;
	///
	this()
	{
		this.ticktime =dur!"seconds"(1);
	}
	
	/++
	+ Add a Thing to the Grid's Thing collection,
	+ and loadClass() its type.
	++/
	void addThing( Thing actor )
	{ 
		if ( actor.name !in _textures )
		{
			loadTexture( actor.name );
		}
		this._things.stableInsert( actor );
		actor.grid =this;
	}
	
	/++
	+ Add an Thing to the Grid's Thing collection,
	+ loadClass its type, and set the actor's position
	+ to the argument for ease.+/
	void placeThing( Thing actor, int x, int y)
	{
		actor.position =Position( x, y);
		addThing( actor);
	}
	///
	void placeThing( Thing actor, Position position)
	{
		actor.position =position;
		addThing( actor);
	}
	/++Find an Thing in the Grid, and Remove it.+/
	void rmvThing( Thing actor)
		{ /+this._things.linearRemove( find( _things[], actor).take(1));+/
		this._rmvs.insert( actor);}
		
	void loadTexture( string name )
	{
		debug writefln( "Loading texture \"%s\"..", name);
		Image image = new Image();
		if ( !image.load(`img\` ~name ~`.png`))
		{
			debug writeln( "Texture does not exist!");
			return;
		}
		_textures[name] =image;
		debug writeln( "Success!");
	}
	
	/++
	+ Render the scene.
	+ Called once per frame-update, independent of game-updates.
	+/
	void render()
	{
		Imagebox.startRender();
		foreach( actor; things)
		{
			Imagebox.render( _textures[actor.name], actor.position.x, actor.position.y );
		}
		Imagebox.endRender();

	}
	/++Runs each Actor's act() method to update it. Called once-per ticktime Duration.+/
	void update()
	{
		foreach( actor; _things[].filter!( a =>cast(Actor)a !is null))
		{
			(cast(Actor)actor).act();
		}
		foreach( thing; _rmvs[])
		{
			_things.linearRemove( _things[].find(thing).take(1));
		}
		_rmvs.clear();
		things =_things.dup();
	}
	/++Returns if any Actors are present at position.+/
	bool occupiedAt( Position position)
	{
		foreach( thing; _things)
		{
			if( thing.position == position)
				{ return true;}
		}
		return false;
	}
	auto thingsAt( Position position)
	{
		DList!Thing at;
		foreach( thing; _things)
		{
			if( thing.position == position)
				{ at.insert( thing);}
		}
		return at[];
	}
	DList!Thing things;
private:
	DList!Thing _things;
	DList!Thing _rmvs;
	
	Image[string] _textures;
	static immutable float[8] verts =
	[ 
		-0.5f, -0.5f,
		0.5f, -0.5f,
		0.5f, 0.5f,
		-0.5f, 0.5f
	];
	
	/+ NOTHING HERE+/
	static immutable float[8] textsn =
	[ 
		0f, 1f,
		1f, 1f,
		1f, 0f,
		0f, 0f
	];
	static float fuckshit( Direction direction)
	{
		switch( direction)
		{
			case Direction.north:
				return 0f;
			case Direction.northeast:
				return 315f;
			case Direction.east:
				return 270f;
			case Direction.southeast:
				return 225f;
			case Direction.south:
				return 180f;
			case Direction.southwest:
				return 135f;
			case Direction.west:
				return 90f;
			case Direction.northwest:
				return 45f;
			default:
				return 0f;
		}
	}
}