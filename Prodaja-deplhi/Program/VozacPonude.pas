unit VozacPonude;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, Data.DB,
  Data.Win.ADODB, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  FMX.Objects, ProdajaTura;

type
  TForm15 = class(TForm)
    VertScrollBox1: TVertScrollBox;
    SpeedButton1: TSpeedButton;
    ADOQuery1: TADOQuery;
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure KarticaClick(Sender: TObject);
  private
  public
    UlogovaniVozac: Integer;
  end;

var
  Form15: TForm15;

implementation

uses Vozac, VozacPrihvatanje;

{$R *.fmx}

procedure TForm15.FormShow(Sender: TObject);
var
  Kartica: TRectangle;
  LabelRuta, LabelDatum, LabelNovo: TLabel;
  YPozicija: Single;
begin
 while VertScrollBox1.Content.ChildrenCount > 0 do
  VertScrollBox1.Content.Children[0].Free;
  YPozicija := 10;

  try
    ADOQuery1.Connection := Form8.ADOConnection1;
    ADOQuery1.Close;
  ADOQuery1.SQL.Text :=
  'SELECT r.IDRezervacije, z.[ID zahteva], ' +
  '       z.MestoUtovara, z.MestoIstovara, z.DatumUtovara ' +
  'FROM ((Rezervacije r ' +
  'INNER JOIN Zahtevi z ON r.ZahtevID = z.[ID zahteva]) ' +
  'LEFT JOIN Ponude p ON z.[ID zahteva] = p.ZahtevID) ' +
  'WHERE r.VozacID = :VozacID AND ' +
  'IIF(p.StatusID IS NOT NULL, p.StatusID, z.StatusID) = 4';
    ADOQuery1.Parameters.ParamByName('VozacID').Value := UlogovaniVozac;
    ADOQuery1.Open;

    while not ADOQuery1.Eof do
    begin
      Kartica := TRectangle.Create(VertScrollBox1);
      Kartica.Parent := VertScrollBox1;
      Kartica.Width := VertScrollBox1.Width - 20;
      Kartica.Height := 100;
      Kartica.Position.X := 10;
      Kartica.Position.Y := YPozicija;
      Kartica.Fill.Color := TAlphaColorRec.White;
      Kartica.Stroke.Color := TAlphaColorRec.Lightgray;
      Kartica.XRadius := 8;
      Kartica.YRadius := 8;
      Kartica.Tag := ADOQuery1.FieldByName('ID zahteva').AsInteger;
      Kartica.OnClick := KarticaClick;

      LabelNovo := TLabel.Create(Kartica);
      LabelNovo.Parent := Kartica;
      LabelNovo.Text := '● NOVA TURA';
      LabelNovo.FontColor := TAlphaColorRec.Crimson;
      LabelNovo.Position.X := 10;
      LabelNovo.Position.Y := 8;
      LabelNovo.Font.Size := 11;

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

      YPozicija := YPozicija + 110;
      ADOQuery1.Next;
    end;

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

procedure TForm15.KarticaClick(Sender: TObject);
var
  KliknutiZahtevID: Integer;
begin
  KliknutiZahtevID := (Sender as TRectangle).Tag;

  if not Assigned(Form16) then
    Application.CreateForm(TForm16, Form16);

  Form16.ZahtevID := KliknutiZahtevID;
  Form16.UlogovaniVozac := UlogovaniVozac;
  Form16.PraviIDVozaca := UlogovaniVozac;
  Form16.Left := Self.Left;
  Form16.Top := Self.Top;
  Form16.Width := Self.Width;
  Form16.Height := Self.Height;
  Form16.Show;
  Self.Hide;
end;

procedure TForm15.SpeedButton1Click(Sender: TObject);
begin
  Form7.Show;
  Self.Hide;
end;

end.
