unit Admin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, UnosPodataka, FMX.Objects, FMX.Maps,
  Data.DB, Data.Win.ADODB, FMX.ListBox, PozicijaForme;
   type
  TPrijavljeniKorisnik = record
    ID: Integer;
    KorisnickoIme: string;
    Role: string;
  end;
  var
  TrenutniKorisnik: TPrijavljeniKorisnik;
type
  TForm4 = class(TForm)
    SpeedButton1: TSpeedButton;
    MapView1: TMapView;
    Text1: TText;
    btnChat: TButton;
    btnOtvoriNalog: TButton;
    btnUpravljajNalozima: TButton;
    ComboKorisniciAdmin: TComboBox;
    DugmeUdjiAdmin: TButton;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DugmeUdjiAdminClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnOtvoriNalogClick(Sender: TObject);
  private
    procedure PopuniComboKorisnike;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation
       uses Klijent, NovKlijent;
{$R *.fmx}
procedure TForm4.PopuniComboKorisnike;
begin
  ComboKorisniciAdmin.Items.Clear;
  ADOQuery1.Close;
  ADOQuery1.SQL.Text :=
    'SELECT id, korisnickoime, role FROM login WHERE role <> ''menadzer''';
  ADOQuery1.Open;
  while not ADOQuery1.Eof do
  begin
    ComboKorisniciAdmin.Items.AddObject(
      ADOQuery1.FieldByName('korisnickoime').AsString,
      TObject(ADOQuery1.FieldByName('id').AsInteger)
    );
    ADOQuery1.Next;
  end;
end;

procedure TForm4.btnOtvoriNalogClick(Sender: TObject);
var
  IzabraniLoginID: Integer;
begin
  // 1. Provera da li je admin uopšte izabrao nalog iz ComboBox-a
  if ComboKorisniciAdmin.ItemIndex = -1 then
  begin
    ShowMessage('Molimo Vas da prvo izaberete nalog iz liste za koji otvarate profil klijenta.');
    Exit;
  end;

  // 2. Izvlačimo ID naloženog korisnika iz objekta ComboBox-a
  IzabraniLoginID := Integer(ComboKorisniciAdmin.Items.Objects[ComboKorisniciAdmin.ItemIndex]);

  // 3. Prosleđujemo taj ID formi za unos klijenta (Form10) u njenu javnu promenljivu
  Form10.LoginIDZaUnos := IzabraniLoginID;

  // 4. Otvaramo formu za unos klijenta
  Form10.Show;
end;

procedure TForm4.DugmeUdjiAdminClick(Sender: TObject);
var
IzabraniID: Integer;
begin
  if ComboKorisniciAdmin.ItemIndex = -1 then
  begin
    ShowMessage('Molimo izaberite korisnika.');
    Exit;
  end;
  IzabraniID := Integer(ComboKorisniciAdmin.Items.Objects[ComboKorisniciAdmin.ItemIndex]);
  TrenutniKorisnik.ID := IzabraniID;
  TrenutniKorisnik.KorisnickoIme := ComboKorisniciAdmin.Items[ComboKorisniciAdmin.ItemIndex];
  TrenutniKorisnik.Role := 'Korisnik';
  Form6.Show;



end;

procedure TForm4.FormCreate(Sender: TObject);
begin
 Position := TFormPosition.Designed;

  if LastFormX <> -1 then
  begin
    Left := Round(LastFormX);
    Top := Round(LastFormY);
  end;
 ADOConnection1.ConnectionString :=
    'Provider=Microsoft.Jet.OLEDB.4.0;' +
    'Data Source=' + ExtractFilePath(ParamStr(0)) + 'mpmBaza.mdb;';
  ADOConnection1.LoginPrompt := False;
  ADOConnection1.Connected := True;
  PopuniComboKorisnike;
end;

procedure TForm4.SpeedButton1Click(Sender: TObject);
begin
Form2.Show;
Close;
end;
procedure TForm4.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LastFormX := Left;
  LastFormY := Top;
end;

end.
