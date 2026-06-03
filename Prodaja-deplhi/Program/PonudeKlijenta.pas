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
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    procedure NapraviKarticuPonude(PonudaID, ZahtevID: Integer;
      Ruta, Datum, Cena, Valuta, RokPlacanja, Napomena: string);
    procedure KarticaClick(Sender: TObject);
    procedure PrihvatiClick(Sender: TObject);
    procedure OdbijClick(Sender: TObject);
  public
    KlijentID: Integer; // Dobija vrednost iz Form6 (Glavni meni klijenta)
  end;

var
  Form11: TForm11;

implementation

// Kružnu referencu rešavamo tako što forme stavljamo u implementation uses
uses Klijent, ProdajaTura;

{$R *.fmx}

procedure TForm11.FormShow(Sender: TObject);
var
  Ruta, Datum, Cena, Valuta, RokPlacanja, Napomena: string;
begin
  // Blokiramo osvežavanje ekrana dok čistimo i gradimo kartice
  VertScrollBox1.BeginUpdate;
  try
    VertScrollBox1.DeleteChildren;

    // Povezivanje na glavnu konekciju
    ADOQuery1.Connection := Form8.ADOConnection1;

    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;
    // Izvuci sve poslate ponude (StatusID = 3) za trenutno ulogovanog klijenta
    ADOQuery1.SQL.Add('SELECT p.PonudaID, p.ZahtevID, p.Cena, p.Valuta, p.RokPlacanja, p.Napomena,');
    ADOQuery1.SQL.Add('       z.MestoUtovara, z.MestoIstovara, z.DatumUtovara');
    ADOQuery1.SQL.Add('FROM Ponude p');
    ADOQuery1.SQL.Add('INNER JOIN Zahtevi z ON p.ZahtevID = z.[ID zahteva]');
    ADOQuery1.SQL.Add('WHERE z.KlijentID = :KlijentID AND p.StatusID = 3');
    ADOQuery1.Parameters.ParamByName('KlijentID').Value := KlijentID;
    ADOQuery1.Open;

    if ADOQuery1.IsEmpty then
    begin
      var Lbl := TLabel.Create(Self);
      Lbl.Parent := VertScrollBox1;
      Lbl.Align := TAlignLayout.Center;
      Lbl.TextSettings.FontColor := TAlphaColorRec.Gray;
      Lbl.TextSettings.HorzAlign := TTextAlign.Center;
      Lbl.Text := 'Trenutno nemate novih ponuda na čekanju.';
      Exit;
    end;

    // Prolazimo kroz bazu i punimo ScrollBox dinamičkim karticama
    while not ADOQuery1.Eof do
    begin
      Ruta := ADOQuery1.FieldByName('MestoUtovara').AsString + ' → ' +
              ADOQuery1.FieldByName('MestoIstovara').AsString;

      Datum := DateToStr(ADOQuery1.FieldByName('DatumUtovara').AsDateTime);
      Cena := FormatFloat('#,##0.00', ADOQuery1.FieldByName('Cena').AsFloat);
      Valuta := ADOQuery1.FieldByName('Valuta').AsString;
      RokPlacanja := ADOQuery1.FieldByName('RokPlacanja').AsString;

      if Trim(ADOQuery1.FieldByName('Napomena').AsString) <> '' then
        Napomena := ADOQuery1.FieldByName('Napomena').AsString
      else
        Napomena := '/';

      NapraviKarticuPonude(
        ADOQuery1.FieldByName('PonudaID').AsInteger,
        ADOQuery1.FieldByName('ZahtevID').AsInteger,
        Ruta, Datum, Cena, Valuta, RokPlacanja, Napomena
      );

      ADOQuery1.Next;
    end;
  finally
    VertScrollBox1.EndUpdate;
  end;
end;

procedure TForm11.NapraviKarticuPonude(PonudaID, ZahtevID: Integer;
  Ruta, Datum, Cena, Valuta, RokPlacanja, Napomena: string);
var
  Kartica: TRectangle;
  DetaljiKontejner: TLayout;
  LblRuta, LblDatum, LblCena, LblRok, LblNapomena: TLabel;
  BtnPrihvati, BtnOdbij: TButton;
