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

	public static float Round2Nearest(float value, float interval)
	{
		return value - (value % interval);
	}

	public static float GetTimeFromFrames(int frameCount, float fps = 30.0f)
	{
		return (frameCount * 2) / 60.0f;
	}
}