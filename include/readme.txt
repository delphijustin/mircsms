TmIRCControl (C) 2002, GJSoft

This component for Borland Delphi can be used to interface an application with mIRC.
It uses mIRC's builtin message handling capacaty to send/run commands and evaluate variables.
It is a conversion of the mIRC helpfile topic : SendMessage

Licence :

Do what you want with it but it would be nice if you tell
me your using it

Version

1.0 : First Public Release
1.1 : Changed it from a unit into a component
1.2 : Fixed the bugs, added few commands

Any comments/suggestions/bugreports should be sent to Geraint Jones <geraint.jones@bucksnet.co.uk> any feedback is appreceated


Some Help :

procedure Command(command:string;cMethod:integer);

This is used to send a command to mIRC 

cMethod is as described in the help file

   cMethod - the way in which you want mIRC to process the message, where:
	   1 = As if typed in editbox
	   2 = As if typed in editbox, send as plain text
	   4 = Use flood protection if turned on, can be or'd with 1 or 2


Example : mIRCControl.Command('/join #test',1)


function ChanTopic(chan:string):string;

This is used to get the topic of a channel that is open in the target mIRC

Example : Topic:=mIRCControl.ChanTopic('#test');


function Evaluate(command:string):string;

This fucntion sends a WM_MEVALUATE to mIRC and mIRC 
will evaluate the variable supplied as command

Example : ActiveChan:=mIRCControl.Evaluate('$active');


function GetLastLine:String; overload;
function GetLastLine(chan:string):String; overload;

This function will either return the last line in the active window in mIRC, if used with no param.
Or it will return the last line from the channel you specify.

Example :
         LastActiveLine:=mIRCControl.GetLastLine;
         MyChanLastLine:=mIRCControl.GetLastLine('#test');


function GetVersion:String;

A function used simply to get the host mIRC version

Example : mIRCVer:=mIRCControl.GetVersion;

procedure Join(chan:string);

Procedure used to join a channel in mIRC

Example : mIRCControl.Join('#test');

procedure ListChans(var list:tstringlist);

Used to return a list of the channels that the active mIRC is in
format used in stringlist is : channame - key - modes - topic 

Example : 
         ChanList:=TStringList.Create;
         mIRCControl.ListChans(ChanList);


procedure Part(chan:string);

Procedure used to part a channel in mIRC

Example : mIRCControl.Part('#test');

procedure Say(chan,content:string);

Procedure used to say somthing on a channel in mIRC

Example : mIRCControl.Say('#test','this is a message');

procedure SetNick(const NewNick:String);

Procedure used to change nickname in mIRC

Example : mIRCControl.SetNick('NewNick');

procedure Users(chan:string;var list:tstringlist);

Used to return a list of the users in a channel

Example : 
         NickList:=TStringList.Create;
         mIRCControl.Users('#test',NickList);

property Active:Boolean

Set to true to use if set to false it will do nothing

property ActiveChanNicks:TStringList

READ-ONLY! This is a stringlist of all the nicknames in the active mIRC window

property ActiveChan:String

READ-ONLY! This returns the name of the active mIRC window aka channel

property ChanCount : Integer

READ-ONLY! Count of channels mIRC has open

property Channels:TStringList

READ-ONLY! A list of the channels that the active mIRC is in
format used in stringlist is : channame - key - modes - topic

property CurrentServer:String

READ-ONLY! This returns the name of the active server in mIRC

property CurrentServerPort:String

READ-ONLY! This returns the port of the active server in mIRC

property mIRCHandle:hwnd

READ-ONLY! This returns the handle of the active mIRC

property mIRCVersion:String

READ-ONLY! This returns the version of mIRC being used

property mIRCPath:String

READ-ONLY! This returns the full path to the mIRC exeicutable

property MyNick:String

This property returns your current mIRC nick if changed your nick on mIRC will change

-EOF