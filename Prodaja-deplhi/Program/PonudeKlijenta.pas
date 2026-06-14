unit PonudeKlijenta;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts,
  Data.DB, Data.Win.ADODB, FMX.ScrollBox;

type
  TForm11 = class(TForm)
    VertScrollBox1: TVertScrollBox;
    SpeedButton1: TSpeedButton;
    Text1: TText;
    ADOQuery1: TADOQuery;
    DugmeNove: TButton;
    DugmePrihvacene: TButton;
    DugmeOdbijene: TButton;
    Line1: TLine;
    procedure SpeedButton1Click(Sender: TObject);
    procedure KarticaClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DugmeNoveClick(Sender: TObject);
    procedure DugmePrihvaceneClick(Sender: TObject);
    procedure DugmOdbijeneClick(Sender: TObject);
  private
    procedure PopuniKartice(AStatusID: Integer);
  public
    PraviIDKlijenta: Integer;
  end;

var
  Form11: TForm11;

implementation

uses Klijent, ProdajaTura, KlijentPrihvatanje;

{$R *.fmx}

procedure TForm11.PopuniKartice(AStatusID: Integer);
var
  Kartica: TRectangle;
  LabelRuta, LabelDatum, LabelCena, LabelStatus: TLabel;
  YPozicija: Single;
  StatusTekst: string;
  StatusBoja: TAlphaColor;
begin
  while VertScrollBox1.Content.ChildrenCount > 0 do
    VertScrollBox1.Content.Children[0].Free;

  YPozicija := 10;

  try
    ADOQuery1.Connection := Form8.ADOConnection1;
    ADOQuery1.Close;
   ADOQuery1.SQL.Text :=
   'SELECT p.PonudaID, p.Cena, p.Valuta, p.RokPlacanja, ' +
  '       z.MestoUtovara, z.MestoIstovara, z.DatumUtovara ' +
  'FROM Ponude p ' +
  'INNER JOIN Zahtevi z ON p.ZahtevID = z.[ID zahteva] ' +
  'WHERE p.KlijentID = :KlijentID AND p.OdgovorKlijenta = :StatusID';
   ADOQuery1.Parameters.ParamByName('KlijentID').Value := PraviIDKlijenta;
    ADOQuery1.Parameters.ParamByName('StatusID').Value := AStatusID;
    ADOQuery1.Open;

    case AStatusID of
      0: begin StatusTekst := '● NOVO'; StatusBoja := TAlphaColorRec.Crimson; end;
      1: begin StatusTekst := '✔ PRIHVAĆENO'; StatusBoja := TAlphaColorRec.Green; end;
      2: begin StatusTekst := '✖ ODBIJENO'; StatusBoja := TAlphaColorRec.Gray; end;
    end;

    while not ADOQuery1.Eof do
    begin
      Kartica := TRectangle.Create(VertScrollBox1);
      Kartica.Parent := VertScrollBox1;
      Kartica.Width := VertScrollBox1.Width - 20;
      Kartica.Height := 120;
      Kartica.Position.X := 10;
      Kartica.Position.Y := YPozicija;
      Kartica.Fill.Color := TAlphaColorRec.White;
      Kartica.Stroke.Color := TAlphaColorRec.Lightgray;
      Kartica.XRadius := 8;
      Kartica.YRadius := 8;
      Kartica.Tag := ADOQuery1.FieldByName('PonudaID').AsInteger;

      if AStatusID = 0 then
        Kartica.OnClick := KarticaClick;

      LabelStatus := TLabel.Create(Kartica);
      LabelStatus.Parent := Kartica;
      LabelStatus.Text := StatusTekst;
      LabelStatus.FontColor := StatusBoja;
      LabelStatus.Position.X := 10;
      LabelStatus.Position.Y := 8;
      LabelStatus.Font.Size := 11;

      LabelRuta := TLabel.Create(Kartica);
      LabelRuta.Parent := Kartica;
      LabelRuta.Text := '🚛 ' + ADOQuery1.FieldByName('MestoUtovara').AsString +
                        ' → ' + ADOQuery1.FieldByName('MestoIstovara').AsString;
      LabelRuta.Position.X := 10;
      LabelRuta.Position.Y := 28;
      LabelRuta.Font.Size := 14;
      LabelRuta.Font.Style := [TFontStyle.fsBold];

      LabelDatum := TLabel.Create(Kartica);
      LabelDatum.Parent := Kartica;
      LabelDatum.Text := '📅 ' + ADOQuery1.FieldByName('DatumUtovara').AsString;
      LabelDatum.Position.X := 10;
      LabelDatum.Position.Y := 55;
      LabelDatum.Font.Size := 12;

      LabelCena := TLabel.Create(Kartica);
      LabelCena.Parent := Kartica;
      LabelCena.Text := '💰 ' + ADOQuery1.FieldByName('Cena').AsString +
                        ' ' + ADOQuery1.FieldByName('Valuta').AsString;
      LabelCena.Position.X := 10;
      LabelCena.Position.Y := 78;
      LabelCena.Font.Size := 12;
      LabelCena.FontColor := TAlphaColorRec.Darkgreen;

      YPozicija := YPozicija + 130;
      ADOQuery1.Next;
    end;

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

procedure TForm11.FormShow(Sender: TObject);
begin
  PopuniKartice(0);
end;

procedure TForm11.DugmeNoveClick(Sender: TObject);
begin
  PopuniKartice(0);
end;

procedure TForm11.DugmePrihvaceneClick(Sender: TObject);
begin
  PopuniKartice(1);
end;

procedure TForm11.DugmOdbijeneClick(Sender: TObject);
begin
  PopuniKartice(2);
end;

procedure TForm11.KarticaClick(Sender: TObject);
var
  KliknutiPonudaID: Integer;
begin
  KliknutiPonudaID := (Sender as TRectangle).Tag;

  if not Assigned(Form14) then
    Application.CreateForm(TForm14, Form14);

  Form14.PonudaID := KliknutiPonudaID;
  Form14.Left := Self.Left;
  Form14.Top := Self.Top;
  Form14.Width := Self.Width;
  Form14.Height := Self.Height;
  Form14.Show;
  Self.Hide;
end;

procedure TForm11.SpeedButton1Click(Sender: TObject);
begin
  Form6.Show;
  Self.Hide;
end;

end.
