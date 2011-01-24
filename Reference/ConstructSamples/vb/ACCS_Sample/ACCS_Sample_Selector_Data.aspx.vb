Imports configcompare3.kp.chrome.com

Partial Class ACCS_Sample_Selector_Data
    Inherits System.Web.UI.Page

    Protected configService As AutomotiveConfigCompareService3 = New configcompare3.kp.chrome.com.AutomotiveConfigCompareService3
    Protected Const accountNumber As String = "0"
    Protected Const accountSecret As String = "accountSecret"
    Protected result As String = String.Empty

    Sub Page_Load(ByVal Sender As System.Object, ByVal e As System.EventArgs)
        Dim dataRequest As String = Request.QueryString("data")

        Select Case dataRequest
            Case "locale"
                setAccountInfo(Request.QueryString("locale"))

            Case "orderAvailability"
                Dim orderAvailability As String = Request.QueryString("orderAvailability")
                If (orderAvailability.Equals("Fleet")) Then
                    Session("configOrderAvailability") = configcompare3.kp.chrome.com.OrderAvailability.Fleet
                    Session("compareOrderAvailability") = configcompare3.kp.chrome.com.OrderAvailability.Fleet
                Else
                    Session("configOrderAvailability") = configcompare3.kp.chrome.com.OrderAvailability.Retail
                    Session("compareOrderAvailability") = configcompare3.kp.chrome.com.OrderAvailability.Retail
                End If

            Case "years"
                Dim modelYears() As Integer = getModelYears()
                Dim i As Integer
                For i = 0 To modelYears.Length - 1
                    If (i > 0) Then
                        result += ";;"
                    End If

                    result += modelYears(i).ToString() + "~~" + modelYears(i).ToString()
                Next i

            Case "divisions"
                Dim modelYear As Integer = Int32.Parse(Request.QueryString("modelYear"))

                Dim divisions() As Division = getDivisions(modelYear)
                Dim i As Integer
                For i = 0 To divisions.Length - 1
                    If (i > 0) Then
                        result += ";;"
                    End If

                    result += divisions(i).divisionId.ToString() + "~~" + divisions(i).divisionName
                Next i

            Case "models"
                Dim modelYear As Integer = Int32.Parse(Request.QueryString("modelYear"))
                Dim divisionId As Integer = Int32.Parse(Request.QueryString("divisionId"))

                Dim model() As Model = getModels(modelYear, divisionId)
                Dim i As Integer
                For i = 0 To model.Length - 1
                    If (i > 0) Then
                        result += ";;"
                    End If

                    result += model(i).modelName + "~~" + model(i).modelId.ToString()
                Next i

            Case "styles"
                Dim modelYear As Integer = Int32.Parse(Request.QueryString("modelYear"))
                Dim divisionName As String = Request.QueryString("divisionName")
                Dim modelId As String = Request.QueryString("modelId")
                Dim modelName As String = Request.QueryString("modelName")

                Dim styles() As Style = getStyles(modelId)

                Dim i As Integer
                For i = 0 To styles.Length - 1
                    Dim style As Style = styles(i)
                    Dim invoice As String = String.Empty
                    Dim msrp As String = String.Empty

                    invoice = "$" + style.baseInvoice.ToString()
                    msrp = "$" + style.baseMsrp.ToString()

                    If (i > 0) Then
                        result += ";;"
                    End If

                    result += modelYear.ToString() + "~~" + divisionName + "~~" + modelName + "~~" + style.styleName + "~~" + invoice + "~~" + msrp + "~~" + style.styleId.ToString()
                Next i

        End Select

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

    Private Function getFilterRules(ByVal availability As OrderAvailability) As FilterRules
        Dim rules As New FilterRules
        rules.orderAvailability = availability
        Return rules
    End Function

    Private Function getModelYears() As Integer()
        Dim accountInfo As AccountInfo = Session("configAccountInfo")
        Dim orderAvailability As OrderAvailability = Session("configOrderAvailability")

        Dim modelYearRequest As ModelYearsRequest = New ModelYearsRequest
        modelYearRequest.accountInfo = accountInfo
        modelYearRequest.filterRules = getFilterRules(orderAvailability)

        Dim modelYears As Integer() = configService.getModelYears(modelYearRequest)

        Return modelYears
    End Function

    Private Function getDivisions(ByVal modelYear As Integer) As Division()
        Dim accountInfo As AccountInfo = Session("configAccountInfo")
        Dim orderAvailability As OrderAvailability = Session("configOrderAvailability")

        Dim divisionsRequest As DivisionsRequest = New DivisionsRequest
        divisionsRequest.accountInfo = accountInfo
        divisionsRequest.filterRules = getFilterRules(orderAvailability)
        divisionsRequest.modelYear = modelYear

        Dim divisions() As Division = configService.getDivisions(divisionsRequest)

        Return divisions
    End Function

    Private Function getModels(ByVal modelYear As Integer, ByVal divisionId As Integer) As Model()
        Dim accountInfo As AccountInfo = Session("configAccountInfo")
        Dim orderAvailability As OrderAvailability = Session("configOrderAvailability")

        Dim modelsByDivisionRequest As ModelsByDivisionRequest = New ModelsByDivisionRequest
        modelsByDivisionRequest.accountInfo = accountInfo
        modelsByDivisionRequest.filterRules = getFilterRules(orderAvailability)
        modelsByDivisionRequest.modelYear = modelYear
        modelsByDivisionRequest.divisionId = divisionId

        Dim models() As Model = configService.getModelsByDivision(modelsByDivisionRequest)

        Return models

    End Function

    Private Function getStyles(ByVal modelId As String) As Style()
        Dim accountInfo As AccountInfo = Session("configAccountInfo")
        Dim orderAvailability As OrderAvailability = Session("configOrderAvailability")

        Dim stylesRequest As StylesRequest = New StylesRequest
        stylesRequest.accountInfo = accountInfo
        stylesRequest.filterRules = getFilterRules(orderAvailability)
        stylesRequest.modelId = modelId

        Dim styles() As Style = configService.getStyles(stylesRequest)

        Return styles

    End Function
End Class
