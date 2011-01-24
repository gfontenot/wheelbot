<cfinclude template="ACCS_Sample_Util.cfm">

<cfset configService = createObject("webservice", "chromeConfigCompareService")>
<cfset dataType = url.data>
<cfset returnString = "">

<cfif dataType EQ "locale">

	<!---  get accountInfo --->
	<cfset accountInfo = StructNew()>
	<cfset accountInfo.accountNumber = "0">
	<cfset accountInfo.accountSecret = "accountSecret">

	<cfset accountInfo.locale = StructNew()>
	<cfset accountInfo.locale.language = "en">
	<cfset accountInfo.locale.country = "US">
	<cfset accountInfo.sessionId = "">

	<cfset locale = url.locale>

	<cfif locale EQ "enCA">
	   <cfset accountInfo.locale.country = "CA">
	<cfelseif locale EQ "frCA">
	    <cfset accountInfo.locale.language = "fr">
	    <cfset accountInfo.locale.country = "CA">
	</cfif>

	<!---  save accountInfo --->
	<cflock timeout="20" scope="Session" type="Exclusive">
		<cfset Session.accountInfo = accountInfo>
	</cflock>

<cfelseif dataType EQ "orderAvailability">

	<!---  get orderAvailability --->
	<cfset orderAvailability = url.orderAvailability>

	<!---  save orderAvailability --->
	<cflock timeout="20" scope="Session" type="Exclusive">
		<cfset Session.orderAvailability = orderAvailability>
	</cflock>

<cfelseif dataType EQ "getSearchCriteria">

	<cfset criteriaRequest = StructNew()>
	<cfset criteriaRequest.accountInfo = Session.accountInfo>

    <cfset descriptors = configService.getSearchCriterionDescriptors(criteriaRequest)>

    <cfloop index="i" from="1" to="#ArrayLen(descriptors)#">
        <cfif i GT 0>
            <cfset returnString = returnString & ";;">
        </cfif>
        <cfset descriptor = descriptors[i]>
        <cfset returnString = returnString & descriptor.name & "~~">
        <cfset returnString = returnString & descriptor.type & "~~">
	<cfif IsDefined("descriptor.min")>

	</cfif>
        <cfset returnString = returnString & "~~">
	<cfif IsDefined("descriptor.max")>

	</cfif>
        <cfset returnString = returnString & "~~">
	<cfif IsDefined("descriptor.unit")>

	</cfif>
    </cfloop>

