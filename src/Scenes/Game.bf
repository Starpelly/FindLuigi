using System;
using System.Collections;
using RaylibBeef;

using FindLuigi.Game;

namespace FindLuigi.Scenes;

public class Game : Scene
{
	private RenderTexture m_RenderTextureGame;
	private RenderTexture m_RenderTextureScore;

	private float m_Timer = 22;
	private int CeilTimer() => (int)Math.Ceiling(m_Timer);
	private int m_LastCeilTime = -1;

	public enum State
	{
		STATE_LOADING_ROOM,
		STATE_PLAYING,
		STATE_FOUND
	}

	private State m_CurrentState;
	private float m_TimeSinceStateSwitch;

	private Simulation m_CurrentRoomType = null ~ delete _;

	private int m_FoundIndex = 0;
	private int m_HoveringFaceIndex = 0;

	private Vector2 m_MousePositionViewport;

	private uint32 m_CurrentRoomIndex = 0;

	private bool m_MusicMuted = true;

	private List<Face> m_Faces ~ delete _;

	private float m_LeftSideWidthRatio = 0.75f;

	private Rectangle getLeftSideRect()
	{
		return .(0, 0, Raylib.GetScreenWidth() * m_LeftSideWidthRatio, Raylib.GetScreenHeight());
	}
	private Rectangle getRightSideRect()
	{
		return .(getLeftSideRect().width, 0, Raylib.GetScreenWidth() - getLeftSideRect().width, Raylib.GetScreenHeight());
	}

	private Type GetSimulationType(int index)
	{
		switch (index)
		{
		case 0: return typeof(FindLuigi.Game.Simulations.BasicGrid);
		case 1: return typeof(FindLuigi.Game.Simulations.DVDScreenSaver);
		case 2: return typeof(FindLuigi.Game.Simulations.BouncyCastle);
		case 3: return typeof(FindLuigi.Game.Simulations.Cars);
		case 4: return typeof(FindLuigi.Game.Simulations.NoBounceTwoDirectional);
		}
		return typeof(FindLuigi.Game.Simulations.BasicGrid);
	}

	private void loadSimulationTree()
	{
#if BF_PLATFORM_WINDOWS

		{
			let simulation = new FindLuigi.Game.Simulations.BouncyCastle();

			startLevel(62, simulation);
		}

		/*
		{
			let simulation = new FindLuigi.Game.Simulations.Finale();

			startLevel(7, simulation);
		}
		*/

		return;
#endif

		if (m_CurrentRoomIndex < 3)
		{
			var faceCount = 4;
			switch (m_CurrentRoomIndex)
			{
			case 0: faceCount = 4; break;
			case 1: faceCount = 16; break;
			case 2: faceCount = 48; break;
			}

			let simulation = new FindLuigi.Game.Simulations.BasicGrid();
			startLevel(faceCount, simulation);
		}
		else if (m_CurrentRoomIndex < 10)
		{
			let simulation = new FindLuigi.Game.Simulations.DVDScreenSaver();
			simulation.NoMove = true;

			startLevel(64, simulation);
		}
		else
		{
			let simulation = new FindLuigi.Game.Simulations.DVDScreenSaver();

			startLevel(16, simulation);
		}
	}
	
	private void startLevel(int faceCount, Simulation simulation)
	{
		m_CurrentRoomIndex++;

		let luigiIndex = (uint32)Raylib.GetRandomValue(0, (int32)faceCount - 1);

		if (m_CurrentRoomType != null)
			DeleteAndNullify!(m_CurrentRoomType);
		m_CurrentRoomType = simulation;

		for (var i < faceCount)
		{
			var newFace = Face() {
				Sprite =
					i == (int)luigiIndex ?
					Sprite.FACE_LUIGI_GREEN
					:
					 (Sprite)Raylib.GetRandomValue((int32)Sprite.FACE_MARIO, (int32)Sprite.FACE_WARIO),
				IsLuigi = i == (int)luigiIndex
			};

			m_Faces.Add(newFace);
		}
		m_CurrentRoomType.Setup((int)luigiIndex, ref m_Faces);
	}

