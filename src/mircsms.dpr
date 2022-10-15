program mircsms;

uses
  Forms,
  smsUnit1 in 'smsUnit1.pas' {SMSBot},
  mIRCc in '..\include\mIRCc.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TSMSBot, SMSBot);
  Application.Run;
end.
