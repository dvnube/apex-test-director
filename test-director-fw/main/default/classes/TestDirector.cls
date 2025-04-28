@IsTest
public class TestDirector {
    // holds the scenes to be run in sequence
    private List<TestScene> scenes;
    // if the scene is to be run as a specific user, the user's id is set to
    // this variable
    private Id runAsUserId;
    // stores the output for all scenes run by the director
    private Map<String, Object> sceneOutputs = new Map<String, Object>();
    // stores the output for each scene run by the director
    private List<Map<String, Object>> individualSceneOutputs = new List<Map<String, Object>>();

    /**
     * Constructor in which it is possible to define the running user for the
     * scenes.
     */
    public TestDirector(Id runAsUserId) {
        this.scenes = new List<TestScene>();
        this.runAsUserId = runAsUserId;

        this.sceneOutputs.put('runAsUserId', runAsUserId);
    }

    /**
     * Constructor for running the test as the current user in system mode.
     */
    public TestDirector() {
        this.scenes = new List<TestScene>();
    }

    /**
     * Starts the test with the first scene. This method is used to start the
     * test scenario.
     * @param ts The first scene to be run.
     * @return The TestDirector instance.
     */
    public TestDirector startWith(TestScene ts) {
        return then(ts);
    }

    /**
     * Adds a scene to the test scenario.
     * This method is used to add additional scenes to the test scenario.
     * @param ts The scene to be added.
     * @return The TestDirector instance.
     */
    public TestDirector then(TestScene ts) {
        this.scenes.add(ts);

        return this;
    }

    /**
     * Executes the test scenario. Called after `startWith` and `then`(s).
     * This method assigns permissions as necessary and runs the scenes in
     * the order they were added.
     * @return The TestDirector instance.
     */
    public TestDirector action() {
        Map<String, Object> currentScenarioParams = new Map<String, Object>();
        Set<String> permissionsNames = new Set<String>();

        // build permissions first
        for (TestScene ts : this.scenes) {
            permissionsNames.addAll(ts.getRunningUserPermissions());
        }

        // by default assign permissions to the current user
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Database.SaveResult> assignmentResults = Permissions.assignPermissionSets(
                this.runAsUserId,
                new List<String>(permissionsNames)
            );

            Integer successes = 0;
            Integer errors = 0;

            for (Database.SaveResult sr : assignmentResults) {
                if (!sr.isSuccess()) {
                    errors += 1;
                } else {
                    successes += 1;
                }
            }
        }

        // then objects
        if (this.runAsUserId != null) {
            System.runAs(new User(Id = this.runAsUserId)) {
                runScenes(this.scenes);
            }
        }

        runScenes(this.scenes);

        return this;
    }

    /**
     * Returns the output of all scenes run by the director.
     * The keys are defined by whatever string was used in the scene.
     * @return A map containing the output of all scenes run by the director.
     */
    public Map<String, Object> getAllScenarioParams() {
        return this.sceneOutputs.size() == 0 ? null : this.sceneOutputs;
    }

    /**
     * Returns the output of a specific scene run by the director.
     * The keys are defined by whatever string was used in the scene.
     * @param sceneIndex The index of the scene to get the output for.
     */
    public Map<String, Object> getSceneOutput(Integer sceneIndex) {
        if (
            this.individualSceneOutputs == null ||
            this.individualSceneOutputs.size() == 0 ||
            sceneIndex < 0 ||
            sceneIndex > this.individualSceneOutputs.size() - 1
        ) {
            return null;
        }

        return this.individualSceneOutputs.get(sceneIndex);
    }

    private void runScenes(List<TestScene> scenes) {
        for (TestScene ts : scenes) {
            Map<String, Object> resultParams = ts.build(this.sceneOutputs);

            this.individualSceneOutputs.add(resultParams);
            this.sceneOutputs.putAll(resultParams);
        }
    }
}
