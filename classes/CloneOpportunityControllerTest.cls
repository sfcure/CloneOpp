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
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        
        System.assertEquals( 1, CloneOpportunityController.getOpportunityLineItems( opp.Id ).size() );
        
        List<OpportunityLineItem> lstOppLineItems = [SELECT Id, UnitPrice, Quantity, Description, ServiceDate FROM OpportunityLineItem ];
        
        System.assertNotEquals( null, CloneOpportunityController.cloneOpportunityWithProducts( opp.Id, lstOppLineItems ) );
        
        System.assertEquals( 2, [SELECT Id FROM Opportunity].size() );
        
        Test.stopTest();
    }
}