begin
  // 1. Osnova kartice - Inicijalno skupljena na visinu 75
  Kartica := TRectangle.Create(Self);
  Kartica.Parent := VertScrollBox1;
  Kartica.Align := TAlignLayout.Top;
  Kartica.Height := 75;
  Kartica.Margins.Left := 15;
  Kartica.Margins.Right := 15;
  Kartica.Margins.Top := 10;
  Kartica.Margins.Bottom := 5;
  Kartica.Fill.Color := TAlphaColorRec.White;
  Kartica.Stroke.Color := $FFE0E0E0;
  Kartica.XRadius := 10;
  Kartica.YRadius := 10;
  Kartica.Tag := PonudaID; // Skriveni ID ponude za prepoznavanje kliknutog elementa
  Kartica.OnClick := KarticaClick;

  // 2. Elementi vidljivi odmah (Gornji deo)
  LblRuta := TLabel.Create(Kartica);
  LblRuta.Parent := Kartica;
  LblRuta.Position.X := 15;
  LblRuta.Position.Y := 15;
  LblRuta.Width := Kartica.Width - 30;
  LblRuta.Text := 'Relacija: ' + Ruta;
  LblRuta.Font.Size := 13;
  LblRuta.Font.Style := [TFontStyle.fsBold];
  LblRuta.TextSettings.FontColor := $FF1A5276;
  LblRuta.HitTest := False; // Klik prolazi kroz tekst na samu karticu

  LblCena := TLabel.Create(Kartica);
  LblCena.Parent := Kartica;
  LblCena.Position.X := 15;
  LblCena.Position.Y := 42;
  LblCena.Text := 'Iznos ponude: ' + Cena + ' ' + Valuta + ' (+ 20% PDV)';
  LblCena.Font.Style := [TFontStyle.fsBold];
  LblCena.TextSettings.FontColor := $FF27AE60; // Zelena boja cene
  LblCena.HitTest := False;

  // 3. Skriveni kontejner za Master-Detail pregled (Otvara se na klik)
  DetaljiKontejner := TLayout.Create(Kartica);
  DetaljiKontejner.Parent := Kartica;
  DetaljiKontejner.Position.X := 0;
  DetaljiKontejner.Position.Y := 75;
  DetaljiKontejner.Width := Kartica.Width;
  DetaljiKontejner.Height := 145;
  DetaljiKontejner.Visible := False;
  DetaljiKontejner.Name := 'Detalji_' + IntToStr(PonudaID);
  DetaljiKontejner.HitTest := False;

  // Tanka linija razdvajanja
  var Linija := TLine.Create(DetaljiKontejner);
  Linija.Parent := DetaljiKontejner;
  Linija.Position.X := 15;
  Linija.Position.Y := 0;
  Linija.Width := Kartica.Width - 30;
  Linija.Stroke.Color := $FFF2F4F4;

  // Datum utovara
  LblDatum := TLabel.Create(DetaljiKontejner);
  LblDatum.Parent := DetaljiKontejner;
  LblDatum.Position.X := 15;
  LblDatum.Position.Y := 15;
  LblDatum.Text := 'Datum utovara: ' + Datum;
  LblDatum.TextSettings.FontColor := $FF555555;

  // Rok plaćanja
  LblRok := TLabel.Create(DetaljiKontejner);
  LblRok.Parent := DetaljiKontejner;
  LblRok.Position.X := 15;
  LblRok.Position.Y := 38;
  LblRok.Text := 'Valuta plaćanja: ' + RokPlacanja + ' dana od završetka transporta';
  LblRok.TextSettings.FontColor := $FF555555;

  // Napomena
  LblNapomena := TLabel.Create(DetaljiKontejner);
  LblNapomena.Parent := DetaljiKontejner;
  LblNapomena.Position.X := 15;
  LblNapomena.Position.Y := 61;
  LblNapomena.Width := Kartica.Width - 30;
  LblNapomena.Text := 'Napomena prevoznika: ' + Napomena;
  LblNapomena.TextSettings.FontColor := TAlphaColorRec.Dimgray;

  // Dugme PRIHVATI
  BtnPrihvati := TButton.Create(DetaljiKontejner);
  BtnPrihvati.Parent := DetaljiKontejner;
  BtnPrihvati.Text := '✓ Prihvati ponudu';
  BtnPrihvati.Position.X := 15;
  BtnPrihvati.Position.Y := 95;
  BtnPrihvati.Width := 130;
  BtnPrihvati.Height := 32;
  BtnPrihvati.Tag := PonudaID;
  BtnPrihvati.OnClick := PrihvatiClick; // Povezujemo proceduru za bazu

  // Dugme ODBIJ
  BtnOdbij := TButton.Create(DetaljiKontejner);
  BtnOdbij.Parent := DetaljiKontejner;
  BtnOdbij.Text := '✕ Odbij';
  BtnOdbij.Position.X := 155;
  BtnOdbij.Position.Y := 95;
  BtnOdbij.Width := 100;
  BtnOdbij.Height := 32;
  BtnOdbij.Tag := PonudaID;
  BtnOdbij.OnClick := OdbijClick; // Povezujemo proceduru za bazu
