using RaylibBeef;
using System.Collections;

namespace FindLuigi.Game;

// A simulation is basically a "Room Type", probably what I should've called it instead...
// But "simulation" sounded cooler.
public abstract class Simulation
{
	public abstract void Setup(int luigiIndex, ref List<Face> faces);
	public abstract void Simulate(ref List<Face> faces);

	private List<Vector2> m_TakenGridPositions = new .() ~ delete _;

	// NOTE: So, about this code:
	// While play-testing, I found out that the game would sometimes be impossible because Luigi would be hidden behind another face.
	// I could've fixed this by making Luigi always the last one rendered, but the game would become too easy.
	// I'm not sure how Nintendo fixed this... But when analyzing the game, I found that the "random positions"
	// looked suspiciously like a grid with the positions moved around a little bit.
	//
	// It's a little ugly, but I don't care! >:|
	//
	// Also, at about 130-ish, there isn't enough room for full visibility. But it's probably fine.
	protected void MoveRandomPos(ref Face face)
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
			for (var gridPos in m_TakenGridPositions)
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

		m_TakenGridPositions.Add(.(randGridX, randGridY));

		face.Position.x = randGridX * HALF_FACE_WIDTH;
		face.Position.y = randGridY * HALF_FACE_HEIGHT;

		face.Position.x += Raylib.GetRandomValue(-2, 2) * SCREEN_SCALE;
		face.Position.y += Raylib.GetRandomValue(-2, 2) * SCREEN_SCALE;

		// face.Position.x = Math.Clamp(face.Position.x, face.GetHalfFaceWidth(), Engine.SCREEN_WIDTH - face.GetHalfFaceWidth());
		// face.Position.y = Math.Clamp(face.Position.y, face.GetHalfFaceHeight(), Engine.SCREEN_HEIGHT - face.GetHalfFaceHeight());
	}
}