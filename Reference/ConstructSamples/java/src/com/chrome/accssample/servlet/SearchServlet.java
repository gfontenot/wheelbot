package com.chrome.accssample.servlet;

import com.chrome.kp.configcompare3.*;
import com.chrome.kp.configcompare3.Locale;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletException;
import java.io.IOException;
import java.io.PrintWriter;
import java.rmi.RemoteException;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: gene.nguyen
 * Date: Apr 13, 2007
 * Time: 4:37:27 PM
 */
public class SearchServlet extends AccsServlet {

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
    private static final int[] MEANINGFUL_WHEELBASE_MARKET_CLASS_IDS = new int[]
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

    private static final double VARIANCE_PERCENT = 0.05;
    private static final int PASSENGER_CAPACITY_TECH_SPEC_ID = 8;
    private static final int WHEELBASE_TECH_SPEC_ID = 301;
    private static HashMap searchDescriptorMap = null;

    public void doGet( HttpServletRequest request, HttpServletResponse response ) throws IOException, ServletException
    {
		response.setContentType( "text/html" );
		PrintWriter out = response.getWriter();

		HttpSession session = request.getSession();

		//get config service
		AutomotiveConfigCompareService3Port configService = getConfigCompareService();

		//get data request type
		String selectorRequest = request.getParameter( "data" );
		String returnString = "";
		//============================================get Locale
		if( selectorRequest.equalsIgnoreCase( "locale" ) )
        {
			//get config locale
			Locale configLocale = new Locale();
			configLocale.setCountry( "US" );
			configLocale.setLanguage( "en" );

			String queryLocale = request.getParameter( "locale" );
			if ( queryLocale.equalsIgnoreCase( "enCA" ) )  {
				configLocale.setCountry( "CA" );
				configLocale.setLanguage( "en" );
			}
			else if ( queryLocale.equalsIgnoreCase( "frCA" ) ) {
				configLocale.setCountry( "CA" );
				configLocale.setLanguage( "fr" );
			}

			// set accountInfo for config
			AccountInfo configAccountInfo = getAccountInfo( session );
			configAccountInfo.setLocale( configLocale );

			session.setAttribute( "configAccountInfo", configAccountInfo );

			// set accountInfo for compare
			Locale compareLocale = new Locale();
			compareLocale.setCountry( "US" );
			compareLocale.setLanguage( "en" );

			if ( queryLocale.equalsIgnoreCase( "enCA" ) )  {
				compareLocale.setCountry( "CA" );
				compareLocale.setLanguage( "en" );
			}
			else if ( queryLocale.equalsIgnoreCase( "frCA" ) ) {
				compareLocale.setCountry( "CA" );
				compareLocale.setLanguage( "fr" );
			}

            // get/set compare account info
			AccountInfo compareAccountInfo = getAccountInfo( session );
			compareAccountInfo.setLocale( compareLocale );

			session.setAttribute( "compareAccountInfo", compareAccountInfo );

            // set accountInfo for search
			Locale searchLocale = new Locale();
			searchLocale.setCountry( "US" );
			searchLocale.setLanguage( "en" );

			if ( queryLocale.equalsIgnoreCase( "enCA" ) )  {
				searchLocale.setCountry( "CA" );
				searchLocale.setLanguage( "en" );
			}
			else if ( queryLocale.equalsIgnoreCase( "frCA" ) ) {
				searchLocale.setCountry( "CA" );
				searchLocale.setLanguage( "fr" );
			}

			// get/set config account info
			AccountInfo searchAccountInfo = getAccountInfo( session );
			searchAccountInfo.setLocale( searchLocale );

			session.setAttribute( "searchAccountInfo", searchAccountInfo );
        }
		//============================================get orderAvailability
		else if( selectorRequest.equalsIgnoreCase( "orderAvailability" ) )
        {
			String orderAvailability = request.getParameter( "orderAvailability" );

			// get/set config orderAvailability
			OrderAvailability configOrderAvailability = OrderAvailability.Fleet;
			if( orderAvailability.equalsIgnoreCase( "Retail" ) )
				configOrderAvailability = OrderAvailability.Retail;

			session.setAttribute( "configOrderAvailability", configOrderAvailability );

			// get/set compare orderAvailability
			OrderAvailability compareOrderAvailability = OrderAvailability.Fleet;
			if( orderAvailability.equalsIgnoreCase( "Retail" ) )
				compareOrderAvailability = OrderAvailability.Retail;

			session.setAttribute( "compareOrderAvailability", compareOrderAvailability );

            // get/set searc orderAvailability
			OrderAvailability searchOrderAvailability = OrderAvailability.Fleet;
			if( orderAvailability.equalsIgnoreCase( "Retail" ) )
				searchOrderAvailability = OrderAvailability.Retail;

			session.setAttribute( "searchOrderAvailability", searchOrderAvailability );
        }
        //============================================get orderAvailability
		else if( selectorRequest.equalsIgnoreCase( "getSearchCriteria" ) )
        {
            AccountInfo searchAccountInfo = (AccountInfo)session.getAttribute( "searchAccountInfo" );

            StringBuffer buffer = new StringBuffer();
            
            // construct the request to retrieve all available search criteria
            SearchCriterionDescriptor descriptors[] = configService.getSearchCriterionDescriptors( searchAccountInfo );
            for( int i = 0; i < descriptors.length; ++i )
            {
                if( i > 0 )
                    buffer.append( ";;" );  // separator between descriptors

                buffer.append( descriptors[ i ].getName() + "~~"// name
                        + descriptors[ i ].getType() + "~~" // type
                        + (descriptors[ i ].getMin() != null ? descriptors[ i ].getMin() : "" ) + "~~" // min
                        + (descriptors[ i ].getMax() != null ? descriptors[ i ].getMax() : "" ) + "~~"// max
                        + (descriptors[ i ].getUnit() != null ? descriptors[ i ].getUnit().getValue() : "" ) // unit
                        );
            }

            out.print( buffer.toString() );
        }
        //============================================do search
		else if( selectorRequest.equalsIgnoreCase( "getSearchResults" ) )
        {
            AccountInfo searchAccountInfo = (AccountInfo)session.getAttribute( "searchAccountInfo" );
            OrderAvailability searchOrderAvailability = (OrderAvailability)session.getAttribute( "searchOrderAvailability" );
            String searchType = request.getParameter( "searchType" );
            boolean filterTBD = false;
            boolean filterPostalCode = false;
            String postalCode = request.getParameter( "postalCode" );
            if( request.getParameter( "filterTBD" ) != null )
                filterTBD = Boolean.valueOf( request.getParameter( "filterTBD" ) ).booleanValue();
            if( request.getParameter( "filterPostalCode" ) != null )
                filterPostalCode = Boolean.valueOf( request.getParameter( "filterPostalCode" ) ).booleanValue();

            Integer maxNumResults = null;
            if( request.getParameter( "maxNumResults" ) != null )
            {
                maxNumResults = Integer.valueOf( request.getParameter( "maxNumResults" ) );
            }
            
            ArrayList generalCriteria = new ArrayList();
            ArrayList andCriteria = new ArrayList();
            ArrayList orCriteria = new ArrayList();

            // extract all the search params from the request
            // each param will be similar in form to:
            // compositeName=division&compositeType=general&compositeMustHave=true&name=division&type=String&mustHave=true&value=ford&min=&max=
            int searchParamIndex = 0;
            String searchParamKey = "searchParam" + searchParamIndex;
            while( request.getParameter( searchParamKey ) != null )
            {
                String paramString = request.getParameter( searchParamKey );
                searchParamKey = "searchParam" + (++searchParamIndex);

                CompositeSearchCriterion compositeCriterion = CompositeSearchCriterion.parse( paramString );
                if( compositeCriterion != null )
                {
                    if( compositeCriterion.getType().equals( "general" ) )
                    {
                        generalCriteria.add( compositeCriterion.getSubCriteria().get( 0 ) );
                    }
                    else if( compositeCriterion.getType().equals( "and" ) )
                    {
                        SearchCriterion subCriteria[] = (SearchCriterion[])compositeCriterion.getSubCriteria().toArray( new SearchCriterion[ compositeCriterion.getSubCriteria().size() ] );
                        AndCriterion andCriterion = new AndCriterion( compositeCriterion.getName(), subCriteria );
                        andCriteria.add( andCriterion );
                    }
                    else if( compositeCriterion.getType().equals( "or" ) )
                    {
                        SearchCriterion subCriteria[] = (SearchCriterion[])compositeCriterion.getSubCriteria().toArray( new SearchCriterion[ compositeCriterion.getSubCriteria().size() ] );
                        OrCriterion orCriterion = new OrCriterion( compositeCriterion.getMustHave(), subCriteria );
                        orCriteria.add( orCriterion );
                    }
                }
            }

            // Create the search service request
            SearchServiceRequest searchRequest = new SearchServiceRequest(
                    (SearchCriterion[])generalCriteria.toArray( new SearchCriterion[ generalCriteria.size() ] ),
                    (OrCriterion[])orCriteria.toArray( new OrCriterion[ orCriteria.size() ] ),
                    (AndCriterion[])andCriteria.toArray( new AndCriterion[ andCriteria.size() ] ),
                    filterTBD, filterPostalCode, postalCode, maxNumResults );

            if( searchType.equals( "searchStyles") )
            {
                Style styles[] = configService.searchStyles( searchAccountInfo, searchOrderAvailability, searchRequest );
                sortStyles( styles );
                for( int i = 0; styles != null && i < styles.length; i++ )
                {
                    Style style = styles[i];
                    String invoice = "$" + style.getBaseInvoice();
                    String msrp = "$" +  style.getBaseMsrp();
                    if (i > 0) {
                        returnString += ";;";
                    }
                    returnString += style.getModelYear() + "~~" + style.getDivisionName() + "~~" + style.getModelName() + "~~" + style.getStyleName() + "~~" + invoice + "~~" + msrp + "~~" + style.getStyleId();
                }
            }
            else if( searchType.equals( "searchModels") )
            {
                ModelSearchResult[] searchResults = configService.searchModels( searchAccountInfo, searchOrderAvailability, searchRequest );
                for( int i = 0; searchResults != null && i < searchResults.length; i++ ){
                    if( i > 0 ){
                        returnString += ";;";
                    }
                    String dateString = "";
                    Model model = searchResults[i].getModel();
                    if( model.getLastModifiedDate() != null ){
                        dateString = model.getLastModifiedDate().getTime().toString();
                    }
                    returnString += model.getModelId() + "~~" + model.getModelName() + "~~" +  dateString;
                }
            }

            out.print( returnString );
        }
        else if( selectorRequest.equalsIgnoreCase( "findComparable" ) )
        {
            // This search is designed to find similar vehicles to the target vehicle based on the vehicle's
            // model year, market class, body style, etc.

            boolean filterTBD = false;
            boolean filterPostalCode = false;
            String postalCode = request.getParameter( "postalCode" );
            if( request.getParameter( "filterTBD" ) != null )
                filterTBD = Boolean.valueOf( request.getParameter( "filterTBD" ) ).booleanValue();
            if( request.getParameter( "filterPostalCode" ) != null )
                filterPostalCode = Boolean.valueOf( request.getParameter( "filterPostalCode" ) ).booleanValue();

            Integer maxNumResults = null;
            if( request.getParameter( "maxNumResults" ) != null )
            {
                maxNumResults = Integer.valueOf( request.getParameter( "maxNumResults" ) );
            }

            AccountInfo searchAccountInfo = (AccountInfo)session.getAttribute( "searchAccountInfo" );

            String scratchListId = request.getParameter( "scratchListId" );
			ConfigurationState configState = (ConfigurationState) session.getAttribute( scratchListId );

            // Retrieve target vehicle info so we know what to base comparable search on
            OrderAvailability orderAvailability = configState.getOrderAvailability();
            ToggleOptionResponse toggleResponse = configService.getStyleFullyConfigured( searchAccountInfo, configState, null );
            Configuration configStyle = toggleResponse.getConfiguration();

            // now build up the search criteria
            ArrayList generalCriteria = new ArrayList();
            ArrayList orCriteria = new ArrayList();
            ArrayList andCriteria = new ArrayList();

            // only search for model year of target vehicle or newer
            SearchCriterion yearCriterion = new SearchCriterion( SearchTokenName.year, SearchImportanceType.MustHave, SearchCriterionType.NumberRange,
                    null, String.valueOf( configStyle.getStyle().getModelYear() ), null );
            generalCriteria.add( yearCriterion );

            // only search for selected makes
            String chosenMakes[] = request.getParameter( "makes" ).split( ";;" );
            if( chosenMakes != null && chosenMakes.length > 0 )
            {
                ArrayList makeCriteriaList = new ArrayList();
                for( int i = 0; i < chosenMakes.length; ++i )
                {
                    SearchCriterion makeCriterion = new SearchCriterion( SearchTokenName.divisionId, SearchImportanceType.MustHave, SearchCriterionType.String,
                            chosenMakes[ i ], null, null );
                    makeCriteriaList.add( makeCriterion );
                }

                // make an OrCriterion that includes all of the passed in makes (e.g. This vehicle make must = Ford or Chevy or Honda, etc.)
                OrCriterion makeListCriterion = new OrCriterion( SearchImportanceType.MustHave, (SearchCriterion[])makeCriteriaList.toArray( new SearchCriterion[ makeCriteriaList.size() ] ) );
                orCriteria.add( makeListCriterion );
            }

            // only search for vehicles with the same market class as this target vehicle
            SearchCriterion marketClassCriterion = new SearchCriterion( SearchTokenName.marketClassId, SearchImportanceType.MustHave, SearchCriterionType.String,
                    String.valueOf( configStyle.getStyle().getMarketClassId() ), null, null );
            generalCriteria.add( marketClassCriterion );

            // only search for selected vehicles with same body type as target vehicle
            ArrayList bodyTypeList = new ArrayList();
            for( int i = 0; i < configStyle.getStyle().getBodyTypes().length; ++i )
            {
                BodyType bodyType = configStyle.getStyle().getBodyTypes()[ i ];
                SearchCriterion bodyTypeCriterion = new SearchCriterion( SearchTokenName.bodyType, SearchImportanceType.MustHave, SearchCriterionType.String,
                        String.valueOf( bodyType.getBodyTypeId() ), null, null );
                bodyTypeList.add( bodyTypeCriterion );
            }

            // make an OrCriterion that includes all of the body types (e.g. This vehicle body type must = Short Bed or Crew Cab Pickup, etc.)
            OrCriterion bodyTypeCriterion = new OrCriterion( SearchImportanceType.MustHave, (SearchCriterion[])bodyTypeList.toArray( new SearchCriterion[ bodyTypeList.size() ] ) );
            orCriteria.add( bodyTypeCriterion );

            // only search for vehicles with the same number of passenger doors on target vehicle
            SearchCriterion passengerDoorsCriterion = new SearchCriterion( SearchTokenName.numberOfDoors, SearchImportanceType.MustHave, SearchCriterionType.String,
                    String.valueOf( configStyle.getStyle().getPassengerDoors() ), null, null );
            generalCriteria.add( passengerDoorsCriterion );

            // this vehicle has a meaningful wheelbase value if its market class id is contained in the list
            boolean hasMeaningfulWheelbase = Arrays.binarySearch( MEANINGFUL_WHEELBASE_MARKET_CLASS_IDS,
                    configStyle.getStyle().getMarketClassId() ) >= 0;

            // match on certain tech specs (passenger capacity, wheelbase - if truck or suv)
            TechnicalSpecification techSpecs[] = configStyle.getTechnicalSpecifications();
            for( int i = 0; i < techSpecs.length; ++i )
            {
                // passenger capacity
                if( techSpecs[ i ].getTitleId() == PASSENGER_CAPACITY_TECH_SPEC_ID )
                {
                    String passengerCapacity = techSpecs[ i ].getValue();
                    SearchCriterion passengerCapacityCriterion = new SearchCriterion( SearchTokenName.passengerCapacity, SearchImportanceType.MustHave, SearchCriterionType.TechnicalSpecificationRange,
                        null, passengerCapacity, passengerCapacity );
                    generalCriteria.add( passengerCapacityCriterion );
                }

                // if this vehicle has a meaningful wheelbase, then add this to the search criteria
                if( hasMeaningfulWheelbase && techSpecs[ i ].getTitleId() == WHEELBASE_TECH_SPEC_ID )
                {
                    String value = techSpecs[ i ].getValue();
                    Double wheelbase = null;
                    try
                    {
                        wheelbase = Double.valueOf( value );
                    }
                    catch( NumberFormatException nfe ){}

                    // create a range that the wheelbase of search vehicles can fall within
                    if( wheelbase != null )
                    {
                        double min = wheelbase.doubleValue() * (1 - VARIANCE_PERCENT);
                        double max = wheelbase.doubleValue() * (1 + VARIANCE_PERCENT);

                        SearchCriterion wheelbaseCriterion = new SearchCriterion( SearchTokenName.wheelbase, SearchImportanceType.MustHave, SearchCriterionType.TechnicalSpecificationRange,
                            null, String.valueOf( min ), String.valueOf( max ) );
                        generalCriteria.add( wheelbaseCriterion );
                    }
                }
            }

            // only search for vehicles that fall within a certain msrp price range (if it has a price)
            PriceState priceState = configStyle.getConfiguredPriceState();
            if( priceState == PriceState.Actual || priceState == PriceState.Estimated )
            {
                // create a range that the msrp of search vehicles can fall within
                double min = configStyle.getConfiguredTotalMsrp() * (1 - VARIANCE_PERCENT);
                double max = configStyle.getConfiguredTotalMsrp() * (1 + VARIANCE_PERCENT);

                SearchCriterion wheelbaseCriterion = new SearchCriterion( SearchTokenName.msrp, SearchImportanceType.MustHave, SearchCriterionType.MoneyRange,
                    null, String.valueOf( min ), String.valueOf( max ) );
                generalCriteria.add( wheelbaseCriterion );

            }

            // now create a criteria to exclude vehicles with the same model as the target vehicle
            SearchCriterion modelCriterion = new SearchCriterion( SearchTokenName.modelId, SearchImportanceType.MustNotHave, SearchCriterionType.String,
                    String.valueOf( configStyle.getStyle().getModelId() ), null, null );
                generalCriteria.add( modelCriterion );

            // Create the search service request
            SearchServiceRequest searchRequest = new SearchServiceRequest(
                    (SearchCriterion[])generalCriteria.toArray( new SearchCriterion[ generalCriteria.size() ] ),
                    (OrCriterion[])orCriteria.toArray( new OrCriterion[ orCriteria.size() ] ),
                    (AndCriterion[])andCriteria.toArray( new AndCriterion[ andCriteria.size() ] ),
                    filterTBD, filterPostalCode, postalCode, maxNumResults );

            Style styles[] = configService.searchStyles( searchAccountInfo, orderAvailability, searchRequest );
            sortStyles( styles );
            for( int i = 0; styles != null && i < styles.length; i++ )
            {
                Style style = styles[i];
                String invoice = "$" + style.getBaseInvoice();
                String msrp = "$" +  style.getBaseMsrp();
                if (i > 0) {
                    returnString += ";;";
                }
                returnString += style.getModelYear() + "~~" + style.getDivisionName() + "~~" + style.getModelName() + "~~" + style.getStyleName() + "~~" + invoice + "~~" + msrp + "~~" + style.getStyleId();
            }
            out.print( returnString );
        }
        else if( selectorRequest.equalsIgnoreCase( "getAvailableMakes" ) )
        {
			AccountInfo searchAccountInfo = (AccountInfo)session.getAttribute( "searchAccountInfo" );

            String scratchListId = request.getParameter( "scratchListId" );
            String modelYear = request.getParameter( "year" );
			ConfigurationState configState = (ConfigurationState) session.getAttribute( scratchListId );

            // retrieve all the available makes for the model year of the target vehicle
            OrderAvailability orderAvailability = configState.getOrderAvailability();

            Division[] divisions = configService.getDivisions( searchAccountInfo, Integer.parseInt( modelYear ), createFilterRules(orderAvailability) );
			for ( int i = 0; divisions != null && i < divisions.length; i++ ) {
				int divisionId = divisions[i].getDivisionId();
				String divisionName = divisions[i].getDivisionName();
				if (i > 0) {
					returnString += ";;";
				}
				returnString += divisionId + "~~" + divisionName;
			}
			out.print( returnString );			
        } else if ( selectorRequest.equalsIgnoreCase( "getOptionalValues" ) ){
            initSearchDescriptorMap( configService, getAccountInfo( session ) );
            String tokenName = request.getParameter( "tokenName" );
            returnString = getOptionalValues( tokenName );
            out.print( returnString );
        }
    }

