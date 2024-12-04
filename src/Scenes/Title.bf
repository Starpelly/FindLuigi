using System;
using RaylibBeef;

namespace FindLuigi.Scenes;

public class Title : Scene
{
	public override void OnLoad()
	{
		// Engine.ChangeScene<Game>();
	}

	public override void OnUnload(){}

	public override void OnUpdate()
	{
		Raylib.ClearBackground(Raylib.BLACK);

		void drawLogo()
		{
			let logoScale = 2.0f;
			let measure = Vector2(Engine.Assets.Logo.Size().x * logoScale, Engine.Assets.Logo.Size().y * logoScale);

			let x = (Raylib.GetScreenWidth() * 0.5f) - (measure.x * 0.5f);
			let y = (Raylib.GetScreenHeight() * 0.5f) - (measure.y * 0.5f);

			let length = 1f;
			let ease = EasingFunctions.OutElastic(Math.Normalize(Math.Clamp(Engine.CurrentSceneTime, 0.0f, length), 0.0f, length), 0.4f);

			let logoPosX = Math.Lerp(Raylib.GetScreenWidth(), x, ease) - 20;
			let logoPosY = y;

			Raylib.DrawTextureEx(Engine.Assets.Logo.Texture, .(logoPosX, logoPosY), 0, 2, Raylib.WHITE);
		}

		drawLogo();
	}

	public override void OnDraw(){}
}