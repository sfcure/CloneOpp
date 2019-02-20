({
        
    validateFieldsAndhideCustomDockFooter: function(component, event, helper) {
    	component.set("v.isDataChanged", true);	  
        console.log(event.getParam('draftValues'));
        helper.validate(component, event);
    },
    
    cloneOpportunity: function(component, event, helper) {
        // stop the form from submitting since we are going to clone the opportunity 
        // so it will be done in the server side action
        event.preventDefault();       
        var fields = event.getParam("fields");
        //fields["Id"] = component.get("v.recordId");
        console.log(JSON.stringify(fields))
       	
        helper.cloneOppAndGetLineItems(component, fields);
        
    },
    
    handleCloneLineItems: function(component, event, helper){
        helper.cloneOppLineItems(component, event);  
    },
    
    handleColumnSorting : function(component, event, helper) {
        // assign the latest attribute with the sorted column fieldName and sorted direction
    	component.set("v.sortedBy", event.getParam("fieldName"));
    	component.set("v.sortedDirection", event.getParam("sortDirection")); 
        helper.sortData(component, event.getParam("fieldName"), event.getParam("sortDirection"));
    },
    
    /**
     * Handling opp line item row action i.e. deleting a row
     * */
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log(action, row);
        switch (action.name) {
            case 'delete':
                helper.deleteRow(component, row);
                break;
        }
    },
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    navigateToOpp : function( component ) {
        helper.navigateToRecord(component.get("v.clonedOppRecordId"));
    },
})