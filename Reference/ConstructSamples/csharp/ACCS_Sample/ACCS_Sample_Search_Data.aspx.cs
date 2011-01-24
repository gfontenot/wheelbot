using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;

using configcompare3.kp.chrome.com;

public partial class ACCS_Sample_Search_Data : System.Web.UI.Page
{
    /*
        This is a list of the available market class information for vehicles (market class id, market class name).
        It can be used to filter on certain vehicle types (e.g. SUVs, Trucks, passenger cars, etc.)

        1,"2WD Small Pickup Trucks"
        2,"4WD Small Pickup Trucks"
        3,"2WD Standard Pickup Trucks"
        4,"4WD Standard Pickup Trucks"
        5,"2WD Light Duty Chassis-Cab Trucks"
        6,"4WD Light Duty Chassis Cab Trucks"
        9,"Medium Duty Chassis Cab Trucks"
        12,"2WD Special Purpose Vehicles"
        14,"4WD Special Purpose Vehicles"
        16,"2WD Sport Utility Vehicles"
        18,"4WD Sport Utility Vehicles"
        20,"Two-seater Passenger Car"
        21,"2-door Mini-Compact Passenger Car"
        22,"2-door Sub-Compact Passenger Car"
        23,"2-door Compact Passenger Car"
        24,"2-door Mid-Size Passenger Car"
        25,"2-door Large Passenger Car"
        42,"4-door Sub-Compact Passenger Car"
        43,"4-door Compact Passenger Car"
        44,"4-door Mid-Size Passenger Car"
        45,"4-door Large Passenger Car"
        53,"Small Station Wagon"
        54,"Mid-Size Station Wagon"
        55,"Large Station Wagon"
        61,"Mini-Van (Passenger)"
        62,"2WD Minivans"
        63,"4WD Minivans"
        65,"Large Passenger Vans"
        66,"Cargo Vans"
        99,"Commercial Vehicles"
     */

    private static readonly int[] MEANINGFUL_WHEELBASE_MARKET_CLASS_IDS = new int[]
    {
        1, // "2WD Small Pickup Trucks"
        2, // "4WD Small Pickup Trucks"
        3, // "2WD Standard Pickup Trucks"
        4, // "4WD Standard Pickup Trucks"
        5, // "2WD Light Duty Chassis-Cab Trucks"
        6, // "4WD Light Duty Chassis Cab Trucks"
        9, // "Medium Duty Chassis Cab Trucks"
        12, // "2WD Special Purpose Vehicles"
        14, // "4WD Special Purpose Vehicles"
        16, // "2WD Sport Utility Vehicles"
        18, // "4WD Sport Utility Vehicles"
        65, // "Large Passenger Vans"
        66, // "Cargo Vans"
        99, // "Commercial Vehicles"
    };

    private static readonly double VARIANCE_PERCENT = 0.05;
    private static readonly int PASSENGER_CAPACITY_TECH_SPEC_ID = 8;
    private static readonly int WHEELBASE_TECH_SPEC_ID = 301;

    private Hashtable searchDescriptorMap = null;

    protected AutomotiveConfigCompareService3 configService = new AutomotiveConfigCompareService3();
    protected const String accountNumber = "0";
    protected const String accountSecret = "accountSecret";
    protected String result = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        String dataRequest = Request.QueryString["data"];

