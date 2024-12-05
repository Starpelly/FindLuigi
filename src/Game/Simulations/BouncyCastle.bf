using System;
using System.Collections;
using FindLuigi.Game;
using RaylibBeef;

namespace FindLuigi.Game.Simulations;

public class BouncyCastle : Simulation
{
	private struct BounceFace
	{
		public float Gravity;
		public float Velocity;
	}

	private List<BounceFace> m_BounceFaceProperties ~ delete _;

	public override void Setup(int luigiIndex, ref List<Face> faces)
	{
		// NOTE:
		// This level can get quite hard. I'm thinking Luigi should always be in front so it's
		// easier to click him.

		for (var i < faces.Count)
		{
			var face = ref faces[i];

			face.Speed = i == luigiIndex ? 1.54f : 1.5f; // Luigi is slightly faster so he can't get stuck behind another face.
			face.Angle = Raylib.GetRandomValue(0, 1) == 0 ? 180 : 0;

			MoveRandomPos(ref face);
		}

		m_BounceFaceProperties = new .(faces.Count);
		for (var face in faces)
		{
			m_BounceFaceProperties.Add(.()
				{
					Gravity = 0.35f
				});
		}
	}

	public override void Simulate(ref List<Face> faces)
	{
		for (var i < faces.Count)
		{
			var face = ref faces[i];
			var waveFace = ref m_BounceFaceProperties[i];

			var angleRad = face.Angle * Raylib.DEG2RAD;
			let direction = Vector2(Math.Cos(angleRad), Math.Sin(angleRad));

			waveFace.Velocity += waveFace.Gravity;

			face.Position.x += direction.x * face.Speed;
			face.Position.y += direction.y * face.Speed;

			face.Position.y += waveFace.Velocity;

			// Keep in screen bounds
			let halfFaceWidth = face.GetHalfFaceWidth();
			let halfFaceHeight = face.GetHalfFaceHeight();
			let screenMin = Vector2(0 + halfFaceWidth, 0 + halfFaceHeight);
			let screenMax = Vector2(SCREEN_WIDTH - halfFaceWidth, SCREEN_HEIGHT - halfFaceHeight);

			bool faceOutsideX() => face.Position.x > screenMax.x || face.Position.x < screenMin.x;
			bool faceOutsideY() => face.Position.y > screenMax.y;

			if (faceOutsideX())
			{
				face.Angle = 180.0f - face.Angle;
				face.Position.x = Math.Clamp(face.Position.x, screenMin.x, screenMax.x);
			}
			if (faceOutsideY())
			{
				waveFace.Velocity = Raylib.GetRandomValue(-15, -4);
				face.Position.y = Math.Clamp(face.Position.y, screenMin.y, screenMax.y);
			}
		}
	}
}