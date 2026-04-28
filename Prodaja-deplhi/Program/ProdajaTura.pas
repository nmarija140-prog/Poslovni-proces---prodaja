unit ProdajaTura;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Ani, FMX.Layouts;

type
  TForm8 = class(TForm)
    HambMeni2: TSpeedButton;
    PanelProdaja: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Layout1: TLayout;
    PoslateKartica: TRectangle;
    RectAnimation1: TRectAnimation;
    RectAnimation2: TRectAnimation;
    PrihvaceneKartica: TRectangle;
    RectAnimation3: TRectAnimation;
    NoviZahteviKartica: TRectangle;
    RectAnimation4: TRectAnimation;
    OdbijeneKartica: TRectangle;
    RectAnimation5: TRectAnimation;
    Text1: TText;
    Text2: TText;
    Text3: TText;
    Text4: TText;
    noviZahtevDugme: TSpeedButton;
    procedure HambMeni2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form8: TForm8;

implementation

{$R *.fmx}

procedure TForm8.HambMeni2Click(Sender: TObject);
begin
PanelProdaja.Visible := not PanelProdaja.Visible;
HambMeni2.BringToFront;
end;

end.
