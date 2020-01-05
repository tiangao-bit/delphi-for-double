unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, iSevenSegmentDisplay, iSevenSegmentAnalog, iComponent, IniFiles,
  iVCLComponent, iPlotComponent, iXYPlot, publicunit, LbSpeedButton,
  ExtCtrls, EController, iAnalogDisplay, iEditCustom, iAnalogOutput,
  ComCtrls;

type
  TFrmMain = class(TForm)
    NowAngleDisp: TiSevenSegmentAnalog;
    lbl1: TLabel;
    NowTorqueDisp: TiSevenSegmentAnalog;
    lbl2: TLabel;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    OutputA1: TiAnalogOutput;
    NowPositionDisp: TiSevenSegmentAnalog;
    label111: TLabel;
    PC1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    Plot2: TiXYPlot;
    Plot1: TiXYPlot;
    Label7: TLabel;
    NowMaxTorqueDisp: TiSevenSegmentAnalog;
    NowRunCountDisp: TiSevenSegmentAnalog;
    Label9: TLabel;
    MaxTorqueOffDisp: TiSevenSegmentAnalog;
    Label13: TLabel;
    InitMinTorqueDisp: TiSevenSegmentAnalog;
    Label14: TLabel;
    NowMinTorqueDisp: TiSevenSegmentAnalog;
    Label15: TLabel;
    MinTorqueOffDisp: TiSevenSegmentAnalog;
    Label5: TLabel;
    Label6: TLabel;
    Label11: TLabel;
    NowMaxAngleDisp: TiSevenSegmentAnalog;
    InitMaxTorqueDisp: TiSevenSegmentAnalog;
    NowMinAngleDisp: TiSevenSegmentAnalog;
    RunCountSetZero: TLbSpeedButton;
    Plot3: TiXYPlot;
    Panel1: TPanel;
    BtnStart: TLbSpeedButton;
    BtnCurver: TLbSpeedButton;
    BtnRunPara: TLbSpeedButton;
    LbSpeedButton2: TLbSpeedButton;
    BtnECy: TLbSpeedButton;
    LbSpeedButton1: TLbSpeedButton;
    BtnReset: TLbSpeedButton;
    AngleReset: TLbSpeedButton;
    StopRun: TLbSpeedButton;
    PositionSetZero: TLbSpeedButton;
    AngleSetZero: TLbSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnStartClick(Sender: TObject);
    procedure BtnCurverClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtnECyClick(Sender: TObject);
    procedure LbSpeedButton2Click(Sender: TObject);
    procedure BtnRunParaClick(Sender: TObject);
    procedure LbSpeedButton1Click(Sender: TObject);
    procedure ClearRunCountClick(Sender: TObject);
    procedure BtnResetClick(Sender: TObject);
    procedure OutputA1Change(Sender: TObject);
    procedure StopRunClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure PositionSetZeroClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GetRunFre;
    procedure AngleSetZeroClick(Sender: TObject);
    procedure ShowDisp;
    procedure RunCountSetZeroClick(Sender: TObject);
    procedure AngleResetClick(Sender: TObject);
  private
    { Private declarations }
    RunAmp,RunFreq,RunOffset:Single;
  public
    { Public declarations }
    CH_ID, ReCount: Integer;
    RunState,ShowPlotState: Integer;
    S_Angle, S_Torque: TSensor;
    n:Integer;
    ECy: array[0..1] of TECylinder;//Cylinder电缸 G


    TorqueResetFlag,AngleResetFlag:Boolean; //扭矩系统复位标志位
    TorqueResetState,AngleResetState:Integer;   //扭矩系统复位状态
    ClearPlot2Index,ClearPlot3Index:Integer;




    SaveDataFlag:array[0..3] of Boolean;
    procedure ClearPlotData(st:Single);
    procedure LoadSensorPara;
    procedure SaveParaToText;

  //  procedure GetMaxandMinTorque;
  //  procedure ClearMaxandMinTorque;
  end;

var
  FrmMain: TFrmMain;

implementation

uses TestSignal, SensorSetting, Face;

{$R *.DFM}

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  RunState:=0;
  ShowPlotState:=0 ;
  LoadSensorPara;
  TorqueResetState:=0;
  AngleResetState:=0;
 // ECy[0]:=nil;
 // ECy[1]:=nil;
end;

