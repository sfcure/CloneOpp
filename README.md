# CloneOpp - A lightning component to clone an opportunity with it's associated products
## Overview
A Lightning Component to clone an opportunity record with it's related opportunity line items. I came across many questions regarding this feature on Success Community and Salesforce product team still need some time to delivering this well needed feature. So, It made me think to create one and distribute this in the community.

![Idea on IdeaExchange](https://sfcure.files.wordpress.com/2018/06/clone-with-products.png)

## Packaged Release History
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
1. ## Adding Clone with Products button to page layout
   - You will have to go to the page layout where you want to add the lightning action. Navigate to Setup and click on Object Manager tab. Search for the Opportunity and click on the Opportunity link. 
   - Click on Page Layouts link in the left side panel. Edit the desired page layout and look for the lightning action "Clone with Product" and drag that action and drop in the pane.
![Snapshot](https://sfcure.files.wordpress.com/2018/06/screenshot_101.png)
   

2. ## Adding Fields to be copied over on Opportunity ( During cloning )
   - First switch to Salesforce Classic view if you are in Lightning Experience ( This is because you can't access the fieldsets in LEX )
   - Navigate to Setup | Customize | Opportunity | Field Sets
   - Look for Clone Opportunity Field Set and click on Edit link
   - Here you can add/remove fields which you want to copy in cloned opportunity
3. ## Adding Fields to be copied over on Opportunity Product ( During cloning )
   - First switch to Salesforce Classic view if you are in Lightning Experience ( This is because you can't access the fieldsets in LEX )
   - Navigate to Setup | Customize | Opportunity Products | Field Sets
   - Look for Clone Opportunity Field Set and click on Edit link
   - Here you can add/remove fields which you want to copy in cloned opportunity

![Snapshot](https://sfcure.files.wordpress.com/2018/06/screenshot_9.png)


## Component will look like as shown in the following screenshot.
![Snapshot](https://sfcure.files.wordpress.com/2018/06/clone-with-products.gif)
