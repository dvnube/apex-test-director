# Apex Test Director

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/dvnube/apex-test-director.svg)]()

The Apex Test Director is a small framework designed to assist with the creation of multiple test scenarios for a single organization. It is designed to work in way so that developers can modularize the different components that build the data of their tests.

## Rationale

What often happens is a bunch of code that relies on a specific order of execution with the almost exact same data being created over and over again. With this framework we expect that each different scene is encapsulated in its own class, and that each scene is responsible for creating a specific piece of data. This allows developers to create a set of test data that can be reused in multiple tests. It also allows developers to create a set of test scenarios that can be reused in multiple tests. This allows more focus on the business logic of their tests rather than the setup of the test data.

### Example

A project has a lot of automation and Apex that needs to be tested. Most, if not all, of the data in the project relies on creating an account and a contact, at least. But then, there are other parts of the system that rely on creating multiple accounts or multiple contacts, or a mixture of these. And then there are other scenarios after creating those that rely on creating opportunities, or cases, or whatever else. This is a lot of code that needs to be repeated over and over again in the tests, even with the `@TestSetup` annotation.

If the test director is used properly, it should significantly reduce the time and amount of code that needs to be written in the tests, as each different part of the test data build is encapsulated in its own class.

## Installation

To install this on your org/project, you can just deploy the `force-app` folder as it is.

> NOTE: This repository includes a .forceignore file that ignores the deploy of the sample [account scenes](force-app/main/default/classes/AccountScenes.cls) file.

## Usage

### Before you start

To use this framework, begin with thinking about the different "scenes", or "layers", of your test. These should represent each a separate process of creating SObject test data. For example, the first scene in a test might be the creation of accounts, followed by the scene of creating the contacts related to those accounts, followed by creating opportunities, and so on.

### Defining the scenes

When you are done thinking about those "base" scenes, you can start creating the "Scenes" Apex files in your project that will represent each of those scenes. Each scene should extend the `TestScene` class and implement the `build` method. This method accepts and returns a `Map<String, Object>` object. The keys of this map define the name of the data that will be accessible through the `TestDirector` class during the test, and also which parameters are going to be available to other scenes during the test execution.

### Chaining scenes

Due to the nature of the `build` method, you are able to use the director to chain scenes together. This means that you can create a scene that will use the data from another scene to build its own data. This is done by passing the data from the first scene to the second scene as parameters. The next scene executed by the director will have access to the data from the previous scene, and so on. This allows you to create a chain of scenes that will build the data for your test.

So, instead of listing each individual object creation on your tests, like this:

```apex
Account acc = new Account(Name = 'Test Account');
insert acc;

Contact con = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id);
insert con;
```

You can create two scenes that will create the account and the contact records for you, like this:

```apex
@isTest
private class AccountScene extends TestScene {
    public override Map<String, Object> build(Map<String, Object> params) {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        return new Map<String, Object>{ 'account' => acc };
    }
}
```

```apex
@isTest
private class ContactScene extends TestScene {
    public override Map<String, Object> build(Map<String, Object> params) {
        Account acc = (Account) params.get('account');
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id
        );
        insert con;

        return new Map<String, Object>{ 'contact' => con };
    }
}
```

Although the initial idea of the framework was to use each scene for a single object "layer" of the unit test, there's absolutely nothing preventing you from creating multiple objects at once in a single scene:

```apex
@isTest
private class AccountWithContactScene extends TestScene {
    public override Map<String, Object> build(Map<String, Object> params) {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = acc.Id
        );
        insert con;

        return new Map<String, Object>{ 'account' => acc, 'contact' => con };
    }
}
```

### Asserting the data

Once you have created the scenes, you can use the `TestDirector` class to execute them and assert the data. The `TestDirector` class should be called with these three methods in order:

1. `startWith`: This method starts the test with a single scene.
2. `then`: This is the method that allows chaining and adding more scenes to the test.
3. `action`: Finally, this method tells the director to stop accepting new scenes and execute the test in the order that was provided with the other two methods.

In the [AccountScenes.cls](/force-app/main/default/classes/AccountScenes.cls) file, you can see an example of how to use the `TestDirector` class to execute the scenes and assert the data in the `selfTest` method.

#### getAllScenarioParams

On that method we use the `getAllScenarioParams` method to get all the parameters that were passed to the scenes. This method returns a `Map<String, Object>` object with all the values gathered and stored through the test from all scenes. You can use this map to assert the data that was created by the scenes.

> NOTE: Using strings as the key do mean that one scene may override the data of another scene. This is not a problem if you are careful with the names of the keys, but it is something to keep in mind.

#### getSceneOutput

The `getSceneOutput` method returns the output of a specific scene. This is useful if you want to assert the data that was created by a specific scene. You can use this method to get the output of a scene and assert the data that was created by that scene. It accepts an integer as the parameter, which is the index of the scene in the chain. The first scene is 0, the second scene is 1, and so on.

### Using `runAs`

The `runAs` method allows you to run the test as a specific user. This is useful if you want to test the behavior of the code as a specific user. To use the `runAs` method from the `System` namespace you may specify a user Id as the parameter for the TestDirector instantiation, or use the attribute `runAsUserId` within the scenes, through the `params` that are received in the `build` method (this way you can run the test as a specific user without having to specify the user Id in the `TestDirector` instantiation, and also use different users during the test).

```apex
@isTest
private class TestDirectorTest {
    @isTest
    static void test() {
        User currentUser = new User(Id=UserInfo.getUserId(),

        // runs as the current user
        TestDirector director = new TestDirector(currentUser.Id)
            .startWith(new AccountScene()).
            .then(new ContactScene()).
            .action();

        Test.startTest();
        // ... do the actual test with the data and remember to call Test.stopTest() later
    }
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```

```
