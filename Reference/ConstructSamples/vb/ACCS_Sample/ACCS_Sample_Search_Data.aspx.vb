imports configcompare3.kp.chrome.com

Partial Class ACCS_Sample_Search_Data
    Inherits System.Web.UI.Page

    Protected configService As AutomotiveConfigCompareService3 = New configcompare3.kp.chrome.com.AutomotiveConfigCompareService3
    Protected const accountNumber as String = "0"
    protected const accountSecret as String = "accountSecret"
    Protected result As String = String.Empty
    Private searchDescriptorMap As Hashtable = Nothing

    Private Const VARIANCE_PERCENT As Double = 0.05
    Private Const PASSENGER_CAPACITY_TECH_SPEC_ID As Integer = 8
    Private Const WHEELBASE_TECH_SPEC_ID As Integer = 301

    Sub Page_Load(ByVal Sender As System.Object, ByVal e As System.EventArgs)
        dim dataRequest as String = Request.QueryString( "data" )

        Select Case dataRequest
            Case "locale"
                setAccountInfo( Request.QueryString( "locale" ) )

            Case "orderAvailability"
                dim orderAvailabilityQuery as String = Request.QueryString( "orderAvailability" )
                if( orderAvailabilityQuery = "Fleet" )
                    Session( "configOrderAvailability" ) = OrderAvailability.Fleet
                    Session( "compareOrderAvailability" ) = OrderAvailability.Fleet
                    Session( "searchOrderAvailability" ) = OrderAvailability.Fleet
                else
                    Session( "configOrderAvailability" ) = OrderAvailability.Retail
                    Session( "compareOrderAvailability" ) = OrderAvailability.Retail
                    Session( "searchOrderAvailability" ) = OrderAvailability.Retail
                end if
            
            Case "getSearchCriteria"
            
                dim searchAccountInfo as AccountInfo = Session( "searchAccountInfo" )

                ' construct the request to retrieve all available search criteria
                dim descriptorRequest as SearchCriterionDescriptorRequest = new SearchCriterionDescriptorRequest()
                descriptorRequest.accountInfo = searchAccountInfo
                dim descriptors as SearchCriterionDescriptor() = configService.getSearchCriterionDescriptors( descriptorRequest )

                dim i as Integer
                for i = 0 to descriptors.Length - 1
                    if( i > 0 )
                        result += ( ";;" )  ' separator between descriptors
                    end if

                    result += descriptors( i ).name.ToString() & "~~" ' name
                    result += descriptors( i ).type.ToString() & "~~" ' type
                    if( not descriptors( i ).min is nothing )
                        result += descriptors( i ).min
                    End If
                    result += "~~"
                    if( not descriptors( i ).max is nothing )
                        result += descriptors( i ).max
                    End If
                    result += "~~"
                    result += descriptors( i ).unit.ToString()
                    
                next i

            Case "getSearchResults"
                dim searchAccountInfo as AccountInfo = Session( "searchAccountInfo" )
                dim searchOrderAvailability as OrderAvailability = Session( "searchOrderAvailability" )
                dim searchType as String = Request.QueryString( "searchType" )
                dim filterTBD as Boolean = false
                dim filterPostalCode as Boolean = false
                dim postalCode as String = Request.QueryString( "postalCode" )
                if( not Request.QueryString( "filterTBD" ) is nothing  )
                    filterTBD = Boolean.Parse( Request.QueryString( "filterTBD" ) )
                end if
                if( not Request.QueryString( "filterPostalCode" ) is nothing )
                    filterPostalCode = Boolean.Parse( Request.QueryString( "filterPostalCode" ) )
                end if

                dim maxNumResults as Integer = -1
                if( not Request.QueryString( "maxNumResults" ) is nothing )
                    maxNumResults = Int32.Parse( Request.QueryString( "maxNumResults" ) )
                end if
                
                dim generalCriteria as ArrayList = new ArrayList()
                dim andCriteria as ArrayList = new ArrayList()
                dim orCriteria as ArrayList = new ArrayList()

                ' extract all the search params from the request
                ' each param will be similar in form to:
                ' compositeName=division&compositeType=general&compositeMustHave=true&name=division&type=String&mustHave=true&value=ford&min=&max=
                dim searchParamIndex as Integer = 0
                dim searchParamKey as String = "searchParam" + searchParamIndex.ToString()
                while( not Request.QueryString( searchParamKey ) is nothing )
                    dim paramString as String = Request.QueryString( searchParamKey )
                    searchParamIndex += 1
                    searchParamKey = "searchParam" + searchParamIndex.ToString()

                    dim compositeCriterion as CompositeSearchCriterion = CompositeSearchCriterion.parse( paramString )
                    if( not compositeCriterion is nothing )
                        select case compositeCriterion.type
                            case "general"
                                generalCriteria.Add( compositeCriterion.subCriteria( 0 ) )
                            
                            case "and"                            
                                dim subCriteria as SearchCriterion() = compositeCriterion.subCriteria.ToArray( new SearchCriterion().GetType() )
                                dim andCriterion as AndCriterion = new AndCriterion()
                                andCriterion.name = compositeCriterion.name
                                andCriterion.criteriaArray = subCriteria
                                andCriteria.Add( andCriterion )

                            case "or"
                                dim subCriteria as SearchCriterion() = compositeCriterion.subCriteria.ToArray( new SearchCriterion().GetType() )
                                dim orCriterion as OrCriterion = new OrCriterion()
                                orCriterion.importance = compositeCriterion.mustHave
                                orCriterion.criteriaArray = subCriteria
                                orCriteria.Add( orCriterion )
                            
                        end select
                    end if
                end while

                ' Create the search service request
                dim searchRequest as SearchServiceRequest = new SearchServiceRequest()
                searchRequest.criteriaArray = generalCriteria.ToArray( new SearchCriterion().GetType() )
                searchRequest.orCriteriaArray = orCriteria.ToArray( new OrCriterion().GetType() )
                searchRequest.andCriteriaArray = andCriteria.ToArray( new AndCriterion().GetType() )
                searchRequest.filterTBD = filterTBD
                searchRequest.filterByPostalCode = filterPostalCode
                searchRequest.postalCode = postalCode
                searchRequest.maxNumResults = maxNumResults

                select case searchType 
                
                    case "searchStyles"
                        dim theRequest as SearchStylesRequest= new SearchStylesRequest()
                        theRequest.accountInfo = searchAccountInfo
                        theRequest.orderAvailability = searchOrderAvailability
                        theRequest.searchRequest = searchRequest

                        dim styles as configcompare3.kp.chrome.com.Style() = configService.searchStyles( theRequest )
                        dim i as integer
                        for i = 0 to styles.Length - 1
                            dim style as configcompare3.kp.chrome.com.Style = styles( i )
                            dim invoice as String = "$" + style.baseInvoice.ToString()
                            dim msrp as String = "$" +  style.baseMsrp.ToString()
                            if (i > 0) 
                                result += ";;"
                            end if
                            result += style.modelYear.ToString() + "~~" + style.divisionName + "~~" + style.modelName + "~~" + style.styleName + "~~" + invoice + "~~" + msrp + "~~" + style.styleId.ToString()
                        next i

                    case "searchModels":
                        dim theRequest as SearchModelsRequest = new SearchModelsRequest()
                        theRequest.accountInfo = searchAccountInfo
                        theRequest.orderAvailability = searchOrderAvailability
                        theRequest.searchRequest = searchRequest

                        dim searchResults as ModelSearchResult() = configService.searchModels( theRequest )
                        dim i as Integer
                        for i = 0 to searchResults.Length - 1
                            if (i > 0)
                                result += ";;"
                            end if
                            Dim model As configcompare3.kp.chrome.com.Model = searchResults(i).model
                            dim dateString as String = model.lastModifiedDate.ToShortDateString()                            
                            result += model.modelId.ToString() + "~~" + model.modelName + "~~" +  dateString
                        next i
                    
                end select

            Case "findComparable"

                ' This search is designed to find similar vehicles to the target vehicle based on the vehicle's
                ' model year, market class, body style, etc.

                Dim i As Integer
                Dim filterTBD As Boolean = False
                Dim filterPostalCode As Boolean = False

                Dim postalCode As String = Request.QueryString("postalCode")
                If (Not Request.QueryString("filterTBD") Is Nothing) Then
                    filterTBD = Boolean.Parse(Request.QueryString("filterTBD"))
                End If
                If (Not Request.QueryString("filterPostalCode") Is Nothing) Then
                    filterPostalCode = Boolean.Parse(Request.QueryString("filterPostalCode"))
                End If
                Dim maxNumResults As Int32 = -1
                If (Not Request.QueryString("maxNumResults") Is Nothing) Then
                    maxNumResults = Int32.Parse(Request.QueryString("maxNumResults"))
                End If

                Dim searchAccountInfo As AccountInfo = Session("searchAccountInfo")

                Dim scratchListId As String = Request.QueryString("scratchListId")
                Dim configState As ConfigurationState = Session(scratchListId)

                ' Retrieve target vehicle info so we know what to base comparable search on
                Dim orderAvailability As OrderAvailability = configState.orderAvailability
                Dim styleRequest As FullyConfiguredRequest = New FullyConfiguredRequest()
                styleRequest.accountInfo = searchAccountInfo
                styleRequest.configurationState = configState
                Dim toggleResponse As ToggleOptionResponse = configService.getStyleFullyConfigured(styleRequest)
                Dim configStyle As configcompare3.kp.chrome.com.Configuration = toggleResponse.configuration

                ' now build up the search criteria
                Dim generalCriteria As ArrayList = New ArrayList()
                Dim andCriteria As ArrayList = New ArrayList()
                Dim orCriteria As ArrayList = New ArrayList()

                ' only search for model year of target vehicle or newer
                Dim yearCriterion As SearchCriterion = getSearchCriterion(SearchTokenName.year, SearchImportanceType.MustHave, SearchCriterionType.NumberRange, Nothing, configStyle.style.modelYear.ToString(), Nothing)
                generalCriteria.Add(yearCriterion)

                ' only search for selected makes
                Dim chosenMakes As String() = Request.QueryString("makes").Split(New String() {";;"}, StringSplitOptions.None)
                If (Not chosenMakes Is Nothing And chosenMakes.Length > 0) Then
                    Dim makeCriteriaList As ArrayList = New ArrayList()
                    Dim j As Integer
                    For j = 0 To chosenMakes.Length - 1
                        Dim makeCriterion As SearchCriterion = getSearchCriterion(SearchTokenName.divisionId, SearchImportanceType.MustHave, SearchCriterionType.String, chosenMakes(j), Nothing, Nothing)
                        makeCriteriaList.Add(makeCriterion)
                    Next j
                    ' make an OrCriterion that includes all of the passed in makes (e.g. This vehicle make must = Ford or Chevy or Honda, etc.)
                    Dim makeListCriterion As OrCriterion = getOrCriterion(SearchImportanceType.MustHave, makeCriteriaList.ToArray(New SearchCriterion().GetType()))
                    orCriteria.Add(makeListCriterion)
                End If

                ' only search for vehicles with the same market class as this target vehicle
                Dim marketClassCriterion As SearchCriterion = getSearchCriterion(SearchTokenName.marketClassId, SearchImportanceType.MustHave, SearchCriterionType.String, configStyle.style.marketClassId.ToString(), Nothing, Nothing)
                generalCriteria.Add(marketClassCriterion)

                ' only search for selected vehicles with same body type as target vehicle
                Dim bodyTypeList As ArrayList = New ArrayList()
                For i = 0 To configStyle.style.bodyTypes.Length - 1
                    Dim bodyType As BodyType = configStyle.style.bodyTypes(i)
                    Dim bodyTypeCriterion As SearchCriterion = getSearchCriterion(SearchTokenName.bodyType, SearchImportanceType.MustHave, SearchCriterionType.String, bodyType.bodyTypeId.ToString(), Nothing, Nothing)
                    bodyTypeList.Add(bodyTypeCriterion)
                Next i
                ' make an OrCriterion that includes all of the body types (e.g. This vehicle body type must = Short Bed or Crew Cab Pickup, etc.)
                Dim bodyCriterion As OrCriterion = getOrCriterion(SearchImportanceType.MustHave, bodyTypeList.ToArray(New SearchCriterion().GetType()))
                orCriteria.Add(bodyCriterion)

                ' only search for vehicles with the same number of passenger doors on target vehicle
                Dim passengerDoorsCriterion As SearchCriterion = getSearchCriterion(SearchTokenName.numberOfDoors, SearchImportanceType.MustHave, SearchCriterionType.String, configStyle.style.passengerDoors.ToString(), Nothing, Nothing)
                generalCriteria.Add(passengerDoorsCriterion)

                ' this vehicle has a meaningful wheelbase value if its market class id is contained in the list
                Dim hasMeaningfulWheelbase As Boolean = doesWheelbaseMatter(configStyle.style.marketClassName)

                ' match on certain tech specs (passenger capacity, wheelbase - if truck or suv)
                Dim techSpecs As TechnicalSpecification() = configStyle.technicalSpecifications
                For i = 0 To techSpecs.Length - 1
                    ' passenger capacity
                    If (techSpecs(i).titleId = PASSENGER_CAPACITY_TECH_SPEC_ID) Then
                        Dim passengerCapacity As String = techSpecs(i).value
                        Dim passengerCapacityCriterion As SearchCriterion = getSearchCriterion(SearchTokenName.passengerCapacity, SearchImportanceType.MustHave, SearchCriterionType.TechnicalSpecificationRange, Nothing, passengerCapacity, passengerCapacity)
                        generalCriteria.Add(passengerCapacityCriterion)
                    End If

                    ' if this vehicle has a meaningful wheelbase, then add this to the search criteria
                    If (hasMeaningfulWheelbase And techSpecs(i).titleId = WHEELBASE_TECH_SPEC_ID) Then
                        Dim value As String = techSpecs(i).value
                        Dim wheelbase As Double = -1
                        Try
                            wheelbase = Double.Parse(value)
                        Catch
                        End Try
                        ' create a range that the wheelbase of search vehicles can fall within
                        If (wheelbase <> -1) Then
                            Dim min As Double = wheelbase * (1 - VARIANCE_PERCENT)
                            Dim max As Double = wheelbase * (1 + VARIANCE_PERCENT)
                            Dim wheelbaseCriterion As SearchCriterion = getSearchCriterion(SearchTokenName.wheelbase, SearchImportanceType.MustHave, SearchCriterionType.TechnicalSpecificationRange, Nothing, min.ToString(), max.ToString())
                            generalCriteria.Add(wheelbaseCriterion)
                        End If
                    End If
                Next i

                ' only search for vehicles that fall within a certain msrp price range (if it has a price)
                Dim priceState As PriceState = configStyle.configuredPriceState
                If (priceState = priceState.Actual Or priceState = priceState.Estimated) Then
                    ' create a range that the msrp of search vehicles can fall within
                    Dim min As Double = configStyle.configuredTotalMsrp * (1 - VARIANCE_PERCENT)
                    Dim max As Double = configStyle.configuredTotalMsrp * (1 + VARIANCE_PERCENT)
                    Dim wheelbaseCriterion As SearchCriterion = getSearchCriterion(SearchTokenName.msrp, SearchImportanceType.MustHave, SearchCriterionType.MoneyRange, Nothing, min.ToString(), max.ToString())
                    generalCriteria.Add(wheelbaseCriterion)
                End If

                ' now create a criteria to exclude vehicles with the same model as the target vehicle
                Dim modelCriterion As SearchCriterion = getSearchCriterion(SearchTokenName.modelId, SearchImportanceType.MustNotHave, SearchCriterionType.String, configStyle.style.modelId.ToString(), Nothing, Nothing)
                generalCriteria.Add(modelCriterion)

                ' Create the search service request
                Dim searchRequest As SearchServiceRequest = New SearchServiceRequest()
                searchRequest.criteriaArray = generalCriteria.ToArray(New SearchCriterion().GetType())
                searchRequest.orCriteriaArray = orCriteria.ToArray(New OrCriterion().GetType())
                searchRequest.andCriteriaArray = andCriteria.ToArray(New AndCriterion().GetType())
                searchRequest.filterTBD = filterTBD
                searchRequest.filterByPostalCode = filterPostalCode
                searchRequest.postalCode = postalCode
                searchRequest.maxNumResults = maxNumResults

                Dim thisRequest As SearchStylesRequest = New SearchStylesRequest()
                thisRequest.accountInfo = searchAccountInfo
                thisRequest.orderAvailability = orderAvailability
                thisRequest.searchRequest = searchRequest

                Dim styles As configcompare3.kp.chrome.com.Style() = configService.searchStyles(thisRequest)
                If (Not styles Is Nothing) Then
                    For i = 0 To styles.Length - 1
                        Dim style As configcompare3.kp.chrome.com.Style = styles(i)
                        Dim invoice As String = "$" + style.baseInvoice.ToString
                        Dim msrp As String = "$" + style.baseMsrp.ToString
                        If (i > 0) Then
                            result += ";;"
                        End If
                        result += style.modelYear.ToString + "~~" + style.divisionName + "~~" + style.modelName + "~~" + style.styleName + "~~" + invoice.ToString + "~~" + msrp.ToString + "~~" + style.styleId.ToString
                    Next i
                End If

            Case "getAvailableMakes"

                Dim searchAccountInfo As AccountInfo = Session("searchAccountInfo")
                Dim scratchListId As String = Request.QueryString("scratchListId")
                Dim modelYear As String = Request.QueryString("year")
                Dim configState As ConfigurationState = Session(scratchListId)

                ' retrieve all the available makes for the model year of the target vehicle
                Dim orderAvailability As OrderAvailability = configState.orderAvailability

                Dim divisionRequest As DivisionsRequest = New DivisionsRequest()
                divisionRequest.accountInfo = searchAccountInfo
                divisionRequest.filterRules = getFilterRules(orderAvailability)
                divisionRequest.modelYear = Int32.Parse(modelYear)

                Dim divisions As Division() = configService.getDivisions(divisionRequest)
                If (Not divisions Is Nothing) Then
                    Dim i As Integer
                    For i = 0 To divisions.Length - 1
                        Dim divisionId As Integer = divisions(i).divisionId
                        Dim divisionName As String = divisions(i).divisionName
                        If (i > 0) Then
                            result += ";;"
                        End If
                        result += divisionId.ToString + "~~" + divisionName
                    Next i
                End If

            Case "getOptionalValues"

                Dim accountInfo As AccountInfo = Session("searchAccountInfo")
                Dim tokenName As String = Request.QueryString("tokenName")

                initSearchDescriptorMap(accountInfo)
                result = getOptionalValues(tokenName)

        End Select
    End Sub

    Private Function getFilterRules(ByVal availability As OrderAvailability) As FilterRules
        Dim rules As New FilterRules
        rules.orderAvailability = availability
        Return rules
    End Function

    Private Function getOptionalValues(ByVal searchTokenName As String)
        Dim values As String = ""
        Dim descriptor As SearchCriterionDescriptor = searchDescriptorMap(searchTokenName)
        If (Not descriptor Is Nothing And Not descriptor.values Is Nothing) Then
            Dim i As Integer
            For i = 0 To descriptor.values.Length - 1
                Dim choice As String = descriptor.values(i).id + "~~" + descriptor.values(i).value
                If (values.Length > 0) Then
                    values += ";;"
                End If
                values += choice
            Next i
        End If
        Return values
    End Function

    Private Sub initSearchDescriptorMap(ByVal accountInfo As AccountInfo)
        If (searchDescriptorMap Is Nothing) Then
            searchDescriptorMap = New Hashtable()
            Dim request As New SearchCriterionDescriptorRequest()
            request.accountInfo = accountInfo
            Dim descriptors As SearchCriterionDescriptor() = configService.getSearchCriterionDescriptors(request)
            Dim i As Integer
            For i = 0 To descriptors.Length - 1
                Dim descriptor As SearchCriterionDescriptor = descriptors(i)
                searchDescriptorMap.Add(descriptor.name.ToString, descriptor)
            Next i
        End If
    End Sub

    ' sorts passed in style array by model year, then by make name, then by model name
    Sub sortStyles(ByVal styles As configcompare3.kp.chrome.com.Style())
        If (styles Is Nothing Or styles.Length = 0) Then
            Return
        End If
        Array.Sort(styles, New StyleSorter)
    End Sub

    Private Sub setAccountInfo(ByVal locale As String)

        Dim country As String = "US"
        Dim language As String = "en"

        If (locale.Equals("enCA")) Then
            country = "CA"
        ElseIf (locale.Equals("frCA")) Then
            country = "CA"
            language = "fr"
        End If

        'set compare and config Locales 
        Dim configLocale As Locale = New Locale
        configLocale.country = country
        configLocale.language = language

        Dim compareLocale As configcompare3.kp.chrome.com.Locale = New configcompare3.kp.chrome.com.Locale
        compareLocale.country = country
        compareLocale.language = language

        'set compare, config, and search AccountInfos
        Dim configAccountInfo As AccountInfo = New AccountInfo
        configAccountInfo.accountNumber = accountNumber
        configAccountInfo.accountSecret = accountSecret
        configAccountInfo.locale = configLocale
        Session("configAccountInfo") = configAccountInfo

        Dim compareAccountInfo As configcompare3.kp.chrome.com.AccountInfo = New configcompare3.kp.chrome.com.AccountInfo
        compareAccountInfo.accountNumber = accountNumber
        compareAccountInfo.accountSecret = accountSecret
        compareAccountInfo.locale = compareLocale
        Session("compareAccountInfo") = compareAccountInfo

        Dim searchAccountInfo As configcompare3.kp.chrome.com.AccountInfo = New configcompare3.kp.chrome.com.AccountInfo
        searchAccountInfo.accountNumber = accountNumber
        searchAccountInfo.accountSecret = accountSecret
        searchAccountInfo.locale = compareLocale
        Session("searchAccountInfo") = searchAccountInfo

    End Sub

    Function getSearchCriterion(ByVal name As SearchTokenName, ByVal importance As SearchImportanceType, ByVal type As SearchCriterionType, ByVal value As String, ByVal min As String, ByVal max As String) As SearchCriterion

        Dim criterion As SearchCriterion = New SearchCriterion()

        criterion.name = name
        criterion.importance = importance
        criterion.type = type
        criterion.value = value
        criterion.min = min
        criterion.max = max

        Return criterion

    End Function

    Function getOrCriterion(ByVal importance As SearchImportanceType, ByVal subCriteria As SearchCriterion()) As OrCriterion

        Dim orCriterion As OrCriterion = New OrCriterion()

        orCriterion.importance = importance
        orCriterion.criteriaArray = subCriteria

        Return orCriterion

    End Function

    Function doesWheelbaseMatter(ByVal marketClassName As String) As Boolean

        Dim wheelbaseDoesMatter As Boolean = False

        If (InStr(marketClassName, "Truck") > 0) Then
            wheelbaseDoesMatter = True
        ElseIf (InStr(marketClassName, "Van") > 0) Then
            wheelbaseDoesMatter = True
        ElseIf (InStr(marketClassName, "Special Purpose") > 0) Then
            wheelbaseDoesMatter = True
        ElseIf (InStr(marketClassName, "Sport Utility") > 0) Then
            wheelbaseDoesMatter = True
        ElseIf (InStr(marketClassName, "Commercial Vehicles") > 0) Then
            wheelbaseDoesMatter = True
        End If

        Return wheelbaseDoesMatter

    End Function

