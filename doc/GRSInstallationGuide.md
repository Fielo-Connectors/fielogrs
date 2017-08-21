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
