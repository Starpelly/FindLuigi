using System;
using RaylibBeef;
namespace FindLuigi.Game.Simulations;

public class Finale : Simulation
{
	private float m_Time = 0.0f;

	public override void Setup(int luigiIndex, ref System.Collections.List<Face> faces)
	{
		// Override all the shit we do in the main game for this joke

		for (var i < faces.Count)
		{
			var face = ref faces[i];

			face.Angle = (i / ((float)faces.Count - 1)) * 360.0f;

			face.Sprite = .FACE_LUIGI_RED + i;

			face.IsLuigi = face.Sprite == .FACE_LUIGI_GREEN;
		}

		Raylib.PlayMusicStream(Engine.Assets.MusicFinale);
	}

	public override void Simulate(ref System.Collections.List<Face> faces)
	{
		defer { m_Time += Raylib.GetFrameTime(); }

		Raylib.UpdateMusicStream(Engine.Assets.MusicFinale);

		let centerX = SCREEN_WIDTH / 2;
		let centerY = SCREEN_HEIGHT / 2;

		let radius = (Math.Sin(m_Time * 3)) + 100.0f;

		for (var i < faces.Count)
		{
			var face = ref faces[i];

			if (i == 0)
			{
				face.Position.x = centerX;
				face.Position.y = centerY;
			}
			else
			{
				let radians = Math.DegreesToRadians(face.Angle);

				face.Position.x = centerX + radius * Math.Cos(radians);
				face.Position.y = centerY + radius * Math.Sin(radians);

				face.Angle -= face.Speed;

				if (face.Angle >= 360)
				{
					face.Angle += 360;
				}
			}
		}
	}
}