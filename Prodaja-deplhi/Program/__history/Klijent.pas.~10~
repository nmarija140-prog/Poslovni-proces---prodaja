unit Klijent;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, UnosPodataka, FMX.Objects, PozicijaForme,
  FMX.Layouts, Data.DB, Data.Win.ADODB, ProdajaTura;

type
  TForm6 = class(TForm)
    Image1: TImage;
    Text1: TText;
    txtImeKorisnika: TText;
    txtNazivFirme: TText;
    txtPIB: TText;
    txtAdresa: TText;
    btnOtvoriNalog: TButton;
    btnUrediProfil: TButton;
    txtEmail: TText;
    txtBrojTelefona: TText;
    Zvonce: TPath;
    Label1: TLabel;
    PravougaonikZvonce: TRectangle;
    LayoutZvonce: TLayout;
    ADOQuery1: TADOQuery;
    Panel1: TPanel;
    mojProfil: TButton;
    chat: TButton;
    istorijaIsporuke: TButton;
    Fakture: TButton;
    Pomoc: TButton;
    odjava: TButton;
    Ponude: TButton;
    HambMeni2: TSpeedButton;
    procedure HambMeni2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ZvonceClick(Sender: TObject);
    procedure PonudeClick(Sender: TObject);


  private
    PraviIDKlijenta: Integer;
  public
    UlogovaniUser: Integer;
  end;

var
  Form6: TForm6;

implementation

uses Detalji, pocetna, PonudeKlijenta;

{$R *.fmx}

procedure TForm6.FormCreate(Sender: TObject);
begin
  LayoutZvonce.Align := TAlignLayout.None;


  LayoutZvonce.Position.X := Self.Width - LayoutZvonce.Width - 25;
  LayoutZvonce.Position.Y := 10;


  LayoutZvonce.Anchors := [TAnchorKind.akTop, TAnchorKind.akRight];

  PravougaonikZvonce.Position.X := 22;
  PravougaonikZvonce.Position.Y := -2;

  PravougaonikZvonce.BringToFront;
  Position := TFormPosition.Designed;

  if LastFormX <> -1 then
  begin
    Left := Round(LastFormX);
    Top := Round(LastFormY);
  end;
end;

procedure TForm6.FormShow(Sender: TObject);
var
  BrojPonuda: Integer;
begin
  try

    ADOQuery1.Connection := Form8.ADOConnection1;


    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;
    ADOQuery1.SQL.Add('SELECT * FROM Klijenti WHERE LoginID = :LoginID');
    ADOQuery1.Parameters.ParamByName('LoginID').Value := UlogovaniUser;
    ADOQuery1.Open;

    if not ADOQuery1.IsEmpty then
    begin
      PraviIDKlijenta := ADOQuery1.FieldByName('IDKlijenta').AsInteger;


      txtNazivFirme.Text := ADOQuery1.FieldByName('nazivKlijenta').AsString;
      txtImeKorisnika.Text := ADOQuery1.FieldByName('kontaktOsoba').AsString;
      txtPIB.Text := 'PIB: ' + ADOQuery1.FieldByName('PIB').AsString;
      txtAdresa.Text := ADOQuery1.FieldByName('adresa').AsString;
      txtEmail.Text := ADOQuery1.FieldByName('email').AsString;
      txtBrojTelefona.Text := ADOQuery1.FieldByName('telefon').AsString;
    end
    else
    begin
      ShowMessage('Greška: Nisu pronađeni korisnički podaci za nalog.');
      Exit;
    end;
    ADOQuery1.Close;
    ADOQuery1.SQL.Clear;
    ADOQuery1.SQL.Add('SELECT COUNT(*) AS UkupnoNovih FROM Ponude p ');
    ADOQuery1.SQL.Add('INNER JOIN Zahtevi z ON p.ZahtevID = z.[ID zahteva] ');
    ADOQuery1.SQL.Add('WHERE z.KlijentID = :KlijentID AND p.StatusID = 3');
    ADOQuery1.Parameters.ParamByName('KlijentID').Value := PraviIDKlijenta;
    ADOQuery1.Open;

    BrojPonuda := ADOQuery1.FieldByName('UkupnoNovih').AsInteger;

    if BrojPonuda > 0 then
    begin
      Label1.Text := IntToStr(BrojPonuda);
      PravougaonikZvonce.Visible := True;

      PravougaonikZvonce.BringToFront;
      Label1.BringToFront;
    end
    else
    begin
      PravougaonikZvonce.Visible := False;
    end;

  except
    on E: Exception do
      ShowMessage('Greška pri učitavanju: ' + E.Message);
  end;
end;

procedure TForm6.HambMeni2Click(Sender: TObject);
begin
  Panel1.Visible := not Panel1.Visible;
  if Panel1.Visible then
  begin
    Panel1.BringToFront;
  end;
  HambMeni2.BringToFront;
end;


procedure TForm6.PonudeClick(Sender: TObject);
begin
  if not Assigned(Form11) then
    Application.CreateForm(TForm11, Form11);
  Form11.PraviIDKlijenta := PraviIDKlijenta;
  Form11.Left := Self.Left;
  Form11.Top := Self.Top;
  Form11.Width := Self.Width;
  Form11.Height := Self.Height;
  Form11.Show;
  Self.Hide;

end;

procedure TForm6.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LastFormX := Left;
  LastFormY := Top;
end;
procedure TForm6.ZvonceClick(Sender: TObject);
begin
  if not Assigned(Form11) then
    Application.CreateForm(TForm11, Form11);
  Form11.PraviIDKlijenta := PraviIDKlijenta;
  Form11.Left := Self.Left;
  Form11.Top := Self.Top;
  Form11.Width := Self.Width;
  Form11.Height := Self.Height;
  Form11.Show;
  Self.Hide;
end;
end.
