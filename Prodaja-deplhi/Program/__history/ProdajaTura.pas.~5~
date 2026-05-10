unit ProdajaTura;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Ani, FMX.Layouts,
  Data.DB, Data.Win.ADODB;

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
    KarticaNoviZahtevi: TRectangle;
    RectAnimation4: TRectAnimation;
    Text3: TText;
    SpeedButton1: TSpeedButton;
    KarticaZahtevi: TRectangle;
    Text5: TText;
    ZahteviLista: TVertScrollBox;
    Prihvacen: TRectangle;
    Poslato: TRectangle;
    Odbijeno: TRectangle;
    Novo: TRectangle;
    Text6: TText;
    Text7: TText;
    Text8: TText;
    Text9: TText;
    PanelProdaja: TPanel;
    operativaDugme: TButton;
    ProdajaTuraDugme: TButton;
    ChatDugme: TButton;
    IzvestajiDugme: TButton;
    MojProfilDugme: TButton;
    OdjavaDugme: TButton;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    procedure HambMeni2Click(Sender: TObject);
    procedure KarticaZahteviClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure KarticaNoviZahteviClick(Sender: TObject);
    procedure KarticaPoslatePonudeClick(Sender: TObject);
    procedure KarticaPrihvacenePonudeClick(Sender: TObject);
    procedure KarticaOdbijenePonudeClick(Sender: TObject);
  private
    procedure Filtriranje(Status: string);
  public

  end;

var
  Form8: TForm8;

implementation

{$R *.fmx}
procedure TForm8.FormCreate(Sender: TObject);
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

procedure TForm8.HambMeni2Click(Sender: TObject);
begin
PanelProdaja.Visible := not PanelProdaja.Visible;
HambMeni2.BringToFront;
end;

procedure TForm8.KarticaNoviZahteviClick(Sender: TObject);
begin
 Filtriranje('Novi zahtev');
  ZahteviLista.Visible := True;
end;

procedure TForm8.KarticaOdbijenePonudeClick(Sender: TObject);
begin
      Filtriranje('Odbijena ponuda');
  ZahteviLista.Visible := True;
end;

procedure TForm8.KarticaPoslatePonudeClick(Sender: TObject);
begin
  Filtriranje('Poslata ponuda');
  ZahteviLista.Visible := True;
end;


procedure TForm8.KarticaPrihvacenePonudeClick(Sender: TObject);
begin
   Filtriranje('Prihvacena ponuda');
  ZahteviLista.Visible := True;
end;

procedure TForm8.KarticaZahteviClick(Sender: TObject);
begin
 Filtriranje('svi');
ZahteviLista.Visible := not ZahteviLista.Visible;
  ZahteviLista.BringToFront;
  KarticaZahtevi.BringToFront;
end;
procedure TForm8.Filtriranje(Status: string);
begin
  Novo.Visible := (Status = 'svi') or (Status = 'Novi zahtev');
  Poslato.Visible := (Status = 'svi') or (Status = 'Poslata ponuda');
  Prihvacen.Visible := (Status = 'svi') or (Status = 'Prihvacena ponuda');
  Odbijeno.Visible := (Status = 'svi') or (Status = 'Odbijena ponuda');
end;



end.