End Class

Class StyleSorter
    Implements IComparer

    Function Compare(ByVal x As Object, ByVal y As Object) As Integer Implements IComparer.Compare

        Dim styleA As Style = x
        Dim styleB As Style = y
        Dim yearA As Integer = styleA.modelYear
        Dim yearB As Integer = styleB.modelYear

        If (yearA < yearB) Then
            Return -1
        ElseIf (yearA > yearB) Then
            Return 1
        Else
            Dim makeA As String = styleA.divisionName
            Dim makeB As String = styleB.divisionName
            Dim compareValue As Integer = String.Compare(makeA, makeB, True)
            If (compareValue = 0) Then
                Return String.Compare(styleA.modelName, styleB.modelName, True)
            Else
                Return compareValue
            End If
        End If

    End Function

End Class


Class CompositeSearchCriterion
    Public name As SearchTokenName
    Public type As String
    Public mustHave As SearchImportanceType
    Public subCriteria As ArrayList = New ArrayList()

    Public Sub New(ByVal nameValue As SearchTokenName, ByVal typeValue As String, ByVal mustHaveValue As SearchImportanceType)
        name = nameValue
        type = typeValue
        mustHave = mustHaveValue
    End Sub

    Public Sub addCriterion(ByVal criterion As SearchCriterion)
        subCriteria.Add(criterion)
    End Sub

    ' param string should be of form:
    ' compositeName=orCrit&compositeType=or&compositeMustHave=true&name=airbagSideType&type=String&mustHave=true&value=sbs&min=&max=;;&name=hasMoonRoof&type=Boolean&mustHave=true&value=true&min=&max=
    Public Shared Function parse(ByVal paramString As String) As CompositeSearchCriterion

        Dim criterion As CompositeSearchCriterion = Nothing
        Dim compositeName As SearchTokenName
        Dim compositeType As String = ""
        Dim mustHave As SearchImportanceType

        Dim criteria As String() = paramString.Split(New String() {";;"}, StringSplitOptions.None)    ' divide into subcriteria
        Dim i As Integer
        For i = 0 To criteria.Length - 1    ' process each subcriteria
            Dim attributeMap As Hashtable = parseAttributes(criteria(i))

            If (i = 0) Then
                compositeType = attributeMap("compositeType")
                compositeName = convertToType(New SearchTokenName().GetType(), attributeMap("compositeName"))

                Dim mustHaveBool As Boolean = Boolean.Parse(attributeMap("compositeMustHave"))
                If (mustHaveBool) Then
                    mustHave = SearchImportanceType.MustHave
                Else
                    mustHave = SearchImportanceType.MustNotHave
                End If

                criterion = New CompositeSearchCriterion(compositeName, compositeType, mustHave)
            End If

            Dim subCriterion As SearchCriterion = createSearchCriterion(attributeMap)
            If (Not subCriterion Is Nothing) Then
                criterion.addCriterion(subCriterion)
            End If
        Next i

        Return criterion
    End Function

    ' takes a string of form key1=value1&key2=value2 and returns a map of the form: key1 -> value1, etc.
    Shared Function parseAttributes(ByVal attributeString As String) As Hashtable

        Dim attributeMap As Hashtable = New Hashtable()
        Dim attributes As String() = attributeString.Split("&")
        Dim i As Integer
        For i = 0 To attributes.Length - 1
            Dim values As String() = attributes(i).Split("=")
            If (values.Length = 2) Then
                attributeMap.Add(values(0), values(1))
            End If
        Next i

        Return attributeMap
    End Function

    Shared Function createSearchCriterion(ByVal attributes As Hashtable) As SearchCriterion
        Dim criterion As SearchCriterion

        Dim name As SearchTokenName = convertToType(New SearchTokenName().GetType(), attributes("name"))
        Dim type As SearchCriterionType = convertToType(New SearchCriterionType().GetType(), attributes("type"))
        Dim importance As SearchImportanceType
        Dim importanceBoolean As Boolean = attributes("mustHave") = "true"
        If (importanceBoolean) Then
            importance = SearchImportanceType.MustHave
        Else
            importance = SearchImportanceType.MustNotHave
        End If

        Dim value As String = ""
        If (attributes.ContainsKey("value") And attributes("value").Length > 0) Then
            value = attributes("value")
        End If

        Dim min As String = ""
        If (attributes.ContainsKey("min") And attributes("min").Length > 0) Then
            min = attributes("min")
        End If

        Dim max As String = Nothing
        If (attributes.ContainsKey("max") And attributes("max").Length > 0) Then
            max = attributes("max")
        End If

        criterion = New SearchCriterion()
        criterion.name = name
        criterion.importance = importance
        criterion.type = type
        criterion.value = value
        criterion.min = min
        criterion.max = max

        Return criterion
    End Function

    Shared Function convertToType(ByVal type As Type, ByVal target As String) As Object

        Dim returnObject As Object = Nothing
        Dim field As System.Reflection.FieldInfo = type.GetField(target)

        If (Not field Is Nothing) Then
            returnObject = field.GetValue(Nothing)
        End If

        Return returnObject

    End Function

End Class