using System;
using System.Collections;
using RaylibBeef;
using static RaylibBeef.Raylib;

namespace FindLuigi;

public class Game
{
	private static uint8[?] SpriteSheetData = Compiler.ReadBinary("assets/spritesheet.png");
	private Texture2D m_SpriteSheet;

	private static uint8[?] MusicData = Compiler.ReadBinary("assets/music.ogg");
	private Music m_Music;

	private RenderTexture m_RenderTextureGame;

	private enum Sprite
	{
		// Nice that these line up, looks nice :)
		FACE_LUIGI = 10,
		FACE_MARIO,
		FACE_YOSHI,
		FACE_WARIO
	}

	private int m_FaceScale = 2;
	private const int32 FACE_WIDTH = 32;
	private const int32 FACE_HEIGHT = 32;

	private const int32 SCREEN_WIDTH = 256 * 2;
	private const int32 SCREEN_HEIGHT = 192 * 2;
	private const float SCREEN_ASPECT_RATIO = (float)SCREEN_WIDTH / (float)SCREEN_HEIGHT;

	private int getFaceWidth()
	{
		return FACE_WIDTH * m_FaceScale;
	}

	private int getFaceHeight()
	{
		return FACE_HEIGHT * m_FaceScale;
	}

	private struct Face
	{
		public Sprite Sprite;

		public Vector2 Position;

		public float Speed = 1.5f;
		public float Angle = 0.0f;
	}

	private List<Face> m_Faces ~ delete _;

	public this()
	{
		let spriteSheetImage = LoadImageFromMemory(".png", (char8*)&SpriteSheetData, SpriteSheetData.Count);
		defer UnloadImage(spriteSheetImage);
		m_SpriteSheet = LoadTextureFromImage(spriteSheetImage);

		m_Music = LoadMusicStreamFromMemory(".ogg", (char8*)&MusicData, MusicData.Count);
		defer PlayMusicStream(m_Music);

		let faceCount = 20;
		let luigiIndex = GetRandomValue(0, faceCount - 1);

		m_Faces = new .(faceCount);

		let halfFaceWidth = getFaceWidth() / 2;
		let halfFaceHeight = getFaceHeight() / 2;
		for (var i < faceCount)
		{
			m_Faces.Add(.() {
				Sprite =
					i == luigiIndex ?
					Sprite.FACE_LUIGI
					:
					 (Sprite)GetRandomValue((int32)Sprite.FACE_MARIO, (int32)Sprite.FACE_WARIO),
				Speed = i == luigiIndex ? 1.54f : 1.5f, // Luigi is slightly faster so he can't get stuck behind another face
				Position = .(
					GetRandomValue(0 + (int32)halfFaceWidth, SCREEN_WIDTH - (int32)halfFaceWidth),
					GetRandomValue(0 + (int32)halfFaceHeight, SCREEN_HEIGHT - (int32)halfFaceHeight)),
				Angle = GetRandomValue(0, 360)
			});
		}

		// NOTE: We should do a little test to check that Luigi is visible before starting.

		m_RenderTextureGame = LoadRenderTexture(SCREEN_WIDTH, SCREEN_HEIGHT);
	}

	private Vector2 m_MousePositionViewport;

	public ~this()
	{
		UnloadRenderTexture(m_RenderTextureGame);
	}

	public void Update()
	{
		// UpdateMusicStream(m_Music);
	}

	public void Draw()
	{
		BeginDrawing();
		defer EndDrawing();
		defer DrawFPS(20, 20);

		let viewportSize = getLargestSizeForViewport();
		let viewportPos = getCenteredPositionForViewport(viewportSize);

		m_MousePositionViewport = .((GetMouseX() / viewportSize.x) * SCREEN_WIDTH, (GetMouseY() / viewportSize.y) * SCREEN_HEIGHT);
		m_MousePositionViewport = .(Math.Clamp(m_MousePositionViewport.x, 0, SCREEN_WIDTH), Math.Clamp(m_MousePositionViewport.y, 0, SCREEN_HEIGHT));

		BeginTextureMode(m_RenderTextureGame);
		{
			drawGame();
		}
		EndTextureMode();

		ClearBackground(.(15, 15, 15, 255));
		DrawTexturePro(m_RenderTextureGame.texture, .(0, 0, m_RenderTextureGame.texture.width, -m_RenderTextureGame.texture.height), .(0, 0, viewportSize.x, viewportSize.y), .(0, 0), 0, WHITE);
	}

