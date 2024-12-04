using System;
using System.Collections;
using RaylibBeef;
using static RaylibBeef.Raylib;

using FindLuigi.Game;

namespace FindLuigi.Scenes;

public class Game : Scene
{
	private RenderTexture m_RenderTextureGame;

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

	private void loadSimulation()
	{
		startRoom<FindLuigi.Game.Simulations.BasicGrid>();
	}

	public override void OnLoad()
	{
		defer
		{
			PlayMusicStream(Engine.Assets.Music);
			Raylib.SetMusicVolume(Engine.Assets.Music, m_MusicMuted ? 0.0f : 1.0f);
		}

		m_Faces = new .(1000);
		loadSimulation();

		// NOTE: We should do a little test to check that Luigi is visible before starting.

		m_RenderTextureGame = LoadRenderTexture(Engine.SCREEN_WIDTH, Engine.SCREEN_HEIGHT);
	}

	public override void OnUnload()
	{
		UnloadRenderTexture(m_RenderTextureGame);
	}

	private void startRoom<T>() where T : Simulation
	{
		m_CurrentRoomIndex++;

		let faceCount = 4;
		let luigiIndex = (uint32)GetRandomValue(0, (int32)faceCount - 1);

		if (m_CurrentRoomType != null)
			DeleteAndNullify!(m_CurrentRoomType);
		m_CurrentRoomType = new T();

		for (var i < faceCount)
		{
			var newFace = Face() {
				Sprite =
					i == luigiIndex ?
					Sprite.FACE_LUIGI
					:
					 (Sprite)GetRandomValue((int32)Sprite.FACE_MARIO, (int32)Sprite.FACE_WARIO)
			};

			m_Faces.Add(newFace);
		}
		m_CurrentRoomType.Setup(luigiIndex, ref m_Faces);
	}

	public override void OnUpdate()
	{
		if (Raylib.IsKeyPressed(.KEY_M))
		{
			m_MusicMuted = !m_MusicMuted;
			Raylib.SetMusicVolume(Engine.Assets.Music, m_MusicMuted ? 0.0f : 1.0f);
		}

		UpdateMusicStream(Engine.Assets.Music);

		m_TimeSinceStateSwitch += Raylib.GetFrameTime();
		m_HoveringFaceIndex = -1;

		if (m_CurrentState == .STATE_PLAYING)
		{
			simulateFaceMovement();
		}
		else if (m_CurrentState == .STATE_LOADING_ROOM)
		{
			if (m_TimeSinceStateSwitch >= Math.GetTimeFromFrames(12))
			{
				switchState(.STATE_PLAYING);
			}
		}
		else if (m_CurrentState == .STATE_FOUND)
		{
			if (m_TimeSinceStateSwitch >= Math.GetTimeFromFrames(75))
			{
				m_Faces.Clear();
				switchState(.STATE_LOADING_ROOM);
				loadSimulation();
			}
		}
	}

	public override void OnDraw()
	{
		defer
		{
			DrawFPS(20, 20);
			if (m_MusicMuted)
			{
				DrawText("Music Muted", 20, 40, 20, GREEN);
			}
		}

		let viewportSize = getLargestSizeForViewport();
		let viewportPos = getCenteredPositionForViewport(viewportSize);

		m_MousePositionViewport = .((GetMouseX() / viewportSize.x) * Engine.SCREEN_WIDTH, (GetMouseY() / viewportSize.y) * Engine.SCREEN_HEIGHT);
		m_MousePositionViewport = .(Math.Clamp(m_MousePositionViewport.x, 0, Engine.SCREEN_WIDTH), Math.Clamp(m_MousePositionViewport.y, 0, Engine.SCREEN_HEIGHT));

		BeginTextureMode(m_RenderTextureGame);
		{
			drawGame();
		}
		EndTextureMode();

		ClearBackground(.(15, 15, 15, 255));
		DrawTexturePro(m_RenderTextureGame.texture, .(0, 0, m_RenderTextureGame.texture.width, -m_RenderTextureGame.texture.height),
			.(0, 0, viewportSize.x, viewportSize.y),
			.(0, 0), 0, WHITE);
	}