procedure TFrmMain.BtnStartClick(Sender: TObject);
var Str:String;
    Data:array[0..50]of Single;
begin
  if RunState=1 then
  begin
    ECy[0].Stop;
    RunState:=0;
    BtnCurver.Color:=$00ECCE94;
    Plot1.BeginUpdate;
    SaveFile(CH_ID);
  end
  else
  begin
    HistoryCount[CH_ID]:=SetupFile.ReadInteger('已试验次数','通道'+inttostr(CH_ID),0);
    ECy[0].AutoRun;
    GetAveTorque[CH_ID]:=True;
    AveMaxTorque[CH_ID]:=0;
    AveMinTorque[CH_ID]:=0;
    SumMaxTorque[CH_ID]:=0;
    SumMinTorque[CH_ID]:=0;
    GetTorqueNumber[CH_ID]:=0;
    GetTorqueIndex[CH_ID]:=0;
    JudgeFreCount[CH_ID]:=0;
    RunState:=1;
    ClearPlotData(0);
    BtnCurver.Color:=clLime;
    Plot1.EndUpdate;
    AllDataBufCount[CH_ID]:=0;
    DataBufCount[CH_ID]:=0;
  end;
end;

procedure TFrmMain.GetRunFre;
var IniFile:TIniFile;
    FName,SecName,Str:String;
    Strs:TStringList;
    SelectTaskID,abd:Integer;
begin
  FName:=ExtractFilePath(Application.ExeName)+'Setup(192.168.1.103).Ini';
  IniFile:=TIniFile.Create(FName);
end;

procedure TFrmMain.BtnCurverClick(Sender: TObject);
var Btn:TLbSpeedButton;
begin
  if BtnCurver.Color=clLime then
  begin
    BtnCurver.Color:=$00ECCE94;
    Plot1.BeginUpdate;
    ShowPlotState:=0
  end
  else
  begin
    BtnCurver.Color:=clLime;
    ClearPlotData(0);
    Plot1.EndUpdate;
    ShowPlotState:=1;
    MyTimer[CH_ID].Clear(0);
  end;
end;

