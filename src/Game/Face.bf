using RaylibBeef;

namespace FindLuigi.Game;

public struct Face
{
	public Sprite Sprite;
	public bool IsLuigi = false;

	public Vector2 Position;

	public float Speed = 1.5f;
	public float Angle = 0.0f;

	public float Scale = 1.0f;

	public float GetFaceWidth()
	{
		return FACE_WIDTH * Scale;
	}

	public float GetFaceHeight()
	{
		return FACE_HEIGHT * Scale;
	}

	public float GetHalfFaceWidth()
	{
		return GetFaceWidth() * FACE_ORIGIN_X;
	}

	public float GetHalfFaceHeight()
	{
		return GetFaceHeight() * FACE_ORIGIN_Y;
	}
}