using RaylibBeef;
using System;
namespace FindLuigi.Game.Simulations;

public class NoBounceTwoDirectional : Simulation
{
	public override void Setup(int luigiIndex, ref System.Collections.List<Face> faces)
	{
		for (var i < faces.Count)
		{
			var face = ref faces[i];

			face.Speed = i == luigiIndex ? 1.54f : 1.5f; // Luigi is slightly faster so he can't get stuck behind another face.
			face.Angle = Raylib.GetRandomValue(0, 360);

			MoveRandomPos(ref face);
		}
	}

	public override void Simulate(ref System.Collections.List<Face> faces)
	{
		for (var i < faces.Count)
		{
			var face = ref faces[i];

			var angleRad = face.Angle * Raylib.DEG2RAD;
			let direction = Vector2(Math.Cos(angleRad), Math.Sin(angleRad));

			face.Position.x += direction.x * face.Speed;
			face.Position.y += direction.y * face.Speed;

			let halfFaceWidth = face.GetHalfFaceWidth();
			let halfFaceHeight = face.GetHalfFaceHeight();
			let screenMin = Vector2(0 - halfFaceWidth, 0 - halfFaceHeight);
			let screenMax = Vector2(SCREEN_WIDTH + halfFaceWidth, SCREEN_HEIGHT + halfFaceHeight);

			if (face.Position.x > screenMax.x)
			{
				face.Position.x = -halfFaceWidth;
			}
			if (face.Position.x < screenMin.x)
			{
				face.Position.x = screenMax.x;
			}

			if (face.Position.y > screenMax.y)
			{
				face.Position.y = screenMin.y;
			}
			if (face.Position.y < screenMin.y)
			{
				face.Position.y = screenMax.y;
			}
		}
	}
}