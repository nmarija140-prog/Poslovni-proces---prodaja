unit ProdajaTura;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Ani, FMX.Layouts,
  Data.DB, Data.Win.ADODB, System.IniFiles, System.IOUtils, FMX.Edit,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, UnosPodataka;

type
  TForm8 = class(TForm)
    HambMeni2: TSpeedButton;
    KarticaPrihvacenePonude: TRectangle;
    RectAnimation1: TRectAnimation;
    Text4: TText;
    KarticaZakazaneTure: TRectangle;
    RectAnimation2: TRectAnimation;
    Text1: TText;
    KarticaPoslatePonude: TRectangle;
    RectAnimation3: TRectAnimation;
    Text2: TText;
    RectAnimation4: TRectAnimation;
    Text3: TText;
    NoviZahtevDugme: TSpeedButton;
    PanelProdaja: TPanel;
    operativaDugme: TButton;
    ProdajaTuraDugme: TButton;
    ChatDugme: TButton;
    IzvestajiDugme: TButton;
    MojProfilDugme: TButton;
    OdjavaDugme: TButton;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    ListaZahtevi: TListView;
    Text5: TText;
    procedure HambMeni2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KarticaNoviZahteviClick(Sender: TObject);
    procedure KarticaPoslatePonudeClick(Sender: TObject);
    procedure KarticaPrihvacenePonudeClick(Sender: TObject);
    procedure KarticaZakazaneTureClick(Sender: TObject);
    procedure NoviZahtevDugmeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListaZahteviItemClick(const Sender: TObject; const AItem: TListViewItem);
   procedure PopuniListuZahteva(AStatusID: Integer);
    procedure OdjavaDugmeClick(Sender: TObject);
  private
  KlijentID: Integer;
  public
  end;

var
  Form8: TForm8;

implementation
uses NoviZahtev, Detalji, KreiranjeRezervacije, KreiranjePonude;
{$R *.fmx}

procedure TForm8.FormCreate(Sender: TObject);
var
  dbPath: string;
begin
  ListaZahtevi.ItemAppearanceName := 'ListItem';
  ListaZahtevi.AllowSelection := True;

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
    PopuniListuZahteva(1);
  except
    on E: Exception do
      ShowMessage('Greška pri konekciji sa bazom: ' + E.Message);
  end;
  ADOQuery1.Close;
ADOQuery1.SQL.Text :=
  'UPDATE Zahtevi SET StatusID = 6 ' +
  'WHERE StatusID = 5 AND DatumUtovara <= Now()';
ADOQuery1.ExecSQL;
end;

procedure TForm8.HambMeni2Click(Sender: TObject);
begin
  PanelProdaja.Visible := not PanelProdaja.Visible;
  if PanelProdaja.Visible then
  begin
    PanelProdaja.BringToFront;
  end;
  HambMeni2.BringToFront;
end;

procedure TForm8.KarticaNoviZahteviClick(Sender: TObject);
begin
  PopuniListuZahteva(1);
end;

procedure TForm8.KarticaPoslatePonudeClick(Sender: TObject);
begin
  PopuniListuZahteva(3);
end;

procedure TForm8.KarticaPrihvacenePonudeClick(Sender: TObject);
begin
  PopuniListuZahteva(4);
end;

procedure TForm8.KarticaZakazaneTureClick(Sender: TObject);
begin
  PopuniListuZahteva(5);
end;

procedure TForm8.PopuniListuZahteva(AStatusID: Integer);
var
  Stavka: TListViewItem;Krug:String;
