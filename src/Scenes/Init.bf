namespace FindLuigi.Scenes;

public class Init : Scene
{
	public override void OnLoad()
	{
		Engine.ChangeScene<Splashscreen>();
	}

	public override void OnUnload(){}
	public override void OnUpdate(){}
	public override void OnDraw(){}
}