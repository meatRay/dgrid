/++Authors: Syphist, meatRay+/
module dgrid.gamewindow;

import dgrid.grid;
import dgrid.actor;
import meat.keyboard;

import meat.window;
import meat.camera;
import meat.mouse;

import derelict.sdl2.sdl;

import std.datetime;
debug import std.stdio;

/++
+ Advanced Window object for drawing Grids, and pushing actions to them.
+ Examples:
+ ---
+ auto window =new GameWindow( "FlatLand", 150, 200, 600, 450);
+ window.grid =new Grid();
+ window.run();
+ ---
+/
class GameWindow: Window
{
public:
	Mouse mouse() @property
		{ return this._mouse;}
	Camera camera() @property
		{ return this._camera;}
	/++Currently rendering and updating grid.+/
	Grid grid;
	/++Construct a new GameWindow, with a title, position, and size.+/
	this( string title, int x, int y, int width, int height)
		{ 
			super( title, x, y, width,height); 
			this._camera =new Camera();
			this._mouse =new Mouse();
			this._tickedLast =Clock.currTime;
		}
protected:
	/++
	+ Ran on the Window's update Thread.
	+ Checks for keyboard input, and updates the Camera.
	+ See_Also: meat.window.Window.update()
	+/
	override void update()
	{
		if( Clock.currTime -_tickedLast >= grid.ticktime)
		{
			this._tickedLast =Clock.currTime;
			this.grid.update();
		}
		//Dehardcode max speed.
		if( this._camera.velx < 2 &&this._camera.velx > -2)
		{
			if( keyboard.keyDown(Key.D) )
				{ this._camera.velx +=0.005f; }
			else if( keyboard.keyDown(Key.A) )
				{ this._camera.velx -=0.005f; }
			else
				{ this._camera.velx *= 0.9f; }
		}
		if( this._camera.vely < 2 &&this._camera.vely > -2 )
		{
			if( keyboard.keyDown(Key.W) )
				{ this._camera.vely +=0.005f; }
			else if( keyboard.keyDown(Key.S) )
				{ this._camera.vely -=0.005f; }
			else
				{ this._camera.vely *= 0.9f; }
		}
		this._camera.update();
	}
	override void processEvent( SDL_Event event )
	{
		if( event.type == SDL_MOUSEMOTION )
		{
			this._mouse.update( event.motion.x, event.motion.y );
		}
	}
	/++
	+ Begin openGl, and ask the Grid to render.
	+ See_Also: meat.window.Window.render()
	+/
	override void render()
	{
		glClear( GL_COLOR_BUFFER_BIT );
		
		glPushMatrix();
		glTranslatef( -_camera.x, -_camera.y, 0f );

		this.grid.render();
		glPopMatrix();
	}
	/++
	+ Calculate openGl matrices.
	+ See_Also: meat.window.Window.load()
	+/
	override void load()
	{
		debug writefln( "Beginning load");
		
		//dehardcode
		glClearColor( 0.317, 0.639, 0.152, 1.0 );
		
		glViewport( 0, 0, width, height);
		glMatrixMode( GL_PROJECTION);
		glLoadIdentity();
		
		//zoom
		glOrtho( -10f, 10f, -10f/aspectRatio, 10f/aspectRatio, -1f, 1f );
		glMatrixMode( GL_MODELVIEW);
	}
	/++
	+ Recalulate openGl matrices.
	+ See_Also: meat.window.Window.resize()
	+/
	override void resize()
	{
		debug writefln( "resizing to  %d, by %d. Ratio of %2f", width, height, aspectRatio );
		glViewport( 0, 0, width, height );
		glMatrixMode( GL_PROJECTION );
		glLoadIdentity();
		glOrtho(-10f, 10f, -10f/aspectRatio, 10f/aspectRatio, -1f, 1f );
		glMatrixMode( GL_MODELVIEW );
	}
private:
	SysTime _tickedLast;
	Camera _camera;
	Mouse _mouse;
}
