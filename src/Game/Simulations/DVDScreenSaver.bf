using System;
using System.Collections;
using FindLuigi.Game;
using RaylibBeef;

namespace FindLuigi.Game.Simulations;

public class DVDScreenSaver : Simulation
{
	public override void Setup(int luigiIndex, ref List<Face> faces)
	{
		for (var i < faces.Count)
		{
			var face = ref faces[i];

			face.Speed = i == luigiIndex ? 1.54f : 1.5f; // Luigi is slightly faster so he can't get stuck behind another face.
			face.Angle = Raylib.GetRandomValue(0, 360);

			let halfFaceWidth = face.GetHalfFaceWidth();
			let halfFaceHeight = face.GetHalfFaceHeight();

			face.Position = .(
					Raylib.GetRandomValue(0 + (int32)halfFaceWidth, (int32)Engine.SCREEN_WIDTH - (int32)halfFaceWidth),
					Raylib.GetRandomValue(0 + (int32)halfFaceHeight, (int32)Engine.SCREEN_HEIGHT - (int32)halfFaceHeight));
		}
	}

	public override void Simulate(ref List<Face> faces)
	{
		for (var i < faces.Count)
		{
			var face = ref faces[i];

			let faceWidth = face.GetFaceWidth();
			let faceHeight = face.GetFaceHeight();
			let halfFaceWidth = face.GetHalfFaceWidth();
			let halfFaceHeight = face.GetHalfFaceHeight();

			let screenMin = Vector2(0 + halfFaceWidth, 0 + halfFaceHeight);
			let screenMax = Vector2(Engine.SCREEN_WIDTH - halfFaceWidth, Engine.SCREEN_HEIGHT - halfFaceHeight);

			var angleRad = face.Angle * Raylib.DEG2RAD;
			let direction = Vector2(Math.Cos(angleRad), Math.Sin(angleRad));

			face.Position.x += direction.x * face.Speed;
			face.Position.y += direction.y * face.Speed;

			bool faceOutsideX() => face.Position.x > screenMax.x || face.Position.x < screenMin.x;
			bool faceOutsideY() => face.Position.y > screenMax.y || face.Position.y < screenMin.y;

			if (faceOutsideX())
			{
				face.Angle = 180.0f - face.Angle;
				face.Position.x = Math.Clamp(face.Position.x, screenMin.x, screenMax.x);
			}
			if (faceOutsideY())
			{
				face.Angle = -face.Angle;
				face.Position.y = Math.Clamp(face.Position.y, screenMin.y, screenMax.y);
			}
		}
	}
}