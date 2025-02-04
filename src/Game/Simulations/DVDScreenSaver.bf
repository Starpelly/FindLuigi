using System;
using System.Collections;
using FindLuigi.Game;
using RaylibBeef;

namespace FindLuigi.Game.Simulations;

public class DVDScreenSaver : Simulation
{
	public bool NoMove = false;
	public float SpeedModify = 1.0f;

	public override void Setup(int luigiIndex, ref List<Face> faces)
	{
		for (var i < faces.Count)
		{
			var face = ref faces[i];

			face.Speed = i == luigiIndex ? 1.54f : 1.5f; // Luigi is slightly faster so he can't get stuck behind another face.
			face.Angle = Raylib.GetRandomValue(0, 360);

			MoveRandomPos(ref face);
		}
	}

	public override void Simulate(ref List<Face> faces)
	{
		for (var i < faces.Count)
		{
			var face = ref faces[i];

			if (NoMove) return;

			var angleRad = face.Angle * Raylib.DEG2RAD;
			let direction = Vector2(Math.Cos(angleRad), Math.Sin(angleRad));

			face.Position.x += direction.x * face.Speed;
			face.Position.y += direction.y * face.Speed;

			// Keep in screen bounds
			let halfFaceWidth = face.GetHalfFaceWidth();
			let halfFaceHeight = face.GetHalfFaceHeight();
			let screenMin = Vector2(0 + halfFaceWidth, 0 + halfFaceHeight);
			let screenMax = Vector2(SCREEN_WIDTH - halfFaceWidth, SCREEN_HEIGHT - halfFaceHeight);

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