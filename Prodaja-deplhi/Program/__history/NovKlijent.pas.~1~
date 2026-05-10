unit NovKlijent;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, Data.DB, Data.Win.ADODB;

type
  TForm10 = class(TForm)
    sacuvajKlijentaDugme: TButton;
    otkayiDugme2: TButton;
    telefon: TEdit;
    email: TEdit;
    kontaktOsoba: TEdit;
    nazivKlijenta: TEdit;
    adresa: TEdit;
    ADOQuery1: TADOQuery;
    ADOConnection1: TADOConnection;
    procedure sacuvajKlijentaDugmeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
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
  if Trim(nazivKlijenta.Text) = '' then
  begin
    ShowMessage('Unesi naziv klijenta');
    Exit;
  end;

  ADOQuery1.Close;
  ADOQuery1.SQL.Text :=
    'INSERT INTO klijenti (nazivKlijenta, adresa, kontaktOsoba, email, brojTelefona) ' +
    'VALUES (:naziv, :adresa, :kontakt, :email, :telefon)';

  ADOQuery1.Parameters.ParamByName('naziv').Value := nazivKlijenta.Text;
  ADOQuery1.Parameters.ParamByName('adresa').Value := adresa.Text;
  ADOQuery1.Parameters.ParamByName('kontakt').Value := kontaktOsoba.Text;
  ADOQuery1.Parameters.ParamByName('email').Value := email.Text;
  ADOQuery1.Parameters.ParamByName('telefon').Value := telefon.Text;

  try
    ADOQuery1.ExecSQL;
    ShowMessage('Klijent uspešno dodat');
    ModalResult := mrOk;
  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;
end.
