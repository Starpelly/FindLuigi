using RaylibBeef;
namespace FindLuigi.Game;

public enum Sprite
{
	// Nice that these line up, looks nice :)
	FACE_MARIO,
	FACE_YOSHI,
	FACE_WARIO,

	FACE_LUIGI_RED = 50,
	FACE_LUIGI_ORANGE,
	FACE_LUIGI_YELLOW,
	FACE_LUIGI_GREEN,
	FACE_LUIGI_CYAN,
	FACE_LUIGI_BLUE,
	FACE_LUIGI_VIOLET,
}

static
{
	public static (Assets.TextureEx, Rectangle) GetSpriteData(Sprite sprite)
	{
		mixin horizontalIndex(Assets.TextureEx tex, int i)
		{
			return (tex, .(i * 32, 0, 32, 32));
		}

		switch (sprite)
		{
			// Luigi
		case .FACE_LUIGI_RED: horizontalIndex!(Engine.Assets.Sprite_Luigi, 0);
		case .FACE_LUIGI_ORANGE: horizontalIndex!(Engine.Assets.Sprite_Luigi, 1);
		case .FACE_LUIGI_YELLOW: horizontalIndex!(Engine.Assets.Sprite_Luigi, 2);
		case .FACE_LUIGI_GREEN: horizontalIndex!(Engine.Assets.Sprite_Luigi, 3);
		case .FACE_LUIGI_CYAN: horizontalIndex!(Engine.Assets.Sprite_Luigi, 4);
		case .FACE_LUIGI_BLUE: horizontalIndex!(Engine.Assets.Sprite_Luigi, 5);
		case .FACE_LUIGI_VIOLET: horizontalIndex!(Engine.Assets.Sprite_Luigi, 6);

		case .FACE_MARIO: horizontalIndex!(Engine.Assets.SpriteSheet, 1);
		case .FACE_YOSHI: horizontalIndex!(Engine.Assets.SpriteSheet, 2);
		case .FACE_WARIO: horizontalIndex!(Engine.Assets.SpriteSheet, 3);

		default: break;
		}
		return (null, .(0, 0, 0, 0));
	}
}