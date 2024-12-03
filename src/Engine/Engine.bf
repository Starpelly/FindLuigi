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
	public const int32 SCREEN_WIDTH = 256 * 2;
	public const int32 SCREEN_HEIGHT = 192 * 2;
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
}