procedure TFrmMain.Timer1Timer(Sender: TObject);
var i,j:Integer;
begin

  //获取当前的数值
   if (Ecy[0]<>nil) and (Ecy[1]<>nil)  then
   begin



    //读出当前的角度和扭矩
     if CH_ID=0 then
     begin
       NowAngle[CH_ID]:=(Ecy[1].TD.speed-AngleOff[CH_ID])*AngleGain[CH_ID];  //取角度
       NowTorque[CH_ID]:=(Ecy[0].TD.actforce-TorqueOff[CH_ID])*TorqueGain[CH_ID];   //取扭矩
       MaxAngle[CH_ID]:=(Ecy[1].TD.givpos-AngleOff[CH_ID])*AngleGain[CH_ID];//取最大角度
       MinAngle[CH_ID]:=(Ecy[1].TD.actpos-Angleoff[CH_ID])*AngleGain[CH_ID]; //取最小角度

       MaxTorque[CH_ID]:=(Ecy[1].TD.givforce-TorqueOff[CH_ID])*TorqueGain[CH_ID];//取最大扭矩
       MinTorque[CH_ID]:=(Ecy[1].TD.actforce-TorqueOff[CH_ID])*TorqueGain[CH_ID];  //取最小扭矩
     end;

     if CH_ID=1 then
     begin
       NowAngle[CH_ID]:=-(Ecy[1].TD.speed-AngleOff[CH_ID])*AngleGain[CH_ID];  //取角度
       NowTorque[CH_ID]:=(Ecy[0].TD.actforce-TorqueOff[CH_ID])*TorqueGain[CH_ID];   //取扭矩
       MinAngle[CH_ID]:=(Ecy[1].TD.givpos-AngleOff[CH_ID])*AngleGain[CH_ID];//取最大角度
       MaxAngle[CH_ID]:=(Ecy[1].TD.actpos-Angleoff[CH_ID])*AngleGain[CH_ID]; //取最小角度

       MaxTorque[CH_ID]:=(Ecy[1].TD.givforce-TorqueOff[CH_ID])*TorqueGain[CH_ID];//取最大扭矩
       MinTorque[CH_ID]:=(Ecy[1].TD.actforce-TorqueOff[CH_ID])*TorqueGain[CH_ID];  //取最小扭矩
     end;



   {  if(AveMaxTorque[CH_ID]<>0) and(AveMinTorque[CH_ID]<>0) then
     begin
       MaxTorqueOff[CH_ID]:=(MaxAngle[CH_ID]-AveMaxTorque[CH_ID])/AveMaxTorque[CH_ID];   //取最大最小扭矩偏差的百分比
       MinTorqueOff[CH_ID]:=(MinAngle[CH_ID]-AveMinTorque[CH_ID])/AveMinTorque[CH_ID];
     end;    }


     ShowDisp;  //显示当前运行数值

   end;










  if(RunState>0) or (ShowPlotState>0) then

  begin
    NowRunCount[CH_ID]:=ECy[0].TD.runcount+HistoryCount[CH_ID];

    //存所有的数据

    AllDataBuf[CH_ID,0,AllDataBufCount[CH_ID]]:=MyTimer[CH_ID].GetTime(0);
    AllDataBuf[CH_ID,1,AllDataBufCount[CH_ID]]:=NowTorque[CH_ID];
    AllDataBuf[CH_ID,2,AllDataBufCount[CH_ID]]:=NowAngle[CH_ID];
    Inc(AllDataBufCount[CH_ID]);

    if LastRunCount[CH_ID]<>NowRunCOunt[CH_ID] then     //一个周期结束之后
    begin
      Inc(ClearPlot2Index);

      //往存数据的数组里存数 两个通道，每个通道4个

      DataBuf[CH_ID,0,DataBufCount[CH_ID]]:=MyTimer[CH_ID].GetTime(2);
      DataBuf[CH_ID,1,DataBufCount[CH_ID]]:=MaxTorque[CH_ID];
      DataBuf[CH_ID,2,DataBufCount[CH_ID]]:=MinTorque[CH_ID];
      DataBuf[CH_ID,3,DataBufCount[CH_ID]]:=MaxAngle[CH_ID];
      DataBuf[CH_ID,4,DataBufCount[CH_ID]]:=MinAngle[CH_ID];
      DataBuf[CH_ID,5,DataBufCount[CH_ID]]:=NowRunCount[CH_ID];

      Inc(DataBufCount[CH_ID]);

      if(MyTimer[CH_ID].GetTime(2)>300) then    //每300秒存一次数据
      begin
        SaveFile(CH_ID);
        MyTimer[CH_ID].Clear(2);

      end;



      if (GetTorqueIndex[CH_ID]=1) and(AveMaxTorque[CH_ID]<>0) and(AveMinTorque[CH_ID]<>0)then
      begin
        MaxTorqueOff[CH_ID]:= (MaxTorque[CH_ID]-AveMaxTorque[CH_ID])/AveMaxTorque[CH_ID]*100;
        MinTorqueOff[CH_ID]:= (MinTorque[CH_ID]-AveMinTorque[CH_ID])/AveMinTorque[CH_ID]*100;
        if((MaxTorque[CH_ID]/AveMaxTorque[CH_ID])<0.8) and((Abs(MinTorque[CH_ID])/Abs(AveMinTorque[CH_ID]))<0.8)  then
        begin
         ECy[0].Stop;
         SaveDataFlag[CH_ID]:=True;
         SaveParaToText;
         RunState:=0;
         AveMaxTorque[CH_ID]:=0;
         AveMinTorque[CH_ID]:=0;
         GetTorqueNumber[CH_ID]:=0;
         GetTorqueIndex[CH_ID]:=0;
         SumMaxTorque[CH_ID]:=0;
         SumMinTorque[CH_ID]:=0;
        end;
      end;

      if (NowRunCount[CH_ID]>=RunMaxCount[CH_ID]) then   //运行次数大于设定的最大运行次数时停机
      begin
         ECy[0].Stop;
         SaveDataFlag[CH_ID]:=True;
         SaveParaToText;
         RunState:=0;
      end;

      if GetAveTorque[CH_ID]=True then                 //每次点击开始运行时 取得当次运行的最大最小停机扭矩
      begin
         JudgeMaxTorque[CH_ID,GetTorqueNumber[CH_ID]]:=MaxTorque[CH_ID];
         JudgeMinTorque[CH_ID,GetTorqueNumber[CH_ID]]:=MinTorque[CH_ID];
         //SumMaxTorque[CH_ID]:=SumMaxTorque[CH_ID]+ JudgeMaxTorque[CH_ID,GetTorqueNumber[CH_ID]];
        // SumMinTorque[CH_ID]:=SumMinTorque[CH_ID]+ JudgeMinTorque[CH_ID,GetTorqueNumber[CH_ID]];
         GetTorqueNumber[CH_ID]:= GetTorqueNumber[CH_ID]+1;

         if GetTorqueNumber[CH_ID] = 11 then     //取了10个周期的最大最小值后，记录判断的最大最小扭矩
         begin
           for j:=1 to 10 do
           begin
             SumMaxTorque[CH_ID]:=SumMaxTorque[CH_ID]+ JudgeMaxTorque[CH_ID,j];
             SumMinTorque[CH_ID]:=SumMinTorque[CH_ID]+ JudgeMinTorque[CH_ID,j];
           end;
           GetAveTorque[CH_ID]:=False;
           GetTorqueNumber[CH_ID]:=0;
           AveMaxTorque[CH_ID]:=SumMaxTorque[CH_ID]*0.1;  //得到停机的扭矩平均最大最小扭矩
           AveMinTorque[CH_ID]:=SumMinTorque[CH_ID]*0.1;
           GetTorqueIndex[CH_ID]:=1;
           for j:=0 to 9 do
             begin
               JudgeMaxTorque[CH_ID,j]:=0;
               JudgeMinTorque[CH_ID,j]:=0;
             end;
         end;

      end;


    end;

    LastRunCount[CH_ID]:=NowRunCOunt[CH_ID];


    //画图
    if BtnCurver.Color =clLime then
    begin

      //第一个图的显示
      with Plot1.Channel[0] do if visible then AddXY(MyTimer[CH_ID].GetTime(0),NowAngle[CH_ID]);
      with Plot1.Channel[1] do if visible then AddXY(MyTimer[CH_ID].GetTime(0),NowTorque[CH_ID]);

      if MyTimer[CH_ID].GetTime(0)>Plot1.XAxis[0].Max then Plot1.XAxis[0].Min:=Plot1.XAxis[0].Min+Plot1.XAxis[0].Span/4;
      if MyTimer[CH_ID].GetTime(0)>300 then
      begin
        MYTimer[CH_ID].Clear(0);
        Plot1.ClearAllData;
        Plot1.XAxis[0].Min:=0;

        SaveAllDataFile(CH_ID);

      end;

      //第二个图的显示曲线
      with Plot2.Channel[0] do if visible then AddXY(NowAngle[CH_ID],NowTorque[CH_ID]);
      if  ClearPlot2Index = 1 then
      begin
         Plot2.ClearAllData;
         ClearPlot2Index:=0;
      end;

      //第三个图的显示曲线

      if round(MyTimer[CH_ID].GetTime(1)) mod 4=0  then //每隔4秒画一次
      begin
         with Plot3.Channel[0] do if visible then AddXY(MyTimer[CH_ID].GetTime(1),MaxTorque[CH_ID]);
         with Plot3.Channel[1] do if visible then AddXY(MyTimer[CH_ID].GetTime(1),MinTorque[CH_ID]);
         with Plot3.Channel[2] do if visible then AddXY(MyTimer[CH_ID].GetTime(1),MaxAngle[CH_ID]);
         with Plot3.Channel[3] do if visible then AddXY(MyTimer[CH_ID].GetTime(1),MinAngle[CH_ID]);
        // Inc(ClearPlot3Index);

      end;
     // if MyTimer[CH_ID].GetTime(1)>Plot3.XAXis[0].Max then Plot3.XAxis[0].Min:=Plot3.XAxis[0].Min+Plot3.XAxis[0].Span/4;



    end;

     LastRunCount[CH_ID]:=NowRunCOunt[CH_ID];

  end;

  if TorqueResetFlag then  //  执行扭矩复位程序
  begin
     if TorqueResetState=1 then
     begin
       if NowTorque[CH_ID]>0 then
       begin
         ECy[0].ClearSig;
         ECy[0].RunFix(SPEED_CONTROL,-1*0.15);
         TorqueResetState:=2;
       end;
       if NowTorque[CH_ID]<0 then
       begin
         ECy[0].ClearSig;
         ECy[0].RunFix(SPEED_CONTROL,1*0.15);
         TorqueResetState:=3;
       end;
     end;
     if TorqueResetState = 2 then
     begin
        if NowTorque[CH_ID]< 0.1 then
        begin
          ECy[0].Stop;
          TorqueResetState:=0;
          TorqueResetFlag:=False;
        end;

        if Abs(NowTorque[CH_ID])>50  then
        begin
          ECy[0].Stop;
          TorqueResetState:=0;
          TorqueResetFlag:=False;
        end;
     end;

     if TorqueResetState = 3 then
     begin
        if NowTorque[CH_ID]> -0.1 then
        begin
          ECy[0].Stop;
          TorqueResetState:=0;
          TorqueResetFlag:=False;
        end;

        if Abs(NowTorque[CH_ID])>50  then
        begin
          ECy[0].Stop;
          TorqueResetState:=0;
          TorqueResetFlag:=False;
        end;
     end;

  end;

  if AngleResetFlag then  //  执行角度复位程序
  begin
     if AngleResetState=1 then
     begin
       if NowAngle[CH_ID]>0 then
       begin
         ECy[0].ClearSig;
         ECy[0].RunFix(SPEED_CONTROL,-1*0.2);
         AngleResetState:=2;
       end;
       if NowAngle[CH_ID]<0 then
       begin
         ECy[0].ClearSig;
         ECy[0].RunFix(SPEED_CONTROL,1*0.2);
         AngleResetState:=3;
       end;
     end;
     if AngleResetState = 2 then
     begin
        if NowAngle[CH_ID]< 0.05 then
        begin
          ECy[0].Stop;
          AngleResetState:=0;
          AngleResetFlag:=False;
        end;

        if Abs(NowAngle[CH_ID])> 5  then
        begin
          ECy[0].Stop;
          AngleResetState:=0;
          AngleResetFlag:=False;
        end;
     end;

     if AngleResetState = 3 then
     begin
        if NowAngle[CH_ID] >- 0.05 then
        begin
          ECy[0].Stop;
          AngleResetState:=0;
          AngleResetFlag:=False;
        end;

        if Abs(NowAngle[CH_ID])> 5  then
        begin
          ECy[0].Stop;
          AngleResetState:=0;
          AngleResetFlag:=False;
        end;
     end;

  end;

