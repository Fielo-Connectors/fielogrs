# GRS Installation Guide

## 1. Introduction

This document  is designed to assist Global Rewards Solutions installing and configuring GRS Partner APIs.
The integration with Fielo partner will be implemented by using 3 (three) Partner APIs:  
   - getMember (GET)
   - createOrder (POST)
   - cancelOrder (POST)

## 2. General Configuration
- **Install FieloGRS package**  

After logging into your Salesforce Org, use the URL below to install Fielo GRS package:  
https:/{!instance}.salesforce.com/packaging/installPackage.apexp?p0=04tf40000018F6T

## 3. Program Configuration (required for Member GET)
**In *Program* object, make the following configuration:**

- GRS Point Type (FieloGRS__GRSPointType__c) - Select the point type to be adopted in order to correctly display the Current Point Balance.  
![image](https://user-images.githubusercontent.com/26011197/29518455-c28180b8-864f-11e7-8bc8-b25cc42eab5e.png)

- GRS Member Fieldset (FieloGRS__GRSMemberFieldset__c) - This field is filled with a JSON format containing all the API optional fields.   
![image](https://user-images.githubusercontent.com/26011197/29518856-7831c1a6-8651-11e7-8f0a-d2209c09da55.png)  

A sample of the JSON format is as follows:
```
[
	{
		"grsFieldName":"email",
		"sfFieldName":"FieloPLT__Email__c"
	},
	{
		"grsFieldName":"firstName",
		"sfFieldName":"FieloPLT__Contact__r.FirstName"
	},
	{
		"grsFieldName":"lastName",
		"sfFieldName":"FieloPLT__Contact__r.LastName"
	}
]
```
## 4. Objects Configuration  
**If necessary, create custom fields on Provider Order and Redemption Item objects in order to be able to map optional fields for Order and OrderItem.**  
![image](https://user-images.githubusercontent.com/26011197/29518924-bac6f95a-8651-11e7-9ffe-1eee35b925aa.png)  

## 5. Program Configuration (required for Order Details POST)  
**In Program object, make the following configuration:**  

- GRS Point Type (FieloGRS__GRSPointType__c) - The point type to be consumed by the checkout. Already configured on item 3.  

- GRS Account (FieloGRS__GRSAccount__c) - The reward provider. In this case, GRS.  
![image](https://user-images.githubusercontent.com/26011197/29519003-0d214ab6-8652-11e7-880f-5f1e71b25c96.png)  

- GRS Order Fieldset (FieloGRS__GRSOrderFieldset__c) - This field is filled with a JSON format containing all the optional fields when creating the order request. The optional fields are the ones created on step 4.  
![image](https://user-images.githubusercontent.com/26011197/29529321-9811240c-8675-11e7-927d-0c30c41a812e.png)  
:point_right: The fields below are already included in the package and don't need to be used in the Json:  
➤ Order Type - type  
➤ Member Employee ID - employeeID  
➤ Order Number – orderNumber  

- GRS Order Item Fieldset (FieloGRS__GRSOrderItemFieldset__c) - This field is filled with a JSON format containing all the optional fields when creating the order request. The optional fields are the ones created on step 4.  
![image](https://user-images.githubusercontent.com/26011197/29529610-be8b6e0c-8676-11e7-9f3a-c072bffe3d4a.png)  
:point_right: The fields below are already included in the package and don't need to be used in the Json:  
➤ Order ID - orderId  
➤ Point Cost – pointCost  
➤ Quantity – quantity  

## 6. Members Profile Configuration  
   1. **In the profile for the member user in the front end, give access to the following apex classes:**  
      - FieloGRS.RESTMember  
      - FieloGRS.RESTOrder  
  
![image](https://user-images.githubusercontent.com/26011197/29519070-581c91c4-8652-11e7-935d-5337432761bb.png)  
![image](https://user-images.githubusercontent.com/26011197/29519103-7f870aaa-8652-11e7-95b2-20378a97a0ef.png)  

   2. **Give access in the connected app for the admin user to the following class:**  
      - FieloGRS.RESTOrderUpdate  
      
## 7. Setup Services in GRS  
   - getMember  
     https://{!instance}.salesforce.com/services/apexrest/FieloGRS/V1/members/{!memberId}  

   - createOrder  
     https://{!instance}.salesforce.com/services/apexrest/FieloGRS/V1/orders/  

   - cancelOrder  
     https://{!instance}.salesforce.com/services/apexrest/FieloGRS/V1/orders/update/  
