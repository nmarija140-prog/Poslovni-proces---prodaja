unit NovKlijent;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit,
  Data.DB, Data.Win.ADODB;

type
  TForm10 = class(TForm)
    otkayiDugme2: TButton;
    telefon: TEdit;
    email: TEdit;
    kontaktOsoba: TEdit;
    nazivKlijenta: TEdit;
    adresa: TEdit;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    sacuvajKlijentaDugme: TButton;
    procedure FormCreate(Sender: TObject);
    procedure sacuvajKlijentaDugmeClick(Sender: TObject);
  private
  public
  end;

var
  Form10: TForm10;

implementation

{$R *.fmx}

procedure TForm10.FormCreate(Sender: TObject);
var
  dbPath: string;
begin
  dbPath := ExtractFilePath(ParamStr(0)) + 'mpmBaza.mdb';
  if not FileExists(dbPath) then
  begin
    ShowMessage('Baza ne postoji na lokaciji: ' + dbPath);
    Exit;
  end;
  try
    ADOConnection1.ConnectionString :=
      'Provider=Microsoft.Jet.OLEDB.4.0;'+
      'Data Source=' + dbPath + ';';
    ADOConnection1.Connected := True;
  except
    on E: Exception do
    begin
      ShowMessage('Greška pri konekciji sa bazom: ' + E.Message);
      Exit;
    end;
  end;
end;



procedure TForm10.sacuvajKlijentaDugmeClick(Sender: TObject);
begin
if nazivKlijenta.Text.Trim = '' then
begin
  ShowMessage('Unesi naziv klijenta!');
  Exit;
end;

if adresa.Text.Trim = '' then
begin
  ShowMessage('Unesi adresu!');
  Exit;
end;

if telefon.Text.Trim = '' then
begin
  ShowMessage('Unesi telefon!');
  Exit;
end;

if email.Text.Trim = '' then
begin
  ShowMessage('Unesi email!');
  Exit;
end;

if kontaktOsoba.Text.Trim = '' then
begin
  ShowMessage('Unesi kontakt osobu!');
  Exit;
end;

  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;

  ADOQuery1.SQL.Add(
    'INSERT INTO Klijenti ' +
    '(nazivKlijenta, adresa, telefon, email, kontaktOsoba) ' +
    'VALUES (:nazivKlijenta, :adresa, :telefon, :email, :kontaktOsoba)'
  );

  ADOQuery1.Parameters.ParamByName('nazivKlijenta').Value := nazivKlijenta.Text;
  ADOQuery1.Parameters.ParamByName('adresa').Value := adresa.Text;
  ADOQuery1.Parameters.ParamByName('telefon').Value := telefon.Text;
  ADOQuery1.Parameters.ParamByName('email').Value := email.Text;
  ADOQuery1.Parameters.ParamByName('kontaktOsoba').Value := kontaktOsoba.Text;


  ADOQuery1.ExecSQL;

  ShowMessage('Klijent je uspešno sa?uvan!');
  Close;
end;

end.