end;

procedure TFrmMain.ClearPlotData(st:Single);
begin
  Plot1.ClearAllData;
  Plot1.XAxis[0].Min:=st;
  MyTimer[CH_ID].CLear(0);
  MyTimer[CH_ID].CLear(2);
end;

procedure TFrmMain.BtnECyClick(Sender: TObject);
begin
  ECy[0].ShowECyParaSetting;
end;

procedure TFrmMain.LbSpeedButton2Click(Sender: TObject);
begin
  ECy[0].ShowSingleCyTest;
end;

procedure TFrmMain.BtnRunParaClick(Sender: TObject);
begin
  Ecy[0].ShowRunSigSetting;
 { FrmTestSignal:=TFrmTestSignal.Create(Application);
  FrmTestSignal.CH_ID:=CH_ID;
  FrmTestSignal.ShowModal;
  FrmTestSignal.Free;    }
end;

procedure TFrmMain.LoadSensorPara;
var Str:string;
    Data:array[0..10]of Single;
begin
  Str:=SetupFile.ReadString('传感器'+inttostr(CH_ID)+'参数','角度','1 0');
  GetDataFromString(Str,Data);
  AngleGain[CH_ID]:=Data[0];   AngleOff[CH_ID]:=Data[1];

  Str:=SetupFile.ReadString('传感器'+inttostr(CH_ID)+'参数','扭矩','1 0');
  GetDataFromString(Str,Data);
  TorqueGain[CH_ID]:=Data[0];   TorqueOff[CH_ID]:=Data[1];
