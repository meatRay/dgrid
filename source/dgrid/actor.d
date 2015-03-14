/++Authors: Syphist, meatRay+/
module dgrid.actor;

import dgrid.vector;
import dgrid.grid;

/++
+ "Does Stuff"
+/
class Actor :Thing
{
public:
	/++Publicly define game-update actions.+/
	void delegate() onAct;
	/++Construct with a position defined.+/
	this(this T)()
	{
		super();
		this.name =T.stringof;
		this.onAct =delegate void(){};
	}
	/++
	+ Called once per game-update.
	+ Overload to define derived classes actions.
	+/
	void act()
	{
		onAct();
	}
	
	bool step()
		{ return step( direction);}
	bool step( Direction direction)
	{
		auto pos =Position.add( position, direction);
		if(! this.grid.occupiedAt( pos))
		{
			this.position =pos;
			return true;
		}
		return false;
	}
	void rotate( Rotation rotation)
	{
		this.direction =rotateDir( this.direction, rotation);
	}
}