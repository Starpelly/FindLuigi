using System;
using RaylibBeef;

namespace FindLuigi.Scenes;

public class Splashscreen : Scene
{
	public override void OnLoad(){}

	public override void OnUnload(){}

	public override void OnUpdate()
	{
		if (Raylib.IsKeyPressed(.KEY_SPACE))
		{
			Engine.ChangeScene<Game>();
		}
	}

	public override void OnDraw()
	{
		Raylib.ClearBackground(Raylib.BLACK);

		let timePO = Engine.CurrentSceneTime - 0.25f;

		var logoPosX = 0.0f;
		var logoPosY = 0.0f;

		let logoSizeMult = Math.Lerp(0.5f, 0.53f, timePO) * 2.0f;
		let logoSize = Vector2(Engine.Assets.BoxsubmusLogo.Texture.width * logoSizeMult, Engine.Assets.BoxsubmusLogo.Texture.height * logoSizeMult);

		let logoPosMiddleX = (Raylib.GetScreenWidth() * 0.5f) - (logoSize.x * 0.5f);
		let logoPosMiddleY = (Raylib.GetScreenHeight() * 0.5f) - (logoSize.y * 0.5f);

		let bounceInLength = 1.6f;

		// Drop Down
		if (timePO < bounceInLength)
		{
			let length = 1f;
			let offset = 0.1f;

			let time = Math.Clamp(timePO, offset, offset + length);
			let ease = EasingFunctions.OutElastic(Math.Normalize(time, offset, offset + length), 0.4f);

			logoPosX = logoPosMiddleX;
			logoPosY = Math.Lerp(-logoSize.y, logoPosMiddleY, ease);
		}
		// Slide Left
		else
		{
			let length = 0.5f;

			let ease = EasingFunctions.InBack(Math.Normalize(timePO, bounceInLength, bounceInLength + length), 1.1f);
			logoPosX = Math.Lerp(logoPosMiddleX, -logoSize.x, ease);
			logoPosY = logoPosMiddleY;
		}

		Raylib.DrawTextureEx(Engine.Assets.BoxsubmusLogo.Texture, .(logoPosX, logoPosY), 0, logoSizeMult, Raylib.WHITE);

		if (timePO > 2.1f)
		{
			Engine.ChangeScene<Title>();
		}
	}
}