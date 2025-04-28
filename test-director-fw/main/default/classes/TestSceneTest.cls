@IsTest
private class TestSceneTest {
    @IsTest
    static void test() {
        TestSceneTest.Implementation i = new TestSceneTest.Implementation();
        i.build();
        i.getRunningUserPermissions();
        Assert.isTrue(true, '');
    }

    private class Implementation extends TestScene {
        public override Map<String, Object> build(Map<String, Object> params) {
            return new Map<String, Object>();
        }
    }
}
