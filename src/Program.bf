using System;
using RaylibBeef;
using static RaylibBeef.Raylib;

namespace FindLuigi;

class Program
{
	private static Game game;

	public static int Main(String[] args)
	{
		InitWindow(800, 600, "Find Luigi");
		defer CloseWindow();

		InitAudioDevice();
		defer CloseAudioDevice();

		SetTargetFPS(60);

		game = new Game();
		defer delete game;

#if BF_PLATFORM_WASM
		emscripten_set_main_loop(=> emscriptenMainLoop, 0, 1);
#else 
		while (!WindowShouldClose())
		{
			update();
		}
#endif

		return 0;
	}

	private static void update()
	{
		game.Update();
		game.Draw();
	}

#if BF_PLATFORM_WASM
	private function void em_callback_func();

	[CLink, CallingConvention(.Stdcall)]
	private static extern void emscripten_set_main_loop(em_callback_func func, int32 fps, int32 simulateInfinteLoop);

	[CLink, CallingConvention(.Stdcall)]
	private static extern int32 emscripten_set_main_loop_timing(int32 mode, int32 value);

	[CLink, CallingConvention(.Stdcall)]
	private static extern double emscripten_get_now();

	private static void emscriptenMainLoop()
	{
		update();
	}
#endif
}