<cfelseif dataType EQ "getSearchResults">

    <cfset searchType = url.searchType>
    <cfset postalCode = url.postalCode>

    <cfset filterTBD = FALSE>
    <cfif IsDefined("url.filterTBD")>
        <cfset filterTBD = url.filterTBD>
    </cfif>

    <cfset filterPostalCode = FALSE>
    <cfif IsDefined("url.filterPostalCode")>
        <cfset filterPostalCode = url.filterPostalCode>
    </cfif>

    <cfset maxNumResults = 0>
    <cfif IsDefined("url.maxNumResults")>
        <cfset maxNumResults = url.maxNumResults>
    </cfif>

    <cfset generalCriteria = ArrayNew(1)>
    <cfset andCriteria = ArrayNew(1)>
    <cfset orCriteria = ArrayNew(1)>

    <!---
        extract all the search params from the request
        each param will be similar in form to:
        compositeName=division&compositeType=general&compositeMustHave=true&name=division&type=String&mustHave=true&value=ford&min=&max=
    --->

    <cfset searchParamIndex = 0>
    <cfset searchParamKey = "searchParam" & searchParamIndex>

    <cfloop condition = "#IsDefined("url." & searchParamKey)#">
        <cfset paramString = url[searchParamKey]>
        <cfset searchParamIndex = searchParamIndex + 1>
        <cfset searchParamKey = "searchParam" & searchParamIndex>
        <cfset compositeCriterion = parseCompositeSearchCriterion( paramString )>
        <cfif NOT StructIsEmpty(compositeCriterion)>
            <cfif compositeCriterion.type EQ "general">
                <cfset ArrayAppend(generalCriteria, compositeCriterion.subCriteria[1])>
            <cfelseif compositeCriterion.type EQ "and">
                <cfset subCriteria = compositeCriterion.subCriteria>
                <cfset andCriterion = StructNew()>
                <cfset andCriterion.name = compositeCriterion.name>
                <cfset andCriterion.criteriaArray = subCriteria>
                <cfset ArrayAppend(andCriteria, andCriterion)>
            <cfelseif compositeCriterion.type EQ "or">
                <cfset subCriteria = compositeCriterion.subCriteria>
                <cfset orCriterion = StructNew()>
                <cfset orCriterion.importance = compositeCriterion.mustHave>
                <cfset orCriterion.criteriaArray = subCriteria>
                <cfset ArrayAppend(orCriteria, orCriterion)>
            </cfif>
        </cfif>
    </cfloop>

    <cfset searchCriteria = StructNew()>
    <cfset searchCriteria.criteriaArray = generalCriteria>
    <cfset searchCriteria.orCriteriaArray = orCriteria>
    <cfset searchCriteria.andCriteriaArray = andCriteria>
    <cfset searchCriteria.filterTBD = filterTBD>
    <cfset searchCriteria.filterByPostalCode = filterPostalCode>
    <cfset searchCriteria.postalCode = postalCode>
    <cfset searchCriteria.maxNumResults = maxNumResults>

    <cfset searchRequest = StructNew()>
    <cfset searchRequest.accountInfo = Session.accountInfo>
    <cfset searchRequest.orderAvailability = Session.orderAvailability>
    <cfset searchRequest.searchRequest = searchCriteria>

    <cfif searchType EQ "searchStyles">

        <cfset styles = configService.searchStyles(searchRequest)>
        <cfloop index="i" from="1" to="#ArrayLen(styles)#">
            <cfset style = styles[i]>
            <cfset invoice = "$" & style.baseInvoice>
            <cfset msrp = "$" & style.baseMsrp>
            <cfif i GT 1>
                <cfset returnString = returnString & ";;">
            </cfif>
            <cfset returnString = returnString & style.modelYear & "~~" & style.divisionName & "~~" & style.modelName & "~~" & style.styleName & "~~" & invoice & "~~" & msrp & "~~" & style.styleId>
        </cfloop>

    <cfelseif searchType EQ "searchModels">

        <cfset searchResults = configService.searchModels(searchRequest)>
        <cfloop index="i" from="1" to="#ArrayLen(searchResults)#">
            <cfif i GT 1>
                <cfset returnString = returnString & ";;">
            </cfif>
            <cfset dateString = "">
            <cfset model = searchResults[i].model>
            <cfif IsDefined("model.lastModifiedDate")>
                <cfset dateString = model.lastModifiedDate.time>
            </cfif>
            <cfset returnString = returnString & model.modelId & "~~" & model.modelName & "~~" & dateString>
        </cfloop>

    </cfif>

