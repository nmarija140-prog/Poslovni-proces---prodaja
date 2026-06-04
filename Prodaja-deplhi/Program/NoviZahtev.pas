unit NoviZahtev;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.Edit, FMX.Layouts, FMX.ListBox, Data.DB, Data.Win.ADODB,
  Data.FMTBcd, Data.SqlExpr, NovKlijent, DateUtils, FMX.DateTimeCtrls, System.IniFiles;

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
    procedure ListaKlijenataItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure MemoNapomenaEnter(Sender: TObject);
    procedure MemoNapomenaExit(Sender: TObject);
    procedure sacuvajZahtevDugmeClick(Sender: TObject);
    procedure otkaziDugmeClick(Sender: TObject);
    procedure OcistiPolja;
  private
    KlijentID: Integer;
    BlokirajPretragu: Boolean;
  public
    { Public declarations }
  end;

var
  Form9: TForm9;

implementation

{$R *.fmx}

uses ProdajaTura;

procedure TForm9.OcistiPolja;
begin
  BlokirajPretragu := True;
  try
    EditSearch.Text := '';
  finally
    BlokirajPretragu := False;
  end;

  vrstaRobeDugme.Text := '';
  kolicinaDugme.Text := '';
  mestoIstovaraDugme.Text := '';
  mestoUtovaraDugme.Text := '';
  MemoNapomena.Text := 'Napomena';
  DatumUtovara.Date := Date;
  DatumIstovara.Date := Date;
  KlijentID := -1;
  ListaKlijenata.Visible := False;
end;

procedure TForm9.FormCreate(Sender: TObject);
var
  dbPath: string;
  Ini: TIniFile;
begin
  BlokirajPretragu := False;

  Ini := TIniFile.Create(ExtractFilePath(ParamStr(0)) + 'settings.ini');
  try
    Self.Left := Ini.ReadInteger('Pozicija', 'Left', 100);
    Self.Top := Ini.ReadInteger('Pozicija', 'Top', 100);
  finally
    Ini.Free;
  end;

  DatumUtovara.Date := Date;
  DatumIstovara.Date := Date;
  KlijentID := -1;
  MemoNapomena.Text := 'Napomena';
  Position := TFormPosition.DefaultPosOnly;
  ListaKlijenata.Width := EditSearch.Width;
  ListaKlijenata.Height := 150;
  ListaKlijenata.Position.X := EditSearch.Position.X;
  ListaKlijenata.Position.Y := EditSearch.Position.Y + EditSearch.Height;
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
      'Provider=Microsoft.Jet.OLEDB.4.0;' +
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

procedure TForm9.ListaKlijenataItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  if Item = nil then Exit;

  KlijentID := Item.Tag;

  BlokirajPretragu := True;
  try

    if Pos(' - ', Item.Text) > 0 then
      EditSearch.Text := Copy(Item.Text, 1, Pos(' - ', Item.Text) - 1)
    else
      EditSearch.Text := Item.Text;
  finally

    BlokirajPretragu := False;
  end;

  ListaKlijenata.Visible := False;
end;

procedure TForm9.EditSearchChangeTracking(Sender: TObject);
var
  Item: TListBoxItem;
