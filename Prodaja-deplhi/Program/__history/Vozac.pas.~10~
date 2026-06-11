unit Vozac;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, UnosPodataka, FMX.Objects, FMX.Maps,
  Data.DB, Data.Win.ADODB, PozicijaForme, Menadzer, FMX.Layouts, VozacPonude;

type
  TForm7 = class(TForm)
    SpeedButton1: TSpeedButton;
    MapView1: TMapView;
    Text1: TText;
    btnIsporuke: TButton;
    btnProfil: TButton;
    btnChat: TButton;
    ADOConnection1: TADOConnection;
    ADOQuery1: TADOQuery;
    LayoutZvonce: TLayout;
    Zvonce: TPath;
    PravougaonikZvonce: TRectangle;
    Label1: TLabel;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ZvonceClick(Sender: TObject);
  private
    PraviIDVozaca: Integer;
  public
    UlogovaniVozac: Integer;
  end;

var
  Form7: TForm7;

implementation

{$R *.fmx}

procedure TForm7.FormCreate(Sender: TObject);
begin
  Position := TFormPosition.Designed;

  LayoutZvonce.Align := TAlignLayout.None;
  LayoutZvonce.Position.X := Self.Width - LayoutZvonce.Width - 25;
  LayoutZvonce.Position.Y := 10;
  LayoutZvonce.Anchors := [TAnchorKind.akTop, TAnchorKind.akRight];

  PravougaonikZvonce.Position.X := 22;
  PravougaonikZvonce.Position.Y := -2;
  PravougaonikZvonce.BringToFront;

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
end;

procedure TForm7.FormShow(Sender: TObject);
var
  BrojRezervacija: Integer;
begin
  try
    if not ADOConnection1.Connected then
      ADOConnection1.Connected := True;

    ADOQuery1.Connection := ADOConnection1;

    ADOQuery1.Close;
    ADOQuery1.SQL.Text := 'SELECT IDVozaca FROM Vozaci WHERE LoginID = :LoginID';
    ADOQuery1.Parameters.ParseSQL(ADOQuery1.SQL.Text, True);
    ADOQuery1.Parameters.ParamByName('LoginID').Value := UlogovaniVozac;
    ADOQuery1.Open;

    if ADOQuery1.IsEmpty then
    begin
      PravougaonikZvonce.Visible := False;
      Exit;
    end;

    PraviIDVozaca := ADOQuery1.FieldByName('IDVozaca').AsInteger;

    ADOQuery1.Close;
   ADOQuery1.SQL.Text :=
  'SELECT COUNT(*) AS Ukupno ' +
  'FROM ((Rezervacije r ' +
  'INNER JOIN Zahtevi z ON r.ZahtevID = z.[ID zahteva]) ' +
  'LEFT JOIN Ponude p ON z.[ID zahteva] = p.ZahtevID) ' +
  'WHERE r.VozacID = :VozacID AND ' +
  'IIF(p.StatusID IS NOT NULL, p.StatusID, z.StatusID) = 4';
    ADOQuery1.Parameters.ParseSQL(ADOQuery1.SQL.Text, True);
    ADOQuery1.Parameters.ParamByName('VozacID').Value := PraviIDVozaca;
    ADOQuery1.Open;

    BrojRezervacija := ADOQuery1.FieldByName('Ukupno').AsInteger;

    if BrojRezervacija > 0 then
    begin
      Label1.Text := IntToStr(BrojRezervacija);
      PravougaonikZvonce.Visible := True;
      PravougaonikZvonce.BringToFront;
      Label1.BringToFront;
    end
    else
      PravougaonikZvonce.Visible := False;

  except
    on E: Exception do
      ShowMessage('Greška: ' + E.Message);
  end;
end;

procedure TForm7.ZvonceClick(Sender: TObject);
begin
  if not Assigned(Form15) then
    Application.CreateForm(TForm15, Form15);
  Form15.UlogovaniVozac := PraviIDVozaca;
  Form15.Left := Self.Left;
  Form15.Top := Self.Top;
  Form15.Width := Self.Width;
  Form15.Height := Self.Height;
  Form15.Show;
  Self.Hide;
end;

procedure TForm7.SpeedButton1Click(Sender: TObject);
begin
  Form2.Show;
  Close;
end;

procedure TForm7.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LastFormX := Left;
  LastFormY := Top;
end;

end.
