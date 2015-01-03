/++Authors: Syphist, meatRay+/
module dgrid.grid;

import dgrid.actor;
import meat.window;

import std.container;
import std.algorithm;
import std.range;

debug import std.stdio;

import derelict.sdl2.sdl;
import derelict.sdl2.image;
import std.datetime: Duration, dur;

static this()
{
	DerelictSDL2Image.load();
	IMG_Init( IMG_INIT_PNG);
}
static ~this()
{ IMG_Quit(); }

abstract class Thing
{
public:
	Direction direction =Direction.north;
	Grid grid;
	Position position;
	
	this(this T)()
	{
		this.name =T.stringof;
	}
	string name;
}

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
	~this()
	{
		foreach( texture; _textures)
		{
			glDeleteTextures( 1, &texture);
		}
	}
	/++
	+ Add a Thing to the Grid's Thing collection,
	+ and loadClass() its type.
	++/
	void addThing( Thing actor)
	{ 
		if ( !loadTexture( actor.name))
		{
			//actor.name ="Thing";
			//loadTexture( "Thing");
			//debug writeln( "Warning! Reverted actor's texture name to Thing.png\nEither supply a correct name or an existing image.");
		}
		this._things.stableInsert( actor);
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
	/++
	+ Loads a texture.
	+ Returns: The texture's buffer address if successful.
	+ 0 if error occurs loading.
	+/
	uint loadTexture( string name)
	{
		debug writefln( "Loading texture \"%s\"..", name);
		if(name !in _textures)
		{
			_textures[name] =0;
			glGenTextures( 1, &_textures[name]);
			SDL_Surface* tex =IMG_Load( cast(const(char)*)(`img\` ~name ~`.png`) );
			if( tex is null)
			{
				debug writeln( "Texture does not exist!");
				return 0;
			}
			glBindTexture( GL_TEXTURE_2D, _textures[name]);
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
			glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
			glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, tex.w, tex.h, 0, GL_RGBA, GL_UNSIGNED_BYTE, cast(const(void)*)tex.pixels);
			glBindTexture( GL_TEXTURE_2D, 0);
			debug writeln( "Success!");
		}
		else
		{
			//debug writeln( "Texture already loaded.");
		}
		return _textures[name];
	}
	
	/++
	+ Render the scene.
	+ Called once per frame-update, independent of game-updates.
	+/
	void render()
	{
		glEnableClientState( GL_VERTEX_ARRAY);
		glEnableClientState( GL_TEXTURE_COORD_ARRAY);
		glEnable( GL_TEXTURE_2D);
		glEnable( GL_BLEND);
		glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glColor4f( 1f, 1f, 1f, 1f);
		
		glVertexPointer(2, GL_FLOAT, 0, verts.ptr);		
		foreach( actor; things)
		{
			glTexCoordPointer( 2, GL_FLOAT, 0, textsn.ptr);	
			glPushMatrix();
			glTranslatef( actor.position.x +0.5f, actor.position.y +0.5f, 0f);
			glBindTexture( GL_TEXTURE_2D, _textures[actor.name]);
			glRotatef( fuckshit(actor.direction), 0, 0, 1);
			glDrawArrays( GL_QUADS, 0, 4);
			glPopMatrix();
		}
		glDisable( GL_BLEND);
		glDisable( GL_TEXTURE_2D);
		glDisableClientState( GL_TEXTURE_COORD_ARRAY);
		glDisableClientState( GL_VERTEX_ARRAY);

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
	
	uint[string] _textures;
	static immutable float[8] verts =
	[ 
		-0.5f, -0.5f,
		0.5f, -0.5f,
		0.5f, 0.5f,
		-0.5f, 0.5f
	];
	static immutable(float)* texCoordFromDir( Direction direction) pure
	{
		switch( direction)
		{
			case( Direction.north):
				return textsn.ptr;
			case( Direction.east):
				return textse.ptr;
			case( Direction.south):
				return textss.ptr;
			default:
				return textsw.ptr;
		}
	}
	
	/+ NOTHING HERE+/
	static immutable float[8] textsn =
	[ 
		0f, 1f,
		1f, 1f,
		1f, 0f,
		0f, 0f
	];
	static immutable float[8] textse =
	[ 
		1f, 1f,
		1f, 0f,
		0f, 0f,
		0f, 1f
	];
	static immutable float[8] textss =
	[ 
		1f, 0f,
		0f, 0f,
		0f, 1f,
		1f, 1f
	];
	static immutable float[8] textsw =
	[ 
		0f, 0f,
		0f, 1f,
		1f, 1f,
		1f, 0f
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