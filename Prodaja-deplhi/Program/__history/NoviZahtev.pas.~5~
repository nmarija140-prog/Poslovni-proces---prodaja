unit NoviZahtev;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.Edit, FMX.Layouts, FMX.ListBox, Data.DB, Data.Win.ADODB,
  Data.FMTBcd, Data.SqlExpr, NovKlijent,DateUtils, FMX.DateTimeCtrls;

type
  TForm9 = class(TForm)
    dodajKlijentaDugme: TSpeedButton;
    vrstaRobeDugme: TEdit;
    kolicinaDugme: TEdit;
    mestoIstovaraDugme: TEdit;
    mestoUtovaraDugme: TEdit;
    MemoNapomena: TMemo;
    sacuvajZahtevDugme: TButton;
    otkaziDugme: TButton;
    ADOQuery1: TADOQuery;
    ADOConnection1: TADOConnection;
    EditSearch: TEdit;
    ListaKlijenata: TListBox;
    DatumUtovara: TDateEdit;
    DatumIstovara: TDateEdit;
     procedure FormCreate(Sender: TObject);
     procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure dodajKlijentaDugmeClick(Sender: TObject);
    procedure EditSearchChangeTracking(Sender: TObject);
    procedure ListaKlijenataItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure MemoNapomenaEnter(Sender: TObject);
    procedure MemoNapomenaExit(Sender: TObject);
    procedure sacuvajZahtevDugmeClick(Sender: TObject);
  private
      KlijentID: Integer;
  public
    { Public declarations }
  end;

var
  Form9: TForm9;

implementation

{$R *.fmx}
uses ProdajaTura;




procedure TForm9.FormCreate(Sender: TObject);
 var
  dbPath: string;
begin
DatumUtovara.Date := Date;
DatumIstovara.Date := Date;
KlijentID := -1;
MemoNapomena.Text := 'Napomena';
Position := TFormPosition.DefaultPosOnly;
ListaKlijenata.Width := EditSearch.Width;
ListaKlijenata.Height := 150;

ListaKlijenata.Position.X := EditSearch.Position.X;

ListaKlijenata.Position.Y :=
  EditSearch.Position.Y + EditSearch.Height;

ListaKlijenata.BringToFront;
ListaKlijenata.Visible := False;
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
procedure TForm9.ListaKlijenataItemClick(
  const Sender: TCustomListBox;
  const Item: TListBoxItem);
begin
  EditSearch.Text := Item.Text;

  ListaKlijenata.Visible := False;
  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;

  ADOQuery1.SQL.Text :=
    'SELECT IDKlijenta FROM Klijenti ' +
    'WHERE nazivKlijenta = :n';

  ADOQuery1.Parameters.ParamByName('n').Value :=
    Item.Text;

  ADOQuery1.Open;
  KlijentID :=
    ADOQuery1.FieldByName('IDKlijenta').AsInteger;
end;

procedure TForm9.MemoNapomenaEnter(Sender: TObject);
begin
if MemoNapomena.Text = 'Napomena' then
  begin
    MemoNapomena.Text := '';
  end;
end;

procedure TForm9.MemoNapomenaExit(Sender: TObject);
begin
if Trim(MemoNapomena.Text) = '' then
  begin
    MemoNapomena.Text := 'Napomena';
  end;
end;

procedure TForm9.sacuvajZahtevDugmeClick(Sender: TObject);
begin
  if KlijentID = -1 then
  begin
    ShowMessage('Izaberi klijenta!');
    Exit;
  end;

  if mestoUtovaraDugme.Text.Trim = '' then
  begin
    ShowMessage('Unesi mesto utovara!');
    Exit;
  end;
   if DatumUtovara.Text.Trim = '' then
  begin
    ShowMessage('Unesi datum utovara!');
    Exit;
  end;
   if mestoIstovaraDugme.Text.Trim = '' then
  begin
    ShowMessage('Unesi mesto istovara!');
    Exit;
  end;
   if DatumIstovara.Text.Trim = '' then
  begin
    ShowMessage('Unesi datum istovara!');
    Exit;
  end;
   if vrstaRobeDugme.Text.Trim = '' then
  begin
    ShowMessage('Unesi vrstu robe!');
    Exit;
  end;
   if kolicinaDugme.Text.Trim = '' then
  begin
    ShowMessage('Unesi kolicinu!');
    Exit;
  end;

  try

    ADOQuery1.Close;
ADOQuery1.SQL.Clear;

ADOQuery1.SQL.Text :=
    'INSERT INTO Zahtevi ' + '(KlijentID, MestoUtovara, DatumUtovara, MestoIstovara, DatumIstovara, VrstaRobe, Kolicina, Napomena) '
    + 'VALUES (:KlijentID, :MestoUtovara, :DatumUtovara, :MestoIstovara, :DatumIstovara, :VrstaRobe, :Kolicina, :Napomena)' ;
     ADOQuery1.Parameters.ParamByName('KlijentID').Value := KlijentID;
     ADOQuery1.Parameters.ParamByName('MestoUtovara').Value := mestoUtovaraDugme.Text;
     ADOQuery1.Parameters.ParamByName('DatumUtovara').Value :=VarFromDateTime(DatumUtovara.Date);
      ADOQuery1.Parameters.ParamByName('MestoIstovara').Value := mestoIstovaraDugme.Text;
      ADOQuery1.Parameters.ParamByName('DatumIstovara').Value :=VarFromDateTime(DatumIstovara.Date);
      ADOQuery1.Parameters.ParamByName('VrstaRobe').Value := vrstaRobeDugme.Text;
       ADOQuery1.Parameters.ParamByName('Kolicina').Value := StrToFloatDef(kolicinaDugme.Text, 0);
        ADOQuery1.Parameters.ParamByName('Napomena').Value := MemoNapomena.Text; ADOQuery1.ExecSQL;
         ShowMessage('Zahtev uspešno sačuvan!');
Self.Hide;

if not Assigned(Form8) then
  Application.CreateForm(TForm8, Form8);

Form8.Show;

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

procedure TForm9.EditSearchChangeTracking(Sender: TObject);
begin
  KlijentID := -1;

  if Trim(EditSearch.Text) = '' then
  begin
    ListaKlijenata.Visible := False;
    Exit;
  end;

  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;

  ADOQuery1.SQL.Text :=
    'SELECT IDKlijenta, nazivKlijenta FROM Klijenti ' + 'WHERE nazivKlijenta LIKE :p ' +
    'ORDER BY nazivKlijenta';

  ADOQuery1.Parameters.ParamByName('p').Value :=
    EditSearch.Text + '%';

  ADOQuery1.Open;

  ListaKlijenata.Clear;

  while not ADOQuery1.Eof do
  begin
    ListaKlijenata.Items.Add(
      ADOQuery1.FieldByName('nazivKlijenta').AsString
    );

    ADOQuery1.Next;
  end;

  ListaKlijenata.Visible := ListaKlijenata.Items.Count > 0;

  ListaKlijenata.Height :=
    ListaKlijenata.Items.Count * 35;

  if ListaKlijenata.Height > 150 then
    ListaKlijenata.Height := 150;

  ListaKlijenata.BringToFront;
end;
procedure TForm9.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    if ADOQuery1.Active then
      ADOQuery1.Close;

    if ADOConnection1.Connected then
      ADOConnection1.Connected := False;

  except
  end;
end;
procedure TForm9.dodajKlijentaDugmeClick(Sender: TObject);
begin
Form10.Show;
end;

end.
