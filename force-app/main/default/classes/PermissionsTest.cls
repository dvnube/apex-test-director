@IsTest
private class PermissionsTest {
    @IsTest
    static void test() {
        PermissionSet ps = [
            SELECT Name
            FROM PermissionSet
            WHERE IsCustom = FALSE
            AND IsOwnedByProfile = FALSE
            LIMIT 1
        ];

        Test.startTest();
        System.runAs(new User(Id=UserInfo.getUserId())) {
            try {
                Permissions.assignPermissionSets(
                    UserInfo.getUserId(),
                    ps.Name
                );
                Permissions.assignPermissionSets(
                    UserInfo.getUserId(),
                    new List<String>{ ps.Name }
                );
                Permissions.assignPermissionSets(
                    new List<Id>{ UserInfo.getUserId() },
                    ps.Name
                );
            } catch (Exception e) {
                Assert.fail('Should not have thrown an exception.');
            }
        }
        Test.stopTest();
    }
}