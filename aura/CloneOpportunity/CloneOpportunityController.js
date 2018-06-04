({
    doInit: function( cmp, event, helper ) {
    	
        // Get the list of the products from the source opportunity
        let action = cmp.get("c.getOpportunityLineItems");
        action.setParams({
            opportunityId: cmp.get("v.recordId")	
        });
        
        action.setCallback( this, function( response ) { 
        	let state = response.getState();
            console.log(state);
			if (state === "SUCCESS") {
                console.log( response.getReturnValue() );
				cmp.set( "v.lstLineItems", response.getReturnValue() );
            }
            else if (state === "INCOMPLETE") {
            	
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
    },
    
    // Function which creates a new opportunity 
    // from the details of source/original opportunity
    // Also clone the selected products 
	doSaveAction : function(cmp, event, helper) {
		
        // Getting the cloned product fields to validate
        let quantityFields = cmp.find("inputQuantity");
        let unitPriceFields = cmp.find("inputUnitPrice");
        
        var requiredFields = [];
        if( quantityFields.length != undefined )
        	requiredFields = requiredFields.concat( quantityFields );  
        
        if( unitPriceFields.length != undefined )
        	requiredFields = requiredFields.concat( unitPriceFields );  
        // Initialize the counter to zero - used to check validity of fields
        var blank=0;
        // If there are more than 1 fields
        if( requiredFields.length != undefined ) {
            console.log( quantityFields );
            // Iterating all the fields
            var allValid = requiredFields.reduce(function ( validSoFar, inputCmp ) {
                console.log( validSoFar, inputCmp );
                // return whether all fields are valid or not
                return validSoFar && helper.checkForRequired( inputCmp, "Complete this field" );
            }, true );
            // If all fields are not valid increment the counter
            if ( !allValid ) {
                blank++;
            }
        } else {
            // If there is only one field, get that field and check for validity (true/false)
            var allValid = requiredFields;
            // If field is not valid, increment the counter
            if ( !helper.checkForRequired( allValid ) ) {
                blank++;
            }
        }
        // Call the helper method only when counter is 0
        if(blank == 0) {
            
            helper.cloneOpportunityWithProducts( cmp, helper );
        }	
        
	},
    
    doCancelAction : function(cmp, event, helper) {
    	$A.get("e.force:closeQuickAction").fire();    
        cmp.destroy();
    }
})