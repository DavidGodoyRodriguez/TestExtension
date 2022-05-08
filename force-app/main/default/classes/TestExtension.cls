
@IsTest
public class TestExtension {

    public class LimitsException extends Exception {}
    
    public static void startTest() {
        Test.startTest();
        // Use it in your tests, in case future implementations may be required...
    }

    public static void stopTest() {
        TestLimitsChecker.runChecks();
        Test.stopTest();
    }

}
