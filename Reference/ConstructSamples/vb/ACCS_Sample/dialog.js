var modalWinMask;
var msgDialog;
var msgDiv;
var contentDiv;
var dialogWidth = 600;
var dialogCallback;
var buttonDiv;

function showMessageDialog(message, callbackFunction)
{
    initializeDialog( callbackFunction );

    // create ok button and update msg div
    msgDiv.innerHTML = "";
    contentDiv.innerHTML = message;
    buttonDiv.innerHTML = "<input type='button' value='OK' onclick='closeDialog(); processCallback()' >";

    showDialog();
}

function showContentDialog( message, contentHTML, callbackFunction )
{
    initializeDialog( callbackFunction );

    // create ok button and update msg and content div
    msgDiv.innerHTML = message;
    contentDiv.innerHTML = contentHTML;
    buttonDiv.innerHTML = "<input type='button' value='OK' onclick='closeDialog(); processCallback()' >";

    showDialog();
}

function processCallback()
{
    if(dialogCallback)
        dialogCallback();
    dialogCallback = null;
}

function initializeDialog( callbackFunction )
{
    dialogCallback = callbackFunction;

    dialogCallback = callbackFunction;

    if( !modalWinMask )
    {
        modalWinMask = document.createElement( "DIV" );
        modalWinMask.id = "modalWinMask";
        modalWinMask.style.position = "absolute";
        modalWinMask.style.top = "0";
        modalWinMask.style.left = "0";
        modalWinMask.style.display = "none";
        modalWinMask.style.zIndex = "1";
        modalWinMask.style.backgroundColor = "gray";
        modalWinMask.style.opacity = "0.25";
        modalWinMask.style.filter = "Alpha(opacity=25)";
        document.body.appendChild( modalWinMask );
    }
    if( !msgDialog )
    {
        msgDialog = document.createElement( "DIV" );
        msgDialog.id = "msgDialog";
        msgDialog.style.position = "absolute";
        msgDialog.style.border = "1px solid";
        msgDialog.style.backgroundColor = "white";
        msgDialog.style.width = dialogWidth + "px";
        msgDialog.style.zIndex = "2";

        msgDiv = document.createElement( "DIV" );
        msgDiv.id = "msgDiv";
        msgDialog.appendChild( msgDiv );
        msgDialog.appendChild( document.createElement( "HR" ) )

        contentDiv = document.createElement( "DIV" );
        contentDiv.id = "contentDiv";
        msgDialog.appendChild( contentDiv );
        msgDialog.appendChild( document.createElement( "HR" ) )

        buttonDiv = document.createElement( "DIV" );
        buttonDiv.align = "center";
        msgDialog.appendChild( buttonDiv );

        document.body.appendChild( msgDialog );
    }
}

function showDialog()
{
    var scrollPosition = getScrollingPosition();
    var innerDimension = getInnerDimensions();
    var screenDimension = getScreenDimensions();

    //show mask
    modalWinMask.style.width = innerDimension[ 0 ] + "px";
    modalWinMask.style.height = screenDimension[ 1 ] + "px";
    toggleElementVisibility( "modalWinMask", true );

    msgDialog.style.left = (scrollPosition[0] + (innerDimension[0]/2) - (dialogWidth/2) ) + "px";
    msgDialog.style.top = (scrollPosition[1] + (innerDimension[1]/2)) + "px";

    toggleElementVisibility( "msgDialog", true );
}

function closeDialog( )
{
    toggleElementVisibility( "modalWinMask", false );
    toggleElementVisibility( 'msgDialog', false );
}

function toggleElementVisibility( elementName, visible )
{
    var element = document.getElementById( elementName );
    if( element )
    {
        element.style.visibility = visible ? "visible" : "hidden";
        element.style.display = visible ? "" : "none";
    }
}

// screen dimension code referenced from:  www.quirksmode.org
function getScreenDimensions()
{
    var x,y;
    var test1 = document.body.scrollHeight;
    var test2 = document.body.offsetHeight
    if (test1 > test2) // all but Explorer Mac
    {
        x = document.body.scrollWidth;
        y = document.body.scrollHeight;
    }
    else // Explorer Mac;
         //would also work in Explorer 6 Strict, Mozilla and Safari
    {
        x = document.body.offsetWidth;
        y = document.body.offsetHeight;
    }

    return [ x, y ];
}

// Scrolling code referenced from:  www.quirksmode.org
function getScrollingPosition()
{
    var x,y;
    if (self.pageYOffset) // all except Explorer
    {
        x = self.pageXOffset;
        y = self.pageYOffset;
    }
    else if (document.documentElement && document.documentElement.scrollTop)
        // Explorer 6 Strict
    {
        x = document.documentElement.scrollLeft;
        y = document.documentElement.scrollTop;
    }
    else if (document.body) // all other Explorers
    {
        x = document.body.scrollLeft;
        y = document.body.scrollTop;
    }

    return [ x, y ];
}

// inner dimensions code referenced from:  www.quirksmode.org
function getInnerDimensions()
{
    var x,y;
    if (self.innerHeight) // all except Explorer
    {
        x = self.innerWidth;
        y = self.innerHeight;
    }
    else if (document.documentElement && document.documentElement.clientHeight)
        // Explorer 6 Strict Mode
    {
        x = document.documentElement.clientWidth;
        y = document.documentElement.clientHeight;
    }
    else if (document.body) // other Explorers
    {
        x = document.body.clientWidth;
        y = document.body.clientHeight;
    }

    return [ x, y ];
}