using RaylibBeef;

namespace System;

extension Math
{
	public static float Normalize(float val, float min, float max)
	{
		return (val - min) / (max - min);
	}

	public static float Clamp01(float value)
	{
		if (value < 0F)
			return 0F;
		else if (value > 1f)
			return 1f;
		else
			return value;
	}

	public static float Round2Nearest(float val, float interval)
	{
		return val - (val % interval);
	}

	public static float GetTimeFromFrames(int frameCount, float fps = 30.0f)
	{
		return (frameCount * 2) / 60.0f;
	}

	public static bool IsWithin(float val, float min, float max)
	{
		return val >= min && val <= max;
	}

	public static bool IsWithin(Vector2 val, Vector2 min, Vector2 max)
	{
		return IsWithin(val.x, min.x, max.x) && IsWithin(val.y, min.y, max.y);
	}
}