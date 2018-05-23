
{
  "exportType" : "update",
  "configObjects" : [ {
    "apiName" : "fieloplt__library__c",
    "fieldsToExclude" : "fieloplt__resourceid__c"
  }, {
    "apiName" : "fieloplt__ruletrigger__c",
    "fieldsToExclude" : "fieloplt__prefix__c"
  }, {
    "apiName" : "fieloplt__action__c",
    "fieldsToExclude" : "fieloplt__rulesquantity__c,fieloplt__missionsquantity__c,fieloplt__criteriafields__c,fieloplt__templatesquantity__c"
  } ],
  "migrationRecords" : [ {
    "objectAPIName" : "fieloplt__library__c",
    "records" : [ {
      "fieldsValues" : [ {
        "apiName" : "name",
        "value" : "FieloGRS"
      }, {
        "apiName" : "fieloplt__version__c",
        "value" : "1.001"
      }, {
        "apiName" : "fieloplt__externalid__c",
        "value" : "FieloGRS"
      } ],
      "relatedList" : [ {
        "objectAPIName" : "fieloplt__ruletrigger__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__model__c",
        "records" : [ ]
      }, {
        "objectAPIName" : "fieloplt__pagesettings__c",
        "records" : [ {
          "fieldsValues" : [ {
            "apiName" : "name",
            "value" : "Program > Detail"
          }, {
            "apiName" : "fieloplt__library__c.fieloplt__externalid__c",
            "value" : "FieloGRS",
            "refObject" : "fieloplt__library__c"
          }, {
            "apiName" : "fieloplt__object__c",
            "value" : "FieloPLT__Program__c"
          }, {
            "apiName" : "fieloplt__order__c",
            "value" : "5"
          }, {
            "apiName" : "fieloplt__sections__c",
            "value" : "{\"Rows\":[[],[{\"WhereCondition\":null,\"Value\":null,\"Type\":\"lookup\",\"SearchField\":null,\"Required\":null,\"ReadOnly\":null,\"onchange\":null,\"Name\":\"FieloGRS__GRSPointType__c\",\"MetaField\":null,\"Label\":null,\"id\":null},{\"WhereCondition\":null,\"Value\":null,\"Type\":\"lookup\",\"SearchField\":null,\"Required\":null,\"ReadOnly\":null,\"onchange\":null,\"Name\":\"FieloGRS__GRSAccount__c\",\"MetaField\":null,\"Label\":null,\"id\":null}],[{\"WhereCondition\":null,\"Value\":null,\"Type\":\"input\",\"SearchField\":null,\"Required\":null,\"ReadOnly\":null,\"onchange\":null,\"Name\":\"FieloGRS__GRSMemberFieldset__c\",\"MetaField\":null,\"Label\":null,\"id\":null}],[{\"WhereCondition\":null,\"Value\":null,\"Type\":\"input\",\"SearchField\":null,\"Required\":null,\"ReadOnly\":null,\"onchange\":null,\"Name\":\"FieloGRS__GRSMetadataFieldSet__c\",\"MetaField\":null,\"Label\":null,\"id\":null}]],\"Name\":\"GRS Settings\",\"id\":null,\"CssClass\":null}"
          }, {
            "apiName" : "fieloplt__type__c",
            "value" : "Detail"
          }, {
            "apiName" : "fieloplt__externalid__c",
            "value" : "00Df4000000kVA8-a0Lf4000002GPdm"
          }, {
            "apiName" : "fieloplt__iscustom__c",
            "value" : "true"
          } ],
          "relatedList" : [ {
            "objectAPIName" : "fieloplt__programassignment__c",
            "records" : [ ]
          } ]
        }, {
          "fieldsValues" : [ {
            "apiName" : "name",
            "value" : "Program > Edit"
          }, {
            "apiName" : "fieloplt__library__c.fieloplt__externalid__c",
            "value" : "FieloGRS",
            "refObject" : "fieloplt__library__c"
          }, {
            "apiName" : "fieloplt__object__c",
            "value" : "FieloPLT__Program__c"
          }, {
            "apiName" : "fieloplt__order__c",
            "value" : "5"
          }, {
            "apiName" : "fieloplt__sections__c",
            "value" : "{\"Rows\":[[],[{\"WhereCondition\":null,\"Value\":null,\"Type\":\"lookup\",\"SearchField\":null,\"Required\":null,\"ReadOnly\":null,\"onchange\":null,\"Name\":\"FieloGRS__GRSPointType__c\",\"MetaField\":null,\"Label\":null,\"id\":null},{\"WhereCondition\":null,\"Value\":null,\"Type\":\"lookup\",\"SearchField\":null,\"Required\":null,\"ReadOnly\":null,\"onchange\":null,\"Name\":\"FieloGRS__GRSAccount__c\",\"MetaField\":null,\"Label\":null,\"id\":null}],[{\"WhereCondition\":null,\"Value\":null,\"Type\":\"input\",\"SearchField\":null,\"Required\":null,\"ReadOnly\":null,\"onchange\":null,\"Name\":\"FieloGRS__GRSMemberFieldset__c\",\"MetaField\":null,\"Label\":null,\"id\":null}],[{\"WhereCondition\":null,\"Value\":null,\"Type\":\"input\",\"SearchField\":null,\"Required\":null,\"ReadOnly\":null,\"onchange\":null,\"Name\":\"FieloGRS__GRSMetadataFieldSet__c\",\"MetaField\":null,\"Label\":null,\"id\":null}]],\"Name\":\"GRS Settings\",\"id\":null,\"CssClass\":null}"
          }, {
            "apiName" : "fieloplt__type__c",
            "value" : "Edit"
          }, {
            "apiName" : "fieloplt__externalid__c",
            "value" : "00Df4000000kVA8-a0Lf4000002GPbg"
          }, {
            "apiName" : "fieloplt__iscustom__c",
            "value" : "true"
          } ],
          "relatedList" : [ {
            "objectAPIName" : "fieloplt__programassignment__c",
            "records" : [ ]
          } ]
        } ]
      } ]
    } ]
  } ],
  "segmentsCombinations" : [ ]
}