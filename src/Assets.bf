using System;
using RaylibBeef;

namespace FindLuigi;

public static struct Data
{
	public static uint8[?] SpriteSheetData = Compiler.ReadBinary("assets/spritesheet.png");
	public static uint8[?] MusicData = Compiler.ReadBinary("assets/music.ogg");
}

public class Assets
{
	public Texture2D SpriteSheet { get; private set; }
	public Music Music { get; private set; }

	public this()
	{
		// Sprite Sheet
		let spriteSheetImage = Raylib.LoadImageFromMemory(".png", (char8*)&Data.SpriteSheetData, Data.SpriteSheetData.Count);
		defer Raylib.UnloadImage(spriteSheetImage);
		SpriteSheet = Raylib.LoadTextureFromImage(spriteSheetImage);

		// Game Music
		Music = Raylib.LoadMusicStreamFromMemory(".ogg", (char8*)&Data.MusicData, Data.MusicData.Count);
	}

	public ~this()
	{
		Raylib.UnloadTexture(SpriteSheet);
		Raylib.UnloadMusicStream(Music);
	}
}