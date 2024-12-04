using System;

namespace FindLuigi;

class Program
{
	public static int Main(String[] args)
	{
		let engine = scope Engine();
		engine.Run();

		return 0;
	}
}