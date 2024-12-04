using System;
using System.Collections;
using FindLuigi.Game;
using RaylibBeef;

namespace FindLuigi.Game.Simulations;

public class BasicGrid : Simulation
{
	public override void Setup(int luigiIndex, ref List<Face> faces)
	{
		let maxColumns = 8;
		let maxRows = 6;

		// Grid dimensions
		var gridColumns = (int)Math.Min(Math.Ceiling(Math.Sqrt(faces.Count)), maxColumns);
		var gridRows = (int)Math.Min(Math.Ceiling(Math.Sqrt(faces.Count)), maxRows);

		if (faces.Count >= (Engine.SCREEN_WIDTH * Engine.SCREEN_HEIGHT) / (FACE_WIDTH * FACE_HEIGHT))
		{
			gridColumns = 8; // Hack, I can't be bothered to figure out the math for this right now.
		}

		let gridWidth = gridColumns * FACE_WIDTH;
		let gridHeight = gridRows * FACE_HEIGHT;

		// Center grid to screen
		let gridStartX = ((Engine.SCREEN_WIDTH - gridWidth) / 2) + (FACE_WIDTH / 2);
		let gridStartY = ((Engine.SCREEN_HEIGHT - gridHeight) / 2) + (FACE_HEIGHT / 2);

		var createdFaceCount = 0;
		for (let row < gridRows)
		{
			for (let col < gridColumns)
			{
				if (createdFaceCount >= faces.Count) break; // Stop if all faces are placed.

				var xPos = gridStartX + (col * FACE_WIDTH);
				var yPos = gridStartY + (row * FACE_HEIGHT);

				faces[createdFaceCount].Position = .(xPos, yPos);

				createdFaceCount++;
			}
			if (createdFaceCount >= faces.Count) break; // Stop if all faces are placed.
		}
	}

	public override void Simulate(ref List<Face> faces)
	{
	}
}