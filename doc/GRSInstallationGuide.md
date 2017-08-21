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