	private void drawGame()
	{
		if (m_CurrentState == .STATE_FOUND && m_TimeSinceStateSwitch >= Math.GetTimeFromFrames(25))
		{
			ClearBackground(BG_FOUND);
		}
		else
		{	
			ClearBackground(BG_PLAYING);
		}

		void drawFace(int index, Color color)
		{
			var face = m_Faces[index];

			let faceWidth = face.GetFaceWidth();
			let faceHeight = face.GetFaceHeight();
			let halfFaceWidth = face.GetHalfFaceWidth();
			let halfFaceHeight = face.GetHalfFaceHeight();

			let faceIndex = (int)face.Sprite - 10;
			DrawTexturePro(Engine.Assets.SpriteSheet.Texture,
				.(faceIndex * 32, 0, 32, 32),
				.(face.Position.x, face.Position.y, faceWidth, faceHeight),
				.(halfFaceWidth, halfFaceHeight),
				0,
				color);
		}

		if (m_CurrentState == .STATE_PLAYING)
		{
			// Actually drawing the faces
			for (var i < m_Faces.Count)
			{
				drawFace(i, (m_HoveringFaceIndex == i) ? RED : WHITE);
			}
		}
		else if (m_CurrentState == .STATE_FOUND)
		{
			drawFace(m_FoundIndex, WHITE);
		}
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
				let mouseOnTransparentPixel = pixelOnSpriteTransparent((face.Sprite - Sprite.FACE_LUIGI) * (FACE_WIDTH / FACE_SCALE), 0, mouseImageX, mouseImageY);

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

			if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT))
			{
				if (face.Sprite == .FACE_LUIGI)
				{
					Console.WriteLine("You found Luigi! +5 points!");
					switchState(.STATE_FOUND);
					m_FoundIndex = m_HoveringFaceIndex;

					return; // Early return, we don't want to simulate the game this frame when we've won
				}
				else
				{
					Console.WriteLine("That's not Luigi! -10 points!");
				}
			}
		}

		// Actual face simulation
		m_CurrentRoomType.Simulate(ref m_Faces);
	}

	private bool pixelOnSpriteTransparent(int spriteX, int spriteY, int pixelX, int pixelY)
	{
		let image = Engine.Assets.SpriteSheet.Image;

		let positionX = spriteX + pixelX;
		let positionY = spriteY + pixelY;

		let testPixel = Engine.Assets.SpriteSheet.Pixels[positionY * image.width + positionX];

		return testPixel.a == 0;
	}

	private Vector2 getLargestSizeForViewport()
	{
	    let windowSize = Vector2(GetScreenWidth(), GetScreenHeight());

	    float aspectWidth = windowSize.x;
	    float aspectHeight = aspectWidth / Engine.SCREEN_ASPECT_RATIO;
	    if (aspectHeight > windowSize.y)
	    {
	        aspectHeight = windowSize.y;
	        aspectWidth = aspectHeight * Engine.SCREEN_ASPECT_RATIO;
	    }

	    return .(Math.Round2Nearest(aspectWidth, Engine.BASE_SCREEN_WIDTH), Math.Round2Nearest(aspectHeight, Engine.BASE_SCREEN_HEIGHT));
	}

	private Vector2 getCenteredPositionForViewport(Vector2 aspectSize)
	{
	    let windowSize = Vector2(GetScreenWidth(), GetScreenHeight());

	    float viewportX = (windowSize.x / 2.0f) - (aspectSize.x / 2.0f);
	    float viewportY = (windowSize.y / 2.0f) - (aspectSize.y / 2.0f);

	    return .(viewportX, viewportY);
	}

	private void switchState(State state)
	{
		m_CurrentState = state;
		m_TimeSinceStateSwitch = 0.0f;
	}
}