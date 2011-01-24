Imports System.IO
Imports configcompare3.kp.chrome.com

Partial Class ACCS_Sample_Save_Style
	Inherits System.Web.UI.Page

	Protected result As String = String.Empty

	Sub Page_Load(ByVal Sender As System.Object, ByVal e As System.EventArgs)

        result = "success"

        dim type as String = Request.QueryString( "actionType" )

		Dim styleName As String = Request.QueryString("styleName")

        select Case type 

            case "add"
                try
                
		            Dim configStyle As Configuration = Session("configStyle")
		            Dim serializedState As String = configStyle.style.configurationState.serializedValue

		            Dim path As String = "C:\\tmp\\savedStyles\\"

		            If (Not Directory.Exists(path)) Then
			            Dim di As DirectoryInfo = Directory.CreateDirectory(path)
		            End If

		            'delete old file, then create new file
		            Dim fileName As String = path + styleName + ".xml"
		            If (File.Exists(fileName)) Then
			            File.Delete(fileName)
		            End If

		            Dim streamWriter As StreamWriter = File.CreateText(fileName)
		            streamWriter.WriteLine(serializedState)
		            streamWriter.Close()

                Catch ex As Exception
                    result = "failed"

                End Try

            case "delete"
                try
                    If (File.Exists(styleName)) Then
			            File.Delete(styleName)
		            End If
                Catch ex As Exception
                    result = "failed"
                End Try

        end select

	End Sub

End Class
