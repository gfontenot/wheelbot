Imports configcompare3.kp.chrome.com

Partial Class ACCS_Sample_Config_ToggleOption
    Inherits System.Web.UI.Page

    protected configService as AutomotiveConfigCompareService3 = New configcompare3.kp.chrome.com.AutomotiveConfigCompareService3
    protected result as String = String.Empty

    Sub Page_Load(ByVal Sender As System.Object, ByVal e As System.EventArgs)
    
        dim accountInfo as AccountInfo = Session( "configAccountInfo" )

		' get config style
        dim configStyle as configcompare3.kp.chrome.com.Configuration = Session( "configStyle" )
		dim originatingOptionCode as String = Request.QueryString( "optionCode" )

        dim toggleRequest as ToggleOptionRequest = new ToggleOptionRequest
        toggleRequest.accountInfo = accountInfo
        toggleRequest.configurationState = configStyle.style.configurationState
        toggleRequest.chromeOptionCode = originatingOptionCode

		dim optionToggleResponse as ToggleOptionResponse = configService.toggleOption( toggleRequest )

		' save config style
        dim newConfigStyle as configcompare3.kp.chrome.com.Configuration = optionToggleResponse.configuration
		Session( "configStyle" ) = newConfigStyle

		' handle option conflict
		if( optionToggleResponse.requiresToggleToResolve ) then 
        
			result = "yesConflict~~"
			dim conflictingOptionsAndDescs as String = ""

			' get conflicting option codes and descriptions
			dim conflictingOptions as String() = optionToggleResponse.conflictResolvingChromeOptionCodes
            Dim i As Integer
			For i = 0 To conflictingOptions.Length - 1
            
				dim conflictingOptionCode as String = conflictingOptions(i)
				if( i > 0 and i < conflictingOptions.Length )
					conflictingOptionsAndDescs += ";;"
                end if

				dim options as configcompare3.kp.chrome.com.Option() = newConfigStyle.options
                dim j as Integer
				for j = 0 to options.Length - 1 
                
					dim optionItem as configcompare3.kp.chrome.com.Option = options(j)
					if( optionItem.chromeOptionCode = conflictingOptionCode ) 
                    
                        dim optionName as String = ""
                        dim k as Integer
                        for k=0 to optionItem.descriptions.Length - 1
                        
                            if( optionItem.descriptions(k).type = OptionDescriptionType.PrimaryName )
                                optionName = optionItem.descriptions(k).description
                            end if
                        next k

                        conflictingOptionsAndDescs += conflictingOptionCode + "::" + optionName
						exit for
					end if
				next j
			next i

			' get manufacturer code and description for originating option code
			dim manuCodeAndDesc as String = ""
			for i = 0 to newConfigStyle.options.Length - 1
            
				dim optionItem as configcompare3.kp.chrome.com.Option = newConfigStyle.options(i)
				if( String.Compare( optionItem.chromeOptionCode, originatingOptionCode, true ) = 0 ) 
                    dim optionName as String = ""
                    dim j as Integer
                    for j=0 to optionItem.descriptions.Length - 1
                    
                        if( optionItem.descriptions(j).type = OptionDescriptionType.PrimaryName )
                            optionName = optionItem.descriptions(j).description
                        end if
                    next j
                    manuCodeAndDesc = optionItem.oemOptionCode + ";;" + optionName
					exit for
				end if
			next i

            if (optionToggleResponse.originatingOptionAnAddition )
				result += manuCodeAndDesc + "~~add~~" + conflictingOptionsAndDescs
			else
				result += manuCodeAndDesc + "~~delete~~" + conflictingOptionsAndDescs
            end if
		
        elseif (not optionToggleResponse.requiresToggleToResolve )
            ' no option conflict
			result = "noConflict~~"
			
            'get all option codes and states
			dim allOptionCodesAndStates as String = ""
            dim i as Integer
			for i = 0 to newConfigStyle.options.Length - 1 
            
				dim optionItem as configcompare3.kp.chrome.com.Option = newConfigStyle.options(i)
				dim optionCodeAndState as String = optionItem.chromeOptionCode + "::" + optionItem.selectionState.ToString()
				if( i > 0 and i < newConfigStyle.options.Length )
					allOptionCodesAndStates += ";;"
                end if

				allOptionCodesAndStates += optionCodeAndState
			next i

			' get new pricing
            dim totalOptionsInvoice as String = newConfigStyle.configuredOptionsInvoice.ToString()
            dim totalOptionsMsrp as String = newConfigStyle.configuredOptionsMsrp.ToString()

            dim totalInvoice as String = newConfigStyle.configuredTotalInvoice.ToString()
            dim totalMsrp as String = newConfigStyle.configuredTotalMsrp.ToString()

			result += allOptionCodesAndStates + "~~" + totalOptionsInvoice + "~~" + totalOptionsMsrp + "~~" + totalInvoice + "~~" + totalMsrp
		end if

    end sub
end class