end;

procedure TFrmMain.SaveParaToText;
begin
  SetupFile.WriteInteger('总试验次数','通道'+inttostr(CH_ID),RunMaxCount[CH_ID]);
  SetupFile.WriteInteger('已试验次数','通道'+inttostr(CH_ID),NowRunCount[CH_ID]);
  SetupFile.WriteString('转角校正','通道'+inttostr(CH_ID),FloatToStr(AngleOff[CH_ID]));
end;

procedure TFrmMain.LbSpeedButton1Click(Sender: TObject);
begin

  FrmSensorSetting:=TFrmSensorSetting.Create(Application);
  FrmSensorSetting.CH_ID:=CH_ID;
  FrmSensorSetting.ShowModal;
  FrmSensorSetting.Free;
end;

procedure TFrmMain.ClearRunCountClick(Sender: TObject);
begin
  HistoryCount[CH_ID]:=0;
  SetupFile.WriteInteger('已试验次数','通道'+inttostr(CH_ID),0);
end;

procedure TFrmMain.OutputA1Change(Sender: TObject);
begin
  RunMaxCount[CH_ID]:=Round(OutputA1.Value);
  SetupFile.WriteInteger('总试验次数','通道'+inttostr(CH_ID),RunMaxCount[CH_ID]);
end;