<cfelseif dataType EQ "findComparable">

    <!---
        This search is designed to find similar vehicles to the target vehicle based on the vehicle's
        model year, market class, body style, etc.
    --->

    <cfset accountInfo = Session.accountInfo>

    <cfset filterTBD = FALSE>
    <cfif IsDefined("url.filterTBD")>
        <cfset filterTBD = url.filterTBD>
    </cfif>

    <cfset filterPostalCode = FALSE>
    <cfif IsDefined("url.filterPostalCode")>
        <cfset filterPostalCode = url.filterPostalCode>
    </cfif>

    <cfset maxNumResults = 0>
    <cfif IsDefined("url.maxNumResults")>
        <cfset maxNumResults = url.maxNumResults>
    </cfif>

    <cfset scratchListId = url.scratchListId>
    <cfset configState = Session.scratchList[scratchListId]>
    <cfset orderAvailability = configState.orderAvailability>

    <!---
        Retrieve target vehicle info so we know what to base comparable search on
    --->
	<cfset styleRequest = StructNew()>
	<cfset styleRequest.accountInfo = accountInfo>
	<cfset styleRequest.configurationState = configState>
	<cfset styleRequest.returnParameters = getStyleReturnParameters()>
	<cfset toggleResponse = configService.getStyleFullyConfigured( styleRequest )>
    <cfset configStyle = toggleResponse.configuration>

    <!---
        now build up the search criteria
    --->
    <cfset generalCriteria = ArrayNew(1)>
    <cfset andCriteria = ArrayNew(1)>
    <cfset orCriteria = ArrayNew(1)>

    <!---
        only search for model year of target vehicle or newer
    --->
    <cfset yearCriterion = StructNew()>
    <cfset yearCriterion.name = "year">
    <cfset yearCriterion.importance = "MustHave">
    <cfset yearCriterion.type = "NumberRange">
    <cfset yearCriterion.min = configStyle.style.modelYear>
    <cfset ArrayAppend(generalCriteria, yearCriterion)>

    <!---
        only search for selected makes
    --->
    <cfset chosenMakes = ListToArray(url.makes, ";;")>
    <cfif ArrayLen(chosenMakes) GT 0>
        <cfset makeCriteriaList = ArrayNew(1)>
        <cfloop index="i" from="1" to="#ArrayLen(chosenMakes)#">
            <cfset makeCriterion = StructNew()>
            <cfset makeCriterion.name = "divisionId">
            <cfset makeCriterion.importance = "MustHave">
            <cfset makeCriterion.type = "String">
            <cfset makeCriterion.value = chosenMakes[i]>
            <cfset ArrayAppend(makeCriteriaList, makeCriterion)>
        </cfloop>
        <!---
            make an OrCriterion that includes all of the passed in makes (e.g. This vehicle make must = Ford or Chevy or Honda, etc.)
        --->
        <cfset makeListCriterion = StructNew()>
        <cfset makeListCriterion.importance = "MustHave">
        <cfset makeListCriterion.criteriaArray = makeCriteriaList>
        <cfset ArrayAppend(orCriteria, makeListCriterion)>
    </cfif>

    <!---
        only search for vehicles with the same market class as this target vehicle
    --->
    <cfset marketClassCriterion = StructNew()>
    <cfset marketClassCriterion.name = "marketClassId">
    <cfset marketClassCriterion.importance = "MustHave">
    <cfset marketClassCriterion.type = "String">
    <cfset marketClassCriterion.value = configStyle.style.marketClassId>
    <cfset ArrayAppend(generalCriteria, marketClassCriterion)>

    <!---
        only search for selected vehicles with same body type as target vehicle
    --->
    <cfset bodyTypeList = ArrayNew(1)>
    <cfloop index="i" from="1" to="#ArrayLen(configStyle.style.bodyTypes)#">
        <cfset bodyType = configStyle.style.bodyTypes[i]>
        <cfset bodyTypeCriterion = StructNew()>
        <cfset bodyTypeCriterion.name = "bodyType">
        <cfset bodyTypeCriterion.importance = "MustHave">
        <cfset bodyTypeCriterion.type = "String">
        <cfset bodyTypeCriterion.value = bodyType.bodyTypeId>
        <cfset ArrayAppend(bodyTypeList, bodyTypeCriterion)>
    </cfloop>
    <!---
        make an OrCriterion that includes all of the body types (e.g. This vehicle body type must = Short Bed or Crew Cab Pickup, etc.)
    --->
    <cfset bodyTypeCriterion = StructNew()>
    <cfset bodyTypeCriterion.importance = "MustHave">
    <cfset bodyTypeCriterion.criteriaArray = bodyTypeList>
    <cfset ArrayAppend(orCriteria, bodyTypeCriterion)>

    <!---
        only search for vehicles with the same number of passenger doors on target vehicle
    --->
    <cfset passengerDoorsCriterion = StructNew()>
    <cfset passengerDoorsCriterion.name = "numberOfDoors">
    <cfset passengerDoorsCriterion.importance = "MustHave">
    <cfset passengerDoorsCriterion.type = "String">
    <cfset passengerDoorsCriterion.value = configStyle.style.passengerDoors>
    <cfset ArrayAppend(generalCriteria, passengerDoorsCriterion)>

	<cfset passengerCapacityTechSpecId = 8>
    <cfset wheelbaseTechSpecId = 301>
    <cfset variancePercentage = 0.05>

    <!---
        match on certain tech specs (passenger capacity, wheelbase - if truck or suv)
    --->
    <cfset techSpecs = configStyle.technicalSpecifications>
    <cfloop index="i" from="1" to="#ArrayLen(techSpecs)#">

        <!---
            passenger capacity
        --->
        <cfif techSpecs[i].titleId EQ passengerCapacityTechSpecId>
            <cfset passengerCapacity = techSpecs[i].value>
            <cfset passengerCapacityCriterion = StructNew()>
            <cfset passengerCapacityCriterion.name = "passengerCapacity">
            <cfset passengerCapacityCriterion.importance = "MustHave">
            <cfset passengerCapacityCriterion.type = "TechnicalSpecificationRange">
            <cfset passengerCapacityCriterion.min = passengerCapacity>
            <cfset passengerCapacityCriterion.max = passengerCapacity>
            <cfset ArrayAppend(generalCriteria, passengerCapacityCriterion)>
        </cfif>

        <!---
            if this vehicle has a meaningful wheelbase, then add this to the search criteria
        --->
        <cfif doesWheelbaseMatter(configStyle.style.marketClassName) AND techSpecs[i].titleId EQ wheelbaseTechSpecId>
            <cfset wheelbase = techSpecs[i].value>
            <!---
                create a range that the wheelbase of search vehicles can fall within
            --->
            <cfif wheelbase GT 0>
                <cfset min = wheelbase * (1 - variancePercentage)>
                <cfset max = wheelbase * (1 + variancePercentage)>
                <cfset wheelbaseCriterion = StructNew()>
                <cfset wheelbaseCriterion.name = "wheelbase">
                <cfset wheelbaseCriterion.importance = "MustHave">
                <cfset wheelbaseCriterion.type = "TechnicalSpecificationRange">
                <cfset wheelbaseCriterion.min = min>
                <cfset wheelbaseCriterion.max = max>
                <cfset ArrayAppend(generalCriteria, wheelbaseCriterion)>
            </cfif>
        </cfif>
    </cfloop>

    <!---
        only search for vehicles that fall within a certain msrp price range (if it has a price)
    --->
    <cfset priceState = configStyle.configuredPriceState>
    <cfif priceState EQ "Actual" OR priceState EQ "Estimated">
        <!---
            create a range that the msrp of search vehicles can fall within
        --->
        <cfset min = configStyle.configuredTotalMsrp * (1 - variancePercentage)>
        <cfset max = configStyle.configuredTotalMsrp * (1 + variancePercentage)>
        <cfset priceCriterion = StructNew()>
        <cfset priceCriterion.name = "msrp">
        <cfset priceCriterion.importance = "MustHave">
        <cfset priceCriterion.type = "MoneyRange">
        <cfset priceCriterion.min = min>
        <cfset priceCriterion.max = max>
        <cfset ArrayAppend(generalCriteria, priceCriterion)>
    </cfif>

    <!---
        now create a criteria to exclude vehicles with the same model as the target vehicle
    --->
    <cfset modelCriterion = StructNew()>
    <cfset modelCriterion.name = "modelId">
    <cfset modelCriterion.importance = "MustNotHave">
    <cfset modelCriterion.type = "String">
    <cfset modelCriterion.value = configStyle.style.modelId>
    <cfset ArrayAppend(generalCriteria, modelCriterion)>

    <cfset searchCriteria = StructNew()>
    <cfset searchCriteria.criteriaArray = generalCriteria>
    <cfset searchCriteria.orCriteriaArray = orCriteria>
    <cfset searchCriteria.andCriteriaArray = andCriteria>
    <cfset searchCriteria.filterTBD = filterTBD>
    <cfset searchCriteria.filterByPostalCode = filterPostalCode>
    <cfset searchCriteria.postalCode = postalCode>
    <cfset searchCriteria.maxNumResults = maxNumResults>

    <cfset searchRequest = StructNew()>
    <cfset searchRequest.accountInfo = Session.accountInfo>
    <cfset searchRequest.orderAvailability = Session.orderAvailability>
    <cfset searchRequest.searchRequest = searchCriteria>

    <cfset styles = configService.searchStyles(searchRequest)>
    <cfloop index="i" from="1" to="#ArrayLen(styles)#">
        <cfset style = styles[i]>
        <cfset invoice = "$" & style.baseInvoice>
        <cfset msrp = "$" & style.baseMsrp>
        <cfif i GT 1>
            <cfset returnString = returnString & ";;">
        </cfif>
        <cfset returnString = returnString & style.modelYear & "~~" & style.divisionName & "~~" & style.modelName & "~~" & style.styleName & "~~" & invoice & "~~" & msrp & "~~" & style.styleId>
    </cfloop>