    // sorts passed in style array by model year, then by make name, then by model name
    private void sortStyles( Style styles[] )
    {
        if( styles == null || styles.length == 0 )
            return;
        
        Arrays.sort( styles, new Comparator()
        {
            public int compare( Object a, Object b )
            {
                Style styleA = (Style)a;
                Style styleB = (Style)b;

                int yearA = styleA.getModelYear();
                int yearB = styleB.getModelYear();

                if( yearA < yearB )
                    return -1;
                else if( yearA > yearB )
                    return 1;
                else
                {
                    String makeA = styleA.getDivisionName();
                    String makeB = styleB.getDivisionName();

                    int compare = makeA.compareToIgnoreCase( makeB );
                    if( compare == 0 )
                        return styleA.getModelName().compareToIgnoreCase( styleB.getModelName() );
                    else
                        return compare;
                }
            }
        }
        );
    }

    private FilterRules createFilterRules( OrderAvailability availability ){
        FilterRules filterRules = new FilterRules();
        filterRules.setOrderAvailability( availability );
        return filterRules;
    }

    private String getOptionalValues( String searchTokenName ){
        String values = "";
        SearchCriterionDescriptor descriptor = (SearchCriterionDescriptor) searchDescriptorMap.get( searchTokenName );
        if( descriptor != null && descriptor.getValues() != null ){
            for( int i=0; i < descriptor.getValues().length; i++ ){
                String choice = descriptor.getValues()[i].getId() + "~~" + descriptor.getValues()[i].getValue();
                values += ( values.length() == 0 ? choice : ";;" + choice );
            }
        }
        return values;
    }

