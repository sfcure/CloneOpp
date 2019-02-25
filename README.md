# CloneOpp - A lightning component to clone an opportunity with it's associated products
## Overview
A Lightning Component to clone an opportunity record with it's related opportunity line items. I came across many questions regarding this feature on Success Community and Salesforce product team still need some time to delivering this well needed feature. So, It made me think to create one and distribute this in the community.

![Idea on IdeaExchange](https://sfcure.files.wordpress.com/2018/06/clone-with-products.png)

## Packaged Release History
## Release 1.6 ( Unmanaged package ) - Current
- Sandbox [Package Link](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t7F000005QwK9)
- Production/Developer [Package Link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t7F000005QwK9)
   - Now, you can update cloned opportunity record
   - Add/Remove columns in the add product layout (2nd Screen)

## Release 1.5 ( Managed package ) - Current
- Sandbox [Package Link](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tf4000004PpFF)
- Production/Developer [Package Link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tf4000004PpFF)
   - Now, you can update cloned opportunity
   - Add/Remove columns in the add product layout

## Release 1.2 ( Unmanaged package )
- Sandbox [Package Link](https://test.salesforce.com/packaging/installPackage.apexp?p0=04t7F000003iaKl)
- Developer [Package Link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t7F000003iaKl)

## Release 1.3 ( Managed package ) 
- Sandbox [Package Link](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tf4000003f1Mi)
- Production/Developer [Package Link](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tf4000003f1Mi)

## Pre-Requsites for installing this package
My Domain should be enabled in your orginzation.

## GitHub Repository for Source Code (Developers)
You can can check the [GitHub Repository](https://github.com/sfcure/CloneOpp) for the source code and can make any adjustments as per your need.

## Getting Started
1. ## Install the package by clicking the link in your dev/sandbox/production org.
2. ## Adding Clone with Products button to page layout
   - You will have to go to the page layout where you want to add the lightning action. Navigate to Setup and click on Object Manager tab. Search for the Opportunity and click on the Opportunity link. 
   - Click on Page Layouts link in the left side panel. Edit the desired page layout and look for the lightning action "Clone with Product" and drag that action and drop in the pane.
![Snapshot](https://sfcure.files.wordpress.com/2018/06/screenshot_101.png)
   
3. ## Configuring it for new columns and change behaviour of exisitng cloning functionality
   - Go to Setup 
   - Search for Custom Metadata Type in Quick Find box
   - Click on Manage Records link next to Clone Opportunity Setting
   - Click on New button to add new column on Cloned Product Layout. Label should be exactly same as the Field API Name which you wants to add You will see several checkboxes and their use is explained below -
   Editable - Make the fields editable in the column
   Cloneable - If you don't want to show the field on the layout but still want that to be cloned 
   Sortable - Make the column sortable
   Required - Make the field required on the product layout 


## Component will look like as shown in the following screenshot.
![Snapshot](https://sfcure.com/wp-content/uploads/2019/02/Opportunity-1.png)
![Snapshot](https://sfcure.com/wp-content/uploads/2019/02/Products-1.png)
