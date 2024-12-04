using System.Collections;

namespace FindLuigi.Game;

// A simulation is basically a "Room Type", probably what I should've called it instead...
// But "simulation" sounded cooler.
public abstract class Simulation
{
	public abstract void Setup(int luigiIndex, ref List<Face> faces);
	public abstract void Simulate(ref List<Face> faces);
}