procedure TFrmMain.StopRunClick(Sender: TObject);
begin
   ECy[0].Stop;
   RunState:=0;
   SaveDataFlag[CH_ID]:=True;
   SaveParaToText;
   SaveFile(CH_ID);
   SaveAllDataFile(CH_ID);
   BtnCurver.Color:=clSilver;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ECy[0].Stop;
  RunState:=0;
  SaveFile(CH_ID);
  SaveAllDataFile(CH_ID);
  SaveParaToText;
end;

procedure TFrmMain.PositionSetZeroClick(Sender: TObject);
begin
   ECy[0].SetZero;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  RunState:=0;
  ShowPlotState:=0 ;
 // S_Angle:=TSensor.Create(80);
 // S_Torque:=TSensor.Create(80);
  LoadSensorPara;
  TorqueResetState:=0;
  AngleResetState:=0;
  Plot1.UpdateFrameRate:=2;
  MyTimer[CH_ID]:=TMyTimer.Create;
  RunMaxCount[CH_ID]:=SetupFile.ReadInteger('总试验次数','通道'+inttostr(CH_ID),0);
  OutputA1.Value:=RunMaxCount[CH_ID];
  HistoryCount[CH_ID]:=SetupFile.ReadInteger('已试验次数','通道'+inttostr(CH_ID),0);
  NowRunCount[CH_ID]:=HistoryCount[CH_ID];
  LastRunCount[CH_ID]:=NowRunCount[CH_ID];
  Timer1.Enabled:=true;
end;

procedure TFrmMain.AngleSetZeroClick(Sender: TObject);
begin
   AngleOff[CH_ID]:=Ecy[1].TD.speed;
   //SetupFile.WriteString('传感器'+inttostr(CH_ID)+'参数','角度',floattostr(AngleOff[CH_ID]));
  //S_Angle.off:= S_Angle.Value+ S_Angle.off;
end;

procedure TFrmMain.ShowDisp;
begin
  NowAngleDisp.Value:=NowAngle[CH_ID];
  NowTorqueDisp.Value:=NowTorque[CH_ID];
  if ECy[0]<>nil then NowPositionDisp.Value:=ECy[0].TD.actpos;
  NowRunCountDisp.Value:=NowRunCount[CH_ID];
  NowMaxAngleDisp.Value:=MaxAngle[CH_ID];
  NowMinAngleDisp.Value:=MinAngle[CH_ID];

  InitMaxTorqueDisp.Value:= AveMaxTorque[CH_ID];
  InitMinTorqueDisp.Value:= AveMinTorque[CH_ID];
  NowMaxTorqueDisp.Value:=MaxTorque[CH_ID];
  NowMinTorqueDisp.Value:=MinTorque[CH_ID];
  NowMaxTorqueDisp.Value:=MaxTorque[CH_ID];
  NowMinTorqueDisp.Value:=MinTorque[CH_ID];

  MaxTorqueOffDisp.Value:=MaxTorqueOff[CH_ID];
  MinTorqueOffDisp.Value:=MinTorqueOff[CH_ID];


end;

procedure TFrmMain.RunCountSetZeroClick(Sender: TObject);
begin
  HistoryCount[CH_ID]:=0;
  SetupFile.WriteInteger('已试验次数','通道'+inttostr(CH_ID),0);
  NowRunCountDisp.Value:=0;
end;

procedure TFrmMain.AngleResetClick(Sender: TObject);
begin
  AngleResetFlag:=True;
  AngleResetState:=1;
end;

procedure TFrmMain.BtnResetClick(Sender: TObject);
begin
  TorqueResetFlag:=True;
  TorqueResetState:=1;
end;

end.
