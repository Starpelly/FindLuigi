using System;
using RaylibBeef;

namespace FindLuigi;

public static struct Data
{
	public static uint8[?] SpriteSheetData = Compiler.ReadBinary("assets/spritesheet.png");
	public static uint8[?] BoxsubmusLogoData = Compiler.ReadBinary("assets/boxsubmus-logo.png");
	public static uint8[?] LogoData = Compiler.ReadBinary("assets/logo.png");
	public static uint8[?] TimerNumbersData = Compiler.ReadBinary("assets/timer-numbers.png");
	public static uint8[?] TimerLabelData = Compiler.ReadBinary("assets/time-label.png");

	public static uint8[?] MusicData = Compiler.ReadBinary("assets/music.ogg");

	public static uint8[?] SFX_MenuSelect = Compiler.ReadBinary("assets/sfx/menu-select.ogg");
	public static uint8[?] SFX_HighScore = Compiler.ReadBinary("assets/sfx/high-score.ogg");
	public static uint8[?] SFX_LevelStart = Compiler.ReadBinary("assets/sfx/level-start.ogg");
	public static uint8[?] SFX_DrumRoll = Compiler.ReadBinary("assets/sfx/drumroll.ogg");
	public static uint8[?] SFX_Tick = Compiler.ReadBinary("assets/sfx/tick.ogg");
	public static uint8[?] SFX_TickLittleTime = Compiler.ReadBinary("assets/sfx/tick-littletime.ogg");
	public static uint8[?] SFX_TimeAdd = Compiler.ReadBinary("assets/sfx/time-add.ogg");
	public static uint8[?] SFX_GameOver = Compiler.ReadBinary("assets/sfx/game-over.ogg");
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

		public Vector2 Size()
		{
			return .(Texture.width, Texture.height);
		}
	}

	public class SoundFX
	{
		public Sound Sound { get; private set; }

		public this(uint8* samples, int32 sampleCount)
		{
			let wave = Raylib.LoadWaveFromMemory(".ogg", (char8*)samples, sampleCount);
			Sound = Raylib.LoadSoundFromWave(wave);
			Raylib.UnloadWave(wave);
		}

		public ~this()
		{
			Raylib.UnloadSound(Sound);
		}
	}

	public TextureEx SpriteSheet { get; private set; } = new .(&Data.SpriteSheetData, Data.SpriteSheetData.Count) ~ delete _;
	public TextureEx BoxsubmusLogo { get; private set; } = new .(&Data.BoxsubmusLogoData, Data.BoxsubmusLogoData.Count, .TEXTURE_FILTER_BILINEAR) ~ delete _;
	public TextureEx Logo { get; private set; } = new .(&Data.LogoData, Data.LogoData.Count) ~ delete _;
	public TextureEx TimerNumbers { get; private set; } = new .(&Data.TimerNumbersData, Data.TimerNumbersData.Count) ~ delete _;
	public TextureEx TimerLabel { get; private set; } = new .(&Data.TimerLabelData, Data.TimerLabelData.Count) ~ delete _;

	public Music Music { get; private set; }

	public SoundFX SFX_MenuSelect { get; private set; } = new SoundFX(&Data.SFX_MenuSelect, Data.SFX_MenuSelect.Count) ~ delete _;
	public SoundFX SFX_HighScore { get; private set; } = new SoundFX(&Data.SFX_HighScore, Data.SFX_HighScore.Count) ~ delete _;
	public SoundFX SFX_LevelStart { get; private set; } = new SoundFX(&Data.SFX_LevelStart, Data.SFX_LevelStart.Count) ~ delete _;
	public SoundFX SFX_DrumRoll { get; private set; } = new SoundFX(&Data.SFX_DrumRoll, Data.SFX_DrumRoll.Count) ~ delete _;
	public SoundFX SFX_Tick { get; private set; } = new SoundFX(&Data.SFX_Tick, Data.SFX_Tick.Count) ~ delete _;
	public SoundFX SFX_TickLittleTime { get; private set; } = new SoundFX(&Data.SFX_TickLittleTime, Data.SFX_TickLittleTime.Count) ~ delete _;
	public SoundFX SFX_TimeAdd { get; private set; } = new SoundFX(&Data.SFX_TimeAdd, Data.SFX_TimeAdd.Count) ~ delete _;
	public SoundFX SFX_GameOver { get; private set; } = new SoundFX(&Data.SFX_GameOver, Data.SFX_GameOver.Count) ~ delete _;

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