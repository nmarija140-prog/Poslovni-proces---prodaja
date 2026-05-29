unit NovKlijent;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit,
  Data.DB, Data.Win.ADODB, FMX.Layouts, FMX.ListBox;

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
    PIB: TEdit;
    Grad: TEdit;
    ListaGradovi: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure sacuvajKlijentaDugmeClick(Sender: TObject);
    procedure GradChangeTracking(Sender: TObject);
procedure ListaGradoviItemClick(const Sender: TCustomListBox;
  const Item: TListBoxItem);
  private
  GradID: Integer;
  public
  LoginIDZaUnos: Integer;
  end;

var
  Form10: TForm10;

implementation

{$R *.fmx}

procedure TForm10.FormCreate(Sender: TObject);
var
  dbPath: string;
begin
ListaGradovi.Width := Grad.Width;
ListaGradovi.Height := 150;

ListaGradovi.Position.X := Grad.Position.X;

ListaGradovi.Position.Y :=
  Grad.Position.Y + Grad.Height;

ListaGradovi.BringToFront;
ListaGradovi.Visible := False;
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
    '(nazivKlijenta, adresa, telefon, email, kontaktOsoba, PIB, GradID, KorisnickoIme) ' +
    'VALUES (:nazivKlijenta, :adresa, :telefon, :email, :kontaktOsoba, :PIB, :GradID, :KorisnickoIme)'
  );

  ADOQuery1.Parameters.ParamByName('nazivKlijenta').Value := nazivKlijenta.Text;
  ADOQuery1.Parameters.ParamByName('adresa').Value := adresa.Text;
  ADOQuery1.Parameters.ParamByName('telefon').Value := telefon.Text;
  ADOQuery1.Parameters.ParamByName('email').Value := email.Text;
  ADOQuery1.Parameters.ParamByName('kontaktOsoba').Value := kontaktOsoba.Text;
  ADOQuery1.Parameters.ParamByName('PIB').Value := PIB.Text;
ADOQuery1.Parameters.ParamByName('GradID').Value := GradID;
ADOQuery1.Parameters.ParamByName('KorisnickoIme').Value := email.Text;


  ADOQuery1.ExecSQL;

  ShowMessage('Klijent je uspešno sa?uvan!');
  Close;
end;
procedure TForm10.GradChangeTracking(Sender: TObject);
begin
  GradID := -1;

  if Trim(Grad.Text) = '' then
  begin
    ListaGradovi.Visible := False;
    Exit;
  end;

  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;

  ADOQuery1.SQL.Text :=
    'SELECT GradID, Grad FROM Gradovi ' + 'WHERE Grad LIKE :p ' +
    'ORDER BY grad';

  ADOQuery1.Parameters.ParamByName('p').Value :=
    Grad.Text + '%';

  ADOQuery1.Open;

  ListaGradovi.Clear;

  while not ADOQuery1.Eof do
  begin
    ListaGradovi.Items.Add(
      ADOQuery1.FieldByName('Grad').AsString
    );

    ADOQuery1.Next;
  end;

  ListaGradovi.Visible := ListaGradovi.Items.Count > 0;

  ListaGradovi.Height :=
    ListaGradovi.Items.Count * 35;

  if ListaGradovi.Height > 150 then
    ListaGradovi.Height := 150;

  ListaGradovi.BringToFront;
end;
procedure TForm10.ListaGradoviItemClick(
  const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  Grad.Text := Item.Text;

  ListaGradovi.Visible := False;

  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;

  ADOQuery1.SQL.Text :=
    'SELECT GradID FROM Gradovi ' +
    'WHERE Grad = :n';

  ADOQuery1.Parameters.ParamByName('n').Value :=
    Item.Text;

  ADOQuery1.Open;

  GradID :=
    ADOQuery1.FieldByName('GradID').AsInteger;
end;

end.

