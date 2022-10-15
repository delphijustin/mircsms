unit smsUnit1;
{$RESOURCE MIRCSMSEXE.RES}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,math,
  ExtCtrls, mIRCc, StdCtrls,httpapp,urlmon,comobj, Menus,shellapi, ComCtrls,
  clipbrd;
const appname='mIRCSMS';
OUTBOX_URL='https://delphianserver.com/outbox/';
ERROR_USE_NULL=0;//writelog does nothing
ERROR_USE_MEMO=1;//Write error to memo
ERROR_USE_FILE=2;//Write to log file
ERROR_USE_MIRCSELCH=4;//send a message to channel/query that is being used
ERROR_USE_MIRCSELFMSG=8;//send a private message back to yourself.
ERROR_USE_DEFAULT=ERROR_USE_FILE OR ERROR_USE_MEMO;
MAX_SMS=160;
yesno:array[boolean]of string=('No','Yes');
TEXTBELT_URL_ERROR='Sorry, ability to send URLs via text is limited to verified accounts. Please go to https://textbelt.com/whitelist?key=%s or email support@textbelt.com with your use case and we will verify your key ASAP.';
REG_QWORD=$B;
type
TSMSSpeedMenu=record
Timer:TTimer;
valueName:pansichar;
end;
PSMSSpeedMenu=^TSMSSpeedMenu;
  TSMSBot = class(TForm)
    Timer1: TTimer;
    Memo1: TMemo;
    Timer2: TTimer;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Paused1: TMenuItem;
    Quit1: TMenuItem;
    Tools1: TMenuItem;
    Checkquota1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Clear1: TMenuItem;
    CopyToClipboard1: TMenuItem;
    SelectAll1: TMenuItem;
    CheckStatus1: TMenuItem;
    Help1: TMenuItem;
    Website1: TMenuItem;
    About1: TMenuItem;
    Donate1: TMenuItem;
    SupportForum1: TMenuItem;
    CheckStatus2: TMenuItem;
    Options1: TMenuItem;
    Cropping1: TMenuItem;
    Nocropping1: TMenuItem;
    BuyMoreCredits1: TMenuItem;
    ViewLastMessage1: TMenuItem;
    viaPayPal1: TMenuItem;
    viaCashApp1: TMenuItem;
    Makemessagetofitintoonetextmessage1: TMenuItem;
    StatusBar1: TStatusBar;
    ViewLastPhoneNumber1: TMenuItem;
    ViewLogFile1: TMenuItem;
    Protocol1: TMenuItem;
    https1: TMenuItem;
    http1: TMenuItem;
    MinimumQuota1: TMenuItem;
    EncodeURLs1: TMenuItem;
    MessageDecoderSite1: TMenuItem;
    OfflineMessageDecoder1: TMenuItem;
    MessageDecoders1: TMenuItem;
    GooglePlay1: TMenuItem;
    Timer3: TTimer;
    LowQuotaCommand1: TMenuItem;
    Panel1: TPanel;
    Edit1: TEdit;
    Button1: TButton;
    CopyKeyToClipboard1: TMenuItem;
    mIRCDelay1: TMenuItem;
    IncomingSMSDelay1: TMenuItem;
    DailyQuotaLimit1: TMenuItem;
    Timer4: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer2Timer(Sender: TObject);
    procedure Paused1Click(Sender: TObject);
    procedure Quit1Click(Sender: TObject);
    procedure Checkquota1Click(Sender: TObject);
    procedure Clear1Click(Sender: TObject);
    procedure CopyToClipboard1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure CheckStatus1Click(Sender: TObject);
    procedure Website1Click(Sender: TObject);
    procedure SupportForum1Click(Sender: TObject);
    procedure CheckStatus2Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure BuyMoreCredits1Click(Sender: TObject);
    procedure ViewLastMessage1Click(Sender: TObject);
    procedure Cropping(Sender: TObject);
    procedure viaPayPal1Click(Sender: TObject);
    procedure viaCashApp1Click(Sender: TObject);
    procedure ViewLastPhoneNumber1Click(Sender: TObject);
    procedure ViewLogFile1Click(Sender: TObject);
    procedure https1Click(Sender: TObject);
    procedure MinimumQuota1Click(Sender: TObject);
    procedure EncodeURLs1Click(Sender: TObject);
    procedure MessageDecoderSite1Click(Sender: TObject);
    procedure OfflineMessageDecoder1Click(Sender: TObject);
    procedure GooglePlay1Click(Sender: TObject);
    procedure LowQuotaCommand1Click(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CopyKeyToClipboard1Click(Sender: TObject);
    procedure mIRCDelay1Click(Sender: TObject);
    procedure Timer4Timer(Sender: TObject);
    procedure DailyQuotaLimit1Click(Sender: TObject);
  private
choice:string;
  lastbuff:array[0..2048]of ansichar;
  function getlastmsg:string;
  procedure setlastmsg(value:String);
  function regchkconfig:dword;
  function getqlimit:DWORD;
  procedure setqlimit(Limit:DWORD);
  procedure setquota(x:DWORD);
  procedure setphone(x:int64);
  procedure setproto(Port:dword);
  procedure setQCmd(cmd:string);
  function getQCmd:string;
  function getProto:dword;
  function getPhone:int64;
  function getquotaEnabled:boolean;
  function gettquota:dword;
  procedure settquota(x:dword);
  procedure setquotaenabled(b:boolean);
  procedure setkey(APIKey:string);
  function getkey:string;
  function getbEncoding:Boolean;
  procedure setbEncoding(b:boolean);
  function getdaily:dword;
  procedure setdaily(x:dword);
  function getquota:DWORD;
    { Private declarations }
  public
  watchlist,regkey,cache,favkey:HKey;
  mIRC:TmIRCControl;
  targetQ:string;
  CropMode,firstTime:dword;
  smscommands,json:tstringlist;
  textbeltWorks:boolean;
  startTime:tdatetime;
  property dailylimit:dword read getdaily write setdaily;
  function FormatSMS(msg:string):string;
  property QuotaPaused:boolean read getquotaenabled write setquotaenabled;
  procedure writelog(const func,msg:string;whatToUse:dword=error_use_default);
  procedure execBuiltIn(const Command:string);
  property QuotaCommand:string read getqcmd write setqcmd;
  property LastMSG:string read getlastmsg write setlastmsg;
  property NoEncodingURLs:boolean read getbEncoding write setbEncoding;
  procedure mIRCExec(const sms:string);
  procedure processmIRC(const targetq:string);
  property Quota:DWORD read getquota write setquota;
  property Protocol:dword read getproto write setproto;
  property TodayQuota:dword read gettquota write settquota;
  function protocols(dwPort:dword):string;
  property phone:int64 read getphone write setphone;
  property ConfigVersion:dword read regchkconfig;
  property textbeltKey:string read getkey write setkey;
  function sendSMS(msg:string;watchId:pansichar=nil):TStringlist;
  property MinQuota:DWORD read getqlimit write setqlimit;
  function GetTargets:TStringlist;
    { Public declarations }
  end;
  TSMSBotFunction=function(args:tstringlist;bot:tsmsbot):string;
  function mIRCSMSVersion:dword;external 'libmIRCSMS.dll';
var
  SMSBot: TSMSBot;
implementation

{$R *.DFM}

procedure tsmsbot.settquota;
var dw:dword;
begin
dw:=x;
regsetvalueexa(cache,'TodayQuota',0,reg_dword,@dw,4);
end;

function tsmsbot.gettquota;
var rs:dword;
begin
rs:=4;result:=0;
regqueryvalueexa(cache,'TodayQuota',nil,nil,@result,@rs);
end;

procedure tsmsbot.setdaily;
var daily:dword;
begin
daily:=x;
regsetvalueexa(regkey,'DailyLimit',0,reg_dword,@daily,4);
end;

function tsmsbot.getdaily;
var rs:dword;
begin
rs:=4;result:=maxlong;
regqueryvalueexa(regkey,'DailyLimit',nil,nil,@result,@rs);
end;

procedure tsmsbot.setQCmd;
var buff:array[0..2048]of ansichar;
begin
regsetvalueexa(regkey,'OnLowQuota',0,reg_expand_sz,strplcopy(buff,cmd,2048),1+
length(cmd));
end;

function tsmsbot.GetTargets;
var ns,ind:dword;
nam:array[byte]of ansichar;
begin
ind:=0;
ns:=256;
nam[0]:=#0;
result:=tstringlist.Create;
while regenumvalue(watchlist,ind,nam,ns,nil,nil,nil,nil)=error_success do begin
result.Append(nam);
ns:=256;
strpcopy(nam,'/');
inc(ind);
end;
end;
procedure tsmsbot.setbEncoding;
begin
if b then regsetvalueexa(regkey,'NoEncodingURLs',0,reg_binary,nil,0)else
regdeletevaluea(regkey,'NoEncodingURLs');
end;
function tsmsbot.getquotaEnabled;
var dwdate,rs:dword;
begin
dwDate:=0;rs:=4;regqueryvalueexa(regkey,'QuotaDate',nil,nil,@dwDate,@rs);
result:=(trunc(date)=dwdate);
end;
procedure tsmsbot.setquotaenabled;
var dwDate:dword;
begin
dwdate:=trunc(date);
if b then regsetvalueexa(regkey,'QuotaDate',0,reg_dword,@dwdate,4)else
regdeletevaluea(regkey,'QuotaDate');
end;
function tsmsbot.getbEncoding;
begin
result:=(regqueryvalueexa(regkey,'NoEncodingURLs',nil,nil,nil,nil)=error_success);
end;

function tsmsbot.getqlimit;
var rs:dword;
begin
result:=0;rs:=4;regqueryvalueexa(regkey,'MinQuota',nil,nil,@result,@rs);
end;

procedure tsmsbot.setqlimit;
var Dw:DWORD;
begin
Dw:=limit;
regsetvalueexa(regkey,'MinQuota',0,reg_DWORD,@DW,4);
end;

procedure tsmsbot.writelog;
var line:array[byte]of ansichar;
ec:dword;
ts,pid:array[0..32]of ansichar;
logname:array[0..max_path]of ansichar;
begin
if whattouse=error_use_null then exit;
strfmt(pid,'PID%u',[getcurrentprocessid]);
strplcopy(ts,datetimetostr(now),32);strlfmt(line,255,'%s: %s',[func,msg]);
strpcopy(logname,changefileext(forms.application.exename,'.log'));
if error_use_memo and whattouse>0then memo1.Lines.Values[ts]:=line;
if eRROR_USE_MIRCSELCH and whattouse>0then mirc.Say(targetq,strpas(line));
if error_use_mircselfmsg and whattouse>0then mirc.Say(mirc.mynick,strpas(line));
if error_use_file AND Whattouse>0then if not writeprivateprofilestring(pid,ts,
line,logname)then begin ec:=getlasterror;regsetvalueexa(cache,'LogWriteError',0,
reg_dword,@ec,4);end;
end;
function tsmsbot.regchkconfig;
var rs:dword;
begin
rs:=4;result:=0;
regqueryvalueexa(regkey,'ConfigVersion',nil,nil,@result,@rs);
end;
function tsmsbot.getPhone;
var rs:dword;
begin
result:=0;rs:=8;
regqueryvalueexa(regkey,'Phone',nil,nil,@result,@rs);
end;
function tsmsbot.getkey;
var textbelt:array[byte]of ansichar;
rs:dword;
begin
strcopy(textbelt,'textbelt');
rs:=256;
regqueryvalueexa(regkey,'TextBeltKey',nil,nil,@textbelt,@rs);
result:=strpas(textbelt);
if pos(' /test',lowercase(getcommandline))>0then result:=result+'_test';
end;
procedure tsmsbot.setkey;
var err:longint;
begin
err:=regsetvalueexa(regkey,'TextBeltKey',0,reg_sz,@apikey[1],1+length(apikey));
if err<>error_success then writelog('setTextbeltKey',syserrormessage(err));
end;
procedure tsmsbot.setphone;
var y:int64;
err:longint;
begin
y:=x;
err:=regsetvalueexa(regkey,'Phone',0,reg_qword,@y,8);if err<>error_success then
writelog('setPhoneNumber',syserrormessage(err));
end;
function isFromNick(const nick,msg:string):boolean;
begin
result:=(pos('<'+lowercase(nick)+'>',lowercase(msg))=1)or(pos('<@'+lowercase(nick
)+'>',lowercase(msg))=1)or(pos('<+'+lowercase(nick)+'>',lowercase(msg))=1)or(pos(
'<%'+lowercase(nick)+'>',lowercase(msg))=1);
end;
function tsmsbot.getquota;
var rs:dword;
begin
rs:=4;result:=MAXDWORD;
regqueryvalueexa(regkey,'Quota',nil,nil,@result,@rs);
if json.indexof('quotaRemaining')=-1then exit;
result:=strtointdef(copy(json[json.indexof('quotaRemaining')+1],
2,maxint),result);setquota(result);
end;

function tsmsbot.getProto;
var rs:dword;
begin
rs:=4;result:=443;regqueryvalueexa(regkey,'Protocol',nil,nil,@result,@rs);
end;

procedure tsmsbot.setproto;
var dw:dword;
begin
dw:=port;
regsetvalueexa(regkey,'Protocol',0,reg_dword,@dw,4);
case dw of
80:http1.Checked:=true;
else https1.Checked:=true;
end;
end;

procedure tsmsbot.setquota;
var y:DWORD;
begin
y:=x;
regsetvalueexa(regkey,'Quota',0,reg_dword,@y,4);
end;

function ismIRCStatus(const line:String):boolean;
begin
result:=(pos('$',line)=1);
end;
procedure tsmsbot.setlastmsg;
begin
regsetvalueexa(cache,'LastMsg',0,reg_sz,strplcopy(lastbuff,value,2048),1+length(
value));
end;

function tsmsbot.getlastmsg;
var rs:dword;
begin
rS:=2049;
regqueryvalueexa(cache,'LastMsg',nil,nil,@lastbuff,@rs);
result:=strpas(lastbuff);
end;
function tsmsbot.FormatSMS;
begin
result:=msg;
if cropmode>1then Makemessagetofitintoonetextmessage1.Click;
case cropmode of
0:result:=copy(result,1,max_sms);
1:result:=result;
end;
end;
function unwatch(args:tstringlist;bot:tsmsbot):string;
var wname:array[byte]of ansichar;
begin
result:=syserrormessage(error_invalid_parameter);
if args.Count<>2then exit;
result:='';
regdeletevaluea(bot.watchlist,strpcopy(wname,args[1]));
end;
function sendQuota(args:tstringlist;bot:tsmsbot):string;
begin
result:=format('%u credits left',[bot.quota]);
end;

function getNicks(args:tstringlist;bot:tsmsbot):string;
var nicks,ison:tstringlist;
I:integer;
begin
nicks:=tstringlist.Create;
bot.mIRC.Users(bot.targetQ,nicks);
if args.count=1then
result:=nicks.CommaText
else begin
ison:=tstringlist.Create;
result:='(no users found)';
for i:=1to args.count-1do if nicks.IndexOf(args[i])>-1then ison.Append(args[i]);
if ison.Count>0then result:=ison.commatext;ison.Free;
end;
nicks.Free;
end;

function tsmsbot.sendSMS;
var mparams:array[0..2048]of ansichar;
fn:array[0..max_path]of ansichar;
tar:string;
buff,textid:array[byte]of ansichar;
error:hresult;
sms,sl:tstringlist;
begin
try
result:=tstringlist.Create;
sl:=tstringlist.Create;
if((dailylimit<maxlong)and(todayquota>dailylimit))or ismIRCStatus(msg)or
isfromnick(mirc.MyNick,msg) then begin sl.free; exit;end;
if dailylimit<maxlong then begin todayquota:=todayquota+1;
if todayquota>=dailylimit then begin sl.Free;
sendsms('Daily Quota reached type @enable to chat');quotapaused:=true;exit;
end;
end;
tar:='';
if watchid<>nil then tar:=strpas(watchid)+' ';
error:=urldownloadtocachefilea(nil,strplcopy(mparams,
protocols(protocol)+'://textbelt.com/text?message='+httpencode(formatsms(tar+msg))+
'&phone='+inttostr(phone)+'&replyWebhookUrl='+httpencode(outbox_url)+'&key='+
textbeltkey+'&now='+floattostr(now),2048),fn,max_path,0,nil);
if fileexists(fn)then begin
sl.LoadFromFile(fn);
result.Text:=sl.Text;
json.CommaText:=stringreplace(stringreplace(sl.text,'{','',[]),'}','',[]);
deletefile(fn);
sms:=tstringlist.Create;
sms.Text:=msg;
if(pos(' /test',lowercase(getcommandline))>0)then begin
if(json.IndexOf('textid')>-1)then
writeprivateprofilestringa(strfmt(mparams,'Test PID%u',[Getcurrentprocessid]),
strpcopy(textid,json[json.indexof('textid')+1]),strplcopy(buff,msg,255),strpcopy(
fn,changefileext(forms.application.exename,'.log')));
end;
if(pos(format(textbelt_url_error,[textbeltkey]),sl.Text)>0)and(not NoEncodingURLs)then
begin
sl:=sendsms(tar+stringreplace(stringreplace(httpencode(msg),'.','%2E',[rfreplaceall])
,'+',#32,[rfreplaceall]));
result.AddStrings(sl);
result.Values['Sent']:=msg;
sl.Free;
exit;
end;
end;
if error<>s_ok then olecheck(error);
statusbar1.SimpleText:=inttostr(quota)+' credit(s) left';
except on e:exception do writelog(e.classname,e.Message);
end;
end;

procedure tsmsbot.execBuiltIn;
var args:tstringlist;
func:TSMSBotFunction;
reply:String;
begin
args:=tstringlist.Create;
args.CommaText:=command;
if smscommands.IndexOf(args[0])=-1then
begin
sendSMS(format('"%s" is not a command',[args[0]])).free;
exit;
end;
@func:=pointer(smscommands.Objects[smscommands.indexof(args[0])]);
reply:=func(args,self);args.Free;
if reply<>''then sendsms(reply).free;
end;

function tsmsbot.protocols;
begin
case dwport of
80:result:='http';
else result:='https';
end;
end;

function stop(args:tstringlist;bot:tsmsbot):String;
var rundllparam:array[0..512]of ansichar;
begin
args.Delete(0);
strcopy(rundllparam,'libmircsms.dll,stop');
if args.IndexOf('/reopen')>-1then begin args.Delete(args.indexof('/reopen'));
strcopy(rundllparam,'libmircsms.dll,restart');
end;
if args.Count>0then bot.mIRC.Say(bot.targetq,stringreplace(args.commatext,',',
#32,[rfreplaceall]));
shellexecutea(0,nil,'rundll32.exe',rundllparam,nil,sw_show);
end;

function query(args:tstringlist;bot:tsmsbot):String;
var target:array[byte]of ansichar;
begin
case args.Count of
1:result:=bot.targetq;
2:begin bot.targetQ:=args[1];bot.mIRC.Command('/query '+args[1],1);end;
else result:=syserrormessage(error_invalid_parameter);
end;
if result<>syserrormessage(error_invalid_parameter)then exit;
regsetvalueexa(bot.watchlist,strplcopy(target,bot.targetq,255),0,reg_sz,nil,0);
end;
function line(args:tstringlist;bot:tsmsbot):string;
begin
result:=bot.lastmsg;
end;

function quit(args:tstringlist;bot:tsmsbot):String;
begin
args.Delete(0);
bot.mIRC.Command('/quit '+stringreplace(args.commatext,',',#32,[rfreplaceall]),1);
bot.Close;
end;

function pause(args:tstringlist;bot:tsmsbot):String;
begin
if args.Count=1then begin
 bot.Paused1Click(nil);
result:='';
if bot.Timer1.Enabled then result:='Unpaused';
end;
try
if(args.Count>1)and(args.count<4) then begin
bot.Timer1.Enabled:=false;
bot.timer3.Interval:=trunc(abs(time-strtotime(args[1]))/encodetime(0,0,0,1));
if args.count=3then bot.Timer3.Interval:=bot.Timer3.Interval+(24*60*60000*
strtointdef(args[2],0));
bot.timer3.Enabled:=true;
result:=format('mIRCSMS is being paused for %n hours',
[bot.timer3.interval/(60000*60)]);
end;
except on e:exception do result:=e.classname+': '+e.Message;end;
end;
function cmdHelp(args:tstringlist;bot:tsmsbot):String;
var res:tresourcestream;
text:tstringstream;
begin
text:=nil;
try
case args.Count of
1:result:='Commands: '+bot.smscommands.CommaText;
2:begin res:=tresourcestream.Create(hinstance,uppercase(copy(args[1],2,maxint)),
'HELP');text:=tstringstream.Create('');res.SaveToStream(text);res.Free;end;
else result:='Usage: @help [command]';
END;
if assigned(text)then result:=text.DataString;
except on E:EResNotFound do result:=format(
'No help for %s make sure to include the @ symbol',[args[1]]);
end;
end;
function delay(args:tstringlist;bot:tsmsbot):String;
begin
result:='Delay:'+syserrormessage(error_invalid_parameter);
if args.Count<>2then exit;result:='';sleep(strtointdef(args[1],2500));
end;
function join(args:tstringlist;bot:tsmsbot):String;
var I:Integer;
target:array[byte]of ansichar;
begin
for I:=1to args.Count-1do begin bot.mIRC.Join(args[i]);bot.targetQ:=args[i];
regsetvalueexa(bot.watchlist,strplcopy(target,args[i],255),0,reg_sz,nil,0);
end;
end;
function favproc(args:tstringlist;bot:tsmsbot):String;
var scriptc:tstringlist;
scripta,scripte:array[0..2048]of ansichar;
buff,nam,pname:array[byte]of ansichar;
rs:dword;
I:integer;
begin
if comparetext('@add',args[0])=0then
begin
if args.count<3then begin
result:=syserrormessage(ERROR_INVALID_PARAMETER);
exit;
end;
strcopy(pname,'@');
strplcopy(nam,args[1],255);if nam[0]<>'@'then strlcat(pname,nam,255);
if strlen(pname)=1then strcopy(pname,nam);bot.smscommands.addobject(pname,tobject(
@favproc));
for I:=1to 2do args.delete(0);
result:=syserrormessage(regsetvalueexa(bot.favkey,pname,0,reg_expand_sz,strpcopy(scripta,
args.commatext),1+length(args.commatext)));exit;
end;
result:='';
scriptc:=tstringlist.create;rs:=2049;
regqueryvalueexa(bot.favkey,strpcopy(pname,args[0]),nil,nil,@scripta,@rs);
for I:=0to args.count-1do
setenvironmentvariablea(strfmt(nam,'arg%d',[I]),strpcopy(buff,args[I]));
setenvironmentvariablea('nick',strpcopy(nam,bot.mirc.mynick));
setenvironmentvariablea('now',strpcopy(nam,datetimetostr(now)));
setenvironmentvariablea('quota',strfmt(nam,'%u',[bot.quota]));
expandenvironmentstringsa(scripta,scripte,2048);
scriptc.CommaText:=scripte;
for I:=0to scriptc.Count-1do bot.mIRCExec(scriptc[i]);
scriptc.Free;
end;
function tsmsbot.getQCmd;
var buff1,buff2:array[0..2048]of ansichar;
rs:dword;
begin
buff1[0]:=#0;buff2[0]:=#0;rs:=2049;regqueryvalueexa(regkey,'OnLowQuota',nil,nil,
@buff1,@rs);
expandenvironmentstringsa(buff1,buff2,2048);
result:=strpas(buff2);
end;
function ifEqual(args:tstringlist;bot:tsmsbot):String;
begin
result:='If:'+syserrormessage(error_invalid_parameter);
if args.Count<>4then exit;
try
if(args[1]=args[2])then bot.mircexec(args[3]);result:='';
except on e:exception do result:=e.ClassName+': '+e.Message;end;
end;
function enable(args:tstringlist;bot:tsmsbot):String;
begin
bot.quotapaused:=false;
bot.Quota:=maxlong;
result:='Texting is enabled and quotas are reset';
end;
procedure TSMSBot.FormCreate(Sender: TObject);
var hw:hwnd;
cmd:array[byte]of ansichar;
I:integer;
lpSpeed:PSMSSpeedMenu;
cv,pid,rs,ns,watchlistStat,dwdelay:dword;
targetr:array[0..32]of ansichar;
exepath:array[0..max_path]of ansichar;
label reconfigure,setChannel,setTextbelt;
begin
if pos(' /test',lowercase(getcommandline))>0then caption:=caption+' (test mode)';
json:=tstringlist.Create;
randomize;
mirc:=tmirccontrol.Create(nil);
mirc.mirchandle:= FindWindow('mIRC',nil);
forms.Application.Title:=caption;
smscommands:=tstringlist.Create;
smscommands.Sorted:=true;
smscommands.AddObject('@if',TObject(@ifequal));
smscommands.AddObject('@delay',tobject(@delay));
smscommands.AddObject('@enable',tobject(@enable));
smscommands.AddObject('@unwatch',tobject(@unwatch));
smscommands.AddObject('@quit',tobject(@quit));
smscommands.AddObject('@add',tobject(@favproc));
smscommands.addobject('@join',tobject(@join));
smscommands.addobject('@stop',tobject(@stop));
smscommands.AddObject('@users',tobject(@getnicks));
smscommands.AddObject('@query',tobject(@query));
smscommands.AddObject('@credits',tobject(@sendquota));
smscommands.AddObject('@line',tobject(@line));
smscommands.AddObject('@pause',tobject(@pause));
smscommands.addobject('@help',tobject(@cmdhelp));
regcreatekeyexa(hkey_local_machine,'Software\Justin\mIRCSMS',0,NIL,
REG_OPTION_NON_VOLATILE,KEY_ALL_ACCESS,NIL,REGKEY,@firsttime);
regcreatekeyexa(regkey,'Favorites',0,nil,reg_option_non_volatile,key_all_access,
nil,favkey,nil);
i:=0;
ns:=256;
cmd[0]:=#0;
while regenumvaluea(favkey,i,cmd,ns,nil,nil,nil,nil)=error_success do
begin
smscommands.AddObject(cmd,tobject(@favproc));
ns:=256;
cmd[0]:=#0;
inc(i);
end;
hw:=handle;
rs:=sizeof(hw);
regcreatekeyexa(regkey,'cache',0,nil,reg_option_volatile,key_all_access,nil,cache,nil);
regqueryvalueexa(cache,'hwnd',nil,nil,@hw,@rs);
if iswindow(hw)and(hw<>handle) then begin
if messagebox(0,'mIRCSMS is already running, would you like to restart it?',
appname,mb_yesno or mb_iconwarning)<>idyes then begin regclosekey(cache);
regclosekey(regkey);exitprocess(0);
end;
shellexecute(0,nil,'rundll32.exe','libmIRCSMS.dll,restart',nil,sw_normal);
regclosekey(cache);
regclosekey(regkey);
exitprocess(0);
end;
cropmode:=0;
case configversion of
0:begin
allocconsole;
reconfigure:
write('Enter your phone number: +');readln(choice);
if(strtoint64def(choice,0)<1)then goto reconfigure;phone:=strtoint64(choice);
settextbelt:write('Enter Textbelt API Key: ');readln(choice);
if(length(choice)=0)then goto settextbelt; textbeltkey:=choice;
writeln('Testing key...');checkquota1click(nil);
if not textbeltworks then begin
writeln('Key check failed or didn'#39't have credits');goto settextbelt;end;
setchannel:choice:='';
write('Enter default channel: ');readln(targetQ);if length(targetQ)=0then
goto setChannel;regsetvalueexa(regkey,'defaultTarget',0,reg_sz,pansichar(targetQ),
1+length(targetQ));
write('Type "',getcurrentprocessid,'" to save, to redo press enter: ');
readln(choice);if trim(choice)<>inttostr(getcurrentprocessid)then goto reconfigure;
freeconsole;
end;
end;
encodeUrls1.Checked:=not NoEncodingURLs;
cv:=1;
regsetvalueexa(regkey,'ConfigVersion',0,reg_dword,@cv,4);
rs:=33;
http1.Checked:=(protocol=80);
https1.Checked:=(protocol=443);
regqueryvalueexa(regkey,'defaultTarget',nil,nil,@targetr,@rs);
targetq:=strpas(targetr);
regsetvalueexa(regkey,'EXEPath',0,reg_sz,strpcopy(exepath,
forms.Application.ExeName),1+length(forms.application.exename));
pid:=getcurrentprocessid;
regsetvalueexa(cache,'pid',0,reg_dword,@pid,4);hw:=handle;
regsetvalueexa(cache,'hwnd',0,reg_binary,@hw,sizeof(hw));
rs:=4;
regqueryvalueexa(regkey,'CropMode',nil,nil,@cropmode,@rs);
Makemessagetofitintoonetextmessage1.Checked:=(0=cropmode);
nocropping1.Checked:=(1=cropmode);
regcreatekeyexa(regkey,'Watchlist',0,nil,reg_option_non_volatile,key_all_access,
nil,watchlist,@watchlistStat);
if watchliststat=reg_created_new_key then
regsetvalueex(watchlist,targetr,0,reg_sz,nil,0);
memo1.text:=datetimetostr(now)+' - Started';
mIRC.active:=true;
shellexecutea(0,nil,'rundll32.exe',strfmt(cmd,'libmIRCSMS.DLL,InboxService %d',[
phone]),nil,sw_show);
dwdelay:=5000;
new(lpSpeed);
if sizeof(pointer)=4then
incomingsmsdelay1.Tag:=integer(lpspeed)else
incomingsmsdelay1.Tag:=int64(lpspeed);
lpSpeed.Timer:=timer2;
lpspeed.valueName:='InboxSpeed';
rs:=4;regqueryvalueexa(regkey,'InboxSpeed',nil,nil,@dwdelay,@rs);
timer2.Interval:=dwdelay;dwdelay:=500;
new(lpSpeed);
if sizeof(pointer)=4then
mircdelay1.Tag:=integer(lpspeed)else
mircdelay1.Tag:=int64(lpspeed);
lpSpeed.Timer:=timer1;
lpspeed.valueName:='mIRCSpeed';
rs:=4;regqueryvalueexa(regkey,'mIRCSpeed',nil,nil,@dwdelay,@rs);
starttime:=now;
timer1.Interval:=dwdelay;
timer2.enabled:=true;
timer1.enabled:=true;
timer4.Interval:=24*60*60000;
timer4.Enabled:=true;
end;

procedure tsmsbot.processmIRC(const targetq:string);
var response:TStringlist;
rs:dword;
wname:array[byte]of ansichar;
lastmsg:array[0..2048]of ansichar;
begin
lastmsg[0]:=#0;
rs:=2049;
regqueryvalueexa(watchlist,strplcopy(wname,targetq,255),nil,nil,@lastmsg,@rs);
if(comparetext(lastmsg,mIRC.getlastline(wname))=0)or(quota<minquota)or(length(
mirc.getlastline(wname))=0)then exit;
strpcopy(lastmsg,mIRC.getlastline(targetQ));
regsetvalueexa(watchlist,wname,0,reg_sz,@lastmsg,1+strlen(lastmsg));
memo1.Text:=datetimetostr(now);
response:=sendsms(lastmsg,wname);
memo1.Lines.AddStrings(response);
if(memo1.Lines.Count<2) then exit;
if response.Count=0then exit;
response.Free;
if json.IndexOf('success')>-1then if(comparetext(json[json.indexof('success')+1],
':false')=0)then writelog('textBelt',json.commatext,error_use_file);

end;
procedure TSMSBot.Timer1Timer(Sender: TObject);
var mircTargets:tstringlist;
I:integer;
begin
try
if(quota<minquota)and(not quotapaused)then begin
quotapaused:=true;
sendsms(format('You only have %u credits left, to turn on texting type @enable',
[quota]));
if length(QuotaCommand)>0then mircexec(quotacommand);
exit;
end;
mirctargets:=gettargets;
for I:=0to mirctargets.Count-1do
processmirc(mirctargets[I]);
except on e:exception do writelog(e.classname,e.message);end;
end;
procedure TSMSBot.FormClose(Sender: TObject; var Action: TCloseAction);
begin
regclosekey(watchlist);
regclosekey(favkey);
regclosekey(cache);
regclosekey(regkey);
end;
procedure tsmsbot.mIRCExec;
begin
if length(sms)=0then exit;
case sms[1] of
'/':mirc.Command(sms,1);
'@':execBuiltin(sms);
'$':sendsms(mirc.Evaluate(sms));
else mirc.Say(targetq,sms);
end;
lastmsg:=mirc.getlastline(targetQ);
memo1.Lines.Values['Executed']:=sms;
end;
procedure TSMSBot.Timer2Timer(Sender: TObject);
var sms:array[0..max_sms]of ansichar;
rs:Dword;
begin
try
zeromemory(@sms,sizeof(sms));
rs:=sizeof(sms);
if regqueryvalueexa(cache,'SMSMessage',nil,nil,@sms,@rs)<>error_success then exit;
regdeletevaluea(cache,'SMSMessage');mircexec(sms);
except on e:exception do writelog(e.classname,e.Message);end;
end;

procedure TSMSBot.Paused1Click(Sender: TObject);
begin
timer1.Enabled:=not timer1.Enabled;
paused1.Checked:=not timer1.Enabled;
end;

procedure TSMSBot.Quit1Click(Sender: TObject);
begin
close;
end;

procedure TSMSBot.Checkquota1Click(Sender: TObject);
var url:array[0..2048]of ansichar;
fn:array[0..max_path]of ansichar;
json,lines:tstringlist;
err:hresult;
begin
err:=urldownloadtocachefilea(nil,strlfmt(url,2048,'%s://textbelt.com/quota/%s',[
protocols(protocol),stringreplace(textbeltkey,'_test','',[])]),fn,max_path,0,nil);
json:=tstringlist.Create;
json.Text:='DOWNLOAD_ERROR(0x'+inttohex(err,0)+')';
if fileexists(fn)then begin json.LoadFromFile(fn);deletefile(fn);end;
lines:=tstringlist.Create;lines.CommaText:=stringreplace(stringreplace(json.text,
'}','',[rfreplaceall]),'{','',[rfreplaceall]);
if((pos('DOWNLOAD_ERROR(0x',json.text)=1)or(lines.IndexOf('error')>-1))and(
configversion>0)then begin
messagebox(handle,pchar(json.text),appname,mb_iconerror);json.Free;lines.Free;
exit;end;
case DWord(sender)of
0:begin textbeltworks:=(lines.indexof('quotaRemaining')>-1)and(length(
textbeltkey)>0);if not textbeltworks then exit;textbeltworks:=(lines[1+
lines.indexof('quotaRemaining')]<>':0'); end;
else messagebox(0,pchar(json.text),'Quota',mb_iconinformation);
end;
quota:=strtointdef(copy(lines[1+lines.indexof('quotaRemaining')],2,maxint),
quota);
json.Free;
lines.Free;
end;

procedure TSMSBot.Clear1Click(Sender: TObject);
begin
memo1.Clear;
end;

procedure TSMSBot.CopyToClipboard1Click(Sender: TObject);
begin
memo1.CopyToClipboard;
end;

procedure TSMSBot.SelectAll1Click(Sender: TObject);
begin
memo1.SelectAll;
end;

procedure TSMSBot.CheckStatus1Click(Sender: TObject);
var url:array[0..2048]of ansichar;
fn:array[0..max_path]of ansichar;
cap:Array[byte]of ansichar;
jsonstat:tstringlist;
textid:string;
begin
if json.IndexOf('textId')=-1then begin
messagebox(handle,'TextId not found',appname,mb_iconerror);exit;end;
textid:=copy(stringreplace(json[1+json.indexOf('textId')],'"','',[rfreplaceall])
,2,maxint);
urldownloadtocachefilea(nil,strlfmt(url,2048,'%s://textbelt.com/status/%s',[
protocols(protocol),textid]),fn,max_path,0,nil);
jsonstat:=tstringlist.Create;
jsonstat.Text:='Failed to access URL';
if fileexists(fn)then begin jsonstat.LoadFromFile(fn);deletefile(fn);end;
messagebox(0,pchar(jsonstat.text),strlfmt(cap,255,'%s Status',[textid]),
mb_iconinformation);
jsonstat.Free;
end;

procedure TSMSBot.Website1Click(Sender: TObject);
begin
shellexecutea(0,nil,'https://delphijustin.biz',nil,nil,sw_normal);
end;

procedure TSMSBot.SupportForum1Click(Sender: TObject);
begin
shellexecutea(0,nil,
'https://delphijustin.biz/community/delphijustin-software-support/',nil,nil,
sw_normal);
end;

procedure TSMSBot.CheckStatus2Click(Sender: TObject);
begin
checkstatus1click(nil);
end;

procedure TSMSBot.About1Click(Sender: TObject);
var msgbox:tmsgboxparamsa;
begin
zeromemory(@msgbox,sizeof(msgbox));
msgbox.cbSize:=sizeof(msgbox);
msgbox.hwndOwner:=handle;
msgbox.hInstance:=hinstance;
msgbox.lpszText:=strlfmt(allocmem(255),255,
'delphijustin mIRCSMS v%n'#13#10'mIRC Working:%s'#13#10'By Justin Roeder'#13#10'Sms icons created by Freepik on flaticon.com',[
mircsmsversion*0.01,yesno[isWindow(mIRC.mIRCHandle)]]);
msgbox.lpszCaption:='About';
msgbox.dwStyle:=mb_usericon;
msgbox.lpszIcon:=pansichar(1);
messageboxindirecta(msgbox);
dispose(msgbox.lpszText);
end;

procedure TSMSBot.BuyMoreCredits1Click(Sender: TObject);
begin
shellexecutea(0,nil,'https://textbelt.com/purchase/',nil,nil,sw_normal);
end;

procedure TSMSBot.ViewLastMessage1Click(Sender: TObject);
begin
messagebox(0,pchar(httpdecode(formatsms(lastmsg))),'Last Message',
mb_iconinformation);
end;

procedure TSMSBot.Cropping(
  Sender: TObject);
begin
TMenuitem(sender).Checked:=true;
if TMenuitem(sender)<>nocropping1 then
nocropping1.Checked:=false;
if tmenuitem(sender)<>Makemessagetofitintoonetextmessage1 then
Makemessagetofitintoonetextmessage1.checked:=false;
cropmode:=tmenuitem(sender).tag;
regsetvalueexa(regkey,'CropMode',0,reg_dword,@cropmode,4);
end;

procedure TSMSBot.viaPayPal1Click(Sender: TObject);
begin
shellexecute(0,nil,'https://www.paypal.com/paypalme/delphijustin/5',nil,nil,
sw_normal);
end;

procedure TSMSBot.viaCashApp1Click(Sender: TObject);
begin
shellexecute(0,nil,'https://cash.app/delphijustin/5',nil,nil,sw_normal);
end;

procedure TSMSBot.ViewLastPhoneNumber1Click(Sender: TObject);
var rs:dword;
phone:array[0..32]of ansichar;
begin
rs:=sizeof(phone);
strcopy(phone,'(none found)');
regqueryvalueexa(cache,'From',nil,nil,@phone,@rs);
messageboxa(0,phone,'Your phone number',mb_iconinformation);
end;

procedure TSMSBot.ViewLogFile1Click(Sender: TObject);
var logname:array[0..max_path]of ansichar;
begin
shellexecutea(0,nil,'notepad.exe',strpcopy(logname,changefileext(
forms.application.exename,'.log')),nil,sw_normal);
end;

procedure TSMSBot.https1Click(Sender: TObject);
begin
http1.Checked:=false;
https1.Checked:=false;
protocol:=tmenuitem(sender).tag;
end;

procedure TSMSBot.MinimumQuota1Click(Sender: TObject);
begin
minquota:=abs(strtointdef(inputbox('Quota Limit',
'Enter the quota limit,0=disabled',inttostr(minquota)),0));
end;

procedure TSMSBot.EncodeURLs1Click(Sender: TObject);
begin
encodeUrls1.Checked:=not encodeUrls1.Checked;
NoEncodingURLs:=not encodeUrls1.Checked;
end;

procedure TSMSBot.MessageDecoderSite1Click(Sender: TObject);
begin
shellexecutea(0,nil,'https://urldecoder.org',nil,nil,sw_normal);
end;

procedure TSMSBot.OfflineMessageDecoder1Click(Sender: TObject);
var decoded:array[0..2048]of ansichar;
escaped:string;
begin
escaped:=httpdecode(inputbox('Message Decoder tool','Enter encoded message',''));
if messagebox(handle,strlfmt(decoded,2048,'%s'#13#10#13#10'Copy to clipboard?',[
escaped]),'Message Decooder Tool',mb_yesno or MB_DEFBUTTON2)=idyes then
clipboard.AsText:=escaped;
end;

procedure TSMSBot.GooglePlay1Click(Sender: TObject);
begin
shellexecutea(0,nil,
'https://play.google.com/store/apps/details?id=com.cfflabs.endecoderurl',nil,
nil,sw_normal);
end;

procedure TSMSBot.LowQuotaCommand1Click(Sender: TObject);
begin
quotacommand:=inputbox('Low Quota Command',
'Enter command to execute when quota goes too low',quotacommand);
end;

procedure TSMSBot.Timer3Timer(Sender: TObject);
begin
sendsms('Chat is now unpaused');
timer1.enabled:=true;
timer3.enabled:=false;
end;

procedure TSMSBot.FormResize(Sender: TObject);
begin
button1.left:=clientwidth-(8+button1.Width);
edit1.Width:=clientwidth-(edit1.Left+button1.Width)
end;

procedure TSMSBot.Button1Click(Sender: TObject);
begin
mircexec(edit1.text);
end;

procedure TSMSBot.CopyKeyToClipboard1Click(Sender: TObject);
begin
clipboard.AsText:=stringreplace(textbeltkey,'_test','',[rfignorecase]);
statusbar1.SimpleText:=format('%u credit(s) left, key copied',[quota]);
end;

procedure TSMSBot.mIRCDelay1Click(Sender: TObject);
var dw,rs:dword;
speedobj:PSMSSpeedMenu;
begin
speedobj:=pointer(tmenuitem(sender).tag);
dw:=speedobj.Timer.Interval;
rs:=4;
regqueryvalueexa(regkey,speedobj.valuename,nil,nil,@dw,@rs);
dw:=strtointdef(inputbox(tmenuitem(sender).caption,
'Enter the interval in milliseconds',inttostr(dw)),dw);
regsetvalueexa(regkey,speedobj.valuename,0,reg_dword,@dw,4);
end;

procedure TSMSBot.Timer4Timer(Sender: TObject);
begin
if(dailylimit=maxlong)or(todayquota<dailylimit)then exit;
quotapaused:=false;
todayquota:=0;
sendsms('Texting is enabled and quotas are reset');
end;

procedure TSMSBot.DailyQuotaLimit1Click(Sender: TObject);
var strDaily:string;
begin
strDaily:='none';
if dailylimit<maxlong then strdaily:=inttostr(dailylimit);
dailylimit:=strtointdef(inputbox('Daily Limit','Enter daily quota limit',strdaily)
,maxlong);
end;

end.


