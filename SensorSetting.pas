unit SensorSetting;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, iComponent, iVCLComponent, iEditCustom, iAnalogOutput,
  LbSpeedButton, LbButton, iEdit, Mask, Grids, IniFiles,PublicUnit,
  jpeg, ExtCtrls, ComCtrls, Face;

type
  TFrmSensorSetting = class(TForm)
    btnApply: TLbButton;
    btnOK: TLbButton;
    Label6: TLabel;
    Label8: TLabel;
    InputA1: TiAnalogOutput;
    InputB1: TiAnalogOutput;
    Panel1: TPanel;
    Label1: TLabel;
    Label12: TLabel;
    Label15: TLabel;
    InputA2: TiAnalogOutput;
    InputB2: TiAnalogOutput;
    LbButton1: TLbButton;
    Label3: TLabel;
    btnCancel: TLbButton;
    btn2: TLbButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure LbButton1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    CH_ID:Integer;
  end;

var
  FrmSensorSetting: TFrmSensorSetting;

implementation

uses Main;

{$R *.DFM}

procedure TFrmSensorSetting.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSensorSetting.btnOKClick(Sender: TObject);
begin
  btnApply.Click;
  Close;
end;

procedure TFrmSensorSetting.btnApplyClick(Sender: TObject);
var Str:string;
begin
  Str:=InputA1.Text+' '+InputA2.Text;
  SetupFile.WriteString('传感器'+inttostr(CH_ID)+'参数','角度',Str);
  Str:=InputB1.Text+' '+InputB2.Text;
  SetupFile.WriteString('传感器'+inttostr(CH_ID)+'参数','扭矩',Str);
  SetupFile.UpdateFile;

  FrmMain_CHs[CH_ID].LoadSensorPara;
end;

procedure TFrmSensorSetting.LbButton1Click(Sender: TObject);
begin
  InputA2.Value:=FrmMain_CHs[CH_ID].Ecy[1].TD.speed;
end;

procedure TFrmSensorSetting.btn2Click(Sender: TObject);
begin
  InputB2.Value:=FrmMain_CHs[CH_ID].Ecy[0].Td.actforce;
end;

procedure TFrmSensorSetting.FormShow(Sender: TObject);
var Str:string;
    Data:array[0..10]of Single;
begin
  Str:=SetupFile.ReadString('传感器'+inttostr(CH_ID)+'参数','角度','1 0');
  GetDataFromString(Str,Data);
  InputA1.Value:=Data[0];   InputA2.Value:=Data[1];

  Str:=SetupFile.ReadString('传感器'+inttostr(CH_ID)+'参数','扭矩','1 0');
  GetDataFromString(Str,Data);
  InputB1.Value:=Data[0];   InputB2.Value:=Data[1];
end;

end.
