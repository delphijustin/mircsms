library libmIRCSMS;
{$RESOURCE MIRCSMSDLL.RES}
uses
  SysUtils,
  windows,shellapi,
  Classes,urlmon;
const reg_mirc_path_key='SOFTWARE\Clients\IM\mIRC\shell\open\command';

procedure stopA(hw:hwnd;inst:hinst;params:pansichar;nShow:integer);stdcall;
var cache:hkey;
rs,pid:dword;
hp:thandle;
begin
regopenkeyexa(hkey_local_machine,'Software\Justin\mIRCSMS\cache',0,key_read,cache);
pid:=0;
rs:=4;
regqueryvalueexa(cache,'pid',nil,nil,@pid,@rs);
regclosekey(cache);
hp:=openprocess(process_terminate,false,pid);
terminateprocess(hp,0);
closehandle(hp);
end;
function protocols(dwPort:dword):string;
begin
case dwport of
80:result:='http';
else result:='https';
end;
end;

function mIRCSMSVersion:dword;
begin
result:=100;
end;

procedure InboxServiceA(hw:hwnd;inst:hinst;phone:pansichar;nShow:Integer);stdcall;
var cache,appkey:hkey;
hwApp:hwnd;
from:array[0..32]of ansichar;
smsmsg:array[0..160]of ansichar;
url,fn:array[0..max_path]of ansichar;
updateDate,rs,protocol,delay:dword;
begin
regopenkeyexa(hkey_local_machine,'Software\Justin\mIRCSMS',0,key_all_access,
appkey);
protocol:=443;
rs:=4;regqueryvalueexa(appkey,'Protocol',nil,nil,@protocol,@rs);
regopenkeyexa(appkey,'Cache',0,key_all_access,cache);
rs:=sizeof(hw);regqueryvalueexa(cache,'hwnd',nil,nil,@hwapp,@rs);
updatedate:=0;
while iswindow(hwapp) do begin
delay:=5000;
rs:=4;regqueryvalueexa(appkey,'InboxSpeed',nil,nil,@delay,@rs);
urldownloadtocachefilea(nil,strfmt(url,
'%s://delphianserver.com/outbox/scan.php?p=%s&now=%g',[protocols(protocol),phone,
now]),fn,max_path,0,nil);
rs:=4;
regqueryvalueexa(cache,'UpdateDate',nil,nil,@updatedate,@rs);
if(getprivateprofileinta('mIRCSMS','version',mircsmsversion,fn)>mircsmsversion)
and(trunc(date)<>updatedate)then begin updatedate:=trunc(date);
case messagebox(0,'A new version of mIRCSMS is avalible,'#13#10'Download now?',
'mIRCSMS Updates',mb_iconinformation or mb_yesno)of
idno:regsetvalueexa(cache,'UpdateDate',0,reg_dword,@updatedate,4);
idyes:begin stopA(hw,0,'update',nshow);getprivateprofilestringa('updates',
'webpage','https://delphijustin.biz',strcopy(url,''),max_path,fn);
shellexecutea(0,nil,url,nil,nil,sw_normal);end;
 end;
 end;