begin
  ListaZahtevi.Items.BeginUpdate;
  try
    ListaZahtevi.Items.Clear;
    ADOQuery1.Close;
    ADOQuery1.SQL.Text :=
  'SELECT z.[ID Zahteva], ' +
  '  IIF(z.StatusID >= 5, z.StatusID, IIF(p.StatusID IS NOT NULL, p.StatusID, z.StatusID)) AS StatusID, ' +
  '  k.nazivKlijenta, g.Grad ' +
  'FROM ((Zahtevi z ' +
  'INNER JOIN Klijenti k ON z.KlijentID = k.IDKlijenta) ' +
  'INNER JOIN Gradovi g ON k.GradID = g.GradID) ' +
  'LEFT JOIN Ponude p ON z.[ID zahteva] = p.ZahtevID ' +
  'WHERE IIF(z.StatusID >= 5, z.StatusID, IIF(p.StatusID IS NOT NULL, p.StatusID, z.StatusID)) = :StatusID';
    ADOQuery1.Parameters.ParamByName('StatusID').Value := AStatusID;
    ADOQuery1.Open;
    while not ADOQuery1.Eof do
    begin
      Stavka := ListaZahtevi.Items.Add;
      case ADOQuery1.FieldByName('StatusID').AsInteger of
    1: Krug := '🟡 ';
    3: Krug := '🔵 ';
    4: Krug := '🟢 ';
    5: Krug := '🟣 ';
  else
    Krug := '⚪ ';
  end;
       Stavka.Text := Krug + ADOQuery1.FieldByName('nazivKlijenta').AsString +
                 ' (' + ADOQuery1.FieldByName('Grad').AsString + ')';
      Stavka.Tag := ADOQuery1.FieldByName('ID Zahteva').AsInteger;
      Stavka.Detail := ADOQuery1.FieldByName('StatusID').AsString;
      ADOQuery1.Next;
    end;
  finally
    ListaZahtevi.Items.EndUpdate;
  end;
end;

procedure TForm8.ListaZahteviItemClick(const Sender: TObject; const AItem: TListViewItem);
var
  KliknutiStatusID: Integer;
begin
  if AItem = nil then Exit;

  KliknutiStatusID := StrToInt(AItem.Detail);

  if KliknutiStatusID = 1 then
  begin
    if not Assigned(FormDetalji) then
      Application.CreateForm(TFormDetalji, FormDetalji);
    FormDetalji.IzabraniID := AItem.Tag;
    FormDetalji.IzabraniStatusID := KliknutiStatusID;
    FormDetalji.DugmePonuda.Visible := True;
    FormDetalji.RezervacijaDugme.Visible := False;
    FormDetalji.Left := Self.Left;
    FormDetalji.Top := Self.Top;
    FormDetalji.Width := Self.Width;
    FormDetalji.Height := Self.Height;
    FormDetalji.Show;
    Self.Hide;
  end;

if KliknutiStatusID = 3 then
begin
  if not Assigned(Form13) then
    Application.CreateForm(TForm13, Form13);
  Form13.IDZahtevaZaPonudu := AItem.Tag;
  Form13.Left := Self.Left;
  Form13.Top := Self.Top;
  Form13.Width := Self.Width;
  Form13.Height := Self.Height;
  Form13.Show;
  Self.Hide;
end;

  if KliknutiStatusID = 4 then
  begin
    if not Assigned(FormDetalji) then
      Application.CreateForm(TFormDetalji, FormDetalji);
    FormDetalji.IzabraniID := AItem.Tag;
    FormDetalji.IzabraniStatusID := KliknutiStatusID;
    FormDetalji.DugmePonuda.Visible := False;
    FormDetalji.RezervacijaDugme.Visible := True;
    FormDetalji.Left := Self.Left;
    FormDetalji.Top := Self.Top;
    FormDetalji.Width := Self.Width;
    FormDetalji.Height := Self.Height;
    FormDetalji.Show;
    Self.Hide;
  end;

  if KliknutiStatusID = 5 then
  begin
    if not Assigned(Form12) then
      Application.CreateForm(TForm12, Form12);
    Form12.IDZahtevaZaPonudu := AItem.Tag;
    Form12.Left := Self.Left;
    Form12.Top := Self.Top;
    Form12.Width := Self.Width;
    Form12.Height := Self.Height;
    Form12.Show;
    Self.Hide;
  end;
end;

procedure TForm8.NoviZahtevDugmeClick(Sender: TObject);
begin
  Form9.Left := Self.Left;
  Form9.Top := Self.Top;
  Form9.Width := Self.Width;
  Form9.Height := Self.Height;
  Form9.Show;
  Self.Hide;
end;

procedure TForm8.OdjavaDugmeClick(Sender: TObject);
begin
Form2.Show;
Self.Hide;
end;

procedure TForm8.FormClose(Sender: TObject; var Action: TCloseAction);
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
