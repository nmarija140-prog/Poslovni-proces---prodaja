unit UnosPodataka;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  pocetna, FMX.Edit, FMX.Objects, FMX.StdCtrls, FMX.Controls.Presentation,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef, Data.Win.ADODB, System.Hash,
  System.IniFiles;

type
  TForm2 = class(TForm)
    SpeedButton1: TSpeedButton;
    Text1: TText;
    txtbKorisnickoime: TEdit;
    txtbSifra: TEdit;
    PrijavaBtn: TButton;
    Image1: TImage;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    DataSource1: TDataSource;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure PrijavaBtnClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

uses Menadzer, Admin, disp,Klijent, Vozac;

procedure TForm2.FormCreate(Sender: TObject);
    var
  dbPath: string;
begin
  // Lokacija baze
  dbPath := ExtractFilePath(ParamStr(0)) + 'mpmBaza.mdb';

  // Provera da li fajl baze postoji
  if not FileExists(dbPath) then
  begin
    ShowMessage('Baza ne postoji na lokaciji: ' + dbPath);
    Exit;
  end;

  // Povezivanje sa bazom u try except
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

{procedure TForm2.HashDugmeClick(Sender: TObject);
var
  username, plainPass, hashedPass: string;
begin
  ADOQuery1.Close;
  ADOQuery1.SQL.Text := 'SELECT korisnickoime, sifra FROM login';
  ADOQuery1.Open;

  while not ADOQuery1.Eof do
  begin
    username := ADOQuery1.FieldByName('korisnickoime').AsString;
    plainPass := ADOQuery1.FieldByName('sifra').AsString;

    hashedPass := THashSHA2.GetHashString(plainPass);

    with TADOQuery.Create(nil) do
    try
      Connection := ADOConnection1;
      SQL.Text :=
        'UPDATE login SET sifra = :sifra ' +
        'WHERE korisnickoime = :korisnickoime';

      Parameters.ParamByName('sifra').Value := hashedPass;
      Parameters.ParamByName('korisnickoime').Value := username;

      ExecSQL;
    finally
      Free;
    end;

    ADOQuery1.Next;
  end;

  ShowMessage('Sve šifre su hashirane.');
end;                       }
procedure TForm2.PrijavaBtnClick(Sender: TObject);
    var
  role: string;
begin



               ADOQuery1.Close;
  ADOQuery1.SQL.Text :=
    'SELECT ID, role FROM login ' +
    'WHERE StrComp(korisnickoime, :u, 0)=0'+' AND StrComp(sifra, :p, 0)=0';  ///Case sensitive

  ADOQuery1.Parameters.ParamByName('u').Value :=
    Trim(txtbKorisnickoime.Text);
  ADOQuery1.Parameters.ParamByName('p').Value :=
  THashSHA2.GetHashString(Trim(txtbSifra.Text));

  ADOQuery1.Open;

  if not ADOQuery1.eof then


begin
    role := ADOQuery1.FieldByName('role').AsString;

    if SameText(role, 'menadzer') then
begin
  Form3.Left := Self.Left;
  Form3.Top := Self.Top;
  Form3.Show;
end
else if SameText(role, 'administrator') then
begin
  Form4.Left := Self.Left;
  Form4.Top := Self.Top;
  Form4.Show;
end
else if SameText(role, 'dispecer') then
begin
  Form5.Left := Self.Left;
  Form5.Top := Self.Top;
  Form5.Show;
end
else if SameText(role, 'klijent') then
begin
Form6.UlogovaniUser := ADOQuery1.FieldByName('ID').AsInteger;
  Form6.Left := Self.Left;
  Form6.Top := Self.Top;
  Form6.Show;
end
else if SameText(role, 'vozac') then
begin
  Form7.UlogovaniVozac := ADOQuery1.FieldByName('ID').AsInteger;
  Form7.Left := Self.Left;
  Form7.Top := Self.Top;
  Form7.Show;
end
else
  ShowMessage('Nepoznata uloga!');

Hide;
end
  else
  begin
    ShowMessage('Pogrešno korisničko ime ili šifra!');
    txtbKorisnickoIme.Text := '';
    txtbSifra.Text := '';

end;
end;

procedure TForm2.SpeedButton1Click(Sender: TObject);
begin


Form1.Show;
            Close;
end;

procedure TForm2.SpeedButton3Click(Sender: TObject);
begin
txtbSifra.Password:= not txtbSifra.Password;
end;
procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'settings.ini');
  try
    Ini.WriteInteger('Pozicija', 'Left', Self.Left);
    Ini.WriteInteger('Pozicija', 'Top', Self.Top);
  finally
    Ini.Free;
  end;

end;

end.