        switch( dataRequest ) 
        {
            case "locale":
            {
                setAccountInfo(Request.QueryString["locale"]);
                break;
            }

            case "orderAvailability":
            {
                String orderAvailabilityQuery = Request.QueryString["orderAvailability"];
                if (orderAvailabilityQuery == "Fleet")
                {
                    Session["configOrderAvailability"] = OrderAvailability.Fleet;
                    Session["compareOrderAvailability"] = OrderAvailability.Fleet;
                    Session["searchOrderAvailability"] = OrderAvailability.Fleet;
                }
                else
                {
                    Session["configOrderAvailability"] = OrderAvailability.Retail;
                    Session["compareOrderAvailability"] = OrderAvailability.Retail;
                    Session["searchOrderAvailability"] = OrderAvailability.Retail;
                }
                break;
            }

            case "getSearchCriteria":
            {
                AccountInfo searchAccountInfo = (AccountInfo)Session[ "searchAccountInfo" ] ;

                // construct the request to retrieve all available search criteria
                SearchCriterionDescriptorRequest descriptorRequest = new SearchCriterionDescriptorRequest();
                descriptorRequest.accountInfo = searchAccountInfo;                
                SearchCriterionDescriptor[] descriptors = configService.getSearchCriterionDescriptors( descriptorRequest );
                for( int i = 0; i < descriptors.Length; ++i )
                {
                    if( i > 0 )
                        result += ( ";;" );  // separator between descriptors

                    result += descriptors[ i ].name + "~~"// name
                            + descriptors[ i ].type + "~~" // type
                            + (descriptors[ i ].min != null ? descriptors[ i ].min : "" ) + "~~" // min
                            + (descriptors[ i ].max != null ? descriptors[ i ].max : "" ) + "~~"// max
                            + (descriptors[ i ].unit != null ? descriptors[ i ].unit.Value.ToString() : "" ); // unit
                }
            }
            break;

            case "getSearchResults":
            {
                AccountInfo searchAccountInfo = (AccountInfo)Session[ "searchAccountInfo" ];
                OrderAvailability searchOrderAvailability = (OrderAvailability)Session[ "searchOrderAvailability" ];
                String searchType = Request.QueryString[ "searchType" ];
                bool filterTBD = false;
                bool filterPostalCode = false;
                String postalCode = Request.QueryString[ "postalCode" ];
                if( Request.QueryString[ "filterTBD" ] != null )
                    filterTBD = Boolean.Parse( Request.QueryString[ "filterTBD" ] );
                if( Request.QueryString[ "filterPostalCode" ] != null )
                    filterPostalCode = Boolean.Parse( Request.QueryString[ "filterPostalCode" ] );

                int maxNumResults = -1;
                if( Request.QueryString[ "maxNumResults" ] != null )
                {
                    maxNumResults = Int32.Parse( Request.QueryString[ "maxNumResults" ] );
                }
                
                ArrayList generalCriteria = new ArrayList();
                ArrayList andCriteria = new ArrayList();
                ArrayList orCriteria = new ArrayList();

                // extract all the search params from the request
                // each param will be similar in form to:
                // compositeName=division&compositeType=general&compositeMustHave=true&name=division&type=String&mustHave=true&value=ford&min=&max=
                int searchParamIndex = 0;
                String searchParamKey = "searchParam" + searchParamIndex;
                while( Request.QueryString[ searchParamKey ] != null )
                {
                    String paramString = Request.QueryString[ searchParamKey ];
                    searchParamKey = "searchParam" + (++searchParamIndex);

                    CompositeSearchCriterion compositeCriterion = CompositeSearchCriterion.parse( paramString );
                    if( compositeCriterion != null )
                    {
                        switch( compositeCriterion.getType() )
                        {
                            case "general":
                            {
                                generalCriteria.Add( compositeCriterion.getSubCriteria()[ 0 ] );
                            }
                            break;

                            case "and":
                            {
                                SearchCriterion[] subCriteria = (SearchCriterion[])compositeCriterion.getSubCriteria().ToArray( new SearchCriterion().GetType() );
                                AndCriterion andCriterion = new AndCriterion();
                                andCriterion.name = compositeCriterion.getName();
                                andCriterion.criteriaArray = subCriteria;
                                andCriteria.Add( andCriterion );
                            }
                            break;

                            case "or":
                            {
                                SearchCriterion[] subCriteria = (SearchCriterion[])compositeCriterion.getSubCriteria().ToArray( new SearchCriterion().GetType() );
                                OrCriterion orCriterion = new OrCriterion();
                                orCriterion.importance = compositeCriterion.getMustHave();
                                orCriterion.criteriaArray = subCriteria;
                                orCriteria.Add( orCriterion );
                            }
                            break;
                        }
                    }
                }

                // Create the search service request
                SearchServiceRequest searchRequest = new SearchServiceRequest();
                searchRequest.criteriaArray = (SearchCriterion[])generalCriteria.ToArray( new SearchCriterion().GetType() );
                searchRequest.orCriteriaArray = (OrCriterion[])orCriteria.ToArray( new OrCriterion().GetType() );
                searchRequest.andCriteriaArray = (AndCriterion[])andCriteria.ToArray( new AndCriterion().GetType() );
                searchRequest.filterTBD = filterTBD;
                searchRequest.filterByPostalCode = filterPostalCode;
                searchRequest.postalCode = postalCode;
                searchRequest.maxNumResults = maxNumResults;

                switch( searchType )
                {
                    case "searchStyles":
                    {
                        SearchStylesRequest theRequest = new SearchStylesRequest();
                        theRequest.accountInfo = searchAccountInfo;
                        theRequest.orderAvailability = searchOrderAvailability;
                        theRequest.searchRequest = searchRequest;

                        configcompare3.kp.chrome.com.Style[] styles = configService.searchStyles( theRequest );
                        sortStyles(styles);
                        for( int i = 0; styles != null && i < styles.Length; i++ )
                        {
                            configcompare3.kp.chrome.com.Style style = styles[i];
                            String invoice = "$" + style.baseInvoice.ToString();
                            String msrp = "$" +  style.baseMsrp.ToString();
                            if (i > 0) {
                                result += ";;";
                            }
                            result += style.modelYear + "~~" + style.divisionName + "~~" + style.modelName + "~~" + style.styleName + "~~" + invoice + "~~" + msrp + "~~" + style.styleId;
                        }
                    }
                    break;

                    case "searchModels":
                    {
                        SearchModelsRequest theRequest = new SearchModelsRequest();
                        theRequest.accountInfo = searchAccountInfo;
                        theRequest.orderAvailability = searchOrderAvailability;
                        theRequest.searchRequest = searchRequest;

                        ModelSearchResult[] searchResults = configService.searchModels( theRequest );
                        for( int i = 0; searchResults != null && i < searchResults.Length; i++ ){
                            if( i > 0 ){
                                result += ";;";
                            }
                            String dateString = "";
                            Model model = searchResults[i].model;
                            if( model.lastModifiedDate != null ){
                                dateString = model.lastModifiedDate.ToShortDateString();
                            }
                            result += model.modelId + "~~" + model.modelName + "~~" + dateString;
                        }
                    }
                    break;
                }
            }
            break;

            case "findComparable":
            {
                // This search is designed to find similar vehicles to the target vehicle based on the vehicle's
                // model year, market class, body style, etc.

                bool filterTBD = false;
                bool filterPostalCode = false;
                String postalCode = Request.QueryString[ "postalCode" ];
                if( Request.QueryString[ "filterTBD" ] != null )
                    filterTBD = Boolean.Parse( Request.QueryString[ "filterTBD" ] );
                if( Request.QueryString[ "filterPostalCode" ] != null )
                    filterPostalCode = Boolean.Parse( Request.QueryString[ "filterPostalCode" ] );

                Int32 maxNumResults = -1;
                if( Request.QueryString[ "maxNumResults" ] != null )
                {
                    maxNumResults = Int32.Parse( Request.QueryString[ "maxNumResults" ] );
                }

                AccountInfo searchAccountInfo = (AccountInfo)Session[ "searchAccountInfo" ];

                String scratchListId = Request.QueryString[ "scratchListId" ];
			    ConfigurationState configState = (ConfigurationState)Session[ scratchListId ];

                // Retrieve target vehicle info so we know what to base comparable search on
                OrderAvailability orderAvailability = configState.orderAvailability;
                FullyConfiguredRequest styleRequest = new FullyConfiguredRequest();
                styleRequest.accountInfo = searchAccountInfo;
                styleRequest.configurationState = configState;
                ToggleOptionResponse toggleResponse = configService.getStyleFullyConfigured( styleRequest );
                configcompare3.kp.chrome.com.Configuration configStyle = toggleResponse.configuration;

                // now build up the search criteria
                ArrayList generalCriteria = new ArrayList();
                ArrayList orCriteria = new ArrayList();
                ArrayList andCriteria = new ArrayList();

                // only search for model year of target vehicle or newer
                SearchCriterion yearCriterion = getSearchCriterion(SearchTokenName.year, SearchImportanceType.MustHave, SearchCriterionType.NumberRange,
                        null, configStyle.style.modelYear.ToString(), null );
                generalCriteria.Add( yearCriterion );

                // only search for selected makes
                String[] chosenMakes = Request.QueryString[ "makes" ].Split( new String[]{ ";;" }, StringSplitOptions.None );
                if( chosenMakes != null && chosenMakes.Length > 0 )
                {
                    ArrayList makeCriteriaList = new ArrayList();
                    for( int i = 0; i < chosenMakes.Length; ++i )
                    {
                        SearchCriterion makeCriterion = getSearchCriterion( SearchTokenName.divisionId, SearchImportanceType.MustHave, SearchCriterionType.String,
                                chosenMakes[ i ], null, null );
                        makeCriteriaList.Add( makeCriterion );
                    }

                    // make an OrCriterion that includes all of the passed in makes (e.g. This vehicle make must = Ford or Chevy or Honda, etc.)
                    OrCriterion makeListCriterion = getOrCriterion(SearchImportanceType.MustHave, (SearchCriterion[])makeCriteriaList.ToArray(new SearchCriterion().GetType()));
                    orCriteria.Add( makeListCriterion );
                }

                // only search for vehicles with the same market class as this target vehicle
                SearchCriterion marketClassCriterion = getSearchCriterion( SearchTokenName.marketClassId, SearchImportanceType.MustHave, SearchCriterionType.String,
                        configStyle.style.marketClassId.ToString(), null, null );
                generalCriteria.Add( marketClassCriterion );

                // only search for selected vehicles with same body type as target vehicle
                ArrayList bodyTypeList = new ArrayList();
                for( int i = 0; i < configStyle.style.bodyTypes.Length; ++i )
                {
                    BodyType bodyType = configStyle.style.bodyTypes[ i ];
                    SearchCriterion bodyTypeCriterion = getSearchCriterion( SearchTokenName.bodyType, SearchImportanceType.MustHave, SearchCriterionType.String,
                            bodyType.bodyTypeId.ToString(), null, null );
                    bodyTypeList.Add( bodyTypeCriterion );
                }

                // make an OrCriterion that includes all of the body types (e.g. This vehicle body type must = Short Bed or Crew Cab Pickup, etc.)
                OrCriterion bodyCriterion = getOrCriterion(SearchImportanceType.MustHave, (SearchCriterion[])bodyTypeList.ToArray(new SearchCriterion().GetType()));
                orCriteria.Add( bodyCriterion );

                // only search for vehicles with the same number of passenger doors on target vehicle
                SearchCriterion passengerDoorsCriterion = getSearchCriterion( SearchTokenName.numberOfDoors, SearchImportanceType.MustHave, SearchCriterionType.String,
                        configStyle.style.passengerDoors.ToString(), null, null );
                generalCriteria.Add( passengerDoorsCriterion );

                // this vehicle has a meaningful wheelbase value if its market class id is contained in the list
                bool hasMeaningfulWheelbase = Array.BinarySearch( MEANINGFUL_WHEELBASE_MARKET_CLASS_IDS,
                        configStyle.style.marketClassId ) >= 0;

                // match on certain tech specs (passenger capacity, wheelbase - if truck or suv)
                TechnicalSpecification[] techSpecs = configStyle.technicalSpecifications;
                for( int i = 0; i < techSpecs.Length; ++i )
                {
                    // passenger capacity
                    if( techSpecs[ i ].titleId == PASSENGER_CAPACITY_TECH_SPEC_ID )
                    {
                        String passengerCapacity = techSpecs[ i ].value;
                        SearchCriterion passengerCapacityCriterion = getSearchCriterion( SearchTokenName.passengerCapacity, SearchImportanceType.MustHave, SearchCriterionType.TechnicalSpecificationRange,
                            null, passengerCapacity, passengerCapacity );
                        generalCriteria.Add( passengerCapacityCriterion );
                    }

                    // if this vehicle has a meaningful wheelbase, then add this to the search criteria
                    if( hasMeaningfulWheelbase && techSpecs[ i ].titleId == WHEELBASE_TECH_SPEC_ID )
                    {
                        String value = techSpecs[ i ].value;
                        double wheelbase = -1;
                        try
                        {
                            wheelbase = Double.Parse(value);
                        }
                        catch (Exception ) { }

                        // create a range that the wheelbase of search vehicles can fall within
                        if( wheelbase != -1 )
                        {
                            double min = wheelbase * (1 - VARIANCE_PERCENT);
                            double max = wheelbase * (1 + VARIANCE_PERCENT);

                            SearchCriterion wheelbaseCriterion = getSearchCriterion( SearchTokenName.wheelbase, SearchImportanceType.MustHave, SearchCriterionType.TechnicalSpecificationRange,
                                null, min.ToString(), max.ToString() );
                            generalCriteria.Add( wheelbaseCriterion );
                        }
                    }
                }

                // only search for vehicles that fall within a certain msrp price range (if it has a price)
                PriceState priceState = configStyle.configuredPriceState;
                if( priceState == PriceState.Actual || priceState == PriceState.Estimated )
                {
                    // create a range that the msrp of search vehicles can fall within
                    double min = configStyle.configuredTotalMsrp * (1 - VARIANCE_PERCENT);
                    double max = configStyle.configuredTotalMsrp * (1 + VARIANCE_PERCENT);

                    SearchCriterion wheelbaseCriterion = getSearchCriterion( SearchTokenName.msrp, SearchImportanceType.MustHave, SearchCriterionType.MoneyRange,
                        null, min.ToString(), max.ToString() );
                    generalCriteria.Add( wheelbaseCriterion );

                }

                // now create a criteria to exclude vehicles with the same model as the target vehicle
                SearchCriterion modelCriterion = getSearchCriterion( SearchTokenName.modelId, SearchImportanceType.MustNotHave, SearchCriterionType.String,
                        configStyle.style.modelId.ToString(), null, null );
                    generalCriteria.Add( modelCriterion );

                // Create the search service request
                SearchServiceRequest searchRequest = new SearchServiceRequest();
                searchRequest.criteriaArray = (SearchCriterion[])generalCriteria.ToArray(new SearchCriterion().GetType());
                searchRequest.orCriteriaArray = (OrCriterion[])orCriteria.ToArray(new OrCriterion().GetType());
                searchRequest.andCriteriaArray = (AndCriterion[])andCriteria.ToArray(new AndCriterion().GetType());
                searchRequest.filterTBD = filterTBD;
                searchRequest.filterByPostalCode = filterPostalCode;
                searchRequest.postalCode = postalCode;
                searchRequest.maxNumResults = maxNumResults;

                SearchStylesRequest thisRequest = new SearchStylesRequest();
                thisRequest.accountInfo = searchAccountInfo;
                thisRequest.orderAvailability = orderAvailability;
                thisRequest.searchRequest = searchRequest;

                configcompare3.kp.chrome.com.Style[] styles = configService.searchStyles( thisRequest );
                sortStyles( styles );
                for( int i = 0; styles != null && i < styles.Length; i++ )
                {
                    configcompare3.kp.chrome.com.Style style = styles[i];
                    String invoice = "$" + style.baseInvoice;
                    String msrp = "$" +  style.baseMsrp;
                    if (i > 0) {
                        result += ";;";
                    }
                    result += style.modelYear + "~~" + style.divisionName + "~~" + style.modelName + "~~" + style.styleName + "~~" + invoice + "~~" + msrp + "~~" + style.styleId;
                }
            }
            break;

            case "getAvailableMakes":
            {
			    AccountInfo searchAccountInfo = (AccountInfo)Session[ "searchAccountInfo" ];

                String scratchListId = Request.QueryString[ "scratchListId" ];
                String modelYear = Request.QueryString[ "year" ];
			    ConfigurationState configState = (ConfigurationState)Session[ scratchListId ];

                // retrieve all the available makes for the model year of the target vehicle
                OrderAvailability orderAvailability = configState.orderAvailability;
                FilterRules filterRules = new FilterRules();
                filterRules.orderAvailability = orderAvailability;
                DivisionsRequest divisionRequest = new DivisionsRequest();
                divisionRequest.accountInfo = searchAccountInfo;
                divisionRequest.filterRules = filterRules;
                divisionRequest.modelYear = Int32.Parse( modelYear );

                Division[] divisions = configService.getDivisions( divisionRequest );
			    for ( int i = 0; divisions != null && i < divisions.Length; i++ ) {
				    int divisionId = divisions[i].divisionId;
				    String divisionName = divisions[i].divisionName;
				    if (i > 0) {
					    result += ";;";
				    }
				    result += divisionId + "~~" + divisionName;
			    }
            }
            break;

            case "getOptionalValues":
            {
                AccountInfo accountInfo = (AccountInfo)Session[ "searchAccountInfo" ];
                initSearchDescriptorMap( accountInfo );
                String tokenName = Request.QueryString["tokenName"];
                result = getOptionalValues( tokenName );
            }
            break;
        }
    }

    private String getOptionalValues( String searchTokenName ){
        String values = "";
        SearchCriterionDescriptor descriptor = (SearchCriterionDescriptor) searchDescriptorMap[ searchTokenName ];
        if( descriptor != null && descriptor.values != null ){
            for( int i=0; i < descriptor.values.Length; i++ ){
                String choice = descriptor.values[i].id + "~~" + descriptor.values[i].value;
                values += ( values.Length == 0 ? choice : ";;" + choice );
            }
        }
        return values;
    }

    private void initSearchDescriptorMap( AccountInfo accountInfo ){
        if( searchDescriptorMap == null ){
            searchDescriptorMap = new Hashtable();
            SearchCriterionDescriptorRequest request = new SearchCriterionDescriptorRequest();
            request.accountInfo = accountInfo;
            SearchCriterionDescriptor[] descriptors = configService.getSearchCriterionDescriptors( request  );
            for( int i=0; i < descriptors.Length; i++ ){
                SearchCriterionDescriptor descriptor = descriptors[i];
                searchDescriptorMap.Add( descriptor.name.ToString(), descriptor );
            }
        }
    }

    // sorts passed in style array by model year, then by make name, then by model name
    private void sortStyles( configcompare3.kp.chrome.com.Style[] styles )
    {
        if( styles == null || styles.Length == 0 )
            return;
        Array.Sort(styles, new StyleSorter());
    }

    private void setAccountInfo(String localeString)
    {
        String country = "US";
        String language = "en";

        if (localeString == "enCA")
            country = "CA";
        else if (localeString == "frCA")
        {
            country = "CA";
            language = "fr";
        }

        Locale configLocale = new Locale();
        configLocale.country = country;
        configLocale.language = language;

        configcompare3.kp.chrome.com.Locale compareLocale = new configcompare3.kp.chrome.com.Locale();
        compareLocale.country = country;
        compareLocale.language = language;

        configcompare3.kp.chrome.com.Locale searchLocale = new configcompare3.kp.chrome.com.Locale();
        searchLocale.country = country;
        searchLocale.language = language;

        //set config accountInfo
        AccountInfo configAccountInfo = new AccountInfo();
        configAccountInfo.accountNumber = accountNumber;
        configAccountInfo.accountSecret = accountSecret;
        configAccountInfo.locale = configLocale;
        Session["configAccountInfo"] = configAccountInfo;

        //set compare accountInfo
        configcompare3.kp.chrome.com.AccountInfo compareAccountInfo = new configcompare3.kp.chrome.com.AccountInfo();
        compareAccountInfo.accountNumber = accountNumber;
        compareAccountInfo.accountSecret = accountSecret;
        compareAccountInfo.locale = compareLocale;
        Session["compareAccountInfo"] = compareAccountInfo;

        //set search accountInfo
        configcompare3.kp.chrome.com.AccountInfo searchAccountInfo = new configcompare3.kp.chrome.com.AccountInfo();
        searchAccountInfo.accountNumber = accountNumber;
        searchAccountInfo.accountSecret = accountSecret;
        searchAccountInfo.locale = searchLocale;
        Session["searchAccountInfo"] = searchAccountInfo; 
    }

    private SearchCriterion getSearchCriterion(SearchTokenName name, SearchImportanceType importance, SearchCriterionType type,
                        String value, String min, String max)
    {
        SearchCriterion criterion = new SearchCriterion();
        criterion.name = name;
        criterion.importance = importance;
        criterion.type = type;
        criterion.value = value;
        criterion.min = min;
        criterion.max = max;

        return criterion;
    }

    private OrCriterion getOrCriterion(SearchImportanceType importance, SearchCriterion[] subCriteria )
    {
        OrCriterion orCriterion = new OrCriterion();
        orCriterion.importance = importance;
        orCriterion.criteriaArray = subCriteria;

        return orCriterion;
    }
}