	private void drawGame()
	{
		ClearBackground(BLACK);

		let faceWidth = getFaceWidth();
		let faceHeight = getFaceHeight();
		let halfFaceWidth = faceWidth / 2;
		let halfFaceHeight = faceHeight / 2;

		let screenMin = Vector2(0 + halfFaceWidth, 0 + halfFaceHeight);
		let screenMax = Vector2(SCREEN_WIDTH - halfFaceWidth, SCREEN_HEIGHT - halfFaceHeight);

		var hoveringFaceIndex = -1;
		var i = 0;
		for (var face in ref m_Faces)
		{
			defer { i++; }

			var angleRad = face.Angle * DEG2RAD;
			let direction = Vector2(Math.Cos(angleRad), Math.Sin(angleRad));

			face.Position.x += direction.x * face.Speed;
			face.Position.y += direction.y * face.Speed;

			bool faceOutsideX() => face.Position.x > screenMax.x || face.Position.x < screenMin.x;
			bool faceOutsideY() => face.Position.y > screenMax.y || face.Position.y < screenMin.y;

			if (faceOutsideX())
			{
				face.Angle = 180.0f - face.Angle;
				face.Position.x = Math.Clamp(face.Position.x, screenMin.x, screenMax.x);
			}
			if (faceOutsideY())
			{
				face.Angle = -face.Angle;
				face.Position.y = Math.Clamp(face.Position.y, screenMin.y, screenMax.y);
			}

			if (face.Sprite == .FACE_LUIGI)
			{
			}

			if (m_MousePositionViewport.x >= (face.Position.x - halfFaceWidth) && m_MousePositionViewport.x <= (face.Position.x - halfFaceWidth) + faceWidth
				&& m_MousePositionViewport.y >= (face.Position.y - halfFaceHeight) && m_MousePositionViewport.y <= (face.Position.y - halfFaceHeight) + faceHeight)
			{
				hoveringFaceIndex = i;
			}
		}

		if (hoveringFaceIndex >= 0)
		{
			var face = m_Faces[hoveringFaceIndex];
			DrawCircleV(.(face.Position.x, face.Position.y), 48, .(255, 255, 255, 180));

			if (IsMouseButtonPressed(.MOUSE_BUTTON_LEFT))
			{
				if (face.Sprite == .FACE_LUIGI)
				{
					Console.WriteLine("You found Luigi! +5 points!");
				}
				else
				{
					Console.WriteLine("That's not Luigi! -10 points!");
				}
			}
		}

		for (var face in ref m_Faces)
		{
			let faceIndex = (int)face.Sprite - 10;
			DrawTexturePro(m_SpriteSheet, .(faceIndex * 32, 0, 32, 32), .(face.Position.x, face.Position.y, faceWidth, faceHeight), .(halfFaceWidth, halfFaceHeight), 0, WHITE);
		}
	}

	private Vector2 getLargestSizeForViewport()
	{
	    let windowSize = Vector2(GetScreenWidth(), GetScreenHeight());

	    float aspectWidth = windowSize.x;
	    float aspectHeight = aspectWidth / SCREEN_ASPECT_RATIO;
	    if (aspectHeight > windowSize.y)
	    {
	        aspectHeight = windowSize.y;
	        aspectWidth = aspectHeight * SCREEN_ASPECT_RATIO;
	    }

	    return .(aspectWidth, aspectHeight);
	}

	private Vector2 getCenteredPositionForViewport(Vector2 aspectSize)
	{
	    let windowSize = Vector2(GetScreenWidth(), GetScreenHeight());

	    float viewportX = (windowSize.x / 2.0f) - (aspectSize.x / 2.0f);
	    float viewportY = (windowSize.y / 2.0f) - (aspectSize.y / 2.0f);

	    return .(viewportX, viewportY);
	}
}