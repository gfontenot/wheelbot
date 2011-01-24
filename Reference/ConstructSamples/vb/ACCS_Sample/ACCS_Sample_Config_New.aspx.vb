Imports configcompare3.kp.chrome.com
Imports System.IO

Partial Class ACCS_Sample_Config_New
    Inherits System.Web.UI.Page

    Protected configService As AutomotiveConfigCompareService3 = New configcompare3.kp.chrome.com.AutomotiveConfigCompareService3
    Protected result As String = String.Empty

    Sub Page_Load(ByVal Sender As System.Object, ByVal e As System.EventArgs)

        Dim accountInfo As AccountInfo = Session("configAccountInfo")
        Dim orderAvailability As OrderAvailability = Session("configOrderAvailability")

        'load saved style or get from session
        Dim configState As ConfigurationState
        Dim scratchListId As String = Request.QueryString("scratchListId")
        If (scratchListId.Equals("none")) Then
            Dim filePathAndName As String = Request.QueryString("filePathAndName")
            configState = loadSavedState(accountInfo, filePathAndName)
        Else
            configState = Session(scratchListId)
        End If


        ' do checklist
        Dim configRequest As FullyConfiguredRequest = New FullyConfiguredRequest
        configRequest.accountInfo = accountInfo
        configRequest.configurationState = configState

        Dim toggleResponse As ToggleOptionResponse = configService.getStyleFullyConfigured(configRequest)
        Dim configStyle As configcompare3.kp.chrome.com.Configuration = toggleResponse.configuration

        ' save fully configured
        Session(scratchListId) = configStyle.style.configurationState

        ' save configuration to session
        Session("configStyle") = configStyle

    End Sub


    Private Function loadSavedState(ByVal accountInfo As AccountInfo, ByVal filePathAndName As String) As ConfigurationState

        Dim fileReader As StreamReader = New StreamReader(filePathAndName)
        Dim serializedStyleState As String = fileReader.ReadToEnd
        fileReader.Close()

        ' get styleState
        Dim stateRequest As ConfigurationStateRequest = New ConfigurationStateRequest
        stateRequest.accountInfo = accountInfo
        stateRequest.serializedValue = serializedStyleState

        Dim configState As ConfigurationStateElement = configService.materializeConfigurationState(stateRequest)

        Return configState.configurationState
    End Function
End Class