public abstract class TestScene {
    public virtual List<String> getRunningUserPermissions() {
        return new List<String>();
    }

    public abstract Map<String, Object> build(Map<String, Object> params);

    public virtual Map<String, Object> build() {
        return build(new Map<String, Object>());
    }
}
