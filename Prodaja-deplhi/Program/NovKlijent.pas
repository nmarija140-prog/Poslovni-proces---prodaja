unit NovKlijent;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit,
  Data.DB, Data.Win.ADODB;

type
  TForm10 = class(TForm)
    sacuvajKlijentaDugme: TButton;
    otkayiDugme2: TButton;
    telefon: TEdit;
    email: TEdit;
    kontaktOsoba: TEdit;
    nazivKlijenta: TEdit;
    adresa: TEdit;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;

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
  try
    dbPath := ExtractFilePath(ParamStr(0)) + 'mpmBaza.mdb';

    ADOConnection1.LoginPrompt := False;
    ADOConnection1.Connected := False;

    ADOConnection1.ConnectionString :=
      'Provider=Microsoft.ACE.OLEDB.4.0;' +
      'Data Source=' + dbPath + ';' +
      'Persist Security Info=False;';

    ADOConnection1.Connected := True;

    ADOQuery1.Connection := ADOConnection1;

  except
    on E: Exception do
      ShowMessage('Greška konekcije: ' + E.Message);
  end;
end;

procedure TForm10.sacuvajKlijentaDugmeClick(Sender: TObject);
begin
  if Trim(nazivKlijenta.Text) = '' then
  begin
    ShowMessage('Unesi naziv klijenta');
    Exit;
  end;

  try
    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;

    ADOQuery1.SQL.Text :=
      'INSERT INTO Klijenti ' +
      '(nazivKlijenta, kontaktOsoba, telefon, email, adresa) ' +
      'VALUES ' +
      '(:nazivKlijenta, :kontaktOsoba, :telefon, :email, :adresa)';

    ADOQuery1.Parameters.ParamByName('nazivKlijenta').Value := nazivKlijenta.Text;
    ADOQuery1.Parameters.ParamByName('kontaktOsoba').Value := kontaktOsoba.Text;
    ADOQuery1.Parameters.ParamByName('telefon').Value := telefon.Text;
    ADOQuery1.Parameters.ParamByName('email').Value := email.Text;
    ADOQuery1.Parameters.ParamByName('adresa').Value := adresa.Text;

    ADOQuery1.ExecSQL;

    ShowMessage('Klijent uspešno sa?uvan');
    ModalResult := mrOk;

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

end.