class StyleSorter : IComparer
{
    public int Compare( Object a, Object b )
    {
        configcompare3.kp.chrome.com.Style styleA = (configcompare3.kp.chrome.com.Style)a;
        configcompare3.kp.chrome.com.Style styleB = (configcompare3.kp.chrome.com.Style)b;

        int yearA = styleA.modelYear;
        int yearB = styleB.modelYear;

        if( yearA < yearB )
            return -1;
        else if( yearA > yearB )
            return 1;
        else
        {
            String makeA = styleA.divisionName;
            String makeB = styleB.divisionName;

            int compare = String.Compare(makeA, makeB, true);
            if( compare == 0 )
                return String.Compare( styleA.modelName, styleB.modelName, true );
            else
                return compare;
        }
    }
}


class CompositeSearchCriterion
{
    public SearchTokenName name;
    public String type;
    public SearchImportanceType mustHave;
    public ArrayList subCriteria = new ArrayList();

    CompositeSearchCriterion(SearchTokenName name, String type, SearchImportanceType mustHave)
    {
        this.name = name;
        this.type = type;
        this.mustHave = mustHave;
    }

    public SearchTokenName getName()
    {
        return name;
    }

    public String getType()
    {
        return type;
    }

    public SearchImportanceType getMustHave()
    {
        return mustHave;
    }

