using System.Collections;
using RaylibBeef;

namespace FindLuigi.Game.Simulations;

public class Cars : Simulation
{
	public override void Setup(int luigiIndex, ref System.Collections.List<Face> faces)
	{
		let moveColumnCount = Raylib.GetRandomValue(2, 4);
		List<int> moveColumns = scope .(moveColumnCount);

		int32 columnCount = 0;
		for (var i < moveColumnCount)
		{
			moveColumns.Add(Raylib.GetRandomValue(columnCount + 1, columnCount + 3));
		}

		for (var i < faces.Count)
		{
			var face = ref faces[i];
		}
	}

	public override void Simulate(ref System.Collections.List<Face> faces)
	{
		for (var i < faces.Count)
		{
			var face = ref faces[i];

			face.Position.y += 4;

			if (face.Position.y > SCREEN_HEIGHT + HALF_FACE_HEIGHT)
			{
				face.Position.y = -HALF_FACE_HEIGHT;
			}
		}
	}
}