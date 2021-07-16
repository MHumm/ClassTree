program Klassenbaum;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  DECHash in '..\DECGitMaster\Source\DECHash.pas',
  DECHashAuthentication in '..\DECGitMaster\Source\DECHashAuthentication.pas',
  DECHashBase in '..\DECGitMaster\Source\DECHashBase.pas',
  DECHashBitBase in '..\DECGitMaster\Source\DECHashBitBase.pas',
  DECHashInterface in '..\DECGitMaster\Source\DECHashInterface.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