<cfelseif dataType EQ "getAvailableMakes">

    <cfset accountInfo = Session.accountInfo>
    <cfset scratchListId = url.scratchListId>
    <cfset modelYear = url.year>

    <cfset configState = Session.scratchList[scratchListId]>
    <cfset orderAvailability = configState.orderAvailability>

	<cfset divisionsRequest = StructNew()>
	<cfset divisionsRequest.accountInfo = accountInfo>
	<cfset divisionsRequest.filterRules = getFilterRules(orderAvailability)>
	<cfset divisionsRequest.modelYear = modelYear>

	<cfset divisions = configService.getDivisions(divisionsRequest)>

    <cfloop index="i" from="1" to="#ArrayLen(divisions)#">
        <cfset division = divisions[i]>
        <cfif i GT 1>
            <cfset returnString = returnString & ";;">
        </cfif>
        <cfset returnString = returnString & division.divisionId & "~~" & division.divisionName>
    </cfloop>

<cfelseif dataType EQ "getOptionalValues">

	<cfif NOT "#IsDefined("Session.searchDescriptors")#">
		<cfset descriptorRequest = StructNew()>
		<cfset descriptorRequest.accountInfo = Session.accountInfo>
		<cfset descriptors = configService.getSearchCriterionDescriptors(descriptorRequest)>
        <cfset searchDescriptorMap = StructNew()>
        <cfloop index="i" from="1" to="#ArrayLen(descriptors)#">
            <cfset descriptor = descriptors[i]>
            <cfset a = StructInsert(searchDescriptorMap, descriptor.name, descriptor, 1)>
        </cfloop>
        <cfset Session.searchDescriptors = searchDescriptorMap>
    </cfif>

    <cfset tokenName = url.tokenName>
    <cfset returnString = getOptionalValues(tokenName)>

