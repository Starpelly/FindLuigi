using RaylibBeef;

namespace FindLuigi;

public class Engine
{
	private Assets m_AssetManager = new .() ~ delete _;
	public static Assets Assets => g_Instance.m_AssetManager;

	private Scene m_CurrentScene = null ~ delete _;
	private float m_CurrentSceneTime = 0.0f;
	public static float CurrentSceneTime => g_Instance.m_CurrentSceneTime;

	// Constants
	public const uint32 BASE_SCREEN_WIDTH = 256;
	public const uint32 BASE_SCREEN_HEIGHT = 192;

	public const uint32 SCREEN_SCALE = 2;
	public const uint32 SCREEN_WIDTH = BASE_SCREEN_WIDTH * SCREEN_SCALE;
	public const uint32 SCREEN_HEIGHT = BASE_SCREEN_HEIGHT * SCREEN_SCALE;
	public const float SCREEN_ASPECT_RATIO = (float)SCREEN_WIDTH / (float)SCREEN_HEIGHT;

	// Globals
	private static Engine g_Instance { get; private set; }

	public this()
	{
		g_Instance = this;

		ChangeScene<FindLuigi.Scenes.Init>();
	}

	public ~this()
	{
		g_Instance.m_CurrentScene.OnUnload();
	}

	public void Loop()
	{
		m_CurrentSceneTime += Raylib.GetFrameTime();
		m_CurrentScene.OnUpdate();

		RaylibBeef.Raylib.BeginDrawing();
		defer RaylibBeef.Raylib.EndDrawing();

		m_CurrentScene.OnDraw();

		{
			defer
			{
				Raylib.DrawFPS(20, 20);
			}
			Raylib.HideCursor();
			Raylib.DrawCircle(Raylib.GetMouseX(), Raylib.GetMouseY(), 12, Raylib.BLACK);
			Raylib.DrawCircle(Raylib.GetMouseX(), Raylib.GetMouseY(), 8, Raylib.WHITE);
		}
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
}