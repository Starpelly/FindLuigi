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

		public float PositionX;
		public float PositionY;

		public float SpeedX = 2;
		public float SpeedY = 1;
	}

	private List<Face> m_Faces ~ delete _;

	public this()
	{
		let spriteSheetImage = LoadImageFromMemory(".png", (char8*)&SpriteSheetData, SpriteSheetData.Count);
		defer UnloadImage(spriteSheetImage);
		m_SpriteSheet = LoadTextureFromImage(spriteSheetImage);

		m_Music = LoadMusicStreamFromMemory(".ogg", (char8*)&MusicData, MusicData.Count);
		defer PlayMusicStream(m_Music);

		let faceCount = 100;
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
				PositionX = GetRandomValue(0 + (int32)halfFaceWidth, GetScreenWidth() - (int32)halfFaceWidth),
				PositionY = GetRandomValue(0 + (int32)halfFaceHeight, GetScreenHeight() - (int32)halfFaceHeight),
				SpeedX = (GetRandomValue(0, 1) == 1) ? -1 : 1,
				SpeedY = (GetRandomValue(0, 1) == 1) ? -1 : 1
			});
		}
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

		let screenMinX = 0 + halfFaceWidth;
		let screenMinY = 0 + halfFaceHeight;
		let screenMaxX = GetScreenWidth() - halfFaceWidth;
		let screenMaxY = GetScreenHeight() - halfFaceHeight;

		for (var face in ref m_Faces)
		{
			bool faceOutsideX() => face.PositionX > screenMaxX || face.PositionX < screenMinX;
			bool faceOutsideY() => face.PositionY > screenMaxY || face.PositionY < screenMinY;

			if (faceOutsideX())
			{
				face.SpeedX *= -1;
				while (faceOutsideX()) // Hack to prevent stuff from getting stuck
				{
					face.PositionX += face.SpeedX;
				}
			}
			if (faceOutsideY())
			{
				face.SpeedY *= -1;
				while (faceOutsideY()) // Hack to prevent stuff from getting stuck
				{
					face.PositionY += face.SpeedY;
				}
			}

			face.PositionX += face.SpeedX;
			face.PositionY += face.SpeedY;

			let faceIndex = (int)face.Sprite - 10;
			DrawTexturePro(m_SpriteSheet, .(faceIndex * 32, 0, 32, 32), .(face.PositionX, face.PositionY, faceWidth, faceHeight), .(faceWidth * 0.5f, faceHeight * 0.5f), 0, WHITE);
		}
	}
}