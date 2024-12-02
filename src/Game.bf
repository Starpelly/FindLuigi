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

	private enum Sprite
	{
		// Nice that these line up, looks nice :)
		FACE_LUIGI = 10,
		FACE_MARIO,
		FACE_YOSHI,
		FACE_WARIO
	}

	private int m_FaceScale = 2;
	private const int FACE_WIDTH = 32;
	private const int FACE_HEIGHT = 32;

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

		let faceCount = 150;
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
				Position = .(
					GetRandomValue(0 + (int32)halfFaceWidth, GetScreenWidth() - (int32)halfFaceWidth),
					GetRandomValue(0 + (int32)halfFaceHeight, GetScreenHeight() - (int32)halfFaceHeight)),
				Angle = GetRandomValue(0, 360)
			});
		}

		// NOTE: We should do a little test to check that Luigi is visible before starting.
	}

	public void Update()
	{
		UpdateMusicStream(m_Music);
	}

	public void Draw()
	{
		BeginDrawing();
		defer EndDrawing();

		ClearBackground(BLACK);

		defer DrawFPS(20, 20);

		let faceWidth = getFaceWidth();
		let faceHeight = getFaceHeight();
		let halfFaceWidth = faceWidth / 2;
		let halfFaceHeight = faceHeight / 2;

		let screenMin = Vector2(0 + halfFaceWidth, 0 + halfFaceHeight);
		let screenMax = Vector2(GetScreenWidth() - halfFaceWidth,  GetScreenHeight() - halfFaceHeight);

		for (var face in ref m_Faces)
		{
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
				DrawCircleV(.(face.Position.x, face.Position.y), 64, WHITE);
			}

			let faceIndex = (int)face.Sprite - 10;
			DrawTexturePro(m_SpriteSheet, .(faceIndex * 32, 0, 32, 32), .(face.Position.x, face.Position.y, faceWidth, faceHeight), .(halfFaceWidth, halfFaceHeight), 0, WHITE);
		}
	}
}