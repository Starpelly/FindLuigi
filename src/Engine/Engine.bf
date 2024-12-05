using RaylibBeef;
using System;

namespace FindLuigi;

public class Engine
{
#if BF_PLATFORM_WASM
	[CLink, CallingConvention(.Stdcall)]
	private static extern void emscripten_console_log(char8* utf8String);

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

	private Assets m_AssetManager ~ delete _;
	public static Assets Assets => g_Instance.m_AssetManager;

	private Scene m_CurrentScene = null ~ delete _;
	private float m_CurrentSceneTime = 0.0f;
	public static float CurrentSceneTime => g_Instance.m_CurrentSceneTime;

	private Vector2 m_LastWindowSize;

	// Globals
	private static Engine g_Instance { get; private set; }

	public this()
	{
		g_Instance = this;
	}

	public ~this()
	{
		g_Instance.m_CurrentScene.OnUnload();
	}

	public void Run()
	{
		Raylib.SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
		Raylib.InitWindow(1280, 768, "Find Luigi");
		defer Raylib.CloseWindow();

		Raylib.InitAudioDevice();
		defer Raylib.CloseAudioDevice();

		Raylib.SetExitKey(.KEY_NULL);
		Raylib.SetTargetFPS(60);

		m_AssetManager = new .();

		ChangeScene<FindLuigi.Scenes.Init>();

#if BF_PLATFORM_WASM
		emscripten_set_main_loop(=> emscriptenMainLoop, 0, 1);
#else 
		while (!Raylib.WindowShouldClose())
		{
			loop();
		}
#endif
	}

	private void loop()
	{
		if (Raylib.GetScreenWidth() != m_LastWindowSize.x || Raylib.GetScreenHeight() != m_LastWindowSize.y)
		{
			m_CurrentScene.OnWindowResize();
		}
		m_LastWindowSize = .(Raylib.GetScreenWidth(), Raylib.GetScreenHeight());

		m_CurrentSceneTime += Raylib.GetFrameTime();
		m_CurrentScene.OnUpdate();

		RaylibBeef.Raylib.BeginDrawing();
		defer RaylibBeef.Raylib.EndDrawing();

		defer
		{
			Raylib.DrawFPS(20, 20);

			/*
			Raylib.HideCursor();
			Raylib.DrawCircle(Raylib.GetMouseX(), Raylib.GetMouseY(), 10, Raylib.BLACK);
			Raylib.DrawCircle(Raylib.GetMouseX(), Raylib.GetMouseY(), 8, Raylib.WHITE);
			*/
		}

		m_CurrentScene.OnDraw();
	}

	public static void ChangeScene<T>() where T : Scene
	{
		g_Instance.m_CurrentSceneTime = 0.0f;

		if (g_Instance.m_CurrentScene != null)
		{
			g_Instance.m_CurrentScene.OnUnload();
			DeleteAndNullify!(g_Instance.m_CurrentScene);
		}
		g_Instance.m_CurrentScene = new T();
		g_Instance.m_CurrentScene.OnLoad();
	}

	public static bool PixelOnSpriteTransparent(int spriteX, int spriteY, int pixelX, int pixelY)
	{
		let image = Engine.Assets.SpriteSheet.Image;

		let positionX = spriteX + pixelX;
		let positionY = spriteY + pixelY;

		let testPixel = Engine.Assets.SpriteSheet.Pixels[positionY * image.width + positionX];

		return testPixel.a == 0;
	}

	public static void ConsoleLog(StringView line)
	{
#if DEBUG
#if BF_PLATFORM_WINDOWS
		Console.WriteLine(line);
#elif BF_PLATFORM_WASM
		emscripten_console_log(line.ToScopeCStr!());
#endif
#endif
	}
}