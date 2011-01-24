imports configcompare3.kp.chrome.com

Partial Class ACCS_Sample_Compare_SBS
    Inherits System.Web.UI.Page

    Protected compareService As AutomotiveConfigCompareService3 = New configcompare3.kp.chrome.com.AutomotiveConfigCompareService3

    Sub Page_Load(ByVal Sender As System.Object, ByVal e As System.EventArgs)
        
        ' get attributes
        dim accountInfo as AccountInfo = Session( "compareAccountInfo" )
        dim scratchListIds as String() = Request.QueryString("scratchListIds").Split(new String() { "~~" }, StringSplitOptions.None )

        dim allStyleStates( scratchListIds.Length ) as ConfigurationState
        
        ' get chromeStyleState for each id
        dim i as Integer
        for i = 0 to scratchListIds.Length - 1
            dim chromeStyleState as ConfigurationState = Session( scratchListIds(i) )
            allStyleStates(i) = chromeStyleState
        next i

        ' get category Ids
        dim catDefRequest as CategoryDefinitionsRequest = new CategoryDefinitionsRequest
        catDefRequest.accountInfo = accountInfo
        dim categoryDefinitions as CategoryDefinition() = compareService.getCategoryDefinitions(catDefRequest)
        dim categoryIds(categoryDefinitions.Length) as Integer
        for i = 0 to categoryDefinitions.Length - 1
            categoryIds(i) = categoryDefinitions(i).categoryId
        next i

        ' get tech. specs Ids
        dim techSpecRequest as TechnicalSpecificationDefinitionsRequest = new TechnicalSpecificationDefinitionsRequest
        techSpecRequest.accountInfo = accountInfo
        dim techSpecDefinitions as TechnicalSpecificationDefinition() = compareService.getTechnicalSpecificationDefinitions(techSpecRequest)
        dim techSpecIds(techSpecDefinitions.Length) as Integer
        for i = 0 to techSpecDefinitions.Length - 1
            techSpecIds(i) = techSpecDefinitions(i).titleId
        next i

        dim sbsRequest as SideBySideComparisonRequest = new SideBySideComparisonRequest
        sbsRequest.accountInfo = accountInfo
        sbsRequest.comparisonConfigurationStates = allStyleStates
        sbsRequest.includeCategoryComparisons = true
        sbsRequest.filteredCategoryIds = categoryIds
        sbsRequest.includeTechSpecComparisons = true
        sbsRequest.filteredTechSpecTitleIds = techSpecIds
        dim sideBySideComparisonResult as SideBySideComparison= compareService.compareSideBySide(sbsRequest)
        Dim comparisonConfigurations As configcompare3.kp.chrome.com.Configuration() = sideBySideComparisonResult.comparisonConfigurations
        dim comparisonGroups as SideBySideComparisonGroup() = sideBySideComparisonResult.comparisonGroups

        Session("comparisonConfigurations") = comparisonConfigurations
        Session("comparisonGroups") = comparisonGroups

    end sub
end class
