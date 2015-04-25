module dgrid.vector;

struct Position
{
public:
	int x, y;
	static Position add( Position left, Position right) pure
	{
		left.x += right.x;
		left.y += right.y;
		return left;
	}
	//Just lynch me now.
	static Position add( Position position, Direction direction) pure
	{
		switch( direction)
		{
			case Direction.north:
				++position.y;
				break;
			case Direction.northeast:
				++position.y;
				++position.x;
				break;
			case Direction.east:
				++position.x;
				break;
			case Direction.southeast:
				--position.y;
				++position.x;
				break;
			case Direction.south:
				--position.y;
				break;
			case Direction.southwest:
				--position.y;
				--position.x;
				break;
			case Direction.west:
				--position.x;
				break;
			case Direction.northwest:
				++position.y;
				--position.x;
				break;
			default:
				break;
		}
		return position;
	}
}

public alias rotateCw =Rotation.clockwise;
public alias rotateCcw =Rotation.counterClockwise;
enum Rotation: byte{ none =0, clockwise =1, counterClockwise =-1};
enum Direction: ubyte{ north =0x01, northeast =0x02, east =0x04, southeast =0x08, south =0x10, southwest =0x20, west =0x40, northwest =0x80};

alias rotateDir =rotateDirection; //Fix old code.
Direction rotateDirection( Direction direction, Rotation rotation)
{
	if( rotation > 0)
	{
		direction <<=1;
		if( direction == 0)
			{ return direction.north;}
	}
	else if( rotation < 0)
	{
		direction >>=1;
		if( direction == 0)
			{ return direction.northwest;}
	}
	return direction;
}