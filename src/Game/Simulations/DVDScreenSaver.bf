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
		List<Vector2> takenGridPositions = scope .();

		// NOTE: So, about this code:
		// While play-testing, I found out that the game would sometimes be impossible because Luigi would be hidden behind another face.
		// I could've fixed this by making Luigi always the last one rendered, but the game would become too easy.
		// I'm not sure how Nintendo fixed this... But when analyzing the game, I found that the "random positions"
		// looked suspiciously like a grid with the positions moved around a little bit.
		//
		// It's a little ugly, but I don't care! >:|
		//
		// Also, at about 130-ish, there isn't enough room for full visibility. But it's probably fine.
		void moveRandomPos(ref Face face)
		{
			let gridWidth = SCREEN_WIDTH / HALF_FACE_WIDTH;
			let gridHeight = SCREEN_HEIGHT / HALF_FACE_HEIGHT;

			var randGridX = 0;
			var randGridY = 0;

			bool alreadyTaken = false;
			repeat
			{
				randGridX = Raylib.GetRandomValue(1, gridWidth - 1);
				randGridY = Raylib.GetRandomValue(1, gridHeight - 1);

				var earlyReturn = false;

				// Check to see if that grid position is already taken
				for (var gridPos in takenGridPositions)
				{
					if (gridPos == .(randGridX, randGridY))
					{
						alreadyTaken = true;
						earlyReturn = true;
						break;
					}
				}

				if (earlyReturn)
				{
					continue;
				}
				else
				{
					alreadyTaken = false;
				}
			}
			while (alreadyTaken);

			takenGridPositions.Add(.(randGridX, randGridY));

			face.Position.x = randGridX * HALF_FACE_WIDTH;
			face.Position.y = randGridY * HALF_FACE_HEIGHT;

			face.Position.x += Raylib.GetRandomValue(-2, 2) * SCREEN_SCALE;
			face.Position.y += Raylib.GetRandomValue(-2, 2) * SCREEN_SCALE;

			// face.Position.x = Math.Clamp(face.Position.x, face.GetHalfFaceWidth(), Engine.SCREEN_WIDTH - face.GetHalfFaceWidth());
			// face.Position.y = Math.Clamp(face.Position.y, face.GetHalfFaceHeight(), Engine.SCREEN_HEIGHT - face.GetHalfFaceHeight());
		}

		for (var i < faces.Count)
		{
			var face = ref faces[i];

			face.Speed = i == luigiIndex ? 1.54f : 1.5f; // Luigi is slightly faster so he can't get stuck behind another face.
			face.Angle = Raylib.GetRandomValue(0, 360);

			moveRandomPos(ref face);
		}
	}

	public override void Simulate(ref List<Face> faces)
	{
		for (var i < faces.Count)
		{
			var face = ref faces[i];

			if (NoMove) return;

			let halfFaceWidth = face.GetHalfFaceWidth();
			let halfFaceHeight = face.GetHalfFaceHeight();

			let screenMin = Vector2(0 + halfFaceWidth, 0 + halfFaceHeight);
			let screenMax = Vector2(SCREEN_WIDTH - halfFaceWidth, SCREEN_HEIGHT - halfFaceHeight);

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