</cfif>

<cfoutput>#returnString#</cfoutput>

<cffunction name="getOptionalValues" returnType="string"><cfargument name="searchTokenName" type="string" required="true">
    <cfset optionalValues = "">
	<cfset searchDescriptorMap = Session.searchDescriptors>
	<cfif "#IsDefined("searchDescriptorMap." & searchTokenName)#">
		<cfset descriptor = searchDescriptorMap[searchTokenName]>
		<cfif "#IsDefined("descriptor.values")#">
			<cfset choices = descriptor.values>
			<cfloop index="i" from="1" to="#ArrayLen(choices)#">
	            <cfset choice = choices[i]>
                <cfset choiceText = choice.id & "~~" & choice.value>
                <cfif i GT 1>
                	<cfset optionalValues = optionalValues & ";;">
                </cfif>
                <cfset optionalValues = optionalValues & choiceText>
			</cfloop>
		</cfif>
	</cfif>
	<cfreturn optionalValues>
</cffunction>

<cffunction name="parseCompositeSearchCriterion" returnType="struct"><cfargument name="paramString" type="string" required="true">

    <cfset criterion = StructNew()>

    <!--- divide into subcriteria --->
    <cfset criteria = ListToArray(paramString, ";;")>

    <!--- process each subcriteria --->
    <cfloop index="i" from="1" to="#ArrayLen(criteria)#">

        <cfset attributeMap = parseAttributes( criteria[i] )>

	<cfif IsDefined("attributeMap.compositeType")>
            <cfset compositeType = attributeMap.compositeType>
            <cfset compositeName = attributeMap.compositeName>
	    <cfset mustHave = "MustHave">
	    <cfif attributeMap.compositeMustHave EQ "false">
	        <cfset mustHave = "MustNotHave">
	    </cfif>
            <cfset criterion.name = compositeName>
            <cfset criterion.type = compositeType>
            <cfset criterion.mustHave = mustHave>
            <cfset criterion.subCriteria = ArrayNew(1)>
        </cfif>

        <cfset subCriterion = createSearchCriterion( attributeMap )>
        <cfif NOT StructIsEmpty(subCriterion)>
            <cfset ArrayAppend(criterion.subCriteria, subCriterion)>
        </cfif>
    </cfloop>

    <cfreturn criterion>

