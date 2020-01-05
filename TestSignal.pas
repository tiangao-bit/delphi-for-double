unit TestSignal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, iComponent, iVCLComponent, iEditCustom,
  iAnalogOutput, ComCtrls, Buttons, PublicUnit, LbButton, iEdit,
  LbSpeedButton;
type
  TFrmTestSignal = class(TForm)
    BtnCancel: TLbButton;
    BtnOK: TLbButton;
    lbl6: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    InputA1: TiEdit;
    InputA2: TiEdit;
    InputA3: TiEdit;
    Label1: TLabel;
    InputA4: TiEdit;
    procedure BtnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CH_ID:Integer;
  end;

var
  FrmTestSignal: TFrmTestSignal;

implementation

{$R *.DFM}

procedure TFrmTestSignal.BtnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmTestSignal.FormShow(Sender: TObject);
var Str:String;
    Data:array[0..50]of Single;
begin
  Str:=SetupFile.ReadString('试验参数','通道'+inttostr(CH_ID),'10 0.5 0 -1');
  GetDataFromString(Str,Data);
  InputA1.Value:=Format('%.0f',[Data[0]]);
  InputA2.Value:=Format('%.1f',[Data[1]]);
  InputA3.Value:=Format('%.0f',[Data[2]]);
  InputA4.Value:=Format('%.0f',[Data[3]]);
end;

procedure TFrmTestSignal.BtnOKClick(Sender: TObject);
var Str:String;
begin
  Str:=InputA1.Value+' '+InputA2.Value+' '+InputA3.Value+' '+InputA4.Value;
  SetupFile.WriteString('试验参数','通道'+inttostr(CH_ID),Str);
  SetupFile.UpdateFile;
end;

end.
