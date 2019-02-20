/* *
* Test class for validating the methods from CloneOpportunityController class
* */

@isTest
class CloneOpportunityControllerTest {
    
    @testSetup
    static void createTestData() {
        
        // Get the pricebook id
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create your product
        Product2 prod = new Product2(
             Name = 'Product X',
             ProductCode = 'Pro-X',
             isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
             Pricebook2Id = pricebookId,
             Product2Id = prod.Id,
             UnitPrice = 100.00,
             IsActive = true
        );
        insert pbEntry;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            CloseDate = System.today(),
            StageName = 'Closed Won'
        );
        insert opp;
        
        //create your opportunity line item.  
        OpportunityLineItem oli = new OpportunityLineItem(
        
             OpportunityId = opp.Id,
             Quantity = 5,
             PricebookEntryId = pbEntry.Id,
             TotalPrice = 5 * pbEntry.UnitPrice
             
        );
        insert oli;
    }
    
    
    @isTest
    static void getOpportunityLineItems_test() {
        
        Opportunity opp = [SELECT Id, StageName, CloseDate, AccountId FROM Opportunity LIMIT 1];
        
        Test.startTest();
        
        String clonedOppRes = CloneOpportunityController.cloneOpportunityAndReturnProducts(opp, opp.Id);
        
        System.assertNotEquals( null, clonedOppRes );
        
        List<Opportunity> lstOpportunity = [SELECT Id FROM Opportunity ORDER BY CreatedDate];
        
        System.assertEquals(2, lstOpportunity.size());
        
        String clonedOppId = lstOpportunity[1].Id;
        
        Map<Id, OpportunityLineItem> mapOppLineItems = new Map<Id, OpportunityLineItem>([SELECT Id, UnitPrice, Quantity, Description, ServiceDate FROM OpportunityLineItem ]);
        
        System.assertNotEquals( null, CloneOpportunityController.cloneOpportunityLineItems( opp.Id, clonedOppId, new List<Id>(mapOppLineItems.keySet()), new List<OpportunityLineItem>() ) );
        
        System.assertEquals( 1, [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :clonedOppId].size() );
        
        Test.stopTest();
    }
}