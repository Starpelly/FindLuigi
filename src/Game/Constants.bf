using RaylibBeef;

namespace FindLuigi.Game;

static
{
	public const uint8 FACE_SCALE = Engine.SCREEN_SCALE;
	public const uint32 FACE_WIDTH = 32 * FACE_SCALE;
	public const uint32 FACE_HEIGHT = 32 * FACE_SCALE;

	public const uint32 HALF_FACE_WIDTH = FACE_WIDTH / 2;
	public const uint32 HALF_FACE_HEIGHT = FACE_HEIGHT / 2;

	public const float FACE_ORIGIN_X = 0.5f;
	public const float FACE_ORIGIN_Y = 0.5f;

	public const Color BG_PLAYING = .(0, 0, 0, 255);
	public const Color BG_FOUND = .(255, 231, 66, 255);
}