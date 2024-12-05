namespace FindLuigi;

public abstract class Scene
{
	public abstract void OnLoad();
	public abstract void OnUnload();
	public abstract void OnUpdate();
	public abstract void OnDraw();
	public abstract void OnWindowResize();
}