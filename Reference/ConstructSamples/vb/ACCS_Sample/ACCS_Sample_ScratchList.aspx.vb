imports configcompare3.kp.chrome.com

Partial Class ACCS_Sample_ScratchList
    Inherits System.Web.UI.Page

    protected Dim configService as AutomotiveConfigCompareService3 = New configcompare3.kp.chrome.com.AutomotiveConfigCompareService3
    protected result as String = String.Empty

    Sub Page_Load(ByVal Sender As System.Object, ByVal e As System.EventArgs)
    
        dim cmd as String = Request.QueryString("cmd")

        result = "fail"

        Select Case cmd
        
            case "add"
                dim styleId as String = Request.QueryString( "styleId" )
                dim accountInfo as AccountInfo = Session( "configAccountInfo" )
                dim orderAvailability as OrderAvailability = Session( "configOrderAvailability" )
                dim returnParams as ReturnParameters = new ReturnParameters()

                Dim styleRequest As ConfigurationByStyleIdRequest = New ConfigurationByStyleIdRequest
                styleRequest.accountInfo = accountInfo
                styleRequest.orderAvailability = orderAvailability
                styleRequest.styleId = Int32.Parse(styleId)
                styleRequest.returnParameters = returnParams

                Dim config As configcompare3.kp.chrome.com.ConfigurationElement = configService.getConfigurationByStyleId(styleRequest)
                dim scratchListId as string = styleId + "|" + DateTime.Now.ToBinary().ToString()
                Session(scratchListId) = config.configuration.style.configurationState
                result = scratchListId

            case "remove"
                dim scratchListId as String = Request.QueryString( "scratchListId" )
                Session.Remove( scratchListId )
                result = "success"
            
        end select
    end sub
end class
