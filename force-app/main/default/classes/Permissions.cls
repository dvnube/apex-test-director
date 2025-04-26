/**
 * Handles assignment of permission sets to users.
 */
public without sharing class Permissions {
    public static Database.SaveResult assignPermissionSets(
        Id userId,
        String permissionSetName
    ) {
        return assignPermissionSets(
            new List<Id>{ userId },
            new List<String>{ permissionSetName }
        )[0];
    }

    public static List<Database.SaveResult> assignPermissionSets(
        Id userId,
        List<String> permissionSetNames
    ) {
        return assignPermissionSets(new List<Id>{ userId }, permissionSetNames);
    }

    public static List<Database.SaveResult> assignPermissionSets(
        List<Id> userIds,
        String permissionSetName
    ) {
        return assignPermissionSets(
            userIds,
            new List<String>{ permissionSetName }
        );
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    public static List<Database.SaveResult> assignPermissionSets(
        List<Id> userIds,
        List<String> permissionSetNames
    ) {
        List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();

        for (PermissionSet ps : [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name IN :permissionSetNames
        ]) {
            for (Id userId : userIds) {
                permissionSetAssignments.add(
                    new PermissionSetAssignment(
                        AssigneeId = userId,
                        PermissionSetId = ps.Id
                    )
                );
            }
        }

        return Database.insert(permissionSetAssignments, false);
    }
}
