module dgrid.thing;

import dgrid.vector;
import dgrid.grid;

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