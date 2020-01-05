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
  FrmMain_CHs: array[0..MaxCHNum-1]of TFrmMain;//���ͨ���� G

implementation

{$R *.DFM}


procedure TFrmFace.FormCreate(Sender: TObject);
var i:Integer;
    FName:String;
begin
  FName:=ExtractFilePath(Application.ExeName)+'�����ļ�.Ini';
  SetupFile:=TIniFile.Create(FName);//Setup�������ļ�������ϵ G

  InitECSystem;//��ʼ�����ϵͳ G
 for i:=0 to MaxCHNum-1 do //��ÿ��ͨ�����ò��� G
  begin
    FrmMain_CHs[i]:=TFrmMain.Create(Application);//������ͬͨ���������� G
    FrmMain_CHs[i].CH_ID:=i;
    FrmMain_CHs[i].Caption:='ƣ������-CH'+IntToStr(i+1);
    FrmMain_CHs[i].Plot1.TitleText:='ƣ������-CH'+IntToStr(i+1);
  end;

  FrmMain_CHs[0].ECy[0]:=ECs[3].ECys[0]; //ͨ��1 2�ĵ������ ���� ��׿���ģʽ3��0.1.2.3 ������� G 
  FrmMain_CHs[0].ECy[1]:=ECs[3].ECys[2];
  FrmMain_CHs[1].ECy[0]:=ECs[3].ECys[1];
  FrmMain_CHs[1].ECy[1]:=ECs[3].ECys[3];

end;

procedure TFrmFace.Btn_CH1Click(Sender: TObject);
var Btn:TLbButton;
    ID:Integer;
begin
  Btn:=Sender as TLbButton; //sender�����˵������ڹ��̵Ŀؼ�G
  ID:=Btn.Tag;
 // ECy[ID*2]:=ECs[3].ECys[ID+0];
 // ECy[ID*2+1]:=ECs[3].ECys[ID+2];
  FrmMain_CHs[ID].Show;//��ʾ������ͬͨ�� G
end;

end.
