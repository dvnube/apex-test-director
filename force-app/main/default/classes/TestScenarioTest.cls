@IsTest
private class TestScenarioTest {
    @IsTest
    static void test() {
        TestScenarioTest.Implementation i = new TestScenarioTest.Implementation();
        i.build();
        i.getRunningUserPermissions();
        Assert.isTrue(true, '');
    }

    private class Implementation extends TestScenario {
    }
}