end;

procedure TForm11.KarticaClick(Sender: TObject);
var
  SelektovanaKartica: TRectangle;
  KontejnerDetalji: TComponent;
  Komp: TFmxObject;
begin
  if Sender is TRectangle then
    SelektovanaKartica := TRectangle(Sender)
  else
    Exit;

  // Pronalazimo skriveni Layout po imenu
  KontejnerDetalji := SelektovanaKartica.FindComponent('Detalji_' + IntToStr(SelektovanaKartica.Tag));

  if Assigned(KontejnerDetalji) and (KontejnerDetalji is TLayout) then
  begin
    VertScrollBox1.BeginUpdate;
    try
      // Ako je skupljena, proširi je na 220px i prikaži detalje
      if SelektovanaKartica.Height = 75 then
      begin
        if Assigned(VertScrollBox1.Content) then
        begin
          // Skupljamo sve ostale da ekran bude uredan
          for Komp in VertScrollBox1.Content.Children do
          begin
            if (Komp is TRectangle) and (Komp <> SelektovanaKartica) then
            begin
              TRectangle(Komp).Height := 75;
              var OstaliDetalji := Komp.FindComponent('Detalji_' + IntToStr(Komp.Tag));
              if Assigned(OstaliDetalji) and (OstaliDetalji is TLayout) then
                TLayout(OstaliDetalji).Visible := False;
            end;
          end;
        end;

        SelektovanaKartica.Height := 220;
        TLayout(KontejnerDetalji).Visible := True;
      end
      else
      begin
        // Ako je bila raširena, ponovo je skupi
        SelektovanaKartica.Height := 75;
        TLayout(KontejnerDetalji).Visible := False;
      end;
    finally
      VertScrollBox1.EndUpdate;
    end;
  end;
end;

procedure TForm11.PrihvatiClick(Sender: TObject);
var
  ID: Integer;
begin
  ID := TButton(Sender).Tag; // Izvlačimo ID ponude iz džepa dugmeta
  if MessageDlg('Da li ste sigurni da želite da PRIHVATITE zvaničnu ponudu MPM Transporta?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    try
      ADOQuery1.Close;
      // Menjamo status u 4 (Prihvaćeno od strane klijenta)
      ADOQuery1.SQL.Text := 'UPDATE Ponude SET StatusID = 4 WHERE PonudaID = :ID';
      ADOQuery1.Parameters.ParamByName('ID').Value := ID;
      ADOQuery1.ExecSQL;

      ShowMessage('Uspešno ste prihvatili ponudu! Naš tim će Vas kontaktirati za realizaciju.');
      FormShow(Self); // Osvežavamo listu, prihvaćena ponuda nestaje sa ekrana klijenta
    except
      on E: Exception do
        ShowMessage('Greška pri ažuriranju baze podataka: ' + E.Message);
    end;
  end;
end;

procedure TForm11.OdbijClick(Sender: TObject);
var
  ID: Integer;
begin
  ID := TButton(Sender).Tag;
  if MessageDlg('Da li ste sigurni da želite da ODBIJETE ponudu?',
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    try
      ADOQuery1.Close;
      // Menjamo status u 2 (Odbijeno)
      ADOQuery1.SQL.Text := 'UPDATE Ponude SET StatusID = 2 WHERE PonudaID = :ID';
      ADOQuery1.Parameters.ParamByName('ID').Value := ID;
      ADOQuery1.ExecSQL;

      ShowMessage('Ponuda je označena kao odbijena.');
      FormShow(Self); // Osvežavamo listu
    except
      on E: Exception do
        ShowMessage('Greška pri ažuriranju baze podataka: ' + E.Message);
    end;
  end;
end;

procedure TForm11.SpeedButton1Click(Sender: TObject);
begin
  Form6.Show; // Povratak na glavni meni klijenta
  Self.Hide;
end;

end.