    public void addCriterion(SearchCriterion criterion)
    {
        subCriteria.Add(criterion);
    }

    public ArrayList getSubCriteria()
    {
        return subCriteria;
    }

    // param string should be of form:
    // compositeName=orCrit&compositeType=or&compositeMustHave=true&name=airbagSideType&type=String&mustHave=true&value=sbs&min=&max=;;&name=hasMoonRoof&type=Boolean&mustHave=true&value=true&min=&max=
    public static CompositeSearchCriterion parse(String paramString)
    {
        CompositeSearchCriterion criterion = null;
        SearchTokenName compositeName;
        String compositeType = "";
        SearchImportanceType mustHave;

        String[] criteria = paramString.Split(new String[] { ";;" }, StringSplitOptions.None );    // divide into subcriteria
        for( int i = 0; i < criteria.Length; ++i )    // process each subcriteria
        {
            Hashtable attributeMap = parseAttributes( criteria[ i ] );

            if( i == 0 )
            {
                compositeType = (String)attributeMap["compositeType"];
                compositeName = (SearchTokenName)convertToType( new SearchTokenName().GetType(), (String)attributeMap["compositeName"]);
                
                mustHave = Boolean.Parse( (String)attributeMap[ "compositeMustHave" ] ) ? SearchImportanceType.MustHave : SearchImportanceType.MustNotHave;

                criterion = new CompositeSearchCriterion( compositeName, compositeType, mustHave );
            }

            SearchCriterion subCriterion = createSearchCriterion( attributeMap );
            if( subCriterion != null )
                criterion.addCriterion( subCriterion );
        }

        return criterion;
    }

