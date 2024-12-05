namespace FindLuigi.Scenes;

public class Init : Scene
{
	public override void OnLoad()
	{
		Engine.ChangeScene<Game>();
	}

	public override void OnUnload(){}
	public override void OnUpdate(){}
	public override void OnDraw(){}
	public override void OnWindowResize(){}
}