({
    
    cloneOppAndGetLineItems: function (component, fields){
        
    	let action = component.get("c.cloneOpportunityAndReturnProducts");
        action.setParams({
            opp: fields,
            sourceOppRecordId : component.get("v.recordId")
        });
        
        this.showSpinner(component);
        
        action.setCallback( this, function( response ) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.saved", true);
                console.log(response.getReturnValue());
                let resObj = JSON.parse(response.getReturnValue());
                
                //Set the cloned opportunity record id
                component.set("v.clonedOppRecordId", resObj.clonedOppId);
                
                // Set the data-table columns with additional action column 
                // which will allow users to delete a line item 
                var actions = [
                    { label: 'Delete', name: 'delete' }
                ];
                let actionCol = { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'left' } };
                resObj.columns.push(actionCol);
                
                //Find the Product2.Name column and change the fieldName so that we can reference the parent name
                let product2Col = resObj.columns.find(c=>c.fieldName == "Product2.Name");
                if(product2Col.fieldName != undefined){
                    product2Col.fieldName = "Product2Name";    
                }
				component.set('v.columns', resObj.columns);
                
                //Set the products data to display in the data-table
                //In order to display product names, we will have to flatten the column names 
                for (var i = 0; i < resObj.data.length; i++) {
                    var row = resObj.data[i];
                    if (row.Product2) row.Product2Name = row.Product2.Name;
                }
                
                component.set('v.products', resObj.data);
                
            }
            else if (state === "INCOMPLETE") {
                console.error('ERROR');
                this.handleErrors(component, [{message: 'Unable to clone the opportunity due to network error'}]);
            }
            else if (state === "ERROR") {
                console.error(response.getError());
                this.handleErrors(component, response.getError(), 'info');
            }
            this.hideSpinner(component);
        } );

        $A.enqueueAction(action);    
    },
    
    navigateToRecord: function ( recordId ) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();	
    },
    
    
    cloneOppLineItems: function (component, event){
    	let action = component.get("c.cloneOpportunityLineItems");
        //console.log(component.get("v.recordId"));
        //console.log(component.get("v.clonedOppRecordId"));
        //console.log(component.get("v.products"));
        //console.log(component.get("v.savedDraftValues"));
        
        if(typeof event.getParam === "function"){
            component.set('v.savedDraftValues', event.getParam('draftValues'));
        }
        else {
        	component.set('v.savedDraftValues', []);    
        }
        
        let isValidData = this.validate(component, event);
        console.log(isValidData);
        
        if(isValidData){
            let lstSourceLineItemIds = [];
            for(let oli of component.get("v.products")){
                lstSourceLineItemIds.push(oli.Id);	    
            }
            action.setParams({
                sourceOppRecordId: component.get("v.recordId"),
                clonedOppRecordId: component.get("v.clonedOppRecordId"),
                lstSourceLineItemIds: lstSourceLineItemIds,
                lstLineItemsChanges: component.get("v.savedDraftValues")
            });
    		
            this.showSpinner(component);
            
            action.setCallback( this, function( response ) {
                
                let state = response.getState();
                if (state === "SUCCESS") {
                    this.navigateToRecord(response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    this.handleErrors(component, [{message: 'Unable to clone the opportunity line items due to network problem'}]);
                }
                else if (state === "ERROR") {
                    this.handleErrors(component, response.getError());
                }
                this.hideSpinner(component);
            } );
    
            $A.enqueueAction(action);    
        }
    },
    
    deleteRow: function (component, row){
    	var rows = component.get('v.products');
        var rowIndex = rows.indexOf(row);
        rows.splice(rowIndex, 1);
        component.set('v.products', rows);    
    },
    
    sortData: function (component, fieldName, sortDirection) {
        var products = component.get("v.products");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        products.sort(this.sortBy(fieldName, reverse))
        component.set("v.products", products);
    },
    
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    
    handleErrors: function (component, errors, type, closeCallback){
        
        let msgText = 'Unknown error';
		let variant = 'error';
        
        if(type){
            variant = type;
        }

        if (errors && Array.isArray(errors) && errors.length > 0) {
            msgText = errors[0].message;
        }
        
        console.error(msgText);
        
        component.find('notifLib').showNotice({
            "variant": variant,
            "header": variant == "error" ? "Something has gone wrong!" : "Information",
            "message": msgText,
            closeCallback: closeCallback ? closeCallback : null 
        });
    },
    
    validate: function(component, event) {
		
        console.log('validate called');
        let rows = {};
        let isValid = true;
        let items = component.get("v.savedDraftValues");
        if(items == undefined){
            items = event.getParam('draftValues');
        }
        for(let oli of items){
            let messages = [];
            let fieldNames = [];
            for(let col of component.get("v.columns")){
                if(col.required && oli[col.fieldName] == ''){
                	messages.push('Enter a valid ' + col.label);	
                    fieldNames.push(col.fieldName);
                }    
            }
            if(fieldNames.length > 0){
                isValid = false;
            	let title = "We found " + fieldNames.length + " errors.";  
                rows[oli.Id] = {
                    title: title,
                    messages: messages,
                    fieldNames: fieldNames
                };
            } 
        }
        
        if(!isValid){
            component.set('v.errors', {
                rows: rows,
                table: {
                    title: 'Your entry cannot be saved. Fix the errors and try again.'
                }
             });
        }
        
        return isValid;
    },
    
    showSpinner : function( component ) {

        $A.util.removeClass( component.find( 'spinner' ), 'slds-hide' );

    },

    hideSpinner : function( component ) {

        $A.util.addClass( component.find( 'spinner' ), 'slds-hide' );

    },

})