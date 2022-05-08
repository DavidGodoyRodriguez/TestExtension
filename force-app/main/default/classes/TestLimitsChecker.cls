@IsTest
public class TestLimitsChecker {

    private static String TEST_GOVERNOR_LIMITS_SOBJECT_NAME = 'Test_Governor_Limits__mdt';
    private static String TEST_GOVERNOR_LIMITS_RECORD_DEVELOPER_NAME = 'Test_Governor_Limits';
    private static List<String> TEST_GOVERNOR_LIMITS_FIELDS = new List<String>{
        'CPU_Maximum_Limit__c', 
        'Callouts_Limit__c', 
        'DML_Immediate_Limit__c', 
        'DML_Rows_Limit__c', 
        'DML_Statements_Limit__c', 
        'Email_Invocations_Limit__c', 
        'Future_Calls_Limit__c', 
        'Heap_Maximum_Limit__c', 
        'Mobile_Apex_Push_Calls_Limit__c', 
        'Queueable_Jobs_Limit__c', 
        'SOQL_Queries_Limit__c', 
        'SOQL_Query_Rows_Limit__c', 
        'SOSL_Queries_Limit__c'
    };

    private static Test_Governor_Limits__mdt testGovernorLimits;

    private static String CHECK_LIMITS_EXCEPTION_MESSAGE = 'Please check the following governor limits for your test to improve performance: {0}';
    private class TestLimitsCheckerException extends Exception {}

    public static void runChecks() {
        getGovernorLimitsConfiguration();
        assertGovernorLimits();
    }

    private static void getGovernorLimitsConfiguration() {
        if (testGovernorLimits == null) {
            List<Test_Governor_Limits__mdt> testGovernorLimitsList = Database.query(
                'SELECT ' + String.join(TEST_GOVERNOR_LIMITS_FIELDS, ', ') + ' ' +
                'FROM ' + TEST_GOVERNOR_LIMITS_SOBJECT_NAME + ' ' +
                'WHERE DeveloperName = \'' + TEST_GOVERNOR_LIMITS_RECORD_DEVELOPER_NAME +'\''
            );

            if (!testGovernorLimitsList.isEmpty()) {
                testGovernorLimits = testGovernorLimitsList.get(0);
            }
        }
    }
    
    private static void assertGovernorLimits() {
        List<String> surpassedLimits = new List<String>();
        if (Limits.getCpuTime() > calculateMaximumAllowedLimit(Limits.getLimitCpuTime(), testGovernorLimits.CPU_Maximum_Limit__c)) {
            surpassedLimits.add('CPU');
        }
        if (Limits.getCallouts() > calculateMaximumAllowedLimit(Limits.getLimitCallouts(), testGovernorLimits.Callouts_Limit__c)) {
            surpassedLimits.add('Callouts');
        }
        if (Limits.getPublishImmediateDML() > calculateMaximumAllowedLimit(Limits.getLimitPublishImmediateDML(), testGovernorLimits.DML_Immediate_Limit__c)) {
            surpassedLimits.add('Publish Immediate DML');
        }
        if (Limits.getDmlRows() > calculateMaximumAllowedLimit(Limits.getLimitDmlRows(), testGovernorLimits.DML_Rows_Limit__c)) {
            surpassedLimits.add('DML Rows');
        }
        if (Limits.getDmlStatements() > calculateMaximumAllowedLimit(Limits.getLimitDmlStatements(), testGovernorLimits.DML_Statements_Limit__c)) {
            surpassedLimits.add('DML Statements');
        }
        if (Limits.getEmailInvocations() > calculateMaximumAllowedLimit(Limits.getLimitEmailInvocations(), testGovernorLimits.Email_Invocations_Limit__c)) {
            surpassedLimits.add('Email Invocations');
        }
        if (Limits.getFutureCalls() > calculateMaximumAllowedLimit(Limits.getLimitFutureCalls(), testGovernorLimits.Future_Calls_Limit__c)) {
            surpassedLimits.add('Future Calls');
        }
        if (Limits.getHeapSize() > calculateMaximumAllowedLimit(Limits.getLimitHeapSize(), testGovernorLimits.Heap_Maximum_Limit__c)) {
            surpassedLimits.add('Heap Size');
        }
        if (Limits.getMobilePushApexCalls() > calculateMaximumAllowedLimit(Limits.getLimitMobilePushApexCalls(), testGovernorLimits.Mobile_Apex_Push_Calls_Limit__c)) {
            surpassedLimits.add('Mobile Push Apex Calls');
        }
        if (Limits.getQueueableJobs() > calculateMaximumAllowedLimit(Limits.getLimitQueueableJobs(), testGovernorLimits.Queueable_Jobs_Limit__c)) {
            surpassedLimits.add('Queueable Jobs');
        }
        if (Limits.getQueries() > calculateMaximumAllowedLimit(Limits.getLimitQueries(), testGovernorLimits.SOQL_Queries_Limit__c)) {
            surpassedLimits.add('SOQL Queries');
        }
        if (Limits.getQueryRows() > calculateMaximumAllowedLimit(Limits.getLimitQueryRows(), testGovernorLimits.SOQL_Query_Rows_Limit__c)) {
            surpassedLimits.add('SOQL Query Rows');
        }
        if (Limits.getSoslQueries() > calculateMaximumAllowedLimit(Limits.getLimitSoslQueries(), testGovernorLimits.SOSL_Queries_Limit__c)) {
            surpassedLimits.add('SOSL Queries');
        }

        if (!surpassedLimits.isEmpty()) {
            String surpassedLimitsString = String.join(surpassedLimits, ', ');
            List<String> formatterParameters = new List<String>{surpassedLimitsString};
            throw new TestLimitsCheckerException(String.format(CHECK_LIMITS_EXCEPTION_MESSAGE, formatterParameters));
        }

    }

    private static Decimal calculateMaximumAllowedLimit(Integer platformGovernorLimit, Decimal allowedLimitPercentage) {
        return (platformGovernorLimit * allowedLimitPercentage / 100);
    }

}