    private void initSearchDescriptorMap( AutomotiveConfigCompareService3Port service, AccountInfo accountInfo ) throws RemoteException {
        if( searchDescriptorMap == null ){
            searchDescriptorMap = new HashMap();
            SearchCriterionDescriptor[] descriptors = service.getSearchCriterionDescriptors( accountInfo );
            for( int i=0; i < descriptors.length; i++ ){
                SearchCriterionDescriptor descriptor = descriptors[i];
                searchDescriptorMap.put( descriptor.getName().getValue(), descriptor );
            }
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

    public void addCriterion( SearchCriterion criterion )
    {
        subCriteria.add( criterion );
    }

    public ArrayList getSubCriteria()
    {
        return subCriteria;
    }

    // param string should be of form:
    // compositeName=orCrit&compositeType=or&compositeMustHave=true&name=airbagSideType&type=String&mustHave=true&value=sbs&min=&max=;;&name=hasMoonRoof&type=Boolean&mustHave=true&value=true&min=&max=
    public static CompositeSearchCriterion parse( String paramString )
    {
        CompositeSearchCriterion criterion = null;
        SearchTokenName compositeName = null;
        String compositeType = "";
        SearchImportanceType mustHave = null;

        String criteria[] = paramString.split( ";;" );    // divide into subcriteria
        for( int i = 0; i < criteria.length; ++i )    // process each subcriteria
        {
            Map attributeMap = parseAttributes( criteria[ i ] );

            if( i == 0 )
            {
                compositeType = (String)attributeMap.get( "compositeType" );
                compositeName = SearchTokenName.fromString( (String)attributeMap.get( "compositeName" ) );
                
                mustHave = Boolean.valueOf( (String)attributeMap.get( "compositeMustHave" ) ).booleanValue() ? SearchImportanceType.MustHave : SearchImportanceType.MustNotHave;

                criterion = new CompositeSearchCriterion( compositeName, compositeType, mustHave );
            }

            SearchCriterion subCriterion = createSearchCriterion( attributeMap );
            if( subCriterion != null )
                criterion.addCriterion( subCriterion );
        }

        return criterion;
    }

    // takes a string of form key1=value1&key2=value2 and returns a map of the form: key1 -> value1, etc.
    static Map parseAttributes( String attributeString )
    {
        HashMap attributeMap = new HashMap();
        String attributes[] = attributeString.split( "&" );
        for( int i = 0; i < attributes.length; ++i )
        {
            String values[] = attributes[ i ].split( "=" );
            if( values.length == 2 )
            {
                attributeMap.put( values[ 0 ], values[ 1 ] );
            }
        }

        return attributeMap;
    }

    static SearchCriterion createSearchCriterion( Map attributes )
    {
        SearchCriterion criterion = null;

        SearchTokenName name = SearchTokenName.fromString( (String)attributes.get( "name" ) );
        SearchCriterionType type = SearchCriterionType.fromString( (String)attributes.get( "type" ) );
        SearchImportanceType importance = ((String)attributes.get( "mustHave" )).equals( "true" ) ? SearchImportanceType.MustHave : SearchImportanceType.MustNotHave;
        String value = (String)attributes.get( "value" );
        String min = (String)attributes.get( "min" );
        String max = (String)attributes.get( "max" );

        criterion = new SearchCriterion( name, importance, type, value, min, max );

        return criterion;
    }

}
