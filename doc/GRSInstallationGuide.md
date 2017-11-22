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
​[
  {"grsFieldName":"employeeId","sfFieldName":"Id"},
  {"grsFieldName":"firstName","sfFieldName":"FieloPLT__Contact__r.FirstName"},
  {"grsFieldName":"lastName","sfFieldName":"FieloPLT__Contact__r.LastName"},
  {"grsFieldName":"email","sfFieldName":"FieloPLT__Email__c"},
  {"grsFieldName":"address1","sfFieldName":"FieloPLT__Contact__r.MailingStreet"},
  {"grsFieldName":"city","sfFieldName":"FieloPLT__Contact__r.MailingCity"},
  {"grsFieldName":"postalCode","sfFieldName":"FieloPLT__Contact__r.MailingPostalCode"},
  {"grsFieldName":"provinceState","sfFieldName":"FieloPLT__Contact__r.MailingStateCode"},
  {"grsFieldName":"country","sfFieldName":"FieloPLT__Contact__r.MailingCountryCode"},
  {"grsFieldName":"telephone","sfFieldName":"FieloPLT__Contact__r.Phone"},
  {"grsFieldName":"language","sfFieldName":"FieloPLT__User__r.LanguageLocaleKey", "isLocale":true}
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

   3. **Enable API for member profile:**
      - Go to **Fielo Member Profile > Administrative Permissions** and set **API Enabled** to true.

## 7. Custom Settings
   1. **Define data format for *GRS Allowed Fields* custom settings**   
   - Go to the Setup > Develop > Custom Settings
   - Hit *Manage* button beside the *GRS Allowed Fields* custom settings
   - Click the *New* button **above the *Default Organization Level Value* area**
   - Set the location for each field an Save it
   - Press the *Edit* button in order to set the allowed data for each custom field:
   ![image](https://user-images.githubusercontent.com/26011197/30080352-b41509b2-9259-11e7-9d9d-050ca3518221.png)
   - _Sample values_
      - **​GRS Member Allowed Fields:** firstName,lastName,email,address1,address2,country,city,provinceState,telephone,language,employeeId,postalCode,balance
      - **​GRS Order Allowed Fields 1:** ​businessAddress,totalPointCost,totalPointCostLessPointsPurchased,pin,pointsPurchased,pointsPurchasedCost,pointsPurchasedCurrency,shipAddress1
      - **​GRS Order Allowed Fields 2:** ​shipAddress2,shipCity,shipCompany,shipCountry,shipEmail,shipName,shipPostal,shipProvinceState,shipTelephone,discountCoupon
      - **​GRS Order Item Allowed Fields:** ​catalogCode,catalogName,description,lineItemId,name,orderedAt

   - Click *Save*.  

   2. **Set storefront credentials for *​GRS Settings* custom settings**
   - Go to the Setup > Develop > Custom Settings
   - Hit *Manage* button beside the *GRS Settings* custom settings
   - Click the *New* button **above the *Default Organization Level Value* area**
   - This values must be provided by GRS

## 8. Setup Services in GRS  
   - getMember  
     https://{!instance}.salesforce.com/services/apexrest/FieloGRS/V1/members/{!memberId}  

   - createOrder  
     https://{!instance}.salesforce.com/services/apexrest/FieloGRS/V1/orders/  

   - cancelOrder  
     https://{!instance}.salesforce.com/services/apexrest/FieloGRS/V1/orders/update/  
