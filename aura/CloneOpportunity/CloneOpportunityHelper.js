({
    navigateToRecord : function( recordId ) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();	
    },
    
    // Function for checking the required fields
    checkForRequired: function( inputCmp, message ) {
        let value = inputCmp.get("v.value");
        console.log( value );
        if( value == null || value == '' ) {
            inputCmp.set("v.errors", [{ message: message }]);
            return false;
        }
        else {
            //clear error
            inputCmp.set("v.errors", null);
            return true;
        }
    },
    
    // Function which calls server method to create the opportunity
    // and associated products
    cloneOpportunityWithProducts: function( cmp, helper ) {
        
        // this apex method create a new opportunity and it's related opportunity products
        let action = cmp.get("c.cloneOpportunityWithProducts");
        action.setParams({
            opportunityId: cmp.get("v.recordId"),
            lstLineItems: cmp.get("v.lstLineItems")
        });
        
        action.setCallback( this, function( response ) {
            
            let state = response.getState();
            if (state === "SUCCESS") {
                helper.navigateToRecord( response.getReturnValue() );
            }
            else if (state === "INCOMPLETE") {
                alert(' ERROR : Unable to create the opportunity.');    
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        } );
        
        $A.enqueueAction(action);
    }
})