	public override void OnLoad()
	{
		defer
		{
			Raylib.PlayMusicStream(Engine.Assets.Music);
			Raylib.SetMusicVolume(Engine.Assets.Music, m_MusicMuted ? 0.0f : 1.0f);
		}

		m_Faces = new .(1000);
		loadSimulationTree();

		// NOTE: We should do a little test to check that Luigi is visible before starting.

		m_RenderTextureGame = Raylib.LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT);
		m_RenderTextureScore = Raylib.LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT);
	}

	public override void OnUnload()
	{
		Raylib.UnloadRenderTexture(m_RenderTextureGame);
		Raylib.UnloadRenderTexture(m_RenderTextureScore);
	}

	bool m_PlayedLevelStartSound = false;

	public override void OnUpdate()
	{
		if (Raylib.IsKeyPressed(.KEY_M))
		{
			m_MusicMuted = !m_MusicMuted;
			Raylib.SetMusicVolume(Engine.Assets.Music, m_MusicMuted ? 0.0f : 1.0f);
		}

		Raylib.UpdateMusicStream(Engine.Assets.Music);

		m_TimeSinceStateSwitch += Raylib.GetFrameTime();
		m_HoveringFaceIndex = -1;

		if (m_CurrentState == .STATE_PLAYING)
		{
			m_Timer -= Raylib.GetFrameTime();
			if (m_LastCeilTime != CeilTimer())
			{
				let sound = (CeilTimer() > 5) ? Engine.Assets.SFX_Tick.Sound : Engine.Assets.SFX_TickLittleTime.Sound;
				Raylib.PlaySound(sound);
			}
			m_LastCeilTime = CeilTimer();

			simulateFaceMovement();
		}
		else if (m_CurrentState == .STATE_LOADING_ROOM)
		{
			if (m_TimeSinceStateSwitch >= Math.GetTimeFromFrames(7) && !m_PlayedLevelStartSound)
			{
				Raylib.PlaySound(Engine.Assets.SFX_LevelStart.Sound);
				m_PlayedLevelStartSound = true;
			}
			if (m_TimeSinceStateSwitch >= Math.GetTimeFromFrames(12))
			{
				switchState(.STATE_PLAYING);
				m_PlayedLevelStartSound = false;
			}
		}
		else if (m_CurrentState == .STATE_FOUND)
		{
			if (m_TimeSinceStateSwitch >= Math.GetTimeFromFrames(75))
			{
				m_Faces.Clear();
				switchState(.STATE_LOADING_ROOM);
				loadSimulationTree();
			}
		}
	}

	public override void OnDraw()
	{
		defer
		{
			if (m_MusicMuted)
			{
				Raylib.DrawText("Music Muted", 20, 40, 20, Raylib.GREEN);
			}
		}

		let viewportSize = getLargestSizeForViewport();
		let viewportPos = getCenteredPositionForViewport(viewportSize);

		let relativeMouseX = Raylib.GetMouseX() - viewportPos.x;
		let relativeMouseY = Raylib.GetMouseY() - viewportPos.y;
		m_MousePositionViewport = .((relativeMouseX / viewportSize.x) * SCREEN_WIDTH, (relativeMouseY / viewportSize.y) * SCREEN_HEIGHT);
		m_MousePositionViewport = .(Math.Clamp(m_MousePositionViewport.x, 0, SCREEN_WIDTH), Math.Clamp(m_MousePositionViewport.y, 0, SCREEN_HEIGHT));

		Raylib.BeginTextureMode(m_RenderTextureGame);
		{
			drawGame();
		}
		Raylib.EndTextureMode();

		Raylib.BeginTextureMode(m_RenderTextureScore);
		{
			drawScore();
		}
		Raylib.EndTextureMode();

		Raylib.ClearBackground(Raylib.BROWN);

		Raylib.DrawRectangleRec(getLeftSideRect(), .(15, 15, 15, 255));
		Raylib.DrawRectangleRec(getRightSideRect(), .(25, 25, 25, 255));
		Raylib.DrawLineEx(.(getRightSideRect().x, getRightSideRect().y), .(getRightSideRect().x, getRightSideRect().height), 2, Raylib.BLACK);

		Raylib.DrawTexturePro(m_RenderTextureScore.texture,
			.(0, 0, m_RenderTextureScore.texture.width, -m_RenderTextureScore.texture.height),
			.(getRightSideRect().x, getRightSideRect().y, getRightSideRect().width, getRightSideRect().width),
			.(0, 0),
			0,
			Raylib.WHITE);

		Raylib.DrawTexturePro(m_RenderTextureGame.texture,
			.(0, 0, m_RenderTextureGame.texture.width, -m_RenderTextureGame.texture.height),
			.(viewportPos.x, viewportPos.y, viewportSize.x, viewportSize.y),
			.(0, 0),
			0,
			Raylib.WHITE);
	}

	public override void OnWindowResize()
	{
		Raylib.UnloadRenderTexture(m_RenderTextureScore);
		m_RenderTextureScore = Raylib.LoadRenderTexture((int32)getRightSideRect().width, (int32)getRightSideRect().width);
	}

	public static void DrawFace(Face face, Color color)
	{
		let data = FindLuigi.Game.GetSpriteData(face.Sprite);

		DrawFaceEx(face, data.0, data.1, color);
	}

	public static void DrawFaceEx(Face face, Assets.TextureEx texture, Rectangle textureRect, Color color)
	{
		let faceWidth = face.GetFaceWidth();
		let faceHeight = face.GetFaceHeight();
		let halfFaceWidth = face.GetHalfFaceWidth();
		let halfFaceHeight = face.GetHalfFaceHeight();

		Raylib.DrawTexturePro(texture.Texture,
			textureRect,
			.(face.Position.x, face.Position.y, faceWidth, faceHeight),
			.(halfFaceWidth, halfFaceHeight),
			0,
			color);
	}

	private void drawGame()
	{
		if (m_CurrentState == .STATE_FOUND && m_TimeSinceStateSwitch >= Math.GetTimeFromFrames(25))
		{
			Raylib.ClearBackground(BG_FOUND);
		}
		else
		{	
			Raylib.ClearBackground(BG_PLAYING);
		}

		if (m_CurrentState == .STATE_PLAYING)
		{
			// Actually drawing the faces
			for (var i < m_Faces.Count)
			{
				DrawFace(m_Faces[i], (m_HoveringFaceIndex == i) ? Raylib.RED : Raylib.WHITE);
			}
		}
		else if (m_CurrentState == .STATE_FOUND)
		{
			DrawFace(m_Faces[m_FoundIndex], Raylib.WHITE);
		}
	}

	private void drawScore()
	{
		Raylib.ClearBackground(BG_FOUND);

		let screenWidth = getRightSideRect().width;
		let screenHeight = getRightSideRect().width;

		int num = Math.Max(CeilTimer(), 0);
		let numString = num.ToString(.. scope .());

		let fontScale = 3;
		let spaceBtwChars = 0;

		let fontHeight = Engine.Assets.TimerNumbers.Texture.height * fontScale;
		let stringWidth = (numString.Length * (16 + spaceBtwChars)) * fontScale;
		let fontPosX = (screenWidth * 0.5f) - (stringWidth * 0.5f);
		let fontPosY = (screenHeight * 0.5f) - (fontHeight * 0.5f);

		// Raylib.DrawRectangle((int32)fontPosX, (int32)fontPosY, (int32)stringWidth, 15 * fontScale, Raylib.RED);

		let fontOffset = Vector2(Math.Round(fontPosX), fontPosY);
		for (var i = 0; i < numString.Length; i++)
		{
			let char = numString[i];
			let charI = int8.Parse(char.ToString(.. scope .()));

			let charX = (((14 + spaceBtwChars) * fontScale) * i) + (numString.Length);

			Raylib.DrawTexturePro(Engine.Assets.TimerNumbers.Texture,
				.(charI * 16, 0, 16, 15),
				.(Math.Round(charX) + fontOffset.x, (0) + fontOffset.y, 16 * fontScale, 15 * fontScale),
				.(0, 0),
				0,
				Raylib.WHITE);
		}
		Raylib.DrawTextureEx(Engine.Assets.TimerLabel.Texture, .((screenHeight * 0.5f) - ((Engine.Assets.TimerLabel.Texture.width * fontScale) * 0.5f), fontPosY - 30), 0, fontScale, Raylib.WHITE);
	}

	private void simulateFaceMovement()
	{
		for (var i < m_Faces.Count)
		{
			var face = ref m_Faces[i];

			let faceWidth = face.GetFaceWidth();
			let faceHeight = face.GetFaceHeight();
			let halfFaceWidth = face.GetHalfFaceWidth();
			let halfFaceHeight = face.GetHalfFaceHeight();

			// We first check that the mouse is over the "area" of a face before pixel testing, this is 32 pixels (FACE_WIDTH)
			if (m_MousePositionViewport.x >= (face.Position.x - halfFaceWidth) && m_MousePositionViewport.x <= (face.Position.x - halfFaceWidth) + faceWidth
				&& m_MousePositionViewport.y >= (face.Position.y - halfFaceHeight) && m_MousePositionViewport.y <= (face.Position.y - halfFaceHeight) + faceHeight)
			{
				// Pixel testing over the sprite to check if we're over a transparent pixel or not just felt more natural and less
				// frustrating during play-testing. So that's what we're going with!
				// NOTE: Replace with sprite properties instead (create a manager for that, eventually!)
				let mouseImageX = (int)(Math.Floor((m_MousePositionViewport.x - face.Position.x + halfFaceWidth) / (float)FACE_SCALE) / face.Scale);
				let mouseImageY = (int)(Math.Floor((m_MousePositionViewport.y - face.Position.y + halfFaceHeight) / (float)FACE_SCALE) / face.Scale);
				let mouseOnTransparentPixel = Engine.PixelOnSpriteTransparent((face.Sprite - Sprite.FACE_LUIGI_GREEN) * (FACE_WIDTH / FACE_SCALE), 0, mouseImageX, mouseImageY);

				if (!mouseOnTransparentPixel)
				{
					m_HoveringFaceIndex = i;
				}
			}
		}

		// Checks to see if we click and if we do, if we click the correct face
		// Early returns if we select the correct face so we don't continue simulation
		if (m_HoveringFaceIndex >= 0)
		{
			var face = m_Faces[m_HoveringFaceIndex];

			if (Raylib.IsMouseButtonPressed(.MOUSE_BUTTON_LEFT))
			{
				if (face.IsLuigi)
				{
					Engine.ConsoleLog("You found Luigi! +5 points!");
					m_Timer += 5;

					switchState(.STATE_FOUND);
					m_FoundIndex = m_HoveringFaceIndex;

					return; // Early return, we don't want to simulate the game this frame when we've won
				}
				else
				{
					m_Timer -= 10;
					Engine.ConsoleLog("That's not Luigi! -10 points!");
				}
			}
		}

		// Actual face simulation
		m_CurrentRoomType.Simulate(ref m_Faces);
	}

	private Vector2 getLargestSizeForViewport()
	{
	    // let windowSize = Vector2(GetScreenWidth(), GetScreenHeight());
		let windowSize = getLeftSideRect();

	    float aspectWidth = windowSize.width;
	    float aspectHeight = aspectWidth / SCREEN_ASPECT_RATIO;
	    if (aspectHeight > windowSize.height)
	    {
	        aspectHeight = windowSize.height;
	        aspectWidth = aspectHeight * SCREEN_ASPECT_RATIO;
	    }

		return .(Math.Round2Nearest(aspectWidth, BASE_SCREEN_WIDTH), Math.Round2Nearest(aspectHeight, BASE_SCREEN_HEIGHT));
	    // return .(aspectWidth, aspectHeight);
	}

	private Vector2 getCenteredPositionForViewport(Vector2 aspectSize)
	{
	    let windowSize = getLeftSideRect();

	    float viewportX = (windowSize.width / 2.0f) - (aspectSize.x / 2.0f);
	    float viewportY = (windowSize.height / 2.0f) - (aspectSize.y / 2.0f);

	    return .(viewportX, viewportY);
	}

	private void switchState(State state)
	{
		m_CurrentState = state;
		m_TimeSinceStateSwitch = 0.0f;
	}
}