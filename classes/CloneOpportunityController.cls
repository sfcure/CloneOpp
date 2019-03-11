public class CloneOpportunityController {
    
    /**
     * Method which will clone an opportunity with it's products 
     * @param opp : Opportunity record which needs to be cloned
     * @param sourceOppRecordId : Id of the source opportunity, we had to pass it expicitly 
     *                            since it's not coming in the opp param which has page-layout field values
     * */
    @AuraEnabled
    public static String cloneOpportunityAndReturnProducts(Opportunity opp, String sourceOppRecordId) {
        
        System.debug(' opp : ' + opp);
        System.debug(' sourceOppRecordId : ' + sourceOppRecordId);
        
        try {
            Set<String> lstPopulatedFields = opp.getPopulatedFieldsAsMap().keySet();
            Map<String, Schema.SObjectField> mapOpportunityFields = Schema.SObjectType.Opportunity.fields.getMap();
            System.debug('mapOpportunityFields >> ' + mapOpportunityFields);
            //Check for the required fields for the opportunity sObject
            // if they are not the part of the populated fields then add them in query explicitly
            List<String> lstOpportunityFields = new List<String>();
            for( String fieldName : mapOpportunityFields.keySet() ){
                Schema.DescribeFieldResult desribeResult = mapOpportunityFields.get( fieldName ).getDescribe();
                // Check if field is required and not was populated from the page-layout
                if( desribeResult.isCreateable() && 
                   !desribeResult.isNillable() && 
                   !desribeResult.isDefaultedOnCreate() && 
                   !lstPopulatedFields.contains( fieldName.toLowerCase() ) ) { 
                    
                       lstOpportunityFields.add( fieldName.toLowerCase() ); // Add to the query field list    
                }
            }
            
            System.debug( ' >>>> lstOpportunityFields >>> ' + lstOpportunityFields );
            
            // Construct dynamic query from the fetched fields
            String queryForOpp = 'SELECT ' + String.join( lstOpportunityFields, ', ' ) + ' FROM Opportunity WHERE Id = \'' + sourceOppRecordId + '\'';
            system.debug(queryForOpp);
            Opportunity sourceOpp = Database.query( queryForOpp );
            
           
            // Deep clone the opportunity 
            Opportunity clonedOpp = sourceOpp.clone( false, true, false, false );
            
            //Pouplate cloned opportunity fields from the record passed in the method parameter 
            // Get all the values in fieldName and value map
            Map<String, Object> oppFieldsToValue = opp.getPopulatedFieldsAsMap();
            for(String fieldApiName : oppFieldsToValue.keySet()){
                if(fieldApiName != 'Id'){
                    clonedOpp.put(fieldApiName, oppFieldsToValue.get(fieldApiName));  
                }
            }
            
            // Insert the cloned opportunity record 
            if(Schema.SObjectType.Opportunity.isCreateable()){
                insert clonedOpp;
                System.debug('Opportunity record is inserted ' + clonedOpp);
            }
            
            // Again, will query the opportunity line item fields 
            Map<String, Clone_Opportunity_Setting__mdt> mapOpportunityProductFields = new Map<String, Clone_Opportunity_Setting__mdt>();
            Map<String, Schema.SObjectField> mapOpportunityProductDescribedFields = Schema.SObjectType.OpportunityLineItem.fields.getMap();
            List<Column> lstColumns = new List<Column>();
            
            //Check if there are any fields which are provided in the custom metadata 
            // and use them instead of hard-coded fields
            Boolean isFieldsConfigured = false;
            for(Clone_Opportunity_Setting__mdt cos : CloneOpportunityController.getSetting()){
                if(mapOpportunityProductDescribedFields.containsKey( cos.MasterLabel )) {
                    Schema.DescribeFieldResult desribeResult = mapOpportunityProductDescribedFields.get( cos.MasterLabel ).getDescribe();
                    if(desribeResult.isCreateable() ) {
                        mapOpportunityProductFields.put( cos.MasterLabel, cos );  
                    }
                    isFieldsConfigured = true;
                }
            }
            
            // Compulsary fields on the layout 
            // User doesn't have ability to remove them however they can make these fields non-editable
            if(mapOpportunityProductFields.containsKey('Product2Id')){
                Clone_Opportunity_Setting__mdt setting = mapOpportunityProductFields.get('Product2Id');
                lstColumns.add(new Column('Product', 'Product2.Name', 'text', setting.Editable__c, setting.Sortable__c, setting.Required__c));
            }
            else{
                lstColumns.add(new Column('Product', 'Product2.Name', 'text', false, false, true));    
            }
            if(mapOpportunityProductFields.containsKey('Quantity')){
                Clone_Opportunity_Setting__mdt setting = mapOpportunityProductFields.get('Quantity');
                lstColumns.add(new Column('Quantity', 'Quantity', 'number', setting.Editable__c, setting.Sortable__c, setting.Required__c));
            }
            else{
                lstColumns.add(new Column('Quantity', 'Quantity', 'number', true, false, true));    
            }
            if(mapOpportunityProductFields.containsKey('UnitPrice')){
                Clone_Opportunity_Setting__mdt setting = mapOpportunityProductFields.get('UnitPrice');
                lstColumns.add(new Column('Sales Price', 'UnitPrice', 'currency', setting.Editable__c, setting.Sortable__c, setting.Required__c));
            }
            else{
                lstColumns.add(new Column('Sales Price', 'UnitPrice', 'currency', true, false, true));    
            }
            
            if(!isFieldsConfigured){
                lstColumns.add(new Column('Line Description', 'Description', 'text', true, false, false));  
            }
            else {
                for(String fieldName : mapOpportunityProductFields.keySet()){
                    if(mapOpportunityProductDescribedFields.containsKey( fieldName )) {
                        Schema.DescribeFieldResult desribeResult = mapOpportunityProductDescribedFields.get( fieldName ).getDescribe();
                        if( desribeResult.isCreateable() ) {
                            lstColumns.add( new Column(desribeResult, mapOpportunityProductFields.get(fieldName)) ); 
                        }
                    }
                }
            }
            
            List<String> fieldsInQuery = new List<String>();
            for(Column c : lstColumns){
                if(!fieldsInQuery.contains(c.fieldName.toLowerCase())){
                    fieldsInQuery.add(c.fieldName.toLowerCase());    
                }       
            }
            // Construct dynamic query from the fetched fields
            String queryForOppLineItem = 'SELECT ' + String.join(fieldsInQuery, ', ' ) + ' FROM OpportunityLineItem WHERE OpportunityId = \'' + sourceOppRecordId + '\'';
            
            List<OpportunityLineItem> sourceOppLineItems = Database.query( queryForOppLineItem );
            
            String dataColumnJson = '{ "clonedOppId": "' + clonedOpp.Id + '", "columns": ' + JSON.serialize(lstColumns) + ', "data":' + JSON.serialize(sourceOppLineItems) + '}'; 
            
            System.debug('dataColumnJson : ' + dataColumnJson);
            
            return dataColumnJson;
        }
        catch(Exception e) {
            System.debug(e.getLineNumber() + ' : ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + ' : ' + e.getMessage() );
        }
    }
    
    
     /**
     * Method which will clone all opportunity line items 
     * @param sourceOppRecordId : Record id of the source opportunity
     * @param clonedOppRecordId : Id of the target opportunity record
     * @param lstSourceLineItemIds : Id of line items from the source opportunity
     * @param lstLineItemsChanges :  List of OpportunityLineItem object which has updated values                        
     * */
    @AuraEnabled
    public static Id cloneOpportunityLineItems(Id sourceOppRecordId, Id clonedOppRecordId, List<Id> lstSourceLineItemIds, List<OpportunityLineItem> lstLineItemsChanges){
        
        try{
            System.debug(' sourceOppRecordId : ' + sourceOppRecordId );
            System.debug(' clonedOppRecordId : ' + clonedOppRecordId );
            System.debug(' lstSourceLineItemIds : ' + lstSourceLineItemIds );
            System.debug(' lstLineItemsChanges : ' + lstLineItemsChanges );
            
            // Query opportunity line items from the source opportunity and 
            // use the fields which has been configured at custom metadata level
            List<String> lstFieldsInQuery = new List<String>{ 'product2id', 'quantity', 'pricebookentryid', 'unitprice' };
                                                                  
            // Check the custom metadata level if fields are provided there 
            Map<String, Clone_Opportunity_Setting__mdt> mapOpportunityProductFields = new Map<String, Clone_Opportunity_Setting__mdt>();
            Map<String, Schema.SObjectField> mapOpportunityProductDescribedFields = Schema.SObjectType.OpportunityLineItem.fields.getMap();
            
            Boolean isFieldsConfigured = false;
            for(Clone_Opportunity_Setting__mdt cos : CloneOpportunityController.getSetting()){
                if(mapOpportunityProductDescribedFields.containsKey( cos.MasterLabel.toLowerCase() )) {
                    Schema.DescribeFieldResult desribeResult = mapOpportunityProductDescribedFields.get( cos.MasterLabel.toLowerCase() ).getDescribe();
                    if(desribeResult.isCreateable() && ( cos.Cloneable__c || cos.Editable__c ) ) {
                        mapOpportunityProductFields.put( cos.MasterLabel.toLowerCase(), cos );  
                    }
                    isFieldsConfigured = true;
                }
            }
            //If no fields are not configured then use the hard-coded fields
            if(!isFieldsConfigured){
                for( String fieldName : mapOpportunityProductDescribedFields.keySet() ){
                    Schema.DescribeFieldResult desribeResult = mapOpportunityProductDescribedFields.get( fieldName ).getDescribe();
                    // Add to the query field list  
                    if( desribeResult.isCreateable() && !lstFieldsInQuery.contains(fieldName.toLowerCase() ) && fieldName.toLowerCase() != 'totalprice' ){
                        lstFieldsInQuery.add( fieldName.toLowerCase() );
                    }
                }         
            }
            else {
                for(String fieldName : mapOpportunityProductFields.keySet()){
                    if(!lstFieldsInQuery.contains(fieldName)){
                        lstFieldsInQuery.add(fieldName);
                    }        
                } 
                if( !(lstFieldsInQuery.contains('unitprice') || lstFieldsInQuery.contains('totalprice')) ) {
                    lstFieldsInQuery.add('unitprice');
                }
            }
            System.debug(lstFieldsInQuery);
            //Check for the required fields on opportunity line item object
            // if they are not the part of the lstFieldsInQuery then add them in query explicitly
            for( String fieldName : mapOpportunityProductDescribedFields.keySet() ){
                Schema.DescribeFieldResult desribeResult = mapOpportunityProductDescribedFields.get( fieldName ).getDescribe();
                if( desribeResult.isCreateable() && 
                   !desribeResult.isNillable() && 
                   !desribeResult.isDefaultedOnCreate() && 
                   !lstFieldsInQuery.contains( fieldName.toLowerCase() ) ) { 
                       // Add to the query field list   
                       lstFieldsInQuery.add( fieldName.toLowerCase() );  
                }
            }
            
            System.debug(' INCLUDING REQUIRED FIELDS : ' + lstFieldsInQuery);
            
            Map<Id, OpportunityLineItem> mapUpdatedOppLineItems = new Map<Id, OpportunityLineItem>();
            if(lstLineItemsChanges != NULL){
                mapUpdatedOppLineItems.putAll(lstLineItemsChanges);
            }
            
            //Query all the opportunity line items from the query 
            // Construct dynamic query from the fetched fields
            String queryForOppLineItem = 'SELECT ' + String.join( lstFieldsInQuery, ', ' ) + ' FROM OpportunityLineItem WHERE Id IN :lstSourceLineItemIds';
            List<OpportunityLineItem> lstSourceOppLineItems = Database.query(queryForOppLineItem);
            
            List<OpportunityLineItem> lstClonedOpportunityLineItems = new List<OpportunityLineItem>();
            //Update source opp line items with updated values
            for(OpportunityLineItem sourceOli : lstSourceOppLineItems){
                
                OpportunityLineItem clonedOppLineItem = sourceOli.clone( false, true, false, false );
                System.debug(' clonedOppLineItem : ' + clonedOppLineItem );
                clonedOppLineItem.OpportunityId = clonedOppRecordId;
                
                if(mapUpdatedOppLineItems.containsKey(sourceOli.Id)){
                    //Find the populated values on the sObject
                    Map<String, Object> mapFieldsToValue = mapUpdatedOppLineItems.get(sourceOli.Id).getPopulatedFieldsAsMap(); 
                    for (String fieldName : mapFieldsToValue.keySet()) {
                        if(fieldName != 'Id'){
                            System.debug(' fieldName : ' + fieldName + ' => value : ' + mapFieldsToValue.get(fieldName));
                            clonedOppLineItem.put(fieldName, mapFieldsToValue.get(fieldName));
                        }
                    }
                }    
                //Adding to the list 
                lstClonedOpportunityLineItems.add(clonedOppLineItem);
                
            }
            
            insert lstClonedOpportunityLineItems;
            return clonedOppRecordId;
        }
        catch(Exception e) {
            System.debug(e.getLineNumber() + ' : ' + e.getMessage());
            throw new AuraHandledException( e.getLineNumber() + ' : ' + e.getMessage() );
        }
    }  
    
    
    /**
     * This method is returning the allowed types for the column
     * Lightning data table supported types are being retuned based on the Schema.DisplayType enum
     */
    public static String getColumnType(Schema.DisplayType fieldType){
        String columnType = 'text';
        switch on fieldType {
            when STRING, PICKLIST, TEXTAREA, MULTIPICKLIST  {
                columnType = 'text';
            }
            when DOUBLE, LONG, INTEGER {
                columnType = 'number';
            }
            when DATETIME {
                columnType = 'date';
            }
            when DATE {
                columnType = 'date-local';
            }
            when ADDRESS {
                columnType = 'location';
            }
            when else { 
                columnType = String.valueOf(fieldType).toLowerCase();    
            }
        } 
        return columnType;
    }
    
    public static List<Clone_Opportunity_Setting__mdt> getSetting(){
        if(!Test.isRunningTest()){
            return [SELECT MasterLabel, Cloneable__c, Editable__c, Sortable__c, Required__c FROM Clone_Opportunity_Setting__mdt];    
        }
        else {
            String jsonData = '[{"MasterLabel": "UnitPrice", "Cloneable__c": true, "Editable__c": true, "Required__c": true, "Sortable__c": false }, ' +
                               ' {"MasterLabel": "Quantity", "Cloneable__c": true, "Editable__c": true, "Required__c": true, "Sortable__c": false }, ' + 
                               ' {"MasterLabel": "Product2Id", "Cloneable__c": true, "Editable__c": true, "Required__c": true, "Sortable__c": false }, ' + 
                               ' {"MasterLabel": "Description", "Cloneable__c": false, "Editable__c": true, "Required__c": false, "Sortable__c": false } ' + 
                               ']';
            List<Clone_Opportunity_Setting__mdt> lstSetting = (List<Clone_Opportunity_Setting__mdt>) JSON.deserialize(jsonData, List<Clone_Opportunity_Setting__mdt>.class);
            return lstSetting;    
        } 
    }
    
    //Wrapper class for generating the JSON for Lightning:dataTable columns
    public class Column {
        String label;
        String fieldName;
        String type;
        Boolean editable;
        Boolean sortable;
        Boolean required;
        Map<String, String> cellAttributes;   // To control the cell behaviour
        
        public Column(Schema.DescribeFieldResult field, Clone_Opportunity_Setting__mdt setting){
            this.label = field.getLabel();
            this.fieldName = field.getName();
            this.type = getColumnType(field.getType());
            this.editable = setting.Editable__c;
            this.sortable = setting.Sortable__c;
            this.required = setting.Required__c;
            this.cellAttributes = new Map<String, String>{'alignment'=>'left'};
        }
        public Column(String label, String fieldName, String type, Boolean editable, Boolean sortable, Boolean required){
            this.label = required ? '*' + label : label;
            this.fieldName = fieldName;
            this.type = type;
            this.editable = editable;
            this.sortable = sortable;
            this.required = required;
            this.cellAttributes = new Map<String, String>{'alignment'=>'left'};
        }
        
    }
}