</cffunction>

<cffunction name="parseAttributes" returnType="struct"><cfargument name="attributeString" type="string" required="true">

    <cfset attributeMap = StructNew()>
    <cfset attributes = ListToArray(attributeString, "&")>
    <cfloop index="i" from="1" to="#ArrayLen(attributes)#">
        <cfset values = ListToArray(attributes[i], "=")>
        <cfif ArrayLen(values) EQ 2>
            <cfset name = values[1]>
            <cfset value = values[2]>
	    <cfset StructInsert(attributeMap, name, value, 1)>
        </cfif>
    </cfloop>

    <cfreturn attributeMap>

</cffunction>

<cffunction name="createSearchCriterion" returnType="struct"><cfargument name="attributes" type="struct" required="true">

    <cfset searchCriterion = StructNew()>

    <cfset searchCriterion.name = attributes.name>
    <cfset searchCriterion.type = attributes.type>
    <cfset searchCriterion.importance = "MustHave">
    <cfif attributes.mustHave EQ "false">
        <cfset searchCriterion.importance = "MustNotHave">
    </cfif>
    <cfif IsDefined("attributes.value")>
    	<cfset searchCriterion.value = attributes.value>
    </cfif>
    <cfif IsDefined("attributes.min")>
    	<cfset searchCriterion.min = attributes.min>
    </cfif>
    <cfif IsDefined("attributes.max")>
    	<cfset searchCriterion.max = attributes.max>
    </cfif>

    <cfreturn searchCriterion>

</cffunction>

<cffunction name="doesWheelbaseMatter" returnType="boolean"><cfargument name="marketClassName" type="string" required="true">

    <cfset wheelbaseDoesMatter = FALSE>

    <cfif find("Truck",marketClassName) > 0 >
        <cfset wheelbaseDoesMatter = TRUE>
    <cfelseif find("Van",marketClassName) > 0 >
        <cfset wheelbaseDoesMatter = TRUE>
    <cfelseif find("Special Purpose",marketClassName) > 0 >
        <cfset wheelbaseDoesMatter = TRUE>
    <cfelseif find("Sport Utility",marketClassName) > 0 >
        <cfset wheelbaseDoesMatter = TRUE>
    <cfelseif find("Commercial Vehicles",marketClassName) > 0 >
        <cfset wheelbaseDoesMatter = TRUE>
    </cfif>

    <cfreturn wheelbaseDoesMatter>

</cffunction>