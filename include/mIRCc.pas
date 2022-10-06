unit mIRCc;
{

From mIRC's Help FIle

Applications can now use SendMessage() to communicate with the 32bit mIRC.

Performing Commands
The following call to SendMessage() makes mIRC perform the commands that you specify.

   SendMessage(mHwnd, WM_MCOMMAND, cMethod, 0L)

   mHwnd - the handle of the main mIRC window, or the handle of a Channel, Query, etc. window.

   WM_MCOMMAND - which should be defined as WM_USER + 200

   cMethod - the way in which you want mIRC to process the message, where:
	   1 = As if typed in editbox
	   2 = As if typed in editbox, send as plain text
	   4 = Use flood protection if turned on, can be or'd with 1 or 2

   Returns - 1 if success, 0 if fail

Evaluating Identifiers and Variables
The following call to SendMessage() makes mIRC evaluate
the contents of any line that you specify.

   SendMessage(mHwnd, WM_MEVALUATE, 0, 0L)

   mHwnd - the handle of the main mIRC window, or the
   handle of a Channel, Query, etc. window.

   WM_MEVALUATE - should be defined as WM_USER + 201

   Returns - 1 if success, 0 if fail

Mapped Files
The application that sends these messages must create a
mapped file named mIRC with CreateFileMapping().

When mIRC receives the above messages, it will open this
file and use the data that this mapped file contains to
perform the command or evaluation. In the case of an
evaluation, mIRC will output the results to the mapped file.

The mapped file must be at least 1024 bytes in length.


This unit is an implementation of the above for Delphi

Written 16-09-2002 Geraint Jones <geraint.jones@bucksnet.co.uk>

Licence :

Do what you want with it but it would be nice if you tell
me your using it

Version

1.0 : First Public Release
1.1 : Changed it from a unit into a component
}
interface

uses
  Windows, Messages, SysUtils, Classes;

type
  TmIRCChan = Record
   Name  : String;
   Key   : String;
   Topic : String;
   Modes : String;
  end;
  TmIRCControl = class(TComponent)
  private
   FmIRCWnd   : HWND;
   FChans     : TStringList;
   FNicks     : TStringList;
   FhFileMap  : THandle;
   FmData     : pchar;
   FChan      : string;
   FActive    : Boolean;
   FVersion   : String;
   FPath      : String;
   FServer    : String;
   FPort      : String;
   FChanCount : Integer;
   FLastLine  : String;
   function GetmIRCPath:String;
   function GetChans:TStringList;
   function ActiveNicks:TStringList;
   function GetmIRCWnd:HWND;
   function GetNick:String;
   function GetServer:String;
   function GetPort:String;
   function GetChan:String;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function Evaluate(command:string):string;
    procedure Command(command:string;cMethod:integer);
    procedure Part(chan:string);
    procedure Join(chan:string);
    procedure Say(chan,content:string);
    procedure Users(chan:string;var list:tstringlist);
    procedure ListChans(var list:tstringlist);
    function ChanTopic(chan:string):string;
    procedure SetNick(const NewNick:String); virtual;
    function GetVersion:String;
    function GetLastLine:String; overload;
    function GetLastLine(chan:string):String; overload;
  published
    property ChanCount : Integer read FChanCount write FChanCount;
    property mIRCHandle:hwnd read GetmIRCWnd write FmIRCWnd;
    property Channels:TStringList read GetChans write FChans;
    property ActiveChanNicks:TStringList read ActiveNicks;
    property ActiveChan:String read GetChan write FChan;
    property MyNick:String read GetNick write SetNick;
    property Active:Boolean read FActive write FActive;
    property mIRCVersion:String read GetVersion write FVersion;
    property mIRCPath:String read GetmIRCPath write FPath;
    property CurrentServer:String read GetServer write FServer;
    property CurrentServerPort:String read GetPort write FPort;
  end;

procedure Register;

implementation

const
WM_MEVALUATE = WM_USER + 201;
WM_MCOMMAND = WM_USER + 200;


constructor TmIRCControl.Create(AOwner: TComponent);
begin
  inherited;
  FhFileMap := CreateFileMapping(INVALID_HANDLE_VALUE,0,PAGE_READWRITE,0,4096,'mIRC');
  FmData := MapViewOfFile(FhFileMap,FILE_MAP_ALL_ACCESS,0,0,0);
  FmIRCWnd:=GetmIRCWnd;
  FChans:=TStringList.Create;
  ListChans(FChans);
