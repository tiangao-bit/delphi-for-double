unit Face;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  LbButton,  IniFiles, NI_Delphi, PublicUnit, Main, EController;

type
  TFrmFace = class(TForm)
    Btn_CH1: TLbButton;
    Btn_CH2: TLbButton;
    procedure FormCreate(Sender: TObject);
    procedure Btn_CH1Click(Sender: TObject);

  private
    { Private declarations }
  public

  end;

var
  FrmFace: TFrmFace;
  FrmMain_CHs: array[0..MaxCHNum-1]of TFrmMain;//最大通道数 G

implementation

{$R *.DFM}


procedure TFrmFace.FormCreate(Sender: TObject);
var i:Integer;
    FName:String;
begin
  FName:=ExtractFilePath(Application.ExeName)+'配置文件.Ini';
  SetupFile:=TIniFile.Create(FName);//Setup与配置文件建立联系 G

  InitECSystem;//初始化电缸系统 G
 for i:=0 to MaxCHNum-1 do //给每个通道设置参数 G
  begin
    FrmMain_CHs[i]:=TFrmMain.Create(Application);//创建不同通道的主窗口 G
    FrmMain_CHs[i].CH_ID:=i;
    FrmMain_CHs[i].Caption:='疲劳试验-CH'+IntToStr(i+1);
    FrmMain_CHs[i].Plot1.TitleText:='疲劳试验-CH'+IntToStr(i+1);
  end;

  FrmMain_CHs[0].ECy[0]:=ECs[3].ECys[0]; //通道1 2的电缸属性 等于 电缸控制模式3的0.1.2.3 电缸属性 G 
  FrmMain_CHs[0].ECy[1]:=ECs[3].ECys[2];
  FrmMain_CHs[1].ECy[0]:=ECs[3].ECys[1];
  FrmMain_CHs[1].ECy[1]:=ECs[3].ECys[3];

end;

procedure TFrmFace.Btn_CH1Click(Sender: TObject);
var Btn:TLbButton;
    ID:Integer;
begin
  Btn:=Sender as TLbButton; //sender代表了调用所在过程的控件G
  ID:=Btn.Tag;
 // ECy[ID*2]:=ECs[3].ECys[ID+0];
 // ECy[ID*2+1]:=ECs[3].ECys[ID+2];
  FrmMain_CHs[ID].Show;//显示两个不同通道 G
end;

end.