if getprivateprofileIntA('stats','error',maxword,fn)=0then begin
getprivateprofilestringa('message','message','',smsmsg,160,fn);
getprivateprofilestringa('message','phone','N/A',from,32,fn);
DeleteFileA(fn);
fn[0]:=#0;
regsetvalueexa(cache,'SMSMessage',0,reg_sz,@smsmsg,1+strlen(smsmsg));
regsetvalueexa(cache,'From',0,reg_sz,@from,1+strlen(from));
end;
sleep(delay);
end;
regclosekey(cache);regclosekey(appkey);
end;
procedure pauseSMSA(hw:hwnd;inst:hinst;delay:PANSICHAR;nshow:integer);stdcall;
var cache:hkey;
smsmsg:array[byte]of ansichar;
begin
regcreatekeyexa(hkey_local_machine,'Software\Justin\mIRCSMS\cache',0,nil,
reg_option_volatile,key_all_access,nil,cache,nil);
strcopy(smsmsg,'@pause');
if delay<>nil then
if strlen(delay)>0 then
strlfmt(strend(smsmsg),255,' %s',[delay]);
regsetvalueexa(cache,'SMSMessage',0,reg_sz,@smsmsg,1+strlen(smsmsg));
regclosekey(cache);
end;
procedure startA(hw:hwnd;inst:hinst;params:pansichar;nShow:Integer);stdcall;
var mircCmd:pointer;
hkClient,appkey,cache:HKey;
ec,rs:dword;
exec,smsbot:tshellexecuteinfoa;
Trys:integer;
hwSMS:HWND;
begin
regopenkeyexa(hkey_current_user,reg_mirc_path_key,0,key_read,hkclient);
rs:=513;
mirccmd:=allocmem(513);
if error_success<>regqueryvalueexa(hkclient,nil,nil,nil,mirccmd,@rs)then
FatalAppExit(0,'Client reg failed');
zeromemory(@exec,sizeof(exec));
exec.cbSize:=sizeof(exec);
exec.Wnd:=hw;
exec.lpFile:=strpcopy(mirccmd,stringreplace(strpas(mirccmd),' %1','',[]));
exec.lpParameters:=allocmem(2049);
rs:=2049;
regqueryvalueex(appkey,'mIRCParameters',nil,nil,pointer(exec.lpparameters),@rs);
smsbot.nShow:=nshow;
exec.nShow:=nshow;
if FindWindow('mIRC',nil)=0then
if not shellexecuteex(@exec)then begin
dispose(mirccmd);
regclosekey(hkclient);
exit;
end;
regclosekey(hkclient);
hwSMS:=0;
regopenkeyexa(hkey_local_machine,'Software\Justin\mIRCSMS',0,KEY_READ,APPKEY);
regopenkeyexa(appkey,'cache',0,key_read,cache);
rs:=sizeof(hwnd);
regqueryvalueex(cache,'hwnd',nil,nil,@hwsms,@rs);
if iswindow(hwsms)then begin
regclosekey(cache);
regclosekey(appkey);
exitprocess(1);
end;
trys:=20;
repeat
dec(trys);
sleep(1000);
until(trys<0)and(FindWindow('mIRC',nil)<>0);
zeromemory(@smsbot,sizeof(smsbot));
smsbot.cbSize:=sizeof(smsbot);
smsbot.lpFile:=allocmem(max_path+1);
rs:=max_path+1;
regqueryvalueex(appkey,'EXEPath',nil,nil,pointer(smsbot.lpfile),@rs);
rs:=2049;
smsbot.Wnd:=hw;
smsbot.lpDirectory:=strpcopy(allocmem(strlen(smsbot.lpfile)),extractfilepath(
smsbot.lpfile));
smsbot.fMask:=see_mask_nocloseprocess;
smsbot.lpParameters:=params;
if not shellexecuteex(@smsbot) then
begin
regclosekey(cache);
regclosekey(appkey);
exitprocess(3);
end;
ec:=still_active;
while ec=still_active do begin
getexitcodeprocess(smsbot.hProcess,ec);
sleep(1000);
end;
closehandle(smsbot.hProcess);
if ec<>0 then begin
sleep(10000);
shellexecutea(hw,nil,'rundll32.exe','libmIRCSMS.dll,restart /CRASH',NIL,NSHOW);
end;
exitprocess(ec);
end;
procedure helpA(hw:hwnd;inst:hinst;name:pansichar;nShow:integer);stdcall;
begin
messageboxa(hw,pansichar(
'Usage: rundll32 libmIRCSMS.dll,<commandname> "Parameters"'#13#10+
'start [mircsms_parameters] Starts mIRC and the bot'#13#10+
'stop                       Stops the bot and leaves mIRC running'#13#10+
'restart [start_parameters] Calls stop function then calls start function'#13#10+
'pauseSMS [enable_time] [days] Executes @pause on the running bot, good for scheduled Task'#13#10#13#10+
'To get help with a certain command via text messaging just text @help'
),'mIRCSMS Help',0);
end;
procedure restartA(hw:hwnd;inst:hinst;params:pansichar;nShow:integer);stdcall;
begin
stopa(hw,0,nil,nShow);
startA(hw,0,params,nShow);
end;
exports stopA,pauseSMSA,helpA,startA,restartA,InboxServiceA,mIRCSMSVersion;
begin
end.
