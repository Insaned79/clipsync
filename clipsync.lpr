program clipsync;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main
  { you can add units after this },UniqueInstanceRaw;

{$R *.res}

begin
  if not InstanceRunning('clipsync') then
  begin
    RequireDerivedFormResource:=True;
  Application.Scaled:=True;
    Application.Initialize;
    Application.CreateForm(TMainForm, MainForm);
    Application.Run;
  end;
end.

