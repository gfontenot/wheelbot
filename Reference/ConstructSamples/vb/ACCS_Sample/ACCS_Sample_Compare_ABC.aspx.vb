
imports configcompare3.kp.chrome.com

Partial Class ACCS_Sample_Compare_ABC
    Inherits System.Web.UI.Page
        Protected compareService As AutomotiveConfigCompareService3 = New configcompare3.kp.chrome.com.AutomotiveConfigCompareService3

    Sub Page_Load(ByVal Sender As System.Object, ByVal e As System.EventArgs)
        
        ' get account info
        dim accountInfo as AccountInfo = Session( "compareAccountInfo" )

        ' get ids
        dim primaryScratchListId as String = Request.QueryString( "primaryScratchListId" )
        dim primaryStyleState as ConfigurationState = Session( primaryScratchListId )

        ' get chromeStyleState for each id
        dim scratchListIds as String() = Request.QueryString( "scratchListIds" ).Split(new String() { "~~" }, StringSplitOptions.None)
        dim comparisonStateList as ArrayList = new ArrayList()
        
        dim i as Integer
        for i = 0 to scratchListIds.Length - 1
            dim chromeStyleState as ConfigurationState = Session( scratchListIds(i))
            comparisonStateList.Add(chromeStyleState)
        next i

        dim compareStates as ConfigurationState() = comparisonStateList.ToArray(new ConfigurationState().GetType())

        ' finally, do advantage based compare
        dim abcRequest as AdvantageBasedComparisonRequest = new AdvantageBasedComparisonRequest()
        abcRequest.accountInfo = accountInfo
        abcRequest.ruleSetName = "chromerules"
        abcRequest.pivotConfigurationState = primaryStyleState
        abcRequest.comparisonConfigurationStates = compareStates

        dim advantageCompareResult as AdvantageBasedComparison = compareService.compareAdvantages(abcRequest)
        
        Session( "compareResult" ) = advantageCompareResult
        Session( "scratchListIds" ) = primaryScratchListId + "~~" + Request.QueryString( "scratchListIds" )
    end sub
end class