end;
function TmIRCControl.GetLastLine(chan:string):String;
var
linecount:integer;
begin
FChan:=chan;
try
linecount:=strtoint(evaluate('$line('+FChan+',0)'));
except
end;
result:=evaluate('$line('+FChan+','+inttostr(linecount)+')');
end;

function TmIRCControl.GetLastLine:String;
var
linecount:integer;
begin
FChan:=evaluate('$active');
try
linecount:=strtoint(evaluate('$line('+FChan+',0)'));
except
end;
result:=evaluate('$line('+FChan+','+inttostr(linecount)+')');
end;

function TmIRCControl.GetChans:TStringList;
begin
  FChans:=TStringList.Create;
  ListChans(FChans);
  Result:=FChans;
end;

function TmIRCControl.GetServer:String;
begin
  Result:=Evaluate('$server');
end;

function TmIRCControl.GetPort:String;
begin
  Result:=Evaluate('$port');
end;

function TmIRCControl.GetmIRCPath:String;
begin
  result:=Evaluate('$mircexe')
end;

function TmIRCControl.ActiveNicks:TStringList;
begin
  FNicks:=TStringList.Create;
  Users(ActiveChan,FNicks);
  Result:=FNicks;
end;

procedure TmIRCControl.SetNick(const NewNick:String);
begin
  if FActive then Command('/nick '+NewNick,1);
end;

function TmIRCControl.GetVersion:String;
begin
  Result := Evaluate('$version');
end;

function TmIRCControl.GetNick:String;
begin
  if FActive then Result := Evaluate('$me') else Result := '';
end;

function TmIRCControl.GetChan:String;
begin
  if FActive then Result := Evaluate('$active') else Result := '';
end;

function TmIRCControl.GetmIRCWnd:HWND;
begin
  Result:=FindWindow('mIRC',nil);
end;

destructor TmIRCControl.Destroy;
begin
  inherited;
  FChans.Free;
  FNicks.Free;
  UnmapViewOfFile(FmData);
  CloseHandle(FhFileMap);
end;
function TmIRCControl.Evaluate(command:string):string;
begin
  StrPCopy(FmData,command);
  SendMessage(FmIRCWnd,WM_MEVALUATE,0,0);
  Result:=FmData;
end;

procedure TmIRCControl.Command(command:string;cMethod:integer);
begin
  StrPCopy(FmData,command);
  SendMessage(FmIRCWnd,WM_MCOMMAND,cMethod,0);
end;

procedure TmIRCControl.Part(chan:string);
begin
  Command('/part '+chan,1);
end;

procedure TmIRCControl.Join(chan:string);
begin
  Command('/join '+chan,1);
end;

procedure TmIRCControl.Say(chan,content:string);
begin
  Command('/msg '+chan+' '+content,1);
end;
procedure TmIRCControl.Users(chan:string;var list:tstringlist);
var
i : integer;
s: string;
begin
  try
   s:=Evaluate('$nick('+chan+',0)');
    for i := 1 to StrToInt(s)
      do list.Add(Evaluate('$nick('+chan+','+inttostr(i)+')'));
      Except
       list.Add('Window Is PM');
      end;
end;

procedure TmIRCControl.ListChans(var list:tstringlist);
var
i : integer;
s: string;
begin
  try
   s:=Evaluate('$chan(0)');
   FChanCount:=StrToInt(s);
    for i := 1 to StrToInt(s)
      do
      begin
      list.Add(Evaluate('$chan('+inttostr(i)+')')+' - '+Evaluate('$chan('+inttostr(i)+').key')+' - '+Evaluate('$chan('+inttostr(i)+').mode')+' - '+Evaluate('$chan('+inttostr(i)+').topic'));
      end;
      Except
      end;
end;

function TmIRCControl.ChanTopic(chan:string):string;
var
s:string;
begin
  s:=Evaluate('$chan('+chan+').topic');
  result:=s;
end;

procedure Register;
begin
  RegisterComponents('GJSoft', [TmIRCControl]);
end;

end.