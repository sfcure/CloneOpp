public class CloneOpportunityController {
    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityLineItems(String opportunityId) {
        
        List<OpportunityLineItem> lstClonedLineItems = new List<OpportunityLineItem>();
        
        for( List<OpportunityLineItem> lstItems : [
            SELECT
                Id,
                Product2Id,
                Product2.Name,
                Quantity,
                ServiceDate,
                UnitPrice,
                Description,
                PriceBookEntryId
            FROM 
                OpportunityLineItem
            WHERE
                OpportunityId = :opportunityId
            ORDER BY
                SortOrder
        ]) {
            lstClonedLineItems = lstItems;
        }
        return lstClonedLineItems;
    }
    
    
    /**
     * Method which will clone an opportunity with it's products 
     * @param opportunityId : Opportunity Id which is the source for cloning
     * @param lstLineItems : Products which are going to be cloned 
     * */
    @AuraEnabled 
    public static String cloneOpportunityWithProducts( Id opportunityId, List<OpportunityLineItem>  lstLineItems ){
        
        try {
            
            // Create a map of OpportunityLineItem objects so we can get the quantity and unit price 
            Map<Id, OpportunityLineItem> mapOpportunityLineItems = new Map<Id, OpportunityLineItem>();
            for( OpportunityLineItem oli : lstLineItems ){
                mapOpportunityLineItems.put( oli.Id, oli );
            }
            
            // Get fields from the fieldset which will be copied over the new opportunity
            List<String> lstOpportunityFields = new List<String>();
            System.debug( SObjectType.Opportunity.FieldSets.Clone_Opportunity_Field_Set.getFields() );
            Map<String, Schema.SObjectField> mapOpportunityFields = Schema.SObjectType.Opportunity.fields.getMap();
            for( Schema.FieldSetMember f : SObjectType.Opportunity.FieldSets.Clone_Opportunity_Field_Set.getFields() ) {
                if( mapOpportunityFields.get( f.getFieldPath() ).getDescribe().isUpdateable() ) // Check if this field can be updated for this user
                    lstOpportunityFields.add( f.getFieldPath().toLowerCase() );
            }
            System.debug( ' >>>> lstOpportunityFields >>> ' + lstOpportunityFields );
            
            //Check for the required fields for the opportunity sobject
            // if they are not the part of the fieldset then add them in query explicitly
            for( String fieldName : mapOpportunityFields.keySet() ){
                Schema.DescribeFieldResult desribeResult = mapOpportunityFields.get( fieldName ).getDescribe();
                if( desribeResult.isCreateable() && 
                   !desribeResult.isNillable() && 
                   !desribeResult.isDefaultedOnCreate() && 
                   !lstOpportunityFields.contains( fieldName.toLowerCase() ) ) { // Check if field is required and not a part of fieldset 
                    
                       lstOpportunityFields.add( fieldName ); // Add to the query field list    
                }
            }
            
            System.debug( ' >>>> lstOpportunityFields >>> ' + lstOpportunityFields );
            
            // Construct dynamic query from the fetched fields
            String queryForOpp = 'SELECT ' + String.join( lstOpportunityFields, ', ' ) + ' FROM Opportunity WHERE Id = \'' + opportunityId + '\'';
            system.debug(queryForOpp);
            Opportunity sourceOpp = Database.query( queryForOpp );
            
            // Again, will query the opportunity line item fields 
            
            List<String> lstOpportunityProductFields = new List<String>();
            Map<String, Schema.SObjectField> mapOpportunityProductFields = Schema.SObjectType.OpportunityLineItem.fields.getMap();
            for( Schema.FieldSetMember f : SObjectType.OpportunityLineItem.FieldSets.Clone_Opportunity_Field_Set.getFields() ) {
                if( mapOpportunityProductFields.get( f.getFieldPath() ).getDescribe().isCreateable() ) // Check if this field is creatable for this user
                    lstOpportunityProductFields.add( f.getFieldPath().toLowerCase() );
            }
                        
            // check for product2Id and PriceBookEntry field
            if( !lstOpportunityProductFields.contains( 'product2id' ) ) {
                lstOpportunityProductFields.add( 'product2id' );    
            } 
            if( !lstOpportunityProductFields.contains( 'pricebookentryid' ) ) {
                lstOpportunityProductFields.add( 'pricebookentryid' );    
            } 
            //Check for the required fields on opportunity line item object
            // if they are not the part of the fieldset then add them in query explicitly
            for( String fieldName : mapOpportunityProductFields.keySet() ){
                Schema.DescribeFieldResult desribeResult = mapOpportunityProductFields.get( fieldName ).getDescribe();
                if( desribeResult.isCreateable() && 
                   !desribeResult.isNillable() && 
                   !desribeResult.isDefaultedOnCreate() && 
                   !lstOpportunityProductFields.contains( fieldName.toLowerCase() ) ) { // Check if field is required and not a part of fieldset 
                    
                       lstOpportunityProductFields.add( fieldName ); // Add to the query field list    
                }
            }
            
            // Construct dynamic query from the fetched fields
            String queryForOppLineItem = 'SELECT ' + String.join( lstOpportunityProductFields, ', ' ) + ' FROM OpportunityLineItem WHERE OpportunityId = \'' + opportunityId + '\'';
            
            List<OpportunityLineItem> sourceOppLineItems = Database.query( queryForOppLineItem );
            
            // Start cloning opportunity for the queried fields
            Opportunity clonedOpp = sourceOpp.clone( false, true, false, false );
            
            // Inser new opportunity record so we can use it's id for opportunity product records
            insert clonedOpp;
            
            // Clone all the related opportunity products
            List<OpportunityLineItem> clonedOppLineItems = new List<OpportunityLineItem>();
            for( OpportunityLineItem oli : sourceOppLineItems ) {
                OpportunityLineItem clonedOli = oli.clone( false, true, false, false );
                clonedOli.OpportunityId = clonedOpp.Id;
                if( mapOpportunityLineItems.containsKey( oli.Id ) ) {
                    clonedOli.Quantity = mapOpportunityLineItems.get( oli.Id ).Quantity;
                    clonedOli.UnitPrice = mapOpportunityLineItems.get( oli.Id ).UnitPrice;
                    clonedOli.ServiceDate = mapOpportunityLineItems.get( oli.Id ).ServiceDate;
                    clonedOli.Description = mapOpportunityLineItems.get( oli.Id ).Description;
                }
                clonedOppLineItems.add( clonedOli );  
                
            }
            
            insert clonedOppLineItems;
            
            return clonedOpp.Id;
        }
        catch(Exception e) {
            System.assert( false, e.getMessage() + ' : ' + e.getLineNumber() );
        }
       
        return null;
    }
}