    // takes a string of form key1=value1&key2=value2 and returns a map of the form: key1 -> value1, etc.
    static Hashtable parseAttributes(String attributeString)
    {
        Hashtable attributeMap = new Hashtable();
        String[] attributes = attributeString.Split( '&' );
        for( int i = 0; i < attributes.Length; ++i )
        {
            String[] values = attributes[ i ].Split( '=' );
            if( values.Length == 2 )
            {
                attributeMap.Add( values[ 0 ], values[ 1 ] );
            }
        }

        return attributeMap;
    }

    static SearchCriterion createSearchCriterion(Hashtable attributes)
    {
        SearchCriterion criterion = null;

        SearchTokenName name = (SearchTokenName)convertToType(new SearchTokenName().GetType(), (String)attributes["name"]);
        SearchCriterionType type = (SearchCriterionType)convertToType(new SearchCriterionType().GetType(), (String)attributes["type"]);
        SearchImportanceType importance = (String)attributes["mustHave"] == "true" ? SearchImportanceType.MustHave : SearchImportanceType.MustNotHave;
        String value = attributes.ContainsKey("value") && ((String)attributes["value"]).Length > 0 ? (String)attributes["value"] : null;
        String min = attributes.ContainsKey("min") && ((String)attributes["min"]).Length > 0  ? (String)attributes["min"] : null;
        String max = attributes.ContainsKey("max") && ((String)attributes["max"]).Length > 0  ? (String)attributes["max"] : null;

        criterion = new SearchCriterion();
        criterion.name = name;
        criterion.importance = importance;
        criterion.type = type;
        criterion.value = value;
        criterion.min = min;
        criterion.max = max;
        
        return criterion;
    }

    static object convertToType(Type type, String target)
    {
        Object returnObject = null;
        System.Reflection.FieldInfo field = type.GetField(target);
        if (field != null)
            returnObject = field.GetValue(null);
        return returnObject;
    }
}