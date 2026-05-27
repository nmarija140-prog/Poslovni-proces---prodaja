unit ProdajaTura;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Ani, FMX.Layouts,
  Data.DB, Data.Win.ADODB, System.IniFiles, System.IOUtils, FMX.Edit,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView;

type
  TForm8 = class(TForm)
    HambMeni2: TSpeedButton;
    KarticaPrihvacenePonude: TRectangle;
    RectAnimation1: TRectAnimation;
    Text4: TText;
    KarticaOdbijenePonude: TRectangle;
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
    procedure HambMeni2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KarticaNoviZahteviClick(Sender: TObject);
    procedure KarticaPoslatePonudeClick(Sender: TObject);
    procedure KarticaPrihvacenePonudeClick(Sender: TObject);
    procedure KarticaOdbijenePonudeClick(Sender: TObject);
    procedure NoviZahtevDugmeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListaZahteviItemClick(const Sender: TObject; const AItem: TListViewItem);
    procedure PopuniListuZahteva(AStatusID: Integer; PocetniPrikaz: Boolean = False);
  private
  public
  end;

var
  Form8: TForm8;

implementation
uses NoviZahtev, Detalji;
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

    PopuniListuZahteva(1, True);

  except
    on E: Exception do
      ShowMessage('Greška pri konekciji sa bazom: ' + E.Message);
  end;
end;

procedure TForm8.HambMeni2Click(Sender: TObject);
begin
  PanelProdaja.Visible := not PanelProdaja.Visible;
  HambMeni2.BringToFront;
end;

procedure TForm8.KarticaNoviZahteviClick(Sender: TObject);
begin
  PopuniListuZahteva(1, False);
end;

procedure TForm8.KarticaOdbijenePonudeClick(Sender: TObject);
begin
  PopuniListuZahteva(2, False);
end;

procedure TForm8.KarticaPoslatePonudeClick(Sender: TObject);
begin
  PopuniListuZahteva(3, False);
end;

procedure TForm8.KarticaPrihvacenePonudeClick(Sender: TObject);
begin
  PopuniListuZahteva(4, False);
end;

procedure TForm8.PopuniListuZahteva(AStatusID: Integer; PocetniPrikaz: Boolean = False);
var
  Stavka: TListViewItem;
begin
  ListaZahtevi.Items.BeginUpdate;
  try
    ListaZahtevi.Items.Clear;
    ADOQuery1.Close;

    if PocetniPrikaz then
    begin
      ADOQuery1.SQL.Text :=
        'SELECT z.[ID Zahteva], z.StatusID, k.nazivKlijenta, g.Grad ' +
        'FROM (Zahtevi z ' +
        'INNER JOIN Klijenti k ON z.KlijentID = k.IDKlijenta) ' +
        'INNER JOIN Gradovi g ON k.GradID = g.GradID ' +
        'WHERE z.StatusID IN (1, 4)';
    end
    else
    begin
      ADOQuery1.SQL.Text :=
        'SELECT z.[ID Zahteva], z.StatusID, k.nazivKlijenta, g.Grad ' +
        'FROM (Zahtevi z ' +
        'INNER JOIN Klijenti k ON z.KlijentID = k.IDKlijenta) ' +
        'INNER JOIN Gradovi g ON k.GradID = g.GradID ' +
        'WHERE z.StatusID = :StatusID';

      ADOQuery1.Parameters.ParamByName('StatusID').Value := AStatusID;
    end;

    ADOQuery1.Open;

    while not ADOQuery1.Eof do
    begin
      Stavka := ListaZahtevi.Items.Add;

      Stavka.Text := '  ' + ADOQuery1.FieldByName('nazivKlijenta').AsString +
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
begin

  Form11.IzabraniID := AItem.Tag;
  Form11.IzabraniStatusID := StrToInt(AItem.Detail);

  if Form11.IzabraniStatusID = 1 then
  begin
    Form11.DugmePonuda.Visible := True;
    Form11.DugmeKreirajRezervaciju.Visible := False;
  end
  else if Form11.IzabraniStatusID = 4 then
  begin
    Form11.DugmePonuda.Visible := False;
    Form11.DugmeKreirajRezervaciju.Visible := True;
  end
  else
  begin
    Form11.DugmePonuda.Visible := False;
    Form11.DugmeKreirajRezervaciju.Visible := False;
  end;

  Form11.Left := Self.Left;
  Form11.Top := Self.Top;
  Form11.Width := Self.Width;
  Form11.Height := Self.Height;

  Form11.Show;
  Self.Hide;
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
