using System;
using System.Collections;
using RaylibBeef;
using static RaylibBeef.Raylib;

namespace FindLuigi.Scenes;

public class Game : Scene
{
	private RenderTexture m_RenderTextureGame;

	private enum Sprite
	{
		// Nice that these line up, looks nice :)
		FACE_LUIGI = 10,
		FACE_MARIO,
		FACE_YOSHI,
		FACE_WARIO
	}

	public enum State
	{
		STATE_PLAYING,
		STATE_SUCCESS
	}

	private int m_FaceScale = 2;
	private const int32 FACE_WIDTH = 32;
	private const int32 FACE_HEIGHT = 32;

	private Vector2 m_MousePositionViewport;

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

	public override void OnLoad()
	{
		defer PlayMusicStream(Engine.Assets.Music);

		let faceCount = 10;
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
					GetRandomValue(0 + (int32)halfFaceWidth, Engine.SCREEN_WIDTH - (int32)halfFaceWidth),
					GetRandomValue(0 + (int32)halfFaceHeight, Engine.SCREEN_HEIGHT - (int32)halfFaceHeight)),
				Angle = GetRandomValue(0, 360)
			});
		}

		// NOTE: We should do a little test to check that Luigi is visible before starting.

		m_RenderTextureGame = LoadRenderTexture(Engine.SCREEN_WIDTH, Engine.SCREEN_HEIGHT);
	}

	public override void OnUnload()
	{
		UnloadRenderTexture(m_RenderTextureGame);
	}

	public override void OnUpdate()
	{
		// UpdateMusicStream(m_AssetManager.Music);
	}

	public override void OnDraw()
	{
		defer DrawFPS(20, 20);

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
		let screenMax = Vector2(Engine.SCREEN_WIDTH - halfFaceWidth, Engine.SCREEN_HEIGHT - halfFaceHeight);

		var hoveringFaceIndex = -1;
		for (var i < m_Faces.Count)
		{
			var face = ref m_Faces[i];

			// We first check that the mouse is over the "area" of a face before pixel testing, this is 32 pixels (FACE_WIDTH)
			if (m_MousePositionViewport.x >= (face.Position.x - halfFaceWidth) && m_MousePositionViewport.x <= (face.Position.x - halfFaceWidth) + faceWidth
				&& m_MousePositionViewport.y >= (face.Position.y - halfFaceHeight) && m_MousePositionViewport.y <= (face.Position.y - halfFaceHeight) + faceHeight)
			{
				// Pixel testing over the sprite to check if we're over a transparent pixel or not just felt more natural and less
				// frustrating during play-testing. So that's what we're going with!
				let mouseImageX = (int)Math.Floor((m_MousePositionViewport.x - face.Position.x + halfFaceWidth) / m_FaceScale);
				let mouseImageY = (int)Math.Floor((m_MousePositionViewport.y - face.Position.y + halfFaceHeight) / m_FaceScale);
				let mouseOnTransparentPixel = pixelOnSpriteTransparent((face.Sprite - Sprite.FACE_LUIGI) * FACE_WIDTH, 0, mouseImageX, mouseImageY);

				if (!mouseOnTransparentPixel)
				{
					hoveringFaceIndex = i;
				}
			}

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
		}

		if (hoveringFaceIndex >= 0)
		{
			var face = m_Faces[hoveringFaceIndex];

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

		// Actually drawing the faces
		for (var i < m_Faces.Count)
		{
			var face = m_Faces[i];

			let faceIndex = (int)face.Sprite - 10;
			DrawTexturePro(Engine.Assets.SpriteSheet.Texture, .(faceIndex * 32, 0, 32, 32), .(face.Position.x, face.Position.y, faceWidth, faceHeight), .(halfFaceWidth, halfFaceHeight), 0,
				(hoveringFaceIndex == i) ? RED : WHITE);
		}
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