using System;
using RaylibBeef;

namespace FindLuigi;

public static struct Data
{
	public static uint8[?] SpriteSheetData = Compiler.ReadBinary("assets/spritesheet.png");
	public static uint8[?] BoxsubmusLogoData = Compiler.ReadBinary("assets/boxsubmus-logo.png");
	public static uint8[?] MusicData = Compiler.ReadBinary("assets/music.ogg");
}

public class Assets
{
	public class TextureEx
	{
		public Image Image { get; private set; }
		public Texture2D Texture { get; private set; }
		public Color* Pixels { get; private set; }

		public this(uint8* pixels, int32 count, TextureFilter filter = .TEXTURE_FILTER_POINT)
		{
			Image = Raylib.LoadImageFromMemory(".png", (char8*)pixels, count);
			Texture = Raylib.LoadTextureFromImage(Image);
			Raylib.SetTextureFilter(Texture, filter);
			Pixels = Raylib.LoadImageColors(Image);
		}

		public ~this()
		{
			Raylib.UnloadImage(Image);
			Raylib.UnloadTexture(Texture);
			Raylib.UnloadImageColors(Pixels);
		}
	}

	public TextureEx SpriteSheet { get; private set; } = new .(&Data.SpriteSheetData, Data.SpriteSheetData.Count) ~ delete _;
	public TextureEx BoxsubmusLogo { get; private set; } = new .(&Data.BoxsubmusLogoData, Data.BoxsubmusLogoData.Count, .TEXTURE_FILTER_BILINEAR) ~ delete _;

	public Music Music { get; private set; }

	public this()
	{
		// Game Music
		Music = Raylib.LoadMusicStreamFromMemory(".ogg", (char8*)&Data.MusicData, Data.MusicData.Count);
	}

	public ~this()
	{
		Raylib.UnloadMusicStream(Music);
	}
}