begin

  if BlokirajPretragu then
    Exit;

  KlijentID := -1;

  if Trim(EditSearch.Text) = '' then
  begin
    ListaKlijenata.Visible := False;
    Exit;
  end;

  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Text :=
    'SELECT Klijenti.IDKlijenta, Klijenti.nazivKlijenta, Gradovi.Grad, Klijenti.PIB ' +
    'FROM Klijenti ' +
    'INNER JOIN Gradovi ON Klijenti.GradID = Gradovi.GradID ' +
    'WHERE Klijenti.nazivKlijenta LIKE :p ' +
    'ORDER BY Klijenti.nazivKlijenta';

  ADOQuery1.Parameters.ParamByName('p').Value := EditSearch.Text + '%';
  ADOQuery1.Open;

  ListaKlijenata.Clear;

  ListaKlijenata.BeginUpdate;
  try
    while not ADOQuery1.Eof do
    begin
      Item := TListBoxItem.Create(ListaKlijenata);
      Item.Text := ADOQuery1.FieldByName('nazivKlijenta').AsString + ' - ' +
                   ADOQuery1.FieldByName('Grad').AsString;
      Item.Tag := ADOQuery1.FieldByName('IDKlijenta').AsInteger;

      ListaKlijenata.AddObject(Item);
      ADOQuery1.Next;
    end;
  finally
    ListaKlijenata.EndUpdate;
  end;

  ListaKlijenata.Visible := ListaKlijenata.Items.Count > 0;
  if ListaKlijenata.Items.Count * 35 < 150 then
    ListaKlijenata.Height := ListaKlijenata.Items.Count * 35
  else
    ListaKlijenata.Height := 150;

  ListaKlijenata.BringToFront;
end;

procedure TForm9.sacuvajZahtevDugmeClick(Sender: TObject);
begin
  if KlijentID = -1 then
  begin
    ShowMessage('Izaberi klijenta sa liste!');
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
      'INSERT INTO Zahtevi (KlijentID, MestoUtovara, DatumUtovara, MestoIstovara, DatumIstovara, VrstaRobe, Kolicina, Napomena, StatusID) ' +
      'VALUES (:KlijentID, :MestoUtovara, :DatumUtovara, :MestoIstovara, :DatumIstovara, :VrstaRobe, :Kolicina, :Napomena, :StatusID)';

    ADOQuery1.Parameters.ParamByName('KlijentID').Value := KlijentID;
    ADOQuery1.Parameters.ParamByName('MestoUtovara').Value := mestoUtovaraDugme.Text;
    ADOQuery1.Parameters.ParamByName('DatumUtovara').Value := VarFromDateTime(DatumUtovara.Date);
    ADOQuery1.Parameters.ParamByName('MestoIstovara').Value := mestoIstovaraDugme.Text;
    ADOQuery1.Parameters.ParamByName('DatumIstovara').Value := VarFromDateTime(DatumIstovara.Date);
    ADOQuery1.Parameters.ParamByName('VrstaRobe').Value := vrstaRobeDugme.Text;
    ADOQuery1.Parameters.ParamByName('Kolicina').Value := kolicinaDugme.Text;
    ADOQuery1.Parameters.ParamByName('Napomena').Value := MemoNapomena.Text;
    ADOQuery1.Parameters.ParamByName('StatusID').Value := 1;

    ADOQuery1.ExecSQL;
    ShowMessage('Zahtev uspešno sačuvan!');
    Form8.PopuniListuZahteva(1);
    OcistiPolja;

    Form8.Left := Self.Left;
    Form8.Top := Self.Top;
    Form8.Width := Self.Width;
    Form8.Height := Self.Height;
    Form8.Show;
    Self.Hide;
  except
    on E: Exception do
      ShowMessage('Greška pri upisu u bazu: ' + E.Message);
  end;
end;

procedure TForm9.MemoNapomenaEnter(Sender: TObject);
begin
  if MemoNapomena.Text = 'Napomena' then
    MemoNapomena.Text := '';
end;

procedure TForm9.MemoNapomenaExit(Sender: TObject);
begin
  if Trim(MemoNapomena.Text) = '' then
    MemoNapomena.Text := 'Napomena';
end;

procedure TForm9.otkaziDugmeClick(Sender: TObject);
begin
  Form8.Show;
  Close;
end;

procedure TForm9.FormClose(Sender: TObject; var Action: TCloseAction);
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

procedure TForm9.dodajKlijentaDugmeClick(Sender: TObject);
begin
  Form10.Left := Self.Left;
  Form10.Top := Self.Top;
  Form10.Width := Self.Width;
  Form10.Height := Self.Height;
  Form10.Show;
end;

end.
